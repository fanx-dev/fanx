#include "std.h"



std_Charset_null std_NativeCharset_fromStr(fr_Env __env, sys_Str name) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
sys_Int std_NativeCharset_encode(fr_Env __env, std_NativeCharset_ref __self, sys_Int ch, std_OutStream out) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
sys_Int std_NativeCharset_encodeArray(fr_Env __env, std_NativeCharset_ref __self, sys_Int ch, sys_Array out, sys_Int offset) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
sys_Int std_NativeCharset_decode(fr_Env __env, std_NativeCharset_ref __self, std_InStream in) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
