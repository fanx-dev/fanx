//
//  main.c
//  run
//
//  Created by yangjiandong on 2017/12/17.
//  Copyright © 2017年 yangjiandong. All rights reserved.
//

#include "runtime.h"
#include "system.h"

#ifdef FR_MAIN
#include "../temp/baseTest.h"
#else
#include "../temp/std.h"
#endif

CF_BEGIN

fr_Obj fr_argsArray = NULL;
fr_Obj fr_makeArgArray(fr_Env env, int start, int argc, const char* argv[]);
void fr_onExit();

const char* fr_homeDir = NULL;
const char* fr_envPaths[32] = {0};


void fr_init(int argc, const char* argv[]) {
    fr_homeDir = "./";
    fr_envPaths[0] = fr_homeDir;

    fr_Env env = fr_getEnv(NULL);
    std_init__(env);

    int i = 0;
    fr_Obj argsObj = fr_makeArgArray((fr_Env)env, i + 1, argc, argv);
    //FObj* args = fr_getPtr((fr_Env)env, argsObj);// makeArgArray(env, i + 1, argc, argv);
    fr_argsArray = fr_newGlobalRef((fr_Env)env, argsObj);
}

#ifdef FR_MAIN
int main(int argc, const char* argv[]) {
    fr_init(argc, argv);

    fr_Env env = fr_getEnv(NULL);
    baseTest_init__(env);

    baseTest_Main_main(env);
    if (env->error) {
        fr_Obj error = env->error;
        fr_clearErr(env);
        sys_Err_trace(env, error);
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
#endif
CF_END
//#endif
