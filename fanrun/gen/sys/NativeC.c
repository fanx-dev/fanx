

#include "sys.h"

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


fr_Err sys_NativeC_toId(fr_Env __env, sys_Int *__ret, sys_Obj self){
    *__ret = (int64_t)self;
    return 0;
}
fr_Err sys_NativeC_typeName(fr_Env __env, sys_Str *__ret, sys_Obj self){
    if (self == NULL) {
        *__ret = sys_Str_defVal;
        return NULL;
    }
    fr_Type type = fr_getClass(__env, self);
    const char * name = type->name;
    *__ret = (sys_Str)fr_newStrUtf8(__env, name, strlen(name));
    return NULL;
}

fr_Err sys_NativeC_print(fr_Env __env, sys_Array utf8){
    puts((const char*)utf8->data);
    return 0;
}
fr_Err sys_NativeC_printErr(fr_Env __env, sys_Array utf8){
    fprintf(stderr, "%s\n", (const char*)utf8->data);
    return 0;
}

fr_Err sys_NativeC_stackTrace(fr_Env __env, sys_Str *__ret){
//    void* callstack[128];
//    int i, frames = backtrace(callstack, 128);
//    char** strs = backtrace_symbols(callstack, frames);
//    for (i = 0; i < frames; ++i) {
//        printf("%s\n", strs[i]);
//    }
//    free(strs);
    
    char *data = getTraceString();
    sys_Str str = (sys_Str)fr_newStrUtf8(__env, data, -1);
    free(data);
    *__ret = str;
    return 0;
}
