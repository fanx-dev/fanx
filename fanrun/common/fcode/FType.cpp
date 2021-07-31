//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by chunquedong on 15/6/26.
//

#include "FType.h"
#include "FPod.h"
#include "../util/escape.h"

bool FSlot::isStatic() { return (flags & FFlags::Static); }

void FType::readMethod(FMethod &method, Buffer &buffer) {
    method.name = buffer.readUInt16();
    method.flags = buffer.readUInt32();
    method.returnType = buffer.readUInt16();
    method.inheritReturenType = buffer.readUInt16();
    method.maxStack = buffer.readUInt8();
    method.paramCount = buffer.readUInt8();
    method.localCount = buffer.readUInt8();
    method.c_native = NULL;
    method.c_reflectSlot = NULL;
    method.c_jit = NULL;
    
    for (int j=0,n=method.paramCount+method.localCount; j<n; ++j) {
        FMethodVar var;
        var.name = buffer.readUInt16();
        var.type = buffer.readUInt16();
        var.flags = buffer.readUInt8();
        var.attrCount = buffer.readUInt16();
        //var.attrs.resize(attrCount);
        for (int i=0; i<var.attrCount; ++i) {
            FAttr *attr = FAttr::readAttr(c_pod, buffer);
            if (attr) {
                var.attrs.push_back(attr);
            }
        }
        method.vars.push_back(var);
    }
    
    method.code.read(buffer);
    
    int attrCount = buffer.readUInt16();
    method.attrCount = attrCount;
    for (int i=0; i<attrCount; ++i) {
        FAttr *attr = FAttr::readAttr(c_pod, buffer);
        if (attr) {
            method.attrs.push_back(attr);
        }
    }
    
#ifndef FCODE_1_0
    method.genericCount = buffer.readUInt8();
    method.genericParams.resize(method.genericCount);
    method.genericParamBounds.resize(method.genericCount);
    for (int i=0; i<method.genericCount; ++i) {
        method.genericParams[i] = buffer.readUInt16();
    }
    for (int i=0; i<method.genericCount; ++i) {
        method.genericParamBounds[i] = buffer.readUInt16();
    }
#endif

    method.c_parent = this;
}

uint16_t FType::findGenericParamBound(const std::string &name) {
    for (int i =0; i<meta.genericCount; ++i) {
        uint16_t nameId = meta.genericParams[i];
        const std::string &tname = c_pod->names[nameId];
        if (tname == name) {
            return meta.genericParamBounds[i];
        }
    }
    return -1;
}

void FType::read(FPod *pod, FTypeMeta &meta, Buffer &buffer) {
    c_allocSize = -1;
    c_allocStaticSize = -1;
    c_staticData = NULL;
    c_reflectType = NULL;
    this->meta = meta;
    this->c_pod = pod;
    FTypeRef &typeRef = pod->typeRefs[meta.self];
    this->c_name = pod->names[typeRef.typeName];
    std::string typeName = pod->name + "_" + this->c_name;
    escape(typeName);
    this->c_mangledName = typeName;
    
    typeRef.c_type = this;
    
    {
        int fieldCount = buffer.readUInt16();
        fields.resize(fieldCount);
        for (int i=0; i<fieldCount; ++i) {
            fields[i].name = buffer.readUInt16();
            fields[i].flags = buffer.readUInt32();
            fields[i].type = buffer.readUInt16();
            int attrCount = buffer.readUInt16();
            fields[i].attrCount = attrCount;
            fields[i].c_offset = -1;
            fields[i].c_parent = this;
            fields[i].c_reflectSlot = NULL;
            for (int i=0; i<attrCount; ++i) {
                FAttr *attr = FAttr::readAttr(pod, buffer);
                if (attr) {
                    fields[i].attrs.push_back(attr);
                }
            }
            
            std::string &name = pod->names[fields[i].name];
            fields[i].c_mangledName = name;
            escape(fields[i].c_mangledName);
            c_fieldMap[name] = &fields[i];
        }
    }
    {
        int methodCount = buffer.readUInt16();
        methods.resize(methodCount);
        for (int i=0; i<methodCount; ++i) {
            FMethod &method = methods[i];
            readMethod(method, buffer);
            
            std::string name = pod->names[method.name];
            if (method.flags & FFlags::Setter) {
                name += "$";
                name += std::to_string(method.paramCount);
            }
            else if (method.flags & FFlags::Overload) {
                name += "$";
                name += std::to_string(method.paramCount);
            }
            //Closure is special that overide the overload version
            else if ((meta.flags & FFlags::Closure) && method.paramCount < 8 && name == "call") {
                name += "$";
                name += std::to_string(method.paramCount);
            }

            method.c_stdName = name;
            
            method.c_mangledSimpleName = name;
            escape(method.c_mangledSimpleName);
            
            method.c_mangledName = typeName +"_"+ method.c_mangledSimpleName;
            escape(method.c_mangledName);
            
            c_methodMap[method.c_stdName] = &method;
        }
    }
    {
        c_isNative = (meta.flags & FFlags::Native) != 0;
        c_isSimpleSym = false;
        int attrCount = buffer.readUInt16();
        //attrs.resize(attrCount);
        for (int i=0; i<attrCount; ++i) {
            FAttr *attr = FAttr::readAttr(pod, buffer);
            if (attr) {
                attrs.push_back(attr);
            }
            if (FFacets *fs = dynamic_cast<FFacets*>(attr)) {
                for (FFacet &f : fs->facets) {
                    FTypeRef &tRef = pod->typeRefs[f.type];
//                    if (pod->names[tRef.podName] == "sys" && pod->names[tRef.typeName] == "NoNative") {
//                        c_isNative = false;
//                    }
                    if (pod->names[tRef.podName] == "sys" && pod->names[tRef.typeName] == "Extern") {
                        c_isSimpleSym = true;
                    }
                }
            }
        }
    }
}


FType::~FType() {
    for (int i=0; i<attrs.size(); ++i) {
        delete attrs[i];
    }
    attrs.clear();
}
