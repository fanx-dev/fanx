//
//  sys_native.c
//  run
//
//  Created by yangjiandong on 2017/12/31.
//  Copyright © 2017年 yangjiandong. All rights reserved.
//

#include "sys.h"
#include "runtime.h"


#include <stdlib.h>
#include <string.h>
#include <wchar.h>
#include <wctype.h>

#ifdef  __cplusplus
extern  "C" {
#endif

//////////////////////////////////////////////////////////

void fr_finalizeObj(fr_Env __env, fr_Obj _obj) {
    sys_Obj obj = (sys_Obj)_obj;
    _FR_VTABLE(sys_Obj, obj)->finalize(__env, obj);
}
fr_Obj fr_arrayNew(fr_Env self, fr_Type elemType, int32_t elemSize, size_t len) {
    if (elemSize <= 0) elemSize = sizeof(void*);
    fr_ValueType vtype = fr_vtObj;
    if (elemType == sys_Int_class__) {
        vtype = fr_vtInt;
    }
    else if (elemType == sys_Float_class__) {
        vtype = fr_vtFloat;
    }
    else if (elemType == sys_Bool_class__) {
        vtype = fr_vtBool;
        elemSize = sizeof(bool);
    }
    else {
        assert(elemSize == sizeof(void*));
    }
    
    size_t allocSize = sizeof(struct fr_Array_) + (elemSize * len) + 1;
    fr_Array *array = (fr_Array*)fr_allocObj(self, sys_Array_class__, allocSize);
    array->elemType = elemType;
    array->elemSize = elemSize;
    array->valueType = vtype;
    array->size = len;
    return array;
}

////////////////////////////////////////////////////////////////
// String
////////////////////////////////////////////////////////////////

sys_Str sys_Str_fromCStr(fr_Env __env, sys_Ptr utf8, sys_Int byteLen);
sys_Array sys_Str_toUtf8(fr_Env __env, sys_Str_ref __self);


fr_Obj fr_newStrUtf8N(fr_Env __env, const char *bytes, ssize_t size) {
    size_t len;
    sys_Str str;
    
    if (size == -1) len = strlen(bytes);
    else len = size;
    
    str = sys_Str_fromCStr(__env, (sys_Ptr)bytes, len);
    return str;
}

const char *fr_getStrUtf8(fr_Env env__, fr_Obj obj) {
    sys_Str str = (sys_Str)obj;
    sys_Array array = sys_Str_toUtf8(env__, str);
    const char *data = (const char*)((fr_Array*)array)->data;
    //if (isCopy) *isCopy = false;
    return data;
}

////////////////////////////////////////////////////////////////
// Error
////////////////////////////////////////////////////////////////

fr_Err fr_makeNPE(fr_Env __env) {
    sys_NullErr npe = FR_ALLOC(sys_NullErr);
    sys_NullErr_make__0(__env, npe);
    return npe;
}
fr_Err fr_makeCastError(fr_Env __env) {
    sys_CastErr npe = FR_ALLOC(sys_CastErr);
    sys_CastErr_make__0(__env, npe);
    return npe;
}
fr_Err fr_makeIndexError(fr_Env __env, fr_Int index, fr_Int limit) {
    char buf[128] = {0};
    snprintf(buf, 128, "index (%d) out of bounds (%d)", (int)index, (int)limit);
    fr_Obj msg = fr_newStrUtf8(__env, buf);
    sys_IndexErr err = FR_ALLOC(sys_IndexErr);
    sys_IndexErr_make__1(__env, err, msg);
    return err;
}

void fr_printError(fr_Env __env, fr_Err error) {
    sys_Err e = (sys_Err)error;
    const char* str = fr_getStrUtf8(__env, e->traceStr);
    fprintf(stderr, "%s\n", str);
}

////////////////////////////////////////////////////////////////
// Boxing
////////////////////////////////////////////////////////////////

//#include <unordered_map>
//#include <mutex>
//
//std::mutex pool_mutex;

fr_Obj fr_box_int(fr_Env __env, sys_Int_val val) {
    fr_Obj obj;
    static fr_Obj map[515];
    int index;
    if (val < 256 && val >= -256) {
        index = val + 256;
    }
    else if (val == sys_Int_maxVal) index = 513;
    else if (val == sys_Int_minVal) index = 514;
    else {
        FR_BOXING_VAL(obj, val, sys_Int, sys_Obj);
        return obj;
    }
    
    obj = map[index];
    if (obj) return obj;
        
    FR_BOXING_VAL(obj, val, sys_Int, sys_Obj);
    obj = fr_newGlobalRef(__env, obj);
    map[index] = obj;
    return obj;
}
fr_Obj fr_box_float(fr_Env __env, sys_Float_val val) {
    fr_Obj obj;
    static fr_Obj map[8];
    int index;
    if (val == 0) index = 0;
    if (val == 1) index = 1;
    if (val == -1) index = 2;
    if (val == 0.5) index = 3;
    if (val == sys_Float_e) index = 4;
    if (val == sys_Float_pi) index = 5;
    if (val == sys_Float_negInf) index = 6;
    if (val == sys_Float_posInf) index = 7;
    else {
        FR_BOXING_VAL(obj, val, sys_Float, sys_Obj);
        return obj;
    }
    
    obj = map[index];
    if (obj) return obj;
    
    FR_BOXING_VAL(obj, val, sys_Float, sys_Obj);
    obj = fr_newGlobalRef(__env, obj);
    map[index] = obj;
    return obj;
}

fr_Obj fr_box_bool(fr_Env __env, sys_Bool_val val) {
    static fr_Obj trueObj = NULL;
    static fr_Obj falseObj = NULL;
    if (!trueObj) {
        //std::lock_guard<std::mutex> lock(pool_mutex);
        FR_BOXING_VAL(trueObj, true, sys_Bool, sys_Obj);
        FR_BOXING_VAL(falseObj, false, sys_Bool, sys_Obj);
        trueObj = fr_newGlobalRef(__env, trueObj);
        falseObj = fr_newGlobalRef(__env, falseObj);
    }
    return val ? trueObj : falseObj;
}

fr_Obj fr_box(fr_Env env, fr_Value* value, fr_ValueType vtype) {
    fr_Obj res = value->h;
    if (vtype == fr_vtBool) {
        res = fr_box_bool(env, value->b);
    }
    else if (vtype == fr_vtInt) {
        res = fr_box_int(env, value->i);
    }
    else if (vtype == fr_vtFloat) {
        res = fr_box_float(env, value->f);
    }
    return res;
}

fr_ValueType fr_unbox(fr_Env env, fr_Obj obj, fr_Value* value) {

    fr_Type type = fr_getObjType(env, obj);
    if (strcmp(type->name, "sys::Bool") == 0) {
        fr_Bool* v = (fr_Bool*)fr_getPtr(env, obj);
        value->b = *v;
        return fr_vtBool;
    }
    else if (strcmp(type->name, "sys::Int") == 0) {
        fr_Int* v = (fr_Int*)fr_getPtr(env, obj);
        value->i = *v;
        return fr_vtInt;
    }
    else if (strcmp(type->name, "sys::Float") == 0) {
        fr_Float* v = (fr_Float*)fr_getPtr(env, obj);
        value->f = *v;
        return fr_vtFloat;
    }
    else {
        value->h = obj;
        return fr_vtHandle;
    }
}


#ifdef  __cplusplus
}//extern "C"
#endif
