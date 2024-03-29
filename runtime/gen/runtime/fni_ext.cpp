//
//  fni.cpp
//  vm
//
//  Created by yangjiandong on 15/9/27.
//  Copyright (c) 2015, yangjiandong. All rights reserved.
//

#include "fni_ext.h"
#include "Env.hpp"
#include "Vm.hpp"
#include <assert.h>
#include "runtime.h"
#include "type.h"
#include "util/system.h"

void fr_registerMethod(fr_Fvm vm, const char *name, fr_NativeFunc func) {
    //pass
}

////////////////////////////
// Param
////////////////////////////

FObj *fr_getPtr(fr_Env self, fr_Obj obj) {
    if (obj == 0) return NULL;
    return (FObj*)(obj);
}

fr_Obj fr_toHandle(fr_Env self, FObj *obj) {
    //FObj *obj = (FObj*)aobj;
    if (obj == NULL) return NULL;
    //Env *e = (Env*)self;
    fr_Obj objRef;
    
    objRef = reinterpret_cast<fr_Obj>(obj);
    //fr_unlock(self);
    return objRef;
}

bool fr_getParam(fr_Env env, void *param, fr_Value *val, int pos, fr_ValueType *vtype) {
    //Env *e = (Env*)env;
    //e->lock();
    fr_Value* tval = (fr_Value*)param;    
    *val = tval[pos];
    if (vtype) *vtype = fr_vtOther;
    return true;
}


////////////////////////////
// GC
////////////////////////////

fr_Obj fr_newLocalRef(fr_Env self, fr_Obj obj) {
    return obj;
}

void fr_deleteLocalRef(fr_Env self, fr_Obj obj) {
}


////////////////////////////
// Type
////////////////////////////

fr_Type fr_findType(fr_Env self, const char *pod, const char *type) {
    Env *e = (Env*)self;
    //e->lock();
    fr_Type t = e->vm->findClass(pod, type);
    //e->unlock();
    //return fr_getTypeObj(self, t);
    return t;
}

fr_Type fr_getObjType(fr_Env self, fr_Obj obj) {
    if (obj == 0) {
        return 0;
    }
    //fr_lock(self);
    FObj *o = fr_getPtr(self, obj);
    fr_Type type = (fr_Type)fr_getClass(self, o);
    //fr_unlock(self);
    
    //return fr_getTypeObj(self, type);
    return type;
}

////////////////////////////
// call
////////////////////////////

fr_Method fr_findMethodN(fr_Env self, fr_Type type, const char *name, int paramCount) {
    
    for (int i=0; i<type->methodCount; ++i) {
        fr_Method method = type->methodList+i;
        if (strcmp(method->name, name) ==0 && (method->paramsCount == paramCount || paramCount == -1 )) {
            return method;
        }
    }

    //find in base class
    fr_Type base = type->base;
    if (base) {
        return fr_findMethodN(self, base, name, paramCount);
    }
    return NULL;
}

void fr_callVirtual(fr_Env self, fr_Method method, int argCount, fr_Value *arg, fr_Value *ret) {
    fr_Type type = fr_getObjType(self, arg[0].h);
    fr_Method realMethod = fr_findMethodN(self, type, method->name, method->paramsCount);
    if (!realMethod) {
        return;
    }
    fr_callNonVirtual(self, realMethod, argCount, arg, ret);
}

void fr_callNonVirtual(fr_Env self, fr_Method method
                       , int argCount, fr_Value *arg, fr_Value *ret) {

    int methodArg = method->paramsCount;
    if ((method->flags & FFlags_Static) == 0) {
        ++methodArg;
    }
    if (methodArg != argCount) {
        printf("ERROR: %s args num not match: %d != %d\n", method->name, methodArg, argCount);
        abort();
        return;
    }
    method->func(self, arg, ret);
}

////////////////////////////
// Field
////////////////////////////

fr_Field fr_findField(fr_Env self, fr_Type type, const char *name) {
    //Env *e = (Env*)self;
    
    for (int i=0; i<type->fieldCount; ++i) {
        fr_Field field = type->fieldList+i;
        if (strcmp(field->name, name) == 0) {
            return field;
        }
    }

    //find in base class
    fr_Type base = type->base;
    if (base) {
        return fr_findField(self, base, name);
    }
    return NULL;
}

void fr_setStaticField(fr_Env self, fr_Field field, fr_Value *arg) {
    void *v = (field->pointer);
    switch (field->size) {
        case 1:
            *((uint8_t*)v) = arg->i;
            break;
        case 2:
            *((uint16_t*)v) = arg->i;
            break;
        case 4:
            *((uint32_t*)v) = (uint32_t)arg->i;
            break;
        case 8:
            *((uint64_t*)v) = arg->i;
            break;
        default:
            printf("ERROR: unkonw field size:%d\n", field->size);
    }
}

bool fr_getStaticField(fr_Env self, fr_Field field, fr_Value *val) {
    void *v = (field->pointer);
    switch (field->size) {
        case 1:
            val->i = *((uint8_t*)v);
            break;
        case 2:
            val->i = *((uint16_t*)v);
            break;
        case 4:
            val->i = *((uint32_t*)v);
            break;
        case 8:
            val->i = *((uint64_t*)v);
            break;
        default:
            printf("ERROR: unkonw field size:%d\n", field->size);
            return false;
    }
    return true;
}
void fr_setInstanceField(fr_Env self, fr_Obj bottom, fr_Field field, fr_Value *arg) {
    char *v = ((char*)fr_getPtr(self, bottom)) + field->offset;
    switch (field->size) {
        case 1:
            *((uint8_t*)v) = arg->i;
            break;
        case 2:
            *((uint16_t*)v) = arg->i;
            break;
        case 4:
            *((uint32_t*)v) = (uint32_t)arg->i;
            break;
        case 8:
            *((uint64_t*)v) = arg->i;
            break;
        default:
            printf("ERROR: unkonw field size:%d\n", field->size);
    }
    fr_setGcDirty(self, fr_getPtr(self, bottom));
}
bool fr_getInstanceField(fr_Env self, fr_Obj bottom, fr_Field field, fr_Value *val) {
    char *v = ((char*)fr_getPtr(self, bottom)) + field->offset;
    switch (field->size) {
        case 1:
            val->i = *((uint8_t*)v);
            break;
        case 2:
            val->i = *((uint16_t*)v);
            break;
        case 4:
            val->i = *((uint32_t*)v);
            break;
        case 8:
            val->i = *((uint64_t*)v);
            break;
        default:
            printf("ERROR: unkonw field size:%d\n", field->size);
            return false;
    }
    return true;
}

////////////////////////////
// exception
////////////////////////////

fr_Obj fr_getErr(fr_Env self) {
    Env *e = (Env*)self;
    fr_Err obj = e->error;
    return (fr_Obj)obj;
}

void fr_throw(fr_Env self, fr_Obj err) {
    fr_setErr(self, err);
}
