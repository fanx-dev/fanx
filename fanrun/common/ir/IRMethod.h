//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by yangjiandong on 16/9/10.
//

#ifndef ____IRMethod__
#define ____IRMethod__

#include "Stmt.hpp"


//Basic Block is min linear code
class Block {
public:
    int index;//id in method
    uint16_t pos;//position in buffer
    
    uint16_t beginOp;//begin postion in ops
    uint16_t endOp;//next ops position of last of pos
    
    std::vector<Stmt*> stmts;
    
    std::vector<Block*> branchs;
    std::vector<Block*> incoming;
    
    std::vector<Expr> stack;//temp stack
    
    std::vector<Var> locals;
    
    bool isVisited;//flag for builder
    bool isForward;//flag if no jump stmt at last
    
    FPod *curPod;
    
    void *llvmBlock;
    
    Block() : index(0), pos(0), beginOp(0), endOp(0), isVisited(false), isForward(false), curPod(NULL), llvmBlock(NULL) {
    }
    
    void print(IRMethod *method, Printer& printer, int pass);
    
    Var &newVar(uint16_t typeRef);
    
    Var &newVarAs(const TypeInfo &type);
    
    void addStmt(Stmt *stmt);
    
    void push(Expr &var) {
        stack.push_back(var);
    }
    Expr pop() {
        if (stack.size() == 0) {
            printf("ERROR: statck is empty\n");
            //abort();
            Expr var;
            return var;
        }
        Expr var = stack.back();
        stack.pop_back();
        return var;
    }
};


class IRMethod {
public:
    FMethod *method;
public:
    std::vector<Block *> blocks;
    Block *methodVars;//include paramCount args
    //std::vector<Var> locals;//include paramCount args
    
    uint16_t returnType;
    uint16_t selfType;
    uint8_t paramCount;//param count with self
    
    FPod *curPod;
    std::string name;
    bool isVoid;
    
    FErrTable *errTable;
    
    IRMethod(FPod *curPod, FMethod *method);
    
    void print(Printer& printer, int pass);
};

#endif /* defined(____IRMethod__) */
