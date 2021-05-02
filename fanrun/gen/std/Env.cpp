#include "std.h"


std_Env std_Env_cur(fr_Env __env) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
void std_Env_make(fr_Env __env, std_Env_ref __self, std_Env parent) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); }
std_Env_null std_Env_parent(fr_Env __env, std_Env_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Str std_Env_platform(fr_Env __env, std_Env_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Str std_Env_os(fr_Env __env, std_Env_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Str std_Env_arch(fr_Env __env, std_Env_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Str std_Env_runtime(fr_Env __env, std_Env_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Bool std_Env_isJs(fr_Env __env, std_Env_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Int std_Env_javaVersion(fr_Env __env, std_Env_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Int std_Env_idHash(fr_Env __env, std_Env_ref __self, sys_Obj_null obj) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_List std_Env_args(fr_Env __env, std_Env_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_Map std_Env_vars(fr_Env __env, std_Env_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_Map std_Env_diagnostics(fr_Env __env, std_Env_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
void std_Env_gc(fr_Env __env, std_Env_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); }
sys_Str std_Env_host(fr_Env __env, std_Env_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Str std_Env_user(fr_Env __env, std_Env_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_InStream std_Env_in(fr_Env __env, std_Env_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_OutStream std_Env_out(fr_Env __env, std_Env_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_OutStream std_Env_err(fr_Env __env, std_Env_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Str_null std_Env_promptPassword(fr_Env __env, std_Env_ref __self, sys_Str msg) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_File std_Env_homeDir(fr_Env __env, std_Env_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_File std_Env_workDir(fr_Env __env, std_Env_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_File std_Env_tempDir(fr_Env __env, std_Env_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_File_null std_Env_findFile(fr_Env __env, std_Env_ref __self, std_Uri uri, sys_Bool checked) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_List std_Env_findAllFiles(fr_Env __env, std_Env_ref __self, std_Uri uri) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_File_null std_Env_findPodFile(fr_Env __env, std_Env_ref __self, sys_Str podName) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_List std_Env_findAllPodNames(fr_Env __env, std_Env_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_Type std_Env_compileScript(fr_Env __env, std_Env_ref __self, std_File f, std_Map_null options) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_List std_Env_index(fr_Env __env, std_Env_ref __self, sys_Str key) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_List std_Env_indexKeys(fr_Env __env, std_Env_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_List std_Env_indexPodNames(fr_Env __env, std_Env_ref __self, sys_Str key) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_Map std_Env_props(fr_Env __env, std_Env_ref __self, std_Pod pod, std_Uri uri, std_Duration maxAge) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Str_null std_Env_config(fr_Env __env, std_Env_ref __self, std_Pod pod, sys_Str key, sys_Str_null defV) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Str_null std_Env_locale(fr_Env __env, std_Env_ref __self, std_Pod pod, sys_Str key, sys_Str_null defV, std_Locale locale) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
void std_Env_exit(fr_Env __env, std_Env_ref __self, sys_Int status) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); }
void std_Env_addShutdownHook(fr_Env __env, std_Env_ref __self, sys_Func hook) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); }
sys_Bool std_Env_removeShutdownHook(fr_Env __env, std_Env_ref __self, sys_Func hook) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
