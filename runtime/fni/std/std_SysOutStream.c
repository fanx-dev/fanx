#include "fni_ext.h"
#include "pod_std_native.h"

#include <stdio.h>

#ifndef _WIN64
#include <unistd.h>
#endif

FILE * std_SysOutStream_getNativePeer(fr_Env env, fr_Obj obj) {
    static fr_Field field = NULL;
    if (field == NULL) field = fr_findField(env, fr_getObjType(env, obj), "handle");
    fr_Value res;
    fr_getInstanceField(env, obj, field, &res);
    return (FILE*)res.i;
}

void std_SysOutStream_setNativePeer(fr_Env env, fr_Obj obj, FILE *file) {
    static fr_Field field = NULL;
    if (field == NULL) field = fr_findField(env, fr_getObjType(env, obj), "handle");
    fr_Value val;
    val.i = (fr_Int)file;
    fr_setInstanceField(env, obj, field, &val);
}

fr_Obj std_SysOutStream_write(fr_Env env, fr_Obj self, fr_Int byte) {
    FILE* file = std_SysOutStream_getNativePeer(env, self);
    fputc(byte, file);
    return self;
}
fr_Obj std_SysOutStream_writeBytes(fr_Env env, fr_Obj self, fr_Obj ba, fr_Int off, fr_Int len) {
    FILE* file = std_SysOutStream_getNativePeer(env, self);

    if (fr_arrayLen(env, ba) < off + len) {
        fr_throwNew(env, "sys", "IOErr", "writeBytes out buffer");
        return self;
    }

    char *buf = (char*)fr_arrayData(env, ba);

    fwrite(buf+off, len, 1, file);
    return self;
}
fr_Obj std_SysOutStream_sync(fr_Env env, fr_Obj self) {
    FILE* file = std_SysOutStream_getNativePeer(env, self);
    fflush(file);

#ifndef _WIN64
    int fd = fileno(file);
    if (fd != -1) {
        fsync(fd);
    }
#endif
    return self;
}
fr_Obj std_SysOutStream_flush(fr_Env env, fr_Obj self) {
    FILE* file = std_SysOutStream_getNativePeer(env, self);
    fflush(file);
    return self;
}
fr_Bool std_SysOutStream_close(fr_Env env, fr_Obj self) {
    FILE* file = std_SysOutStream_getNativePeer(env, self);
    if (file == NULL) return true;
    fflush(file);
    fclose(file);
    std_SysOutStream_setNativePeer(env, self, NULL);
    return true;
}
