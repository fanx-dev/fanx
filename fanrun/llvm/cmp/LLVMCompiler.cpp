//
//  LLVMCompiler.cpp
//  cmp
//
//  Created by yangjiandong on 2019/10/5.
//  Copyright © 2019 yangjiandong. All rights reserved.
//

#include "LLVMCompiler.hpp"
#include "LLVMCodeGen.hpp"
#include "llvm/Bitcode/BitcodeWriter.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Verifier.h"

#include "MBuilder.hpp"
#include "FCodeUtil.hpp"
#include "LLVMStruct.hpp"

LLVMCompiler::LLVMCompiler() : ctx(new IRModule()) {
    InitializeNativeTarget();
    InitializeNativeTargetAsmPrinter();
}

LLVMCompiler::~LLVMCompiler() {
    llvm_shutdown();
}

bool LLVMCompiler::complie(FPod *fpod) {
    
    llvm::IRBuilder<> builder(*ctx.context);
    llvm::FunctionType *FT = llvm::FunctionType::get(ctx.intType, /*not vararg*/false);
    llvm::Function *F = llvm::Function::Create(FT, llvm::Function::ExternalLinkage, "main", ctx.module);
    llvm::Value *env = llvm::ConstantPointerNull::get(ctx.ptrType);
    
    llvm::BasicBlock *BB = llvm::BasicBlock::Create(*ctx.context, "EntryBlock", F);
    builder.SetInsertPoint(BB);
    
    
    for (FType &ftype : fpod->types) {
        IRType *irType = ctx.irModule->defType(&ftype);
        LLVMStruct *ty = ctx.initType(irType);
        ty->genCode();
        
        builder.CreateCall(ty->initFunction, env);
    }
    
    builder.CreateRet(llvm::ConstantInt::get(ctx.intType, 0, true));
    
    if (true) {
//        std::error_code error;
//        llvm::raw_fd_ostream file("out.ll", error, llvm::sys::fs::F_None);
//        if (error) {
//            printf("%s\n", error.message().c_str());
//            return false;
//        }
//
//        ctx.module->print(file, nullptr,
//                      /*ShouldPreserveUseListOrder=*/false, /*IsForDebug=*/true);
//
//        file.flush();
        ctx.module->print(dbgs(), nullptr,
                          /*ShouldPreserveUseListOrder=*/false, /*IsForDebug=*/true);
    }
    
    llvm::verifyModule(*ctx.module, &llvm::errs());
    
    // Output the bitcode file to stdout
    //llvm::WriteBitcodeToFile(*ctx.module, outs());
    
    if (true) {
        std::error_code error;
        llvm::raw_fd_ostream file("out.bc", error, llvm::sys::fs::F_None);
        if (error) {
            printf("%s\n", error.message().c_str());
            return false;
        }
        llvm::WriteBitcodeToFile(*ctx.module, file);
        file.flush();
    }
    
    return true;
}


