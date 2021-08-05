//
//  ObjFactory.cpp
//  vm
//
//  Created by yangjiandong on 15/10/4.
//  Copyright (c) 2015, yangjiandong. All rights reserved.
//

#include "sys_runtime.h"
#include "Env.h"
//#include "StackFrame.h"

#ifdef  __cplusplus
extern  "C" {
#endif

////////////////////////////////////////////////////////////////
// Alloc
////////////////////////////////////////////////////////////////

FObj* fr_allocObj_(Env* env, FType* type, int size) {
    if (!type) {
        printf("WAIN: allocObj with null type");
        return NULL;
    }
    FType* ftype = type;

    env->podManager->initTypeAllocSize(env, ftype);

    if (ftype->c_allocSize > size) {
        size = ftype->c_allocSize;
    }

    GcObj* obj = (GcObj*)env->vm->gc->alloc(ftype, size + sizeof(struct GcObj_));

    return fr_fromGcObj(obj);
}

////////////////////////////////////////////////////////////////
// Error
////////////////////////////////////////////////////////////////

FObj* fr_makeNPE_(Env *env) {
    FObj* str = fr_newStrUtf8_(env, "null pointer");
    fr_TagValue entry;
    entry.any.o = str;
    entry.type = fr_vtObj;
    env->push(&entry);
    entry.any.o = 0;
    env->push(&entry);

    FType* type = env->podManager->getNpeType(env);
    //FMethod *ctor = type->c_methodMap["make"];
    auto itr = type->c_methodMap.find("make");
    if (itr == type->c_methodMap.end()) {
        abort();
    }
    FMethod* ctor = itr->second;

    env->newObj(type, ctor, 2);
    fr_TagValue error = *env->peek();
    return (FObj*)error.any.o;
}

FObj* fr_makeErr_(Env* env, const char* podName, const char* typeName, const char* msg) {

    FObj* str = fr_newStrUtf8_(env, msg);
    fr_TagValue entry;
    entry.any.o = str;
    entry.type = fr_vtObj;
    env->push(&entry);
    entry.any.o = 0;
    env->push(&entry);

    env->newObjByName(podName, typeName, "make", 2);
    fr_TagValue error = *env->peek();
    return (FObj*)error.any.o;
}

FObj* fr_makeCastError_(Env* env) {
    return fr_makeErr_(env, "sys", "CastErr", "");
}

FObj* fr_makeIndexError_(Env* env, fr_Int index, fr_Int limit) {
    char buf[128] = { 0 };
    snprintf(buf, 128, "index (%d) out of bounds (%d)", (int)index, (int)limit);
    return fr_makeErr_(env, "sys", "CastErr", buf);
}

void fr_printError_(Env* env, FObj * err) {
    FType* ftype = fr_getFType((fr_Env)env, err);
    std::string& name = ftype->c_name;
    printf("uncatch error: %s\n", name.c_str());

    FMethod* method = env->podManager->findMethod(env, "sys", "Err", "trace", 0);
    fr_TagValue val;
    val.any.o = err;
    val.type = fr_vtObj;
    env->push(&val);
    env->callVirtual(method, 0);
    env->pop(&val);
}

////////////////////////////////////////////////////////////////
// Other
////////////////////////////////////////////////////////////////

fr_Array* fr_arrayNew_(Env *env, FType* elemType, int32_t elemSize, size_t size) {
    if (elemSize <= 0) elemSize = sizeof(void*);
    FType* arrayType = env->findType("sys", "Array");

    size_t allocSize = sizeof(fr_Array) + (elemSize * (size + 1));
    fr_Array* a = (fr_Array*)fr_allocObj_(env, arrayType, (int)allocSize);
    a->elemType = fr_fromFType((fr_Env)env, elemType);
    a->elemSize = elemSize;
    a->valueType = env->podManager->getValueTypeByType(env, elemType);

    a->size = size;
    return a;
}

////////////////////////////////////////////////////////////////
// String
////////////////////////////////////////////////////////////////

FObj * fr_newStrUtf8N_(Env* e, const char *cstr, ssize_t size) {
    static FMethod *m = NULL;
    if (!m) {
        m = e->findMethod("sys", "Str", "fromCStr");
    }
    fr_TagValue args[2];

    if (size == -1) size = strlen(cstr);

    args[0].type = fr_vtPtr;
    args[0].any.p = (void*)cstr;
    args[1].type = fr_vtInt;
    args[1].any.i = size;
    e->push(&args[0]);
    e->push(&args[1]);
    e->call(m, 2);
      
    fr_TagValue ret;
    e->pop(&ret);
    return (FObj*)ret.any.o;
}

FObj* fr_newStrUtf8_(Env* e, const char* cstr) {
    return fr_newStrUtf8N_(e, cstr, -1);
}

char * fr_getStrUtf8_(Env* e, FObj * self__) {
      
    static FMethod *m = NULL;
    if (!m) {
        m = e->findMethod("sys", "Str", "toUtf8");
    }
    fr_TagValue args[2];
    args[0].type = fr_vtObj;
    args[0].any.o = self__;
    e->push(&args[0]);
    e->call(m, 0);
      
    fr_TagValue ret;
    e->pop(&ret);
    fr_Array *a = (fr_Array*)ret.any.o;
    return (char*)a->data;
}

FObj* fr_getConstString_(Env* env, FPod* curPod, uint16_t sid) {
    if (curPod->constantas.c_strings.size() != curPod->constantas.strings.size()) {
        curPod->constantas.c_strings.resize(curPod->constantas.strings.size());
    }

    FObj* objRef = (FObj*)curPod->constantas.c_strings[sid];
    if (objRef) {
        return objRef;
    }

    const std::string& utf8 = curPod->constantas.strings[sid];
    FObj* obj = (FObj*)fr_newStrUtf8_(env, utf8.c_str());
    env->vm->gc->pinObj(fr_toGcObj(obj));
    curPod->constantas.c_strings[sid] = (void*)obj;

    return obj;
}

////////////////////////////////////////////////////////////////
// Boxing
////////////////////////////////////////////////////////////////

FObj* sys_Int_doBox_(Env* e, fr_Int i) {
    FType* type = e->toType(fr_vtInt);
    int size = sizeof(fr_Int);

    FObj* obj = fr_allocObj_(e, type, size);

    fr_Int* val = (fr_Int*)(((char*)obj));
    *val = i;
    return obj;
}

FObj * fr_box_int_(Env* e, fr_Int i) {
    FObj* obj;
    static FObj *map[515];
    static const fr_Int sys_Int_minVal = -9223372036854775807LL-1;
    static const fr_Int sys_Int_maxVal = 9223372036854775807LL;
    int index;
    if (i < 256 && i >= -256) {
        index = i + 256;
    }
    else if (i == sys_Int_maxVal) index = 513;
    else if (i == sys_Int_minVal) index = 514;
    else {
        return sys_Int_doBox_(e, i);
    }

    obj = map[index];
    if (obj) return obj;

    obj = sys_Int_doBox_(e, i);
    e->vm->gc->pinObj(fr_toGcObj(obj));
    map[index] = obj;
    return obj;
}

FObj * sys_Float_doBox_(Env* e, fr_Float i) {
    FType *type = e->toType(fr_vtFloat);
    int size = sizeof(fr_Float);
    
    FObj * obj = fr_allocObj_(e, type, size);
    
    fr_Float *val = (fr_Float*)(((char*)obj));
    *val = i;
    return obj;
}

FObj* fr_box_float_(Env* e, fr_Float val) {
    FObj* obj;
    static FObj* map[8];
    static const fr_Float sys_Float_e = 2.71828182845904509080;
    static const fr_Float sys_Float_pi = 3.14159265358979311600;
    int index;
    if (val == 0) index = 0;
    if (val == 1) index = 1;
    if (val == -1) index = 2;
    if (val == 0.5) index = 3;
    if (val == sys_Float_e) index = 4;
    if (val == sys_Float_pi) index = 5;
    if (val == -INFINITY) index = 6;
    if (val == INFINITY) index = 7;
    else {
        obj = sys_Float_doBox_(e, val);
        return obj;
    }

    obj = map[index];
    if (obj) return obj;

    obj = sys_Float_doBox_(e, val);
    e->vm->gc->pinObj(fr_toGcObj(obj));
    map[index] = obj;
    return obj;
}

FObj* sys_Bool_doBox_(Env* e, fr_Bool i) {
    FType* type = e->toType(fr_vtBool);
    int size = sizeof(fr_Bool);

    FObj* obj = fr_allocObj_(e, type, size);

    fr_Bool* val = (fr_Bool*)(((char*)obj));
    *val = i;
    return obj;
}
FObj * fr_box_bool_(Env* e, fr_Bool i) {
    static FObj* trueObj = NULL;
    static FObj* falseObj = NULL;
    if (!trueObj) {
        //std::lock_guard<std::mutex> lock(pool_mutex);
        trueObj = sys_Bool_doBox_(e, true);
        falseObj = sys_Bool_doBox_(e, false);
        e->vm->gc->pinObj(fr_toGcObj(trueObj));
        e->vm->gc->pinObj(fr_toGcObj(falseObj));
    }
    return i ? trueObj : falseObj;
}

FObj * fr_box_(Env *env, fr_Value &any, fr_ValueType vtype) {
    FObj * obj = nullptr;
    switch (vtype) {
    case fr_vtInt: 
        obj = fr_box_int_(env, any.i);
        break;
    case fr_vtFloat:
        obj = fr_box_float_(env, any.f);
        break;
    case fr_vtBool:
        obj = fr_box_bool_(env, any.b);
        break;
    default:
        obj = (FObj*)any.o;
        break;
    }
    return obj;
}

fr_ValueType fr_unbox_(Env *env, FObj * obj, fr_Value &value) {
    fr_ValueType type = env->podManager->getValueTypeByType(env, fr_getFType((fr_Env)env, obj));
    if (type == fr_vtInt) {
        fr_Int* val = (fr_Int*)(((char*)obj));
        value.i = *val;
    } else if (type == fr_vtFloat) {
        fr_Float* val = (fr_Float*)(((char*)obj));
        value.f = *val;
    } else if (type == fr_vtBool) {
        fr_Bool* val = (fr_Bool*)(((char*)obj));
        value.b = *val;
    } else {
        value.o = obj;
    }
    //value.type = type;
    return type;
}


#ifdef  __cplusplus
}//extern "C"
#endif