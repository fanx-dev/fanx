//
//  main.c
//  run
//
//  Created by yangjiandong on 2017/12/17.
//  Copyright © 2017年 yangjiandong. All rights reserved.
//

#include "runtime.h"
#include "system.h"

//#if FR_RUN
#include "../temp/baseTest.h"

CF_BEGIN

fr_Obj fr_argsArray = NULL;
fr_Obj fr_makeArgArray(fr_Env env, int start, int argc, const char* argv[]);
void fr_onExit();

const char* fr_homeDir = NULL;
const char* fr_envPaths[32] = {0};

CF_END

int main(int argc, const char* argv[]) {
    fr_homeDir = "./";
    fr_envPaths[0] = fr_homeDir;

    fr_Env env = fr_getEnv(NULL);
    baseTest_init__(env);

    int i = 0;
    fr_Obj argsObj = fr_makeArgArray((fr_Env)env, i + 1, argc, argv);
    FObj* args = fr_getPtr((fr_Env)env, argsObj);// makeArgArray(env, i + 1, argc, argv);
    fr_argsArray = fr_newGlobalRef((fr_Env)env, argsObj);

    baseTest_Main_main(env);
    if (env->error) {
        sys_Err_trace(env, env->error);
    }

    fr_onExit();
    
    //test gc
    /*System_sleep(1000);
    fr_allowGc(env);
    fr_gc(env);
    System_sleep(2000);*/

    //fr_gcQuit();
    //fr_releaseEnv(NULL, env);
}

//#endif
