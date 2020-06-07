//
//  LLVMStruct.cpp
//  vm
//
//  Created by yangjiandong on 2019/8/3.
//  Copyright © 2019 yangjiandong. All rights reserved.
//

#include "LLVMStruct.hpp"
#include "LLVMGenCtx.hpp"
#include "LLVMCodeGen.hpp"
#include "MBuilder.hpp"

int LLVMStruct::virtualTableHeader = 16;

LLVMStruct::LLVMStruct(LLVMGenCtx *ctx, IRType *irType, std::string &name)
    : ctx(ctx), builder(*ctx->context), irType(irType), initFunction(NULL) {
    this->structTy = llvm::StructType::create(*ctx->context, name);
    structPtr = structTy->getPointerTo();
    //structPtr = llvm::PointerType::getUnqual(structTy);
}

llvm::GlobalValue::LinkageTypes LLVMStruct::toLinkageType(uint32_t flags) {
    if (flags & FFlags::Private) {
        return llvm::GlobalValue::InternalLinkage;
    }
    else if (flags & FFlags::Internal) {
        return llvm::GlobalValue::InternalLinkage;
    }
    return llvm::GlobalValue::ExternalLinkage;
}

void LLVMStruct::init() {
    //init struct fileds
    std::vector<llvm::Type*> fieldTypes;
    //super class
    if (irType->ftype->meta.base != 0xFFFF && irType->ftype->c_mangledName == "sys_Obj") {
        LLVMStruct *base = ctx->getStruct(irType->fpod, irType->ftype->meta.base);
        fieldTypes.push_back(base->structTy);
    }
    
    FType *ftype = irType->ftype;
    for (int i=0; i<ftype->fields.size(); ++i) {
        FField &field = ftype->fields[i];
        const std::string &name = ftype->c_pod->names[field.name];
        llvm::Type *t = ctx->toLlvmType(ftype->c_pod, field.type);
        if (field.isStatic()) {
            llvm::GlobalVariable *sf = new llvm::GlobalVariable(*ctx->module, t, false
                                                                    , toLinkageType(field.flags), llvm::ConstantAggregateZero::get(t)
                                                                    , ftype->c_mangledName+"_"+name);
            staticFields[name] = sf;
            continue;
        }
        
        fieldTypes.push_back(t);
        fieldIndex[name] = (int)fieldTypes.size()-1;
    }
    
    if (ftype->meta.flags & FFlags::Mixin) {
        fieldTypes.clear();
        llvm::Type *obj = ctx->objPtrType(ftype->c_pod);
        fieldTypes.push_back(obj);
        //mixin vtable
        fieldTypes.push_back(ctx->ptrType);
    }
    
    structTy->setBody(std::move(fieldTypes));
    
    /////////////////////////////////////////////
    //init class var
    irType->initVTable();
    for (int i=0; i<irType->vtables.size(); ++i) {
        IRVTable *irVtable = irType->vtables[i];
        int virtaulCount = virtualTableHeader + (int)irVtable->functions.size();
        if (i == 0) {
            virtaulCount += irType->vtables.size()*2;
        }
        
        llvm::Type *arrayTy = llvm::ArrayType::get(ctx->ptrType, virtaulCount);
        
        llvm::GlobalVariable *classVar = new llvm::GlobalVariable(*ctx->module, arrayTy, false
                                                                  , llvm::GlobalValue::ExternalLinkage, llvm::ConstantAggregateZero::get(arrayTy)
                                                                  , irType->ftype->c_mangledName + "_class__");
        vtables.push_back(classVar);
    }

}

void LLVMStruct::genCode() {
    genClassInit();
    
    for (FMethod &method : irType->ftype->methods) {
        IRMethod ir(irType->fpod, &method);
        MBuilder mbuilder(method.code, ir);
        mbuilder.buildMethod(&method);
        
        LLVMCodeGen code(ctx, &ir, method.c_mangledName);
        code.gen(ctx->module);
        //this->declMethods[method.c_mangledName] = f;
    }
}

void LLVMStruct::setArrayAt(llvm::Value *vtable, int pos, llvm::Value *val) {
    llvm::Value *casted;
    if (val->getType()->isIntegerTy()) {
        casted = builder.CreateIntToPtr(val, ctx->ptrType);
    }
    else {
        casted = builder.CreateBitCast(val, ctx->ptrType);
    }
    llvm::Value *ptr = builder.CreateStructGEP(vtable, pos);
    builder.CreateStore(casted, ptr);
}

void LLVMStruct::genVTableAt(llvm::Value *vtable, int base, IRVTable *irVTable) {
    
    for (int i=0; i<irVTable->functions.size(); ++i) {
        IRVirtualMethod &vm = irVTable->functions[i];
        
        bool isNative;
        llvm::Function *func = LLVMCodeGen::getFunctionProtoByDef(ctx, builder, vm.method, &isNative);
        setArrayAt(vtable, base+i, func);
    }
}

void LLVMStruct::genClassInit() {
    
    llvm::FunctionType *FT = llvm::FunctionType::get(ctx->ptrType, ctx->ptrType, /*not vararg*/false);
    llvm::Function *F = llvm::Function::Create(FT, llvm::Function::ExternalLinkage, irType->ftype->c_mangledName+"_init__", ctx->module);
    
    initFunction = F;
    
    llvm::Value *env = F->arg_begin();
    env->setName("env");
    
    llvm::BasicBlock *BB = llvm::BasicBlock::Create(*ctx->context, "EntryBlock", F);
    builder.SetInsertPoint(BB);
    
    llvm::Value *ptr = builder.CreateStructGEP(getClassVar(), 0);
    llvm::Value *p0 = builder.CreateLoad(ctx->ptrType, ptr);
    llvm::BasicBlock *initBB = llvm::BasicBlock::Create(*ctx->context, "init", F);
    llvm::BasicBlock *retBB = llvm::BasicBlock::Create(*ctx->context, "ret", F);
    builder.CreateCondBr(builder.CreateIsNull(p0), initBB, retBB) ;
    builder.SetInsertPoint(retBB);
    builder.CreateRet(llvm::ConstantPointerNull::get(ctx->ptrType));
    builder.SetInsertPoint(initBB);
    
    llvm::Type *intType = llvm::Type::getInt64Ty(*ctx->context);
    //init vtable
    for (int i=0; i<irType->vtables.size(); ++i) {
        IRVTable *irVTable = irType->vtables[i];
        llvm::GlobalVariable *classVar = vtables[i];
        
        //init meta data
        llvm::Value *cstring = builder.CreateGlobalStringPtr(irVTable->owner->ftype->c_mangledName.c_str());
        setArrayAt(classVar, 0, cstring);
        
        llvm::Value *cstring2 = builder.CreateGlobalStringPtr(irVTable->type->ftype->c_mangledName.c_str());
        setArrayAt(classVar, 1, cstring2);
        
        setArrayAt(classVar, 3, llvm::ConstantInt::get(intType, irType->ftype->meta.flags, true));
        
        //init ITable
        if (i == 0) {
            int itableOffset = (int)irVTable->functions.size()+virtualTableHeader;
            setArrayAt(classVar, 4, llvm::ConstantInt::get(intType, itableOffset, true));
            int itableSize = (int)irType->vtables.size()-1;
            setArrayAt(classVar, 5, llvm::ConstantInt::get(intType, itableSize, true));
            
            for (int j=1; j<irType->vtables.size(); ++j) {
                llvm::Value *typeVar = ctx->initType(irType->vtables[j]->type)->getClassVar();
                setArrayAt(classVar, itableOffset + j-1, typeVar);
                setArrayAt(classVar, itableOffset + j-1, vtables[j]);
            }
        }
        
        genVTableAt(classVar, virtualTableHeader, irVTable);
    }
    
    genReflect(env);
    
    //call static init
    std::unordered_map<std::string, FMethod*>::iterator itr = irType->ftype->c_methodMap.find("static$init");
    if (itr != irType->ftype->c_methodMap.end()) {
        bool isNative;
        llvm::Function *func = LLVMCodeGen::getFunctionProtoByDef(ctx, builder, itr->second, &isNative);
        llvm::Value *errVal = builder.CreateCall(func, env);
        
        llvm::Value *isNull = builder.CreateIsNull(errVal);
        llvm::BasicBlock *normalBlock = llvm::BasicBlock::Create(*ctx->context, "endCall", F);
        llvm::BasicBlock *errBlock = llvm::BasicBlock::Create(*ctx->context, "errCall", F);
        builder.CreateCondBr(isNull, normalBlock, errBlock);
        
        builder.SetInsertPoint(errBlock);
        builder.CreateRet(errVal);
        builder.SetInsertPoint(normalBlock);
    }
    
    builder.CreateRet(llvm::ConstantPointerNull::get(ctx->ptrType));
}

void LLVMStruct::genReflect(llvm::Value *env) {
    llvm::Type *intType = llvm::Type::getInt64Ty(*ctx->context);
    llvm::Value *typeNameStr = builder.CreateGlobalStringPtr(irType->ftype->c_mangledName.c_str());
    
    //init reflect info
    llvm::Value *clzVar = builder.CreateBitCast(getClassVar(), ctx->ptrType);
    llvm::Value *type = builder.CreateAlloca(ctx->ptrType);
    llvm::Constant* registerF = ctx->module->getOrInsertFunction("sys_Type_register", ctx->ptrType
                                                                 , ctx->ptrType, ctx->pptrType, ctx->ptrType, ctx->ptrType, intType);
    builder.CreateCall(registerF, { env, type, clzVar
        , builder.CreateBitCast(typeNameStr, ctx->ptrType)
        , llvm::ConstantInt::get(intType, irType->ftype->meta.flags, true) });
    llvm::Value *typeVal = builder.CreateLoad(type);
    setArrayAt(getClassVar(), 2, typeVal);
    
    
    //TODO init fields methods mixins
}
