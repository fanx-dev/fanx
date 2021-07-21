//
//  Vm.cpp
//  vm
//
//  Created by yangjiandong on 2017/12/31.
//  Copyright © 2017年 yangjiandong. All rights reserved.
//

#include "Vm.hpp"
#include "Env.hpp"
#include "util/system.h"

Vm::Vm() {
    gc = new Gc(this);
    //gc->gcSupport = this;
}

Vm::~Vm() {
}

void Vm::start() {
    
}
void Vm::stop() {
}

Env *Vm::getEnv() {
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

void Vm::releaseEnv(Env *env) {
    std::lock_guard<std::recursive_mutex> lock_guard(lock);
    
    std::thread::id tid = std::this_thread::get_id();
    threads.erase(tid);
    delete env;
}


#ifdef  __cplusplus
extern  "C" {
#endif
    extern fr_Type sys_Array_class__;
#ifdef  __cplusplus
}
#endif

void Vm::visitChildren(Collector *gc, GcObj *gcobj) {
    FObj* obj = fr_fromGcObj(gcobj);
    fr_Type type = (fr_Type)gc_getType(gcobj);
    
    if (type == sys_Array_class__) {
        fr_Array *array = (fr_Array*)obj;
        if (array->valueType == fr_vtObj) {
            for (int i=0; i<array->size; ++i) {
                FObj* elem = ((FObj**)(array->data))[i];
                if (elem) {
                    GcObj *gp = fr_toGcObj(elem);
                    //list->push_back(gp);
                    gc->onVisit(gp);
                }
            }
        }
        return;
    }
    
    for (int i=0; i<type->fieldCount; ++i) {
        fr_Field_ &f = type->fieldList[i];
        if (!f.isStatic && !f.isValType) {
            fr_Obj* objAddress = (fr_Obj*)(((char*)(obj)) + f.offset);
            if (*objAddress == NULL) continue;
            GcObj *gp = fr_toGcObj(*objAddress);
            //list->push_back(gp);
            gc->onVisit(gp);
        }
    }
}

void Vm::walkRoot(Collector *gc) {
    //static field
    for (auto it = staticFieldRef.begin(); it != staticFieldRef.end(); ++it) {
        fr_Obj *obj = *it;
        if (*obj == NULL) continue;
        GcObj *gobj = fr_toGcObj(*obj);
        //gc->onRoot(gobj);
        gc->onVisit(gobj);
    }
    
    //local
    std::thread::id tid = std::this_thread::get_id();
    for (auto it = threads.begin(); it != threads.end(); ++it) {
        if (it->first == tid) {
            //finalizeObj thread
            continue;
        }
        Env *env = it->second;
        env->walkLocalRoot(gc);
    }
}

//void Vm::walkDirtyList(Gc *gc) {
//    //local
//    for (auto it = threads.begin(); it != threads.end(); ++it) {
//        Env *env = it->second;
//        env->walkDirtyList(gc);
//    }
//}

extern "C" { void fr_finalizeObj(fr_Env __env, fr_Obj _obj); }
void Vm::finalizeObj(GcObj *gcobj) {
    fr_Obj obj = fr_fromGcObj(gcobj);
    //fr_Class type = (fr_Class)gc_getType(gcobj);
    //printf("release %s %p\n", type->name, obj);
    fr_finalizeObj(getEnv(), obj);
}

void Vm::onStartGc() {
//    void *statckVar = 0;
//    //set statckEnd address
//    std::thread::id tid = std::this_thread::get_id();
//    for (auto it = threads.begin(); it != threads.end(); ++it) {
//        Env *env = it->second;
//        //is current thread
//        if (it->first == tid) {
//            env->statckEnd = &statckVar;
//            continue;
//        }
//    }
}

void Vm::puaseWorld(bool bloking) {
    std::lock_guard<std::recursive_mutex> lock_guard(lock);
    void *statckVar = 0;
    
//    for (auto it = threads.begin(); it != threads.end(); ++it) {
//        Env *env = it->second;
//        env->needStop = true;
//    }
    
    if (bloking) {
        std::thread::id tid = std::this_thread::get_id();
        for (auto it = threads.begin(); it != threads.end(); ++it) {
            Env *env = it->second;
            //is current thread
            if (it->first == tid) {
                env->statckEnd = &statckVar;
                continue;
            }
            
            while (!env->isStoped) {
                System_sleep(1);
                std::atomic_thread_fence(std::memory_order_acquire);
            }
        }
    }
}

void Vm::resumeWorld() {
//    std::lock_guard<std::recursive_mutex> lock_guard(lock);
//    for (auto it = threads.begin(); it != threads.end(); ++it) {
//        Env *env = it->second;
//        env->needStop = false;
//    }
}
void Vm::printObj(GcObj *gcobj) {
    fr_Obj obj = fr_fromGcObj(gcobj);
    fr_Type type = (fr_Type)gc_getType(gcobj);
    printf("%s %p", type->name, obj);
}

int Vm::allocSize(void *type) {
    fr_Type t = (fr_Type)type;
    return t->allocSize;
}

void Vm::addStaticRef(fr_Obj *objAddress) {
    std::lock_guard<std::recursive_mutex> lock_guard(lock);
    staticFieldRef.push_back(objAddress);
}

void Vm::registerClass(const char *pod, const char *clz, fr_Type type) {
    std::lock_guard<std::recursive_mutex> lock_guard(lock);
    std::string podName = pod;
    std::string clzName = clz;
    typeDb[podName][clzName] = type;
    //classSet.insert(type);
    for (int i=0; i<type->fieldCount; ++i) {
        fr_Field_ &f = type->fieldList[i];
        if (f.isStatic && !f.isValType) {
            fr_Obj* objAddress = (fr_Obj*)(f.pointer);
            addStaticRef(objAddress);
        }
    }
}
void Vm::registerPod(struct fr_Pod_ *pod) {
    std::lock_guard<std::recursive_mutex> lock_guard(lock);
    pods[pod->name] = pod;
}

fr_Type Vm::findClass(const char *pod, const char *clz) {
    std::lock_guard<std::recursive_mutex> lock_guard(lock);
    auto itr = typeDb.find(pod);
    if (itr == typeDb.end()) return NULL;
    auto type = itr->second.find(clz);
    if (type == itr->second.end()) return NULL;
    return type->second;
}
