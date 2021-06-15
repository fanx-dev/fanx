//
//  PodManager.cpp
//  vm
//
//  Created by yangjiandong on 15/9/26.
//  Copyright (c) 2015, yangjiandong. All rights reserved.
//

#include "PodManager.h"
#include "Printer.h"
#include "Env.h"
//#include "StackFrame.h"
#include "Fvm.h"


////////////////////////////////////////////////////////////////
// methods

void PodManager::registerMethod(const std::string &name, fr_NativeFunc func) {
    nativeFuncMap[name] = func;
}

void PodManager::loadNativeMethod(FMethod *method) {
    if (!method) {
        return;
    }
    FType *type = method->c_parent;
    FPod *pod = type->c_pod;
    std::string &methodName = pod->names[method->name];
    if (!method->c_native
        && ((method->flags & FFlags::Native) || (method->c_parent->meta.flags & FFlags::Native))) {
        std::string fullName = pod->name + "_" + type->c_name + "_"+methodName;
        method->c_native = (FNativeFunc)nativeFuncMap[fullName];
        if (method->c_native == NULL) {
            fullName += std::to_string(method->paramCount);
            method->c_native = (FNativeFunc)nativeFuncMap[fullName];
        }
        
        if (method->c_native == NULL && method->code.isEmpty()) {
            printf("ERROR: not found native func %s\n", fullName.c_str());
        }
    }
}

FMethod *PodManager::getMethod(Env *env, FPod *curPod, FMethodRef &methodRef) {
    //FMethodRef &methodRef = curPod->methodRefs[mid];
    if (!methodRef.c_method) {
        std::string methodName = curPod->names[methodRef.name];
        FType *type = getType(env, curPod, methodRef.parent);
        FMethod *method = type->c_methodMap[methodName];
        
        if (method == NULL) {
            printf("ERROR: method not found %s", methodName.c_str());
            return NULL;
        }
        
        //getter or setter/overload
        if (method->paramCount != methodRef.paramCount) {
            method = type->c_methodMap[methodName +"$"+ std::to_string(methodRef.paramCount)];
        }
        
        loadNativeMethod(method);
        methodRef.c_method = method;
    }
    //*paramCount = methodRef.paramCount;
    return methodRef.c_method;
}

FMethod *PodManager::toVirtualMethod(Env *env, FType *instanceType, FMethod *method) {
    if (instanceType == method->c_parent) {
        return method;
    }
    auto fr = instanceType->c_virtualMethodMapByMethod.find(method);
    if (fr == instanceType->c_virtualMethodMapByMethod.end()) {
        std::string &methodName = method->c_parent->c_pod->names[method->name];
        FMethod *nmethod = findVirtualMethod(env, instanceType, methodName, method->paramCount);
        instanceType->c_virtualMethodMapByMethod[method] = nmethod;
        return nmethod;
    }
    return fr->second;
}

FMethod *PodManager::getVirtualMethod(Env *env, FType *instanceType, FPod *curPod, FMethodRef *methodRef) {
    //FMethodRef *methodRef = &curPod->methodRefs[mid];
    auto fr = instanceType->c_virtualMethodMap.find(methodRef);
    if (fr == instanceType->c_virtualMethodMap.end()) {
        FMethod *method = nullptr;
        
        //FMethodRef &methodRef = curPod->methodRefs[mid];
        std::string methodName = curPod->names[methodRef->name];
        
        method = findVirtualMethod(env, instanceType, methodName, -1);
        if (method->paramCount != methodRef->paramCount) {
            method = findVirtualMethod(env, instanceType, methodName, methodRef->paramCount);
        }
        assert(method);
        
        instanceType->c_virtualMethodMap[methodRef] = method;
        return method;
    }
    return fr->second;
}

FMethod *PodManager::findMethodInType(Env *env, FType *type, const std::string &name, int paramCount) {
    initTypeAllocSize(env, type);
    
    FMethod *method;
    if (paramCount != -1) {
        method = type->c_methodMap[name +"$"+ std::to_string(paramCount)];
    }
    else {
        method = type->c_methodMap[name];
    }
    
    assert(method);
    
    loadNativeMethod(method);
    return method;
}

FMethod *PodManager::findMethod(Env *env, const std::string &podName, const std::string &typeName, const std::string &methodName, int paramCount) {
    
    FPod *pod = findPod(podName);
    if (!pod) return nullptr;
    FType *type = pod->c_typeMap[typeName];
    if (!type) return nullptr;
    
    return findMethodInType(env, type, methodName, paramCount);
}

FMethod *PodManager::findVirtualMethod(Env *env, FType *instanceType, const std::string &name, int paramCount) {
    std::unordered_map<std::string, FMethod*>::iterator fr;
    if (paramCount != -1) {
        fr = instanceType->c_virtualMethodMapByName.find(name+"$"+std::to_string(paramCount));
    }
    else {
        fr = instanceType->c_virtualMethodMapByName.find(name);
    }
    
    if (fr == instanceType->c_virtualMethodMapByName.end()) {
        FMethod *method = nullptr;
        FPod *pod = instanceType->c_pod;
        
        //getter or setter/overload
        if (paramCount != -1) {
            method = instanceType->c_methodMap[name +"$"+ std::to_string(paramCount)];
        }
        else {
            method = instanceType->c_methodMap[name];
        }
        
        if (!method) {
            if (isRootType(env, instanceType)) {
                return nullptr;
            }

            FType *base = getType(env, pod, instanceType->meta.base);
            method = findVirtualMethod(env, base, name, paramCount);
            if (!method) {
                for (int i=0; i<instanceType->meta.mixinCount; ++i) {
                    uint16_t mixin = instanceType->meta.mixin[i];
                    FType *base = getType(env, pod, mixin);
                    method = findVirtualMethod(env, base, name, paramCount);
                    if (method) {
                        break;
                    }
                }
            }
        }
        
        if (method == NULL) {
            printf("ERROR: method not found %s %d", name.c_str(), paramCount);
            return NULL;
        }
        
        loadNativeMethod(method);
        if (paramCount != method->paramCount) {
            instanceType->c_virtualMethodMapByName[name +"$"+ std::to_string(paramCount)] = method;
        }
        else {
            instanceType->c_virtualMethodMapByName[name] = method;
        }
        return method;
    }
    return fr->second;
}

////////////////////////////////////////////////////////////////
// field

FField *PodManager::getField(Env *env, FPod *curPod, uint16_t fid) {
    FFieldRef &fieldRef = curPod->fieldRefs[fid];
    if (!fieldRef.c_field) {
        std::string fieldName = curPod->names[fieldRef.name];
        FType *type = getType(env, curPod, fieldRef.parent);
        FField *field = type->c_fieldMap[fieldName];
        fieldRef.c_field = field;
    }
    return fieldRef.c_field;
}

FField *PodManager::findFieldInType(Env *env, FType *type, const std::string &fieldName) {
    initTypeAllocSize(env, type);
    
    FField *field = type->c_fieldMap[fieldName];
    return field;
}

FField *PodManager::findFieldByName(Env *env, const std::string &podName, const std::string &typeName, const std::string &fieldName) {
    FPod *pod = findPod(podName);
    if (!pod) return NULL;
    FType  *type = pod->c_typeMap[typeName];
    if (!type) return NULL;
    return findFieldInType(env, type, fieldName);
}
/*
FField *PodManager::findFieldByType(FType *type, std::string &fieldName) {
    FField *field = type->c_fieldMap[fieldName];
    return field;
}
*/
fr_Value *PodManager::getInstanceFieldValue(FObj * obj, FField *field) {
    if ((field->flags & FFlags::Static)==0) {
        fr_Value *sfield = (fr_Value*)(((char*)obj)+field->c_offset);
        return sfield;
    }
    return NULL;
}
fr_Value *PodManager::getStaticFieldValue(FField *field) {
    FType *ftype = field->c_parent;
    char *staticData = ftype->c_staticData;
    fr_Value *sfield = (fr_Value*)(staticData + field->c_offset);
    return sfield;
}

////////////////////////////////////////////////////////////////
// type ref

void PodManager::initTypeAllocSize(Env *env, FType *type) {
    if (type->c_allocSize != -1) {
        return;
    }
    
    int d = sizeof(fr_Value);
    int size = 0;
    
    //init super
    if (isRootType(env, type)) {
        size = sizeof( fr_ObjHeader);
    } else {
        FType *base = getType(env, type->c_pod, type->meta.base);
        initTypeAllocSize(env, base);
        size = base->c_allocSize;
    }
    
    //init filed offset
    int staticSize = 0;
    for (int i=0; i<type->fields.size(); ++i) {
        FField &f = type->fields[i];
        if ((f.flags & FFlags::Storage) == 0) {
            continue;
        }
        if (f.flags & FFlags::Static) {
            f.c_offset = staticSize;
            staticSize += d;
        } else {
            f.c_offset = size;
            size += d;
        }
    }
    type->c_allocSize = size;
    type->c_allocStaticSize = staticSize;
    
    //get native alloc size
    if (type->c_isNative) {
        FPod *pod = type->c_pod;
        std::string name = pod->name +"_"+ type->c_name + "__allocSize__";
        int (*func)() = (int (*)())nativeFuncMap[name];
        if (func == NULL) {
            printf("ERROR:not found native method: %s\n", name.c_str());
            abort();
        }
        size = func();
        if (size > type->c_allocSize) {
            type->c_allocSize = size;
        }
    }
    
    //alloc static data
    if (type->c_allocStaticSize > 0) {
        type->c_staticData = (char*)malloc(type->c_allocStaticSize);
        memset(type->c_staticData, 0, type->c_allocStaticSize);
        for (int i=0; i<type->fields.size(); ++i) {
            FField &f = type->fields[i];
            if ((f.flags & FFlags::Static)) {
                fr_Value *val = (fr_Value*)(((char*)type->c_staticData) + f.c_offset);
                fr_ValueType vtype = getValueType(env, type->c_pod, f.type);
                if (vtype == fr_vtObj) {
                    fr_Obj obj = reinterpret_cast<fr_Obj>(&(val->o));
                    vm->addStaticRef(obj);
                }
            }
        }
    }
    
    //call static init
    if (env == nullptr && vm) {
        env = vm->getEnv();
    }
    if (env) {
        FMethod *method = type->c_methodMap["static$init"];
        if (method) {
            if (method->c_native == nullptr) {
                FPod *pod = type->c_pod;
                std::string fullName = pod->name + "_" + type->c_name + "_static$init";
                fr_NativeFunc func = nativeFuncMap[fullName];
                if (func) {
                    method->c_native = (FNativeFunc)func;
                }
            }
            env->call(method, 0);
        }
    } else {
        printf("ERROR: env is null\n");
    }
}

bool PodManager::isNullableType(Env *env, FPod *curPod, uint16_t tid) {
    FTypeRef &typeRef = curPod->typeRefs[tid];
    std::string &sig = typeRef.extName;
    if (sig.size() > 0 && sig[sig.size()-1] == '?') {
        return true;
    }
    return false;
}

bool PodManager::isPrimitiveType(Env *env, FPod *curPod, uint16_t tid) {
    FTypeRef &typeRef = curPod->typeRefs[tid];
    std::string &sig = typeRef.extName;
    if (sig.size() > 0 && sig[sig.size()-1] == '?') {
        return false;
    }
    
    FType *type = getType(env, curPod, tid);
    
    if (!intType) initSysType(env);
    
    if (type == intType) {
        return true;
    }
    else if (type == floatType) {
        return true;
    }
    else if (type == boolType) {
        return true;
    }
    else if (type == ptrType) {
        return true;
    }
    else {
        return false;
    }
}

fr_ValueType PodManager::getValueType(Env *env, FPod *curPod, uint16_t tid) {
    FTypeRef &typeRef = curPod->typeRefs[tid];
    std::string &sig = typeRef.extName;
    if (sig.size() > 0 && sig[sig.size()-1] == '?') {
        return fr_vtObj;
    }
    
    FType *type = getType(env, curPod, tid);
    
    if (!intType) initSysType(env);
    
    if (type == intType) {
        return fr_vtInt;
    }
    else if (type == floatType) {
        return fr_vtFloat;
    }
    else if (type == boolType) {
        return fr_vtBool;
    }
    else if (type == ptrType) {
        return fr_vtPtr;
    }
    else {
        return fr_vtObj;
    }
}

fr_ValueType PodManager::getValueTypeByType(Env *env, FType *type) {
    if (!intType) initSysType(env);
    
    if (type == intType) {
        return fr_vtInt;
    }
    else if (type == floatType) {
        return fr_vtFloat;
    }
    else if (type == boolType) {
        return fr_vtBool;
    }
    else if (type == ptrType) {
        return fr_vtPtr;
    }
    else {
        return fr_vtObj;
    }
}

fr_ValueType PodManager::getExactValueType(FPod *curPod, uint16_t tid, bool &nullable, bool *isVoid) {
    FTypeRef &typeRef = curPod->typeRefs[tid];
    std::string &podName = curPod->names[typeRef.podName];
    std::string &typeName = curPod->names[typeRef.typeName];
    std::string &sig = typeRef.extName;
    
    if (isVoid) {
        *isVoid = false;
    }
    
    fr_ValueType vtype = fr_vtObj;
    if (podName == "sys") {
        if (typeName == "Int") {
            vtype = fr_vtInt;
        }
        else if (typeName == "Float") {
            vtype = fr_vtFloat;
        }
        else if (typeName == "Bool") {
            vtype = fr_vtBool;
        }
        else if (typeName == "Ptr") {
            vtype = fr_vtPtr;
        }
        else if (typeName == "Void") {
            if (isVoid) {
                *isVoid = true;
            }
        }
    }
    
    if (sig.size() > 0 && sig[sig.size()-1] == '?') {
        nullable = true;
    } else {
        nullable = false;
    }
    
    return vtype;
}

FType *PodManager::getInstanceType(Env *env, fr_TagValue &val) {
    if (!intType) initSysType(env);
    
    FType *type = nullptr;
    switch (val.type) {
        case fr_vtInt:
            type = intType;
            break;
        case fr_vtFloat:
            type = floatType;
            break;
        case fr_vtBool:
            type = boolType;
            break;
        case fr_vtPtr:
            type = ptrType;
            break;
        case fr_vtObj:
            type = fr_getFType(env, val.any.o);
            break;
        default:
            type = objType;
            break;
    }
    return type;
}

bool PodManager::isVoidType(Env *env, FType *type) {
    if (!voidType) initSysType(env);
    return type == voidType;
}

bool PodManager::isRootType(Env *env, FType *type) {
    if (!objType) initSysType(env);
    return type == objType;
}

////////////////////////////////////////////////////////////////
// type

bool PodManager::fitTypeByType(Env *env, FType *typeA, FType *typeB) {
    if (typeA == typeB) {
        return true;
    }
    
    if (isRootType(env, typeB)) {
        return true;
    }
    
    if (isRootType(env, typeA)) {
        return false;
    }
    
    FPod *pod = typeA->c_pod;
    FType *base = getType(env, pod, typeA->meta.base);
    bool fit = fitTypeByType(env, base, typeB);
    if (fit) {
        return true;
    }
    
    for (int i=0; i<typeA->meta.mixinCount; ++i) {
        uint16_t mixin = typeA->meta.mixin[i];
        FType *base = getType(env, pod, mixin);
        fit = fitTypeByType(env, base, typeB);
        if (fit) {
            return true;
        }
    }
    return false;
}

bool PodManager::fitType(Env *env, FType *instanceType, FPod *curPod, uint16_t tid) {
    FType *other = getType(env, curPod, tid);
    return fitTypeByType(env, instanceType, other);
}

FType *PodManager::getType(Env *env, FPod *curPod, uint16_t tid) {
    FTypeRef &typeRef = curPod->typeRefs[tid];
    
    if (!typeRef.c_type) {
        std::string &podName = curPod->names[typeRef.podName];
        std::string &typeName = curPod->names[typeRef.typeName];
        
        FPod *pod = findPod(podName);
        FType *type = pod->c_typeMap[typeName];
        typeRef.c_type = type;
        
        initTypeAllocSize(env, type);
    }
    return typeRef.c_type;
}

FType *PodManager::findType(Env *env, const std::string &podName, const std::string &typeName, bool initType) {
    FPod *pod = findPod(podName);
    if (pod == nullptr) {
        return nullptr;
    }
    FType *type = pod->c_typeMap[typeName];
    if (initType) {
        initTypeAllocSize(env, type);
    }
    return type;
}

FType *PodManager::findElemType(Env *env, const std::string &extName, size_t *elemSize, fr_ValueType *valueType) {
    FType *elemType = NULL;
    if (extName == "sys::Int8") {
        elemType = intType;
        *elemSize = 1;
        *valueType = fr_vtInt;
    }
    else if (extName == "sys::Int16") {
        elemType = intType;
        *elemSize = 2;
        *valueType = fr_vtInt;
    }
    else if (extName == "sys::Int32") {
        elemType = intType;
        *elemSize = 4;
        *valueType = fr_vtInt;
    }
    else if (extName == "sys::Int64" || extName == "sys::Int") {
        elemType = intType;
        *elemSize = 8;
        *valueType = fr_vtInt;
    }
    else if (extName == "sys::Float32") {
        elemType = floatType;
        *elemSize = 4;
        *valueType = fr_vtFloat;
    }
    else if (extName == "sys::Float64" || extName == "sys::Float") {
        elemType = floatType;
        *elemSize = 4;
        *valueType = fr_vtFloat;
    }
    else if (extName == "sys::Bool") {
        elemType = boolType;
        *elemSize = 1;
        *valueType = fr_vtBool;
    }
    else {
        size_t pos = extName.find("::");
        std::string pod = extName.substr(0, pos);
        std::string type = extName.substr(pos+2);
        elemType = findType(env, pod, type);
        *valueType = fr_vtObj;
        *elemSize = sizeof(void*);
    }
    return elemType;
}

void PodManager::initSysType(Env *env) {
    if (intType == nullptr) {
        objType = findType(env, "sys", "Obj", false);
        intType = findType(env, "sys", "Int", false);
        floatType = findType(env, "sys", "Float", false);
        boolType = findType(env, "sys", "Bool", false);
        ptrType = findType(env, "sys", "Ptr", false);
        voidType = findType(env, "sys", "Void", false);
        //typeType = findType(env, "sys", "Type", false);
        npeType = findType(env, "sys", "NullErr", false);
        
        initTypeAllocSize(env, objType);
        initTypeAllocSize(env, intType);
        initTypeAllocSize(env, floatType);
        initTypeAllocSize(env, boolType);
        initTypeAllocSize(env, ptrType);
        initTypeAllocSize(env, voidType);
        //initTypeAllocSize(env, typeType);
        initTypeAllocSize(env, npeType);
    }
}

//FType *PodManager::getTypeType(Env *env) {
//    if (!intType) initSysType(env);
//    return typeType;
//}
FType *PodManager::getNpeType(Env *env) {
    if (!intType) initSysType(env);
    return npeType;
}

FType *PodManager::getSysType(Env *env, fr_ValueType vt) {
    if (!intType) initSysType(env);
    FType *type = NULL;
    switch (vt) {
        case fr_vtInt:
            type = intType;
            break;
        case fr_vtFloat:
            type = floatType;
            break;
        case fr_vtBool:
            type = boolType;
            break;
        case fr_vtPtr:
            type = ptrType;
            break;
        case fr_vtObj:
        default:
            type = objType;
            break;
    }
    return type;
}

//FObj * PodManager::getWrappedType(Env *env, FType *type) {
//    return objFactory.getWrappedType(env, type);
//}
//
//FType *PodManager::getFType(Env *env, FObj *otype) {
//    return objFactory.getFType(env, otype);
//}

///////////////////////////////////////////////////////////////////////////////

PodManager::PodManager()
    : intType(nullptr), floatType(nullptr), boolType(nullptr), objType(nullptr), voidType(nullptr), vm(nullptr) {
}

PodManager::~PodManager() {
}

bool PodManager::load(const std::string &path, const std::string &name) {
    return podLoader.load(path, name);
}

