#include "std.h"





void std_Lazy_make(fr_Env __env, std_Lazy_ref __self, sys_Func initial) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); }
sys_Obj_null std_Lazy_get(fr_Env __env, std_Lazy_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }


sys_Bool std_Lock_tryLock(fr_Env __env, std_Lock_ref __self, sys_Int nanoTime) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
void std_Lock_lock(fr_Env __env, std_Lock_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); }
void std_Lock_unlock(fr_Env __env, std_Lock_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); }
sys_Obj_null std_Lock_sync(fr_Env __env, std_Lock_ref __self, sys_Func f) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }


void std_SoftRef_make(fr_Env __env, std_SoftRef_ref __self, sys_Obj_null val) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); }
sys_Obj_null std_SoftRef_get(fr_Env __env, std_SoftRef_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }


void std_Unsafe_make(fr_Env __env, std_Unsafe_ref __self, sys_Obj_null val) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); }
sys_Obj_null std_Unsafe_val(fr_Env __env, std_Unsafe_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Obj_null std_Unsafe_get(fr_Env __env, std_Unsafe_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }

