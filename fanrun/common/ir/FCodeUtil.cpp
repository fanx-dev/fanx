//
//  FCodeUtil.cpp
//  gen
//
//  Created by yangjiandong on 2017/11/5.
//  Copyright © 2017年 yangjiandong. All rights reserved.
//

#include "FCodeUtil.hpp"
#include "util/escape.h"

namespace FCodeUtil {

    FType *getFTypeFromTypeRef(FPod *pod, uint16_t tid) {
        //Obj's base class
        if (tid == 0xFFFF) {
            return NULL;
        }
        
        FTypeRef &typeRef = pod->typeRefs[tid];
        std::string &podName = pod->names[typeRef.podName];
        std::string &typeName = pod->names[typeRef.typeName];
        
        std::string::size_type pos = typeName.find("^");
        if (pos != std::string::npos) {
            std::string pname = typeName.substr(0, pos);
            std::string cname = typeName.substr(pos+1);
            FPod *curPod = pod->c_loader->findPod(podName);
            auto itr = curPod->c_typeMap.find(pname);
            if (itr == curPod->c_typeMap.end()) {
                throw std::string("Unknow Type:")+typeName;
            }
            FType *ftype = itr->second;
            uint16_t ttid = ftype->findGenericParamBound(cname);
            return getFTypeFromTypeRef(curPod, ttid);
        }
        
        FPod *tpod = pod->c_loader->findPod(podName);
        FType *ttype = tpod->c_typeMap[typeName];
        
        return ttype;
    }

    std::string getTypeRawName(FPod *pod, uint16_t tid) {
        //Obj's base class
        if (tid == 0xFFFF) {
            return "";
        }
        
        FTypeRef &typeRef = pod->typeRefs[tid];
        std::string &podName = pod->names[typeRef.podName];
        std::string &typeName = pod->names[typeRef.typeName];
        
        std::string::size_type pos = typeName.find("^");
        if (pos != std::string::npos) {
            std::string pname = typeName.substr(0, pos);
            std::string cname = typeName.substr(pos+1);
            FPod *curPod = pod->c_loader->findPod(podName);
            auto itr = curPod->c_typeMap.find(pname);
            if (itr == curPod->c_typeMap.end()) {
                throw std::string("Unknow Type:")+typeName;
            }
            FType *ftype = itr->second;
            uint16_t ttid = ftype->findGenericParamBound(cname);
            return getTypeRawName(curPod, ttid);
        }
        std::string res = podName + "::" + typeName;
        return res;
    }
    
    std::string getTypeNsName(FPod *pod, uint16_t tid) {
        //Obj's base class
        if (tid == 0xFFFF) {
            return "";
        }
        
        FTypeRef &typeRef = pod->typeRefs[tid];
        std::string &podName = pod->names[typeRef.podName];
        std::string &typeName = pod->names[typeRef.typeName];
        
        std::string::size_type pos = typeName.find("^");
        if (pos != std::string::npos) {
            std::string pname = typeName.substr(0, pos);
            std::string cname = typeName.substr(pos+1);
            FPod *curPod = pod->c_loader->findPod(podName);
            auto itr = curPod->c_typeMap.find(pname);
            if (itr == curPod->c_typeMap.end()) {
                throw std::string("Unknow Type:")+typeName;
            }
            FType *ftype = itr->second;
            uint16_t ttid = ftype->findGenericParamBound(cname);
            return getTypeNsName(curPod, ttid);
        }
        std::string res = podName + "_" + typeName;
        escape(res);
        return res;
    }
    
    std::string getExtTypeName(const std::string &ext_ame, bool isFunc) {
        std::string extName = ext_ame;
        if (extName[0] != '<') return extName;
        extName = extName.substr(1, extName.size()-2);
        
        // <sys::Ptr^T>
        std::string::size_type pos0 = extName.find("^");
        if (pos0 != std::string::npos) {
            return "sys_Obj";
        }

        if (extName.size() == 0) {
            return "sys_Obj";
        }
        
        if (extName[extName.size()-1] == '?') {
            extName.resize(extName.size()-1);
        }
        int pos = (int)extName.find("::");
        if (pos>0) {
            extName = extName.replace(pos, 2, "_");
        }
        if (isFunc && extName == "sys_Int8") {
            extName = "char";
        }
        return extName;
    }
    
    std::string getTypeDeclName(FPod *pod, uint16_t tid, bool forPass) {
        //Obj's base class
        if (tid == 0xFFFF) {
            return "";
        }
        
        FTypeRef &typeRef = pod->typeRefs[tid];
        std::string &podName = pod->names[typeRef.podName];
        std::string &typeName = pod->names[typeRef.typeName];
        
        std::string::size_type pos = typeName.find("^");
        if (pos != std::string::npos) {
            std::string pname = typeName.substr(0, pos);
            std::string cname = typeName.substr(pos+1);
            FPod *curPod = pod->c_loader->findPod(podName);
            auto itr = curPod->c_typeMap.find(pname);
            if (itr == curPod->c_typeMap.end()) {
                throw std::string("Unknow Type:")+typeName;
            }
            FType *ftype = itr->second;
            uint16_t ttid = ftype->findGenericParamBound(cname);
            return getTypeDeclName(curPod, ttid, forPass);
        }
        
        std::string &sig = typeRef.extName;
        
        std::string res = podName + "_" + typeName;
        if (sig.size() > 0 && sig[sig.size()-1] == '?') {
            res += "_null";
        }
        else if (res == "sys_Ptr") {
            //res = getExtTypeName(sig, true) + "*";
            res = "sys_Ptr";
        }
        else if (FCodeUtil::isBuildinVal(res)) {
            res += sig;
        }
        else if (forPass) {
            if (FCodeUtil::isValueTypeRef(pod, tid)) {
                res += "_pass";
            }
        }
        
        escape(res);
        return res;
    }
    
    bool isBuildinVal(const std::string &name) {
        if (name == "sys_Int" || name == "sys_Bool" || name == "sys_Float" || name == "sys_Ptr") {
            return true;
        }
        if (name == "sys_Int8" || name == "sys_Int16" || name == "sys_Int32" || name == "sys_Int64" ||
            name == "sys_Float32" || name == "sys_Float64") {
            return true;
        }
        return false;
    }
    
    bool isBuildinValType(FType *type) {
        if (type->c_pod->name == "sys") {
            if (type->c_name == "Int" || type->c_name == "Bool" || type->c_name == "Float" || type->c_name == "Ptr") {
                return true;
            }
        }
        return false;
    }

    bool isValueType(FType *type) {
        return isBuildinValType(type);
        //return (type->meta.flags & FFlags::Struct) != 0;
    }
    
    bool isNullableTypeRef(FPod *pod, uint16_t tid) {
        FTypeRef &typeRef = pod->typeRefs[tid];
        //std::string &podName = pod->names[typeRef.podName];
        //std::string &typeName = pod->names[typeRef.typeName];
        std::string &sig = typeRef.extName;
        
        if (sig.size() > 0 && sig[sig.size()-1] == '?') {
            return true;
        }
        return false;
    }
    
    bool isVoid(FPod *pod, uint16_t tid) {
        FTypeRef &typeRef = pod->typeRefs[tid];
        std::string &podName = pod->names[typeRef.podName];
        std::string &typeName = pod->names[typeRef.typeName];
        if (podName == "sys" && typeName == "Void") {
            return true;
        }
        return false;
    }
    
    bool isValueTypeRef(FPod *pod, uint16_t tid) {
        if (isNullableTypeRef(pod, tid)) return false;
        FTypeRef &typeRef = pod->typeRefs[tid];
        std::string &podName = pod->names[typeRef.podName];
        std::string &typeName = pod->names[typeRef.typeName];
        
        std::string::size_type pos = typeName.find("^");
        if (pos != std::string::npos) {
            return false;
        }
        
        FPod *curPod = pod->c_loader->findPod(podName);
        auto itr = curPod->c_typeMap.find(typeName);
        if (itr == curPod->c_typeMap.end()) {
            printf("ERROR: not found typeRef\n");
            return false;
        }
        return isValueType(itr->second);
    }
    
    bool isInheriteOf(const std::string &podName, const std::string &name
                      , FPod *curPod, uint16_t typeRefId) {
        FPod *pod = curPod->c_loader->findPod(podName);
        auto itr = pod->c_typeMap.find(name);
        if (itr == pod->c_typeMap.end()) {
            printf("ERROR: not found typeRef\n");
            return false;
        }
        FType *type = itr->second;
        if (type->meta.self == typeRefId || type->meta.base == typeRefId) {
            return true;
        }
        for (auto t : type->meta.mixin) {
            if (t == typeRefId) {
                return true;
            }
        }
        return false;
    }
    
    std::string getIdentifierName(FPod *pod, uint16_t nid) {
        std::string name = pod->names[nid];
        escape(name);
        return name;
    }
    
    void escapeIdentifierName(std::string &name) {
        escape(name);
    }
    
}//ns
