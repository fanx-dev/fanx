#include "fni_ext.h"
#include "pod_std_native.h"
#include <filesystem>
#include <chrono>
#include <fstream>

namespace fs = std::filesystem;

fr_Bool std_FileSystem_exists(fr_Env env, fr_Obj path) {
    const char* str = fr_getStrUtf8(env, path);
    return fs::exists(fs::u8path(str));
}
fr_Int std_FileSystem_size(fr_Env env, fr_Obj path) {
    const char* str = fr_getStrUtf8(env, path);
    return fs::file_size(fs::u8path(str));
}
fr_Int std_FileSystem_modified(fr_Env env, fr_Obj path) {
    const char* str = fr_getStrUtf8(env, path);
    auto ftime = fs::last_write_time(fs::u8path(str));
    uint64_t mills = std::chrono::time_point_cast<std::chrono::milliseconds>(ftime).time_since_epoch().count();
    return mills;
}

fr_Bool std_FileSystem_setModified(fr_Env env, fr_Obj path, fr_Int time) {
    const char* str = fr_getStrUtf8(env, path);
    std::chrono::milliseconds dur(time);
    //std::chrono::time_point<std::chrono::system_clock> dt(dur);
    fs::file_time_type  ftime(dur);
    fs::last_write_time(fs::u8path(str), ftime);
    return true;
}
fr_Obj std_FileSystem_uriToPath(fr_Env env, fr_Obj path) {
    std::string str = fr_getStrUtf8(env, path);

#if _WIN64
    //deal with Windows drive name
    if (str.size() > 3 && str[2] == ':' && str[0] == '/') {
        str = str.substr(1);
    }
#endif
    fs::path p = fs::u8path(str);
    std::string ps = p.string();
    return fr_newStrUtf8(env, ps.c_str());
}
fr_Obj std_FileSystem_pathToUri(fr_Env env, fr_Obj path) {
    const char* str = fr_getStrUtf8(env, path);
    fs::path p = fs::u8path(str);
    std::string ps = p.generic_string();

    //deal with Windows drive name
    if (ps.size() > 2 && ps[1] == ':' && ps[0] != '/') {
        ps = std::string("/") + ps;
    }

    return fr_newStrUtf8(env, ps.c_str());
}
fr_Obj std_FileSystem_list(fr_Env env, fr_Obj path) {
    const char* str = fr_getStrUtf8(env, path);
    fs::path dir = fs::u8path(str);
    fr_Obj list = fr_callMethodS(env, "sys", "List", "make", 1, 8).h;
    for (auto& p : fs::directory_iterator(dir)) {
        std::string pathstr = p.path().string();
        fr_Obj s = fr_newStrUtf8(env, pathstr.c_str());
        fr_callOnObj(env, list, "add", 1, s);
    }
    return list;
}
fr_Obj std_FileSystem_normalize(fr_Env env, fr_Obj path) {
    const char* str = fr_getStrUtf8(env, path);
    fs::path p = fs::u8path(str);
    p = fs::canonical(p);
    std::string pathstr = p.string();
    return fr_newStrUtf8(env, pathstr.c_str());
}
fr_Bool std_FileSystem_createDirs(fr_Env env, fr_Obj path) {
    const char* file = fr_getStrUtf8(env, path);
    std::error_code ec;
    fs::create_directories(fs::u8path(file), ec);
    return ec.value() == 0;
}
fr_Bool std_FileSystem_createFile(fr_Env env, fr_Obj path) {
    const char* file = fr_getStrUtf8(env, path);
    std::ofstream fileStream;
    fileStream.open(file, std::ios::out);
    return true;
}
fr_Bool std_FileSystem_moveTo(fr_Env env, fr_Obj path, fr_Obj to) {
    const char* fromFile = fr_getStrUtf8(env, path);
    const char* toFile = fr_getStrUtf8(env, to);
    std::error_code ec;
    fs::rename(fromFile, toFile, ec);
    return ec.value() == 0;
}
fr_Bool std_FileSystem_copyTo(fr_Env env, fr_Obj path, fr_Obj to) {
    const char* fromFile = fr_getStrUtf8(env, path);
    const char* toFile = fr_getStrUtf8(env, to);
    const auto copyOptions = fs::copy_options::update_existing
                           | fs::copy_options::overwrite_existing;

    std::error_code ec;
    fs::copy_file(fromFile, toFile, copyOptions, ec);
    return ec.value() == 0;
}
fr_Bool std_FileSystem_delete_(fr_Env env, fr_Obj path) {
    const char* file = fr_getStrUtf8(env, path);
    std::error_code ec;
    fs::remove_all(fs::u8path(file), ec);
    return ec.value() == 0;
}
//fr_Bool std_FileSystem_deleteOnExit(fr_Env env, fr_Obj path) {
//    return 0;
//}
fr_Bool std_FileSystem_isReadable(fr_Env env, fr_Obj path) {
    const char* file = fr_getStrUtf8(env, path);
    fs::file_status st = fs::status(fs::u8path(file));
    return (st.permissions() & fs::perms::owner_read) != fs::perms::none;
}
fr_Bool std_FileSystem_isWritable(fr_Env env, fr_Obj path) {
    const char* file = fr_getStrUtf8(env, path);
    fs::file_status st = fs::status(fs::u8path(file));
    return (st.permissions() & fs::perms::owner_write) != fs::perms::none;
}
fr_Bool std_FileSystem_isExecutable(fr_Env env, fr_Obj path) {
    const char* file = fr_getStrUtf8(env, path);
    fs::file_status st = fs::status(fs::u8path(file));
    return (st.permissions() & fs::perms::owner_exec) != fs::perms::none;
}
fr_Bool std_FileSystem_isDir(fr_Env env, fr_Obj path) {
    const char* file = fr_getStrUtf8(env, path);
    return fs::is_directory(fs::u8path(file));
}
fr_Bool std_FileSystem_getSpaceInfo(fr_Env env, fr_Obj path, fr_Obj out) {
    const char* file = fr_getStrUtf8(env, path);
    std::error_code ec;
    std::filesystem::space_info info = fs::space(fs::u8path(file), ec);

    if (ec.value()) return false;

    fr_Value val;
    val.i = info.capacity;
    fr_arraySet(env, out, 0, &val);
    val.i = info.available;
    fr_arraySet(env, out, 1, &val);
    val.i = info.free;
    fr_arraySet(env, out, 2, &val);
    return true;
}
fr_Obj std_FileSystem_osRoots(fr_Env env) {
    fr_Obj list = fr_callMethodS(env, "sys", "List", "make", 1, 8).h;
    fr_callOnObj(env, list, "add", 1, fr_newStrUtf8(env, "/"));
    return list;
}
fr_Obj std_FileSystem_tempDir(fr_Env env) {
    fs::path tempDir = fs::temp_directory_path();
    std::string path = tempDir.string();
    return fr_newStrUtf8(env, path.c_str());
}
fr_Obj std_FileSystem_fileSep(fr_Env env) {
    static fr_Obj pathSep = NULL;
    if (!pathSep) {
#if WIN32
        pathSep = fr_newStrUtf8(env, "\\");
#else
        pathSep = fr_newStrUtf8(env, "/");
#endif
        pathSep = fr_newGlobalRef(env, pathSep);
    }
    return pathSep;
}
fr_Obj std_FileSystem_pathSep(fr_Env env) {
    static fr_Obj pathSep = NULL;
    if (!pathSep) {
#if WIN32
        pathSep = fr_newStrUtf8(env, ";");
#else
        pathSep = fr_newStrUtf8(env, ":");
#endif
        pathSep = fr_newGlobalRef(env, pathSep);
    }
    return pathSep;
}