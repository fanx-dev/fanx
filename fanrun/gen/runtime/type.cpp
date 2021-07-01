//
//  Type.cpp
//  fcode
//
//  Created by yangjiandong on 15/8/2.
//  Copyright (c) 2015年 yangjiandong. All rights reserved.
//

#include "runtime.h"
#include <stdio.h>
#include "ThreadEnv.hpp"
#include "Vm.hpp"


bool fr_fitType(fr_Env env, fr_Type tempType, fr_Type type) {
    while (true) {
        if (tempType == type) return true;
        if (tempType == tempType->base) break;
        tempType = tempType->base;
        if (!tempType) break;
    }
    return false;
}

bool fr_isClass(fr_Env env, fr_Obj obj, fr_Type type) {
    if (!obj) return false;

    fr_Type tempType = fr_getClass(env, obj);
    while (true) {
        if (tempType == type) return true;
        if (tempType == tempType->base) break;
        tempType = tempType->base;
        if (!tempType) break;
    }
    return false;
}

void fr_VTable_init(fr_Env env, fr_Type type) {
    type->name = "";
    type->base = NULL;
    type->mixinCount = 0;
    type->fieldCount = 0;
    type->methodCount = 0;
    type->allocSize = 0;
    type->reflectObj = NULL;
    type->staticInited = false;
}

fr_Type fr_getClass(fr_Env env, fr_Obj obj) {
    if (!obj) {
        return NULL;
    }
    GcObj *g = fr_toGcObj(obj);
    //return obj->super.header;
    fr_Type type = (fr_Type)gc_getType(g);
    return type;
}

void **fr_getInterfaceVTable(fr_Env env, fr_Obj obj, fr_Type itype) {
    fr_Type type = fr_getClass(env, obj);
    int i = 0;
    while (true) {
        struct fr_IVTableMapItem *item = &type->interfaceVTableIndex[i];
        if (item->type == itype) {
            void **base = (void**)((struct fr_Class_*)type+1);
            return (base + item->vtableOffset);
        }
        if (item->type == NULL) break;
    }
    printf("ERROR: not found interface vtable %s\n", itype->name);
    return NULL;
}

void fr_registerClass(fr_Env env, const char *pod, const char *clz, fr_Type type) {
    Env *e = (Env*)env;
    e->vm->registerClass(pod, clz, type);
}

//fr_Type fr_findClass(fr_Env env, const char *pod, const char *clz) {
//    Env *e = (Env*)env;
//    return e->vm->findClass(pod, clz);
//}

void fr_registerPod(fr_Env env, struct fr_Pod_ *pod) {
    Env *e = (Env*)env;
    e->vm->registerPod(pod);
}
