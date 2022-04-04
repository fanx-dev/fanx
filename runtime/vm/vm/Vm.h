//
//  FVM.h
//  vm
//
//  Created by yangjiandong on 15/9/27.
//  Copyright (c) 2015, yangjiandong. All rights reserved.
//

#ifndef __vm__FVM__
#define __vm__FVM__

#include <stdio.h>
#include "PodManager.h"
#include "fni_ext.h"
#include "gc/gci.h"
#include <unordered_map>
#include <thread>
#include "util/LinkedList.h"
#include "../vm/ExeEngine.h"
#include <assert.h>
#include <mutex>

class Env;

class Fvm : public GcSupport {
    std::unordered_map<std::thread::id, Env*> threads;
    LinkedList globalRefList;
    std::vector<fr_Obj> staticFieldRef;
    std::recursive_mutex lock;
public:
    Collector *gc;
    PodManager *podManager;
    ExeEngine *executeEngine;
public:
    Fvm(PodManager *podManager);
    ~Fvm();

    static Fvm* getCur();
    
    void start();
    void stop();
    
    Env *getEnv(bool *isNew);
    void releaseEnv(Env *env);
    
    void registerMethod(const char *name, fr_NativeFunc func);
    
    virtual void visitChildren(Collector *gc, GcObj *obj);
    virtual void walkRoot(Collector *gc);
    virtual void onStartGc();
    
    virtual void finalizeObj(GcObj *obj);
    virtual void puaseWorld(bool bloking);
    virtual void resumeWorld();
    virtual void printObj(GcObj *obj);
    virtual int allocSize(GcObj* gcobj);
    
    fr_Obj newGlobalRef(FObj * obj);
    void deleteGlobalRef(fr_Obj obj);
    void addStaticRef(fr_Obj obj);
private:
    void visitChildrenByType(Collector* gc, FObj* fobj, FType *ftype);
};

#endif /* defined(__vm__FVM__) */
