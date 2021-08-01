//
//  Type.h
//  fcode
//
//  Created by yangjiandong on 15/8/2.
//  Copyright (c) 2015年 yangjiandong. All rights reserved.
//

#ifndef __fcode__Type__
#define __fcode__Type__

#include <inttypes.h>
#include "util/miss.h"

#include "fni_ext.h"

#ifdef  __cplusplus
extern  "C" {
#endif

//void fr_VTable_init(fr_Env env, fr_Type type);

bool fr_isClass(fr_Env env, fr_Obj obj, fr_Type type);

fr_Type fr_getClass(fr_Env env, fr_Obj obj);

void **fr_getInterfaceVTable(fr_Env env, fr_Obj obj, fr_Type itype);

void fr_registerClass(fr_Env env, const char *pod, const char *clz, fr_Type type);
//fr_Type fr_findClass(fr_Env env, const char *pod, const char *clz);
    
void fr_registerPod(fr_Env env, struct fr_Pod_ *pod);

#ifdef  __cplusplus
}//extern  "C" {
#endif
#endif /* defined(__fcode__Type__) */
