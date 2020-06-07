//
//  LLVMCodeGen.cpp
//  vm
//
//  Created by yangjiandong on 16/9/16.
//  Copyright © 2017 chunquedong. All rights reserved.
//

#include "LLVMCodeGen.hpp"
//#include "Env.h"
#include "FCodeUtil.hpp"
#include "LLVMGenCtx.hpp"
#include "LLVMStruct.hpp"

using namespace llvm;

LLVMCodeGen::LLVMCodeGen(LLVMGenCtx *ctx, IRMethod *irMethod, std::string &name)
    : ctx(ctx), builder(*ctx->context), irMethod(irMethod), name(name)
    , envVar(NULL), errVar(NULL), errTableBlock(NULL), errOccurAt(NULL), returnVar(NULL) {

    FCodeUtil::escapeIdentifierName(name);
}

llvm::Function* LLVMCodeGen::getFunctionProto(IRMethod *irMethod, bool *isNative) {
    return getFunctionProtoByDef(ctx, builder, irMethod->method, isNative);
}

llvm::Function* LLVMCodeGen::getFunctionProtoByDef(LLVMGenCtx *ctx, llvm::IRBuilder<> &builder, FMethod *method, bool *isNative) {
    const std::string &name = method->c_mangledName;
    if (auto* function = ctx->module->getFunction(name)) return function;
    
    FPod *pod = method->c_parent->c_pod;
    llvm::Type *returnType = ctx->toLlvmType(pod, method->returnType);
    
    llvm::SmallVector<llvm::Type*, 16> paramTypes;
    //call c native
    if ((method->flags & FFlags::Native) && method->code.isEmpty() && (method->flags & FFlags::Static)) {
        //pass
        *isNative = true;
    }
    else {
        paramTypes.push_back(ctx->ptrType);//env
        *isNative = false;
        if (!returnType->isVoidTy()) {
            llvm::Type *retType = returnType->getPointerTo();
            paramTypes.push_back(retType);
        }
        returnType = ctx->ptrType;
    }
    
    if (!method->isStatic()) {
        paramTypes.push_back(ctx->toLlvmType(pod, method->c_parent->meta.self));
    }
    
    for (int i=0; i < method->paramCount; ++i) {
        FMethodVar &v = method->vars[i];
        paramTypes.push_back(ctx->toLlvmType(pod, v.type));
    }
    
    auto* llvmFunctionType = llvm::FunctionType::get(returnType, paramTypes, false);
    auto* function = llvm::Function::Create(llvmFunctionType, LLVMStruct::toLinkageType(method->flags), name, ctx->module);
    
    return function;
}

llvm::Function* LLVMCodeGen::getFunctionProtoByRef(FPod *curPod, FMethodRef *ref, bool *isNative) {
    //std::string name = curPod->names[ref->name];
    FType *ftype = FCodeUtil::getFTypeFromTypeRef(curPod, ref->parent);
    //std::string typeName = FCodeUtil::getTypeRefName(curPod, ref->parent, false);
    std::string mthName = FCodeUtil::getIdentifierName(curPod, ref->name);
    if ((ref->flags & FFlags::RefSetter) || (ref->flags & FFlags::RefOverload)) {
        mthName += std::to_string(ref->paramCount);
    }
    
    std::unordered_map<std::string, FMethod*>::iterator itr = ftype->c_methodMap.find(mthName);
    if (itr == ftype->c_methodMap.end()) {
        printf("ERROR: found not found: %s\n", mthName.c_str());
        abort();
    }
    FMethod *fmethod = itr->second;
    
    return getFunctionProtoByDef(ctx, builder, fmethod, isNative);
//
//    std::string name = typeName + "_" + mthName;
//
//    if (auto* function = module->getFunction(name)) return function;
//
//    llvm::SmallVector<llvm::Type*, 16> paramTypes;
//    if (!isStatic) {
//        paramTypes.push_back(ctx->toLlvmType(curPod, ref->parent));
//    }
//    for (int i=0; i < ref->paramCount; ++i) {
//        uint16_t tf = ref->params[i];
//        paramTypes.push_back(ctx->toLlvmType(curPod, tf));
//    }
//    llvm::Type *returnType = ctx->toLlvmType(curPod, ref->retType);
//
//    auto* llvmFunctionType = llvm::FunctionType::get(returnType, paramTypes, false);
//    auto* function = llvm::Function::Create(llvmFunctionType, llvm::Function::ExternalLinkage, name, module);
//
//    return function;
}

llvm::Function *LLVMCodeGen::gen(Module *M) {
    module = M;
    bool isNative;
    function = getFunctionProto(irMethod, &isNative);
    
    //set args name
    Argument *argx = &*function->arg_begin();// Get the arg
    //argx->setName("env");
    //++argx;
    if (!isNative) {
        argx->setName("env");
        envVar = argx;
        ++argx;
        if (!irMethod->isVoid) {
            argx->setName("returnVar");
            returnVar = argx;
            ++argx;
        }
    }
    if (!irMethod->method->isStatic()) {
        argx->setName("self");
        ++argx;
    }
    for (int i=0; i < irMethod->method->paramCount; ++i) {
        FMethodVar &v = irMethod->method->vars[i];
        argx->setName(irMethod->curPod->names[v.name]);
        ++argx;
    }
    
    BasicBlock *enterBlock = BasicBlock::Create(*ctx->context, "enterBlock", function);
    builder.SetInsertPoint(enterBlock);
    
    if (irMethod->errTable.size() > 0) {
        errVar = builder.CreateAlloca(ctx->ptrType);
        errVar->setName("errVar");
        //builder.CreateStore(llvm::ConstantPointerNull::get(ctx->ptrType), curErrVar);
        errOccurAt = builder.CreateAlloca(ctx->intType);
        errOccurAt->setName("errOccurAt");
    }
    
    //init params
    for (int j=0; j<irMethod->methodVars->locals.size(); ++j) {
        //args in block0
        if (j < function->arg_size()) {
            Argument *argx = (function->arg_begin()+j);
            locals.push_back(argx);
            continue;
        }
        Var &v = irMethod->methodVars->locals[j];
        llvm::Value *var = builder.CreateAlloca(ctx->ptrType);
        var->setName(v.name);
        locals.push_back(var);
    }
    
    for (int i=0; i<irMethod->blocks.size(); ++i) {
        Block *b = irMethod->blocks[i];
        BasicBlock *BB = BasicBlock::Create(*ctx->context, "block_"+std::to_string(b->index), function);
        b->llvmBlock = BB;
        for (int j=0; j<b->locals.size(); ++j) {
            //args in block0
            if (b->locals[j].isExport) {
                //builder.SetInsertPoint(enterBlock);
                llvm::Value *var = builder.CreateAlloca(ctx->ptrType);
                var->setName(b->locals[j].name);
                locals.push_back(var);
            }
            else {
                locals.push_back(nullptr);
            }
        }
    }
    
    if (irMethod->blocks.size() > 0) {
        builder.CreateBr((BasicBlock*)irMethod->blocks[0]->llvmBlock);
    }
    
    genErrTable();
    
    for (int i=0; i<irMethod->blocks.size(); ++i) {
        Block *b = irMethod->blocks[i];
        genBlock(b);
    }
    
    return function;
}

void LLVMCodeGen::genErrTable() {
    if (irMethod->errTable.size() == 0) return;
    errTableBlock = BasicBlock::Create(*ctx->context, "errTable", function);
    builder.SetInsertPoint(errTableBlock);
    
    llvm::Value *errVal = builder.CreateLoad(errVar->getType()->getPointerElementType(), errVar);
    
    for (FErrTable *errTable : irMethod->errTable) {
        for (FTrap &trap : errTable->traps) {
            llvm::Value *start = llvm::ConstantInt::get(ctx->intType, trap.start, true);
            llvm::Value *end = llvm::ConstantInt::get(ctx->intType, trap.end, true);
            llvm::Value *cond = builder.CreateAnd(builder.CreateICmpSLT(errOccurAt, start),
                              builder.CreateICmpSGT(end, errOccurAt));
            
            llvm::Value *errType = ctx->getStructByName(irMethod->curPod, "sys", "Err")->getClassVar();
            llvm::Value *vtable = getClassVTable(errVal);
            Constant* typeFits = module->getOrInsertFunction("fr_typeFits", Type::getInt1Ty(*ctx->context), ctx->ptrType, ctx->ptrType);
            llvm::Value *typeFitsRes = builder.CreateCall(typeFits, { vtable,  errType});
            //llvm::Value *res = builder.CreateICmpEQ(vtable, type);
            
            llvm::Value *cond2 = builder.CreateAnd(cond, typeFitsRes);
            BasicBlock *errNext = BasicBlock::Create(*ctx->context, "errNext", function);
            builder.SetInsertPoint(errNext);
            builder.CreateCondBr(cond2, (llvm::BasicBlock*)trap.c_handler, errNext);
        }
    }
    
    //default
    builder.CreateRet(errVal);
}

void LLVMCodeGen::genBlock(Block *block) {
    //BasicBlock *parent = builder.GetInsertBlock();
    BasicBlock *BB = (BasicBlock*)block->llvmBlock;
    //builder.CreateBr(BB);
    
    builder.SetInsertPoint(BB);
    
    for (Stmt *t : block->stmts) {
        genStmt(t, block);
    }
}

void LLVMCodeGen::genCall(CallStmt *s, Block *block) {
    bool isNative;
    llvm::Function *callee = getFunctionProtoByRef(irMethod->curPod, s->methodRef, &isNative);
    
    llvm::Value *vtable = NULL;
    bool isVirtual = s->isVirtual || s->isMixin;
    if (!s->isStatic && isVirtual) {
        FType *ftype = FCodeUtil::getFTypeFromTypeRef(irMethod->curPod, s->methodRef->parent);
        //struct
        if (ftype->meta.flags & FFlags::Struct) {
            if (s->isMixin) {
                Expr &expr = s->params.at(0);
                Var &v = expr.block->locals[expr.index];
                if (v.type.isValue) {
                    vtable = ctx->getStructByName(irMethod->curPod, v.type.pod, v.type.name)->getClassVar();
                }
            }
        }
        //normal
        else {
            llvm::Value *instance = getExpr(s->params.at(0));
            if (s->isMixin) {
                vtable = getVTable(s->params.at(0));
            }
            else {
                vtable = getClassVTable(instance);
            }
        }
    }
    
    if (vtable) {
        LLVMStruct *clz = ctx->getStruct(irMethod->curPod, s->methodRef->parent);
        int offset = clz->irType->vtables.at(0)->funcOffset(s->mthName);
        offset += LLVMStruct::virtualTableHeader;
        llvm::Value *mth = builder.CreateStructGEP(vtable, offset);
        callee = (llvm::Function*)builder.CreateBitCast(mth, callee->getType());
    }
    
    llvm::Value *retVal = NULL;
    llvm::SmallVector<llvm::Value*, 16> args;
    if (!isNative) {
        args.push_back(envVar);
        if (!s->isVoid) {
            llvm::Type *returnType = ctx->toLlvmType(irMethod->curPod, s->methodRef->retType);
            retVal = builder.CreateAlloca(returnType);
            args.push_back(retVal);
        }
    }
    
    for (int i=0; i<s->params.size(); ++i) {
        Expr &expr = s->params[i];
        Value *val = getExpr(expr);
        args.push_back(val);
    }
    
    llvm::Value *errVal = builder.CreateCall(callee, args);
    if (!s->isVoid) {
        setExpr(s->retValue, retVal);
    }
    genCheckErr(errVal, block);
}

void LLVMCodeGen::genCheckErr(llvm::Value *errVal, Block *block) {
    llvm::Value *isNull = builder.CreateIsNull(errVal);
    BasicBlock *normalBlock = BasicBlock::Create(*ctx->context, "endCall", function);
    BasicBlock *errBlock = BasicBlock::Create(*ctx->context, "errCall", function);
    builder.CreateCondBr(isNull, normalBlock, errBlock);
    
    builder.SetInsertPoint(errBlock);
    if (errTableBlock) {
        builder.CreateStore(errVal, errVar);
        builder.CreateStore(llvm::ConstantInt::get(ctx->intType, block->pos), errOccurAt);
        builder.CreateBr(errTableBlock);
    }
    else {
        builder.CreateRet(errVal);
    }
    builder.SetInsertPoint(normalBlock);
}

void LLVMCodeGen::genCompare(CompareStmt *stmt) {
    FPod *curPod = irMethod->curPod;
    
    if (stmt->opObj.opcode == FOp::CompareNull) {
        llvm::PointerType *t = Type::getInt8PtrTy(*ctx->context);
        llvm::Value *v1 = llvm::ConstantPointerNull::get(t);
        llvm::Value *v2 = getExpr(stmt->param1);
        llvm::Value *res = builder.CreateICmpEQ(v1, v2);
        setExpr(stmt->result, res);
        return;
    }
    else if (stmt->opObj.opcode == FOp::CompareNotNull) {
        llvm::PointerType *t = Type::getInt8PtrTy(*ctx->context);
        llvm::Value *v1 = llvm::ConstantPointerNull::get(t);
        llvm::Value *v2 = getExpr(stmt->param1);
        llvm::Value *res = builder.CreateICmpNE(v1, v2);
        setExpr(stmt->result, res);
        return;
    }
    
    std::string name= FCodeUtil::getTypeRefName(curPod, stmt->opObj.i1, false);
    if (!FCodeUtil::isBuildinVal(name)) {
        //must struct type
        Constant* compare = module->getOrInsertFunction("memcmp", Type::getInt32Ty(*ctx->context), ctx->ptrType, ctx->ptrType, Type::getInt32Ty(*ctx->context));
        llvm::Value *v1 = getExpr(stmt->param1);
        llvm::Value *v2 = getExpr(stmt->param2);
        llvm::Value *s = llvm::ConstantExpr::getSizeOf(v1->getType()->getPointerElementType());
        llvm::Value *res = builder.CreateCall(compare, { v1, v2, s });
        setExpr(stmt->result, res);
        return;
    }
    
    //llvm::Type* type = ctx->objPtrType(curPod);
    llvm::Value *v1 = getExpr(stmt->param1);
    llvm::Value *v2 = getExpr(stmt->param2);
    llvm::Value *res = NULL;
    
    if (stmt->param1.getTypeName() == "sys_Float") {
        switch (stmt->opObj.opcode) {
            case FOp::CompareEQ: {
                res = builder.CreateFCmpOEQ(v1, v2);
            } break;
            case FOp::CompareNE: {
                res = builder.CreateFCmpONE(v1, v2);
            } break;
            case FOp::Compare: {
                res = builder.CreateFSub(v1, v2);
            } break;
            case FOp::CompareLT: {
                res = builder.CreateFCmpOLT(v1, v2);
            } break;
            case FOp::CompareLE: {
                res = builder.CreateFCmpOLE(v1, v2);
            } break;
            case FOp::CompareGT: {
                res = builder.CreateFCmpOGT(v1, v2);
            } break;
            case FOp::CompareGE: {
                res = builder.CreateFCmpOGE(v1, v2);
            } break;
            default:
                break;
        }
    }
    else {
        switch (stmt->opObj.opcode) {
            case FOp::CompareEQ: {
                res = builder.CreateICmpEQ(v1, v2);
            } break;
            case FOp::CompareNE: {
                res = builder.CreateICmpNE(v1, v2);
            } break;
            case FOp::Compare: {
                res = builder.CreateSub(v1, v2);
            } break;
            case FOp::CompareLT: {
                res = builder.CreateICmpSLT(v1, v2);
            } break;
            case FOp::CompareLE: {
                res = builder.CreateICmpSLE(v1, v2);
            } break;
            case FOp::CompareGT: {
                res = builder.CreateICmpSGT(v1, v2);
            } break;
            case FOp::CompareGE: {
                res = builder.CreateICmpSGE(v1, v2);
            } break;
            default:
                break;
        }
    }
    setExpr(stmt->result, res);
}

llvm::Value *LLVMCodeGen::constFromStr(const std::string &pod, const std::string &typeName, const std::string &str, Block *block) {
    FPod *curPod = irMethod->curPod;
    llvm::Value *cstring = builder.CreateGlobalStringPtr(str.c_str());
    llvm::Value *size = llvm::ConstantInt::get(llvm::Type::getInt32Ty(*ctx->context), str.size(), true);
    
    llvm::Type* type = ctx->getLlvmType(curPod, pod, typeName);
    std::string funcName = pod+"_" + typeName + "_fromCStr";
    auto* stringInit = module->getOrInsertFunction(funcName, ctx->ptrType,
                                                   envVar->getType(), type->getPointerTo(),
                                                   cstring->getType(), size->getType());
    llvm::Value *retVal = builder.CreateAlloca(type);
    llvm::Value *err = builder.CreateCall(stringInit, { envVar, retVal, cstring, size });
    genCheckErr(err, block);
    return retVal;
}

void LLVMCodeGen::getConst(ConstStmt *s, Block *block) {
    FPod *curPod = irMethod->curPod;
    llvm::Value *v = NULL;
    switch (s->opObj.opcode) {
        case FOp::LoadNull: {
            llvm::PointerType *t = Type::getInt8PtrTy(*ctx->context);
            v = llvm::ConstantPointerNull::get(t);
            break;
        }
        case FOp::LoadFalse: {
            v = llvm::ConstantInt::getFalse(*ctx->context);
            break;
        }
        case FOp::LoadTrue: {
            v = llvm::ConstantInt::getTrue(*ctx->context);
            break;
        }
        case FOp::LoadInt: {
            llvm::Type *t = llvm::Type::getInt64Ty(*ctx->context);
            v = llvm::ConstantInt::get(t, curPod->constantas.ints[s->opObj.i1], true);
            break;
        }
        case FOp::LoadFloat: {
            llvm::Type *t = llvm::Type::getDoubleTy(*ctx->context);
            v = llvm::ConstantFP::get(t, curPod->constantas.reals[s->opObj.i1]);
            break;
        }
        case FOp::LoadDecimal: {
            //res.name = "Decimal";
            const std::string &str = curPod->constantas.decimals[s->opObj.i1];
            v = constFromStr("std", "Decimal", str, block);
            break;
        }
        case FOp::LoadStr: {
            //res.name = "Str";
            const std::string &str = curPod->constantas.strings[s->opObj.i1];
            v = constFromStr("sys", "Str", str, block);
            break;
        }
        case FOp::LoadDuration: {
            //res.name = "Duration";
            int64_t mills = curPod->constantas.durations[s->opObj.i1];
            llvm::Value *millsValue = llvm::ConstantInt::get(llvm::Type::getInt64Ty(*ctx->context), mills);
            
            llvm::Type* type = ctx->getLlvmType(curPod, "std", "Duration");
            Constant* init = module->getOrInsertFunction("std_Duration_fromMills", ctx->ptrType,
                                                         envVar->getType(), type->getPointerTo(),
                                                         llvm::Type::getInt64Ty(*ctx->context));
            llvm::Value *retVal = builder.CreateAlloca(type);
            builder.CreateCall(init, { envVar, retVal, millsValue });
            v = retVal;
            break;
        }
        case FOp::LoadUri: {
            //res.name = "Uri";
            const std::string &str = curPod->constantas.uris[s->opObj.i1];
            v = constFromStr("std", "Uri", str, block);
            break;
        }
        case FOp::LoadType: {
            //res.name = "Type";
            LLVMStruct *st = ctx->getStruct(curPod, s->opObj.i1);
            
            Constant* init = module->getOrInsertFunction("fr_toTypeObj", ctx->ptrType,
                                                         ctx->ptrType);
            v = builder.CreateCall(init, { st->getClassVar() });
            break;
        }
        default: {
            //res.name = "Obj";
            break;
        }
    }
    setExpr(s->dst, v);
}

void LLVMCodeGen::genStmt(Stmt *stmt, Block *block) {
    FPod *curPod = irMethod->curPod;
    
    StmtType stmtType = stmt->stmtType();
    switch (stmtType) {
        case StmtType::Const:
            if (ConstStmt *s = dynamic_cast<ConstStmt*>(stmt)) {
                getConst(s, block);
            }
            break;
        case StmtType::Store:
            if (StoreStmt *s = dynamic_cast<StoreStmt*>(stmt)) {
                //StoreStmt *s = dynamic_cast<StoreStmt*>(stmt);
                Value *src = getExpr(s->src);
                Value *dst = getExpr(s->dst);
                if (src->getType()->isPointerTy()) {
                    if (FCodeUtil::isValueTypeRef(curPod, s->src.getType().typeRef)) {
                        src = builder.CreateLoad(src->getType()->getPointerElementType(), src);
                    }
                }
                builder.CreateStore(src, dst);
            }
        break;
        case StmtType::Field:
            if (FieldStmt *s = dynamic_cast<FieldStmt*>(stmt)) {
                
                FFieldRef *fref = s->fieldRef;
                int index = ctx->fieldIndex(irMethod->curPod, fref);
                llvm::Type *t = ctx->toLlvmType(irMethod->curPod, fref->parent);
                llvm::Value *baseValue = getExpr(s->instance);
                
                std::string memberName = curPod->names[fref->name];
                llvm::Value *pos = builder.CreateStructGEP(t, baseValue, index, memberName);
                
                if (s->isLoad) {
                    llvm::Value *value = builder.CreateLoad(pos);
                    setExpr(s->value, value);
                }
                else {
                    llvm::Value *value = getExpr(s->value);
                    builder.CreateStore(value, pos);
                }
            }
            break;
        case StmtType::Call:
            if (CallStmt *s = dynamic_cast<CallStmt*>(stmt)) {
                genCall(s, block);
            }
            break;
        case StmtType::Compare:
            if (CompareStmt *s = dynamic_cast<CompareStmt*>(stmt)) {
                genCompare(s);
            }
            break;
        case StmtType::Return:
            if (ReturnStmt *s = dynamic_cast<ReturnStmt*>(stmt)) {
                if (!s->isVoid) {
                    llvm::Value *v = getExpr(s->retValue);
                    builder.CreateStore(v, returnVar);
                }
                builder.CreateRet(llvm::ConstantPointerNull::get(ctx->ptrType));
            }
            break;
        case StmtType::Jump:
            if (JumpStmt *s = dynamic_cast<JumpStmt*>(stmt)) {
                if (s->jmpType == JumpStmt::trueJmp) {
                    llvm::Value *condition = getExpr(s->expr);
                    builder.CreateCondBr(condition, (llvm::BasicBlock*)(s->targetBlock->llvmBlock), NULL);
                }
                else if (s->jmpType == JumpStmt::falseJmp) {
                    //condition = builder.CreateNot(genExpr(&s->expr));
                    llvm::Value *condition = getExpr(s->expr);
                    builder.CreateCondBr(condition, (llvm::BasicBlock*)(s->targetBlock->llvmBlock), NULL)->swapSuccessors();
                }
                else {
                    builder.CreateBr((llvm::BasicBlock*)(s->targetBlock->llvmBlock));
                }
            }
            break;
        case StmtType::Alloc:
            if (AllocStmt *s = dynamic_cast<AllocStmt*>(stmt)) {
                LLVMStruct *structT = ctx->getStruct(curPod, s->type);
                llvm::Type *type = structT->structTy;
                llvm::Value *sizeValue = llvm::ConstantExpr::getSizeOf(type);
                
                llvm::Value *classVar = structT->getClassVar();
                llvm::Value *classVarV = builder.CreateBitCast(classVar, ctx->ptrType);
                Constant* alloc = module->getOrInsertFunction("fr_alloc", ctx->ptrType, ctx->ptrType, sizeValue->getType());
                llvm::Value *resV = builder.CreateCall(alloc, { classVarV, sizeValue });
                llvm::Value *res = builder.CreateBitCast(resV, type->getPointerTo());
                setExpr(s->obj, res);
            }
            break;
        case StmtType::Throw:
            if (ThrowStmt *s = dynamic_cast<ThrowStmt*>(stmt)) {
                llvm::Value *v = getExpr(s->var);
                
                if (errTableBlock) {
                    llvm::Value *errVal = builder.CreateBitCast(v, ctx->ptrType);
                    builder.CreateStore(errVal, errVar);
                    builder.CreateStore(llvm::ConstantInt::get(ctx->intType, block->pos), errOccurAt);
                    builder.CreateBr(errTableBlock);
                }
                else {
                    builder.CreateRet(v);
                }
//                Constant* std_throw = module->getOrInsertFunction("fr_throw", Type::getVoidTy(*ctx->context), ctx->ptrType);
//                builder.CreateCall(std_throw, { v });
            }
            break;
        case StmtType::Exception:
            if (ExceptionStmt *s = dynamic_cast<ExceptionStmt*>(stmt)) {
                if (s->etype == ExceptionStmt::CatchStart) {
                    if (s->catchType != -1) {
                        llvm::Type *catchType = ctx->toLlvmType(curPod, s->catchType);
                        llvm::Value *catchVar = builder.CreateBitCast(errVar, catchType);
                        setExpr(s->catchVar, catchVar);
                    }
                }
            }
            break;
        case StmtType::Coerce:
            if (CoerceStmt *s = dynamic_cast<CoerceStmt*>(stmt)) {
                llvm::Value *from = getExpr(s->from);
                if (s->fromType == -1 || s->toType == -1) {
                    TypeInfo &tinfo = s->to.getType();
                    if (tinfo.typeRef == -1) return;
                    llvm::Type *type = ctx->getLlvmType(curPod, tinfo.pod, tinfo.name);
                    llvm::Value *res = builder.CreateBitCast(from, type);
                    setExpr(s->to, res);
                    return;
                }
                //TODO
                llvm::Type *type = ctx->toLlvmType(curPod, s->toType);
                llvm::Value *res = builder.CreateBitCast(from, type);
                setExpr(s->to, res);
            }
            break;
        case StmtType::TypeCheck:
            if (TypeCheckStmt *s = dynamic_cast<TypeCheckStmt*>(stmt)) {
                llvm::Value *vtable = getVTable(s->obj);
                llvm::Value *type = ctx->getStruct(curPod, s->type)->getClassVar();
                
                Constant* fr_typeFits = module->getOrInsertFunction("fr_typeFits", Type::getInt1Ty(*ctx->context), ctx->ptrType, ctx->ptrType);
                llvm::Value *res = builder.CreateCall(fr_typeFits, { vtable,  type});
                //llvm::Value *res = builder.CreateICmpEQ(vtable, type);
                setExpr(s->result, res);
            }
    }
}

llvm::Value *LLVMCodeGen::getExpr(Expr &expr) {
    int pos = expr.block->locals[expr.index].newIndex;
    return locals[pos];
}

void LLVMCodeGen::setExpr(Expr &expr, llvm::Value *v) {
    int pos = expr.block->locals[expr.index].newIndex;
    locals[pos] = v;
}

llvm::Value *LLVMCodeGen::getClassVTable(llvm::Value *v) {
//    llvm::Type *int64Ty = llvm::Type::getInt64Ty(*ctx->context);
//    llvm::Value *offset = llvm::ConstantInt::getSigned(int64Ty, -2);
//    llvm::Value *value = builder.CreateBitCast(v, ctx->pptrType);
//    llvm::Value *headerPP = builder.CreateGEP(value, offset);
//    llvm::Value *headerPtr = builder.CreateBitCast(headerPP, ctx->pptrType);
//    llvm::Value *header = builder.CreateLoad(headerPtr);
//    return header;
    
    llvm::Value *value = builder.CreateBitCast(v, ctx->ptrType);
    Constant* getITable = module->getOrInsertFunction("fr_getVTable", ctx->ptrType, ctx->ptrType);
    return builder.CreateCall(getITable, { value });
}

llvm::Value *LLVMCodeGen::getVTable(Expr &expr) {
    Var &v = expr.block->locals[expr.index];
    int pos = v.newIndex;
    
    if (!v.type.isMixin) {
        llvm::Value *vtable = getClassVTable(locals[pos]);
        return vtable;
    }
    FPod *curPod = irMethod->curPod;
    llvm::Value *type = ctx->getStruct(curPod, v.type.typeRef)->getClassVar();
    Constant* getITable = module->getOrInsertFunction("fr_getITable", ctx->ptrType, ctx->ptrType, ctx->ptrType);
    
    llvm::Value *value = builder.CreateBitCast(locals[pos], ctx->ptrType);
    return builder.CreateCall(getITable, { value,  type});
}
