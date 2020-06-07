#include "std.h"

fr_Err std_NativeCharset_fromStr(fr_Env __env, std_Charset_null *__ret, sys_Str name) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_NativeCharset_encode(fr_Env __env, sys_Int *__ret, std_NativeCharset_ref __self, sys_Int ch, std_OutStream out) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_NativeCharset_encodeArray(fr_Env __env, sys_Int *__ret, std_NativeCharset_ref __self, sys_Int ch, sys_Array out, sys_Int offset) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_NativeCharset_decode(fr_Env __env, sys_Int *__ret, std_NativeCharset_ref __self, std_InStream in) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }


