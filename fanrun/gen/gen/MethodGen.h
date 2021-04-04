//
//  CodeGen.h
//  gen
//
//  Created by yangjiandong on 2017/9/16.
//  Copyright © 2017年 yangjiandong. All rights reserved.
//

#ifndef MethodGen_h
#define MethodGen_h

#include "fcode/PodLoader.h"
#include "fcode/Printer.h"
#include "ir/IRMethod.h"
#include "TypeGen.h"

struct MethodGen {
    TypeGen *parent;
    FMethod *method;
    std::string name;
    
    bool isStatic;
    
    MethodGen(TypeGen *parent, FMethod *method);
    
    void genDeclares(Printer *printer, bool funcPtr, bool isValType);
    void genNativePrototype(Printer *printer, bool funcPtr, bool isValType);
    void genImples(Printer *printer);
    void genImplesToVal(Printer *printer);
    void genStub(Printer *printer);
    
    void genRegisterWrap(Printer *printer, bool isValType);
    void genRegister(Printer *printer);
private:
    std::string getTypeDeclName(uint16_t tid, bool forPass = false);
    bool genPrototype(Printer *printer, bool funcPtr, bool isValType);
    void genMethodStub(Printer *printer, bool isValType);
};

#endif /* MethodGen_h */
