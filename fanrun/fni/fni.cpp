//
//  fni.cpp
//  vm
//
//  Created by yangjiandong on 15/9/27.
//  Copyright (c) 2015, yangjiandong. All rights reserved.
//

#include "fni_private.h"
//#include "Env.hpp"
//#include "Vm.hpp"
#include <assert.h>
//#include "runtime.h"
//#include "type.h"
//#include "system.h"
#include <string.h>

static_assert(sizeof(void*) == 8, "must 64-bit");


GcObj *fr_toGcObj(FObj *obj) {
    if (obj == nullptr) return nullptr;
    GcObj *g = (GcObj*)obj;
    --g;
    return g;
    
}
FObj *fr_fromGcObj(GcObj *g) {
    if (g == nullptr) return nullptr;
    FObj *obj = (FObj*)(++g);
    return obj;
}


////////////////////////////
// Array
////////////////////////////

size_t fr_arrayLen(fr_Env self, fr_Obj array) {
    fr_Array *a = (fr_Array*)fr_getPtr(self, array);
    return a->size;
}

void fr_arrayGet(fr_Env self, fr_Obj _array, size_t index, fr_Value *val) {
    fr_Array *array = (fr_Array*)fr_getPtr(self, _array);

    if (index >= array->size) {
        fr_throwNew(self, "sys", "IndexErr", "out index");
        return;
    }
    
    size_t elemSize = array->elemSize;

    switch (elemSize) {
        case 1: {
            int8_t *t = (int8_t*)array->data;
            val->i = t[index];
            break;
        }
        case 2: {
            int16_t *t = (int16_t*)array->data;
            val->i = t[index];
            //resVal.type = fr_vtInt;
            break;
        }
        case 4: {
            int32_t *t = (int32_t*)array->data;
            val->i = *t;
            //resVal.type = fr_vtInt;
            break;
        }
        case 8: {
            int64_t *t = (int64_t*)array->data;
            val->i = *t;
            //resVal.type = fr_vtInt;
            break;
        }
    }

    fr_ValueType vt = (fr_ValueType)array->valueType;
    if (vt == fr_vtObj) {
        val->h = fr_toHandle(self, (FObj*)val->o);
    }
}
void fr_arraySet(fr_Env self, fr_Obj _array, size_t index, fr_Value *val) {
    fr_Array* array = (fr_Array*)fr_getPtr(self, _array);

    if (index >= array->size) {
        fr_throwNew(self, "sys", "IndexErr", "out index");
        return;
    }
    //a->data[index] = fr_getPtr(self, val->h);
    
    size_t elemSize = array->elemSize;

    switch (elemSize) {
        case 1: {
            int8_t *t = (int8_t*)array->data;
            t[index] = val->i;
            break;
        }
        case 2: {
            int16_t *t = (int16_t*)array->data;
            t[index] = val->i;
            break;
        }
        case 4: {
            int32_t *t = (int32_t*)array->data;
            t[index] = (int32_t)val->i;
            break;
        }
        case 8: {
            int64_t *t = (int64_t*)array->data;
            t[index] = val->i;
            break;
        }
    }
}

////////////////////////////
// type
////////////////////////////

const char *fr_getTypeName(fr_Env self, fr_Obj obj) {
    fr_Type type = fr_getObjType(self, obj);
    return type->name;
}

bool fr_fitType(fr_Env env, fr_Type tempType, fr_Type type) {
    while (true) {
        if (tempType == type) return true;
        if (tempType == tempType->base) break;
        tempType = tempType->base;
        if (!tempType) break;
    }
    return false;
}

bool fr_isInstanceOf(fr_Env self, fr_Obj obj, fr_Type type) {
    fr_Type itype = fr_getObjType(self, obj);
    bool rc = fr_fitType(self, itype, type);
    //fr_unlock(self);
    return rc;
}

fr_Type fr_toType(fr_Env self, fr_ValueType vt) {
    //Env *e = (Env*)self;
    
    switch (vt) {
        case fr_vtInt:
            return fr_findType(self, "sys", "Int");
            break;
        case fr_vtFloat:
            return fr_findType(self, "sys", "Float");
            break;
        case fr_vtBool:
            return fr_findType(self, "sys", "Bool");
            break;
        default:
            break;
    }
    
    return fr_findType(self, "sys", "Obj");
}

fr_Type fr_getInstanceType(fr_Env self, fr_Value *obj, fr_ValueType vtype) {
    if (vtype == fr_vtHandle) {
        return fr_getObjType(self, obj->p);
    }
    return fr_toType(self, vtype);
}

////////////////////////////
// call
////////////////////////////

fr_Method fr_findMethod(fr_Env self, fr_Type type, const char *name) {
    return fr_findMethodN(self, type, name, -1);
}

fr_Value fr_callMethod(fr_Env self, fr_Method method, int argCount, ...) {
    va_list args;
    fr_Value ret;
    va_start(args, argCount);
    ret = fr_callMethodV(self, method, argCount, args);
    va_end(args);
    return ret;
}

fr_Value fr_callMethodV(fr_Env self, fr_Method method, int argCount, va_list args) {
    fr_Value valueArgs[10] = {0};
    fr_Value ret;
    for(int i=0; i<argCount; i++) {
        int paramIndex = i;
        if ((method->flags & FFlags_Static) == 0) {
            --paramIndex;
        }
        if (paramIndex == -1) {
            valueArgs[i].h = va_arg(args, fr_Obj);
            continue;
        }
        
        if (strcmp(method->paramsList[paramIndex].type, "sys_Bool") == 0) {
            valueArgs[i].b = va_arg(args, int);
        }
        else {
            valueArgs[i].h = va_arg(args, fr_Obj);
        }
    }
    ret.i = 0;
    fr_callMethodA(self, method, argCount, valueArgs, &ret);
    return ret;
}

void fr_newObjA(fr_Env self, fr_Type type, fr_Method method
               , int argCount, fr_Value *arg, fr_Value *ret) {
    fr_Obj obj = fr_allocObj(self, type, -1);
    
    fr_Value newArgs[10];
    newArgs[0].h = obj;
    for (int i=0; i<argCount; ++i) {
        newArgs[i+1] = arg[i];
    }
    
    fr_callMethodA(self, method, argCount+1, newArgs, ret);
    ret->h = obj;
}

fr_Value fr_newObjV(fr_Env self, fr_Type type, fr_Method method, int argCount, va_list args) {
    fr_Value valueArgs[10] = {0};
    fr_Value ret;
    for(int i=0; i<argCount; i++) {
        int paramIndex = i;
        
        if (strcmp(method->paramsList[paramIndex].type, "sys_Bool") == 0) {
            valueArgs[i].b = va_arg(args, int);
        }
        else {
            valueArgs[i].h = va_arg(args, fr_Obj);
        }
    }
    ret.i = 0;
    fr_newObjA(self, type, method, argCount, valueArgs, &ret);
    return ret;
}

fr_Value fr_newObj(fr_Env self, fr_Type type, fr_Method method, int argCount, ...) {
    va_list args;
    fr_Value ret;
    va_start(args, argCount);
    ret = fr_newObjV(self, type, method, argCount, args);
    va_end(args);
    return ret;
}

fr_Obj fr_newObjS(fr_Env self, const char *pod, const char *type, const char *name
                     , int argCount, ...) {
    va_list args;
    fr_Value ret;
    va_start(args, argCount);
    
    fr_Type ftype = fr_findType(self, pod, type);
    fr_Method m = fr_findMethod(self, ftype, name);
    
    ret = fr_newObjV(self, ftype, m, argCount, args);
    va_end(args);
    return ret.h;
}

fr_Value fr_callOnObj(fr_Env self, const char *name
                         , int argCount, ...) {
    va_list args;
    fr_Value ret;
    va_start(args, argCount);
    fr_Obj obj = va_arg(args, fr_Obj);
    va_start(args, argCount);
    
    fr_Type ftype = fr_getObjType(self, obj);
    fr_Method m = fr_findMethod(self, ftype, name);
    
    ret = fr_callMethodV(self, m, argCount, args);
    va_end(args);
    return ret;
}

fr_Value fr_callMethodS(fr_Env self, const char *pod, const char *type, const char *name
                        , int argCount, ...) {
    va_list args;
    fr_Value ret;
    va_start(args, argCount);
    
    fr_Type ftype = fr_findType(self, pod, type);
    fr_Method m = fr_findMethod(self, ftype, name);
    
    ret = fr_callMethodV(self, m, argCount, args);
    va_end(args);
    return ret;
}

////////////////////////////
// Field
////////////////////////////

bool fr_setFieldS(fr_Env env, fr_Obj obj, const char *name, fr_Value val) {
    fr_Type type = fr_getObjType(env, obj);
    fr_Field field = fr_findField(env, type, name);
    
    if (field == NULL) return false;
    
    if ((field->flags & FFlags_Static) != 0) {
        fr_setStaticField(env, field, &val);
    }
    else {
        fr_setInstanceField(env, obj, field, &val);
    }
    return true;
}

fr_Value fr_getFieldS(fr_Env env, fr_Obj obj, const char *name) {
    fr_Type type = fr_getObjType(env, obj);
    fr_Field field = fr_findField(env, type, name);
    fr_Value ret;
    ret.i = 0;
    
    if (field == NULL) return ret;
    
    if ((field->flags & FFlags_Static) != 0) {
        fr_getStaticField(env, field, &ret);
    }
    else {
        fr_getInstanceField(env, obj, field, &ret);
    }
    return ret;
}

////////////////////////////
// exception
////////////////////////////

void fr_throwNew(fr_Env self, const char *pod, const char *type, const char *msg) {
    fr_Obj err = fr_newObjS(self, pod, type, "make", 1, msg);
    fr_throw(self, err);
}


void fr_printErr(fr_Env self, fr_Obj err) {
    fr_callOnObj(self, "trace", 1, err);
}

void fr_clearErr(fr_Env self) {
    fr_throw(self, NULL);
}

void fr_throwNPE(fr_Env self) {
    fr_throwNew(self, "sys", "NullErr", "null pointer");
}

void fr_throwUnsupported(fr_Env self) {
    fr_throwNew(self, "sys", "UnsupportedErr", "unsupported");
}

bool fr_errOccurred(fr_Env self) {
    return fr_getErr(self) != NULL;
}

////////////////////////////
// Str
////////////////////////////

fr_Obj fr_newStrUtf8(fr_Env self, const char *bytes) {
    return fr_newStrUtf8N(self, bytes, -1);
}

fr_Obj fr_handleToStr(fr_Env env, fr_Obj x) {
    fr_Obj str;
    if (!x) {
        return fr_newStrUtf8(env, "null");
    }
    // if it is primitive type must be unbox before call it's method.
    fr_Value val;
    val.h = x;
    fr_unbox(env, x, &val);

    fr_Value rVal;
    fr_Type type = fr_getObjType(env, x);

    fr_Method method = fr_findMethod(env, type, "toStr");

    fr_callMethodA(env, method, 1, &val, &rVal);

    str = rVal.h;
    return str;
}
//
//fr_Obj fr_objToStr(fr_Env self, fr_Value obj, fr_ValueType vtype) {
////    Env *e = (Env*)self;
//
//    if (vtype != fr_vtHandle) {
//        //TODO op
//        if (vtype == fr_vtObj) {
//            obj.h = fr_toHandle(self, (FObj*)obj.o);
//        } else {
//            obj.h = fr_box(self, &obj, vtype);
//        }
//    }
//    return fr_handleToStr(self, obj.h);
//}
//
