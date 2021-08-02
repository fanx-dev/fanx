//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by chunquedong on 15/6/26.
//

#include "Buffer.h"
#include <iostream>
#include <stdlib.h>

Buffer::Buffer() :
    data(nullptr), _size(0), owner(false), pos(0) {
}

Buffer::Buffer(uint8_t* data, size_t size, bool owner) :
    data(data), _size(size), owner(owner), pos(0) {
}

Buffer::~Buffer() {
    if (owner) {
        free(data);
    }
}

void Buffer::reset(uint8_t* data, size_t size, bool owner) {
    this->data = data;
    this->_size = size;
    this->owner = owner;
    this->pos = 0;
}

void Buffer::seek(int pos) {
    if (pos < _size) {
        this->pos = pos;
    }
}

uint8_t Buffer::readUInt8() {
    if (pos <= _size - 1)
        return data[pos++];
    else
        return 0;
}

uint16_t Buffer::readUInt16() {
    if (pos <= _size - 2) {
        uint16_t byte1 = data[pos++];
        uint16_t byte2 = data[pos++];
        return ((byte1 << 8) | byte2);
    }
    else {
        return 0;
    }
}

uint32_t Buffer::readUInt32() {
    if (pos <= _size - 4) {
        uint32_t byte1 = data[pos++];
        uint32_t byte2 = data[pos++];
        uint32_t byte3 = data[pos++];
        uint32_t byte4 = data[pos++];
        return ((byte1 << 24) | (byte2 << 16) | (byte3 << 8) | byte4);
    }
    else {
        return 0;
    }
}

uint64_t Buffer::readUInt64() {
    if (pos <= _size - 8) {
        uint64_t byte1 = data[pos++];
        uint64_t byte2 = data[pos++];
        uint64_t byte3 = data[pos++];
        uint64_t byte4 = data[pos++];
        uint64_t byte5 = data[pos++];
        uint64_t byte6 = data[pos++];
        uint64_t byte7 = data[pos++];
        uint64_t byte8 = data[pos++];
        return ((byte1 << 56) | (byte2 << 48) | (byte3 << 40) | (byte4 << 32)
                | (byte5 << 24) | (byte6 << 16) | (byte7 << 8) | byte8);
    }
    else {
        return 0;
    }
}


int8_t Buffer::readInt8() {
    if (pos <= _size - 1)
        return data[pos++];
    else
        return 0;
}

int16_t Buffer::readInt16() {
    if (pos <= _size - 2) {
        int16_t byte1 = data[pos++];
        int16_t byte2 = data[pos++];
        return ((byte1 << 8) | byte2);
    }
    else {
        return 0;
    }
}

int32_t Buffer::readInt32() {
    if (pos <= _size - 4) {
        int32_t byte1 = data[pos++];
        int32_t byte2 = data[pos++];
        int32_t byte3 = data[pos++];
        int32_t byte4 = data[pos++];
        return ((byte1 << 24) | (byte2 << 16) | (byte3 << 8) | byte4);
    }
    else {
        return 0;
    }
}

int64_t Buffer::readInt64() {
    if (pos <= _size - 8) {
        int64_t byte1 = data[pos++];
        int64_t byte2 = data[pos++];
        int64_t byte3 = data[pos++];
        int64_t byte4 = data[pos++];
        int64_t byte5 = data[pos++];
        int64_t byte6 = data[pos++];
        int64_t byte7 = data[pos++];
        int64_t byte8 = data[pos++];
        return ((byte1 << 56) | (byte2 << 48) | (byte3 << 40) | (byte4 << 32)
                | (byte5 << 24) | (byte6 << 16) | (byte7 << 8) | byte8);
    }
    else {
        return 0;
    }
}

float Buffer::readFloat() {
    uint32_t intVal = this->readUInt32();
    return *((float*)&intVal);
}

double Buffer::readDouble() {
    uint64_t intVal = this->readUInt64();
    return *((double*)&intVal);
}

std::string Buffer::readString() {
    uint16_t len = this->readUInt16();
    if (len == 0) {
        return "";
    }
    if (pos <= _size - len) {
        std::string str((char*)&data[pos], len);
        pos += len;
        return std::move(str);
    }
    else {
        return "";
    }
}

unsigned char * Buffer::readData(int len, bool copy) {
    unsigned char *p = data+pos;
    if (pos <= _size - len) {
        pos += len;
    }
    else {
        return NULL;
        //len = _size - pos;
        //pos = _size;
    }

    if (copy) {
        uint8_t* res = (uint8_t*)malloc(len);
        memcpy(res, p, len);
        return res;
    }
    else {
        return p;
    }
}

unsigned char* Buffer::readBufData(int& len, bool copy) {
    size_t size = readUInt16();
    unsigned char* data = readData(size, copy);
    len = size;
    return data;
}

void Buffer::readBuf(Buffer& out, bool copy) {
    int len;
    unsigned char* data = readBufData(len, copy);
    out.pos = 0;
    out._size = len;
    out.data = data;
    out.owner = copy;
}