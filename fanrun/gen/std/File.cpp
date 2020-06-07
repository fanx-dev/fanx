#include "std.h"


fr_Err std_File_make(fr_Env __env, std_File *__ret, std_Uri uri, sys_Bool checkSlash) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_File_os(fr_Env __env, std_File *__ret, sys_Str osPath) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_File_osRoots(fr_Env __env, sys_List *__ret) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_File_createTemp(fr_Env __env, std_File *__ret, sys_Str prefix, sys_Str suffix, std_File_null dir) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_File_copyTo(fr_Env __env, std_File *__ret, std_File_ref __self, std_File to, std_Map_null options) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_File_sep(fr_Env __env, sys_Str *__ret) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_File_pathSep(fr_Env __env, sys_Str *__ret) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }





fr_Err std_LocalFile_init(fr_Env __env, std_LocalFile_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_LocalFile_store(fr_Env __env, std_FileStore_null *__ret, std_LocalFile_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_LocalFile_exists(fr_Env __env, sys_Bool *__ret, std_LocalFile_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_LocalFile_size(fr_Env __env, sys_Int *__ret, std_LocalFile_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_LocalFile_modified(fr_Env __env, std_TimePoint_null *__ret, std_LocalFile_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_LocalFile_modified__1(fr_Env __env, std_LocalFile_ref __self, std_TimePoint_null it) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_LocalFile_osPath(fr_Env __env, sys_Str_null *__ret, std_LocalFile_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_LocalFile_list(fr_Env __env, sys_List *__ret, std_LocalFile_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_LocalFile_normalize(fr_Env __env, std_File *__ret, std_LocalFile_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_LocalFile_create(fr_Env __env, std_File *__ret, std_LocalFile_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_LocalFile_moveTo(fr_Env __env, std_File *__ret, std_LocalFile_ref __self, std_File to) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_LocalFile_delete_(fr_Env __env, std_LocalFile_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_LocalFile_deleteOnExit(fr_Env __env, std_File *__ret, std_LocalFile_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_LocalFile_in(fr_Env __env, std_InStream *__ret, std_LocalFile_ref __self, sys_Int bufferSize) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_LocalFile_out(fr_Env __env, std_OutStream *__ret, std_LocalFile_ref __self, sys_Bool append, sys_Int bufferSize) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
