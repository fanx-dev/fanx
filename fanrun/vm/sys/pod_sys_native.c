#include "pod_sys_native.h"
#include "pod_sys_struct.h"

int sys_Obj__allocSize__() {return sizeof(struct sys_Obj_);}

void sys_Obj_trap(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value retValue;

    fr_getParam(env, param, &value_2, 2);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    retValue.h = sys_Obj_trap_f(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

int sys_Int__allocSize__() {return sizeof(struct sys_Int_);}

void sys_Int_fromStr(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value value_2;
    fr_Bool arg_2; 
    fr_Value retValue;

    fr_getParam(env, param, &value_2, 2);
    arg_2 = value_2.b;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    retValue.i = sys_Int_fromStr_f(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_random(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    retValue.i = sys_Int_random_f(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_privateMake(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    sys_Int_privateMake_f(env, arg_0);
}

void sys_Int_equals(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.b = sys_Int_equals_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_compare(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_compare_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_negate(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_negate_f(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_increment(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_increment_f(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_decrement(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_decrement_f(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_mult(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_mult_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_multFloat(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.f = sys_Int_multFloat_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_div(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_div_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_divFloat(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.f = sys_Int_divFloat_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_mod(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_mod_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_modFloat(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.f = sys_Int_modFloat_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_plus(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_plus_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_plusFloat(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.f = sys_Int_plusFloat_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_minus(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_minus_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_minusFloat(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.f = sys_Int_minusFloat_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_not(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_not_f(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_and(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_and_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_or(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_or_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_xor(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_xor_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_shiftl(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_shiftl_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_shiftr(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_shiftr_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_shifta(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_shifta_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_pow(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_pow_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_toStr(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.h = sys_Int_toStr_f(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_toHex(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.h = sys_Int_toHex_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_toRadix(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value value_2;
    fr_Int arg_2; 
    fr_Value retValue;

    fr_getParam(env, param, &value_2, 2);
    arg_2 = value_2.i;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.h = sys_Int_toRadix_f(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_toChar(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.h = sys_Int_toChar_f(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_toCode(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.h = sys_Int_toCode_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_toFloat(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.f = sys_Int_toFloat_f(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

int sys_Func__allocSize__() {return sizeof(struct sys_Func_);}

void sys_Func_call(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Obj arg_3; 
    fr_Value value_4;
    fr_Obj arg_4; 
    fr_Value value_5;
    fr_Obj arg_5; 
    fr_Value value_6;
    fr_Obj arg_6; 
    fr_Value value_7;
    fr_Obj arg_7; 
    fr_Value value_8;
    fr_Obj arg_8; 
    fr_Value retValue;

    fr_getParam(env, param, &value_8, 8);
    arg_8 = value_8.h;

    fr_getParam(env, param, &value_7, 7);
    arg_7 = value_7.h;

    fr_getParam(env, param, &value_6, 6);
    arg_6 = value_6.h;

    fr_getParam(env, param, &value_5, 5);
    arg_5 = value_5.h;

    fr_getParam(env, param, &value_4, 4);
    arg_4 = value_4.h;

    fr_getParam(env, param, &value_3, 3);
    arg_3 = value_3.h;

    fr_getParam(env, param, &value_2, 2);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    retValue.h = sys_Func_call_f(env, arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7, arg_8);
    *((fr_Value*)ret) = retValue;
}

void sys_BindFunc_call(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Obj arg_3; 
    fr_Value value_4;
    fr_Obj arg_4; 
    fr_Value value_5;
    fr_Obj arg_5; 
    fr_Value value_6;
    fr_Obj arg_6; 
    fr_Value value_7;
    fr_Obj arg_7; 
    fr_Value value_8;
    fr_Obj arg_8; 
    fr_Value retValue;

    fr_getParam(env, param, &value_8, 8);
    arg_8 = value_8.h;

    fr_getParam(env, param, &value_7, 7);
    arg_7 = value_7.h;

    fr_getParam(env, param, &value_6, 6);
    arg_6 = value_6.h;

    fr_getParam(env, param, &value_5, 5);
    arg_5 = value_5.h;

    fr_getParam(env, param, &value_4, 4);
    arg_4 = value_4.h;

    fr_getParam(env, param, &value_3, 3);
    arg_3 = value_3.h;

    fr_getParam(env, param, &value_2, 2);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    retValue.h = sys_BindFunc_call_f(env, arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7, arg_8);
    *((fr_Value*)ret) = retValue;
}

void sys_Str_format(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    retValue.h = sys_Str_format_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

int sys_Bool__allocSize__() {return sizeof(struct sys_Bool_);}

void sys_Bool_equals(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Bool arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.b;


    retValue.b = sys_Bool_equals_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Bool_not(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Bool arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.b;


    retValue.b = sys_Bool_not_f(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Bool_and(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Bool arg_0; 
    fr_Value value_1;
    fr_Bool arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.b;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.b;


    retValue.b = sys_Bool_and_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Bool_or(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Bool arg_0; 
    fr_Value value_1;
    fr_Bool arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.b;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.b;


    retValue.b = sys_Bool_or_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Bool_xor(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Bool arg_0; 
    fr_Value value_1;
    fr_Bool arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.b;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.b;


    retValue.b = sys_Bool_xor_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

int sys_Ptr__allocSize__() {return sizeof(struct sys_Ptr_);}

void sys_Ptr_make(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Ptr arg_0; 

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.p;


    sys_Ptr_make_f(env, arg_0);
}

void sys_Ptr_stackAlloc(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.p = sys_Ptr_stackAlloc_f(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Ptr_load(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Ptr arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.p;


    retValue.h = sys_Ptr_load_f(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Ptr_store(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Ptr arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.p;


    sys_Ptr_store_f(env, arg_0, arg_1);
}

void sys_Ptr_plus(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Ptr arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.p;


    retValue.p = sys_Ptr_plus_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Ptr_set(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Ptr arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 

    fr_getParam(env, param, &value_2, 2);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.p;


    sys_Ptr_set_f(env, arg_0, arg_1, arg_2);
}

void sys_Ptr_get(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Ptr arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.p;


    retValue.h = sys_Ptr_get_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

int sys_Array__allocSize__() {return sizeof(struct sys_Array_);}

void sys_Array_make(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    sys_Array_make_f(env, arg_0, arg_1);
}

void sys_Array_size(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    retValue.i = sys_Array_size_f(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Array_get(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    retValue.h = sys_Array_get_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Array_set(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 

    fr_getParam(env, param, &value_2, 2);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    sys_Array_set_f(env, arg_0, arg_1, arg_2);
}

void sys_Array_realloc(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    retValue.h = sys_Array_realloc_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Array_arraycopy(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value value_2;
    fr_Obj arg_2; 
    fr_Value value_3;
    fr_Int arg_3; 
    fr_Value value_4;
    fr_Int arg_4; 

    fr_getParam(env, param, &value_4, 4);
    arg_4 = value_4.i;

    fr_getParam(env, param, &value_3, 3);
    arg_3 = value_3.i;

    fr_getParam(env, param, &value_2, 2);
    arg_2 = value_2.h;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    sys_Array_arraycopy_f(env, arg_0, arg_1, arg_2, arg_3, arg_4);
}

void sys_Array_fill(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Int arg_2; 

    fr_getParam(env, param, &value_2, 2);
    arg_2 = value_2.i;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    sys_Array_fill_f(env, arg_0, arg_1, arg_2);
}

void sys_Array_finalize(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    sys_Array_finalize_f(env, arg_0);
}

void sys_NativeC_toId(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    retValue.i = sys_NativeC_toId_f(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_NativeC_typeName(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    retValue.h = sys_NativeC_typeName_f(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_NativeC_print(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    sys_NativeC_print_f(env, arg_0);
}

void sys_NativeC_printErr(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    sys_NativeC_printErr_f(env, arg_0);
}

void sys_NativeC_stackTrace(fr_Env env, void *param, void *ret) {
    fr_Value retValue;


    retValue.h = sys_NativeC_stackTrace_f(env);
    *((fr_Value*)ret) = retValue;
}

int sys_Float__allocSize__() {return sizeof(struct sys_Float_);}

void sys_Float_makeBits(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.f = sys_Float_makeBits_f(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_makeBits32(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.f = sys_Float_makeBits32_f(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_fromStr(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Bool arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.b;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    retValue.f = sys_Float_fromStr_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_random(fr_Env env, void *param, void *ret) {
    fr_Value retValue;


    retValue.f = sys_Float_random_f(env);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_equals(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.b = sys_Float_equals_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_isNaN(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.b = sys_Float_isNaN_f(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_negate(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.f = sys_Float_negate_f(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_mult(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.f = sys_Float_mult_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_multInt(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.f = sys_Float_multInt_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_div(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.f = sys_Float_div_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_divInt(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.f = sys_Float_divInt_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_mod(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.f = sys_Float_mod_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_modInt(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.f = sys_Float_modInt_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_plus(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.f = sys_Float_plus_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_plusInt(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.f = sys_Float_plusInt_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_minus(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.f = sys_Float_minus_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_minusInt(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.f = sys_Float_minusInt_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_bits(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.i = sys_Float_bits_f(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_bits32(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.i = sys_Float_bits32_f(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_toStr(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.h = sys_Float_toStr_f(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_toInt(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.i = sys_Float_toInt_f(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_toLocale(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.h = sys_Float_toLocale_f(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Enum_doFromStr(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value value_2;
    fr_Bool arg_2; 
    fr_Value retValue;

    fr_getParam(env, param, &value_2, 2);
    arg_2 = value_2.b;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    retValue.h = sys_Enum_doFromStr_f(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

