//
//  Vm.hpp
//  vm
//
//  Created by yangjiandong on 2017/12/31.
//  Copyright © 2017年 yangjiandong. All rights reserved.
//

#ifndef Vm_hpp
#define Vm_hpp

#include "gc/Gc.h"
#include <assert.h>
#include <vector>
#include <stdio.h>
#include "runtime.h"
#include <unordered_map>
#include <map>
#include <thread>
#include <string>
#include <set>

class Env;

class Vm : public GcSupport {
    Collector *gc;
    //std::vector<GcObj*> globalRef;
    std::unordered_map<std::thread::id, Env*> threads;
    std::vector<fr_Obj*> staticFieldRef;
    std::recursive_mutex lock;
    
public:
    //reflect info
    typedef std::map<std::string, fr_Type > ClassMap;
    typedef std::map<std::string, ClassMap > PodMap;
    PodMap typeDb;
    std::map<std::string, struct fr_Pod_*> pods;

public:
    //std::set<fr_Type> classSet;
public:
    Vm();
    ~Vm();
    
    void registerClass(const char *pod, const char *clz, fr_Type type);
    void registerPod(struct fr_Pod_ *pod);
    fr_Type findClass(const char *pod, const char *clz);
    
    void start();
    void stop();
    
    Collector *getGc() { return gc; }
    Env *getEnv();
    void releaseEnv(Env *env);
    void addStaticRef(fr_Obj *obj);
    
    virtual void visitChildren(Collector *gc, GcObj *obj) override;
    virtual void walkRoot(Collector *gc) override;
    //virtual void walkDirtyList(Gc *gc) override;
    virtual void onStartGc() override;
    virtual void finalizeObj(GcObj *obj) override;
    virtual void puaseWorld(bool bloking) override;
    virtual void resumeWorld() override;
    virtual void printObj(GcObj *obj) override;
    virtual int allocSize(void *type) override;
};

#endif /* Vm_hpp */
