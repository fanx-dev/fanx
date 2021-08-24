#include "pod_concurrent_native.h"

void concurrent_ConditionVar_init_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    concurrent_ConditionVar_init(env, arg_0, arg_1);
}

void concurrent_ConditionVar_doWait_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Int arg_2; 
    fr_Value retValue;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.i;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = concurrent_ConditionVar_doWait(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

void concurrent_ConditionVar_doSignal_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    concurrent_ConditionVar_doSignal(env, arg_0, arg_1);
}

void concurrent_ConditionVar_doSignalAll_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    concurrent_ConditionVar_doSignalAll(env, arg_0, arg_1);
}

void concurrent_ConditionVar_finalize_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    concurrent_ConditionVar_finalize(env, arg_0);
}

void concurrent_Thread__start_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    concurrent_Thread__start(env, arg_0, arg_1);
}

void concurrent_Thread_detach_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = concurrent_Thread_detach(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void concurrent_Thread_join_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = concurrent_Thread_join(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void concurrent_Thread_id_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = concurrent_Thread_id(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void concurrent_Thread_curId_v(fr_Env env, void *param, void *ret) {
    fr_Value retValue;


    retValue.i = concurrent_Thread_curId(env);
    *((fr_Value*)ret) = retValue;
}

void concurrent_Thread_sleepNanos_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.i;


    retValue.b = concurrent_Thread_sleepNanos(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void concurrent_Thread_finalize_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    concurrent_Thread_finalize(env, arg_0);
}

