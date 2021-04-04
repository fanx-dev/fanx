//
//  gcobj.h
//  gen
//
//  Created by yangjiandong on 2017/9/16.
//  Copyright © 2017年 yangjiandong. All rights reserved.
//

#ifndef gcobj_h
#define gcobj_h

#ifdef  __cplusplus
extern  "C" {
#endif
    
#include "../util/miss.h"
typedef struct GcObj_ {
//    void *next;
    void *type;
} GcObj;

static const uint64_t headerPtrMask = ~((uint64_t)(7));
static const uint64_t headerMarkMask = ((uint64_t)(1));
static const uint64_t headerDirtyMask = ((uint64_t)(2));
    
inline void setBitField(uint64_t *target, int pos, int val) {
    if (val) {
        *target |= (1<<pos);
    } else {
        *target &= (~(1<<pos));
    }
}

#define gc_getType(obj) ((void*)(((uint64_t)((obj)->type)) & headerPtrMask))
//#define gc_getNext(obj) ((void*)(((uint64_t)((obj)->next)) & headerPtrMask))
#define gc_getMark(obj) (((uint64_t)((obj)->type)) & headerMarkMask)
//#define gc_isDirty(obj) (((uint64_t)((obj)->type)) & headerDirtyMask)

//#define gc_setNext(obj, ptr) ((obj)->next = (void*)((((uint64_t)((obj)->next))&((uint64_t)(7))) | ((uint64_t)ptr)))
#define gc_setMark(obj, marker) setBitField((uint64_t *)(&(obj->type)), 0, marker)
//#define gc_setDirty(obj, dirty) setBitField((uint64_t *)(&(obj->type)), 1, dirty)

#ifdef  __cplusplus
}//extern "C"
#endif
#endif /* gcobj_h */
