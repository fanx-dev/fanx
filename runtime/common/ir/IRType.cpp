//
//  IRClass.cpp
//  vm
//
//  Created by yangjiandong on 2019/8/16.
//  Copyright © 2019 yangjiandong. All rights reserved.
//

#include "IRType.hpp"
#include "FCodeUtil.hpp"


IRVirtualMethod::IRVirtualMethod() : parent(nullptr), method(nullptr) {

}

IRVirtualMethod::IRVirtualMethod(IRType *parent, FMethod *method) : parent(parent), method(method) {
    
}

bool IRVirtualMethod::isAbstract() {
    return (method->flags & FFlags::Abstract);
}

bool IRVirtualMethod::fromObj() {
    return parent->ftype->c_name == "sys_Obj";
}

IRVTable::IRVTable(IRType *owner, IRType *type) : owner(owner), type(type), baseSize(0) {
}


IRType *IRModule::defType(FType *ftype) {
    IRType *type = new IRType(ftype, this);
    types[ftype->c_mangledName] = type;
    return type;
}

IRType *IRModule::getType(FPod *pod, uint16_t typeRefId) {
    std::string name = FCodeUtil::getTypeNsName(pod, typeRefId);
    std::map<std::string, IRType*>::iterator itr = types.find(name);
    if (itr != types.end())
        return itr->second;
    
    FType *ftype = FCodeUtil::getFTypeFromTypeRef(pod, typeRefId);
    IRType *irtype = new IRType(ftype, this);
    types[name] = irtype;
    return irtype;
}

IRType *IRModule::getTypeByName(FPod *curPod, const std::string &podName, const std::string &typeName) {
    std::string name = podName+"_"+typeName;
    std::map<std::string, IRType*>::iterator itr = types.find(name);
    if (itr != types.end())
        return itr->second;
    
    FPod *tpod = curPod->c_loader->findPod(podName);
    FType *ftype = tpod->c_typeMap[typeName];
    IRType *irtype = new IRType(ftype, this);
    types[name] = irtype;
    return irtype;
}


/////////////////////////////////////////////////////////////////////

int IRVTable::funcOffset(const std::string &name) {
    std::map<std::string, int>::iterator found = position.find(name);
    if (found == position.end()) {
        printf("ERROR: method not found %s\n", name.c_str());
        return -1;
    }
    return found->second;
}

IRType::IRType(FType *ftype, IRModule *module) : isVTableInited(false), ftype(ftype), module(module), llvmStruct(nullptr) {
    fpod = ftype->c_pod;
}

void IRType::inheritMethod(IRType *base, bool isMixin) {
    for (std::map<std::string, IRVirtualMethod>::iterator itr = base->resolvedMethods.begin(); itr != base->resolvedMethods.end(); ++itr) {
        std::map<std::string, IRVirtualMethod>::iterator old = resolvedMethods.find(itr->first);
        if (old != resolvedMethods.end()) {
            if ((old->second.isAbstract() || (isMixin && old->second.fromObj()) )) {
                old->second = itr->second;
            }
        }
        else {
            resolvedMethods[itr->first] = itr->second;
        }
    }
}

void IRType::resolveMethod() {
    
    if (ftype->meta.base != 0xFFFF) {
        IRType *base = module->getType(fpod, ftype->meta.base);
        base->initVTable();
        inheritMethod(base, false);
    }
    
    for (int i=0; i<ftype->meta.mixinCount; ++i) {
        IRType *mixin = module->getType(fpod, ftype->meta.mixin[i]);
        mixin->initVTable();
        inheritMethod(mixin, true);
    }
    
    for (int i =0; i<ftype->methods.size(); ++i) {
        FMethod &m = ftype->methods[i];
        if ((m.flags & FFlags::Static) || (m.flags & FFlags::Ctor)) continue;
        //if ((m.flags & FFlags::Virtual) || (m.flags & FFlags::Abstract) || (m.flags & FFlags::Override)) {
            std::string &name = m.c_stdName;
            IRVirtualMethod vm(this, &m);
            resolvedMethods[name] = vm;
        //}
    }
}

void IRType::setVTable(IRVTable *vtable) {
    for (int i=0; i<vtable->functions.size(); ++i) {
        IRVirtualMethod &vm = vtable->functions[i];
        std::string &name = vm.method->c_stdName;
        
        vtable->position[name] = i;
        
        std::map<std::string, IRVirtualMethod>::iterator itr = resolvedMethods.find(name);
        if (itr == resolvedMethods.end()) {
            printf("ERROR: notfound method: %s\n", name.c_str());
            continue;
        }
        //override method
        vm = itr->second;
    }
}

void IRType::initITable() {
    //get mixin from base
    if (ftype->meta.base != 0xFFFF) {
        IRType *base = module->getType(fpod, ftype->meta.base);
        base->initVTable();
        allMinxin = base->allMinxin;
    }
    
    //get mixin from mixins
    for (int i=0; i<ftype->meta.mixinCount; ++i) {
        IRType *mixin = module->getType(fpod, ftype->meta.mixin[i]);
        mixin->initVTable();
        for (std::map<IRType*, int>::iterator itr = mixin->allMinxin.begin(); itr != mixin->allMinxin.end(); ++itr) {
            allMinxin[itr->first] = itr->second;
        }
        allMinxin[mixin] = 0;
    }
    
    //init mixin vtable
    int index = 0;
    for (std::map<IRType*, int>::iterator itr = this->allMinxin.begin(); itr != this->allMinxin.end(); ++itr) {
        IRType *mixin = itr->first;
        IRVTable *itable = new IRVTable(this, mixin);
        itable->functions = mixin->vtables.at(0)->functions;
        vtables.push_back(itable);
        setVTable(itable);
        
        itr->second = index;
        ++index;
    }
}

void IRType::initMainVTable() {
    //init vtable from base
    IRVTable *vtable = NULL;
    IRType *base = NULL;
    if (((ftype->meta.flags & FFlags::Mixin) == 0) && ftype->meta.base != 0xFFFF) {
        base = module->getType(fpod, ftype->meta.base);
        base->initVTable();
        
        vtable = new IRVTable(this, base);
        vtables.push_back(vtable);
        vtable->functions = base->vtables.at(0)->functions;
        vtable->baseSize = (int)vtable->functions.size();
    }
    else {
        vtable = new IRVTable(this, nullptr);
        vtables.push_back(vtable);
    }
    
    //init vtable from self
    for (int i =0; i<ftype->methods.size(); ++i) {
        FMethod &m = ftype->methods[i];
        
        if ((m.flags & FFlags::Static) || (m.flags & FFlags::Ctor)) continue;
        //always add to vtable, even if non-virtual method. some fcodes has error e.g. CallViritual StrBuf.add
        //if ((m.flags & FFlags::Virtual) || (m.flags & FFlags::Abstract) || (m.flags & FFlags::Override))
        
        if (base == NULL) {
            IRVirtualMethod vm(this, &m);
            vtable->functions.push_back(vm);
            continue;
        }
        
        std::string &name = m.c_stdName;
        std::map<std::string, IRVirtualMethod>::iterator itr = base->resolvedMethods.find(name);
        if (itr == base->resolvedMethods.end()) {
            IRVirtualMethod vm(this, &m);
            vtable->functions.push_back(vm);
        }
    }
    
    setVTable(vtable);
}

void IRType::initVTable() {
    if (isVTableInited) return;
    isVTableInited = true;
    
    resolveMethod();
    
    initMainVTable();
    
    initITable();
}
