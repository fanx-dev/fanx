//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by yangjiandong on 15/9/26.
//

#include "PodLoader.h"

PodLoader::PodLoader(){
}

PodLoader::~PodLoader() {
    for (std::unordered_map<std::string, FPod*>::iterator it = podMap.begin();
         it != podMap.end(); ++it) {
        delete it->second;
    }
    podMap.clear();
}

static void string_split(std::string& s, std::string delim,std::vector< std::string >* ret)
{
    size_t last = 0;
    size_t index=s.find(delim,last);
    while (index!=std::string::npos)
    {
        ret->push_back(s.substr(last,index-last));
        last=index+1;
        index=s.find(delim,last);
    }
    if (index-last>0)
    {
        ret->push_back(s.substr(last,index-last));
    }
}

void PodLoader::setEnvPath(const char* envPaths[]) {
    for (int i = 0; envPaths[i] != NULL; ++i) {
        std::string cstr = envPaths[i];
        cstr += "/lib/fan/";
        this->libPaths.push_back(cstr);
    }
}

FPod* PodLoader::findPod(const std::string& podName) {
    if (podMap.find(podName) != podMap.end()) {
        return podMap[podName];
    }

    for (const std::string &path : libPaths) {
        FPod* fpod = doLoad(path, podName);
        if (fpod) {
            return fpod;
        }
    }
    return nullptr;
}

FPod* PodLoader::doLoad(const std::string& path, const std::string& name) {
    if (podMap.find(name) != podMap.end()) {
        return podMap[name];
    }
    std::string file = path + name + ".pod";
    ZipFile* zip = ZipFile::createWithFile(file);

    if (zip == NULL) {
        printf("ERROR: file not found: %s\n", file.c_str());
        return NULL;
    }

    FPod* fpod = new FPod();
    fpod->c_loader = this;

    fpod->load(*zip);
    podMap[fpod->name] = fpod;

    delete zip;

    //parse depends
    std::string depends = fpod->depends;
    std::vector< std::string > dependList;
    string_split(depends, ";", &dependList);
    //depends
    for (int i = 0; i < dependList.size(); ++i) {
        std::string depend = dependList[i];
        std::string::size_type pos = depend.find(" ");
        if (pos != std::string::npos) {
            std::string dependPod = depend.substr(0, pos);
            fpod->c_dependPods.push_back(dependPod);
        }
    }

    return fpod;
}

bool PodLoader::loadAll(const std::string &name) {
  
    FPod *fpod = findPod(name);
    if (fpod == NULL) return false;
    
    //----------------------------------------
    // load all depends
    for (int i=0; i< fpod->c_dependPods.size(); ++i) {
        const std::string &depend = fpod->c_dependPods[i];
        std::string::size_type pos = depend.find(" ");
        if (pos != std::string::npos) {
            std::string dependPod = depend.substr(0, pos);
            findPod(dependPod);
        }
    }
    
    return true;
}

