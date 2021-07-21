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

class Env;
class FPod;

class ObjFactory {
    std::unordered_map<fr_Int, fr_Obj> boxedInt;
    std::unordered_map<fr_Int, fr_Obj> boxedFloat;
    fr_Obj falseObj;
    fr_Obj trueObj;
public:
    ObjFactory();
    
    FObj * allocObj(Env *env, FType * type, int addRef, int size = 0);

    FObj * box(Env *env, fr_Value &value, fr_ValueType vtype);
    bool unbox(Env *env, FObj * &obj, fr_Value &value);
    
    FObj * getString(Env *env, FPod *curPod, uint16_t sid);
    
    FObj * newString(Env *env, const char *utf8);
    
//    FObj * getWrappedType(Env *env, FType *type);
//
//    FType * getFType(Env *env, FObj *otype);
    
    const char *getStrUtf8(Env *env, FObj *obj);
};

#endif /* defined(__vm__ObjFactory__) */
