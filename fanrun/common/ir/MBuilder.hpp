//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by yangjiandong on 16/9/10.
//

#ifndef IRBuilder_hpp
#define IRBuilder_hpp

#include <stdio.h>
#include "IRMethod.h"

/**
 * Convert fcode to IR
 */
class MBuilder {
    std::unordered_map<int16_t, Block*> posToBlock;

    std::vector<Block *> blocks;
    Block *methodVars;
    
    int allLocalsCount;
    FPod *curPod;
    
    IRMethod &irMethod;
    Code &code;
    FErrTable *errTable;
    
public:
    MBuilder(Code &code, IRMethod &irMethod);
    
    //parse code to basic block graph, and flat temp var to stack for gc
    bool buildMethod(FMethod *method);
    
    //bool buildDefParam(FMethod *method, int paramNum, bool isVal);
    
private:
    
    void doBuild();
    
    Var &newVar(int typeRef);
    
    void initJumpTarget();
    
    void initBlock();
    
    void linkBlock();
    
    void rewriteLocals();
    
    Expr asType(Block *block, Expr expr, TypeInfo &expectedType, int pos);
    
    void call(Block *block, FOpObj &opObj, bool isVirtual, bool isStatic
              , bool isMixin, bool isAlloc = false);
    
    void parseBlock(Block *block, Block *previous);
    
    void insertException();
};


#endif /* IRBuilder_hpp */
