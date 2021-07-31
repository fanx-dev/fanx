//
//  Interpreter.h
//  vm
//
//  Created by yangjiandong on 15/9/26.
//  Copyright (c) 2015, yangjiandong. All rights reserved.
//

#ifndef __vm__Interpreter__
#define __vm__Interpreter__

#include <stdio.h>
#include "fcode/Code.h"
#include <unordered_map>
#include "fcode/FType.h"
#include "Env.h"
#include "../vm/ExeEngine.h"
#include <assert.h>

//class Env;
struct InterStackFrame;

struct Interpreter : public ExeEngine {
    Env *context;
private:
    InterStackFrame *frame() { return (InterStackFrame*)context->curFrame; }
public:
    bool run(Env *env);
    ~Interpreter() {}
    
private:
    void initVars();
    
    void runCode();
    
private:

    FErrTable *getErrTable();
    
private:
    bool exeStep();
    bool exception();
    void callNew(int16_t mid);
    void callMethod(int16_t mid, bool isVirtual);
private:
    void compareEq(int16_t t1, int16_t t2, bool notEq);
    void compare(int16_t t1, int16_t t2, fr_Int *ret);
    bool compareSame();
    bool compareNull();
    bool isTypeof(uint16_t tid, bool pop, std::string *msg = NULL);
    
    void pushBool(fr_Bool b) {
        fr_TagValue entry;
        entry.any.b = b;
        entry.type = fr_vtBool;
        context->push(&entry);
    }
    
    void pushObj(FObj *b) {
        fr_TagValue entry;
        entry.any.o = b;
        entry.type = fr_vtObj;
        context->push(&entry);
    }
    
    fr_Bool popBool() {
        fr_Bool i;
        fr_TagValue entry;
        bool rc = context->pop(&entry);
        assert(rc);
        assert(entry.type == fr_vtBool);
        i = entry.any.b;
        return i;
    }
    
    fr_Int popInt() {
        fr_Int i;
        fr_TagValue entry;
        bool rc = context->pop(&entry);
        assert(rc);
        assert(entry.type == fr_vtInt);
        i = entry.any.i;
        return i;
    }
};

#endif /* defined(__vm__Interpreter__) */
