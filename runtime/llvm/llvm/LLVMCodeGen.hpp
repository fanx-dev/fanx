//
//  LLVMCodeGen.hpp
//  vm
//
//  Created by yangjiandong on 16/9/16.
//  Copyright © 2017 chunquedong. All rights reserved.
//

#ifndef LLVMCodeGen_hpp
#define LLVMCodeGen_hpp

#include <stdio.h>
#include "IRMethod.h"

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

//class Env;
class LLVMStruct;
class LLVMGenCtx;

class LLVMCodeGen {
    std::string name;
    IRMethod *irMethod;
    llvm::IRBuilder<> builder;
    
    LLVMGenCtx *ctx;
    llvm::Module *module;
    
    llvm::Function *function;
    
    std::vector<llvm::Value*> locals;
    
    llvm::Value *envVar;
    llvm::Value *errVar;
    llvm::BasicBlock *errTableBlock;
    llvm::Value *errOccurAt;
    llvm::Value *returnVar;
    
public:
    
    LLVMCodeGen(LLVMGenCtx *ctx, IRMethod *irMethod, std::string &name);
    
    llvm::Function *gen(llvm::Module *M);
    
    static llvm::Function* getFunctionProtoByDef(LLVMGenCtx *ctx, llvm::IRBuilder<> &builder, FMethod *method, bool *isNative);
    
private:
    llvm::Function* getFunctionProto(IRMethod *irMethod, bool *isNative);
    llvm::Function* getFunctionProtoByRef(FPod *curPod, FMethodRef *ref, bool *isNative);
    void genBlock(Block *block);
    void genStmt(Stmt *stmt, Block *block);
    
    llvm::Value *getExpr(Expr &expr);
    void setExpr(Expr &expr, llvm::Value *v);
    llvm::Value *getClassVTable(llvm::Value *v);
    llvm::Value *getVTable(Expr &expr);
    
    void genCall(CallStmt *stmt, Block *block);
    void genCompare(CompareStmt *stmt);
    void getConst(ConstStmt *stmt, Block *block);
    void genCheckErr(llvm::Value *errVal, Block *block);
    llvm::Value *constFromStr(const std::string &pod, const std::string &type, const std::string &str, Block *block);
    
    void genErrTable();
    
};

#endif /* LLVMCodeGen_hpp */
