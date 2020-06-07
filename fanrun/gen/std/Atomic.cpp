
#include "std.h"

fr_Err std_AtomicInt_make(fr_Env __env, std_AtomicInt_ref __self, sys_Int val) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicInt_val(fr_Env __env, sys_Int *__ret, std_AtomicInt_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicInt_val__1(fr_Env __env, std_AtomicInt_ref __self, sys_Int it) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicInt_getAndSet(fr_Env __env, sys_Int *__ret, std_AtomicInt_ref __self, sys_Int val) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicInt_compareAndSet(fr_Env __env, sys_Bool *__ret, std_AtomicInt_ref __self, sys_Int expect, sys_Int update) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicInt_getAndIncrement(fr_Env __env, sys_Int *__ret, std_AtomicInt_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicInt_getAndDecrement(fr_Env __env, sys_Int *__ret, std_AtomicInt_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicInt_getAndAdd(fr_Env __env, sys_Int *__ret, std_AtomicInt_ref __self, sys_Int delta) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicInt_incrementAndGet(fr_Env __env, sys_Int *__ret, std_AtomicInt_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicInt_decrementAndGet(fr_Env __env, sys_Int *__ret, std_AtomicInt_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicInt_addAndGet(fr_Env __env, sys_Int *__ret, std_AtomicInt_ref __self, sys_Int delta) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicInt_increment(fr_Env __env, std_AtomicInt_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicInt_decrement(fr_Env __env, std_AtomicInt_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicInt_add(fr_Env __env, std_AtomicInt_ref __self, sys_Int delta) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicInt_toStr(fr_Env __env, sys_Str *__ret, std_AtomicInt_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }

fr_Err std_AtomicRef_make(fr_Env __env, std_AtomicRef_ref __self, sys_Obj_null val) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicRef_val(fr_Env __env, sys_Obj_null *__ret, std_AtomicRef_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicRef_val__1(fr_Env __env, std_AtomicRef_ref __self, sys_Obj_null it) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicRef_getAndSet(fr_Env __env, sys_Obj_null *__ret, std_AtomicRef_ref __self, sys_Obj_null val) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicRef_compareAndSet(fr_Env __env, sys_Bool *__ret, std_AtomicRef_ref __self, sys_Obj_null expect, sys_Obj_null update) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicRef_toStr(fr_Env __env, sys_Str *__ret, std_AtomicRef_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }


fr_Err std_AtomicBool_make(fr_Env __env, std_AtomicBool_ref __self, sys_Bool val) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicBool_val(fr_Env __env, sys_Bool *__ret, std_AtomicBool_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicBool_val__1(fr_Env __env, std_AtomicBool_ref __self, sys_Bool it) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicBool_getAndSet(fr_Env __env, sys_Bool *__ret, std_AtomicBool_ref __self, sys_Bool val) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicBool_compareAndSet(fr_Env __env, sys_Bool *__ret, std_AtomicBool_ref __self, sys_Bool expect, sys_Bool update) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_AtomicBool_toStr(fr_Env __env, sys_Str *__ret, std_AtomicBool_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }


fr_Err std_Lock_tryLock(fr_Env __env, sys_Bool *__ret, std_Lock_ref __self, sys_Int nanoTime) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Lock_lock(fr_Env __env, std_Lock_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Lock_unlock(fr_Env __env, std_Lock_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Lock_sync(fr_Env __env, sys_Obj_null *__ret, std_Lock_ref __self, sys_Func f) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }

