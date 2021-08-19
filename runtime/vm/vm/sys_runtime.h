//
//  ObjFactory.h
//  vm
//
//  Created by yangjiandong on 15/10/4.
//  Copyright (c) 2015, yangjiandong. All rights reserved.
//

#ifndef __vm__ObjFactory__
#define __vm__ObjFactory__

#include <stdio.h>
#include "fni.h"
#include "fni_ext.h"
#include <unordered_map>


#ifdef  __cplusplus
extern  "C" {
#endif

class Env;
class FPod;

////////////////////////////////////////////////////////////////
// Alloc
////////////////////////////////////////////////////////////////

FObj* fr_allocObj_(Env* env, FType* type, int size);

////////////////////////////////////////////////////////////////
// Error
////////////////////////////////////////////////////////////////

FObj* fr_makeNPE_(Env* env);

FObj* fr_makeErr_(Env* env, const char* podName, const char* typeName, const char* msg);

FObj* fr_makeCastError_(Env* env);

FObj* fr_makeIndexError_(Env* env, fr_Int index, fr_Int limit);

void fr_printError_(Env* env, FObj* err);

////////////////////////////////////////////////////////////////
// Other
////////////////////////////////////////////////////////////////

fr_Array* fr_arrayNew_(Env* env, FType* elemType, int32_t elemSize, size_t size);

////////////////////////////////////////////////////////////////
// String
////////////////////////////////////////////////////////////////

FObj* fr_newStrUtf8N_(Env* e, const char* cstr, ssize_t size);

FObj* fr_newStrUtf8_(Env* e, const char* cstr);

char* fr_getStrUtf8_(Env* e, FObj* self__);

FObj* fr_getConstString_(Env* env, FPod* curPod, uint16_t sid);

FObj* fr_getConstUri_(Env* env, FPod* curPod, uint16_t sid);

FObj* fr_getTypeLiteral_(Env* e, FPod* curPod, uint16_t sid);
FObj* fr_getFieldLiteral_(Env* e, FPod* curPod, uint16_t sid);
FObj* fr_getMethodLiteral_(Env* e, FPod* curPod, uint16_t sid);

////////////////////////////////////////////////////////////////
// Boxing
////////////////////////////////////////////////////////////////



FObj* fr_box_(Env* env, fr_Value& any, fr_ValueType vtype);

fr_ValueType fr_unbox_(Env* env, FObj* obj, fr_Value& value);


#ifdef  __cplusplus
}//extern "C"
#endif

#endif /* defined(__vm__ObjFactory__) */
