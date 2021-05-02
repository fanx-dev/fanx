#include "std.h"



std_Zip std_Zip_open(fr_Env __env, std_File file) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_Zip std_Zip_read(fr_Env __env, std_InStream in) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_Zip std_Zip_write(fr_Env __env, std_OutStream out) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
void std_Zip_init(fr_Env __env, std_Zip_ref __self, std_Uri uri) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); }
std_File_null std_Zip_file(fr_Env __env, std_Zip_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_Map_null std_Zip_contents(fr_Env __env, std_Zip_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_File_null std_Zip_readNext(fr_Env __env, std_Zip_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_OutStream std_Zip_writeNext(fr_Env __env, std_Zip_ref __self, std_Uri path, std_TimePoint modifyTime, std_Map_null opts) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Bool std_Zip_finish(fr_Env __env, std_Zip_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Bool std_Zip_close(fr_Env __env, std_Zip_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Str std_Zip_toStr(fr_Env __env, std_Zip_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_OutStream std_Zip_gzipOutStream(fr_Env __env, std_OutStream out) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_InStream std_Zip_gzipInStream(fr_Env __env, std_InStream in) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_OutStream std_Zip_deflateOutStream(fr_Env __env, std_OutStream out, std_Map_null opts) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_InStream std_Zip_deflateInStream(fr_Env __env, std_InStream in, std_Map_null opts) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }


