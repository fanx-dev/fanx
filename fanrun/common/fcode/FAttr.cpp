//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by yangjiandong on 15/8/15.
//

#include "FAttr.h"
#include "FPod.h"

FAttr *FAttr::readAttr(FPod *pod, Buffer &buffer) {
    uint16_t nameId = buffer.readInt16();
    std::string &name = pod->names[nameId];
    
    if (name == "Facets") {
        FFacets *facets = new FFacets();
        facets->name = nameId;
        facets->len = buffer.readInt16();
        facets->data = NULL;
        facets->read(pod, buffer);
        return facets;
    } else if (name == "SourceFile") {
        
    } else if (name == "LineNumber") {
        
    } else if (name == "LineNumbers") {
        
    } else if (name == "ErrTable") {
        FErrTable *errTable = new FErrTable();
        errTable->name = nameId;
        errTable->len = buffer.readInt16();
        errTable->data = NULL;
        errTable->read(pod, buffer);
        return errTable;
    } else if (name == "ParamDefault") {
        FParamDefault *param = new FParamDefault();
        param->name = nameId;
        //param->len = buffer.readInt16();
        param->data = NULL;
        param->read(pod, buffer);
        return param;
    } else if (name == "EnumOrdinal") {
        
    } else {
        //error;
    }
    
    uint16_t len = buffer.readInt16();
    unsigned char *data = buffer.readData(len);
    return NULL;
}

void FErrTable::read(FPod *pod, Buffer &buffer) {
    //uint16_t size = buffer.readInt16();
    uint16_t count = buffer.readInt16();
    for (int i=0; i<count; ++i) {
        FTrap trap;
        trap.start = buffer.readInt16();
        trap.end = buffer.readInt16();
        trap.handler = buffer.readInt16();
        trap.type = buffer.readInt16();
        traps.push_back(trap);
    }
}

void FParamDefault::read(FPod *pod, Buffer &buffer) {
    opcodes.read(buffer);
}

void FFacets::read(FPod *pod, Buffer &buffer) {
    uint16_t count = buffer.readUInt16();
    facets.resize(count);
    for (int i=0; i<count; ++i) {
        facets[i].type = buffer.readUInt16();
        facets[i].value = buffer.readString();
    }
}
