#include "vm.h"
#include "pod_sys_struct.h"
#include "pod_sys_native.h"

#include <stdlib.h>
#include <string.h>

void sys_Array_make(fr_Env env, fr_Obj self, fr_Int size) {
    fr_Array *array;
    //fr_lock(env);
    array = (fr_Array *)fr_getPtr(env, self);
    
    fr_Int len = sizeof(fr_Obj)*size;
    array->size = size;
    array->elemType = fr_findType(env, "sys", "Obj");
    //array->data = (FObj**)malloc(len);
    memset(array->data, 0, len);
    
    //fr_unlock(env);
    return;
}
fr_Obj sys_Array_get(fr_Env env, fr_Obj self, fr_Int pos) {
    fr_Array *array;
    fr_Obj result;
    //fr_lock(env);
    array = (fr_Array *)fr_getPtr(env, self);
    result = fr_toHandle(env, array->data[pos]);
    //fr_unlock(env);
    return result;
}
void sys_Array_set(fr_Env env, fr_Obj self, fr_Int pos, fr_Obj val) {
    fr_Array *array;
    //fr_Obj result;
    //fr_lock(env);
    array = (fr_Array *)fr_getPtr(env, self);
    array->data[pos] = fr_getPtr(env, val);
    //fr_unlock(env);
    return;
}
fr_Int sys_Array_size(fr_Env env, fr_Obj self) {
    fr_Array *array;
    fr_Int result;
    //fr_lock(env);
    array = (fr_Array *)fr_getPtr(env, self);
    result = array->size;
    //fr_unlock(env);
    return result;
}
fr_Obj sys_Array_realloc(fr_Env env, fr_Obj self, fr_Int newSize) {
    fr_Array *array;
    fr_Array *narray;
    //FObj **p;
    
    //bool result;
    //fr_lock(env);
    array = (fr_Array *)fr_getPtr(env, self);
    
    fr_Obj newArray = fr_arrayNew(self, array->elemType, array->elemSize, newSize);
    narray = (fr_Array *)fr_getPtr(self, newArray);
    //p = realloc(array->data, newSize * sizeof(fr_Obj));
//    if (p) {
//        if (newSize > array->size) {
//            memset(p+array->size, 0, sizeof(fr_Obj)*(newSize - array->size));
//        }
//        array->data = p;
//        array->size = newSize;
//        //result = true;
//    }
    //result = false;
    //fr_unlock(env);
    size_t allocSize = sizeof(struct sys_Array_struct) + (newSize*sizeof(void*));
    memcpy(narray, array, allocSize);
    narray->size = newSize;
    return newArray;
}

void sys_Array_arraycopy(fr_Env env, fr_Obj src, fr_Int srcOffset, fr_Obj dest, fr_Int destOffset, fr_Int length) {
    fr_Array *array;
    fr_Array *other;
    
    //fr_lock(env);
    array = (fr_Array *)fr_getPtr(env, dest);
    other = (fr_Array *)fr_getPtr(env, src);
    
    memccpy(array->data+destOffset, other->data, srcOffset, length);
    
    //fr_unlock(env);
}
void sys_Array_fill(fr_Env env, fr_Obj self, fr_Obj obj, fr_Int times) {
    fr_Array *array;
    //fr_lock(env);
    array = (fr_Array *)fr_getPtr(env, self);
    memset(array->data, (int64_t)obj, times);
}
//fr_Obj sys_Array_fromJava(fr_Env env, fr_Obj of, fr_Obj array) {
//    return NULL;
//}
//fr_Obj sys_Array_toJava(fr_Env env, fr_Obj self, fr_Obj clz) {
//    return NULL;
//}
void sys_Array_finalize(fr_Env env, fr_Obj self) {
    //fr_Array *array;
    //fr_lock(env);
    //array = (fr_Array *)fr_getPtr(env, self);
    //free(array->data);
    //array->data = NULL;
    //array->size = 0;
    //fr_unlock(env);
}
void sys_Array_static__init(fr_Env env) {
    return;
}
