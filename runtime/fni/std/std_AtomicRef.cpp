#include "fni_ext.h"
#include "pod_std_native.h"
#include <atomic>
#include <new>

#define TYPE void*
static_assert(sizeof(std::atomic<TYPE>) <= (sizeof(fr_Int) * 2));

void std_AtomicRef_finalize(fr_Env env, fr_Obj self);

static std::atomic<TYPE>* std_AtomicRef_getRaw(fr_Env env, fr_Obj self) {
    static fr_Field f = fr_findField(env, fr_getObjType(env, self), "handle0");
    char* p = (char*)fr_getPtr(env, self);

    std::atomic<TYPE>* raw = (std::atomic<TYPE>*)(p + f->offset);
    return raw;
}

void std_AtomicRef_init(fr_Env env, fr_Obj self, fr_Obj val) {
    std::atomic<TYPE>* r = std_AtomicRef_getRaw(env, self);
    void *ref = fr_getPtr(env, val);
    new (r) std::atomic<TYPE>(ref);
    
    fr_Type type = fr_getObjType(env, self);
    fr_registerDestructor(env, type, std_AtomicRef_finalize);
    return;
}
fr_Obj std_AtomicRef_val(fr_Env env, fr_Obj self) {
    std::atomic<TYPE>* r = std_AtomicRef_getRaw(env, self);
    void* obj = r->load();
    return fr_toHandle(env, (FObj*)obj);
}
void std_AtomicRef_val__1(fr_Env env, fr_Obj self, fr_Obj it) {
    std::atomic<TYPE>* r = std_AtomicRef_getRaw(env, self);
    void* ref = fr_getPtr(env, it);
    r->store(it);
    return;
}
fr_Obj std_AtomicRef_getAndSet(fr_Env env, fr_Obj self, fr_Obj val) {
    std::atomic<TYPE>* r = std_AtomicRef_getRaw(env, self);
    void* ref = fr_getPtr(env, val);
    void* old = r->exchange(ref);
    return fr_toHandle(env, (FObj*)old);
}
fr_Bool std_AtomicRef_compareAndSet(fr_Env env, fr_Obj self, fr_Obj expect, fr_Obj update) {
    std::atomic<TYPE>* r = std_AtomicRef_getRaw(env, self);
    void* expectP = fr_getPtr(env, expect);
    void* updateP = fr_getPtr(env, update);
    fr_Bool t = r->compare_exchange_weak(expectP, updateP);
    return t;
}
void std_AtomicRef_finalize(fr_Env env, fr_Obj self) {
    std::atomic<TYPE>* r = std_AtomicRef_getRaw(env, self);
    r->~atomic<TYPE>();
    return;
}
