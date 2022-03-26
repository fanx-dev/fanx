//
//  runtime.h
//  gen
//
//  Created by yangjiandong on 2017/9/10.
//  Copyright © 2017 yangjiandong. All rights reserved.
//

#ifndef runtime_h
#define runtime_h

#ifdef  __cplusplus
extern  "C" {
#endif

//#include "common.h"
#include "util/miss.h"
#include "type.h"
#include "gc/gcobj.h"

#include <stdlib.h>
#include <stdio.h>
#include <setjmp.h>
#include <string.h>

#include "fni_ext.h"

//#define LONG_JMP_EXCEPTION
typedef fr_Obj fr_Err;

struct fr_Env_struct {
    fr_Err error;
};
typedef struct fr_Env_struct *fr_Env;
typedef void *fr_Fvm;

////////////////////////////
// VM
////////////////////////////

fr_Env fr_getEnv(fr_Fvm vm);
void fr_releaseEnv(fr_Env env);

////////////////////////////
// Exception
////////////////////////////
//#ifdef LONG_JMP_EXCEPTION
//jmp_buf *fr_pushJmpBuf(fr_Env self);
//jmp_buf *fr_popJmpBuf(fr_Env self);
//jmp_buf *fr_topJmpBuf(fr_Env self);
//#endif


//fr_Obj fr_getErr(fr_Env self);
void fr_setErr(fr_Env self, fr_Err err);
//void fr_clearErr(fr_Env self);

////////////////////////////
// GC
////////////////////////////

//fr_Obj fr_addGlobalRef(fr_Env self, fr_Obj obj);
//void fr_deleteGlobalRef(fr_Env self, fr_Obj obj);
//void fr_addStaticRef(fr_Env self, fr_Obj *obj);

void fr_gc(fr_Env self);
//GcObj *fr_toGcObj(fr_Obj obj);
//fr_Obj fr_fromGcObj(GcObj *g);
#define fr_toGcObj_(obj) (((GcObj*)(obj))-1)
#define fr_fromGcObj_(g) ((FObj*)(((GcObj*)(g))+1))

#define fr_toGcObj_o(obj) fr_toGcObj_((FObj*)(obj))
#define fr_fromGcObj_o(g) ((FObj*)fr_toGcObj_(g))

void fr_checkPoint(fr_Env self);
void fr_allowGc(fr_Env self);
void fr_endAllowGc(fr_Env self);
void fr_setGcDirty(fr_Env self, FObj* obj);

////////////////////////////
// Util
////////////////////////////

//fr_Obj fr_newStr(fr_Env __env, const wchar_t *data, size_t size, bool copy);
//fr_Obj fr_newStrUtf8(fr_Env self, const char *bytes, ssize_t size);
const char *fr_getStrUtf8(fr_Env env__, fr_Obj str);
    
//fr_Obj fr_toTypeObj(fr_Env env, fr_Type);
fr_Err fr_makeNPE(fr_Env __env);
fr_Err fr_makeCastError(fr_Env __env);
fr_Err fr_makeIndexError(fr_Env __env, fr_Int index, fr_Int limit);
void fr_printError(fr_Env __env, fr_Err error);

////////////////////////////
// Buildin type
////////////////////////////
typedef int64_t sys_Int_val;
typedef int8_t  sys_Int8_val;
typedef int16_t sys_Int16_val;
typedef int32_t sys_Int32_val;
typedef int64_t sys_Int64_val;
typedef int8_t  sys_Int8;
typedef int16_t sys_Int16;
typedef int32_t sys_Int32;
typedef int64_t sys_Int64;

typedef double sys_Float_val;
typedef double sys_Float64_val;
typedef float sys_Float32_val;
typedef double sys_Float64;
typedef float sys_Float32;

typedef bool sys_Bool_val;
typedef void * sys_Ptr_val;

struct sys_Int_struct {
    int64_t _val;
};
struct sys_Float_struct {
    double _val;
};
struct sys_Bool_struct {
    bool _val;
};

struct sys_Ptr_struct {
    void *_val;
};

fr_Obj fr_box_int(fr_Env, sys_Int_val val);
fr_Obj fr_box_float(fr_Env, sys_Float_val val);
fr_Obj fr_box_bool(fr_Env, sys_Bool_val val);

////////////////////////////
// Other
////////////////////////////

//NullTerminated Str
#define FR_STR(bytes) fr_newStrUtf8(env__, bytes, -1)
    
#define FR_TYPE_IS(obj, type) fr_isClass(__env, obj, type##_class__)
#define FR_TYPE_AS(obj, type) (type##_null)(FR_TYPE_IS(obj, type)?obj:NULL)
#define FR_CAST(pos, ret, obj, type, toType) do{ if (!obj || FR_TYPE_IS(obj, type)) ret = (toType)obj; \
    else FR_THROW(pos, fr_makeCastError(__env)); }while(0)

#define FR_ALLOC(type) ((type##_ref)fr_allocObj(__env, type##_class__, -1))
#define FR_INIT_VAL(val, type) (memset(&val, 0, sizeof(struct type##_struct)))

#define FR_BEGIN_FUNC int __errOccurAt;
#define FR_TRY /*try*/
#define FR_CATCH /*catch(...)*/
#define FR_THROW(pos, err) do{fr_setErr(__env, err); __errOccurAt = pos; goto __errTable;}while(0)
#define FR_THROW_NPE(pos) FR_THROW(pos, fr_makeNPE(__env))
#define FR_CHECK_NULL(pos, obj) do{ if (!obj) FR_THROW_NPE(pos); }while(false)
//#define FR_ERR_TYPE(type) (FR_TYPE_IS(fr_getErr(__env), type))
//#define FR_ALLOC_THROW(pos, errType) FR_THROW(pos, FR_ALLOC(errType))

#define FR_SET_ERROR(err) do{fr_setErr(__env, err);}while(0)
#define FR_SET_ERROR_MAKE(errType, msg) do{\
        errType __err=FR_ALLOC(errType);\
        errType##_make__1(__env, __err, (sys_Str)fr_newStrUtf8(__env, msg, -1));\
        FR_SET_ERROR(__err); \
    }while(0)
#define FR_SET_ERROR_NPE() FR_SET_ERROR(fr_makeNPE(__env))

#define _FR_VTABLE(typeName, self) ( (struct typeName##_vtable*)(((struct fr_Class_*)fr_getClass(__env, self))+1) )
#define _FR_IVTABLE(typeName, self) ( (struct typeName##_vtable*)fr_getInterfaceVTable(__env, self, typeName##_class__) )

#define FR_CHECK_ERR(errPos) do{ if (__env->error) { __errOccurAt = errPos; goto __errTable;} }while(0)

#define FR_VCALL(type, method, self, ...) _FR_VTABLE(type, self)->method(__env, self, ## __VA_ARGS__)
#define FR_ICALL(type, method, self, ...) _FR_IVTABLE(type, self)->method(__env, self, ## __VA_ARGS__)
#define FR_CALL(type, method, self, ...)  type##_##method(__env, self, ## __VA_ARGS__)
#define FR_SCALL(type, method, ...)  type##_##method(__env, ## __VA_ARGS__)


#ifdef STRUCT_VALUE
#define FR_BOXING_STRUCT(target, value, fromType, toType) {\
    fromType##_ref tmp__ = FR_ALLOC(fromType);\
    memcpy(tmp__, &value, sizeof(struct fromType##_struct));\
    target = (toType)tmp__;}
#define FR_UNBOXING_STRUCT(target, obj, toType) (memcpy(&target, (toType##_null)obj, sizeof(struct toType##_struct)), target)
#else
#define FR_BOXING_STRUCT(target, value, fromType, toType) (target = value)
#define FR_UNBOXING_STRUCT(target, obj, toType) (target = obj)
#endif

#define FR_BOXING_VAL(target, value, fromType, toType) {\
    fromType##_ref tmp__ = FR_ALLOC(fromType);\
    tmp__->_val = value;\
    target = (toType)tmp__;}
#define FR_UNBOXING_VAL(obj, toType) (((toType##_null)obj)->_val)

#define FR_BOX_INT(value) ((sys_Int_ref)fr_box_int(__env, value))
#define FR_BOX_FLOAT(value) ((sys_Float_ref)fr_box_float(__env, value))
#define FR_BOX_BOOL(value) ((sys_Bool_ref)fr_box_bool(__env, value))


#define FR_NOT_NULL(pos, ret, obj, toType) do{if (obj) ret = (toType)obj; else FR_THROW_NPE(pos); }while(0)

#define FR_CHECK_POINT() fr_checkPoint(__env)
#define FR_SET_DIRTY(obj) fr_setGcDirty(__env, (fr_Obj)obj)
    
#define FR_STATIC_INIT(type) do{\
    if(!type##_class__->staticInited) {\
        type##_class__->staticInited=true;\
        type##_static__init(__env);\
        if (__env->error) { fr_printError(__env, __env->error); abort(); }\
    }}while(0)

#ifdef  __cplusplus
}
#endif

#endif /* runtime_h */
