//
//  sys_Array.c
//  run
//
//  Created by yangjiandong on 2017/12/17.
//  Copyright © 2017年 yangjiandong. All rights reserved.
//

#include "sys.h"


fr_Err sys_Array_make(fr_Env __env, sys_Array_ref __self, sys_Int size){
    return 0;
}
fr_Err sys_Array_size(fr_Env __env, sys_Int *__ret, sys_Array_ref __self){
    *__ret = __self->size;
    return 0;
}
fr_Err sys_Array_get(fr_Env __env, sys_Obj_null *__ret, sys_Array_ref __self, sys_Int pos){
    *__ret = ((sys_Obj_null*)__self->data)[pos];
    return 0;
}
fr_Err sys_Array_set(fr_Env __env, sys_Array_ref __self, sys_Int pos, sys_Obj_null val){
    ((sys_Obj_null*)__self->data)[pos] = val;
    return 0;
}
fr_Err sys_Array_realloc(fr_Env __env, sys_Obj *__ret, sys_Obj array, sys_Int newSize){
    sys_Array oarray = (sys_Array)array;
    sys_Array narray = (sys_Array)fr_arrayNew(__env, oarray->elemType, oarray->elemSize, newSize);
    
    uint64_t minSize = newSize < oarray->size? newSize : oarray->size;
    memcpy(narray->data, oarray->data, minSize*oarray->elemSize);
    *__ret = (sys_Obj)narray;
    
    //puts((const char*)oarray->data);
    return NULL;
}
fr_Err sys_Array_arraycopy(fr_Env __env, sys_Obj src, sys_Int srcOffset, sys_Obj dest, sys_Int destOffset, sys_Int length){
    sys_Array asrc = (sys_Array)src;
    sys_Array adest = (sys_Array)dest;
    if (asrc->elemType != adest->elemType) {
        FR_RET_ALLOC_THROW(sys_ArgErr);
    }
    memmove(((char*)adest->data)+(destOffset*adest->elemSize),
            ((char*)asrc->data)+(srcOffset*asrc->elemSize), length*asrc->elemSize);
    return NULL;
}
fr_Err sys_Array_fill(fr_Env __env, sys_Obj array, sys_Obj_null val, sys_Int times){
    sys_Array oarray = (sys_Array)array;
    for (uint64_t i = 0; i<times; ++i) {
        oarray->data[i] = val;
    }
    return NULL;
}
fr_Err sys_Array_finalize(fr_Env __env, sys_Array_ref __self){ return 0; }

