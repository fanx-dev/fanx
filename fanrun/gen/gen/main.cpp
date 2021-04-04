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

// /Users/yangjiandong/workspace/code/fanx/env/ baseTest /Users/yangjiandong/workspace/code/fanrun/gen/temp/
int main(int argc, const char * argv[]) {
    std::string libPath;
    std::string pod;
    std::string outPath;
    if (argc == 4) {
        libPath = argv[1];
        pod = argv[2];
        outPath = argv[3];
    }
    else {
        printf("Usage: <envPath> <podName> <outputPath>");
        return -1;
    }
  
    PodLoader podMgr;
    libPath += "lib/fan/";
    podMgr.load(libPath, pod);
    
    std::map<std::string, FPod*> depends;
    getDepends(podMgr, pod, depends);
    
    for (std::map<std::string, FPod*>::iterator itr = depends.begin(); itr != depends.end(); ++itr) {
        PodGen gen1(&podMgr, itr->first);
        gen1.gen(outPath);
    }
    
    puts("DONE!");
    return 0;
}
