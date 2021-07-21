//
//  vm.h
//  vm
//
//  Created by yangjiandong on 2016/9/22.
//  Copyright © 2017 chunquedong. All rights reserved.
//

#ifndef vm_h
#define vm_h

#include "fni.h"
#include <assert.h>
#include "gcobj.h"

CF_BEGIN

/**
 * internal type
 */
struct sys_Obj_struct;
typedef struct sys_Obj_ FObj;

/**
 * fatch pointer from handle
 */
FObj *fr_getPtr(fr_Env self, fr_Obj obj);

/**
 * convert the pointer to handle
 * the pointer may be relocate by gc
 */
fr_Obj fr_toHandle(fr_Env self, FObj *obj);

/**
 * internal type
 */
//struct FType;
//struct fr_ObjHeader { struct FType * type; bool dirty; int mark;  };
typedef GcObj fr_ObjHeader;

/**
 * internal alloc obj
 */
FObj *fr_allocObj_internal(fr_Env self, fr_Type type, int size);

void fr_stackTrace(fr_Env self, char *buf, int size, const char *delimiter);


//struct FType *fr_getFType(fr_Env self, FObj *obj);
//struct FType *fr_toFType(fr_Env self, fr_Type otype);
const char *fr_getTypeName(fr_Env self, FObj *obj);

typedef struct fr_Array_ {
    fr_Type elemType;
    int32_t valueType;
    int32_t elemSize;
    fr_Int size;
    char data[1];
} fr_Array;

CF_END

enum FFlags {
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


#endif /* vm_h */
