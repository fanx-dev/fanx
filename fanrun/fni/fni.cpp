//
//  fni.cpp
//  vm
//
//  Created by yangjiandong on 15/9/27.
//  Copyright (c) 2015, yangjiandong. All rights reserved.
//

#include "fni.h"
//#include "Env.hpp"
//#include "Vm.hpp"
#include <assert.h>
//#include "runtime.h"
//#include "type.h"
//#include "system.h"


bool fr_isInstanceOf(fr_Env self, fr_Obj obj, fr_Type type) {
    fr_Type itype = fr_getObjType(self, obj);
    bool rc = fr_fitType(self, itype, type);
    //fr_unlock(self);
    return rc;
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

fr_Value fr_newObj(fr_Env self, fr_Type type, fr_Method method, int argCount, ...) {
    va_list args;
    fr_Value ret;
    va_start(args, argCount);
    ret = fr_newObjV(self, type, method, argCount, args);
    va_end(args);
    return ret;
}

fr_Value fr_newObjS(fr_Env self, const char *pod, const char *type, const char *name
                     , int argCount, ...) {
    va_list args;
    fr_Value ret;
    va_start(args, argCount);
    
    fr_Type ftype = fr_findType(self, pod, type);
    fr_Method m = fr_findMethod(self, ftype, name);
    
    ret = fr_newObjV(self, ftype, m, argCount, args);
    va_end(args);
    return ret;
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

void fr_setStaticFieldS(fr_Env self, const char *pod, const char *typeName, const char *name, fr_Value *val) {
    //Env *e = (Env*)self;
    fr_Type type = fr_findType(self, pod, typeName);
    fr_Field field = fr_findField(self, type, name);
    fr_setStaticField(self, type, field, val);
}
bool fr_getStaticFieldS(fr_Env self, const char *pod, const char *typeName, const char *name, fr_Value *val) {
    //Env *e = (Env*)self;
    fr_Type type = fr_findType(self, pod, typeName);
    fr_Field field = fr_findField(self, type, name);
    bool rc = fr_getStaticField(self, type, field, val);
    return rc;
}
void fr_setFieldS(fr_Env self, fr_Value *bottom, const char *name, fr_Value *val) {
    //Env *e = (Env*)self;
    fr_Type type = fr_getObjType(self, bottom->h);;
    fr_Field field = fr_findField(self, type, name);
    fr_setInstanceField(self, bottom, field, val);
}
bool fr_getFieldS(fr_Env self, fr_Value *bottom, const char *name, fr_Value *val) {
    //Env *e = (Env*)self;
    fr_Type type = fr_getObjType(self, bottom->h);
    fr_Field field = fr_findField(self, type, name);
    int rc = fr_getInstanceField(self, bottom, field, val);
    return rc;
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
