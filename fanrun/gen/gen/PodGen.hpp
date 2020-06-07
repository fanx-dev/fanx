//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by yangjiandong on 2017/8/20.
//

#ifndef Generator_hpp
#define Generator_hpp

#include <stdio.h>
#include "PodLoader.h"
#include "Printer.h"
#include "TypeGen.h"
#include <unordered_map>
#include "IRType.hpp"

class PodGen {
    IRModule *module;
public:
    PodLoader *podMgr;
    FPod *pod;
    std::string podName;
    
    //all types
    std::vector<TypeGen> allTypes;
    std::vector<TypeGen*> sortedTypes;
    
    std::unordered_map<std::string, TypeGen*> typeMap;
    
public:
    PodGen(PodLoader *podMgr, const std::string& podName);
    ~PodGen();
    void gen(const std::string &path);
private:
    void genHeader(Printer *printer);
    void genNativePrototype(Printer *printer);
    void genImple(Printer *printer);
    void horizontalLine(Printer *printer, const char *name);
    void genConstPool(Printer *printer);
    //void genRegister(Printer *printer);
    //void genStub(Printer *printer);
    void genStaticInit(Printer *printer);
public:
    TypeGen* findType(std::string &name);
private:
    void topoSortType();
};

#endif /* Generator_hpp */
