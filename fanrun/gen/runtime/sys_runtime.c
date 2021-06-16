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

//////////////////////////////////////////////////////////
#ifdef  __cplusplus
extern  "C" {
#endif

void fr_finalizeObj(fr_Env __env, fr_Obj _obj) {
    sys_Obj obj = (sys_Obj)_obj;
    _FR_VTABLE(sys_Obj, obj)->finalize(__env, obj);
}
fr_Obj fr_arrayNew(fr_Env self, fr_Type elemType, size_t elemSize, size_t len) {
    if (elemSize <= 0) elemSize = sizeof(fr_Obj);
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
    
    size_t allocSize = sizeof(struct sys_Array_struct) + (elemSize * len) + 1;
    sys_Array_ref array = (sys_Array_ref)fr_alloc(self, sys_Array_class__, allocSize);
    array->elemType = elemType;
    array->elemSize = elemSize;
    array->valueType = vtype;
    array->size = len;
    return array;
}

//sys_Str sys_Str_format(fr_Env __env, sys_Str format, sys_List args) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }


//sys_Int strHash(sys_Str str);
//size_t utf8encode(const wchar_t *us, char *des, size_t n, int *illegal);
//size_t utf8decode(char const *str, wchar_t *des, size_t n, int *illegal);
sys_Str sys_Str_fromCStr(fr_Env __env, sys_Ptr utf8, sys_Int byteLen);
sys_Array sys_Str_toUtf8(fr_Env __env, sys_Str_ref __self);

fr_Obj fr_newStrUtf8(fr_Env __env, const char *bytes, ssize_t size) {
    size_t len;
    sys_Str str;
    
    if (size == -1) len = strlen(bytes);
    else len = size;
    
    str = sys_Str_fromCStr(__env, (sys_Ptr)bytes, len);
    return str;
}
//fr_Obj fr_newStr(fr_Env __env, const wchar_t *data, size_t size, bool copy) {
//    sys_Str str = FR_ALLOC(sys_Str);
//    if (copy) {
//        wchar_t *data = (wchar_t*)malloc(sizeof(wchar_t)*(size+1));
//        wcsncpy(data, data, size);
//        str->data = data;
//    }
//    else {
//        str->data = data;
//    }
//    str->size = size;
//    str->hashCode = strHash(str);
//    str->utf8 = NULL;
//    return str;
//}
//fr_Obj fr_newStrNT(fr_Env __env, const wchar_t *data, bool copy) {
//    size_t size = wcslen(data);
//    return fr_newStr(__env, data, size, copy);
//}
const char *fr_getStrUtf8(fr_Env env__, fr_Obj obj) {
//    size_t size;
//    size_t realSize;
//    sys_Str str = (sys_Str)obj;
//    if (str->utf8) return str->utf8;
//    size = str->size * 4 + 1;
//    char *utf8 = (char*)malloc(size);
//    realSize = utf8encode(str->data, utf8, size, NULL);
//    utf8[realSize] = 0;
//    str->utf8 = utf8;
    
    sys_Str str = (sys_Str)obj;
    sys_Array array = sys_Str_toUtf8(env__, str);
    const char *data = (const char*)array->data;
    //if (isCopy) *isCopy = false;
    return data;
}

////////////////////////////////////////////////////////////////

//fr_Obj fr_toTypeObj(fr_Env __env, fr_Type clz) {
//    if (!clz->typeObj) {
//        sys_Type type = FR_ALLOC(sys_Type);
//        type->rawClass = clz;
//        clz->typeObj = type;
//    }
//    return clz->typeObj;
//}
//
//fr_Type fr_fromSysType(fr_Env __env, fr_Obj clz) {
//    return ((sys_Type)clz)->rawClass;
//}

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

void fr_printError(fr_Env __env, fr_Err error) {
    sys_Err e = (sys_Err)error;
    const char* str = fr_getStrUtf8(__env, e->traceStr);
    fprintf(stderr, "%s\n", str);
}

////////////////////////////////////////////////////////////////
//#include <unordered_map>
//#include <mutex>
//
//std::mutex pool_mutex;

fr_Obj fr_box_int(fr_Env __env, sys_Int_val val) {
    fr_Obj obj;
    static fr_Obj map[515];
    if ((val < 256 && val >= -256)
        || val == sys_Int_maxVal
        || val == sys_Int_minVal) {
        
//        std::lock_guard<std::mutex> lock(pool_mutex);
//
//        auto itr = map.find(val);
//        if (itr != map.end()) {
//            return itr->second;
//        }
        int index;
        if (val == sys_Int_maxVal) index = 513;
        if (val == sys_Int_minVal) index = 514;
        else index = val + 256;
        
        obj = map[index];
        if (obj) return obj;
        
        FR_BOXING_VAL(obj, val, sys_Int, sys_Obj);
        obj = fr_addGlobalRef(__env, obj);
        map[index] = obj;
        return obj;
    }
    FR_BOXING_VAL(obj, val, sys_Int, sys_Obj);
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
    obj = fr_addGlobalRef(__env, obj);
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
        trueObj = fr_addGlobalRef(__env, trueObj);
        falseObj = fr_addGlobalRef(__env, falseObj);
    }
    return val ? trueObj : falseObj;
}

#ifdef  __cplusplus
}//extern "C"
#endif
