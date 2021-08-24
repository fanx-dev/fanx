#include "fni_ext.h"

void concurrent_ConditionVar_init_v(fr_Env env, void *param, void *ret);
void concurrent_ConditionVar_doWait_v(fr_Env env, void *param, void *ret);
void concurrent_ConditionVar_doSignal_v(fr_Env env, void *param, void *ret);
void concurrent_ConditionVar_doSignalAll_v(fr_Env env, void *param, void *ret);
void concurrent_ConditionVar_finalize_v(fr_Env env, void *param, void *ret);
void concurrent_Thread__start_v(fr_Env env, void *param, void *ret);
void concurrent_Thread_detach_v(fr_Env env, void *param, void *ret);
void concurrent_Thread_join_v(fr_Env env, void *param, void *ret);
void concurrent_Thread_id_v(fr_Env env, void *param, void *ret);
void concurrent_Thread_curId_v(fr_Env env, void *param, void *ret);
void concurrent_Thread_sleepNanos_v(fr_Env env, void *param, void *ret);
void concurrent_Thread_finalize_v(fr_Env env, void *param, void *ret);

void concurrent_register(fr_Fvm vm) {
    fr_registerMethod(vm, "concurrent_ConditionVar_init", concurrent_ConditionVar_init_v);
    fr_registerMethod(vm, "concurrent_ConditionVar_doWait", concurrent_ConditionVar_doWait_v);
    fr_registerMethod(vm, "concurrent_ConditionVar_doSignal", concurrent_ConditionVar_doSignal_v);
    fr_registerMethod(vm, "concurrent_ConditionVar_doSignalAll", concurrent_ConditionVar_doSignalAll_v);
    fr_registerMethod(vm, "concurrent_ConditionVar_finalize", concurrent_ConditionVar_finalize_v);
    fr_registerMethod(vm, "concurrent_Thread__start", concurrent_Thread__start_v);
    fr_registerMethod(vm, "concurrent_Thread_detach", concurrent_Thread_detach_v);
    fr_registerMethod(vm, "concurrent_Thread_join", concurrent_Thread_join_v);
    fr_registerMethod(vm, "concurrent_Thread_id", concurrent_Thread_id_v);
    fr_registerMethod(vm, "concurrent_Thread_curId", concurrent_Thread_curId_v);
    fr_registerMethod(vm, "concurrent_Thread_sleepNanos", concurrent_Thread_sleepNanos_v);
    fr_registerMethod(vm, "concurrent_Thread_finalize", concurrent_Thread_finalize_v);
}
