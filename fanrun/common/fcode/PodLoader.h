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
    std::vector<std::string> libPaths;
    
public:
    void setEnvPath(const char *envPaths[]);
  
    FPod* findPod(const std::string& podName);
    
    bool loadAll(const std::string& name);
    
    PodLoader();
    ~PodLoader();
private:
    FPod* doLoad(const std::string& path, const std::string& name);
    std::unordered_map<std::string, FPod*>& allPods() { return podMap; }
private:
};

#endif /* defined(__vm__PodLoader__) */
