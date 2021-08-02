//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by chunquedong on 15/6/26.
//

#ifndef __zip__Buffer__
#define __zip__Buffer__

#include <stdio.h>
#include <inttypes.h>
#include <string>

class Buffer {
private:
    uint8_t* data;
    size_t pos;
    size_t _size;
    bool owner;
    
public:
    Buffer();
    Buffer(uint8_t* data, size_t size, bool owner);
    ~Buffer();

    void reset(uint8_t* data, size_t size, bool owner);
    
    size_t getPos() { return pos; }
    bool isEof() { return pos >= _size; }
    size_t size() { return _size; }
    
    uint8_t readUInt8();
    uint16_t readUInt16();
    uint32_t readUInt32();
    uint64_t readUInt64();
    int8_t readInt8();
    int16_t readInt16();
    int32_t readInt32();
    int64_t readInt64();
    float readFloat();
    double readDouble();
    std::string readString();
    
    void readBuf(Buffer& out, bool copy);
    unsigned char* readData(int len, bool copy);
    unsigned char* readBufData(int &len, bool copy);
    
    void seek(int pos);
    void _seek(int p) { pos = p; }
};
#endif /* defined(__zip__Buffer__) */
