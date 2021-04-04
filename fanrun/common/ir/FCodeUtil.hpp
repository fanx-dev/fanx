//
//  FCodeUtil.hpp
//  gen
//
//  Created by yangjiandong on 2017/11/5.
//  Copyright © 2017年 yangjiandong. All rights reserved.
//

#ifndef FCodeUtil_hpp
#define FCodeUtil_hpp

#include <stdio.h>
#include "../fcode/PodLoader.h"

namespace FCodeUtil {
    std::string getTypeNsName(FPod *pod, uint16_t tid);
    std::string getTypeDeclName(FPod *pod, uint16_t tid, bool forPass = false);
    std::string getExtTypeName(const std::string &ext_ame, bool isFunc = false);
    
    FType *getFTypeFromTypeRef(FPod *pod, uint16_t tid);
    
    bool isValueTypeRef(FPod *curPod, uint16_t typeRefId);
    bool isValueType(FType *type);
    bool isNullableTypeRef(FPod *curPod, uint16_t typeRefId);
    bool isVoid(FPod *curPod, uint16_t typeRefId);
    
    bool isBuildinValType(FType *type);
    bool isBuildinVal(const std::string &name);
    
    bool isInheriteOf(const std::string &pod, const std::string &name
                      , FPod *curPod, uint16_t typeRefId);
        
    std::string getIdentifierName(FPod *pod, uint16_t nid);
    void escapeIdentifierName(std::string &name);
    
}

#endif /* FCodeUtil_hpp */
