//
//  Bitmap.hpp
//  run
//
//  Created by yangjiandong on 2019/12/31.
//  Copyright © 2019 yangjiandong. All rights reserved.
//

#ifndef Bitmap_hpp
#define Bitmap_hpp

#include <stdio.h>
#include "util/miss.h"
#include <stdlib.h>
#include <memory.h>
#include <assert.h>

class Bitmap {
    uint64_t *words;
    uint64_t size;
    uint64_t useSize;
    uint64_t basePtr;
public:
    Bitmap(uint64_t wordSize = 10 * 1024 * 1024) {
        words = (uint64_t *)calloc(1, wordSize*sizeof(uint64_t));
        size = wordSize;
        useSize = 0;
        basePtr = 0;
        if (sizeof(void*) != 8) abort();
    }
    ~Bitmap() {
        free(words);
    }
    
    bool get(uint64_t i) {
        uint64_t p = i >> 6;
        uint64_t mask = ((uint64_t)1) << (i % 64);
        if (p >= size) return false;
        return (words[p] & mask) != 0;
    }
    void put(uint64_t i, bool v) {
        uint64_t p = i >> 6;
        uint64_t mask = ((uint64_t)1) << (i % 64);
        
        if (p >= size) resize(p+1, true);
        
        if (v) {
            words[p] |= mask;
        }
        else {
            words[p] &= (~mask);
        }
        
        if (p+1 > useSize) useSize = p+1;
    }
    
    void putPtr(void *ptr, bool v) {
        uint64_t p = (uint64_t)ptr;
        p = p >> 3;
        if (p < basePtr) {
            //uint64_t test = basePtr;
            rebase(p);
            //assert(get(test-basePtr));
            assert(p >= basePtr);
        }
        else if (basePtr == 0) {
            basePtr = p;
        }
        
        uint64_t i = p - basePtr;
        put(i, v);
    }
    
    bool getPtr(void *ptr) {
        uint64_t p = (uint64_t)ptr;
        p = p >> 3;
        if (p < basePtr) return false;
        uint64_t i = p - basePtr;
        return get(i);
    }
    
    void *nextPtr(uint64_t &bitPos) {
        while(true) {
            if (bitPos % 64 == 0) {
                while (true) {
                    uint64_t p = bitPos / 64;
                    if (p >= size) return NULL;
                    if (words[p] == 0) {
                        bitPos += 64;
                        continue;
                    }
                    else {
                        break;
                    }
                }
            }
            
            bool v = get(bitPos);
            if (v) {
                void *ptr = (void*)((bitPos + basePtr) << 3);
                ++bitPos;
                return ptr;
            }
            ++bitPos;
        }
        return NULL;
    }
    
    void clear() {
        for (uint64_t i = 0; i<size; ++i) {
            words[i] = 0;
        }
    }
private:
    void rebase(uint64_t ptr) {
        uint64_t shift = (basePtr - ptr) / 64;
        if ((basePtr - ptr) % 64) {
            ++shift;
        }
        
        if (size - useSize < shift) {
            resize(useSize + shift, false);
        }
        memmove(words+shift, words, useSize*8);
        for (uint64_t i = 0; i < shift; ++i) {
            words[i] = 0;
        }
        useSize += shift;
        basePtr -= shift*64;
    }
    
    void resize(uint64_t nsize, bool clean) {
        words = (uint64_t*)realloc(words, nsize*sizeof(uint64_t));
        if (words == NULL) abort();
        uint64_t i = size;
        size = nsize;
        if (clean) {
            for (; i<nsize; ++i) {
                words[i] = 0;
            }
        }
    }
};

#endif /* Bitmap_hpp */
