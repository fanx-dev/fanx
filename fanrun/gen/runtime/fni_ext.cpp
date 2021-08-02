//
//  fni.cpp
//  vm
//
//  Created by yangjiandong on 15/9/27.
//  Copyright (c) 2015, yangjiandong. All rights reserved.
//

#include "fni_ext.h"
#include "Env.hpp"
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
    fr_Value* tval = (fr_Value*)param;    
    *val = tval[pos];
    if (vtype) *vtype = fr_vtOther;
    return true;
}


////////////////////////////
// GC
////////////////////////////

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

////////////////////////////
// call
////////////////////////////

fr_Method fr_findMethodN(fr_Env self, fr_Type type, const char *name, int paramCount) {
    
    for (int i=0; i<type->methodCount; ++i) {
        fr_Method method = type->methodList+i;
        if (strcmp(method->name, name) ==0 && (method->paramsCount == paramCount || paramCount == -1 )) {
            return method;
        }
    }

    //find in base class
    fr_Type base = type->base;
    if (base) {
        return fr_findMethodN(self, base, name, paramCount);
    }
    return NULL;
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

void fr_setStaticField(fr_Env self, fr_Field field, fr_Value *arg) {
    if (strcmp(field->type, "sys::Bool") == 0) {
        fr_Bool *addr = ((fr_Bool*)field->pointer);
        *addr = arg->b;
        return;
    }
    fr_Int *addr = ((fr_Int*)field->pointer);
    *addr = arg->i;
}

bool fr_getStaticField(fr_Env self, fr_Field field, fr_Value *val) {
    if (strcmp(field->type, "sys::Bool") == 0) {
        fr_Bool *addr = ((fr_Bool*)field->pointer);
        val->b = *addr;
        return true;
    }
    val->i = *((fr_Int*)field->pointer);
    return true;
}
void fr_setInstanceField(fr_Env self, fr_Obj bottom, fr_Field field, fr_Value *arg) {
    //Env *e = (Env*)self;
    char *v = ((char*)fr_getPtr(self, bottom)) + field->offset;
    *((uint64_t*)v) = arg->i;
}
bool fr_getInstanceField(fr_Env self, fr_Obj bottom, fr_Field field, fr_Value *val) {
    //Env *e = (Env*)self;
    char *v = ((char*)fr_getPtr(self, bottom)) + field->offset;
    val->i = *((uint64_t*)v);
    return true;
}

////////////////////////////
// exception
////////////////////////////

fr_Obj fr_getErr(fr_Env self) {
    Env *e = (Env*)self;
    fr_Err obj = e->error;
    return (fr_Obj)obj;
}

void fr_throw(fr_Env self, fr_Obj err) {
    fr_setErr(self, err);
}

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
fr_ValueType fr_unbox(fr_Env env, fr_Obj obj, fr_Value *value) {
    
    fr_Type type = fr_getObjType(env, obj);
    if (strcmp(type->name, "sys::Bool") == 0) {
        fr_Bool *v = (fr_Bool*)fr_getPtr(env, obj);
        value->b = *v;
        return fr_vtBool;
    }
    else if (strcmp(type->name, "sys::Int") == 0) {
        fr_Int *v = (fr_Int*)fr_getPtr(env, obj);
        value->i = *v;
        return fr_vtInt;
    }
    else if (strcmp(type->name, "sys::Float") == 0) {
        fr_Float *v = (fr_Float*)fr_getPtr(env, obj);
        value->f = *v;
        return fr_vtFloat;
    }
    else {
        value->h = obj;
        return fr_vtHandle;
    }
}

