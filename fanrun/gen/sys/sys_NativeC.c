

#include "sys.h"

#ifndef _MSC_VER
#include <execinfo.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


char *getTraceString() {
    void *array[100];
    int size;
    char **strings;
    size_t i;
    
    int strSize = 0;
    size_t strAlloc;
    size_t nameSize;
    char *str;
    char *name;
    
    str = (char*)malloc(256);
    if (str == NULL) {
        abort();
    }
    strAlloc = 255;
    
    size = backtrace (array, 100);
    strings = backtrace_symbols (array, size);
    if (NULL == strings) {
        str[strSize] = 0;
        return str;
    }
    
    const int OFFSET = 7;
    for (i = OFFSET; i < size; i++) {
        //name = strrchr(strings[i], '/');
        //if (!name) continue;
        name = strings[i];
        
        nameSize = strlen(name)+1;
        if (strSize + nameSize + 1 > strAlloc) {
            strAlloc = (strSize + nameSize + 1)*3/2;
            str = (char*)realloc(str, strAlloc+1);
            if (str == NULL) {
                abort();
            }
        }
        strcpy(str+strSize, name);
        strSize += nameSize;
        str[strSize-1] = '\n';
        str[strSize] = 0;
    }
    free (strings);
    
    str[strSize] = 0;
    return str;
}
#else
//char* getTraceString() { return _strdup("unsupport trace"); }
#include <windows.h>
#include <memory.h>
#include <dbghelp.h>

char *getTraceString(void)
{
    unsigned int   i;
    void* stack[100];
    unsigned short frames;
    SYMBOL_INFO* symbol;
    HANDLE         process;
    
    char *str = (char*)malloc(256);
    if (str == NULL) {
        abort();
    }
    int pos = 0;

    process = GetCurrentProcess();

    SymInitialize(process, NULL, TRUE);

    frames = CaptureStackBackTrace(0, 100, stack, NULL);
    symbol = (SYMBOL_INFO*)calloc(sizeof(SYMBOL_INFO) + 256 * sizeof(char), 1);
    symbol->MaxNameLen = 255;
    symbol->SizeOfStruct = sizeof(SYMBOL_INFO);

    for (i = 0; i < frames; i++)
    {
        SymFromAddr(process, (DWORD64)(stack[i]), 0, symbol);

        pos += snprintf(str+ pos, 256-pos, "%i: %s - 0x%0X\n", frames - i - 1, symbol->Name, symbol->Address);
    }

    free(symbol);
    return str;
}
#endif


sys_Int sys_NativeC_toId(fr_Env __env, sys_Obj self) { return (int64_t)self; }

sys_Str sys_NativeC_typeName(fr_Env __env, sys_Obj self) {
    if (self == NULL) {
        return sys_Str_defVal;
    }
    fr_Type type = fr_getClass(__env, self);
    const char * name = type->name;
    return (sys_Str)fr_newStrUtf8(__env, name, strlen(name));
}

void sys_NativeC_print(fr_Env __env, sys_Array utf8) { puts((const char*)utf8->data); }
void sys_NativeC_printErr(fr_Env __env, sys_Array utf8) { fprintf(stderr, "ERROR:%s\n", (const char*)utf8->data); }
sys_Str sys_NativeC_stackTrace(fr_Env __env) {
    char *data = getTraceString();
    sys_Str str = (sys_Str)fr_newStrUtf8(__env, data, -1);
    free(data);
    return str;
}
