//
//  sys_Array.c
//  run
//
//  Created by yangjiandong on 2017/12/17.
//  Copyright © 2017年 yangjiandong. All rights reserved.
//

#include "sys.h"

void sys_Array_make(fr_Env __env, sys_Array_ref __self, sys_Int size) {}

sys_Int sys_Array_size(fr_Env __env, sys_Array_ref __self) { return __self->size; }

sys_Obj_null sys_Array_get(fr_Env __env, sys_Array_ref __self, sys_Int pos) { return ((sys_Obj_null*)__self->data)[pos]; }

void sys_Array_set(fr_Env __env, sys_Array_ref __self, sys_Int pos, sys_Obj_null val) { ((sys_Obj_null*)__self->data)[pos] = val; }

sys_Obj sys_Array_realloc(fr_Env __env, sys_Obj array, sys_Int newSize) {
    sys_Array oarray = (sys_Array)array;
    sys_Array narray = (sys_Array)fr_arrayNew(__env, oarray->elemType, oarray->elemSize, newSize);
    
    uint64_t minSize = newSize < oarray->size? newSize : oarray->size;
    memcpy(narray->data, oarray->data, minSize*oarray->elemSize);
    return (sys_Obj)narray;
}

void sys_Array_arraycopy(fr_Env __env, sys_Obj src, sys_Int srcOffset, sys_Obj dest, sys_Int destOffset, sys_Int length) {
    sys_Array asrc = (sys_Array)src;
    sys_Array adest = (sys_Array)dest;
    if (asrc->elemType != adest->elemType) {
        FR_SET_ERROR_MAKE(sys_ArgErr, "arraycopy require same elemment type"); return;
    }
    memmove(((char*)adest->data)+(destOffset*adest->elemSize),
            ((char*)asrc->data)+(srcOffset*asrc->elemSize), length*asrc->elemSize);
}

void sys_Array_fill(fr_Env __env, sys_Obj array, sys_Obj_null val, sys_Int times) {
    sys_Array oarray = (sys_Array)array;
    for (int64_t i = 0; i<times; ++i) {
        oarray->data[i] = val;
    }
}

void sys_Array_finalize(fr_Env __env, sys_Array_ref __self) {}


