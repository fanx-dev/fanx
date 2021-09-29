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
    bool found = pendingRefs.find(ip) != pendingRefs.end();
    if (!found) {
        std::lock_guard<std::recursive_mutex> lock_guard(allRefsLock);
        found = allRefs.find(ip) != allRefs.end();
    }
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
    gc_setMark(obj, !marker);
    lock.unlock();
}

GcObj* Gc::alloc(void *type, int asize) {
    //int size = asize + sizeof(GcObj);
    int size = asize;
    
    GcObj* obj = (GcObj*)calloc(1, size);
    while (obj == NULL) {
        collect();
        System_sleep(1);
        obj = (GcObj*)calloc(1, size);
    }
    
    assert(obj);
    obj->type = type;
    gc_setMark(obj, marker);
    
    {
        std::lock_guard<std::recursive_mutex> lock_guard(lock);
    #ifndef GC_NO_BITMAP
        allRefs.putPtr(obj, true);
        //assert(allRefs.getPtr(obj));
    #else
        uint64_t ip = (uint64_t)obj;
        ip = ip >> 3;
        pendingRefs[ip] = true;
    #endif
        
        if ((allocSize + size - lastAllocSize > collectLimit) && (allocSize + size > lastAllocSize * 10) ) {
            collect();
        } else {
            //lastAllocSize -= 1;
        }
        
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

void Gc::pauseWorld(bool bloking) {
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
    
    uint64_t t0 = System_currentTimeMillis();
    
    //ready for gc
    gcSupport->onStartGc();
    beginGc();
    
    //get root
    pauseWorld();
    getRoot();
    
    setMarking(true);
    resumeWorld();
    
    uint64_t t1 = System_currentTimeMillis();
    
    //concurrent mark
    mark(false);
    //mark();
    
    uint64_t t2 = System_currentTimeMillis();
    
    //remark root
    pauseWorld();
    getRoot();
        
    //remark changed
    mark(true);
    
    //concurrent sweep
    setMarking(false);
    resumeWorld();
    
    uint64_t t3 = System_currentTimeMillis();
    
    sweep();
    
    endGc();
    
    uint64_t t4 = System_currentTimeMillis();
    
    if (trace) {
        uint64_t allTime = t4 - t0;
        uint64_t pauseTime1 = t1 - t0;
        uint64_t pauseTime2 = t3 - t2;
        uint64_t markTime = t2 - t1;
        uint64_t sweepTime = t4 - t3;
        printf("******* end gc: memory:%ld -> %ld (%.2f); allTime:%lld, pause1:%lld, mark:%lld, pause2:%lld, sweep:%lld\n", beginSize, allocSize, allocSize/(double)beginSize, allTime, pauseTime1, markTime, pauseTime2, sweepTime);
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

bool Gc::mark(bool increment) {
    lock.lock();
    if (dirtyList.size() > 0) {
        markStack.insert(markStack.end(), dirtyList.begin(), dirtyList.end());
        dirtyList.clear();
    }
    lock.unlock();
    
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
    std::map<uint64_t, bool> pending;
    lock.lock();
    pending.swap(pendingRefs);
    lock.unlock();
    
    allRefsLock.lock();
    for (auto itr = pending.begin(); itr != pending.end(); ++itr) {
        allRefs[itr->first] = itr->second;
    }
    
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
    allRefsLock.unlock();
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
        //allRefsLock.lock();
        allRefs.erase(allRefs.find(ip));
        //allRefsLock.unlock();
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
