//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by yangjiandong on 2017/8/20.
//

#include "fcode/PodLoader.h"
#include "PodGen.hpp"

void getDepends(PodLoader &podMgr, const std::string &pod, std::map<std::string, FPod*> &depends) {
    FPod *fpod = podMgr.findPod(pod);
    if (fpod == NULL) {
        printf("ERROR: not found pod:%s", pod.c_str());
        return;
    }
    
    for (const std::string name : fpod->c_dependPods) {
        getDepends(podMgr, name, depends);
    }
    
    depends[pod] = fpod;
}

// -p/Users/yangjiandong/workspace/code/fanx/env/ -g/Users/yangjiandong/workspace/code/fanrun/gen/temp/ -r baseTest
int main(int argc, const char * argv[]) {
    char buf[256] = { 0 };
    const char* libPath = NULL;
    const char* nativeOutPath = NULL;

    int i = 1;
    bool recursive = false;
    while (argc > i && argv[i] && argv[i][0] == '-') {
        const char* op = argv[i] + 1;
        switch (op[0]) {
        case 'g':
            nativeOutPath = op + 1;
            break;
        case 'p':
            strncpy(buf, op + 1, 256);
            libPath = buf;
            break;
        case 'r':
            recursive = true;
            break;
        default:
            printf("ignore option:%s\n", argv[i]);
        }
        ++i;
    }

    if (libPath == NULL) {
        const char* fanHome = getenv("FANX_HOME");
        if (fanHome == NULL) {
            printf("required -p for fanHome\n");
            return -1;
        }
        strncpy(buf, fanHome, 256);
        libPath = buf;
    }

    const char* name = argv[i];
    if (name == NULL || nativeOutPath == NULL) {
        printf("Usage:\n  gen -pFanHome -gOutputDir podName\n");
        printf("Options:\n");
        printf("  -c\trecursive pod\n");
        return -1;
    }
  
    PodLoader podMgr;
    const char* envPaths[2] = { 0 };
    envPaths[0] = libPath;
    podMgr.setEnvPath(envPaths);
    //podMgr.loadAll(name);
    
    if (recursive) {
        std::map<std::string, FPod*> depends;
        getDepends(podMgr, name, depends);

        for (std::map<std::string, FPod*>::iterator itr = depends.begin(); itr != depends.end(); ++itr) {
            PodGen gen1(&podMgr, itr->first);
            gen1.gen(nativeOutPath);
        }
    }
    else {
        PodGen gen1(&podMgr, name);
        gen1.gen(nativeOutPath);
    }
    
    puts("DONE!");
    return 0;
}
