//
//  fni_private.h
//  vm
//
//  Created by yangjiandong on 2021/7/22.
//  Copyright © 2021 yangjiandong. All rights reserved.
//

#ifndef fni_private_h
#define fni_private_h


#include "fni.h"
#include <assert.h>
#include "gc/gcobj.h"

CF_BEGIN

/**
 * internal type
 */
struct sys_Obj_struct;
typedef struct sys_Obj_struct FObj;

fr_Fvm fr_getVm(fr_Env env);

/**
 * fatch pointer from handle
 */
FObj *fr_getPtr(fr_Env self, fr_Obj obj);

/**
 * convert the pointer to handle
 * the pointer may be relocate by gc
 */
fr_Obj fr_toHandle(fr_Env self, FObj *obj);


const char *fr_getTypeName(fr_Env self, fr_Obj obj);


typedef struct fr_Array_ {
    fr_Type elemType;
    int32_t valueType;
    int32_t elemSize;
    fr_Int size;
    FObj* data[1];
} fr_Array;

void* fr_arrayData(fr_Env env, fr_Obj array);

GcObj *fr_toGcObj(FObj *obj);
FObj *fr_fromGcObj(GcObj *g);

void fr_gc(fr_Env self);
void fr_setGcDirty(fr_Env self, FObj *obj);

enum FConstFlags {
    FFlags_Abstract   = 0x00000001,
    FFlags_Const      = 0x00000002,
    FFlags_Ctor       = 0x00000004,
    FFlags_Enum       = 0x00000008,
    FFlags_Facet      = 0x00000010,
    FFlags_Final      = 0x00000020,
    FFlags_Getter     = 0x00000040,
    FFlags_Internal   = 0x00000080,
    FFlags_Mixin      = 0x00000100,
    FFlags_Native     = 0x00000200,
    FFlags_Override   = 0x00000400,
    FFlags_Private    = 0x00000800,
    FFlags_Protected  = 0x00001000,
    FFlags_Public     = 0x00002000,
    FFlags_Setter     = 0x00004000,
    FFlags_Static     = 0x00008000,
    FFlags_Storage    = 0x00010000,
    FFlags_Synthetic  = 0x00020000,
    FFlags_Virtual    = 0x00040000,

    FFlags_Struct     = 0x00080000,
    FFlags_Extension  = 0x00100000,
    FFlags_RuntimeConst=0x00200000,
    FFlags_Readonly   = 0x00400000,
    FFlags_Async      = 0x00800000,
    FFlags_Overload   = 0x01000000,
    FFlags_Closure    = 0x02000000,
    FFlags_FlagsMask  = 0x0fffffff,


    FFlags_Param       = 0x0001,  // parameter or local variable
    FFlags_ParamDefault= 0x0002, //the param has default

    //////////////////////////////////////////////////////////////////////////
    // MethodRefFlags
    //////////////////////////////////////////////////////////////////////////
    FFlags_RefOverload = 0x0001,
    FFlags_RefSetter   = 0x0002,
};

struct fr_Facet_ {
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
    struct fr_Facet_ *facetList;
    
    fr_Type parent;

    void* internalSlot;
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
    struct fr_Facet_ *facetList;
    
    fr_Type parent;

    void* internalSlot;
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
    void* internalType;
    
    struct fr_IVTableMapItem interfaceVTableIndex[MAX_INTERFACE_SIZE];
};

struct fr_Pod_ {
    const char *name;
    const char *version;
    const char *depends;
    int metaCount;
    const char *metas;
};


CF_END

#endif /* fni_private_h */
