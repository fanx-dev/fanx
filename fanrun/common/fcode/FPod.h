//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by yangjiandong on 15/7/4.
//

#ifndef __zip__Constants__
#define __zip__Constants__

#include <vector>
#include <string>
#include <stdio.h>
#include "Buffer.h"
#include "ZipFile.h"
#include "FType.h"
#include <unordered_map>

namespace FFlags {
    const uint32_t Abstract   = 0x00000001;
    const uint32_t Const      = 0x00000002;
    const uint32_t Ctor       = 0x00000004;
    const uint32_t Enum       = 0x00000008;
    const uint32_t Facet      = 0x00000010;
    const uint32_t Final      = 0x00000020;
    const uint32_t Getter     = 0x00000040;
    const uint32_t Internal   = 0x00000080;
    const uint32_t Mixin      = 0x00000100;
    const uint32_t Native     = 0x00000200;
    const uint32_t Override   = 0x00000400;
    const uint32_t Private    = 0x00000800;
    const uint32_t Protected  = 0x00001000;
    const uint32_t Public     = 0x00002000;
    const uint32_t Setter     = 0x00004000;
    const uint32_t Static     = 0x00008000;
    const uint32_t Storage    = 0x00010000;
    const uint32_t Synthetic  = 0x00020000;
    const uint32_t Virtual    = 0x00040000;
    
    const uint32_t Struct     = 0x00080000;
    const uint32_t Extension  = 0x00100000;
    const uint32_t RuntimeConst=0x00200000;
    const uint32_t Readonly   = 0x00400000;
    const uint32_t Async      = 0x00800000;
    const uint32_t Overload   = 0x01000000;
    const uint32_t FlagsMask  = 0x0fffffff;
    
    
    const uint32_t Param       = 0x0001;  // parameter or local variable
    const uint32_t ParamDefault= 0x0002; //the param has default
    
    //////////////////////////////////////////////////////////////////////////
    // MethodRefFlags
    //////////////////////////////////////////////////////////////////////////
    const uint32_t RefOverload = 0x0001;
    const uint32_t RefSetter   = 0x0002;
}

struct FConstantas {
    std::vector<int64_t> ints;
    std::vector<double> reals;
    std::vector<const std::string> strings;
    std::vector<int64_t> durations;
    std::vector<const std::string> uris;
    std::vector<const std::string> decimals;
    
    std::vector<void*> c_strings;
};

struct FTypeRef {
    uint16_t podName;//names.def
    uint16_t typeName;//names.def
    std::string extName;//("" if not parameterized, "?" if nullable)
    
    FType *c_type;
};

struct FFieldRef {
    uint16_t parent;//typeRefs.def
    uint16_t name;//names.def
    uint16_t type;//typeRefs.def
    
    FField *c_field;
};

struct FMethodRef {
    uint16_t parent;//typeRefs.def
    uint16_t name;//names.def
    uint16_t retType;//typeRefs.def
    uint8_t paramCount;
    std::vector<uint16_t> params;//typeRefs.def
    uint8_t flags;
    
    FMethod *c_method;
};

class PodLoader;
class FPod {
public:
    std::vector<std::string> names;
    
    FConstantas constantas;
    std::string name;
    std::string version;
    std::string depends;
    std::string fcodeVersion;
    
    std::vector<FTypeRef> typeRefs;
    std::vector<FFieldRef> fieldRefs;
    std::vector<FMethodRef> methodRefs;
    std::vector<FTypeMeta> typeMetas;
    std::vector<FType> types;
    
    //cache
    //std::vector<FType*> c_sortedTypes;
    std::unordered_map<std::string, FType*> c_typeMap;
    void *c_wrappedPod;
    std::vector< std::string > c_dependPods;
    PodLoader *c_loader;
    
    void load(ZipFile &zip);
    
private:
    void read(ZipFile &zip);
    
    void readType(ZipFile &zip, const std::string &name, FTypeMeta &meta, FType &type);
    
};


#endif /* defined(__zip__Constants__) */
