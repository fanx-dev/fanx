//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by yangjiandong on 15/8/15.
//

#ifndef __fcode__FAttr__
#define __fcode__FAttr__

#include "Buffer.h"
#include <vector>
#include "Code.h"

class FPod;

class FAttr {
public:
    uint16_t name;
    uint16_t len;
    unsigned char *data;
    
    static FAttr *readAttr(FPod *pod, Buffer &buffer);
    virtual void read(FPod *pod, Buffer &buffer){}
};

struct FFacet {
    uint16_t type;
    std::string value;
};

class FFacets : public FAttr {
public:
    std::vector<FFacet> facets;
    virtual void read(FPod *pod, Buffer &buffer);
};

class FSourceFile : public FAttr {
public:
    uint16_t size;
    std::string source;
    virtual void read(FPod *pod, Buffer &buffer);
};

class FLineNumber : public FAttr {
public:
    uint16_t size;
    uint16_t line;
    virtual void read(FPod *pod, Buffer &buffer);
};

struct FLine {
    uint16_t pc;
    uint16_t line;
};

class FLineNumbers : public FAttr {
public:
    std::vector<FLine> lines;
    virtual void read(FPod *pod, Buffer &buffer);
};

struct FTrap {
    uint16_t start;    // pc inclusive
    uint16_t end;      // pc exlcusive
    uint16_t handler;  // pc to call on trap
    uint16_t type;     // Err type to catch (typeRefs.def)
    void *c_handler;
};

class FErrTable : public FAttr {
public:
    std::vector<FTrap> traps;
    virtual void read(FPod *pod, Buffer &buffer);
};

class FParamDefault : public FAttr {
public:
    uint16_t size;
    Code opcodes;
    virtual void read(FPod *pod, Buffer &buffer);
};

class FEnumOrdinal : public FAttr {
    uint16_t size;
    uint16_t ordinal;
    virtual void read(FPod *pod, Buffer &buffer);
};

#endif /* defined(__fcode__FAttr__) */
