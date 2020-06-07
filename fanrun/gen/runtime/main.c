//
//  main.c
//  run
//
//  Created by yangjiandong on 2017/12/17.
//  Copyright © 2017年 yangjiandong. All rights reserved.
//

#include "runtime.h"

//#if FR_RUN
#include "../temp/baseTest.h"

int main() {
    fr_Env env = fr_getEnv(NULL);
    baseTest_init__(env);
    
    fr_Err e = baseTest_Main_main(env);
    if (e) {
        sys_Err_trace(env, &e, e);
    }
    
    //test gc
    System_sleep(1000);
    fr_yieldGc(env);
    fr_gc(env);
    System_sleep(2000);
    
    fr_releaseEnv(NULL, env);
}

//#endif
