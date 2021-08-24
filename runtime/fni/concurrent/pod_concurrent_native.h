#include "fni_ext.h"
CF_BEGIN

void concurrent_ConditionVar_init(fr_Env env, fr_Obj self, fr_Obj lock);
fr_Bool concurrent_ConditionVar_doWait(fr_Env env, fr_Obj self, fr_Obj lock, fr_Int nanos);
void concurrent_ConditionVar_doSignal(fr_Env env, fr_Obj self, fr_Obj lock);
void concurrent_ConditionVar_doSignalAll(fr_Env env, fr_Obj self, fr_Obj lock);
void concurrent_ConditionVar_finalize(fr_Env env, fr_Obj self);
void concurrent_Thread__start(fr_Env env, fr_Obj self, fr_Obj name);
fr_Bool concurrent_Thread_detach(fr_Env env, fr_Obj self);
fr_Bool concurrent_Thread_join(fr_Env env, fr_Obj self);
fr_Int concurrent_Thread_id(fr_Env env, fr_Obj self);
fr_Int concurrent_Thread_curId(fr_Env env);
fr_Bool concurrent_Thread_sleepNanos(fr_Env env, fr_Int nanos);
void concurrent_Thread_finalize(fr_Env env, fr_Obj self);

CF_END
