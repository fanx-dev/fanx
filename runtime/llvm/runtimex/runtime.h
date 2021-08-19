//
//  runtime.h
//  vm
//
//  Created by yangjiandong on 2019/8/14.
//  Copyright © 2019 yangjiandong. All rights reserved.
//

#ifndef runtime_h
#define runtime_h

#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

    //void fr_throw(void *err);
    void *fr_alloc(void *env, void *type);
    
    void *fr_getVTable(void *instance);
    void *fr_getITable(void *instance, void *interface);
    _Bool fr_typeFits(void *typeSub, void *typeSuper);
    
    void *fr_toTypeObj(void *vtable);

#ifdef __cplusplus
}
#endif

#endif /* runtime_h */
