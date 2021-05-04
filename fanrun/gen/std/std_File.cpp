#include "std.h"




std_File std_File_make(fr_Env __env, std_Uri uri, sys_Bool checkSlash) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_File std_File_os(fr_Env __env, sys_Str osPath) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_List std_File_osRoots(fr_Env __env) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_File std_File_createTemp(fr_Env __env, sys_Str prefix, sys_Str suffix, std_File_null dir) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_File std_File_copyTo(fr_Env __env, std_File_ref __self, std_File to, std_Map_null options) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Str std_File_sep(fr_Env __env) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Str std_File_pathSep(fr_Env __env) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }



void std_LocalFile_init(fr_Env __env, std_LocalFile_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); }
std_FileStore_null std_LocalFile_store(fr_Env __env, std_LocalFile_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Bool std_LocalFile_exists(fr_Env __env, std_LocalFile_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Int std_LocalFile_size(fr_Env __env, std_LocalFile_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_TimePoint_null std_LocalFile_modified(fr_Env __env, std_LocalFile_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
void std_LocalFile_modified__1(fr_Env __env, std_LocalFile_ref __self, std_TimePoint_null it) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); }
sys_Str_null std_LocalFile_osPath(fr_Env __env, std_LocalFile_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_List std_LocalFile_list(fr_Env __env, std_LocalFile_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_File std_LocalFile_normalize(fr_Env __env, std_LocalFile_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_File std_LocalFile_create(fr_Env __env, std_LocalFile_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_File std_LocalFile_moveTo(fr_Env __env, std_LocalFile_ref __self, std_File to) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
void std_LocalFile_delete_(fr_Env __env, std_LocalFile_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); }
std_File std_LocalFile_deleteOnExit(fr_Env __env, std_LocalFile_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Bool std_LocalFile_isReadable(fr_Env __env, std_LocalFile_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Bool std_LocalFile_isWritable(fr_Env __env, std_LocalFile_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Bool std_LocalFile_isExecutable(fr_Env __env, std_LocalFile_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_InStream std_LocalFile_in(fr_Env __env, std_LocalFile_ref __self, sys_Int bufferSize) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_OutStream std_LocalFile_out(fr_Env __env, std_LocalFile_ref __self, sys_Bool append, sys_Int bufferSize) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
