#include "std.h"


fr_Err std_Env_cur(fr_Env __env, std_Env *__ret) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_make(fr_Env __env, std_Env_ref __self, std_Env parent) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_parent(fr_Env __env, std_Env_null *__ret, std_Env_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_platform(fr_Env __env, sys_Str *__ret, std_Env_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_os(fr_Env __env, sys_Str *__ret, std_Env_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_arch(fr_Env __env, sys_Str *__ret, std_Env_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_runtime(fr_Env __env, sys_Str *__ret, std_Env_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_javaVersion(fr_Env __env, sys_Int *__ret, std_Env_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_idHash(fr_Env __env, sys_Int *__ret, std_Env_ref __self, sys_Obj_null obj) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_args(fr_Env __env, sys_List *__ret, std_Env_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_vars(fr_Env __env, std_Map *__ret, std_Env_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_diagnostics(fr_Env __env, std_Map *__ret, std_Env_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_gc(fr_Env __env, std_Env_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_host(fr_Env __env, sys_Str *__ret, std_Env_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_user(fr_Env __env, sys_Str *__ret, std_Env_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_in(fr_Env __env, std_InStream *__ret, std_Env_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_out(fr_Env __env, std_OutStream *__ret, std_Env_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_err(fr_Env __env, std_OutStream *__ret, std_Env_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_promptPassword(fr_Env __env, sys_Str_null *__ret, std_Env_ref __self, sys_Str msg) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_homeDir(fr_Env __env, std_File *__ret, std_Env_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_workDir(fr_Env __env, std_File *__ret, std_Env_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_tempDir(fr_Env __env, std_File *__ret, std_Env_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_findFile(fr_Env __env, std_File_null *__ret, std_Env_ref __self, std_Uri uri, sys_Bool checked) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_findAllFiles(fr_Env __env, sys_List *__ret, std_Env_ref __self, std_Uri uri) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_findPodFile(fr_Env __env, std_File_null *__ret, std_Env_ref __self, sys_Str podName) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_findAllPodNames(fr_Env __env, sys_List *__ret, std_Env_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_compileScript(fr_Env __env, std_Type *__ret, std_Env_ref __self, std_File f, std_Map_null options) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_index(fr_Env __env, sys_List *__ret, std_Env_ref __self, sys_Str key) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_indexKeys(fr_Env __env, sys_List *__ret, std_Env_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_indexPodNames(fr_Env __env, sys_List *__ret, std_Env_ref __self, sys_Str key) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_props(fr_Env __env, std_Map *__ret, std_Env_ref __self, std_Pod pod, std_Uri uri, std_Duration maxAge) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_config(fr_Env __env, sys_Str_null *__ret, std_Env_ref __self, std_Pod pod, sys_Str key, sys_Str_null defV) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_locale(fr_Env __env, sys_Str_null *__ret, std_Env_ref __self, std_Pod pod, sys_Str key, sys_Str_null defV, std_Locale locale) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_exit(fr_Env __env, std_Env_ref __self, sys_Int status) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_addShutdownHook(fr_Env __env, std_Env_ref __self, sys_Func hook) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Env_removeShutdownHook(fr_Env __env, sys_Bool *__ret, std_Env_ref __self, sys_Func hook) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
