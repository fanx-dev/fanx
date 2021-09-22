//
//  Gc.cpp
//  vm
//
//  Created by yangjiandong on 10/25/15.
//  Copyright © 2015 chunquedong. All rights reserved.
//

#include "Gc.h"
#include <atomic>
#include <stdlib.h>
//#include "FType.h"
#include <assert.h>
//#include "BitmapTest.h"
#include <functional>
#include "util/system.h"

void Gc::gcThreadRun() {
    while (!isQuit) {
        bool runGc = false;
        {
            std::unique_lock<std::mutex> lck(cdLock);
            condition.wait(lck);
            if (running) {
                runGc = true;
            }
        }
        if (isQuit) return;
        if (runGc) {
            doCollect();
        }
    }
}

Gc::Gc(GcSupport *support) : Collector(support), allocSize(0)
    , running(false), marker(0), trace(1), gcThread(NULL), isMarking(false), isStopWorld(false), enable(true), isQuit(false)
{
    lastAllocSize = 29;
    collectLimit = 1000000;

    //BitmapTest_run();
    gcThread = new std::thread(std::bind(&Gc::gcThreadRun, this));
    gcThread->detach();
}

Gc::~Gc() {
    //gcThread->join();
    delete gcThread;
}

void Gc::quit() {
    std::lock_guard<std::recursive_mutex> lock_guard(lock);
    isQuit = true;
    condition.notify_all();
}

#ifndef GC_NO_BITMAP
bool Gc::isRef(void *p) {
    std::lock_guard<std::recursive_mutex> lock_guard(lock);
    bool found = allRefs.getPtr(p);
    return found;
}
#else
bool Gc::isRef(void *p) {
    uint64_t ip = (uint64_t)p;
    ip = ip >> 3;
    std::lock_guard<std::recursive_mutex> lock_guard(lock);
    bool found = allRefs.find(ip) != allRefs.end();
    return found;
}
#endif

void Gc::setMarking(bool m) {
    //std::lock_guard<std::recursive_mutex> lock_guard(lock);
    isMarking.store(m);
}

void Gc::pinObj(GcObj* obj) {
    std::lock_guard<std::recursive_mutex> lock_guard(lock);
    pinObjs.push_back(obj);
}
void Gc::unpinObj(GcObj* obj) {
    std::lock_guard<std::recursive_mutex> lock_guard(lock);
    pinObjs.remove(obj);
}
void Gc::onVisit(GcObj* obj) {
    if (obj == NULL) {
        return;
    }
    if (!isRef(obj)) {
        abort();
    }
    markStack.push_back(obj);
}

void Gc::setDirty(GcObj *obj) {
    if (!isMarking) return;
    if (!isRef(obj)) {
        abort();
    }
    lock.lock();
    dirtyList.push_back(obj);
    lock.unlock();
}

GcObj* Gc::alloc(void *type, int asize) {
    //int size = asize + sizeof(GcObj);
    int size = asize;
    if ((allocSize + size - lastAllocSize > collectLimit) && (allocSize + size > lastAllocSize * 2) ) {
        collect();
    } else {
        lastAllocSize -= 1;
    }
    
    GcObj* obj = (GcObj*)calloc(1, size);
    if (obj == NULL) {
        collect();
        obj = (GcObj*)calloc(1, size);
    }
    
    assert(obj);
    obj->type = type;
    gc_setMark(obj, marker);
    //gc_setDirty(obj, 1);
    
    {
        std::lock_guard<std::recursive_mutex> lock_guard(lock);
    #ifndef GC_NO_BITMAP
        allRefs.putPtr(obj, true);
        //assert(allRefs.getPtr(obj));
    #else
        uint64_t ip = (uint64_t)obj;
        ip = ip >> 3;
        allRefs[ip] = true;
    #endif
        //newAllocRef.push_back(obj);
        allocSize += size;
    }
    
    setDirty(obj);
    
    if (trace > 1) {
        printf("malloc ");
        gcSupport->printObj(obj);
        printf("\n");
    }
    return obj;
}

void Gc::beginGc() {
    //mergeNewAlloc();
    marker = !marker;
}
void Gc::endGc() {
    std::lock_guard<std::recursive_mutex> lock_guard(lock);
    lastAllocSize = allocSize;
    running = false;
}

void Gc::collect() {
    std::lock_guard<std::mutex> lock_guard(cdLock);
    if (running) {
        return;
    }
    running = true;
    condition.notify_all();
}

void Gc::puaseWorld(bool bloking) {
    isStopWorld.store(true);
    gcSupport->puaseWorld(bloking);
//    if (trace) {
//        printf("puaseWorld\n");
//    }
}

void Gc::resumeWorld() {
    gcSupport->resumeWorld();
    isStopWorld.store(false);
//    if (trace) {
//        printf("resumeWorld\n");
//    }
}

bool Gc::isStopTheWorld() {
    return isStopWorld.load();
}

void Gc::doCollect() {
    if (!enable) return;
    
    if (trace) {
        printf("******* start gc: memory:%ld (limit:%ld, last:%ld)\n", allocSize, collectLimit, lastAllocSize);
    }
    long beginSize = allocSize;
    
    //ready for gc
    gcSupport->onStartGc();
    beginGc();
    
    //get root
    puaseWorld();
    getRoot();
    
    setMarking(true);
    resumeWorld();
    //concurrent mark
    mark();
    //mark();
    
    //remark root
    puaseWorld();
    //gcSupport->walkDirtyList(this);
    
    //remark changed
    mark();
    
    //concurrent sweep
    setMarking(false);
    resumeWorld();
    sweep();
    
    endGc();
    
    if (trace) {
        printf("******* end gc: memory:%ld, free:%ld\n", allocSize, beginSize - allocSize);
    }
}

void Gc::getRoot() {
    markStack.clear();
    lock.lock();
    for (auto it = pinObjs.begin(); it != pinObjs.end(); ++it) {
        markStack.push_back(*it);
    }
    lock.unlock();
    
    gcSupport->walkRoot(this);
    
    if (trace > 1) {
        printf("GC ROOT:\n");
        for (auto it = markStack.begin(); it != markStack.end(); ++it) {
            gcSupport->printObj(*it);
            printf(", ");
        }
        printf("\n");
    }
}

bool Gc::mark() {
    if (markStack.size() == 0) {
        lock.lock();
        markStack.swap(dirtyList);
        lock.unlock();
    }
    
    while (markStack.size() > 0) {
        GcObj *obj = markStack.back();
        markStack.pop_back();
        if (markNode(obj)) {
            gcSupport->visitChildren(this, obj);
        }
        //printf("trace:%p,", obj);
        //gcSupport->printObj(obj);
    }
    return true;
}

void Gc::sweep() {
#ifndef GC_NO_BITMAP
    uint64_t pos = 0;
    while (true) {
        lock.lock();
        GcObj *obj = (GcObj*)allRefs.nextPtr(pos);
        lock.unlock();
        
        if (!obj) break;
        if (gc_getMark(obj) != marker) {
            remove(obj, true);
        }
        //System_sleep(10);
    }
#else
    lock.lock();
    for (auto itr = allRefs.begin(); itr != allRefs.end();) {
        uint64_t ip = (itr->first);
        
        GcObj *obj = (GcObj*)(ip << 3);
        if (!obj) break;
        if (gc_getMark(obj) != marker) {
            remove(obj, false);
            itr = allRefs.erase(itr);
        }
        else {
            //printf("%p,", obj);
            ++itr;
        }
    }
    lock.unlock();
//    GcObj *pre = NULL;
//    while (obj) {
//        GcObj *next = (GcObj*)gc_getNext(obj);
//        if (gc_getMark(obj) != marker) {
//            remove(obj);
//            if (pre == NULL) {
//                allRefLink = next;
//            }
//            else {
//                gc_setNext(pre, next);
//            }
//            obj = next;
//        }
//        else {
//            pre = obj;
//            obj = next;
//        }
//    }
#endif
    
}

void Gc::remove(GcObj* obj, bool deleteFromAllRefs) {
    
    int size = gcSupport->allocSize(obj);
    
    gcSupport->finalizeObj(obj);
    
    if (trace > 1) {
        printf("free ");
        gcSupport->printObj(obj);
        printf("\n");
    }
    
    lock.lock();
    allocSize -= size;
    if (deleteFromAllRefs) {
#ifndef GC_NO_BITMAP
        allRefs.putPtr(obj, false);
#else
        uint64_t ip = (uint64_t)obj;
        ip = ip >> 3;
        allRefs.erase(allRefs.find(ip));
#endif
    }
    lock.unlock();
    
    obj->type = NULL;
    //obj->next = NULL;
    free(obj);
}

bool Gc::markNode(GcObj* obj) {
    if (obj == NULL) {
        return false;
    }

    if (gc_getMark(obj) == marker) {
        return false;
    }
    gc_setMark(obj, marker);
    //gc_setDirty(obj, 0);

    return true;
}
