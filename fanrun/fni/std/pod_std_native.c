#include "pod_std_native.h"

void std_BufCrypto_toDigest_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_BufCrypto_toDigest(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_BufCrypto_crc_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_BufCrypto_crc(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_BufCrypto_hmac_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value retValue;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_BufCrypto_hmac(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

void std_BufCrypto_pbk_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Int arg_3; 
    fr_Value value_4;
    fr_Int arg_4; 
    fr_Value retValue;

    fr_getParam(env, param, &value_4, 4, NULL);
    arg_4 = value_4.i;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.i;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_BufCrypto_pbk(env, arg_0, arg_1, arg_2, arg_3, arg_4);
    *((fr_Value*)ret) = retValue;
}

void std_NativeCharset_fromStr_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_NativeCharset_fromStr(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_NativeCharset_encode_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value retValue;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_NativeCharset_encode(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

void std_NativeCharset_encodeArray_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Int arg_3; 
    fr_Value retValue;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.i;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_NativeCharset_encodeArray(env, arg_0, arg_1, arg_2, arg_3);
    *((fr_Value*)ret) = retValue;
}

void std_NativeCharset_decode_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_NativeCharset_decode(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_FileSystem_exists_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_FileSystem_exists(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_FileSystem_size_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_FileSystem_size(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_FileSystem_modified_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_FileSystem_modified(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_FileSystem_setModified_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_FileSystem_setModified(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_FileSystem_uriToPath_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_FileSystem_uriToPath(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_FileSystem_pathToUri_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_FileSystem_pathToUri(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_FileSystem_list_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_FileSystem_list(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_FileSystem_normalize_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_FileSystem_normalize(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_FileSystem_createDirs_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_FileSystem_createDirs(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_FileSystem_createFile_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_FileSystem_createFile(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_FileSystem_moveTo_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_FileSystem_moveTo(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_FileSystem_copyTo_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_FileSystem_copyTo(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_FileSystem_delete__v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_FileSystem_delete_(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_FileSystem_isReadable_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_FileSystem_isReadable(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_FileSystem_isWritable_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_FileSystem_isWritable(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_FileSystem_isExecutable_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_FileSystem_isExecutable(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_FileSystem_isDir_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_FileSystem_isDir(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_FileSystem_tempDir_v(fr_Env env, void *param, void *ret) {
    fr_Value retValue;


    retValue.h = std_FileSystem_tempDir(env);
    *((fr_Value*)ret) = retValue;
}

void std_FileSystem_osRoots_v(fr_Env env, void *param, void *ret) {
    fr_Value retValue;


    retValue.h = std_FileSystem_osRoots(env);
    *((fr_Value*)ret) = retValue;
}

void std_FileSystem_getSpaceInfo_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_FileSystem_getSpaceInfo(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_FileSystem_fileSep_v(fr_Env env, void *param, void *ret) {
    fr_Value retValue;


    retValue.h = std_FileSystem_fileSep(env);
    *((fr_Value*)ret) = retValue;
}

void std_FileSystem_pathSep_v(fr_Env env, void *param, void *ret) {
    fr_Value retValue;


    retValue.h = std_FileSystem_pathSep(env);
    *((fr_Value*)ret) = retValue;
}

void std_LocalFile_in_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_LocalFile_in(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_LocalFile_out_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Bool arg_1; 
    fr_Value value_2;
    fr_Int arg_2; 
    fr_Value retValue;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.i;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.b;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_LocalFile_out(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

void std_FileBuf_init_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_FileBuf_init(env, arg_0, arg_1, arg_2);
}

void std_FileBuf_size_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_FileBuf_size(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_FileBuf_size__1_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_FileBuf_size__1(env, arg_0, arg_1);
}

void std_FileBuf_capacity_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_FileBuf_capacity(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_FileBuf_capacity__1_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_FileBuf_capacity__1(env, arg_0, arg_1);
}

void std_FileBuf_pos_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_FileBuf_pos(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_FileBuf_pos__1_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_FileBuf_pos__1(env, arg_0, arg_1);
}

void std_FileBuf_getByte_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_FileBuf_getByte(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_FileBuf_setByte_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value value_2;
    fr_Int arg_2; 

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.i;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_FileBuf_setByte(env, arg_0, arg_1, arg_2);
}

void std_FileBuf_getBytes_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Int arg_3; 
    fr_Value value_4;
    fr_Int arg_4; 
    fr_Value retValue;

    fr_getParam(env, param, &value_4, 4, NULL);
    arg_4 = value_4.i;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.i;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_FileBuf_getBytes(env, arg_0, arg_1, arg_2, arg_3, arg_4);
    *((fr_Value*)ret) = retValue;
}

void std_FileBuf_setBytes_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Int arg_3; 
    fr_Value value_4;
    fr_Int arg_4; 

    fr_getParam(env, param, &value_4, 4, NULL);
    arg_4 = value_4.i;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.i;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_FileBuf_setBytes(env, arg_0, arg_1, arg_2, arg_3, arg_4);
}

void std_FileBuf_close_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_FileBuf_close(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_FileBuf_sync_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_FileBuf_sync(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_SysInStream_toSigned_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.i;


    retValue.i = std_SysInStream_toSigned(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_SysInStream_avail_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_SysInStream_avail(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_SysInStream_read_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_SysInStream_read(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_SysInStream_skip_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_SysInStream_skip(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_SysInStream_readBytes_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Int arg_2; 
    fr_Value value_3;
    fr_Int arg_3; 
    fr_Value retValue;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.i;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.i;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_SysInStream_readBytes(env, arg_0, arg_1, arg_2, arg_3);
    *((fr_Value*)ret) = retValue;
}

void std_SysInStream_unread_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_SysInStream_unread(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_SysInStream_close_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_SysInStream_close(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_NioBuf_init_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Int arg_3; 
    fr_Value value_4;
    fr_Obj arg_4; 

    fr_getParam(env, param, &value_4, 4, NULL);
    arg_4 = value_4.h;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.i;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_NioBuf_init(env, arg_0, arg_1, arg_2, arg_3, arg_4);
}

void std_NioBuf_alloc_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_NioBuf_alloc(env, arg_0, arg_1);
}

void std_NioBuf_size_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_NioBuf_size(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_NioBuf_size__1_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_NioBuf_size__1(env, arg_0, arg_1);
}

void std_NioBuf_capacity_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_NioBuf_capacity(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_NioBuf_capacity__1_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_NioBuf_capacity__1(env, arg_0, arg_1);
}

void std_NioBuf_pos_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_NioBuf_pos(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_NioBuf_pos__1_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_NioBuf_pos__1(env, arg_0, arg_1);
}

void std_NioBuf_getByte_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_NioBuf_getByte(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_NioBuf_setByte_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value value_2;
    fr_Int arg_2; 

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.i;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_NioBuf_setByte(env, arg_0, arg_1, arg_2);
}

void std_NioBuf_getBytes_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Int arg_3; 
    fr_Value value_4;
    fr_Int arg_4; 
    fr_Value retValue;

    fr_getParam(env, param, &value_4, 4, NULL);
    arg_4 = value_4.i;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.i;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_NioBuf_getBytes(env, arg_0, arg_1, arg_2, arg_3, arg_4);
    *((fr_Value*)ret) = retValue;
}

void std_NioBuf_setBytes_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Int arg_3; 
    fr_Value value_4;
    fr_Int arg_4; 

    fr_getParam(env, param, &value_4, 4, NULL);
    arg_4 = value_4.i;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.i;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_NioBuf_setBytes(env, arg_0, arg_1, arg_2, arg_3, arg_4);
}

void std_NioBuf_close_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_NioBuf_close(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_NioBuf_sync_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_NioBuf_sync(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_SysOutStream_write_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_SysOutStream_write(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_SysOutStream_writeBytes_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Int arg_2; 
    fr_Value value_3;
    fr_Int arg_3; 
    fr_Value retValue;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.i;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.i;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_SysOutStream_writeBytes(env, arg_0, arg_1, arg_2, arg_3);
    *((fr_Value*)ret) = retValue;
}

void std_SysOutStream_sync_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_SysOutStream_sync(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_SysOutStream_flush_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_SysOutStream_flush(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_SysOutStream_close_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_SysOutStream_close(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_AtomicBool_init_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Bool arg_1; 

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.b;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_AtomicBool_init(env, arg_0, arg_1);
}

void std_AtomicBool_val_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_AtomicBool_val(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_AtomicBool_val__1_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Bool arg_1; 

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.b;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_AtomicBool_val__1(env, arg_0, arg_1);
}

void std_AtomicBool_getAndSet_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Bool arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.b;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_AtomicBool_getAndSet(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_AtomicBool_compareAndSet_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Bool arg_1; 
    fr_Value value_2;
    fr_Bool arg_2; 
    fr_Value retValue;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.b;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.b;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_AtomicBool_compareAndSet(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

void std_AtomicBool_finalize_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_AtomicBool_finalize(env, arg_0);
}

void std_AtomicInt_init_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_AtomicInt_init(env, arg_0, arg_1);
}

void std_AtomicInt_val_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_AtomicInt_val(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_AtomicInt_val__1_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_AtomicInt_val__1(env, arg_0, arg_1);
}

void std_AtomicInt_getAndSet_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_AtomicInt_getAndSet(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_AtomicInt_compareAndSet_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value value_2;
    fr_Int arg_2; 
    fr_Value retValue;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.i;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_AtomicInt_compareAndSet(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

void std_AtomicInt_getAndAdd_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_AtomicInt_getAndAdd(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_AtomicInt_addAndGet_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_AtomicInt_addAndGet(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_AtomicInt_finalize_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_AtomicInt_finalize(env, arg_0);
}

void std_AtomicRef_init_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_AtomicRef_init(env, arg_0, arg_1);
}

void std_AtomicRef_val_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_AtomicRef_val(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_AtomicRef_val__1_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_AtomicRef_val__1(env, arg_0, arg_1);
}

void std_AtomicRef_getAndSet_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_AtomicRef_getAndSet(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_AtomicRef_compareAndSet_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value retValue;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_AtomicRef_compareAndSet(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

void std_AtomicRef_finalize_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_AtomicRef_finalize(env, arg_0);
}

void std_Lock_init_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_Lock_init(env, arg_0);
}

void std_Lock_tryLock_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_Lock_tryLock(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Lock_lock_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_Lock_lock(env, arg_0);
}

void std_Lock_unlock_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_Lock_unlock(env, arg_0);
}

void std_Lock_finalize_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_Lock_finalize(env, arg_0);
}

void std_Field_getDirectly_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Field_getDirectly(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Field_setDirectly_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_Field_setDirectly(env, arg_0, arg_1, arg_2);
}

void std_Method_call_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Obj arg_3; 
    fr_Value value_4;
    fr_Obj arg_4; 
    fr_Value value_5;
    fr_Obj arg_5; 
    fr_Value value_6;
    fr_Obj arg_6; 
    fr_Value value_7;
    fr_Obj arg_7; 
    fr_Value value_8;
    fr_Obj arg_8; 
    fr_Value retValue;

    fr_getParam(env, param, &value_8, 8, NULL);
    arg_8 = value_8.h;

    fr_getParam(env, param, &value_7, 7, NULL);
    arg_7 = value_7.h;

    fr_getParam(env, param, &value_6, 6, NULL);
    arg_6 = value_6.h;

    fr_getParam(env, param, &value_5, 5, NULL);
    arg_5 = value_5.h;

    fr_getParam(env, param, &value_4, 4, NULL);
    arg_4 = value_4.h;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.h;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Method_call(env, arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7, arg_8);
    *((fr_Value*)ret) = retValue;
}

void std_Method_call__0_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Method_call__0(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Method_call__1_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Method_call__1(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Method_call__2_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value retValue;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Method_call__2(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

void std_Method_call__3_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Obj arg_3; 
    fr_Value retValue;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.h;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Method_call__3(env, arg_0, arg_1, arg_2, arg_3);
    *((fr_Value*)ret) = retValue;
}

void std_Method_call__4_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Obj arg_3; 
    fr_Value value_4;
    fr_Obj arg_4; 
    fr_Value retValue;

    fr_getParam(env, param, &value_4, 4, NULL);
    arg_4 = value_4.h;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.h;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Method_call__4(env, arg_0, arg_1, arg_2, arg_3, arg_4);
    *((fr_Value*)ret) = retValue;
}

void std_Method_call__5_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Obj arg_3; 
    fr_Value value_4;
    fr_Obj arg_4; 
    fr_Value value_5;
    fr_Obj arg_5; 
    fr_Value retValue;

    fr_getParam(env, param, &value_5, 5, NULL);
    arg_5 = value_5.h;

    fr_getParam(env, param, &value_4, 4, NULL);
    arg_4 = value_4.h;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.h;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Method_call__5(env, arg_0, arg_1, arg_2, arg_3, arg_4, arg_5);
    *((fr_Value*)ret) = retValue;
}

void std_Method_call__6_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Obj arg_3; 
    fr_Value value_4;
    fr_Obj arg_4; 
    fr_Value value_5;
    fr_Obj arg_5; 
    fr_Value value_6;
    fr_Obj arg_6; 
    fr_Value retValue;

    fr_getParam(env, param, &value_6, 6, NULL);
    arg_6 = value_6.h;

    fr_getParam(env, param, &value_5, 5, NULL);
    arg_5 = value_5.h;

    fr_getParam(env, param, &value_4, 4, NULL);
    arg_4 = value_4.h;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.h;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Method_call__6(env, arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6);
    *((fr_Value*)ret) = retValue;
}

void std_Method_call__7_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Obj arg_3; 
    fr_Value value_4;
    fr_Obj arg_4; 
    fr_Value value_5;
    fr_Obj arg_5; 
    fr_Value value_6;
    fr_Obj arg_6; 
    fr_Value value_7;
    fr_Obj arg_7; 
    fr_Value retValue;

    fr_getParam(env, param, &value_7, 7, NULL);
    arg_7 = value_7.h;

    fr_getParam(env, param, &value_6, 6, NULL);
    arg_6 = value_6.h;

    fr_getParam(env, param, &value_5, 5, NULL);
    arg_5 = value_5.h;

    fr_getParam(env, param, &value_4, 4, NULL);
    arg_4 = value_4.h;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.h;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Method_call__7(env, arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7);
    *((fr_Value*)ret) = retValue;
}

void std_MethodFunc_call_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Obj arg_3; 
    fr_Value value_4;
    fr_Obj arg_4; 
    fr_Value value_5;
    fr_Obj arg_5; 
    fr_Value value_6;
    fr_Obj arg_6; 
    fr_Value value_7;
    fr_Obj arg_7; 
    fr_Value value_8;
    fr_Obj arg_8; 
    fr_Value retValue;

    fr_getParam(env, param, &value_8, 8, NULL);
    arg_8 = value_8.h;

    fr_getParam(env, param, &value_7, 7, NULL);
    arg_7 = value_7.h;

    fr_getParam(env, param, &value_6, 6, NULL);
    arg_6 = value_6.h;

    fr_getParam(env, param, &value_5, 5, NULL);
    arg_5 = value_5.h;

    fr_getParam(env, param, &value_4, 4, NULL);
    arg_4 = value_4.h;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.h;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_MethodFunc_call(env, arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7, arg_8);
    *((fr_Value*)ret) = retValue;
}

void std_MethodFunc_call__0_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_MethodFunc_call__0(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_MethodFunc_call__1_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_MethodFunc_call__1(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_MethodFunc_call__2_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value retValue;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_MethodFunc_call__2(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

void std_MethodFunc_call__3_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Obj arg_3; 
    fr_Value retValue;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.h;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_MethodFunc_call__3(env, arg_0, arg_1, arg_2, arg_3);
    *((fr_Value*)ret) = retValue;
}

void std_MethodFunc_call__4_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Obj arg_3; 
    fr_Value value_4;
    fr_Obj arg_4; 
    fr_Value retValue;

    fr_getParam(env, param, &value_4, 4, NULL);
    arg_4 = value_4.h;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.h;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_MethodFunc_call__4(env, arg_0, arg_1, arg_2, arg_3, arg_4);
    *((fr_Value*)ret) = retValue;
}

void std_MethodFunc_call__5_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Obj arg_3; 
    fr_Value value_4;
    fr_Obj arg_4; 
    fr_Value value_5;
    fr_Obj arg_5; 
    fr_Value retValue;

    fr_getParam(env, param, &value_5, 5, NULL);
    arg_5 = value_5.h;

    fr_getParam(env, param, &value_4, 4, NULL);
    arg_4 = value_4.h;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.h;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_MethodFunc_call__5(env, arg_0, arg_1, arg_2, arg_3, arg_4, arg_5);
    *((fr_Value*)ret) = retValue;
}

void std_MethodFunc_call__6_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Obj arg_3; 
    fr_Value value_4;
    fr_Obj arg_4; 
    fr_Value value_5;
    fr_Obj arg_5; 
    fr_Value value_6;
    fr_Obj arg_6; 
    fr_Value retValue;

    fr_getParam(env, param, &value_6, 6, NULL);
    arg_6 = value_6.h;

    fr_getParam(env, param, &value_5, 5, NULL);
    arg_5 = value_5.h;

    fr_getParam(env, param, &value_4, 4, NULL);
    arg_4 = value_4.h;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.h;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_MethodFunc_call__6(env, arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6);
    *((fr_Value*)ret) = retValue;
}

void std_MethodFunc_call__7_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Obj arg_3; 
    fr_Value value_4;
    fr_Obj arg_4; 
    fr_Value value_5;
    fr_Obj arg_5; 
    fr_Value value_6;
    fr_Obj arg_6; 
    fr_Value value_7;
    fr_Obj arg_7; 
    fr_Value retValue;

    fr_getParam(env, param, &value_7, 7, NULL);
    arg_7 = value_7.h;

    fr_getParam(env, param, &value_6, 6, NULL);
    arg_6 = value_6.h;

    fr_getParam(env, param, &value_5, 5, NULL);
    arg_5 = value_5.h;

    fr_getParam(env, param, &value_4, 4, NULL);
    arg_4 = value_4.h;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.h;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_MethodFunc_call__7(env, arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7);
    *((fr_Value*)ret) = retValue;
}

void std_PodList_doInit_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_PodList_doInit(env, arg_0);
}

void std_Pod_doInit_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_Pod_doInit(env, arg_0);
}

void std_Pod_load_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Pod_load(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Pod_files_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Pod_files(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Pod_file_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Bool arg_2; 
    fr_Value retValue;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.b;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Pod_file(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

void std_Type_typeof__v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Type_typeof_(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_BaseType_doInit_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_BaseType_doInit(env, arg_0);
}

void std_DateTime_fromTicks_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.i;


    retValue.h = std_DateTime_fromTicks(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_DateTime_make_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Int arg_2; 
    fr_Value value_3;
    fr_Int arg_3; 
    fr_Value value_4;
    fr_Int arg_4; 
    fr_Value value_5;
    fr_Int arg_5; 
    fr_Value value_6;
    fr_Int arg_6; 
    fr_Value value_7;
    fr_Obj arg_7; 
    fr_Value retValue;

    fr_getParam(env, param, &value_7, 7, NULL);
    arg_7 = value_7.h;

    fr_getParam(env, param, &value_6, 6, NULL);
    arg_6 = value_6.i;

    fr_getParam(env, param, &value_5, 5, NULL);
    arg_5 = value_5.i;

    fr_getParam(env, param, &value_4, 4, NULL);
    arg_4 = value_4.i;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.i;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.i;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.i;


    retValue.h = std_DateTime_make(env, arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7);
    *((fr_Value*)ret) = retValue;
}

void std_DateTime_dayOfYear_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_DateTime_dayOfYear(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_DateTime_weekOfYear_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_DateTime_weekOfYear(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_DateTime_hoursInDay_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_DateTime_hoursInDay(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_DateTime_toLocale_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value retValue;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_DateTime_toLocale(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

void std_DateTime_fromLocale_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Bool arg_3; 
    fr_Value retValue;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.b;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_DateTime_fromLocale(env, arg_0, arg_1, arg_2, arg_3);
    *((fr_Value*)ret) = retValue;
}

void std_DateTime_weekdayInMonth_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Int arg_3; 
    fr_Value retValue;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.i;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.i;


    retValue.i = std_DateTime_weekdayInMonth(env, arg_0, arg_1, arg_2, arg_3);
    *((fr_Value*)ret) = retValue;
}

void std_Locale_cur_v(fr_Env env, void *param, void *ret) {
    fr_Value retValue;


    retValue.h = std_Locale_cur(env);
    *((fr_Value*)ret) = retValue;
}

void std_Locale_setCur_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_Locale_setCur(env, arg_0);
}

void std_TimePoint_nowMillis_v(fr_Env env, void *param, void *ret) {
    fr_Value retValue;


    retValue.i = std_TimePoint_nowMillis(env);
    *((fr_Value*)ret) = retValue;
}

void std_TimePoint_nanoTicks_v(fr_Env env, void *param, void *ret) {
    fr_Value retValue;


    retValue.i = std_TimePoint_nanoTicks(env);
    *((fr_Value*)ret) = retValue;
}

void std_TimePoint_nowUnique_v(fr_Env env, void *param, void *ret) {
    fr_Value retValue;


    retValue.i = std_TimePoint_nowUnique(env);
    *((fr_Value*)ret) = retValue;
}

void std_TimeZone_listFullNames_v(fr_Env env, void *param, void *ret) {
    fr_Value retValue;


    retValue.h = std_TimeZone_listFullNames(env);
    *((fr_Value*)ret) = retValue;
}

void std_TimeZone_fromName_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_TimeZone_fromName(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_TimeZone_cur_v(fr_Env env, void *param, void *ret) {
    fr_Value retValue;


    retValue.h = std_TimeZone_cur(env);
    *((fr_Value*)ret) = retValue;
}

void std_TimeZone_dstOffset_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_TimeZone_dstOffset(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_fromStr_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Bool arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.b;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_fromStr(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_toDecimal_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_toDecimal(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_privateMake_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_Decimal_privateMake(env, arg_0);
}

void std_Decimal_equals_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_Decimal_equals(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_compare_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_Decimal_compare(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_hash_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_Decimal_hash(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_negate_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_negate(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_increment_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_increment(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_decrement_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_decrement(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_mult_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_mult(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_multInt_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_multInt(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_multFloat_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_multFloat(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_div_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_div(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_divInt_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_divInt(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_divFloat_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_divFloat(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_mod_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_mod(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_modInt_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_modInt(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_modFloat_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_modFloat(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_plus_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_plus(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_plusInt_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_plusInt(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_plusFloat_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_plusFloat(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_minus_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_minus(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_minusInt_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_minusInt(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_minusFloat_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_minusFloat(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_abs_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_abs(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_min_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_min(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_max_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_max(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_toStr_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_toStr(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_toCode_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_toCode(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_toInt_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_Decimal_toInt(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_toFloat_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.f = std_Decimal_toFloat(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Decimal_toLocale_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Decimal_toLocale(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Env_make_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_Env_make(env, arg_0);
}

void std_Env_platform_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_platform(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Env_os_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_os(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Env_arch_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_arch(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Env_runtime_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_runtime(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Env_isJs_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_Env_isJs(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Env_javaVersion_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_Env_javaVersion(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Env_idHash_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_Env_idHash(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Env_args_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_args(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Env_vars_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_vars(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Env_diagnostics_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_diagnostics(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Env_gc_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_Env_gc(env, arg_0);
}

void std_Env_host_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_host(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Env_user_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_user(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Env_in_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_in(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Env_out_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_out(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Env_err_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_err(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Env_promptPassword_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_promptPassword(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Env_homeDir_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_homeDir(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Env_workDir_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_workDir(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Env_tempDir_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_tempDir(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Env_findFile_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Bool arg_2; 
    fr_Value retValue;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.b;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_findFile(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

void std_Env_findAllFiles_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_findAllFiles(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Env_findPodFile_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_findPodFile(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Env_findAllPodNames_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_findAllPodNames(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Env_compileScript_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value retValue;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_compileScript(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

void std_Env_index_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_index(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Env_indexKeys_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_indexKeys(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Env_indexPodNames_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_indexPodNames(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Env_props_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Obj arg_3; 
    fr_Value retValue;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.h;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_props(env, arg_0, arg_1, arg_2, arg_3);
    *((fr_Value*)ret) = retValue;
}

void std_Env_config_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Obj arg_3; 
    fr_Value retValue;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.h;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_config(env, arg_0, arg_1, arg_2, arg_3);
    *((fr_Value*)ret) = retValue;
}

void std_Env_locale_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Obj arg_3; 
    fr_Value value_4;
    fr_Obj arg_4; 
    fr_Value retValue;

    fr_getParam(env, param, &value_4, 4, NULL);
    arg_4 = value_4.h;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.h;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Env_locale(env, arg_0, arg_1, arg_2, arg_3, arg_4);
    *((fr_Value*)ret) = retValue;
}

void std_Env_exit_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_Env_exit(env, arg_0, arg_1);
}

void std_Env_addShutdownHook_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_Env_addShutdownHook(env, arg_0, arg_1);
}

void std_Env_removeShutdownHook_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_Env_removeShutdownHook(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Extension_traceTo_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value retValue;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Extension_traceTo(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

void std_Log_printLogRec_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_Log_printLogRec(env, arg_0, arg_1);
}

void std_Math_ceil_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.f;


    retValue.f = std_Math_ceil(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Math_floor_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.f;


    retValue.f = std_Math_floor(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Math_round_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.f;


    retValue.f = std_Math_round(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Math_exp_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.f;


    retValue.f = std_Math_exp(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Math_log_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.f;


    retValue.f = std_Math_log(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Math_log10_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.f;


    retValue.f = std_Math_log10(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Math_pow_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.f;


    retValue.f = std_Math_pow(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Math_sqrt_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.f;


    retValue.f = std_Math_sqrt(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Math_acos_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.f;


    retValue.f = std_Math_acos(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Math_asin_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.f;


    retValue.f = std_Math_asin(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Math_atan_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.f;


    retValue.f = std_Math_atan(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Math_atan2_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.f;


    retValue.f = std_Math_atan2(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Math_cos_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.f;


    retValue.f = std_Math_cos(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Math_cosh_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.f;


    retValue.f = std_Math_cosh(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Math_sin_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.f;


    retValue.f = std_Math_sin(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Math_sinh_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.f;


    retValue.f = std_Math_sinh(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Math_tan_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.f;


    retValue.f = std_Math_tan(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Math_tanh_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.f;


    retValue.f = std_Math_tanh(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Math_toDegrees_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.f;


    retValue.f = std_Math_toDegrees(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Math_toRadians_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.f;


    retValue.f = std_Math_toRadians(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Process_env_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Process_env(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Process_outToIn_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Process_outToIn(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Process_run_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Process_run(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Process_join_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_Process_join(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Process_kill_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Process_kill(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Regex_init_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_Regex_init(env, arg_0);
}

void std_Regex_matches_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_Regex_matches(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Regex_matcher_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Regex_matcher(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Regex_split_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Int arg_2; 
    fr_Value retValue;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.i;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Regex_split(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

void std_RegexMatcher_make_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_RegexMatcher_make(env, arg_0);
}

void std_RegexMatcher_matches_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_RegexMatcher_matches(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_RegexMatcher_find_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_RegexMatcher_find(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_RegexMatcher_replaceFirst_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_RegexMatcher_replaceFirst(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_RegexMatcher_replaceAll_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_RegexMatcher_replaceAll(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_RegexMatcher_groupCount_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_RegexMatcher_groupCount(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_RegexMatcher_group_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_RegexMatcher_group(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_RegexMatcher_start_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_RegexMatcher_start(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_RegexMatcher_end_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = std_RegexMatcher_end(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_RegexMatcher_finalize_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_RegexMatcher_finalize(env, arg_0);
}

void std_Uuid_make_v(fr_Env env, void *param, void *ret) {
    fr_Value retValue;


    retValue.h = std_Uuid_make(env);
    *((fr_Value*)ret) = retValue;
}

void std_Zip_open_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Zip_open(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Zip_read_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Zip_read(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Zip_write_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Zip_write(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Zip_init_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    std_Zip_init(env, arg_0, arg_1);
}

void std_Zip_file_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Zip_file(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Zip_contents_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Zip_contents(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Zip_readNext_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Zip_readNext(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Zip_writeNext_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Obj arg_3; 
    fr_Value retValue;

    fr_getParam(env, param, &value_3, 3, NULL);
    arg_3 = value_3.h;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Zip_writeNext(env, arg_0, arg_1, arg_2, arg_3);
    *((fr_Value*)ret) = retValue;
}

void std_Zip_finish_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_Zip_finish(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Zip_close_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = std_Zip_close(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Zip_toStr_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Zip_toStr(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Zip_gzipOutStream_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Zip_gzipOutStream(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Zip_gzipInStream_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Zip_gzipInStream(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void std_Zip_deflateOutStream_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Zip_deflateOutStream(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void std_Zip_deflateInStream_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = std_Zip_deflateInStream(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

