//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by chunquedong on 15/6/25.
//

#include "ZipFile.h"
#ifndef FR_NO_STD_POD
  #define MINIZ_HEADER_FILE_ONLY
#endif
#include "thirdparty/zip_file.hpp"
#include <unordered_map>
#include <vector>

#define UNZ_MAXFILENAMEINZIP 256

using namespace miniz_cpp;


struct ZipEntryInfo
{
    int pos;
    unsigned long uncompressed_size;
};

typedef std::unordered_map<std::string, struct ZipEntryInfo> FileListContainer;
class ZipFilePrivate
{
public:
    zip_file *zipFile;
    FileListContainer fileList;
    std::vector<std::string> nameList;
};

ZipFile *ZipFile::createWithBuffer(const void* buffer, unsigned long size)
{
    ZipFile *zip = new ZipFile();
    if (zip && zip->initWithBuffer(buffer, size)) {
        return zip;
    } else {
        if (zip) delete zip;
        return nullptr;
    }
}

ZipFile::ZipFile()
: _data(new ZipFilePrivate)
{
    _data->zipFile = nullptr;
}

ZipFile *ZipFile::createWithFile(const std::string &zipFile) {
    ZipFile *zip = new ZipFile();
    zip->_data->zipFile = new zip_file(zipFile.c_str());
    if (zip->_data->zipFile == NULL) {
        delete zip;
        return NULL;
    }
    zip->readIndex();
    return zip;
}

//ZipFile::ZipFile(const std::string &zipFile)
//: _data(new ZipFilePrivate)
//{
//    _data->zipFile = unzOpen(zipFile.c_str());
//    readIndex();
//}

ZipFile::~ZipFile()
{
    if (_data && _data->zipFile)
    {
        delete (_data->zipFile);
    }
    
    delete (_data);
    _data = NULL;
}

#define CC_BREAK_IF(exp) if(exp) break

bool ZipFile::readIndex()
{
    if(!_data || !_data->zipFile) return false;
    
    // clear existing file list
    _data->fileList.clear();
    _data->nameList.clear();
    
    std::vector<zip_info> entrys = _data->zipFile->infolist();
    int i = 0;
    for (zip_info &fileInfo : entrys) {
        ZipEntryInfo entry;
        entry.pos = i;++i;
        entry.uncompressed_size = fileInfo.file_size;
        _data->fileList[fileInfo.filename] = entry;
        _data->nameList.push_back(fileInfo.filename);
    }
    
    return true;
}

void ZipFile::getNameList(std::vector<std::string> &list) {
    //std::unordered_map<std::string, struct ZipEntryInfo>::iterator
    FileListContainer::iterator it = _data->fileList.begin();
    while (it != _data->fileList.end()) {
        list.push_back(it->first);
        ++it;
    }
}

unsigned char *ZipFile::getFileData(const std::string &fileName, ssize_t *size)
{
    unsigned char * buffer = nullptr;
    if (!_data->zipFile->has_file(fileName)) {
        *size = 0;
        return NULL;
    }
    std::string data = _data->zipFile->read(fileName);
    buffer = (unsigned char *)malloc(data.size());
    memcpy(buffer, data.data(), data.size());
    *size = data.size();
    return buffer;
}

bool ZipFile::initWithBuffer(const void *buffer, unsigned long size)
{
    if (!buffer || size == 0) return false;
    
    std::vector<unsigned char> data;
    data.insert(data.end(), (unsigned char*)buffer, (unsigned char*)buffer+size);
    _data->zipFile = new zip_file(data);
    if (!_data->zipFile) return false;
    
    readIndex();
    return true;
}
