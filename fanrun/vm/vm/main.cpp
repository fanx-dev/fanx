//
//  main.cpp
//  vm
//
//  Created by yangjiandong on 15/9/26.
//  Copyright (c) 2015, yangjiandong. All rights reserved.
//

#include <iostream>
#include "Env.h"
#include "NativeGen.h"
#include "Vm.h"
#include <string.h>

CF_BEGIN

void sys_register(fr_Fvm vm);
void std_register(fr_Fvm vm);

fr_Obj fr_argsArray = NULL;
fr_Obj fr_makeArgArray(fr_Env env, int start, int argc, const char* argv[]);
void fr_onExit();

const char* fr_homeDir = NULL;
const char* fr_envPaths[32] = {0};

CF_END

FObj *makeArgArray(Env *env, int start, int argc, const char * argv[]) {
    FType *listType = env->podManager->findType(env, "sys", "List");
    FMethod *listMake = env->podManager->findMethodInType(env, listType, "make", -1);
    fr_TagValue val;
    
    val.type = fr_vtInt;
    val.any.i = 2;
    env->push(&val);
    
//    val.type = fr_vtObj;
//    FType *strType = env->podManager->findType(env, "sys", "Str");
//    val.any.o = env->podManager->getWrappedType(env, strType);
//    env->push(&val);
    
    env->newObj(listType, listMake, 1);
    
    FMethod *listAdd = env->podManager->findMethodInType(env, listType, "add", -1);
    fr_TagValue param;
    param.type = fr_vtObj;
    
    for (int i=start;i<argc; ++i) {
        const char *cstr = argv[i];
        FObj *str = fr_newStrUtf8_(env, cstr);
        param.any.o = str;
        env->push(&param);
        env->callNonVirtual(listAdd, 1);
    }
    env->pop(&val);
    return (FObj*)val.any.o;
}

//-p/Users/yangjiandong/workspace/code/fanx/env/ -d baseTest::BoxingTest.main
int main(int argc, const char * argv[]) {
    char buf[256] = {0};
    const char *libPath = NULL;
    const char *nativeOutPath = NULL;
    int i = 1;
    int debug = 0;
    
    puts(argv[0]);
    
    while (argc > i && argv[i] && argv[i][0] == '-') {
        const char *op = argv[i] + 1;
        switch (op[0]) {
            case 'g': {
                nativeOutPath = op+1;
            }
                break;
            case 'p': {
                strncpy(buf, op+1, 256);
                fr_homeDir = strdup(buf);
            }
                break;
            case 'd': {
                debug = atoi(op+1);
            }
                break;
            default: {
                printf("ignore option:%s\n", argv[i]);
            }
        }
        ++i;
    }
    
    //init homeDir
    if (!fr_homeDir) {
        const char* fanHome = getenv("FANX_HOME");
        if (fanHome == NULL) {
            printf("required -p for fanHome\n");
            return -1;
        }
        fr_homeDir = fanHome;
    }
    strncpy(buf, fr_homeDir, 256);
    strncat(buf, "/lib/fan/", 256);
    libPath = buf;

    //init envPaths
    const char* fr_workDir;
    const char* fanEnvPath = getenv("FANX_ENV_PATH");
    if (fanEnvPath) {
        fr_workDir = fanEnvPath;
        fr_envPaths[0] = fr_workDir;
        fr_envPaths[1] = fr_homeDir;
    }
    else {
        fr_workDir = fr_homeDir;
        fr_envPaths[0] = fr_homeDir;
    }
    
    const char *name = argv[i];
    if (name == NULL) {
        printf("Usage:\n  fan [options] <pod>::<type>.<method> [args]*\n");
        printf("Options:\n");
        printf("  -p\tfanHome\n");
        printf("  -d1\tdebug\n");
        return -1;
    }
    
    char nameBuf[256] = {0};
    strncpy(nameBuf, name, 256);
    char *pod = nameBuf;
    char *type = strstr(nameBuf, "::");
    if (type == NULL) {
        type = (char*)"Main";
    } else {
        *type = 0;
        type = type + 2;
    }
    char *method = strstr(type, ".");
    if (method == NULL) {
        method = (char*)"main";
    } else {
        *method = 0;
        method = method + 1;
    }
    
    PodManager podMgr;
    Fvm vm(&podMgr);
    podMgr.vm = &vm;
    Env *env = vm.getEnv();
    
    podMgr.load(libPath, pod);
    
    //run test
    if (strcmp(pod, "sys") == 0 && strcmp(type, "Test") == 0 && strcmp(method, "main") == 0) {
        if (i+1 < argc) {
            const char *testPos = argv[i+1];
            podMgr.load(libPath, testPos);
        }
    }
    
    sys_register(&vm);
    std_register(&vm);
    
    vm.start();
    env->trace = debug;
    
    fr_Obj argsObj = fr_makeArgArray((fr_Env)env, i + 1, argc, argv);
    FObj* args = fr_getPtr((fr_Env)env, argsObj);// makeArgArray(env, i + 1, argc, argv);
    fr_argsArray = fr_newGlobalRef((fr_Env)env, argsObj);
    
    env->start(pod, type, method, args);

    fr_onExit();
    
    vm.releaseEnv(env);
    env = nullptr;
    vm.stop();

    puts("DONE!");
    System_sleep(1000);
    vm.gc->collect();
    System_sleep(1000);
    //exit(0);
    return 0;
}
