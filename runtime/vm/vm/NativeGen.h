//
//  NativeGen.h
//  vm
//
//  Created by yangjiandong on 15/9/26.
//  Copyright (c) 2015, yangjiandong. All rights reserved.
//

#ifndef __vm__NativeGen__
#define __vm__NativeGen__

#include <stdio.h>

#include "fcode/Printer.h"
#include "fcode/FPod.h"
#include "PodManager.h"

class NativeGen {
    PodManager *podMgr;
public:
    bool genStub;
    
    enum PrintType {
        pRegisterDef, pRegisterCode
        , pStruct
        , pNatiAll, pNatiArgGet, pNatiArgPass, pNatiLocalDecl
        , pImpeDef, pImpeStub
    };
    
    NativeGen();
    
    void genNative(std::string path, std::string podName, PodManager *podMgr);
private:
    void genNativePod(std::string &path, FPod *pod, Printer *printer, PrintType printType);
    void genNativeType(FPod *pod, FType *type, std::string &preName, Printer *printer, PrintType printType);
    void genNativeMethod(FPod *pod, FType *type, FMethod *method, Printer *printer, PrintType printType);
};

#endif /* defined(__vm__NativeGen__) */
