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
#include "fni_ext.h"
#include <string.h>
#include <stdlib.h>

#ifdef  __cplusplus
extern  "C" {
#endif

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

void* fr_arrayData(fr_Env env, fr_Obj array) {
    fr_Array* a = (fr_Array*)fr_getPtr(env, array);
    return a->data;
}

void fr_arrayGet_(fr_Env self, fr_Array* array, size_t index, fr_Value *val) {
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
            val->i = t[index];
            //resVal.type = fr_vtInt;
            break;
        }
        case 8: {
            int64_t *t = (int64_t*)array->data;
            val->i = t[index];
            //resVal.type = fr_vtInt;
            break;
        }
        default:
            abort();
    }
}
void fr_arrayGet(fr_Env self, fr_Obj _array, size_t index, fr_Value* val) {
    fr_Array* array = (fr_Array*)fr_getPtr(self, _array);
    fr_arrayGet_(self, array, index, val);

    fr_ValueType vt = (fr_ValueType)array->valueType;
    if (vt == fr_vtObj) {
        val->h = fr_toHandle(self, (FObj*)val->o);
    }
}
void fr_arraySet_(fr_Env self, fr_Array* array, size_t index, fr_Value *val) {
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
        default:
            abort();
    }

    if (array->valueType == fr_vtObj) {
        fr_setGcDirty(self, (FObj*)val->o);
    }
}

void fr_arraySet(fr_Env self, fr_Obj _array, size_t index, fr_Value* val) {
    fr_Array* array = (fr_Array*)fr_getPtr(self, _array);
    fr_ValueType vt = (fr_ValueType)array->valueType;
    if (vt == fr_vtObj) {
        val->o = fr_getPtr(self, val->h);
    }
    fr_arraySet_(self, array, index, val);
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
    fr_Value valueArgs[50] = {0};
    fr_Value ret;
    for(int i=0; i<argCount; i++) {
        int paramIndex = i;
        if ((method->flags & FFlags_Static) == 0 && (method->flags & FFlags_Ctor) == 0) {
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

void fr_callMethodA(fr_Env env, fr_Method method, int argCount, fr_Value* arg, fr_Value* ret) {

    if ((method->flags & FFlags_Ctor) != 0 && (method->flags & FFlags_Static) == 0) {
        if (method->parent->flags & FFlags_Abstract) {
            printf("try new abstract class, please use callNonVirtual");
            abort();
        }

        fr_Obj obj = fr_allocObj(env, method->parent, -1);

        fr_Value newArgs[50];
        newArgs[0].h = obj;
        for (int i = 0; i < argCount; ++i) {
            newArgs[i + 1] = arg[i];
        }
        fr_callNonVirtual(env, method, argCount+1, newArgs, ret);
        //ctor is Void
        ret->h = obj;
        return;
    }

    if (method->flags & FFlags_Virtual || method->flags & FFlags_Abstract) {
        fr_callVirtual(env, method, argCount, arg, ret);
    }
    else {
        fr_callNonVirtual(env, method, argCount, arg, ret);
    }
}
//
//void fr_newObjA(fr_Env self, fr_Type type, fr_Method method
//               , int argCount, fr_Value *arg, fr_Value *ret) {
//
//    if (type->flags & FFlags_Abstract) {
//        printf("try new abstract class");
//        abort();
//    }
//
//    if ((method->flags & FFlags_Ctor) == 0) {
//        printf("method is not ctor: %s\n", method->name);
//        abort();
//    }
//
//    fr_Obj obj = fr_allocObj(self, type, -1);
//    
//    fr_Value newArgs[50];
//    newArgs[0].h = obj;
//    for (int i=0; i<argCount; ++i) {
//        newArgs[i+1] = arg[i];
//    }
//    
//    fr_callMethodA(self, method, argCount+1, newArgs, ret);
//    ret->h = obj;
//}
//
//fr_Value fr_newObjV(fr_Env self, fr_Type type, fr_Method method, int argCount, va_list args) {
//    fr_Value valueArgs[50] = {0};
//    fr_Value ret;
//    for(int i=0; i<argCount; i++) {
//        int paramIndex = i;
//        
//        if (strcmp(method->paramsList[paramIndex].type, "sys_Bool") == 0) {
//            valueArgs[i].b = va_arg(args, int);
//        }
//        else {
//            valueArgs[i].h = va_arg(args, fr_Obj);
//        }
//    }
//    ret.i = 0;
//    fr_newObjA(self, type, method, argCount, valueArgs, &ret);
//    return ret;
//}
//
//fr_Value fr_newObj(fr_Env self, fr_Type type, fr_Method method, int argCount, ...) {
//    va_list args;
//    fr_Value ret;
//    va_start(args, argCount);
//    ret = fr_newObjV(self, type, method, argCount, args);
//    va_end(args);
//    return ret;
//}
//
//fr_Obj fr_newObjS(fr_Env self, const char *pod, const char *type, const char *name
//                     , int argCount, ...) {
//    va_list args;
//    fr_Value ret;
//    va_start(args, argCount);
//    
//    fr_Type ftype = fr_findType(self, pod, type);
//    fr_Method m = fr_findMethodN(self, ftype, name, argCount);
//    if (m == NULL) {
//        printf("method not found:%s,%d\n", name, argCount);
//        return NULL;
//    }
//    
//    ret = fr_newObjV(self, ftype, m, argCount, args);
//    va_end(args);
//    return ret.h;
//}

fr_Value fr_callOnObj(fr_Env self, fr_Obj obj, const char *name
                         , int argCount, ...) {
    va_list args;
    fr_Value ret;
    va_start(args, argCount);
    
    fr_Type ftype = fr_getObjType(self, obj);
    fr_Method method = fr_findMethodN(self, ftype, name, argCount);

    if (method == NULL) {
        printf("method not found:%s,%d\n", name, argCount);
        ret.h = NULL;
        return ret;
    }
    
    //ret = fr_callMethodV(self, m, argCount, args);
    fr_Value valueArgs[50] = { 0 };
    valueArgs[0].h = obj;
    for (int i = 0; i < argCount; i++) {
        int paramIndex = i;

        if (strcmp(method->paramsList[paramIndex].type, "sys_Bool") == 0) {
            valueArgs[i+1].b = va_arg(args, int);
        }
        else {
            valueArgs[i+1].h = va_arg(args, fr_Obj);
        }
    }
    ret.i = 0;
    fr_callMethodA(self, method, argCount+1, valueArgs, &ret);
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

    int paramCount = argCount;
    if ((m->flags & FFlags_Static) == 0 && (m->flags & FFlags_Ctor) == 0) {
        --paramCount;
    }

    if (paramCount != m->paramsCount) {
        m = fr_findMethodN(self, ftype, name, paramCount);
    }

    if (m == NULL) {
        printf("method not found: %s\n", name);
        ret.h = NULL;
        return ret;
    }
    
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
    fr_Obj msgObj = fr_newStrUtf8(self, msg);
    fr_Obj err = fr_newObjS(self, pod, type, "make", 1, msgObj);
    fr_throw(self, err);
}


void fr_printErr(fr_Env self, fr_Obj err) {
    fr_callOnObj(self, err, "trace", 0);
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

fr_Obj fr_objToStr(fr_Env env, fr_Obj x) {
    fr_Obj str;
    if (!x) {
        return fr_newStrUtf8(env, "null");
    }
    // if it is primitive type must be unbox before call it's method.
    fr_Value val;
    val.h = x;
    //fr_unbox(env, x, &val);

    fr_Value rVal;
    fr_Type type = fr_getObjType(env, x);

    fr_Method method = fr_findMethod(env, type, "toStr");

    fr_callMethodA(env, method, 1, &val, &rVal);

    str = rVal.h;
    return str;
}

////////////////////////////
// Util
////////////////////////////

fr_Obj fr_makeArgArray(fr_Env env, int start, int argc, const char* argv[]) {
    fr_Obj args = fr_callMethodS(env, "sys", "List", "make", 1, (fr_Int)argc).h;
    for (int i = start; i < argc; ++i) {
        const char* cstr = argv[i];
        fr_Obj str = fr_newStrUtf8(env, cstr);
        fr_callOnObj(env, args, "add", 1, str);
    }
    return args;
}

void fr_onExit() {
    static int flag = 0;
    if (flag != 0) return;
    flag = 1;
    fr_Fvm vm = fr_getVm();
    if (vm == NULL) return;
    fr_Env env = fr_getEnv(vm);
    fr_Obj envObj = fr_callMethodS(env, "std", "Env", "cur", 0).h;
    fr_callOnObj(env, envObj, "onExit", 0);
}

#ifdef  __cplusplus
}//extern "C"
#endif