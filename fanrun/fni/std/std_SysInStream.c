#include "fni_ext.h"
#include "pod_std_native.h"

#include <stdio.h>

FILE* std_SysInStream_getNativePeer(fr_Env env, fr_Obj obj) {
    static fr_Field field = NULL;
    if (field == NULL) field = fr_findField(env, fr_getObjType(env, obj), "handle");
    fr_Value res;
    fr_getInstanceField(env, obj, field, &res);
    return (FILE*)res.i;
}

void std_SysInStream_setNativePeer(fr_Env env, fr_Obj obj, FILE* file) {
    static fr_Field field = NULL;
    if (field == NULL) field = fr_findField(env, fr_getObjType(env, obj), "handle");
    fr_Value val;
    val.i = (fr_Int)file;
    fr_setInstanceField(env, obj, field, &val);
}

fr_Int std_SysInStream_toSigned(fr_Env env, fr_Int val, fr_Int byteNum) {
    switch ((int)byteNum) {
    case 1:
        return (int8_t)val;
    case 2:
        return (int16_t)val;
    case 4:
        return (int64_t)val;
    }
    return val;
}
fr_Int std_SysInStream_avail(fr_Env env, fr_Obj self) {
    FILE* file = std_SysInStream_getNativePeer(env, self);
    int64_t prev = ftell(file);
    fseek(file, 0L, SEEK_END);
    int64_t sz = ftell(file);
    fseek(file, prev, SEEK_SET);
    return sz-prev;
}
fr_Int std_SysInStream_read(fr_Env env, fr_Obj self) {
    FILE* file = std_SysInStream_getNativePeer(env, self);
    int byte = fgetc(file);
    if (byte == EOF) return -1;
    return byte;
}
fr_Int std_SysInStream_skip(fr_Env env, fr_Obj self, fr_Int n) {
    FILE* file = std_SysInStream_getNativePeer(env, self);
    return 0;
}
fr_Int std_SysInStream_readBytes(fr_Env env, fr_Obj self, fr_Obj ba, fr_Int off, fr_Int len) {
    FILE* file = std_SysInStream_getNativePeer(env, self);

    if (fr_arrayLen(env, ba) > off + len) {
        fr_throwNew(env, "sys", "IOErr", "readBytes out buffer");
        return;
    }

    char* buf = (char*)fr_arrayData(env, ba);

    int realReadNum = fread(buf+off, len, 1, file);
    return realReadNum;
}
fr_Obj std_SysInStream_unread(fr_Env env, fr_Obj self, fr_Int n) {
    FILE* file = std_SysInStream_getNativePeer(env, self);
    int res = ungetc(n, file);
    if (res == EOF) {
        fr_throwNew(env, "sys", "IOErr", "unread failure");
        return;
    }
    return self;
}
fr_Bool std_SysInStream_close(fr_Env env, fr_Obj self) {
    FILE* file = std_SysInStream_getNativePeer(env, self);
    if (file == NULL) return true;
    fclose(file);
    std_SysInStream_setNativePeer(env, self, NULL);
    return true;
}
