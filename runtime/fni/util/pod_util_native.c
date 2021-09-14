#include "pod_util_native.h"

void util_SeededRandom_init_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    util_SeededRandom_init(env, arg_0);
}

void util_SeededRandom_next_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = util_SeededRandom_next(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void util_SeededRandom_nextBool_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = util_SeededRandom_nextBool(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void util_SeededRandom_nextFloat_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.f = util_SeededRandom_nextFloat(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void util_SeededRandom_nextBuf_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = util_SeededRandom_nextBuf(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void util_SecureRandom_init_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    util_SecureRandom_init(env, arg_0);
}

void util_SecureRandom_next_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = util_SecureRandom_next(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void util_SecureRandom_nextBool_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = util_SecureRandom_nextBool(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void util_SecureRandom_nextFloat_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.f = util_SecureRandom_nextFloat(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void util_SecureRandom_nextBuf_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = util_SecureRandom_nextBuf(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_define_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = util_Unit_define(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_fromStr_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Bool arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.b;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = util_Unit_fromStr(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_list_v(fr_Env env, void *param, void *ret) {
    fr_Value retValue;


    retValue.h = util_Unit_list(env);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_quantities_v(fr_Env env, void *param, void *ret) {
    fr_Value retValue;


    retValue.h = util_Unit_quantities(env);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_quantity_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = util_Unit_quantity(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_equals_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.b = util_Unit_equals(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_hash_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = util_Unit_hash(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_toStr_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = util_Unit_toStr(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_ids_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = util_Unit_ids(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_name_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = util_Unit_name(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_symbol_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = util_Unit_symbol(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_scale_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.f = util_Unit_scale(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_offset_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.f = util_Unit_offset(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_definition_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = util_Unit_definition(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_dim_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = util_Unit_dim(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_kg_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = util_Unit_kg(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_m_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = util_Unit_m(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_sec_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = util_Unit_sec(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_K_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = util_Unit_K(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_A_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = util_Unit_A(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_mol_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = util_Unit_mol(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_cd_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.i = util_Unit_cd(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_mult_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = util_Unit_mult(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_div_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.h = util_Unit_div(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void util_Unit_convertTo_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value retValue;

    fr_getParam(env, param, &value_2, 2, NULL);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1, NULL);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0, NULL);
    arg_0 = value_0.h;


    retValue.f = util_Unit_convertTo(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

