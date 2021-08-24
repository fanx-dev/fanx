#include "fni_ext.h"
#include "pod_std_native.h"
#include <mutex>

#define MUTEX recursive_timed_mutex

static_assert(sizeof(std::MUTEX) <= (sizeof(fr_Int) * 20));
std::MUTEX* std_Lock_getRaw(fr_Env env, fr_Obj self) {
    static fr_Field f = fr_findField(env, fr_getObjType(env, self), "handle0");
    char* p = (char*)fr_getPtr(env, self);

    std::MUTEX* raw = (std::MUTEX*)(p + f->offset);
    return raw;
}

void std_Lock_init(fr_Env env, fr_Obj self) {
    std::MUTEX* m = std_Lock_getRaw(env, self);
    new (m) std::MUTEX();
    //printf("%p:init\n", m);
}
fr_Bool std_Lock_tryLock(fr_Env env, fr_Obj self, fr_Int nanoTime) {
    std::MUTEX* m = std_Lock_getRaw(env, self);
    //printf("%p:trylock\n", m);

    std::chrono::duration<int64_t, std::nano> ns(nanoTime);
    fr_Bool r = m->try_lock_for(ns);
    return r;
}
void std_Lock_lock(fr_Env env, fr_Obj self) {
    std::MUTEX* m = std_Lock_getRaw(env, self);
    //printf("%p:lock\n", m);
    m->lock();
    return;
}
void std_Lock_unlock(fr_Env env, fr_Obj self) {
    std::MUTEX* m = std_Lock_getRaw(env, self);
    //printf("%p:unlock\n", m);
    m->unlock();
    return;
}
void std_Lock_finalize(fr_Env env, fr_Obj self) {
    std::MUTEX* r = std_Lock_getRaw(env, self);
    //printf("%p:finalize\n", r);
    r->~MUTEX();
    return;
}