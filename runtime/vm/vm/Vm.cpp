//
//  FVM.cpp
//  vm
//
//  Created by yangjiandong on 15/9/27.
//  Copyright (c) 2015, yangjiandong. All rights reserved.
//

#include "Vm.h"
#include "Env.h"
#include <assert.h>
#include <atomic>
#include "gc/Gc.h"

#ifdef FR_LLVM
    #include "SimpleLLVMJIT.hpp"
#endif

Fvm *fvm = NULL;

Fvm::Fvm(PodManager *podManager)
    : podManager(podManager), executeEngine(nullptr)
{
    gc = new Gc(this);
    //gc->gcSupport = this;
    LinkedList_make(&globalRefList);
#ifdef FR_LLVM
    executeEngine = new SimpleLLVMJIT();
#endif
    fvm = this;
    podManager->vm = this;
}

Fvm::~Fvm() {
    fvm = NULL;
    LinkedList_release(&globalRefList);
    delete executeEngine;
}

Fvm* Fvm::getCur() {
    return fvm;
}

void Fvm::start() {

}
void Fvm::stop() {
}

Env *Fvm::getEnv() {
    std::lock_guard<std::recursive_mutex> lock_guard(lock);
    std::thread::id tid = std::this_thread::get_id();
    auto found = threads.find(tid);
    Env *env;
    if (found != threads.end()) {
        env = found->second;
    } else {
        env = new Env(this);
        threads[tid] = env;
    }
    return env;
}
void Fvm::releaseEnv(Env *env) {
    std::lock_guard<std::recursive_mutex> lock_guard(lock);
    std::thread::id tid = std::this_thread::get_id();
    threads.erase(tid);
    delete env;
}

void Fvm::registerMethod(const char *name, fr_NativeFunc func) {
    std::lock_guard<std::recursive_mutex> lock_guard(lock);
    podManager->registerMethod(name, func);
}

void Fvm::onStartGc() {
    
}

void Fvm::printObj(GcObj *obj) {
    FType* type = (FType*)gc_getType(obj);
    printf("%p(%s)", obj, type->c_mangledName.c_str());
}

int Fvm::allocSize(GcObj* gcobj) {
    Env* env = nullptr;
    FObj *fobj = fr_fromGcObj(gcobj);
    FType *ftype = fr_getFType((fr_Env)env, fobj);
    FType *objArray = podManager->findType(env, "sys", "Array");
    if (ftype == objArray) {
        fr_Array* array = (fr_Array*)fobj;
        return sizeof(array) + (array->elemSize * array->size) + sizeof(struct GcObj_);
    }
    return ftype->c_allocSize + sizeof(struct GcObj_);
}

void Fvm::visitChildren(Collector *gc, GcObj* gcobj) {
    Env *env = nullptr;
    FObj *fobj = fr_fromGcObj(gcobj);
    FType *ftype = fr_getFType((fr_Env)env, fobj);
    FType *objArray = podManager->findType(env, "sys", "Array");
    FType* objAtomicRef = podManager->findType(env, "std", "AtomicRef");
    if (ftype == objArray) {
        fr_Array *array = (fr_Array *)fobj;
        if (array->valueType == fr_vtObj) {
            for (size_t i=0; i<array->size; ++i) {
                FObj * elem = ((FObj**)(array->data))[i];
                //list->push_back((FObj*)obj);
                gc->onVisit(fr_toGcObj((FObj*)elem));
            }
        }
        return;
    }

    if (ftype == objAtomicRef) {
        FObj** valptr = (FObj**)fobj;
        FObj* val = *valptr;
        if (val) {
            GcObj* gp = fr_toGcObj(val);
            //list->push_back(gp);
            gc->onVisit(gp);
        }
        return;
    }
    
    for (int i=0; i<ftype->fields.size(); ++i) {
        FField &f = ftype->fields[i];
        if ((f.flags & FFlags::Storage) == 0) {
            continue;
        }
        if (f.flags & FFlags::Static) {
            //pass;
        } else {
            fr_Value *val = podManager->getInstanceFieldValue(fobj, &f);
            fr_ValueType vtype = podManager->getValueType(env, ftype->c_pod, f.type);
            if (vtype == fr_vtObj) {
                //list->push_back((FObj*)val->o);
                gc->onVisit(fr_toGcObj((FObj*)(val->o)));
            }
        }
    }
}
void Fvm::walkRoot(Collector *gc) {
    //global ref
    LinkedListElem *it = LinkedList_first(&globalRefList);
    LinkedListElem *end = LinkedList_end(&globalRefList);
    while (it != end) {
        gc->onVisit(fr_toGcObj(reinterpret_cast<FObj*>(it->data)));
        it = it->next;
    }
    
    //static field
    for (auto it = staticFieldRef.begin(); it != staticFieldRef.end(); ++it) {
        gc->onVisit(fr_toGcObj(*reinterpret_cast<FObj **>(*it)));
    }
    
    //local
    for (auto it = threads.begin(); it != threads.end(); ++it) {
        Env *env = it->second;
        env->walkLocalRoot(gc);
    }
}
void Fvm::finalizeObj(GcObj* obj) {
    Env *env = getEnv();
    
    fr_TagValue val;
    val.type = fr_vtObj;
    val.any.o = fr_fromGcObj(obj);
    env->push(&val);
    
    FMethod *m = env->findMethod("sys", "Obj", "finalize");
    env->callVirtual(m, 0);
    //env->callVirtualMethod("finalize", 0);
}
void Fvm::puaseWorld(bool bloking) {
    while (true) {
        bool isAllStoped = true;
        lock.lock();
        std::thread::id tid = std::this_thread::get_id();
        for (auto it = threads.begin(); it != threads.end(); ++it) {
            if (it->first == tid) continue;
            Env* env = it->second;
            if (!env->isStoped.load()) {
                isAllStoped = false;
                //std::atomic_thread_fence(std::memory_order_acquire);
            }
        }
        lock.unlock();
        if (isAllStoped) return;
        System_sleep(5);
    }
}

void Fvm::resumeWorld() {
//    std::lock_guard<std::recursive_mutex> lock_guard(lock);
//    for (auto it = threads.begin(); it != threads.end(); ++it) {
//        Env *env = it->second;
//        env->needStop = false;
//    }
//    std::atomic_thread_fence(std::memory_order_release);
}

fr_Obj Fvm::newGlobalRef(FObj * obj) {
    std::lock_guard<std::recursive_mutex> lock_guard(lock);
    LinkedListElem *elem = LinkedList_newElem(&globalRefList, 0);
    elem->data = obj;
    LinkedList_add(&globalRefList, elem);
    fr_Obj objRef = (fr_Obj)(&elem->data);
    return objRef;
}

void Fvm::deleteGlobalRef(fr_Obj objRef) {
    std::lock_guard<std::recursive_mutex> lock_guard(lock);
    LinkedListElem *elem =  reinterpret_cast<LinkedListElem *>((char*)(objRef) - offsetof(LinkedListElem, data));
    elem->data = NULL;
    LinkedList_remove(&globalRefList, elem);
}

void Fvm::addStaticRef(fr_Obj obj) {
    std::lock_guard<std::recursive_mutex> lock_guard(lock);
    staticFieldRef.push_back(obj);
}
