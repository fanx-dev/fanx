#include "fni_ext.h"
//#include "pod_sys_struct.h"
#include "pod_sys_native.h"

#include <stdlib.h>
#include <string.h>

void sys_Array_make(fr_Env env, fr_Obj self, fr_Int size) {
    fr_Array *array;
    //fr_lock(env);
    array = (fr_Array *)fr_getPtr(env, self);
    
    array->size = size;
    array->elemType = fr_findType(env, "sys", "Obj");
    array->elemSize = sizeof(void*);
    array->valueType = fr_vtObj;
    //array->data = (FObj**)malloc(len);
    memset(array->data, 0, size*array->elemSize);
    
    //fr_unlock(env);
    if (size < 0) {
        fr_throwNew(self, "sys", "ArgErr", "alloc size < 0");
        return;
    }
    return;
}
fr_Obj sys_Array_get(fr_Env env, fr_Obj self, fr_Int pos) {
    fr_Array *array;
    fr_Obj result;
    //fr_lock(env);
    array = (fr_Array *)fr_getPtr(env, self);
    if (pos >= array->size) {
        fr_throwNew(self, "sys", "IndexErr", "out index");
        return NULL;
    }
    result = fr_toHandle(env, ((FObj**)array->data)[pos]);
    //fr_unlock(env);
    return result;
}
void sys_Array_set(fr_Env env, fr_Obj self, fr_Int pos, fr_Obj val) {
    fr_Array *array;
    //fr_Obj result;
    //fr_lock(env);
    array = (fr_Array *)fr_getPtr(env, self);
    if (pos >= array->size) {
        fr_throwNew(self, "sys", "IndexErr", "out index");
        return;
    }
    FObj* obj = fr_getPtr(env, val);
    ((FObj**)array->data)[pos] = obj;
    fr_setGcDirty(env, obj);
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
    if (newSize < 0) {
        fr_throwNew(self, "sys", "ArgErr", "realloc size < 0");
        return NULL;
    }
    
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

    //fr_lock(env);
    fr_Array* destArray = (fr_Array *)fr_getPtr(env, dest);
    fr_Array* srcArray = (fr_Array *)fr_getPtr(env, src);

    if (destOffset + length > destArray->size) {
        fr_throwNew(env, "sys", "IndexErr", "out index");
        return;
    }
    if (srcOffset + length > srcArray->size) {
        fr_throwNew(env, "sys", "IndexErr", "out index");
        return;
    }
    
    assert(destArray->elemSize == srcArray->elemSize);
    
    char *destData = (char*)(destArray->data) + (destOffset*destArray->elemSize);
    char *srcData = (char*)(srcArray->data) + (srcOffset*destArray->elemSize);
    
    if (destArray != srcArray) {
        memcpy(destData, srcData, length*destArray->elemSize);
    }
    else {
        memmove(destData, srcData, length*destArray->elemSize);
    }
    fr_setGcDirty(env, destArray);
    //fr_unlock(env);
}
//void sys_Array_fill(fr_Env env, fr_Obj self, fr_Obj obj, fr_Int times) {
//    fr_Array *array;
//    //fr_lock(env);
//    array = (fr_Array *)fr_getPtr(env, self);
//
//    if (times > array->size) {
//        fr_throwNew(self, "sys", "IndexErr", "out index");
//        return;
//    }
//
//    for (int i = 0; i < times; ++i) {
//        ((FObj**)array->data)[i] = fr_getPtr(env, obj);
//    }
//    //memset(array->data, (int64_t)obj, times);
//
//    fr_setGcDirty(env, array);
//}

void sys_Array_finalize(fr_Env env, fr_Obj self) {
}
//void sys_Array_static__init(fr_Env env) {
//    return;
//}
