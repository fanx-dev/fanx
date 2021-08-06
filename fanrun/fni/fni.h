//
//  vm.h
//  vm
//
//  Created by yangjiandong on 15/9/27.
//  Copyright (c) 2015, yangjiandong. All rights reserved.
//

#ifndef __vm__fni__
#define __vm__fni__

#include <stdio.h>
#include "util/miss.h"
#include <stdarg.h>

CF_BEGIN


/**
 * fr_Value union type
 */
typedef enum fr_ValueType_ {
    fr_vtOther, //unknow
    fr_vtObj,   //internal ref
    fr_vtInt,   //int64
    fr_vtFloat, //float64
    fr_vtBool,  //bool
    fr_vtHandle,//fni handle
    fr_vtPtr,   //sys::Ptr
} fr_ValueType;


/**
 * typedef for Fantom
 */
typedef int64_t fr_Int;
typedef double fr_Float;
typedef bool fr_Bool;
typedef void * fr_Ptr;

/**
 * user client handle type
 */
typedef void *fr_Obj;

struct fr_Class_;
typedef struct fr_Class_ *fr_Type;

struct fr_Field_;
typedef struct fr_Field_ *fr_Field;

struct fr_Method_;
typedef struct fr_Method_ *fr_Method;

struct fr_Pod_;

/**
 * union type, store any thing
 */
typedef union fr_Value_ {
    fr_Int i; //fr_vtInt
    fr_Float f;//fr_vtFloat
    void *o;  //fr_vtObj
    fr_Obj h; //fr_vtHandle
    fr_Bool b;//fr_vtBool
    void *p;  //fr_vtPtr
} fr_Value;

/**
 * fr_Value type with a type tag
 */
typedef struct fr_TagValue_ {
    fr_Value any;
    fr_ValueType type;
} fr_TagValue;


/**
 * fr_Env is a API per thread
 */
//struct fr_Env_;
struct fr_Env_struct;
typedef struct fr_Env_struct *fr_Env;

/**
 * Fantom VM
 */
typedef void *fr_Fvm;

/**
 * native method prototype
 */
typedef void (*fr_NativeFunc)(fr_Env env, void *param, void *ret);

////////////////////////////
// VM
////////////////////////////

fr_Env fr_getEnv(fr_Fvm vm);
void fr_releaseEnv(fr_Fvm vm, fr_Env env);

void fr_registerMethod(fr_Fvm vm, const char *name, fr_NativeFunc func);

////////////////////////////
// Param
////////////////////////////

bool fr_getParam(fr_Env env, void *param, fr_Value *val, int pos, fr_ValueType *vtype);

////////////////////////////
// GC
////////////////////////////

/**
 * check need stop the world
 */
void fr_checkPoint(fr_Env env);

/**
 * allow gc to run in backgroud.
 * must only insert at before of IO blocking.
 */
void fr_allowGc(fr_Env env);
void fr_endAllowGc(fr_Env env);

/**
 * add local ref. it will be auto releae when method finished.
 */
fr_Obj fr_newLocalRef(fr_Env env, fr_Obj obj);
void fr_deleteLocalRef(fr_Env env, fr_Obj obj);

/**
 * add global ref.
 */
fr_Obj fr_newGlobalRef(fr_Env env, fr_Obj obj);
void fr_deleteGlobalRef(fr_Env env, fr_Obj obj);

/**
 * alloc obj without init
 */
fr_Obj fr_allocObj(fr_Env env, fr_Type type, int size);

////////////////////////////
// Type
////////////////////////////

fr_Type fr_findType(fr_Env env, const char *pod, const char *type);
fr_Type fr_toType(fr_Env env, fr_ValueType vt);

bool fr_fitType(fr_Env env, fr_Type a, fr_Type b);
fr_Type fr_getInstanceType(fr_Env env, fr_Value *obj, fr_ValueType vtype);
fr_Type fr_getObjType(fr_Env env, fr_Obj obj);
bool fr_isInstanceOf(fr_Env env, fr_Obj obj, fr_Type type);

//fr_Obj fr_toTypeObj(fr_Env env, fr_Type type);

////////////////////////////
// Array
////////////////////////////

fr_Obj fr_arrayNew(fr_Env env, fr_Type type, int32_t elemSize, size_t size);
size_t fr_arrayLen(fr_Env env, fr_Obj array);
void fr_arrayGet(fr_Env env, fr_Obj array, size_t index, fr_Value *val);
void fr_arraySet(fr_Env env, fr_Obj array, size_t index, fr_Value *val);

////////////////////////////
// Method
////////////////////////////

fr_Method fr_findMethod(fr_Env env, fr_Type type, const char *name);
fr_Method fr_findMethodN(fr_Env env, fr_Type type, const char *name, int paramCount);

fr_Value fr_callMethodV(fr_Env env, fr_Method method, int argCount, va_list args);
fr_Value fr_callMethod(fr_Env env, fr_Method method, int argCount, ...);
void fr_callMethodA(fr_Env env, fr_Method method, int argCount, fr_Value *arg, fr_Value *ret);

void fr_callNonVirtual(fr_Env env, fr_Method method
                       , int argCount, fr_Value *arg, fr_Value *ret);

fr_Value fr_newObjV(fr_Env env, fr_Type type, fr_Method method, int argCount, va_list args);
fr_Value fr_newObj(fr_Env env, fr_Type type, fr_Method method, int argCount, ...);
void fr_newObjA(fr_Env env, fr_Type type, fr_Method method
               , int argCount, fr_Value *arg, fr_Value *ret);

//short cut
fr_Obj fr_newObjS(fr_Env env, const char *pod, const char *type, const char *name, int argCount, ...);
fr_Value fr_callMethodS(fr_Env env, const char *pod, const char *type, const char *name, int argCount, ...);
fr_Value fr_callOnObj(fr_Env env, fr_Obj obj, const char *name, int argCount, ...);

////////////////////////////
// Field
////////////////////////////

fr_Field fr_findField(fr_Env env, fr_Type type, const char *name);

void fr_setStaticField(fr_Env env, fr_Field field, fr_Value *val);
bool fr_getStaticField(fr_Env env, fr_Field field, fr_Value *val);
void fr_setInstanceField(fr_Env env, fr_Obj obj, fr_Field field, fr_Value *val);
bool fr_getInstanceField(fr_Env env, fr_Obj obj, fr_Field field, fr_Value *val);

bool fr_setFieldS(fr_Env env, fr_Obj obj, const char *name, fr_Value val);
fr_Value fr_getFieldS(fr_Env env, fr_Obj obj, const char *name);

/////////////////////////////////////////////////////////////////////////////////
// exception
////////////////////////////////////////////////////////////////////

fr_Obj fr_getErr(fr_Env env);

bool fr_errOccurred(fr_Env env);

void fr_printErr(fr_Env env, fr_Obj err);

void fr_throw(fr_Env env, fr_Obj err);

void fr_throwNPE(fr_Env env);

void fr_throwUnsupported(fr_Env env);

void fr_throwNew(fr_Env env, const char *pod, const char *type, const char *msg);

void fr_clearErr(fr_Env env);

////////////////////////////////////////////////////////////////////
// box
////////////////////////////////////////////////////////////////////

/**
 * box primitive type to obj
 */
fr_Obj fr_box(fr_Env env, fr_Value *value, fr_ValueType vtype);

/**
 * fatch primitive type from obj
 */
fr_ValueType fr_unbox(fr_Env env, fr_Obj obj, fr_Value *value);

////////////////////////////////////////////////////////////////////
// Str
////////////////////////////////////////////////////////////////////

/**
 * new create Str obj from utf8
 */
fr_Obj fr_newStrUtf8(fr_Env env, const char *bytes);
fr_Obj fr_newStrUtf8N(fr_Env env, const char *bytes, ssize_t size);

/**
 * get utf8 from Str obj. the life time depends on str object.
 */
const char *fr_getStrUtf8(fr_Env env, fr_Obj str);



CF_END

#endif /* defined(__vm__fni__) */
