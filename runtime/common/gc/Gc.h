//
//  Gc.hpp
//  vm
//
//  Created by yangjiandong on 10/25/15.
//  Copyright © 2015 chunquedong. All rights reserved.
//

#ifndef Gc_hpp
#define Gc_hpp

#include "gcobj.h"
#include "gci.h"

#include <stdio.h>
//#include "vm.h"
#include <list>
#include <vector>
#include <set>
#include <mutex>
#include <map>
#include "Bitmap.hpp"
#include <thread>
#include <atomic>

#define GC_NO_BITMAP

class Gc : public Collector {
    std::list<GcObj*> pinObjs;

#ifndef GC_NO_BITMAP
    Bitmap allRefs;
#else
    std::map<uint64_t, bool> allRefs;
#endif
    std::vector<GcObj*> markStack;
    
    std::vector<GcObj*> dirtyList;
    
    std::recursive_mutex lock;
    std::atomic<bool> isStopWorld;
    int marker;
    bool running;
    bool isQuit;
    std::atomic<bool> isMarking;
    std::thread *gcThread;
    std::mutex cdLock;
    std::condition_variable condition;
public:
    //GcSupport *gcSupport;
    
    long collectLimit;
    long lastAllocSize;
    long allocSize;
    int trace;
    bool enable;
    
public:

    Gc(GcSupport *support);
    ~Gc();

    void quit();
    
    bool isRef(void *p);
    
    GcObj* alloc(void *type, int size);
    
    void pinObj(GcObj* obj);
    void unpinObj(GcObj* obj);
    
    void onVisit(GcObj* obj);
 
    void collect();
    
    void setDirty(GcObj *obj);
    
    void gcThreadRun();
    
    bool isStopTheWorld();
private:
    void setMarking(bool m);
    void doCollect();
    
    void puaseWorld(bool bloking = true);
    void resumeWorld();
    
    void beginGc();
    void endGc();
    
    //void mergeNewAlloc();
    bool mark();
    void getRoot();
    void sweep();
//    bool remark();
    void remove(GcObj* obj, bool deleteFromAllRefs);
    
    bool markNode(GcObj* obj);
};

#endif /* Gc_hpp */
