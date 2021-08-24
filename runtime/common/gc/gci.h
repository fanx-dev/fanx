//
//  gci.h
//  vm
//
//  Created by yangjiandong on 2020/1/3.
//  Copyright © 2020 yangjiandong. All rights reserved.
//

#ifndef gci_h
#define gci_h



class Collector;

class GcSupport {
public:
    virtual void visitChildren(Collector *gc, GcObj *obj) = 0;
    virtual void walkRoot(Collector *gc) = 0;
    //    virtual void walkDirtyList(Gc *gc) = 0;
    virtual void onStartGc() = 0;
    
    virtual void finalizeObj(GcObj *obj) = 0;
    virtual void puaseWorld(bool bloking) = 0;
    virtual void resumeWorld() = 0;
    virtual void printObj(GcObj *obj) = 0;
    virtual int allocSize(GcObj* gcobj) = 0;
    
    virtual ~GcSupport() {}
};

class Collector {
public:
    GcSupport *gcSupport;
public:
    Collector(GcSupport *support) : gcSupport(support) {}
    
    virtual ~Collector() {}

    virtual void quit() = 0;
    
    virtual bool isRef(void *p) = 0;
    
    virtual GcObj* alloc(void *type, int size) = 0;
    
    virtual void pinObj(GcObj* obj) = 0;
    virtual void unpinObj(GcObj* obj) = 0;
    
    virtual void onVisit(GcObj* obj) = 0;
    
    virtual void collect() = 0;
    
    virtual void setDirty(GcObj *obj) = 0;
    
    virtual void gcThreadRun() = 0;
    
    virtual bool isStopTheWorld() = 0;
};


#endif /* gci_h */
