//
//  LLVMCompiler.hpp
//  cmp
//
//  Created by yangjiandong on 2019/10/5.
//  Copyright © 2019 yangjiandong. All rights reserved.
//

#ifndef LLVMCompiler_hpp
#define LLVMCompiler_hpp

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
#include "IRMethod.h"
#include "LLVMGenCtx.hpp"

#include <stdio.h>
using namespace llvm;

class LLVMCompiler {
    LLVMGenCtx ctx;
    
public:
    LLVMCompiler();
    ~LLVMCompiler();
    bool complie(FPod *fpod);
};

#endif /* LLVMCompiler_hpp */
