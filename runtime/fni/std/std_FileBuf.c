#include "fni_ext.h"
#include "pod_std_native.h"
#include <stdio.h>
#include <stdint.h>

#ifdef _WIN64
#include <Windows.h>
#include <io.h>
#else
#include <unistd.h>
#endif

static FILE* getFile(fr_Env env, fr_Obj self) {
    static fr_Field f = NULL;
    if (f == NULL) f = fr_findField(env, fr_getObjType(env, self), "handle");
    fr_Value val;
    fr_getInstanceField(env, self, f, &val);
    FILE* raw = (FILE*)(val.i);
    return raw;
}

static void setFile(fr_Env env, fr_Obj self, FILE* r) {
    static fr_Field f = NULL;
    if (f == NULL) f = fr_findField(env, fr_getObjType(env, self), "handle");
    fr_Value val;
    val.i = (fr_Int)r;
    fr_setInstanceField(env, self, f, &val);
}

fr_Bool std_FileBuf_init(fr_Env env, fr_Obj self, fr_Obj file, fr_Obj mode) {
    const char* fileStr = fr_getStrUtf8(env, file);
    const char* modeStr = fr_getStrUtf8(env, mode);
    FILE* f = fopen(fileStr, modeStr);
    if (f == NULL) {
        return false;
    }
    setFile(env, self, f);
    return true;
}
fr_Int std_FileBuf_size(fr_Env env, fr_Obj self) {
    FILE *file = getFile(env, self);
    fr_Int oldPos = ftell(file);
    fseek(file, 0, SEEK_END);
    fr_Int size = ftell(file);
    fseek(file, oldPos, SEEK_SET);
    return size;
}
void std_FileBuf_size__1(fr_Env env, fr_Obj self, fr_Int it) {
    FILE* file = getFile(env, self);
#ifdef _WIN64
    _chsize(_fileno(file), it);
#else
    ftruncate(fileno(file), it);
#endif
}
fr_Int std_FileBuf_capacity(fr_Env env, fr_Obj self) {
    return INT64_MAX;
}
void std_FileBuf_capacity__1(fr_Env env, fr_Obj self, fr_Int it) {
    return;
}
fr_Int std_FileBuf_pos(fr_Env env, fr_Obj self) {
    FILE* f = getFile(env, self);
    fr_Int pos = ftell(f);
    return pos;
}
void std_FileBuf_pos__1(fr_Env env, fr_Obj self, fr_Int it) {
    FILE* f = getFile(env, self);
    fseek(f, it, SEEK_SET);
}
fr_Int std_FileBuf_getByte(fr_Env env, fr_Obj self, fr_Int index) {
    FILE* file = getFile(env, self);
    fr_Int oldPos = ftell(file);
    fseek(file, index, SEEK_SET);
    int byte = fgetc(file);

    fseek(file, oldPos, SEEK_SET);
    if (byte == EOF) return -1;
    return byte;
}
void std_FileBuf_setByte(fr_Env env, fr_Obj self, fr_Int index, fr_Int byte) {
    FILE* file = getFile(env, self);
    fr_Int oldPos = ftell(file);
    fseek(file, index, SEEK_SET);
    fputc(byte, file);
    fseek(file, oldPos, SEEK_SET);
}
fr_Int std_FileBuf_getBytes(fr_Env env, fr_Obj self, fr_Int pos, fr_Obj dst, fr_Int off, fr_Int len) {
    FILE* file = getFile(env, self);

    if (fr_arrayLen(env, dst) > off + len) {
        fr_throwNew(env, "sys", "IOErr", "readBytes out buffer");
        return;
    }

    fr_Int oldPos = ftell(file);
    fseek(file, pos, SEEK_SET);

    char* buf = (char*)fr_arrayData(env, dst);
    int realReadNum = fread(buf + off, len, 1, file);

    fseek(file, oldPos, SEEK_SET);
    return realReadNum;
}
void std_FileBuf_setBytes(fr_Env env, fr_Obj self, fr_Int pos, fr_Obj src, fr_Int off, fr_Int len) {
    FILE* file = getFile(env, self);

    if (fr_arrayLen(env, src) > off + len) {
        fr_throwNew(env, "sys", "IOErr", "readBytes out buffer");
        return;
    }

    fr_Int oldPos = ftell(file);
    fseek(file, pos, SEEK_SET);

    char* buf = (char*)fr_arrayData(env, src);
    fwrite(buf + off, len, 1, file);

    fseek(file, oldPos, SEEK_SET);
}
fr_Bool std_FileBuf_close(fr_Env env, fr_Obj self) {
    FILE* file = getFile(env, self);
    if (file == NULL) return true;
    fflush(file);
    fclose(file);
    setFile(env, self, NULL);
    return true;
}
fr_Obj std_FileBuf_sync(fr_Env env, fr_Obj self) {
    FILE* file = getFile(env, self);
    fflush(file);

#ifndef _WIN64
    int fd = fileno(file);
    if (fd != -1) {
        fsync(fd);
    }
#endif
    return self;
}
