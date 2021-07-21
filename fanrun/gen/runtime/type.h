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

#ifdef  __cplusplus
extern  "C" {
#endif

typedef void *fr_Obj;
struct fr_Env_struct;
typedef struct fr_Env_struct *fr_Env;

typedef struct fr_Class_ *fr_Type;

struct fr_Facet {
    const char *type;
    const char *val;
};

struct fr_Field_ {
    const char *name;
    uint32_t flags;
    const char *type;
    int offset;
    bool isStatic;
    bool isValType;
    
    void *pointer;//address of static field
  
    int facetCount;
    struct fr_Facet *facetList;
    
    fr_Type parent;
};

struct fr_MethodParam_ {
    const char *name;
    uint32_t flags;
    const char *type;
};

typedef void* (*fr_Function)(fr_Env env__, void *param, void *retValue);

struct fr_Method_ {
    const char *name;
    uint32_t flags;
    const char *retType;
    //const char *inheritReturenType;
    //int offset; //vtable offset
    fr_Function func;
    int paramsCount;
    struct fr_MethodParam_ *paramsList;
    
    int facetCount;
    struct fr_Facet *facetList;
    
    fr_Type parent;
};


struct fr_IVTableMapItem {
    fr_Type type;
    uint64_t vtableOffset;
};

#define MAX_INTERFACE_SIZE 20

struct fr_Class_ {
    const char *name;
    uint32_t flags;
    
    int allocSize;
    //fr_Obj typeObj;
  
    struct fr_Class_ *base;
    int mixinCount;
  
    int fieldCount;
    struct fr_Field_ *fieldList;
    
    int methodCount;
    struct fr_Method_ *methodList;
    
    int facetCount;
    struct fr_Facet *facetList;
    
    bool staticInited;
    
    fr_Obj reflectObj;
  
    //fr_Function finalize;
    
    struct fr_IVTableMapItem interfaceVTableIndex[MAX_INTERFACE_SIZE];
};

struct fr_Pod_ {
    const char *name;
    const char *version;
    const char *depends;
    int metaCount;
    const char *metas;
};

void fr_VTable_init(fr_Env env, fr_Type type);

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
