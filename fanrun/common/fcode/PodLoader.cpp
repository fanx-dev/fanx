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

bool PodLoader::load(const std::string &path, const std::string &name) {
    
    if (podMap.find(name) != podMap.end()) {
        return true;
    }
    std::string file = path + name + ".pod";
    ZipFile *zip = ZipFile::createWithFile(file);
    
    if (zip == NULL) {
        printf("ERROR: file not found: %s\n", file.c_str());
        return false;
    }
    
//    std::vector<std::string> nameList;
//    zip.getNameList(nameList);
//    for (int i=0; i<nameList.size(); ++i) {
//        std::string fname = nameList[i];
//        printf("%s\n", fname.c_str());
//    }
    
    FPod *fpod = new FPod();
    fpod->c_loader = this;
    
    fpod->load(*zip);
    podMap[fpod->name] = fpod;
    
    delete zip;
    
    //----------------------------------------
    // load all depends
    //parse depends
    std::string depends = fpod->depends;
    std::vector< std::string > dependList;
    string_split(depends, ";", &dependList);
    
    //load depends
    for (int i=0; i<dependList.size(); ++i) {
        std::string depend = dependList[i];
        std::string::size_type pos = depend.find(" ");
        if (pos != std::string::npos) {
            std::string dependPod = depend.substr(0, pos);
            fpod->c_dependPods.push_back(dependPod);
            load(path, dependPod);
        }
    }
    
    return true;
}

