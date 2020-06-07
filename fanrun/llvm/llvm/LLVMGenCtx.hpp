//
//  LLVMGenCtx.hpp
//  vm
//
//  Created by yangjiandong on 2019/8/11.
//  Copyright © 2019 yangjiandong. All rights reserved.
//

#ifndef LLVMGenCtx_hpp
#define LLVMGenCtx_hpp

#include <stdio.h>
#include "llvm/ADT/STLExtras.h"
#include "llvm/IR/Argument.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Type.h"
#include <algorithm>
#include <cassert>
#include <memory>
#include <vector>
#include <map>
#include <string>

#include "IRMethod.h"
#include "IRType.hpp"

class LLVMStruct;

class LLVMGenCtx {
    llvm::Type *objPtrType_;
public:
    llvm::LLVMContext *context;
    llvm::Module *module;
    
    IRModule *irModule;
        
    std::map<std::string, LLVMStruct*> structMap;
    
    llvm::PointerType *ptrType;
    llvm::PointerType *pptrType;
    llvm::Type *intType;
    
    //llvm::Type *valueType;
    //llvm::Type *pvalueType;
    
    LLVMGenCtx(IRModule *ir);
    ~LLVMGenCtx();
    
    llvm::Type *toLlvmType(FPod *curPod, int16_t type);
    llvm::Type *getLlvmType(FPod *curPod, const std::string &podName, const std::string &typeName);
    
    LLVMStruct *getStruct(FPod *curPod, int16_t type);
    
    LLVMStruct *initType(IRType *irType);
    
    int fieldIndex(FPod *curPod, FFieldRef *ref);
    
    llvm::Type *objPtrType(FPod *curPod);
    
    LLVMStruct *getStructByName(FPod *curPod, const std::string &podName, const std::string &typeName);
    
private:
};

#endif /* LLVMGenCtx_hpp */
