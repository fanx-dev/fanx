#include "std.h"


#if WIN32
#include "windows.h"
#else
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#if !defined(__IOS__) && !defined(__ANDROID__)
#include <sys/dir.h>
#endif
#include <dirent.h>
#endif

std_File std_File_os(fr_Env __env, sys_Str osPath) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
sys_List std_File_osRoots(fr_Env __env) {
	sys_List list = sys_List_make(__env, 4);
	FR_VCALL(sys_List, add, list, (sys_Obj)fr_newStrUtf8(__env, "/", -1));
	return list;
}
std_File std_File_createTemp(fr_Env __env, sys_Str prefix, sys_Str suffix, std_File_null dir) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
std_File std_File_copyTo(fr_Env __env, std_File_ref __self, std_File to, std_Map_null options) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
sys_Str std_File_sep(fr_Env __env) {
	static sys_Str pathSep = NULL;
	if (!pathSep) {
#if WIN32
		pathSep = (sys_Str)fr_newStrUtf8(__env, "\\", -1);
#else
		pathSep = (sys_Str)fr_newStrUtf8(__env, "/", -1);
#endif
		fr_addStaticRef(__env, (fr_Obj*)&pathSep);
	}
	return pathSep;
}
sys_Str std_File_pathSep(fr_Env __env) {
	static sys_Str pathSep = NULL;
	if (!pathSep) {
#if WIN32
		pathSep = (sys_Str)fr_newStrUtf8(__env, ";", -1);
#else
		pathSep = (sys_Str)fr_newStrUtf8(__env, "£º", -1);
#endif
		fr_addStaticRef(__env, (fr_Obj*)&pathSep);
	}
	return pathSep;
}

#if WIN32
bool std_LocalFile_initInfo(fr_Env __env, std_LocalFile_ref __self, const char * _path) {
	HANDLE hFile;
	FILETIME ftCreate, ftAccess, ftWrite;
	DWORD lpFileSizeHigh;
	DWORD lpFileSizeLow;
	DWORD rc;
	unsigned __int64 ll;

	rc = GetFileAttributesA(_path);
	if (rc == INVALID_FILE_ATTRIBUTES) {
		goto error;
	}

	if (rc == FILE_ATTRIBUTE_DIRECTORY) {
		__self->isDir = true;
		__self->exists = true;
		__self->size = 0;
		__self->mtime = (time_t)0;
		return true;
	}
	else {
		__self->isDir = false;
	}


	hFile = CreateFileA(_path, GENERIC_READ, FILE_SHARE_READ, NULL,
		OPEN_EXISTING, 0, NULL);

	if (hFile == INVALID_HANDLE_VALUE) {
		goto error;
	}

	// Retrieve the file times for the file.
	if (!GetFileTime(hFile, &ftCreate, &ftAccess, &ftWrite)) {
		goto error;
	}

	lpFileSizeLow = GetFileSize(hFile, &lpFileSizeHigh);
	if (lpFileSizeLow == INVALID_FILE_SIZE) {
		goto error;
	}

	__self->size = (size_t)lpFileSizeLow;

	//FILETIME to time_t
	ll = (((unsigned __int64)ftWrite.dwHighDateTime) << 32) + ftWrite.dwLowDateTime;
	__self->mtime = (time_t)((unsigned __int64)(ll - 116444736000000000) / 10000);
	__self->exists = true;

	CloseHandle(hFile);
	return true;

error:
	__self->exists = false;
	return false;
}
#else
bool std_LocalFile_initInfo(fr_Env __env, std_LocalFile_ref __self, const char* _path) {
	struct stat stbuf;
	if (stat(_path, &stbuf) == -1) {
		_exists = false;
		return false;
	}
	__self->size = stbuf.st_size;
	__self->isDir = S_ISDIR(stbuf.st_mode);
	__self->mtime = stbuf.st_mtime * 1000;
	__self->exists = true;
	return true;
}
#endif

void std_LocalFile_make(fr_Env __env, std_LocalFile_ref __self, std_Uri uri, sys_Bool checkSlash) {
	std_LocalFile_initInfo(__env, __self, fr_getStrUtf8(__env, uri->pathStr));
	if (__self->isDir && std_Uri_isDir(__env, uri)) {
		if (checkSlash) {
			FR_SET_ERROR_MAKE(sys_IOErr, "Must use trailing slash for dir");
			return;
		}
		else {
			uri = std_Uri_plusSlash(__env, uri);
		}
	}
	std_File_privateMake(__env, (std_File)__self, uri);
}

std_FileStore_null std_LocalFile_store(fr_Env __env, std_LocalFile_ref __self) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
sys_Bool std_LocalFile_exists(fr_Env __env, std_LocalFile_ref __self) {
	return __self->exists;
}
sys_Int std_LocalFile_size(fr_Env __env, std_LocalFile_ref __self) {
	return __self->size;
}
std_TimePoint_null std_LocalFile_modified(fr_Env __env, std_LocalFile_ref __self) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
void std_LocalFile_modified__1(fr_Env __env, std_LocalFile_ref __self, std_TimePoint_null it) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); }
sys_Str_null std_LocalFile_osPath(fr_Env __env, std_LocalFile_ref __self) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
sys_List std_LocalFile_list(fr_Env __env, std_LocalFile_ref __self) {
	const char* _path = fr_getStrUtf8(__env, __self->_uri->pathStr);
	sys_List flist = sys_List_make(__env, 64);
#if WIN32
	WIN32_FIND_DATAA* findFileData;
	HANDLE hFind;
	char* regex = (char*)malloc(strlen(_path) + 3);
	strcpy(regex, _path);
	strcat(regex, "\\*");

	findFileData = (WIN32_FIND_DATAA*)malloc(sizeof(WIN32_FIND_DATAA) * 2);
	hFind = FindFirstFileA(regex, findFileData);
	free(regex);
	if (hFind == INVALID_HANDLE_VALUE)
	{
		free(findFileData);
		//self->second = NULL;
		printf("FindFirstFile failed (%d)\n", (int)GetLastError());
		return flist;
	}

	if (hFind == 0) return NULL;
	findFileData[1] = findFileData[0];

	while (FindNextFileA(hFind, findFileData))
	{
		std_File f = std_File_os(__env, (sys_Str)fr_newStrUtf8(__env, findFileData[1].cFileName, -1));
		FR_VCALL(sys_List, add, flist, (sys_Obj)f);
	}
	FindClose(hFind);
	free(findFileData);
#else
	DIR* dir = opendir(_path.toUtf8().c_str());
	if (dir == NULL) return flist;

	struct dirent* ent = NULL;
	while (NULL != (ent = readdir(dir))) {
		std_File f = std_File_os(__env, (sys_Str)fr_newStrUtf8(__env, ent->d_name, -1));
		FR_VCALL(sys_List, add, flist, (sys_Obj)f);
	}

	closedir(dir);
#endif
	return flist;
}
std_File std_LocalFile_normalize(fr_Env __env, std_LocalFile_ref __self) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
std_File std_LocalFile_create(fr_Env __env, std_LocalFile_ref __self) {
	const char* _path = fr_getStrUtf8(__env, __self->_uri->pathStr);
	bool res = false;
#if WIN32
	if (CreateDirectoryA(_path, NULL)) {
		res = true;
	}
#else
	if (mkdir(_path, S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH) == -1) {
		res = true;
	}
#endif
	if (res == false) {
		FR_SET_ERROR_MAKE(sys_IOErr, "Cannot create dir");
	}
	return (std_File)__self;
}

std_File std_LocalFile_moveTo(fr_Env __env, std_LocalFile_ref __self, std_File to) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
void std_LocalFile_delete_(fr_Env __env, std_LocalFile_ref __self) {
	const char* _path = fr_getStrUtf8(__env, __self->_uri->pathStr);
	bool res = false;
#if WIN32
	if (DeleteFileA(_path)) {
		res = true;
	}
#else
	if (::remove(_path) == 0) {
		res = true;
	}
#endif
	if (res == false) {
		FR_SET_ERROR_MAKE(sys_IOErr, "Cannot delete dir");
	}
}
std_File std_LocalFile_deleteOnExit(fr_Env __env, std_LocalFile_ref __self) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
sys_Bool std_LocalFile_isReadable(fr_Env __env, std_LocalFile_ref __self) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
sys_Bool std_LocalFile_isWritable(fr_Env __env, std_LocalFile_ref __self) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
sys_Bool std_LocalFile_isExecutable(fr_Env __env, std_LocalFile_ref __self) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
std_InStream std_LocalFile_in(fr_Env __env, std_LocalFile_ref __self, sys_Int bufferSize) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
std_OutStream std_LocalFile_out(fr_Env __env, std_LocalFile_ref __self, sys_Bool append, sys_Int bufferSize) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
