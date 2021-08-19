//
//  IRClass.hpp
//  vm
//
//  Created by yangjiandong on 2019/8/16.
//  Copyright © 2019 yangjiandong. All rights reserved.
//

#ifndef IRClass_hpp
#define IRClass_hpp

#include <stdio.h>
#include "IRMethod.h"
#include <map>

class IRType;

class IRVirtualMethod {
    IRType *parent;
public:
    
    FMethod *method;
    
    IRVirtualMethod();
    
    IRVirtualMethod(IRType *parent, FMethod *method);
    
    bool isAbstract();
    bool fromObj();
};

class IRVTable {
    friend IRType;
public:
    IRType *type;
    IRType *owner;
    int baseSize;
    
    IRVTable(IRType *owner, IRType *type);
    
    std::vector<IRVirtualMethod> functions;
    
    int funcOffset(const std::string &name);
private:
    std::map<std::string, int> position;
};

class IRModule {
public:
    std::map<std::string, IRType*> types;
    IRType *getType(FPod *pod, uint16_t typeRefId);
    IRType *getTypeByName(FPod *curPod, const std::string &podName, const std::string &typeName);
    
    IRType *defType(FType *ftype);
};



class IRType {
    bool isVTableInited;
public:
    FType *ftype;
    FPod *fpod;
    IRModule *module;
    void *llvmStruct;
    
    std::vector<IRVTable*> vtables;
    
    std::map<std::string, IRVirtualMethod> resolvedMethods;
    
    std::map<IRType*, int> allMinxin;
    
public:
    IRType(FType *ftype, IRModule *module);
    void initVTable();
    
private:
    void resolveMethod();
    void inheritMethod(IRType *base, bool isMixin);
    void setVTable(IRVTable *vtable);
    void initITable();
    void initMainVTable();
};

#endif /* IRClass_hpp */
