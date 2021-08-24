#include "fni_ext.h"
#include "pod_concurrent_native.h"
#include <condition_variable>

#define MUTEX recursive_timed_mutex
std::MUTEX* std_Lock_getRaw(fr_Env env, fr_Obj self);

static std::condition_variable_any* getRaw(fr_Env env, fr_Obj self) {
    static fr_Field f = fr_findField(env, fr_getObjType(env, self), "handle");
    fr_Value val;
    fr_getInstanceField(env, self, f, &val);
    std::condition_variable_any* raw = (std::condition_variable_any*)(val.i);
    return raw;
}

static void setRaw(fr_Env env, fr_Obj self, std::condition_variable_any* r) {
    static fr_Field f = fr_findField(env, fr_getObjType(env, self), "handle");
    fr_Value val;
    val.i = (fr_Int)r;
    fr_setInstanceField(env, self, f, &val);
}

void concurrent_ConditionVar_init(fr_Env env, fr_Obj self, fr_Obj lock) {
    std::condition_variable_any *condvar = new std::condition_variable_any();
    setRaw(env, self, condvar);
    return;
}
fr_Bool concurrent_ConditionVar_doWait(fr_Env env, fr_Obj self, fr_Obj lock, fr_Int nanos) {
    std::chrono::duration<int64_t, std::nano> ns(nanos);
    std::condition_variable_any* condvar = getRaw(env, self);

    std::MUTEX *mut = std_Lock_getRaw(env, lock);

    fr_allowGc(env);
    condvar->wait_for(*mut, ns);
    fr_endAllowGc(env);
    return true;
}
void concurrent_ConditionVar_doSignal(fr_Env env, fr_Obj self, fr_Obj lock) {
    std::condition_variable_any* condvar = getRaw(env, self);
    condvar->notify_one();
    return;
}
void concurrent_ConditionVar_doSignalAll(fr_Env env, fr_Obj self, fr_Obj lock) {
    std::condition_variable_any* condvar = getRaw(env, self);
    condvar->notify_all();
    return;
}
void concurrent_ConditionVar_finalize(fr_Env env, fr_Obj self) {
    std::condition_variable_any* condvar = getRaw(env, self);
    delete condvar;
    setRaw(env, self, NULL);
    return;
}
