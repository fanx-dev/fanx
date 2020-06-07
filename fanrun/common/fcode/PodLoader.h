//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by yangjiandong on 15/9/26.
//

#ifndef __vm__PodLoader_
#define __vm__PodLoader_

#include <stdio.h>
#include "FPod.h"
#include <unordered_map>


class PodLoader {
    std::unordered_map<std::string, FPod*> podMap;
    
public:
    bool load(const std::string &path, const std::string &name);
  
    FPod *findPod(const std::string &podName) { return podMap[podName]; }
    
    
    PodLoader();
    ~PodLoader();

private:
};

#endif /* defined(__vm__PodLoader__) */
