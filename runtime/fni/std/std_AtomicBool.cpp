#include "fni_ext.h"
#include "pod_std_native.h"
#include <atomic>
#include <new>

#define TYPE bool
static_assert(sizeof(std::atomic<TYPE>) <= (sizeof(fr_Int) * 2));
static std::atomic<TYPE>* std_AtomicBool_getRaw(fr_Env env, fr_Obj self) {
    static fr_Field f = fr_findField(env, fr_getObjType(env, self), "handle0");
    char* p = (char*)fr_getPtr(env, self);

    std::atomic<TYPE>* raw = (std::atomic<TYPE>*)(p + f->offset);
    return raw;
}

void std_AtomicBool_init(fr_Env env, fr_Obj self, fr_Bool val) {
    std::atomic<TYPE>* r = std_AtomicBool_getRaw(env, self);
    new (r) std::atomic<TYPE>(val);
    return;
}
fr_Bool std_AtomicBool_val(fr_Env env, fr_Obj self) {
    std::atomic<TYPE>* r = std_AtomicBool_getRaw(env, self);
    fr_Bool b = r->load();
    return b;
}
void std_AtomicBool_val__1(fr_Env env, fr_Obj self, fr_Bool it) {
    std::atomic<TYPE>* r = std_AtomicBool_getRaw(env, self);
    r->store(it);
    return;
}
fr_Bool std_AtomicBool_getAndSet(fr_Env env, fr_Obj self, fr_Bool val) {
    std::atomic<TYPE>* r = std_AtomicBool_getRaw(env, self);
    return r->exchange(val);
}
fr_Bool std_AtomicBool_compareAndSet(fr_Env env, fr_Obj self, fr_Bool expect, fr_Bool update) {
    std::atomic<TYPE>* r = std_AtomicBool_getRaw(env, self);
    return r->compare_exchange_weak(expect, update);
}
void std_AtomicBool_finalize(fr_Env env, fr_Obj self) {
    std::atomic<TYPE>* r = std_AtomicBool_getRaw(env, self);
    r->~atomic<TYPE>();
}
