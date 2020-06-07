//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by chunquedong on 15/6/26.
//

#ifndef __zip__FTypeBody__
#define __zip__FTypeBody__

#include <stdio.h>
#include "Buffer.h"
#include "Code.h"
#include "FAttr.h"
#include <unordered_map>

class FType;

struct FSlot {
    uint16_t name;
    uint32_t flags;
    uint16_t attrCount;
    std::vector<FAttr*> attrs;
    
    bool isStatic();
};

struct FField : public FSlot {
    uint16_t type;
    
    //app
    uint16_t c_offset;
    FType *c_parent;
    std::string c_mangledName;
};

struct FMethodVar : public FSlot {
    uint16_t type;
};

class Code;
typedef void (*FNativeFunc)(void *env, void *param, void *ret);

struct FMethod : public FSlot {
    uint16_t returnType;
    uint16_t inheritReturenType;
    uint8_t maxStack;
    uint8_t paramCount;
    uint8_t localCount;
    std::vector<FMethodVar> vars;
    Code code;
    
    uint8_t genericCount;
    std::vector<uint16_t> genericParams;
    std::vector<uint16_t> genericParamBounds;
    
    //cache
    FType *c_parent;
    
    FNativeFunc c_native;
    void *c_wrappedMethod;
    void (*c_jit)(void *env);
    uint16_t c_jitLocalCount;
    std::string c_stdName;
    std::string c_mangledName;
    std::string c_mangledSimpleName;
};

struct FTypeMeta {
    uint16_t self;//typeRefs.def
    uint16_t base;//  (typeRefs.def or 0xFFFF)
    uint16_t mixinCount;
    std::vector<uint16_t> mixin;// (typeRefs.def)
    uint32_t flags;
    uint8_t genericCount;
    std::vector<uint16_t> genericParams;
    std::vector<uint16_t> genericParamBounds;
};

class FMethodRef;

class FType {
public:
    //uint16_t fieldCount;
    std::vector<FField> fields;
    //uint16_t methodCount;
    std::vector<FMethod> methods;
    //uint16_t attrCount;
    std::vector<FAttr*> attrs;
    
    FTypeMeta meta;
    FPod *c_pod;
    bool c_isExtern;
    
    //cache
    std::string c_name;
    std::string c_mangledName;
    //int c_sortFlag;
    std::unordered_map<std::string, FMethod*> c_methodMap;
    std::unordered_map<std::string, FField*> c_fieldMap;
    int c_allocSize;
    int c_allocStaticSize;
    char *c_staticData;
    std::unordered_map<std::string, FMethod*> c_virtualMethodMapByName;
    std::unordered_map<FMethodRef*, FMethod*> c_virtualMethodMap;
    std::unordered_map<FMethod*, FMethod*> c_virtualMethodMapByMethod;
    void *c_wrappedType;
    
public:
    void read(FPod *pod, FTypeMeta &meta, Buffer &buffer);
    
    ~FType();
    
    uint16_t findGenericParamBound(const std::string &name);
  
private:
    void readMethod(FMethod &method, Buffer &buffer);
};

#endif /* defined(__zip__FTypeBody__) */
