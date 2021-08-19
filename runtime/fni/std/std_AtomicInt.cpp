#include "fni_ext.h"
#include "pod_std_native.h"
#include <atomic>

#define TYPE int64_t
static_assert(sizeof(std::atomic<TYPE>) <= (sizeof(fr_Int) * 2));
static std::atomic<TYPE>* getRaw(fr_Env env, fr_Obj self) {
    static fr_Field f = fr_findField(env, fr_getObjType(env, self), "handle0");
    char* p = (char*)fr_getPtr(env, self);

    std::atomic<TYPE>* raw = (std::atomic<TYPE>*)(p + f->offset);
    return raw;
}

void std_AtomicInt_init(fr_Env env, fr_Obj self, fr_Int val) {
    std::atomic<TYPE> *r = getRaw(env, self);
    new (r) std::atomic<TYPE>(val);
    return;
}
fr_Int std_AtomicInt_val(fr_Env env, fr_Obj self) {
    std::atomic<TYPE>* r = getRaw(env, self);
    fr_Int t = r->load();
    return t;
}
void std_AtomicInt_val__1(fr_Env env, fr_Obj self, fr_Int it) {
    std::atomic<TYPE>* r = getRaw(env, self);
    r->store(it);
    return;
}
fr_Int std_AtomicInt_getAndSet(fr_Env env, fr_Obj self, fr_Int val) {
    std::atomic<TYPE>* r = getRaw(env, self);
    fr_Int t = r->exchange(val);
    return t;
}
fr_Bool std_AtomicInt_compareAndSet(fr_Env env, fr_Obj self, fr_Int expect, fr_Int update) {
    std::atomic<TYPE>* r = getRaw(env, self);
    return r->compare_exchange_weak(expect, update);
}

fr_Int std_AtomicInt_getAndAdd(fr_Env env, fr_Obj self, fr_Int delta) {
    std::atomic<TYPE>* r = getRaw(env, self);
    fr_Int t = r->fetch_add(delta);
    return t;
}

fr_Int std_AtomicInt_addAndGet(fr_Env env, fr_Obj self, fr_Int delta) {
    std::atomic<TYPE>* r = getRaw(env, self);
    fr_Int t = r->fetch_add(delta);
    return t+delta;
}

void std_AtomicInt_finalize(fr_Env env, fr_Obj self) {
    std::atomic<TYPE>* r = getRaw(env, self);
    r->~atomic<TYPE>();
    return;
}
