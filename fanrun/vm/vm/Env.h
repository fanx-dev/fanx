//
//  Interpreter.h
//  vm
//
//  Created by yangjiandong on 15/9/26.
//  Copyright (c) 2015, yangjiandong. All rights reserved.
//

#ifndef __vm__Env__
#define __vm__Env__

#include <stdio.h>
#include "Vm.h"
#include <vector>
#include <set>
#include "util/tinycthread.h"
#include "util/system.h"
#include <atomic>

struct StackFrame {
    StackFrame *preFrame;
    FMethod *method;
    int paddingSize;
    int argCount;
};

class Env {
    ExeEngine *interpreter;
public:
    //volatile bool needStop;
    std::atomic<bool> isStoped;
    
    PodManager *podManager;
private:
    //StackFrame *blockingFrame;
    
    FObj *error;
    FObj *thread;
public:
    char *stackBottom;
    char *stackTop;
    char *stackMemEnd;
    int stackMemSize;
    
    StackFrame *curFrame;

public:
    Fvm *vm;
    int debug;
    
public:
    Env(Fvm *vm);
    ~Env();
    
    void start(const char*, const char* type, const char* name, FObj *args);
    
    ////////////////////////////
    // frame
    ////////////////////////////
private:
    bool popFrame();
    bool pushFrame(FMethod* method, int paramCountWithSelf);
    
    ////////////////////////////
    // Param
    ////////////////////////////
public:
    void push(fr_TagValue *val);
    bool pop(fr_TagValue *val);
    bool popAll(int count);
    fr_TagValue *peek(int pos = -1);
    void insertBack(fr_TagValue *entry, int count);

    //bool getParam(void *param, fr_TagValue *val, int pos);
    
    ////////////////////////////
    // GC
    ////////////////////////////
    
    void checkSafePoint();
    
    fr_Obj newLocalRef(FObj * obj);
    void deleteLocalRef(fr_Obj obj);
    fr_Obj newGlobalRef(FObj * obj);
    void deleteGlobalRef(fr_Obj obj);
    
    void walkLocalRoot(Collector *gc);
    
    ////////////////////////////
    // type
    ////////////////////////////
    
    FType * findType(const char *pod, const char *type);
    FType* toType(fr_ValueType vt);
    
    ////////////////////////////
    // call
    ////////////////////////////
public:

    void call(FMethod *method, int paramCount);
    
    FMethod * findMethod(const char *pod, const char *type, const char *name, int paramCount = -1);
    void callNonVirtual(FMethod * method, int paramCount);
    void newObj(FType *type, FMethod * method, int paramCount);
    void callVirtual(FMethod * method, int paramCount);
    
    void callVirtualByName(const char *name, int paramCount);
    void newObjByName(const char * pod, const char * type, const char * name, int paramCount);
public:
    void setStaticField(FField *field, fr_Value *val);
    bool getStaticField(FField *field, fr_Value *val);
    
    void setInstanceField(FObj* obj, FField *field, fr_Value *val);
    bool getInstanceField(FObj* obj, FField *field, fr_Value *val);
    
    ////////////////////////////
    // exception
    ////////////////////////////
    
    FObj * getError();
    void throwError(FObj * err);
    void throwNPE();
    void clearError();
    
    int curOperandStackSize();
    int printOperandStack();
    void stackTrace(char *buf, int size, const char *delimiter);
    void printStackTrace();
    
private:
    void checkArgType(fr_TagValue* value, FType* expectedType);
};

#endif /* defined(__vm__Interpreter__) */
