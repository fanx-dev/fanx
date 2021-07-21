//
//  fni.cpp
//  vm
//
//  Created by yangjiandong on 15/9/27.
//  Copyright (c) 2015, yangjiandong. All rights reserved.
//

#include "vm.h"
#include "ThreadEnv.hpp"
#include "Vm.hpp"
#include <assert.h>
#include "runtime.h"
#include "type.h"
#include "system.h"

void fr_registerMethod(fr_Fvm vm, const char *name, fr_NativeFunc func) {
    //pass
}

////////////////////////////
// Param
////////////////////////////

FObj *fr_getPtr(fr_Env self, fr_Obj obj) {
    if (obj == 0) return NULL;
    return (FObj*)(obj);
}

fr_Obj fr_toHandle(fr_Env self, FObj *obj) {
    //FObj *obj = (FObj*)aobj;
    if (obj == NULL) return NULL;
    //Env *e = (Env*)self;
    fr_Obj objRef;
    
    objRef = reinterpret_cast<fr_Obj>(obj);
    //fr_unlock(self);
    return objRef;
}

bool fr_getParam(fr_Env env, void *param, fr_Value *val, int pos, fr_ValueType *vtype) {
    //Env *e = (Env*)env;
    //e->lock();
    fr_TagValue *tval = (fr_TagValue *)param;
    tval += pos;
    
    *val = tval->any;
    *vtype = tval->type;
    return true;
}

////////////////////////////
// Type
////////////////////////////

//int fr_getFuncArity(fr_Env env, fr_Type clz) {
//    return 0;
//}

//struct FType *fr_getFType(fr_Env self, FObj *obj) {
//    return (struct FType *)gc_getType(obj);
//}
////struct FType *fr_toFType(fr_Env self, FObj *obj);
const char *fr_getTypeName(fr_Env self, FObj *obj) {
    //Env *e = (Env*)env;
    fr_Type type = fr_getClass(self, obj);
    return type->name;
}

////////////////////////////
// GC
////////////////////////////

//void fr_yieldGc(fr_Env self) {
//    Env *env = (Env*)self;
//    if (env->vm->getGc()->isStopTheWorld()) {
//        void *statckVar = 0;
//        env->statckEnd = &statckVar;
//        env->isStoped = true;
//
//        do {
//            System_sleep(1);
//        } while(env->vm->getGc()->isStopTheWorld());
//        env->isStoped = false;
//    }
//}
void fr_allowGc(fr_Env self) {
//    Env *e = (Env*)self;
    //TODO fr_allowGc GC
}

fr_Obj fr_newLocalRef(fr_Env self, fr_Obj obj) {
    //Env *e = (Env*)self;
    //fr_lock(self);
    //obj = e->newLocalRef(fr_getPtr(self, obj));
    //fr_unlock(self);
    //fr_new
    return obj;
}

void fr_deleteLocalRef(fr_Env self, fr_Obj obj) {
    //Env *e = (Env*)self;
    //fr_lock(self);
    //FObj **fobj = reinterpret_cast<FObj **>(obj);
    //*fobj = nullptr;
    //e->removeLocalRef(fr_getPtr(self, obj));
    //fr_unlock(self);
}

fr_Obj fr_newGlobalRef(fr_Env self, fr_Obj obj) {
    Env *env = (Env*)self;
    env->vm->getGc()->pinObj(fr_toGcObj(obj));
    return obj;
}

//void fr_deleteGlobalRef(fr_Env self, fr_Obj obj) {
//    Env *env = (Env*)self;
//    env->vm->getGc()->unpinObj(fr_toGcObj(obj));
//}

//FType *fr_toFType(fr_Env self, fr_Type otype) {
//    //Env *e = (Env*)self;
//    //FObj *typeObj = fr_getPtr(self, otype);
//    //FType *ftype = e->podManager->getFType(e, typeObj);
//    return otype;
//}


fr_Obj fr_allocObj(fr_Env self, fr_Type type, int size) {
    Env *env = (Env*)self;
    int allocSize = type->allocSize;
    if (allocSize < (int)size) allocSize = (int)size;
    GcObj *gcobj = env->vm->getGc()->alloc(type, allocSize+sizeof(GcObj));
    fr_Obj obj = fr_fromGcObj(gcobj);
    return obj;
}

FObj *fr_allocObj_internal(fr_Env self, fr_Type type, int size) {
    Env *env = (Env*)self;
    int allocSize = type->allocSize;
    if (allocSize < (int)size) allocSize = (int)size;
    GcObj *gcobj = env->vm->getGc()->alloc(type, allocSize+sizeof(GcObj));
    fr_Obj obj = fr_fromGcObj(gcobj);
    return (FObj *)obj;
}

//void fr_gc(fr_Env self) {
//    Env *e = (Env*)self;
//    e->vm->getGc()->collect();
//}

////////////////////////////
// Type
////////////////////////////

fr_Type fr_findType(fr_Env self, const char *pod, const char *type) {
    Env *e = (Env*)self;
    //e->lock();
    fr_Type t = e->vm->findClass(pod, type);
    //e->unlock();
    //return fr_getTypeObj(self, t);
    return t;
}
fr_Type fr_toType(fr_Env self, fr_ValueType vt) {
    //Env *e = (Env*)self;
    
    switch (vt) {
        case fr_vtInt:
            return fr_findType(self, "sys", "Int");
            break;
        case fr_vtFloat:
            return fr_findType(self, "sys", "Float");
            break;
        case fr_vtBool:
            return fr_findType(self, "sys", "Bool");
            break;
        default:
            break;
    }
    
    return fr_findType(self, "sys", "Obj");
}

fr_Type fr_getInstanceType(fr_Env self, fr_Value *obj, fr_ValueType vtype) {
    //return fr_getTypeObj(self, t);
    return fr_getClass(self, obj->p);
}
fr_Type fr_getObjType(fr_Env self, fr_Obj obj) {
    if (obj == 0) {
        return 0;
    }
    //fr_lock(self);
    FObj *o = fr_getPtr(self, obj);
    fr_Type type = (fr_Type)fr_getClass(self, o);
    //fr_unlock(self);
    
    //return fr_getTypeObj(self, type);
    return type;
}

bool fr_isInstanceOf(fr_Env self, fr_Obj obj, fr_Type type) {
    fr_Type itype = fr_getObjType(self, obj);
    bool rc = fr_fitType(self, itype, type);
    //fr_unlock(self);
    return rc;
}

//fr_Obj fr_toTypeObj(fr_Env self, fr_Type type) {
//    Env *e = (Env*)self;
//    //e->lock();
//    FObj *obj = e->podManager->getWrappedType(e, (FType *)type);
//    fr_Obj objRef = fr_toHandle(self, obj);
//    //e->unlock();
//    return objRef;
//}

////////////////////////////
// Array
////////////////////////////


size_t fr_arrayLen(fr_Env self, fr_Obj array) {
    fr_Array *a = (fr_Array*)fr_getPtr(self, array);
    return a->size;
}
void fr_arrayGet(fr_Env self, fr_Obj array, size_t index, fr_Value *val) {
    fr_Array *a = (fr_Array*)fr_getPtr(self, array);
    //TODO
    val->o = ((FObj**)(a->data))[index];
}
void fr_arraySet(fr_Env self, fr_Obj array, size_t index, fr_Value *val) {
    fr_Array *a = (fr_Array*)fr_getPtr(self, array);
    //TODO
    ((FObj**)(a->data))[index] = (FObj*)val->o;
}

////////////////////////////
// call
////////////////////////////
fr_Method fr_findMethod(fr_Env self, fr_Type type, const char *name) {
    return fr_findMethodN(self, type, name, -1);
}
fr_Method fr_findMethodN(fr_Env self, fr_Type type, const char *name, int paramCount) {
    //Env *e = (Env*)self;
    //FMethod *m = e->podManager->findMethodInType(e, (FType*)type, name, paramCount);
    
    for (int i=0; i<type->methodCount; ++i) {
        fr_Method method = type->methodList+i;
        if (strcmp(method->name, name) ==0 && (method->paramsCount == paramCount || paramCount == -1 )) {
            return method;
        }
    }
    //TODO find in base type
    return NULL;
}

fr_Value fr_callMethodV(fr_Env self, fr_Method method, int argCount, va_list args) {
    fr_Value valueArgs[10] = {0};
    fr_Value ret;
    for(int i=0; i<argCount; i++) {
        int paramIndex = i;
        if ((method->flags & FFlags_Static) == 0) {
            --paramIndex;
        }
        if (paramIndex == -1) {
            valueArgs[i].i = va_arg(args, int64_t);
            continue;
        }
        
        if (strcmp(method->paramsList[paramIndex].type, "sys_Bool") == 0) {
            valueArgs[i].b = va_arg(args, int);
        }
        else {
            valueArgs[i].i = va_arg(args, int64_t);
        }
    }
    ret.i = 0;
    fr_callMethodA(self, method, argCount, valueArgs, &ret);
    return ret;
}

fr_Value fr_callMethod(fr_Env self, fr_Method method, int argCount, ...) {
    va_list args;
    fr_Value ret;
    va_start(args, argCount);
    ret = fr_callMethodV(self, method, argCount, args);
    va_end(args);
    return ret;
}

void fr_callMethodA(fr_Env self, fr_Method method, int argCount, fr_Value *arg, fr_Value *ret) {
    //TODO
//    Env *e = (Env*)self;
//    int paramCount = pushArg(self, method, argCount, arg);
//
//    FMethod *f = (FMethod*)method;
//    if (f->flags & FFlags::Virtual || f->flags & FFlags::Abstract) {
//        e->callVirtual(f, paramCount);
//    }
//    else {
//        e->callNonVirtual(f, paramCount);
//    }
//    popRet(e, (FMethod*)method, ret);
    
    if (method->flags & FFlags_Virtual || method->flags & FFlags_Abstract) {
        fr_Type type = fr_getObjType(self, arg[0].h);
        fr_Method realMethod = fr_findMethod(self, type, method->name);
        if (!realMethod) {
            return;
        }
        fr_callNonVirtual(self, realMethod, argCount, arg, ret);
    }
    else {
        fr_callNonVirtual(self, method, argCount, arg, ret);
    }
}

void fr_callNonVirtual(fr_Env self, fr_Method method
                       , int argCount, fr_Value *arg, fr_Value *ret) {
    method->func(self, arg, ret);
}

fr_Value fr_newObjV(fr_Env self, fr_Type type, fr_Method method, int argCount, va_list args) {
    fr_Value valueArgs[10] = {0};
    fr_Value ret;
    for(int i=0; i<argCount; i++) {
        int paramIndex = i;
        if ((method->flags & FFlags_Static) == 0) {
            --paramIndex;
        }
        if (paramIndex == -1) {
            valueArgs[i].i = va_arg(args, int64_t);
            continue;
        }
        
        if (strcmp(method->paramsList[paramIndex].type, "sys_Bool") == 0) {
            valueArgs[i].b = va_arg(args, int);
        }
        else {
            valueArgs[i].i = va_arg(args, int64_t);
        }
    }
    ret.i = 0;
    fr_newObjA(self, type, method, argCount, valueArgs, &ret);
    return ret;
}
fr_Value fr_newObj(fr_Env self, fr_Type type, fr_Method method, int argCount, ...) {
    va_list args;
    fr_Value ret;
    va_start(args, argCount);
    ret = fr_newObjV(self, type, method, argCount, args);
    va_end(args);
    return ret;
}
void fr_newObjA(fr_Env self, fr_Type type, fr_Method method
               , int argCount, fr_Value *arg, fr_Value *ret) {
    fr_Obj obj = fr_alloc(self, type, -1);
    
    fr_Value newArgs[10];
    newArgs[0].h = obj;
    for (int i=0; i<argCount; ++i) {
        newArgs[i+1] = arg[i];
    }
    
    method->func(self, newArgs, ret);
    ret->h = obj;
}

fr_Value fr_newObjS(fr_Env self, const char *pod, const char *type, const char *name
                     , int argCount, ...) {
    va_list args;
    fr_Value ret;
    va_start(args, argCount);
    
    fr_Type ftype = fr_findType(self, pod, type);
    fr_Method m = fr_findMethod(self, ftype, name);
    
    ret = fr_newObjV(self, ftype, m, argCount, args);
    va_end(args);
    return ret;
}

fr_Value fr_callOnObj(fr_Env self, const char *name
                         , int argCount, ...) {
    va_list args;
    fr_Value ret;
    va_start(args, argCount);
    fr_Obj obj = va_arg(args, fr_Obj);
    va_start(args, argCount);
    
    fr_Type ftype = fr_getObjType(self, obj);
    fr_Method m = fr_findMethod(self, ftype, name);
    
    ret = fr_callMethodV(self, m, argCount, args);
    va_end(args);
    return ret;
}

fr_Value fr_callMethodS(fr_Env self, const char *pod, const char *type, const char *name
                        , int argCount, ...) {
    va_list args;
    fr_Value ret;
    va_start(args, argCount);
    
    fr_Type ftype = fr_findType(self, pod, type);
    fr_Method m = fr_findMethod(self, ftype, name);
    
    ret = fr_callMethodV(self, m, argCount, args);
    va_end(args);
    return ret;
}

////////////////////////////
// Field
////////////////////////////

fr_Field fr_findField(fr_Env self, fr_Type type, const char *name) {
    //Env *e = (Env*)self;
    
    for (int i=0; i<type->fieldCount; ++i) {
        fr_Field field = type->fieldList+i;
        if (strcmp(field->name, name) == 0) {
            return field;
        }
    }
    return NULL;
}

void fr_setStaticField(fr_Env self, fr_Type type, fr_Field field, fr_Value *arg) {
    if (strcmp(field->type, "sys::Bool") == 0) {
        fr_Bool *addr = ((fr_Bool*)field->pointer);
        *addr = arg->b;
        return;
    }
    fr_Int *addr = ((fr_Int*)field->pointer);
    *addr = arg->i;
}

bool fr_getStaticField(fr_Env self, fr_Type type, fr_Field field, fr_Value *val) {
    if (strcmp(field->type, "sys::Bool") == 0) {
        fr_Bool *addr = ((fr_Bool*)field->pointer);
        val->b = *addr;
        return true;
    }
    val->i = *((fr_Int*)field->pointer);
    return true;
}
void fr_setInstanceField(fr_Env self, fr_Value *bottom, fr_Field field, fr_Value *arg) {
    //Env *e = (Env*)self;
    char *v = ((char*)bottom->p) + field->offset;
    *((uint64_t*)v) = arg->i;
}
bool fr_getInstanceField(fr_Env self, fr_Value *bottom, fr_Field field, fr_Value *val) {
    //Env *e = (Env*)self;
    char *v = ((char*)bottom->p) + field->offset;
    val->i = *((uint64_t*)v);
    return true;
}


void fr_setStaticFieldS(fr_Env self, const char *pod, const char *typeName, const char *name, fr_Value *val) {
    //Env *e = (Env*)self;
    fr_Type type = fr_findType(self, pod, typeName);
    fr_Field field = fr_findField(self, type, name);
    fr_setStaticField(self, type, field, val);
}
bool fr_getStaticFieldS(fr_Env self, const char *pod, const char *typeName, const char *name, fr_Value *val) {
    //Env *e = (Env*)self;
    fr_Type type = fr_findType(self, pod, typeName);
    fr_Field field = fr_findField(self, type, name);
    bool rc = fr_getStaticField(self, type, field, val);
    return rc;
}
void fr_setFieldS(fr_Env self, fr_Value *bottom, const char *name, fr_Value *val) {
    //Env *e = (Env*)self;
    fr_Type type = fr_getObjType(self, bottom->h);;
    fr_Field field = fr_findField(self, type, name);
    fr_setInstanceField(self, bottom, field, val);
}
bool fr_getFieldS(fr_Env self, fr_Value *bottom, const char *name, fr_Value *val) {
    //Env *e = (Env*)self;
    fr_Type type = fr_getObjType(self, bottom->h);
    fr_Field field = fr_findField(self, type, name);
    int rc = fr_getInstanceField(self, bottom, field, val);
    return rc;
}

////////////////////////////
// exception
////////////////////////////

fr_Obj fr_getErr(fr_Env self) {
    Env *e = (Env*)self;
    fr_Err obj = e->error;
    return (fr_Obj)obj;
}

bool fr_errOccurred(fr_Env self) {
    Env *e = (Env*)self;
    bool oc;
    //e->lock();
    oc = e->error != NULL;
    //e->unlock();
    return oc;
}
//
//void fr_printErr(fr_Env self, fr_Obj err) {
//    Env *e = (Env*)self;
//    e->printError(fr_getPtr(self, err));
//}
//
//void fr_throw(fr_Env self, fr_Obj err) {
//    Env *e = (Env*)self;
//    //fr_lock(self);
//    e->throwError(fr_getPtr(self, err));
//    //fr_unlock(self);
//}
//
void fr_clearErr(fr_Env self) {
    self->error = NULL;
}

void fr_throwNew(fr_Env self, const char *pod, const char *type, const char *msg) {
    Env *e = (Env*)self;
    //e->lock();
    //e->throwNew(pod, type, msg, 2);
    //e->unlock();
    //TODO;
}
//
//void fr_throwNPE(fr_Env self) {
//    Env *e = (Env*)self;
//    //e->lock();
//    e->throwNPE();
//    //e->unlock();
//}
//
//void fr_throwUnsupported(fr_Env self) {
//    fr_throwNew(self, "sys", "UnsupportedErr", "unsupported");
//}
//
//void fr_stackTrace(fr_Env self, char *buf, int size, const char *delimiter) {
//    Env *e = (Env*)self;
//    e->stackTrace(buf, size, delimiter);
//}

////////////////////////////
// box
////////////////////////////
//
fr_Obj fr_box(fr_Env env, fr_Value *value, fr_ValueType vtype) {
    fr_Obj res = value->h;
    if (vtype == fr_vtBool) {
        res = fr_box_bool(env, value->b);
    }
    else if (vtype == fr_vtInt) {
        res = fr_box_int(env, value->i);
    }
    else if (vtype == fr_vtFloat) {
        res = fr_box_float(env, value->f);
    }
    return res;
}
bool fr_unbox(fr_Env env, fr_Obj obj, fr_Value *value) {
    
    fr_Type type = fr_getObjType(env, obj);
    if (strcmp(type->name, "sys::Bool") == 0) {
        fr_Bool *v = (fr_Bool*)fr_getPtr(env, obj);
        value->b = *v;
    }
    else if (strcmp(type->name, "sys::Int") == 0) {
        fr_Int *v = (fr_Int*)fr_getPtr(env, obj);
        value->i = *v;
    }
    else if (strcmp(type->name, "sys::Float") == 0) {
        fr_Float *v = (fr_Float*)fr_getPtr(env, obj);
        value->f = *v;
    }
    else {
        return false;
    }
    return true;
}

////////////////////////////
// Str
////////////////////////////


fr_Obj fr_handleToStr(fr_Env env, fr_Obj x) {
    fr_Obj str;
    if (!x) {
        return fr_newStrUtf8(env, "null");
    }
    // if it is primitive type must be unbox before call it's method.
    fr_Value val;
    val.h = x;
    fr_unbox(env, x, &val);

    fr_Value rVal;
    fr_Type type = fr_getObjType(env, x);

    fr_Method method = fr_findMethod(env, type, "toStr");

    fr_callMethodA(env, method, 1, &val, &rVal);

    str = rVal.h;
    return str;
}

fr_Obj fr_objToStr(fr_Env self, fr_Value obj, fr_ValueType vtype) {
//    Env *e = (Env*)self;

    if (vtype != fr_vtHandle) {
        //TODO op
        if (vtype == fr_vtObj) {
            obj.h = fr_toHandle(self, (FObj*)obj.o);
        } else {
            obj.h = fr_box(self, &obj, vtype);
        }
    }
    return fr_handleToStr(self, obj.h);
}
