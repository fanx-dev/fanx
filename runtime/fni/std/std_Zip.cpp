#include "fni_ext.h"
#include "pod_std_native.h"

#include "thirdparty/zip_file.hpp"

#include <iostream>
#include <istream>
#include <streambuf>
#include <string>

using namespace miniz_cpp;

struct ZipFileHandle {
    zip_file* zipper;

    bool isOutMode;
    std::vector<unsigned char> outData;

    std::vector<zip_info> readEntrys;
    int readEntryPos;

    ZipFileHandle() : zipper(NULL), isOutMode(false), readEntryPos(-1) {}

    void close(fr_Env env, fr_Obj self) {
        if (isOutMode) zipper->save(outData);
        flush(env, self);
        
        if (zipper) {
            delete zipper;
            zipper = NULL;
        }
    }

    void flush(fr_Env env, fr_Obj self) {
        if (outData.size() == 0) return;

        fr_Obj array = fr_arrayNew(env, fr_findType(env, "sys", "Int"), 1, outData.size());
        void* p = fr_arrayData(env, array);
        memcpy(p, outData.data(), outData.size());

        static fr_Field f = fr_findField(env, fr_getObjType(env, self), "_out");
        fr_Value val;
        fr_getInstanceField(env, self, f, &val);
        fr_Obj outObj = val.h;
        
        fr_callOnObj(env, outObj, "writeBytes", 1, array);
        outData.clear();
    }
};

struct membuf : std::streambuf
{
    membuf(char* begin, char* end) {
        this->setg(begin, begin, end);
    }

    pos_type seekoff(off_type off, std::ios_base::seekdir dir, std::ios_base::openmode which = std::ios_base::in) override
    {
        if (dir == std::ios_base::cur)
            gbump(off);
        else if (dir == std::ios_base::end)
            setg(eback(), egptr() + off, egptr());
        else if (dir == std::ios_base::beg)
            setg(eback(), eback() + off, egptr());
        return gptr() - eback();
    }

    pos_type seekpos(pos_type sp, std::ios_base::openmode which) override
    {
        return seekoff(sp - pos_type(off_type(0)), std::ios_base::beg, which);
    }
};

static ZipFileHandle *getZipFileHandle(fr_Env env, fr_Obj self) {
    static fr_Field f = fr_findField(env, fr_getObjType(env, self), "handle");
    fr_Value val;
    fr_getInstanceField(env, self, f, &val);
    ZipFileHandle* raw = (ZipFileHandle*)(val.i);
    return raw;
}

void std_Zip_finalize(fr_Env env, fr_Obj self);

static void setZipFileHandle(fr_Env env, fr_Obj self, ZipFileHandle* zh) {
    static fr_Field f = fr_findField(env, fr_getObjType(env, self), "handle");
    fr_Value val;
    val.i = (fr_Int)zh;
    fr_setInstanceField(env, self, f, &val);
    
    fr_Type type = fr_getObjType(env, self);
    fr_registerDestructor(env, type, std_Zip_finalize);
}

static fr_Obj makeZipEntryFile(fr_Env env, zip_info &entry, fr_Obj self) {
    static fr_Method m = NULL;
    static fr_Type type = NULL;
    if (!m) {
        type = fr_findType(env, "std", "ZipEntryFile");
        m = fr_findMethod(env, type, "make");
    }
    fr_Obj entryObj = fr_newObj(env, type, m, 4,
        fr_newStrUtf8(env, entry.filename.c_str()),
        0,
        entry.file_size,
        self
    ).h;
    return entryObj;
}

fr_Obj std_Zip_open(fr_Env env, fr_Obj file) {
    fr_Obj self = fr_newObjS(env, "std", "Zip", "make", 0);
    fr_Value val;
    val.h = file;
    fr_setFieldS(env, self, "_file", val);

    ZipFileHandle* zh = new ZipFileHandle();

    fr_Obj path = fr_callOnObj(env, file, "osPath", 0).h;
    if (!path) {
        fr_throwUnsupported(env);
        return NULL;
    }
    const char* pathStr = fr_getStrUtf8(env, path);
    zh->zipper = new zip_file(pathStr);

    setZipFileHandle(env, self, zh);
    
    return self;
}
fr_Obj std_Zip_read(fr_Env env, fr_Obj in) {
    fr_Obj self = fr_newObjS(env, "std", "Zip", "make", 0);

    ZipFileHandle* zh = new ZipFileHandle();

    fr_Obj buf = fr_callOnObj(env, in, "readAllBuf", 0).h;
    fr_Obj data = fr_callOnObj(env, buf, "unsafeArray", 0).h;
    if (!data) {
        fr_throwUnsupported(env);
        return NULL;
    }

    char* buffer = (char*)fr_arrayData(env, data);
    int len = fr_callOnObj(env, buf, "size", 0).i;
    membuf sbuf(buffer, buffer + len);
    std::istream cppin(&sbuf);
    zh->zipper = new zip_file(cppin);

    setZipFileHandle(env, self, zh);

    fr_Value val;
    val.h = in;
    fr_setFieldS(env, self, "_in", val);
    return self;
}
fr_Obj std_Zip_write(fr_Env env, fr_Obj out) {
    fr_Obj self = fr_newObjS(env, "std", "Zip", "make", 0);

    ZipFileHandle* zh = new ZipFileHandle();
    zh->zipper = new zip_file();
    //zh->outObj = fr_newGlobalRef(env, out);
    zh->isOutMode = true;

    setZipFileHandle(env, self, zh);

    fr_Value val;
    val.h = out;
    fr_setFieldS(env, self, "_out", val);
    return self;
}

static void removeDir(std::vector<zip_info> &entrys) {
    /*for (int i = 0; i < entrys.size(); ++i) {
        std::string& name = entrys[i].name;
        if (name.find('/') == name.size() - 1) {
            entrys.erase(entrys.begin() + i);
            --i;
        }
    }*/
}

fr_Obj std_Zip_contents(fr_Env env, fr_Obj self, fr_Obj exclude) {
    ZipFileHandle* zh = getZipFileHandle(env, self);
    if (zh->zipper == NULL) {
        fr_throwUnsupported(env);
        return NULL;
    }

    fr_Obj list = fr_callMethodS(env, "std", "Map", "make", 1, (fr_Int)64).h;

    std::vector<zip_info> entrys = zh->zipper->infolist();
    removeDir(entrys);

    fr_Method getUri = fr_findMethod(env, fr_findType(env, "std", "File"), "uri");
    fr_Method mapSet = fr_findMethod(env, fr_findType(env, "std", "Map"), "set");
    for (zip_info &entry : entrys) {
        if (exclude != NULL) {
            const char* excludeStr = fr_getStrUtf8(env, exclude);
            if (entry.filename.find(excludeStr) == 0) continue;
            if (strcmp(excludeStr, "fcode") == 0) {
                if (entry.filename.find(".class") != std::string::npos) continue;
            }
        }
        fr_Obj val = makeZipEntryFile(env, entry, self);
        fr_Obj key = fr_callMethod(env, getUri, 1, val).h;

        fr_callMethod(env, mapSet, 3, list, key, val);
    }
    return list;
}
fr_Obj std_Zip_readEntry(fr_Env env, fr_Obj self, fr_Obj uri) {
    ZipFileHandle* zh = getZipFileHandle(env, self);
    if (zh->zipper == NULL) {
        fr_throwUnsupported(env);
        return NULL;
    }
    const char* name = fr_getStrUtf8(env, fr_callOnObj(env, uri, "toStr", 0).h);
    if (name[0] == '/') name = name + 1;

    std::string data;
    try {
        data = zh->zipper->read(name);
    } catch (...) {
        return NULL;
    }

    fr_Obj array = fr_arrayNew(env, fr_findType(env, "sys", "Int"), 1, data.size());
    void* p = fr_arrayData(env, array);
    memcpy(p, data.data(), data.size());
    return array;
}

fr_Obj std_Zip_readNext(fr_Env env, fr_Obj self) {
    ZipFileHandle* zh = getZipFileHandle(env, self);
    if (zh->zipper == NULL) {
        fr_throwUnsupported(env);
        return NULL;
    }
    if (zh->readEntryPos == -1) {
        zh->readEntrys = zh->zipper->infolist();
        removeDir(zh->readEntrys);
        zh->readEntryPos = 0;
    }
    if (zh->readEntrys.size() <= zh->readEntryPos) return NULL;

    zip_info& entry = zh->readEntrys[zh->readEntryPos];
    ++zh->readEntryPos;
    fr_Obj file = makeZipEntryFile(env, entry, self);
    return file;
}

void std_Zip_writeEntry(fr_Env env, fr_Obj self, fr_Obj buf, fr_Obj path, fr_Obj modifyTime, fr_Obj opts) {
    ZipFileHandle* zh = getZipFileHandle(env, self);
    if (zh->zipper == NULL) {
        fr_throwUnsupported(env);
        return;
    }

    fr_Obj data = fr_callOnObj(env, buf, "unsafeArray", 0).h;
    if (!data) {
        fr_throwUnsupported(env);
        return;
    }
    char* buffer = (char*)fr_arrayData(env, data);
    int len = fr_callOnObj(env, buf, "size", 0).i;
    //membuf sbuf(buffer, buffer + len);
    //std::istream in(&sbuf);
    std::string bytes(buffer, len);

    const char* name = fr_getStrUtf8(env, fr_callOnObj(env, path, "toStr", 0).h);
    if (name[0] == '/') name = name + 1;

    zh->zipper->writestr(name, bytes);
    zh->flush(env, self);
}
fr_Bool std_Zip_finish(fr_Env env, fr_Obj self) {
    ZipFileHandle *zh = getZipFileHandle(env, self);
    zh->close(env, self);
    return true;
}
void std_Zip_finalize(fr_Env env, fr_Obj self) {
    ZipFileHandle* zh = getZipFileHandle(env, self);
    zh->close(env, self);
    delete zh;
}
fr_Obj std_Zip_gzipOutStream(fr_Env env, fr_Obj out) {
    fr_throwUnsupported(env);
    return 0;
}
fr_Obj std_Zip_gzipInStream(fr_Env env, fr_Obj in) {
    fr_throwUnsupported(env);
    return 0;
}
fr_Obj std_Zip_deflateOutStream(fr_Env env, fr_Obj out, fr_Obj opts) {
    fr_throwUnsupported(env);
    return 0;
}
fr_Obj std_Zip_deflateInStream(fr_Env env, fr_Obj in, fr_Obj opts) {
    fr_throwUnsupported(env);
    return 0;
}
