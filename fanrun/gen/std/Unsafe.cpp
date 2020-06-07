#include "std.h"



fr_Err std_Unsafe_make(fr_Env __env, std_Unsafe_ref __self, sys_Obj_null val) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Unsafe_val(fr_Env __env, sys_Obj_null *__ret, std_Unsafe_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Unsafe_get(fr_Env __env, sys_Obj_null *__ret, std_Unsafe_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }


fr_Err std_Lazy_make(fr_Env __env, std_Lazy_ref __self, sys_Func initial) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Lazy_get(fr_Env __env, sys_Obj_null *__ret, std_Lazy_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }


fr_Err std_SoftRef_make(fr_Env __env, std_SoftRef_ref __self, sys_Obj_null val) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_SoftRef_get(fr_Env __env, sys_Obj_null *__ret, std_SoftRef_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
