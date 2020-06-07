//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by yangjiandong on 15/7/4.
//

#include "FPod.h"
#include "FType.h"
#include <stdlib.h>
#include <unordered_map>

static void parseMeta(Buffer &file, std::unordered_map<std::string,std::string> &out) {
    signed char c;//current char
    char key[1024];//key buffer
    char value[1024];//value buffer
    int pos;//current position
    int mode;//token mode, 0 is key, 1 is value;
    
    //open file
    if (file.size() == 0) {
        return;
    }

    c = file.readInt8();
    pos = 0;
    mode = 0;
    while (!file.isEof()) {
        if (c == '\r' || c == '\n') {
            if (mode == 1) {
                // deal new line
                mode = 0;
                value[pos] = 0;
                
                out[key] = value;
            }
            pos = 0;
        } else {
            if (mode == 0) {
                // read key
                if (c == '=') {
                    //end read key
                    mode = 1;
                    key[pos] = 0;
                    pos = 0;
                } else {
                    key[pos++] = c;
                }
            } else {
                //read value
                value[pos++] = c;
            }
        }
        
        c = file.readInt8();
    }
    
    //last line
    if (pos > 0) {
        value[pos] = 0;
        out[key] = value;
    }
}

void FPod::load(ZipFile &zip) {
    
    ssize_t bufSize;
    unsigned char *data = zip.getFileData("meta.props", &bufSize);
    if (data) {
        Buffer buf(data, bufSize, true);
        std::unordered_map<std::string,std::string> props;
        parseMeta(buf, props);
        
        std::string name = props["pod.name"];
        if (name == "syslib") {
            this->name = "sys";
        } else {
            this->name = name;
        }
        version = props["pod.version"];
        depends = props["pod.depends"];
        fcodeVersion = props["fcode.version"];
        
        if (fcodeVersion != "1.1.3") {
            printf("ERROR: fcodeVersion error %s, expected 1.1.3", fcodeVersion.c_str());
        }
    }
    c_wrappedPod = NULL;
    
    read(zip);
    
    types.resize(typeMetas.size());
    for (size_t i=0,n=typeMetas.size(); i<n; ++i) {
        FTypeRef ref = typeRefs[typeMetas[i].self];
        std::string &name = names[ref.typeName];
        readType(zip, name, typeMetas[i], types[i]);
    }
}

void FPod::read(ZipFile &zip) {
    {
        ssize_t bufSize;
        unsigned char *data = zip.getFileData("fcode/names.def", &bufSize);
        if (data) {
            Buffer buf(data, bufSize, true);
            int size = buf.readUInt16();
            std::string name;
            for (int i=0; i<size; ++i) {
                name = buf.readString();
                /*if (isSpecial) {
                    if (name == "syslib") {
                        name = "sys";
                    }
                    else if (name[name.size()-1] == '_') {
                        name.resize(name.size()-1);
                    }
                    else if (name.find("Fan") == 0) {
                        name = name.substr(3, name.size()-3);
                    }
                }*/
                names.push_back(name);
            }
        }
    }
    
    {
        ssize_t bufSize;
        unsigned char *data = zip.getFileData("fcode/ints.def", &bufSize);
        if (data) {
            Buffer buf(data, bufSize, true);
            int size = buf.readUInt16();
            for (int i=0; i<size; ++i) {
                constantas.ints.push_back(buf.readInt64());
            }
        }
    }
    
    {
        ssize_t bufSize;
        unsigned char *data = zip.getFileData("fcode/floats.def", &bufSize);
        if (data) {
            Buffer buf(data, bufSize, true);
            int size = buf.readUInt16();
            for (int i=0; i<size; ++i) {
                constantas.reals.push_back(buf.readDouble());
            }
        }
    }
    
    {
        ssize_t bufSize;
        unsigned char *data = zip.getFileData("fcode/strs.def", &bufSize);
        if (data) {
            Buffer buf(data, bufSize, true);
            int size = buf.readUInt16();
            for (int i=0; i<size; ++i) {
                constantas.strings.push_back(buf.readString());
            }
        }
    }
    {
        ssize_t bufSize;
        unsigned char *data = zip.getFileData("fcode/decimals.def", &bufSize);
        if (data) {
            Buffer buf(data, bufSize, true);
            int size = buf.readUInt16();
            for (int i=0; i<size; ++i) {
                constantas.decimals.push_back(buf.readString());
            }
        }
    }
    {
        ssize_t bufSize;
        unsigned char *data = zip.getFileData("fcode/durations.def", &bufSize);
        if (data) {
            Buffer buf(data, bufSize, true);
            int size = buf.readUInt16();
            for (int i=0; i<size; ++i) {
                int64_t sec = buf.readInt64();
                int32_t nanos = buf.readInt32();
                int64_t mills = (sec * 1000) + (nanos / 1000000);
                constantas.durations.push_back(mills);
            }
        }
    }
    {
        ssize_t bufSize;
        unsigned char *data = zip.getFileData("fcode/uris.def", &bufSize);
        if (data) {
            Buffer buf(data, bufSize, true);
            int size = buf.readUInt16();
            for (int i=0; i<size; ++i) {
                constantas.uris.push_back(buf.readString());
            }
        }
    }
    {
        ssize_t bufSize;
        unsigned char *data = zip.getFileData("fcode/typeRefs.def", &bufSize);
        if (data) {
            Buffer buf(data, bufSize, true);
            int size = buf.readUInt16();
            for (int i=0; i<size; ++i) {
                FTypeRef typeRef;
                typeRef.podName = buf.readUInt16();
                typeRef.typeName = buf.readUInt16();
                typeRef.extName = buf.readString();
                typeRef.c_type= NULL;
                typeRefs.push_back(typeRef);
            }
        }
    }
    {
        ssize_t bufSize;
        unsigned char *data = zip.getFileData("fcode/fieldRefs.def", &bufSize);
        if (data) {
            Buffer buf(data, bufSize, true);
            int size = buf.readUInt16();
            for (int i=0; i<size; ++i) {
                FFieldRef ref;
                ref.parent = buf.readUInt16();
                ref.name = buf.readUInt16();
                ref.type = buf.readUInt16();
                ref.c_field = NULL;
                fieldRefs.push_back(ref);
            }
        }
    }
    {
        ssize_t bufSize;
        unsigned char *data = zip.getFileData("fcode/methodRefs.def", &bufSize);
        if (data) {
            Buffer buf(data, bufSize, true);
            int size = buf.readUInt16();
            for (int i=0; i<size; ++i) {
                FMethodRef ref;
                ref.parent = buf.readUInt16();
                ref.name = buf.readUInt16();
                ref.retType = buf.readUInt16();
                ref.paramCount = buf.readUInt8();
                ref.c_method = NULL;
                for (int i=0; i<ref.paramCount; ++i) {
                    ref.params.push_back(buf.readUInt16());
                }
                ref.flags = buf.readUInt8();
                methodRefs.push_back(ref);
            }
        }
    }
    
    {
        ssize_t bufSize;
        unsigned char *data = zip.getFileData("fcode/types.def", &bufSize);
        if (data) {
            Buffer buf(data, bufSize, true);
            int size = buf.readUInt16();
            for (int i=0; i<size; ++i) {
                FTypeMeta ref;
                ref.self = buf.readUInt16();
                ref.base = buf.readUInt16();
                ref.mixinCount = buf.readUInt16();
                for (int i=0; i<ref.mixinCount; ++i) {
                    ref.mixin.push_back(buf.readUInt16());
                }
                ref.flags = buf.readUInt32();
                
#ifndef FCODE_1_0
                ref.genericCount = buf.readUInt8();
                ref.genericParams.resize(ref.genericCount);
                ref.genericParamBounds.resize(ref.genericCount);
                for (int i=0; i<ref.genericCount; ++i) {
                    ref.genericParams[i] = buf.readUInt16();
                }
                for (int i=0; i<ref.genericCount; ++i) {
                    ref.genericParamBounds[i] = buf.readUInt16();
                }
#endif
                typeMetas.push_back(ref);
            }
        }
    }
}

void FPod::readType(ZipFile &zip, const std::string &name, FTypeMeta &meta, FType &type) {
    ssize_t bufSize;
    std::string path = ("fcode/");
    //if (isSpecial) {
    //    path += "Fan";
    //}
    path += name;
    path += ".fcode";
    
    unsigned char *data = zip.getFileData(path, &bufSize);
    if (data) {
        Buffer buf(data, bufSize, false);
        type.read(this, meta, buf);
        
        c_typeMap[name] = &type;
    }
    //else if (isSpecial) {
    //    readType(zip, name, meta, type, false);
    //}
    else {
        printf("ERROR: can't read type %s\n", name.c_str());
    }
    
    free(data);
}
