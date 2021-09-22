//
//  runtime.c
//  gen
//
//  Created by yangjiandong on 2017/9/10.
//  Copyright © 2017年 yangjiandong. All rights reserved.
//

#include "runtime.h"
#include "Env.hpp"
#include "Vm.hpp"
#include "util/system.h"

Vm *fvm = nullptr;

fr_Env fr_getEnv(fr_Fvm vm) {
    void *statckVar = 0;
    if (vm == nullptr) {
        vm = fr_getVm();
    }
    Vm* fvm = (Vm*)vm;
    Env *env = fvm->getEnv();
    if (env->statckStart == NULL) {
        env->statckStart = &statckVar;
    }
    return env;
}

void fr_releaseEnv(fr_Env env) {
    if (!env) return;
    Env *e = (Env*)env;
    e->vm->releaseEnv(e);
}

fr_Fvm fr_getVm() {
    if (fvm == nullptr) {
        fvm = new Vm();
    }
    return fvm;
}

void fr_gcQuit() {
    fvm->getGc()->quit();
}

//////////////////////////////////////////
// GC
/*
GcObj *fr_toGcObj(fr_Obj obj) {
    GcObj *g = (GcObj*)obj;
    --g;
    return g;
    
}
fr_Obj fr_fromGcObj(GcObj *g) {
    fr_Obj obj = (fr_Obj)(++g);
    return obj;
}
*/
void fr_checkPoint(fr_Env self) {
    Env *env = (Env*)self;
    if (env->vm->getGc()->isStopTheWorld()) {
        void *statckVar = 0;
        env->statckEnd = &statckVar;
        env->isStoped = true;
        
        do {
            System_sleep(1);
        } while(env->vm->getGc()->isStopTheWorld());
        env->isStoped = false;
    }
}

void fr_allowGc(fr_Env self) {
    Env *env = (Env*)self;
    void *statckVar = 0;
    env->statckEnd = &statckVar;
    env->isStoped = true;
}

void fr_endAllowGc(fr_Env self) {
    Env *env = (Env*)self;
    env->isStoped = false;
    fr_checkPoint(self);
}

fr_Obj fr_allocObj(fr_Env self, fr_Type vtable, int size) {
    Env *env = (Env*)self;
    int allocSize = vtable->allocSize;
    if (allocSize < (int)size) allocSize = (int)size;
    GcObj *gcobj = env->vm->getGc()->alloc(vtable, allocSize+sizeof(GcObj));
    fr_Obj obj = fr_fromGcObj(gcobj);
    return obj;
}

void fr_gc(fr_Env self) {
    Env *env = (Env*)self;
    env->vm->getGc()->collect();
}

void fr_setGcDirty(fr_Env self, FObj* obj) {
    Env *env = (Env*)self;
    Collector *gc = env->vm->getGc();
    GcObj *gcobj = fr_toGcObj(obj);
    gc->setDirty(gcobj);
}

fr_Obj fr_newGlobalRef(fr_Env self, fr_Obj obj) {
    Env* env = (Env*)self;
    env->vm->getGc()->pinObj(fr_toGcObj(obj));
    return obj;
}

void fr_deleteGlobalRef(fr_Env self, fr_Obj obj) {
    Env *env = (Env*)self;
    env->vm->getGc()->unpinObj(fr_toGcObj(obj));
}
//void fr_addStaticRef(fr_Env self, fr_Obj *obj) {
//    Env *env = (Env*)self;
//    env->vm->addStaticRef(obj);
//}

void fr_setErr(fr_Env self, fr_Err err) {
    self->error = err;
}
