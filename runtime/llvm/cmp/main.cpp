//
//  main.cpp
//  cmp
//
//  Created by yangjiandong on 2019/10/4.
//  Copyright © 2019 yangjiandong. All rights reserved.
//

#include "PodLoader.h"
#include "LLVMCompiler.hpp"

int main(int argc, const char * argv[]) {
    std::string libPath = "/Users/yangjiandong/workspace/code/fanx/env";
    std::string pod = "baseTest";
    
    PodLoader podMgr;
    libPath += "/lib/fan/";
    podMgr.load(libPath, pod);
    
    FPod *fpod = podMgr.findPod(pod);
    
    LLVMCompiler compiler;
    compiler.complie(fpod);
    
    puts("DONE!");
    return 0;
}
