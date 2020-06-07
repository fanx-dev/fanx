#include "std.h"


fr_Err std_Zip_open(fr_Env __env, std_Zip *__ret, std_File file) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Zip_read(fr_Env __env, std_Zip *__ret, std_InStream in) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Zip_write(fr_Env __env, std_Zip *__ret, std_OutStream out) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Zip_init(fr_Env __env, std_Zip_ref __self, std_Uri uri) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Zip_file(fr_Env __env, std_File_null *__ret, std_Zip_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Zip_contents(fr_Env __env, std_Map_null *__ret, std_Zip_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Zip_readNext(fr_Env __env, std_File_null *__ret, std_Zip_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Zip_writeNext(fr_Env __env, std_OutStream *__ret, std_Zip_ref __self, std_Uri path, std_TimePoint modifyTime) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Zip_finish(fr_Env __env, sys_Bool *__ret, std_Zip_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Zip_close(fr_Env __env, sys_Bool *__ret, std_Zip_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Zip_toStr(fr_Env __env, sys_Str *__ret, std_Zip_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Zip_gzipOutStream(fr_Env __env, std_OutStream *__ret, std_OutStream out) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Zip_gzipInStream(fr_Env __env, std_InStream *__ret, std_InStream in) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Zip_deflateOutStream(fr_Env __env, std_OutStream *__ret, std_OutStream out, std_Map_null opts) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Zip_deflateInStream(fr_Env __env, std_InStream *__ret, std_InStream in, std_Map_null opts) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
