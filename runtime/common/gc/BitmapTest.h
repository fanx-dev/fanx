//
//  BitmapTest.h
//  run
//
//  Created by yangjiandong on 2020/1/1.
//  Copyright © 2020 yangjiandong. All rights reserved.
//

#ifndef BitmapTest_h
#define BitmapTest_h

#include "Bitmap.hpp"


void BimapTest_testReal() {
    void *ptr = ((void*)(0x100c4dc10));
    void *ptr1 = ((void*)( 0x100a46940));
    void *ptr2 = ((void*)( 0x100900900));
    void *ptr3 = ((void*)( 0x100900930));

    Bitmap bitmap(2);
    bitmap.putPtr(ptr, true);
    assert(bitmap.getPtr(ptr));
    bitmap.putPtr(ptr1, true);
    assert(bitmap.getPtr(ptr));
    assert(bitmap.getPtr(ptr1));
    bitmap.putPtr(ptr2, true);
    assert(bitmap.getPtr(ptr));
    assert(bitmap.getPtr(ptr1));
    assert(bitmap.getPtr(ptr2));
    bitmap.putPtr(ptr3, true);
    assert(bitmap.getPtr(ptr));
    assert(bitmap.getPtr(ptr1));
    assert(bitmap.getPtr(ptr2));
    assert(bitmap.getPtr(ptr3));
}

void BitmapTest_testPtr() {
    Bitmap bitmap(2);
    bool r;
    void *ptr = ((void*)(65<<3));
    void *ptr3 = ((void*)(129<<3));
    void *ptr2 = ((void*)(1<<3));
    
    bitmap.putPtr(ptr3, true);
    r = bitmap.getPtr(ptr3);
    assert(r);
    
    bitmap.putPtr(ptr2, true);
    r = bitmap.getPtr(ptr2);
    assert(r);
    
    bitmap.putPtr(ptr3, true);
    r = bitmap.getPtr(ptr3);
    assert(r);
    
    bitmap.putPtr(ptr, true);
    r = bitmap.getPtr(ptr);
    assert(r);
}


void BitmapTest_run() {
    Bitmap bitmap(2);
    bitmap.put(0, true);
    bool r = bitmap.get(0);
    assert(r);
    
    bitmap.put(65, true);
    r = bitmap.get(65);
    assert(r);
    r = bitmap.get(64);
    assert(!r);
    r = bitmap.get(66);
    assert(!r);
    
    bitmap.clear();
    r = bitmap.get(65);
    assert(!r);
    
    bitmap.put(64, true);
    r = bitmap.get(64);
    assert(r);
    
    bitmap.put(64, false);
    r = bitmap.get(64);
    assert(!r);
    
    bitmap.put(63, true);
    r = bitmap.get(63);
    assert(r);
    
    bitmap.put(128, true);
    r = bitmap.get(128);
    assert(r);
    
    BitmapTest_testPtr();
    BimapTest_testReal();
}

#endif /* BitmapTest_h */
