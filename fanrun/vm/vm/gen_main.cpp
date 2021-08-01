//
//  gen_main.cpp
//  fni_gen
//
//  Created by yangjiandong on 2021/6/29.
//  Copyright © 2021 yangjiandong. All rights reserved.
//

#include <iostream>
#include "Env.h"
#include "NativeGen.h"
#include "Vm.h"
#include <string.h>

//-pD:/workspace/fanx-dev/fanx/env/ -gD:/workspace/fanx-dev/fanx/fanrun/fni/sys/ sys
int main(int argc, const char * argv[]) {
    char buf[256] = {0};
    const char *libPath = NULL;
    const char *nativeOutPath = NULL;
    int i = 1;
    bool debug = false;
    bool genImplCode = false;
    puts(argv[0]);
    
    while (argc > i && argv[i] && argv[i][0] == '-') {
        const char *op = argv[i] + 1;
        switch (op[0]) {
            case 'g': {
                nativeOutPath = op+1;
            }
                break;
            case 'c': {
                genImplCode = true;
            }
                break;
            case 'p': {
                strncpy(buf, op+1, 256);
                strncat(buf, "lib/fan/", 256);
                libPath = buf;
            }
                break;
            case 'd': {
                debug = true;
            }
                break;
            default: {
                printf("ignore option:%s\n", argv[i]);
            }
        }
        ++i;
    }
    
    if (libPath == NULL) {
        const char *fanHome = getenv("FANX_HOME");
        if (fanHome == NULL) {
            printf("required -p for fanHome\n");
            return -1;
        }
        strncpy(buf, fanHome, 256);
        strncat(buf, "/lib/fan/", 256);
        libPath = buf;
    }
    
    const char *name = argv[i];
    if (name == NULL || nativeOutPath == NULL) {
        printf("Usage:\n  fan -pFanHome -gOutputDir podName\n");
        printf("Options:\n");
        printf("  -d\tdebug\n");
        printf("  -c\tgen prototype code\n");
        return -1;
    }
    
    const char *pod = name;
    PodManager podMgr;
    Fvm vm(&podMgr);
    podMgr.vm = &vm;
    //Env *env = vm.getEnv();
    bool r = podMgr.load(libPath, pod);
    if (!r) {
        return -1;
    }
    
    NativeGen nativeGen;
    nativeGen.genStub = genImplCode;
    nativeGen.genNative(nativeOutPath, pod, &podMgr);
    puts("DONE!");
    return 0;
}
