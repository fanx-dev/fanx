//
//  Env.h
//  fcode
//
//  Created by yangjiandong on 15/8/2.
//  Copyright (c) 2015年 yangjiandong. All rights reserved.
//

#ifndef __fcode__Env__
#define __fcode__Env__

#include "gc/Gc.h"
#include <assert.h>
#include <vector>
#include "runtime.h"
#include <atomic>

#if defined(__clang__) || defined (__GNUC__)
# define ATTRIBUTE_NO_SANITIZE_ADDRESS __attribute__((no_sanitize_address))
#else
# define ATTRIBUTE_NO_SANITIZE_ADDRESS
#endif

struct JmpBuf {
    jmp_buf buf;
};

class Vm;

class Env : public fr_Env_struct {
public:
    std::atomic<bool> isStoped;
    Vm *vm;
    //fr_Obj error;
    //std::vector<const char*> stackTrace;
//#ifdef LONG_JMP_EXCEPTION
//    std::vector<JmpBuf> exception;
//#endif
public:
    
    
    void **stackStart;
    void **stackEnd;

public:
    Env(Vm *vm);
    void walkLocalRoot(Collector *gc);
    //void walkDirtyList(Gc *gc);
};


#endif /* defined(__fcode__Env__) */
