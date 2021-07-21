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
    return (fr_Env)v->getEnv();
}

void fr_releaseEnv(fr_Fvm vm, fr_Env env) {
    Fvm *v = (Fvm*)vm;
    v->releaseEnv((Env*)env);
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
    return *reinterpret_cast<FObj**>(obj);
}

fr_Obj fr_toHandle(fr_Env self, FObj *obj) {
    if (obj == NULL) return NULL;
    Env *e = (Env*)self;
    fr_Obj objRef;
    
    //fr_lock(self);
    if (e->curFrame) {
        objRef = e->newLocalRef(obj);
    } else {
        //objRef = reinterpret_cast<fr_Obj>(obj);
        assert("ERROR: get handle from no native method");
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
        *vtype = fr_vtHandle;
    } else {
        *val = tval->any;
        *vtype = tval->type;
    }
    return true;
}

////////////////////////////
// Type
////////////////////////////

int fr_getFuncArity(fr_Env env, fr_Type clz) {
    return 0;
}

struct FType *fr_getFType(fr_Env self, FObj *obj) {
    return (struct FType *)gc_getType(fr_toGcObj(obj));
}
//struct FType *fr_toFType(fr_Env self, FObj *obj);
const char *fr_getTypeName(fr_Env self, FObj *obj) {
    return fr_getFType(self, obj)->c_name.c_str();
}

////////////////////////////
// GC
////////////////////////////

void fr_yieldGc(fr_Env self) {
    Env *e = (Env*)self;
    e->checkSafePoint();
}
void fr_allowGc(fr_Env self) {
//    Env *e = (Env*)self;
    //TODO fr_allowGc GC
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
    return (FType*)otype;
}


fr_Obj fr_allocObj(fr_Env self, fr_Type type, int size) {
    Env *e = (Env*)self;
    //e->lock();
    FType *ftype = fr_toFType(self, type);
    FObj *obj = e->allocObj(ftype, 2, size);
    fr_Obj objRef = fr_toHandle(self, obj);
    //e->unlock();
    return objRef;
}

FObj *fr_allocObj_internal(fr_Env self, fr_Type type, int size) {
    Env *e = (Env*)self;
    FType *ftype = fr_toFType(self, type);
    FObj *obj = e->allocObj(ftype, 2, size);
    return obj;
}

void fr_gc(fr_Env self) {
    Env *e = (Env*)self;
    e->gc();
}

////////////////////////////
// Type
////////////////////////////

fr_Type fr_findType(fr_Env self, const char *pod, const char *type) {
    Env *e = (Env*)self;
    //e->lock();
    FType *t = e->findType(pod, type);
    //e->unlock();
    //return fr_getTypeObj(self, t);
    return (fr_Type)t;
}
fr_Type fr_toType(fr_Env self, fr_ValueType vt) {
    Env *e = (Env*)self;
    //e->lock();
    FType *t = e->toType(vt);
    //e->unlock();
    //return fr_getTypeObj(self, t);
    return (fr_Type)t;
}

bool fr_fitType(fr_Env self, fr_Type a, fr_Type b) {
    Env *e = (Env*)self;
    
    //FObj *typeObj = fr_getPtr(self, a);
    //FType *ftype = e->podManager->getFType(e, typeObj);
    
    //FObj *typeObj2 = fr_getPtr(self, b);
    //FType *ftype2 = e->podManager->getFType(e, typeObj2);
    return e->fitType((FType*)a, (FType*)b);
}

fr_Type fr_getInstanceType(fr_Env self, fr_Value *obj, fr_ValueType vtype) {
    Env *e = (Env*)self;
    fr_TagValue val;
    val.type = vtype;
    //val.any = *obj;
    //e->lock();
    val.any.o = fr_getPtr(self, obj->h);
    FType *t = e->getInstanceType(&val);
    //e->unlock();
    
    //return fr_getTypeObj(self, t);
    return (fr_Type)t;
}
fr_Type fr_getObjType(fr_Env self, fr_Obj obj) {
    if (obj == 0) {
        return 0;
    }
    //fr_lock(self);
    FObj *o = fr_getPtr(self, obj);
    FType *type = (FType*)gc_getType(fr_toGcObj(o));
    //fr_unlock(self);
    
    //return fr_getTypeObj(self, type);
    return (fr_Type)type;
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

fr_Obj fr_arrayNew(fr_Env self, fr_Type type, int32_t elemSize, size_t size) {
    Env *env = (Env*)self;
    fr_Array *a = env->arrayNew(fr_toFType(self, type), elemSize, size);
    return fr_toHandle(self, (FObj*)a);
}

size_t fr_arrayLen(fr_Env self, fr_Obj array) {
    fr_Array *a = (fr_Array*)fr_getPtr(self, array);
    return a->size;
}
void fr_arrayGet(fr_Env self, fr_Obj array, size_t index, fr_Value *val) {
    fr_Array *a = (fr_Array*)fr_getPtr(self, array);
    Env *e = (Env*)self;
    e->arrayGet(a, index, val);
    
    fr_ValueType vt = (fr_ValueType)a->valueType;
    if (vt == fr_vtObj) {
        val->h = fr_toHandle(self, (FObj*)val->o);
    }
}
void fr_arraySet(fr_Env self, fr_Obj array, size_t index, fr_Value *val) {
    fr_Array *a = (fr_Array*)fr_getPtr(self, array);
    Env *e = (Env*)self;
    
    fr_ValueType vt = (fr_ValueType)a->valueType;
    if (vt == fr_vtObj) {
        val->o = fr_getPtr(self, val->h);
    }
    e->arraySet(a, index, val);
}

////////////////////////////
// call
////////////////////////////

fr_Method fr_findMethodN(fr_Env self, fr_Type type, const char *name, int paramCount) {
    Env *e = (Env*)self;
    FMethod *m = e->podManager->findMethodInType(e, (FType*)type, name, paramCount);
    return (fr_Method)m;
}

static int pushArg(fr_Env self, fr_Method method, int argCount, fr_Value *arg) {
    Env *e = (Env*)self;
    FMethod *fmethod = (FMethod*)method;
    bool isInstanceM = (((FMethod*)method)->flags & FFlags::Static) == 0 && (((FMethod*)method)->flags & FFlags::Ctor) == 0;
    
    for (int i=0; i<argCount; ++i) {
        fr_Value *param = arg + i;
        fr_TagValue val;
        val.any = *param;
        
        if (isInstanceM) {
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
    
    if (method && isInstanceM) {
        --argCount;
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
fr_Value fr_callMethodV(fr_Env self, fr_Method method, int argCount, va_list args) {
    fr_Value valueArgs[10] = {0};
    fr_Value ret;
    for(int i=0; i<argCount; i++) {
        FMethod *f = (FMethod*)method;
        int paramIndex = i;
        if ((f->flags & FFlags::Static) == 0) {
            --paramIndex;
        }
        if (paramIndex == -1) {
            valueArgs[i].i = va_arg(args, int64_t);
            continue;
        }
        
        std::string type = f->c_parent->c_pod->names[f->vars[paramIndex].type];
        if (type == "sys_Bool") {
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

void fr_callMethodA(fr_Env self, fr_Method method, int argCount, fr_Value *arg, fr_Value *ret) {
    //TODO
    Env *e = (Env*)self;
    int paramCount = pushArg(self, method, argCount, arg);
    
    FMethod *f = (FMethod*)method;
    if (f->flags & FFlags::Virtual || f->flags & FFlags::Abstract) {
        e->callVirtual(f, paramCount);
    }
    else {
        e->callNonVirtual(f, paramCount);
    }
    popRet(e, (FMethod*)method, ret);
}

void fr_callNonVirtual(fr_Env self, fr_Method method
                       , int argCount, fr_Value *arg, fr_Value *ret) {
    Env *e = (Env*)self;
    argCount = pushArg(self, method, argCount, arg);
    e->callNonVirtual((FMethod*)method, argCount);
    
    popRet(e, (FMethod*)method, ret);
}
fr_Value fr_newObjV(fr_Env self, fr_Type type, fr_Method method, int argCount, va_list args) {
    fr_Value valueArgs[10] = {0};
    fr_Value ret;
    for(int i=0; i<argCount; i++) {
        FMethod *f = (FMethod*)method;
        int paramIndex = i;
        if ((f->flags & FFlags::Static) == 0) {
            --paramIndex;
        }
        if (paramIndex == -1) {
            valueArgs[i].i = va_arg(args, int64_t);
            continue;
        }
        
        std::string type = f->c_parent->c_pod->names[f->vars[paramIndex].type];
        if (type == "sys_Bool") {
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

void fr_newObjA(fr_Env self, fr_Type type, fr_Method method
               , int argCount, fr_Value *arg, fr_Value *ret) {
    Env *e = (Env*)self;
    argCount = pushArg(self, method, argCount, arg);
    e->newObj((FType *)type, (FMethod*)method, argCount);
    
    popRet(e, (FMethod*)method, ret);
}

////////////////////////////
// Field
////////////////////////////

fr_Field fr_findField(fr_Env self, fr_Type type, const char *name) {
    Env *e = (Env*)self;
    return (fr_Field)e->podManager->findFieldInType(e, (FType*)type, name);
}

void fr_setStaticField(fr_Env self, fr_Type type, fr_Field field, fr_Value *arg) {
    Env *e = (Env*)self;
    //e->lock();
    fr_Value val;
    fr_ValueType vtype = e->podManager->getValueType(e, ((FField*)field)->c_parent->c_pod, ((FField*)field)->type);
    if (vtype == fr_vtObj) {
        val.o = fr_getPtr(self, arg->h);
    } else {
        val = *arg;
    }
    e->setStaticField((FField*)field, &val);
    //e->unlock();
}
bool fr_getStaticField(fr_Env self, fr_Type type, fr_Field field, fr_Value *val) {
    Env *e = (Env*)self;
    //e->lock();
    FField *ffield = (FField*)field;
    bool rc = e->getStaticField(ffield, val);
    fr_ValueType vtype = e->podManager->getValueType(e, ffield->c_parent->c_pod, ffield->type);
    if (val && vtype == fr_vtObj) {
        val->h = fr_toHandle(self, (FObj*)val->o);
    }
    //e->unlock();
    return rc;
}
void fr_setInstanceField(fr_Env self, fr_Value *bottom, fr_Field field, fr_Value *arg) {
    Env *e = (Env*)self;
    //e->lock();
    fr_Value val;
    fr_ValueType vtype = e->podManager->getValueType(e, ((FField*)field)->c_parent->c_pod, ((FField*)field)->type);
    if (vtype == fr_vtObj) {
        val.o = fr_getPtr(self, arg->h);
    } else {
        val = *arg;
    }
    e->setInstanceField(*bottom, (FField *)field, &val);
    //e->unlock();
}
bool fr_getInstanceField(fr_Env self, fr_Value *bottom, fr_Field field, fr_Value *val) {
    Env *e = (Env*)self;
    //e->lock();
    FField *ffield = (FField*)field;
    bool rc = e->getInstanceField(*bottom, (FField *)field, val);
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

bool fr_errOccurred(fr_Env self) {
    Env *e = (Env*)self;
    bool oc;
    //e->lock();
    oc = e->getError() != NULL;
    //e->unlock();
    return oc;
}

void fr_printErr(fr_Env self, fr_Obj err) {
    Env *e = (Env*)self;
    e->printError(fr_getPtr(self, err));
}

void fr_throw(fr_Env self, fr_Obj err) {
    Env *e = (Env*)self;
    //fr_lock(self);
    e->throwError(fr_getPtr(self, err));
    //fr_unlock(self);
}

void fr_clearErr(fr_Env self) {
    Env *e = (Env*)self;
    //fr_lock(self);
    e->clearError();
    //fr_unlock(self);
}

void fr_throwNew(fr_Env self, const char *pod, const char *type, const char *msg) {
    Env *e = (Env*)self;
    //e->lock();
    e->throwNew(pod, type, msg, 2);
    //e->unlock();
}

void fr_throwNPE(fr_Env self) {
    Env *e = (Env*)self;
    //e->lock();
    e->throwNPE();
    //e->unlock();
}

void fr_throwUnsupported(fr_Env self) {
    fr_throwNew(self, "sys", "UnsupportedErr", "unsupported");
}

void fr_stackTrace(fr_Env self, char *buf, int size, const char *delimiter) {
    Env *e = (Env*)self;
    e->stackTrace(buf, size, delimiter);
}

////////////////////////////
// box
////////////////////////////

fr_Obj fr_box(fr_Env self, fr_Value *value, fr_ValueType vtype) {
    Env *e = (Env*)self;
    //e->lock();
    FObj *obj = e->box(*value, vtype);
    fr_Obj objRef = fr_toHandle(self, obj);
    //e->unlock();
    return objRef;
}
bool fr_unbox(fr_Env self, fr_Obj obj, fr_Value *value) {
    Env *e = (Env*)self;
    //e->lock();
    bool ok = e->unbox(fr_getPtr(self, obj), *value);
    //e->unlock();
    if (!ok) {
        value->h = obj;
    }
    return ok;
}

////////////////////////////
// Str
////////////////////////////

fr_Obj fr_newStrUtf8N(fr_Env self, const char *bytes, ssize_t len) {
    Env *e = (Env*)self;
    //e->lock();
    FObj *str = e->podManager->objFactory.newString(e, bytes);
    fr_Obj objRef = fr_toHandle(self, str);
    //e->unlock();
    return objRef;
}

const char *fr_getStrUtf8(fr_Env self, fr_Obj str) {
    Env *e = (Env*)self;
    //e->lock();
    const char *cstr = e->podManager->objFactory.getStrUtf8(e, fr_getPtr(self, str));
    //e->unlock();
//    if (isCopy) {
//        *isCopy = false;
//    }
    return cstr;
}

//void fr_releaseStrUtf8(fr_Env self, fr_Obj str, const char *bytes) {
//    //pass;
//}

GcObj *fr_toGcObj(FObj *obj) {
    if (obj == nullptr) return nullptr;
    GcObj *g = (GcObj*)obj;
    --g;
    return g;
    
}
FObj *fr_fromGcObj(GcObj *g) {
    if (g == nullptr) return nullptr;
    FObj *obj = (FObj*)(++g);
    return obj;
}
