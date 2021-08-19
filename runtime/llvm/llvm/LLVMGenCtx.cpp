//
//  LLVMGenCtx.cpp
//  vm
//
//  Created by yangjiandong on 2019/8/11.
//  Copyright © 2019 yangjiandong. All rights reserved.
//

#include "LLVMGenCtx.hpp"
#include "FCodeUtil.hpp"
#include "LLVMStruct.hpp"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"

using namespace llvm;

LLVMGenCtx::LLVMGenCtx(IRModule *ir) : objPtrType_(nullptr) {
    irModule = ir;
    context = new llvm::LLVMContext();
    module = new llvm::Module("test", *context);
    ptrType = Type::getInt8PtrTy(*context);
    pptrType = ptrType->getPointerTo();
    
    intType = llvm::Type::getInt32Ty(*context);
    
    //llvm::SMDiagnostic err;
    //runtimeModule = parseIRFile("runtime.ll", err, *context);
}

LLVMGenCtx::~LLVMGenCtx() {
    delete module;
    delete context;
    delete irModule;
}

llvm::Type *LLVMGenCtx::objPtrType(FPod *curPod) {
    if (objPtrType_ == nullptr) {
        objPtrType_ = getStructByName(curPod, "sys", "Obj")->structPtr;
    }
    return objPtrType_;
}

LLVMStruct *LLVMGenCtx::getStruct(FPod *curPod, int16_t type) {
    IRType *irType = irModule->getType(curPod, type);
    return initType(irType);
}

LLVMStruct *LLVMGenCtx::initType(IRType *irType) {
    if (irType->llvmStruct == NULL) {
        LLVMStruct *s = new LLVMStruct(this, irType, irType->ftype->c_mangledName);
        irType->llvmStruct = s;
        s->init();
        return s;
    }
    return (LLVMStruct*)irType->llvmStruct;
}

LLVMStruct *LLVMGenCtx::getStructByName(FPod *curPod, const std::string &podName, const std::string &typeName) {
    IRType *irType = irModule->getTypeByName(curPod, podName, typeName);
    return initType(irType);
}

llvm::Type *LLVMGenCtx::getLlvmType(FPod *curPod, const std::string &podName, const std::string &typeName) {
    llvm::Type *buildValTy = nullptr;
    if (podName == "sys") {
        if (typeName == "Void") {
            return Type::getVoidTy(*context);
        }
        else if (typeName == "Ptr") {
            return ptrType;
        }
        if (typeName == "Int") {
            buildValTy = Type::getInt64Ty(*context);
        }
        else if (typeName == "Float") {
            buildValTy = Type::getDoubleTy(*context);
        }
        else if (typeName == "Bool") {
            buildValTy = Type::getInt1Ty(*context);
        }
    }
    
    LLVMStruct *ty = getStructByName(curPod, podName, typeName);
    return ty->structPtr;
}

llvm::Type *LLVMGenCtx::toLlvmType(FPod *pod, int16_t type) {
    FTypeRef &typeRef = pod->typeRefs[type];
    std::string &podName = pod->names[typeRef.podName];
    std::string &typeName = pod->names[typeRef.typeName];
    
    //primity type
    llvm::Type *buildValTy = nullptr;
    if (podName == "sys") {
        if (typeRef.extName.size() == 0) {
            if (typeName == "Void") {
                return Type::getVoidTy(*context);
            }
            else if (typeName == "Ptr") {
                return ptrType;
            }
            if (typeName == "Int") {
                buildValTy = Type::getInt64Ty(*context);
            }
            else if (typeName == "Float") {
                buildValTy = Type::getDoubleTy(*context);
            }
            else if (typeName == "Bool") {
                buildValTy = Type::getInt1Ty(*context);
            }
        }
        else if (typeRef.extName.size() > 0 && typeRef.extName[0] != '?' && typeRef.extName[0] != '<') {
            if (typeName == "Int") {
                if (typeRef.extName == "8") {
                    buildValTy = Type::getInt8Ty(*context);
                }
                else if (typeRef.extName == "16") {
                    buildValTy = Type::getInt16Ty(*context);
                }
                else if (typeRef.extName == "32") {
                    buildValTy = Type::getInt32Ty(*context);
                }
                else if (typeRef.extName == "64") {
                    buildValTy = Type::getInt64Ty(*context);
                }
            }
            else if (typeName == "Float") {
                if (typeRef.extName == "32") {
                    buildValTy = Type::getFloatTy(*context);
                }
                else if (typeRef.extName == "64") {
                    buildValTy = Type::getDoubleTy(*context);
                }
            }
        }
    }
    
    if (buildValTy) {
        bool isNullable = FCodeUtil::isNullableTypeRef(pod, type);
        if (isNullable) {
            return buildValTy->getPointerTo();
        }
        else {
            return buildValTy;
        }
    }
    
    //FType *ftype = FCodeUtil::getFTypeFromTypeRef(pod, type);
    //std::string name = ftype->c_mangledName;
    
    LLVMStruct *sty = getStruct(pod, type);
//    FType *ftype = FCodeUtil::getFTypeFromTypeRef(pod, type);
//    if (ftype->meta.flags & FFlags::Mixin) {
//        return sty->structTy;
//    }
//    if (ftype->c_mangledName == "sys_Str") {
//        printf("");
//    }
    
    return sty->structPtr;
}

int LLVMGenCtx::fieldIndex(FPod *curPod, FFieldRef *ref) {
    LLVMStruct *s = getStruct(curPod, ref->parent);
    
    std::string name = curPod->names[ref->name];
    return s->fieldIndex[name];
}
