//
//  Env.cpp
//  fcode
//
//  Created by yangjiandong on 15/8/2.
//  Copyright (c) 2015年 yangjiandong. All rights reserved.
//

#include "Env.hpp"
#include "Vm.hpp"

#if defined(__clang__) || defined (__GNUC__)
# define ATTRIBUTE_NO_SANITIZE_ADDRESS __attribute__((no_sanitize_address))
#else
# define ATTRIBUTE_NO_SANITIZE_ADDRESS
#endif

Env::Env(Vm *vm) : vm(vm)//, error(0)
, stackStart(NULL) {
    isStoped = false;
    //needStop = false;
    stackStart = NULL;
    stackEnd = stackStart;
    error = NULL;
}

static bool isPointer(Vm *vm, Collector *gc, int64_t pointer) {
    if (pointer == 0) return false;
    if (pointer % 8 != 0) return false;
    GcObj *gcobj = fr_toGcObj_o((fr_Obj)(pointer));
    
    //must is heaer of pointer
    return gc->isRef(gcobj);
}

ATTRIBUTE_NO_SANITIZE_ADDRESS
void Env::walkLocalRoot(Collector *gc) {
//    if (error) {
//        gc->onRoot(fr_toGcObj(error));
//    }
    
    void **min = stackStart > stackEnd ? stackEnd : stackStart;
    void **max = stackStart < stackEnd ? stackEnd : stackStart;
    for (void **ptr = min; ptr <= max; ++ptr) {
        if (isPointer(vm, gc, (int64_t)(*ptr))) {
            GcObj *obj = fr_toGcObj_o((fr_Obj)(*ptr));
            //gc->onRoot(obj);
            gc->onVisit(obj);
        }
    }
}

//void Env::walkDirtyList(Gc *gc) {
//    for (GcObj *g : dirtyList) {
//        gc->onVisit(g);
//    }
//}

////////////////////////////
// Exception
////////////////////////////
//#ifdef LONG_JMP_EXCEPTION
//jmp_buf *fr_pushJmpBuf(fr_Env self) {
//    Env *env = (Env*)self;
//    JmpBuf buf;
//    env->exception.push_back(buf);
//    return &env->exception.back().buf;
//}
//
//jmp_buf *fr_popJmpBuf(fr_Env self) {
//    Env *env = (Env*)self;
//    JmpBuf &back = env->exception.back();
//    env->exception.pop_back();
//    return &back.buf;
//}
//jmp_buf *fr_topJmpBuf(fr_Env self) {
//    Env *env = (Env*)self;
//    JmpBuf &back = env->exception.back();
//    return &back.buf;
//}
//#endif
//
//fr_Obj fr_getErr(fr_Env self) {
//    Env *env = (Env*)self;
//    return env->error;
//}
//void fr_setErr(fr_Env self, fr_Obj err) {
//    Env *env = (Env*)self;
//    env->error = err;
//}
//void fr_clearErr(fr_Env self) {
//    Env *env = (Env*)self;
//    env->error = nullptr;
//}



