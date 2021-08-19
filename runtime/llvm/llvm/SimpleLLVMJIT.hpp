//
//  LLVMCodeGen.cpp
//  vm
//
//  Created by yangjiandong on 16/9/16.
//  Copyright © 2017 chunquedong. All rights reserved.
//

#ifndef SimpleLLVMJIT_hpp
#define SimpleLLVMJIT_hpp

#include "llvm/ADT/STLExtras.h"
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/GenericValue.h"
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
#include "llvm/Support/Casting.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/raw_ostream.h"
#include <algorithm>
#include <cassert>
#include <memory>
#include <vector>
#include "../vm/ExeEngine.h"
#include "IRMethod.h"

using namespace llvm;

class SimpleLLVMJIT : public ExeEngine {
    LLVMContext Context;
    ExecutionEngine* EE;
public:
    SimpleLLVMJIT();
    ~SimpleLLVMJIT();
    bool run(Env *env);

private:
    void init();
    
    std::unique_ptr<Module> gen(Env *env, FMethod *method, std::string &name, uint16_t &jitLocalCount);
};

#endif /* SimpleLLVMJIT_hpp */
