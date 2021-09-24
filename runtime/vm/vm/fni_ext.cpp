//
//  fni.cpp
//  vm
//
//  Created by yangjiandong on 15/9/27.
//  Copyright (c) 2015, yangjiandong. All rights reserved.
//

#include "fni_ext.h"
#include "Env.h"
#include "Vm.h"
#include <assert.h>

////////////////////////////
// VM
////////////////////////////

fr_Env fr_getEnv(fr_Fvm vm) {
    Fvm *v = (Fvm*)vm;
    if (vm == NULL) v = Fvm::getCur();
    return (fr_Env)v->getEnv();
}

fr_Fvm fr_getVm() {
    return Fvm::getCur();
}

void fr_gcQuit() {
    Fvm::getCur()->gc->quit();
}

void fr_releaseEnv(fr_Env env) {
    Env* e = (Env*)env;
    e->vm->releaseEnv(e);
}

void fr_registerMethod(fr_Fvm vm, const char *name, fr_NativeFunc func) {
    Fvm *v = (Fvm*)vm;
    v->registerMethod(name, func);
}

////////////////////////////
// Param
////////////////////////////

FObj *fr_getPtr(fr_Env self, fr_Obj obj) {
    if (obj == 0) return NULL;
    FObj *fobj = *reinterpret_cast<FObj**>(obj);
#ifndef NODEBUG
    Env* e = (Env*)self;
    if (!e->vm->gc->isRef(fr_toGcObj(fobj))) {
        abort();
    }
#endif
    return fobj;
}

fr_Obj fr_toHandle(fr_Env self, FObj *obj) {
    if (obj == NULL) return NULL;
    Env *e = (Env*)self;

#ifndef NODEBUG
    if (!e->vm->gc->isRef(fr_toGcObj(obj))) {
        abort();
    }
#endif

    fr_Obj objRef = NULL;
    
    //fr_lock(self);
    if (e->curFrame) {
        objRef = e->newLocalRef(obj);
    } else {
        //objRef = reinterpret_cast<fr_Obj>(obj);
        printf("ERROR: get handle from no native method\n");
        abort();
    }
    //fr_unlock(self);
    return objRef;
}

bool fr_getParam(fr_Env env, void *param, fr_Value *val, int pos, fr_ValueType *vtype) {
    Env *e = (Env*)env;
    //e->lock();
    fr_TagValue *tval = (fr_TagValue *)param;
    tval += pos;
    if ((char*)tval >= e->stackTop) {
        return false;
    }
    if (tval->type == fr_vtObj) {
        val->h = &(tval->any.o);
        if (vtype) *vtype = fr_vtHandle;
    } else {
        *val = tval->any;
        if (vtype) *vtype = tval->type;
    }
    return true;
}

////////////////////////////
// Type
////////////////////////////

struct FType *fr_getFType(fr_Env self, FObj *obj) {
    return (struct FType *)gc_getType(fr_toGcObj(obj));
}

////////////////////////////
// GC
////////////////////////////

void fr_checkPoint(fr_Env self) {
    Env *e = (Env*)self;
    e->checkSafePoint();
}
void fr_allowGc(fr_Env self) {
    Env *env = (Env*)self;
    env->isStoped = true;
}
void fr_endAllowGc(fr_Env self) {
    Env *env = (Env*)self;
    env->isStoped = false;
    fr_checkPoint(self);
}

fr_Obj fr_newLocalRef(fr_Env self, fr_Obj obj) {
    Env *e = (Env*)self;
    //fr_lock(self);
    obj = e->newLocalRef(fr_getPtr(self, obj));
    //fr_unlock(self);
    return obj;
}

void fr_deleteLocalRef(fr_Env self, fr_Obj obj) {
    //Env *e = (Env*)self;
    //fr_lock(self);
    FObj **fobj = reinterpret_cast<FObj **>(obj);
    *fobj = nullptr;
    //e->removeLocalRef(fr_getPtr(self, obj));
    //fr_unlock(self);
}

fr_Obj fr_newGlobalRef(fr_Env self, fr_Obj obj) {
    Env *e = (Env*)self;
    //fr_lock(self);
    obj = e->newGlobalRef(fr_getPtr(self, obj));
    //fr_unlock(self);
    return obj;
}

void fr_deleteGlobalRef(fr_Env self, fr_Obj obj) {
    Env *e = (Env*)self;
    //fr_lock(self);
    e->deleteGlobalRef(obj);
    //fr_unlock(self);
}

FType *fr_toFType(fr_Env self, fr_Type otype) {
    //Env *e = (Env*)self;
    //FObj *typeObj = fr_getPtr(self, otype);
    //FType *ftype = e->podManager->getFType(e, typeObj);
    return (FType*)otype->internalType;
}


fr_Obj fr_allocObj(fr_Env self, fr_Type type, int size) {
    Env *e = (Env*)self;
    //e->lock();
    FType *ftype = fr_toFType(self, type);
    FObj *obj = fr_allocObj_(e, ftype, size);
    fr_Obj objRef = fr_toHandle(self, obj);
    //e->unlock();
    return objRef;
}

void fr_gc(fr_Env self) {
    Env *e = (Env*)self;
    e->vm->gc->collect();
}

void fr_setGcDirty(fr_Env self, FObj *obj) {
    if (obj == NULL) return;
    Env* e = (Env*)self;
    e->vm->gc->setDirty(fr_toGcObj((FObj*)obj));
}
////////////////////////////
// Type
////////////////////////////

fr_Type fr_findType(fr_Env self, const char *pod, const char *type) {
    Env *e = (Env*)self;
    //e->lock();
    FType *t = e->findType(pod, type);
    if (t == NULL) {
        printf("type not found: %s::%s\n", pod, type);
        return NULL;
    }
    //e->unlock();
    //return fr_getTypeObj(self, t);
    return fr_fromFType(self, t);
}

/*bool fr_fitType(fr_Env self, fr_Type a, fr_Type b) {
    Env *e = (Env*)self;
    
    //FObj *typeObj = fr_getPtr(self, a);
    //FType *ftype = e->podManager->getFType(e, typeObj);
    
    //FObj *typeObj2 = fr_getPtr(self, b);
    //FType *ftype2 = e->podManager->getFType(e, typeObj2);
    return e->fitType(fr_toFType(self, a), fr_toFType(self, b));
}*/

fr_Type fr_getObjType(fr_Env self, fr_Obj obj) {
    //fr_lock(self);
    FObj *o = fr_getPtr(self, obj);
    if (o == 0) {
        return 0;
    }
    FType *type = (FType*)gc_getType(fr_toGcObj(o));
    //fr_unlock(self);
    
    //return fr_getTypeObj(self, type);
    return fr_fromFType(self, type);
}

////////////////////////////
// Array
////////////////////////////

fr_Obj fr_arrayNew(fr_Env self, fr_Type type, int32_t elemSize, size_t size) {
    Env *env = (Env*)self;
    fr_Array *a = fr_arrayNew_(env, fr_toFType(self, type), elemSize, size);
    return fr_toHandle(self, (FObj*)a);
}


////////////////////////////
// call
////////////////////////////

fr_Method fr_findMethodN(fr_Env self, fr_Type type, const char *name, int paramCount) {
    Env *e = (Env*)self;
    FMethod *m = e->podManager->findMethodInType(e, (FType*)type->internalType, name, paramCount, false);
    if (!m) return NULL;
    return (fr_Method)m->c_reflectSlot;
}

static int pushArg(fr_Env self, fr_Method method, int argCount, fr_Value *arg) {
    Env *e = (Env*)self;
    FMethod *fmethod = (FMethod*)method->internalSlot;
    bool isStatic = (fmethod->flags & FFlags::Static) != 0;
    
    for (int i=0; i<argCount; ++i) {
        fr_Value *param = arg + i;
        fr_TagValue val;
        val.any = *param;
        
        if (!isStatic) {
            if (i == 0) {
                val.type = e->podManager->getValueTypeByType(e, fmethod->c_parent);
            } else {
                //int j = i-1;
                FMethodVar &var = fmethod->vars[i-1];
                val.type = e->podManager->getValueType(e, fmethod->c_parent->c_pod, var.type);
            }
        } else {
        
            FMethodVar &var = fmethod->vars[i];
            val.type = e->podManager->getValueType(e, fmethod->c_parent->c_pod, var.type);
        }
        
        if (val.type == fr_vtObj) {
            val.any.o = fr_getPtr(self, val.any.h);
        }
        //fr_toObj(self, param);
        e->push(&val);
    }
    
    if (method && (!isStatic)) {
        --argCount;
        if (argCount < 0) {
            abort();
        }
    }
    return argCount;
}

static void popRet(Env *context, FMethod *method, fr_Value *ret) {
    //context->lock();
    FPod *curPod = method->c_parent->c_pod;
    FType *reType = context->podManager->getType(context, curPod, method->returnType);
    if ((method->flags & FFlags::Ctor) || !context->podManager->isVoidType(context, reType)) {
        fr_TagValue val;
        context->pop(&val);
        if (ret) {
            if (val.type == fr_vtObj) {
                ret->h = fr_toHandle((fr_Env)context, (FObj*)val.any.o);
            } else {
                *ret = val.any;
            }
        }
    }
    //context->unlock();
}

void fr_callVirtual(fr_Env self, fr_Method method, int argCount, fr_Value *arg, fr_Value *ret) {
    Env *e = (Env*)self;
    int paramCount = pushArg(self, method, argCount, arg);
    
    FMethod *f = (FMethod*)method->internalSlot;
    e->callVirtual(f, paramCount);
    popRet(e, f, ret);
}

void fr_callNonVirtual(fr_Env self, fr_Method method
                       , int argCount, fr_Value *arg, fr_Value *ret) {
    Env *e = (Env*)self;
    FMethod *f = (FMethod*)method->internalSlot;
    int paramCount = pushArg(self, method, argCount, arg);
    e->callNonVirtual(f, paramCount);
    
    popRet(e, f, ret);
}

////////////////////////////
// Field
////////////////////////////

fr_Field fr_findField(fr_Env self, fr_Type type, const char *name) {
    Env *e = (Env*)self;
    FField *ff = e->podManager->findFieldInType(e, (FType*)type->internalType, name);
    if (!ff) return NULL;
    return (fr_Field)ff->c_reflectSlot;
}

void fr_setStaticField(fr_Env self, fr_Field field, fr_Value *arg) {
    Env *e = (Env*)self;
    FField *ff = (FField*)field->internalSlot;
    //e->lock();
    fr_Value val;
    fr_ValueType vtype = e->podManager->getValueType(e, ff->c_parent->c_pod, ff->type);
    if (vtype == fr_vtObj) {
        val.o = fr_getPtr(self, arg->h);
    } else {
        val = *arg;
    }
    e->setStaticField(ff, &val);
    //e->unlock();
}
bool fr_getStaticField(fr_Env self, fr_Field field, fr_Value *val) {
    Env *e = (Env*)self;
    //e->lock();
    FField *ffield = (FField*)field->internalSlot;
    bool rc = e->getStaticField(ffield, val);
    fr_ValueType vtype = e->podManager->getValueType(e, ffield->c_parent->c_pod, ffield->type);
    if (val && vtype == fr_vtObj) {
        val->h = fr_toHandle(self, (FObj*)val->o);
    }
    //e->unlock();
    return rc;
}
void fr_setInstanceField(fr_Env self, fr_Obj bottom, fr_Field field, fr_Value *arg) {
    Env *e = (Env*)self;
    FField *ff = (FField*)field->internalSlot;
    //e->lock();
    fr_Value val;
    fr_ValueType vtype = e->podManager->getValueType(e, ff->c_parent->c_pod, ff->type);
    if (vtype == fr_vtObj) {
        val.o = fr_getPtr(self, arg->h);
    } else {
        val = *arg;
    }
    e->setInstanceField(fr_getPtr(self, bottom), ff, &val);
    //e->unlock();
}
bool fr_getInstanceField(fr_Env self, fr_Obj bottom, fr_Field field, fr_Value *val) {
    Env *e = (Env*)self;
    //e->lock();
    FField *ffield = (FField*)field->internalSlot;
    bool rc = e->getInstanceField(fr_getPtr(self, bottom), ffield, val);
    fr_ValueType vtype = e->podManager->getValueType(e, ffield->c_parent->c_pod, ffield->type);
    if (val && vtype == fr_vtObj) {
        val->h = fr_toHandle(self, (FObj*)val->o);
    }
    //e->unlock();
    return rc;
}

////////////////////////////
// exception
////////////////////////////

fr_Obj fr_getErr(fr_Env self) {
    Env *e = (Env*)self;
    //e->lock();
    FObj *obj = e->getError();
    fr_Obj objRef = fr_toHandle(self, obj);
    //e->unlock();
    return objRef;
}

void fr_throw(fr_Env self, fr_Obj err) {
    Env *e = (Env*)self;
    //fr_lock(self);
    e->throwError(fr_getPtr(self, err));
    //fr_unlock(self);
}

void fr_stackTrace(fr_Env self, char *buf, int size, const char *delimiter, int skip) {
    Env *e = (Env*)self;
    e->stackTrace(buf, size, delimiter, skip);
}

////////////////////////////
// box
////////////////////////////

fr_Obj fr_box(fr_Env self, fr_Value *value, fr_ValueType vtype) {
    Env *e = (Env*)self;
    //e->lock();
    FObj *obj = fr_box_(e, *value, vtype);
    fr_Obj objRef = fr_toHandle(self, obj);
    //e->unlock();
    return objRef;
}
fr_ValueType fr_unbox(fr_Env self, fr_Obj obj, fr_Value *value) {
    Env *e = (Env*)self;
    //e->lock();
    FObj *fobj = fr_getPtr(self, obj);
    fr_ValueType vt = fr_unbox_(e, fobj, *value);
    if (vt == fr_vtObj && value->o == fobj) {
        value->h = obj;
    }
    //e->unlock();
    return vt;
}

////////////////////////////
// Str
////////////////////////////

fr_Obj fr_newStrUtf8N(fr_Env self, const char *bytes, ssize_t len) {
    Env *e = (Env*)self;
    //e->lock();
    FObj *str = fr_newStrUtf8N_(e, bytes, len);
    fr_Obj objRef = fr_toHandle(self, str);
    //e->unlock();
    return objRef;
}

const char *fr_getStrUtf8(fr_Env self, fr_Obj str) {
    Env *e = (Env*)self;
    //e->lock();
    const char* cstr = fr_getStrUtf8_(e, fr_getPtr(self, str));
    //e->unlock();
//    if (isCopy) {
//        *isCopy = false;
//    }
    return cstr;
}

//void fr_releaseStrUtf8(fr_Env self, fr_Obj str, const char *bytes) {
//    //pass;
//}

