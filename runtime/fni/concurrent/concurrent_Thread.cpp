#include "fni_ext.h"
#include "pod_concurrent_native.h"
#include <thread>

static std::thread* concurrent_Thread_getRaw(fr_Env env, fr_Obj self) {
    static fr_Field f = fr_findField(env, fr_getObjType(env, self), "handle");
    fr_Value val;
    fr_getInstanceField(env, self, f, &val);
    std::thread* raw = (std::thread*)(val.i);
    return raw;
}

static void concurrent_Thread_setRaw(fr_Env env, fr_Obj self, std::thread* r) {
    static fr_Field f = fr_findField(env, fr_getObjType(env, self), "handle");
    fr_Value val;
    val.i = (fr_Int)r;
    fr_setInstanceField(env, self, f, &val);
}

static void thread_run(fr_Obj self) {
    fr_Env env = fr_getEnv(NULL);
    static fr_Method f = fr_findMethod(env, fr_getObjType(env, self), "run");
    fr_callMethod(env, f, 1, self);
    fr_releaseEnv(env);
}

void concurrent_Thread__start(fr_Env env, fr_Obj self, fr_Obj name) {
    std::thread* thd = new std::thread(thread_run, self);
    concurrent_Thread_setRaw(env, self, thd);
    return;
}
fr_Bool concurrent_Thread_detach(fr_Env env, fr_Obj self) {
    std::thread* thd = concurrent_Thread_getRaw(env, self);
    thd->detach();
    return true;
}
fr_Bool concurrent_Thread_join(fr_Env env, fr_Obj self) {
    std::thread* thd = concurrent_Thread_getRaw(env, self);
    thd->join();
    return true;
}

static fr_Int threadIdToInt(std::thread::id d) {
    static_assert(sizeof(std::thread::id) <= sizeof(fr_Int));
    fr_Int fid = 0;
    memcpy(&fid, &d, sizeof(std::thread::id));
    return fid;
}

fr_Int concurrent_Thread_id(fr_Env env, fr_Obj self) {
    std::thread* thd = concurrent_Thread_getRaw(env, self);
    std::thread::id d = thd->get_id();
    return threadIdToInt(d);
}
fr_Int concurrent_Thread_curId(fr_Env env) {
    std::thread::id this_id = std::this_thread::get_id();
    return threadIdToInt(this_id);
}
fr_Bool concurrent_Thread_sleepNanos(fr_Env env, fr_Int nanos) {
    std::chrono::duration<int64_t, std::nano> ns(nanos);

    fr_allowGc(env);
    std::this_thread::sleep_for(ns);
    fr_endAllowGc(env);
    return true;
}
void concurrent_Thread_finalize(fr_Env env, fr_Obj self) {
    std::thread* thd = concurrent_Thread_getRaw(env, self);
    thd->detach();
    delete thd;
    concurrent_Thread_setRaw(env, self, NULL);
}
