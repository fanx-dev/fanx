//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by chunquedong on 15/6/25.
//

#ifndef __zip__ZipFile__
#define __zip__ZipFile__

#include <string>
#include <vector>

#if defined(_MSC_VER)
#include <BaseTsd.h>
typedef SSIZE_T ssize_t;
#endif

#ifndef _unz64_H
typedef struct unz_file_info_s unz_file_info;
#endif

// forward declaration
class ZipFilePrivate;
struct unz_file_info_s;

/**
 * Zip file - reader helper class.
 *
 * It will cache the file list of a particular zip file with positions inside an archive,
 * so it would be much faster to read some particular files or to check their existance.
 *
 * @since v2.0.5
 */
class ZipFile
{
public:
    /**
     * Constructor, open zip file and store file list.
     *
     * @param zipFile Zip file name
     * @param filter The first part of file names, which should be accessible.
     *               For example, "assets/". Other files will be missed.
     *
     * @since v2.0.5
     */
    //ZipFile(const std::string &zipFile);
    static ZipFile *createWithFile(const std::string &zipFile);
    virtual ~ZipFile();
    
    /**
     * Get resource file data from a zip file.
     * @param fileName File name
     * @param[out] pSize If the file read operation succeeds, it will be the data size, otherwise 0.
     * @return Upon success, a pointer to the data is returned, otherwise nullptr.
     * @warning Recall: you are responsible for calling free() on any Non-nullptr pointer returned.
     *
     * @since v2.0.5
     */
    unsigned char *getFileData(const std::string &fileName, ssize_t *size);

    static ZipFile *createWithBuffer(const void* buffer, unsigned long size);
    
    void getNameList(std::vector<std::string> &list);
    
private:
    /* Only used internal for createWithBuffer() */
    ZipFile();
    
    /**
     * Regenerate accessible file list based on a new filter string.
     *
     * @param filter New filter string (first part of files names)
     * @return true whenever zip file is open successfully and it is possible to locate
     *              at least the first file, false otherwise
     *
     * @since v2.0.5
     */
    bool readIndex();
    
    bool initWithBuffer(const void *buffer, unsigned long size);
    
    /** Internal data like zip file pointer / file list array and so on */
    ZipFilePrivate *_data;
};

#endif /* defined(__zip__ZipFile__) */
