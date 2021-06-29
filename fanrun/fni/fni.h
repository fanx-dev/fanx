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
#include "miss.h"

CF_BEGIN


/**
 * fr_Value union type
 */
typedef enum fr_ValueType_ {
    fr_vtOther, //unsed
    fr_vtObj,
    fr_vtInt,
    fr_vtFloat,
    fr_vtBool,
    fr_vtHandle,
    fr_vtPtr,
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

/**
 * union type, store any thing
 */
typedef union fr_Value_ {
    fr_Int i;
    fr_Float f;
    void *o;
    fr_Obj h;
    fr_Bool b;
    void *p;
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

bool fr_getParam(fr_Env env, void *param, fr_Value *val, int pos);

////////////////////////////
// GC
////////////////////////////

/**
 * stop the world and yield gc to run
 */
void fr_yieldGc(fr_Env self);

/**
 * allow gc to run in backgroud.
 * must only insert at before of IO blocking.
 */
void fr_allowGc(fr_Env self);

/**
 * add local ref. it will be auto releae when method finished.
 */
fr_Obj fr_newLocalRef(fr_Env self, fr_Obj obj);
void fr_deleteLocalRef(fr_Env self, fr_Obj obj);

/**
 * add global ref.
 */
fr_Obj fr_newGlobalRef(fr_Env self, fr_Obj obj);
void fr_deleteGlobalRef(fr_Env self, fr_Obj obj);

/**
 * alloc obj without init
 */
fr_Obj fr_allocObj(fr_Env self, fr_Type type, int size);

////////////////////////////
// Type
////////////////////////////

fr_Type fr_findType(fr_Env self, const char *pod, const char *type);
fr_Type fr_toType(fr_Env self, fr_ValueType vt);

bool fr_fitType(fr_Env self, fr_Type a, fr_Type b);
fr_Type fr_getInstanceType(fr_Env self, fr_Value *obj, fr_ValueType vtype);
fr_Type fr_getObjType(fr_Env self, fr_Obj obj);
bool fr_isInstanceOf(fr_Env self, fr_Obj obj, fr_Type type);

//fr_Obj fr_toTypeObj(fr_Env self, fr_Type type);

////////////////////////////
// Array
////////////////////////////

fr_Obj fr_arrayNew(fr_Env self, fr_Type type, size_t elemSize, size_t size);
size_t fr_arrayLen(fr_Env self, fr_Obj array);
void fr_arrayGet(fr_Env self, fr_Obj array, size_t index, fr_Value *val);
void fr_arraySet(fr_Env self, fr_Obj array, size_t index, fr_Value *val);

////////////////////////////
// Method
////////////////////////////

fr_Method fr_findMethod(fr_Env self, fr_Type type, const char *name);
fr_Method fr_findMethodN(fr_Env self, fr_Type type, const char *name, int paramCount);

void fr_callMethod(fr_Env self, fr_Method method, int argCount, fr_Value *arg, fr_Value *ret);

void fr_callNonVirtual(fr_Env self, fr_Method method
                       , int argCount, fr_Value *arg, fr_Value *ret);
void fr_newObj(fr_Env self, fr_Type type, fr_Method method
               , int argCount, fr_Value *arg, fr_Value *ret);

void fr_newObjS(fr_Env self, const char *pod, const char *type, const char *name
               , int argCount, fr_Value *arg, fr_Value *ret);

void fr_callMethodS(fr_Env self, const char *pod, const char *type, const char *name
                          , int argCount, fr_Value *arg, fr_Value *ret);

void fr_callOnObj(fr_Env self, const char *name
                    , int argCount, fr_Value *arg, fr_Value *ret);

////////////////////////////
// Field
////////////////////////////

fr_Field fr_findField(fr_Env self, fr_Type type, const char *name);

void fr_setStaticField(fr_Env self, fr_Type type, fr_Field field, fr_Value *val);
bool fr_getStaticField(fr_Env self, fr_Type type, fr_Field field, fr_Value *val);
void fr_setInstanceField(fr_Env self, fr_Value *bottom, fr_Field field, fr_Value *val);
bool fr_getInstanceField(fr_Env self, fr_Value *bottom, fr_Field field, fr_Value *val);

void fr_setStaticFieldS(fr_Env self, const char *pod, const char *type, const char *name, fr_Value *val);
bool fr_getStaticFieldS(fr_Env self, const char *pod, const char *type, const char *name, fr_Value *val);
void fr_setFieldS(fr_Env self, fr_Value *bottom, const char *name, fr_Value *val);
bool fr_getFieldS(fr_Env self, fr_Value *bottom, const char *name, fr_Value *val);

/////////////////////////////////////////////////////////////////////////////////
// exception
////////////////////////////////////////////////////////////////////

fr_Obj fr_getErr(fr_Env self);

bool fr_errOccurred(fr_Env self);

void fr_printErr(fr_Env self, fr_Obj err);

void fr_throw(fr_Env self, fr_Obj err);

void fr_throwNPE(fr_Env self);

void fr_throwUnsupported(fr_Env self);

void fr_throwNew(fr_Env self, const char *pod, const char *type, const char *msg);

void fr_clearErr(fr_Env self);

////////////////////////////////////////////////////////////////////
// box
////////////////////////////////////////////////////////////////////

/**
 * box primitive type to obj
 */
fr_Obj fr_box(fr_Env self, fr_Value *value, fr_ValueType vtype);

/**
 * fatch primitive type from obj
 */
bool fr_unbox(fr_Env self, fr_Obj obj, fr_Value *value);

////////////////////////////////////////////////////////////////////
// Str
////////////////////////////////////////////////////////////////////

/**
 * new create Str obj from utf8
 */
fr_Obj fr_newStrUtf8(fr_Env self, const char *bytes, ssize_t size);

/**
 * get utf8 from Str obj.
 */
const char *fr_getStrUtf8(fr_Env self, fr_Obj str);

/**
 * release utf8 and the local ref of Str
 */
void fr_releaseStrUtf8(fr_Env self, fr_Obj str, const char *bytes);

/**
 * call obj.toStr and return result
 */
fr_Obj fr_objToStr(fr_Env env, fr_Value obj, fr_ValueType vtype);

CF_END

#endif /* defined(__vm__fni__) */
