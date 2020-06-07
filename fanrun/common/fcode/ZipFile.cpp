//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by chunquedong on 15/6/25.
//

#include "ZipFile.h"
#include "unzip.h"
#include <unordered_map>
#include <vector>

#define UNZ_MAXFILENAMEINZIP 256


struct ZipEntryInfo
{
    unz_file_pos pos;
    uLong uncompressed_size;
};

typedef std::unordered_map<std::string, struct ZipEntryInfo> FileListContainer;
class ZipFilePrivate
{
public:
    unzFile zipFile;
    FileListContainer fileList;
    std::vector<std::string> nameList;
};

ZipFile *ZipFile::createWithBuffer(const void* buffer, uLong size)
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
    zip->_data->zipFile = unzOpen(zipFile.c_str());
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
        unzClose(_data->zipFile);
    }
    
    delete (_data);
    _data = NULL;
}

#define CC_BREAK_IF(exp) if(exp) break

bool ZipFile::readIndex()
{
    bool ret = false;
    do
    {
        CC_BREAK_IF(!_data);
        CC_BREAK_IF(!_data->zipFile);
        
        // clear existing file list
        _data->fileList.clear();
        _data->nameList.clear();
        
        // UNZ_MAXFILENAMEINZIP + 1 - it is done so in unzLocateFile
        char szCurrentFileName[UNZ_MAXFILENAMEINZIP + 1];
        unz_file_info64 fileInfo;
        
        int err = unzGoToFirstFile(_data->zipFile);
        while (err == UNZ_OK)
        {
            unz_file_pos posInfo;
            int posErr = unzGetFilePos(_data->zipFile, &posInfo);
            CC_BREAK_IF(posErr != UNZ_OK);
                
            int infoErr = unzGetCurrentFileInfo64(_data->zipFile, &fileInfo, szCurrentFileName, sizeof(szCurrentFileName), NULL, 0, NULL, 0);
            CC_BREAK_IF(infoErr != UNZ_OK);
            
            std::string currentFileName = szCurrentFileName;
            ZipEntryInfo entry;
            entry.pos = posInfo;
            entry.uncompressed_size = (uLong)fileInfo.uncompressed_size;
            _data->fileList[currentFileName] = entry;
            _data->nameList.push_back(currentFileName);
            
            err = unzGoToNextFile(_data->zipFile);
        }
        ret = true;

    } while(false);
    
    return ret;
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
    if (size)
        *size = 0;
    
    do
    {
        CC_BREAK_IF(!_data->zipFile);
        CC_BREAK_IF(fileName.empty());
        
        FileListContainer::const_iterator it = _data->fileList.find(fileName);
        CC_BREAK_IF(it ==  _data->fileList.end());
        
        ZipEntryInfo fileInfo = it->second;
        
        int nRet = unzGoToFilePos(_data->zipFile, &fileInfo.pos);
        CC_BREAK_IF(UNZ_OK != nRet);
        
        nRet = unzOpenCurrentFile(_data->zipFile);
        CC_BREAK_IF(UNZ_OK != nRet);
        
        buffer = (unsigned char*)malloc(fileInfo.uncompressed_size);
        int nSize = unzReadCurrentFile(_data->zipFile, buffer, static_cast<unsigned int>(fileInfo.uncompressed_size));
        if (nSize == 0 || nSize != (int)fileInfo.uncompressed_size) {
            printf("the file size is wrong\n");
            break;
        }
        
        if (size)
        {
            *size = fileInfo.uncompressed_size;
        }
        unzCloseCurrentFile(_data->zipFile);
    } while (0);
    
    return buffer;
}

extern "C" void fill_memory_filefunc(zlib_filefunc_def*);
unzFile unzOpenBuffer(const void* buffer, uLong size)
{
    char path[16] = { 0 };
    zlib_filefunc_def memory_file;
    ::sprintf(path, "%lx+%lx", (uLong)buffer, size);
    ::fill_memory_filefunc(&memory_file);
    return ::unzOpen2(path, &memory_file);
}

bool ZipFile::initWithBuffer(const void *buffer, uLong size)
{
    if (!buffer || size == 0) return false;
    
    _data->zipFile = unzOpenBuffer(buffer, size);
    if (!_data->zipFile) return false;
    
    readIndex();
    return true;
}
