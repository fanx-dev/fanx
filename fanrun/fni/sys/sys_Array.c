#include "fni_ext.h"
//#include "pod_sys_struct.h"
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
    array->elemSize = sizeof(void*);
    //array->data = (FObj**)malloc(len);
    memset(array->data, 0, len*array->elemSize);
    
    //fr_unlock(env);
    return;
}
fr_Obj sys_Array_get(fr_Env env, fr_Obj self, fr_Int pos) {
    fr_Array *array;
    fr_Obj result;
    //fr_lock(env);
    array = (fr_Array *)fr_getPtr(env, self);
    result = fr_toHandle(env, ((FObj**)array->data)[pos]);
    //fr_unlock(env);
    return result;
}
void sys_Array_set(fr_Env env, fr_Obj self, fr_Int pos, fr_Obj val) {
    fr_Array *array;
    //fr_Obj result;
    //fr_lock(env);
    array = (fr_Array *)fr_getPtr(env, self);
    ((FObj**)array->data)[pos] = fr_getPtr(env, val);
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
    
    fr_Obj newArray = fr_arrayNew(env, array->elemType, array->elemSize, newSize);
    narray = (fr_Array *)fr_getPtr(env, newArray);
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
    size_t copySize = sizeof(struct fr_Array_) + (newSize * array->elemSize);
    size_t oldSize = sizeof(struct fr_Array_) + (array->size * array->elemSize);
    if (oldSize < copySize) {
        copySize = oldSize;
    }
    memcpy(narray, array, copySize);
    narray->size = newSize;
    return newArray;
}

void sys_Array_arraycopy(fr_Env env, fr_Obj src, fr_Int srcOffset, fr_Obj dest, fr_Int destOffset, fr_Int length) {
    fr_Array *array;
    fr_Array *other;
    
    //fr_lock(env);
    array = (fr_Array *)fr_getPtr(env, dest);
    other = (fr_Array *)fr_getPtr(env, src);
    
    memcpy(((char*)array->data)+destOffset, ((char*)other->data) + srcOffset, length);
    
    //fr_unlock(env);
}
void sys_Array_fill(fr_Env env, fr_Obj self, fr_Obj obj, fr_Int times) {
    fr_Array *array;
    //fr_lock(env);
    array = (fr_Array *)fr_getPtr(env, self);

    for (int i = 0; i < times; ++i) {
        ((FObj**)array->data)[i] = fr_getPtr(env, obj);
    }
    //memset(array->data, (int64_t)obj, times);
}

void sys_Array_finalize(fr_Env env, fr_Obj self) {
}
void sys_Array_static__init(fr_Env env) {
    return;
}
