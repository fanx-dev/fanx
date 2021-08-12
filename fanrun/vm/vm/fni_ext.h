//
//  vm.h
//  vm
//
//  Created by yangjiandong on 2016/9/22.
//  Copyright © 2017 chunquedong. All rights reserved.
//

#ifndef vm_h
#define vm_h

#include "fni_private.h"
#include <assert.h>
#include "gc/gcobj.h"

CF_BEGIN


/**
 * internal type
 */
struct FType;
//struct fr_ObjHeader { struct FType * type; bool dirty; int mark;  };
//typedef GcObj fr_ObjHeader;

//
void fr_stackTrace(fr_Env self, char *buf, int size, const char *delimiter, int skip);


struct FType *fr_getFType(fr_Env self, FObj *obj);
struct FType *fr_toFType(fr_Env self, fr_Type otype);
fr_Type fr_fromFType(fr_Env env, struct FType* ftype);

void fr_arrayGet_(fr_Env self, fr_Array* array, size_t index, fr_Value* val);
void fr_arraySet_(fr_Env self, fr_Array* array, size_t index, fr_Value* val);

CF_END

#endif /* vm_h */
