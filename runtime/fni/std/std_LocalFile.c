#include "fni_ext.h"
#include "pod_std_native.h"
#include <stdio.h>

void std_SysOutStream_setNativePeer(fr_Env env, fr_Obj obj, FILE* file);
void std_SysInStream_setNativePeer(fr_Env env, fr_Obj obj, FILE* file);

fr_Obj std_LocalFile_in(fr_Env env, fr_Obj self, fr_Int bufferSize) {

    fr_Obj path = fr_callOnObj(env, self, "osPath", 0).h;
    const char* pathStr = fr_getStrUtf8(env, path);
    FILE* file = fopen(pathStr, "r");

    if (file == NULL) {
        fr_throwNew(env, "sys", "IOErr", "can not open file");
        return NULL;
    }

    fr_Obj out = fr_newObjS(env, "std", "SysInStream", "make", 0);
    std_SysInStream_setNativePeer(env, out, file);
    return out;
}
fr_Obj std_LocalFile_out(fr_Env env, fr_Obj self, fr_Bool append, fr_Int bufferSize) {
    
    fr_Obj path = fr_callOnObj(env, self, "osPath", 0).h;
    const char* pathStr = fr_getStrUtf8(env, path);
    FILE* file = fopen(pathStr, append?"ab":"wb");

    if (file == NULL) {
        fr_throwNew(env, "sys", "IOErr", "can not open file");
        return NULL;
    }

    fr_Obj out = fr_newObjS(env, "std", "SysOutStream", "make", 0);
    std_SysOutStream_setNativePeer(env, out, file);
    return out;
}
