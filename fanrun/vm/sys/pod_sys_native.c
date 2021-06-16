#include "pod_sys_native.h"
#include "pod_sys_struct.h"

int sys_Obj__allocSize__() {return sizeof(struct sys_Obj_);}

void sys_Obj_trap_v(fr_Env env, void *param, void *ret) {
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


    retValue.h = sys_Obj_trap(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

void sys_Obj_isImmutable_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    retValue.b = sys_Obj_isImmutable(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Enum_doFromStr_v(fr_Env env, void *param, void *ret) {
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


    retValue.h = sys_Enum_doFromStr(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

int sys_Array__allocSize__() {return sizeof(struct sys_Array_);}

void sys_Array_make_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    sys_Array_make(env, arg_0, arg_1);
}

void sys_Array_size_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    retValue.i = sys_Array_size(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Array_get_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    retValue.h = sys_Array_get(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Array_set_v(fr_Env env, void *param, void *ret) {
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


    sys_Array_set(env, arg_0, arg_1, arg_2);
}

void sys_Array_realloc_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    retValue.h = sys_Array_realloc(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Array_arraycopy_v(fr_Env env, void *param, void *ret) {
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


    sys_Array_arraycopy(env, arg_0, arg_1, arg_2, arg_3, arg_4);
}

void sys_Array_fill_v(fr_Env env, void *param, void *ret) {
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


    sys_Array_fill(env, arg_0, arg_1, arg_2);
}

void sys_Array_finalize_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    sys_Array_finalize(env, arg_0);
}

int sys_Bool__allocSize__() {return sizeof(struct sys_Bool_);}

void sys_Bool_equals_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Bool arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.b;


    retValue.b = sys_Bool_equals_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Bool_not__v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Bool arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.b;


    retValue.b = sys_Bool_not__val(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Bool_and__v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Bool arg_0; 
    fr_Value value_1;
    fr_Bool arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.b;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.b;


    retValue.b = sys_Bool_and__val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Bool_or__v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Bool arg_0; 
    fr_Value value_1;
    fr_Bool arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.b;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.b;


    retValue.b = sys_Bool_or__val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Bool_xor__v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Bool arg_0; 
    fr_Value value_1;
    fr_Bool arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.b;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.b;


    retValue.b = sys_Bool_xor__val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

int sys_Float__allocSize__() {return sizeof(struct sys_Float_);}

void sys_Float_makeBits_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.f = sys_Float_makeBits(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_makeBits32_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.f = sys_Float_makeBits32(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_fromStr_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Bool arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.b;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    retValue.f = sys_Float_fromStr(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_random_v(fr_Env env, void *param, void *ret) {
    fr_Value retValue;


    retValue.f = sys_Float_random(env);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_equals_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.b = sys_Float_equals_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_isNaN_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.b = sys_Float_isNaN_val(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_negate_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.f = sys_Float_negate_val(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_mult_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.f = sys_Float_mult_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_multInt_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.f = sys_Float_multInt_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_div_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.f = sys_Float_div_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_divInt_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.f = sys_Float_divInt_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_mod_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.f = sys_Float_mod_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_modInt_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.f = sys_Float_modInt_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_plus_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.f = sys_Float_plus_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_plusInt_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.f = sys_Float_plusInt_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_minus_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.f = sys_Float_minus_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_minusInt_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.f = sys_Float_minusInt_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_bits_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.i = sys_Float_bits_val(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_bits32_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.i = sys_Float_bits32_val(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_toStr_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.h = sys_Float_toStr_val(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_toInt_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.i = sys_Float_toInt_val(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Float_toLocale_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Float arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.f;


    retValue.h = sys_Float_toLocale_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

int sys_Func__allocSize__() {return sizeof(struct sys_Func_);}

void sys_Func_call_v(fr_Env env, void *param, void *ret) {
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


    retValue.h = sys_Func_call(env, arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7, arg_8);
    *((fr_Value*)ret) = retValue;
}

void sys_BindFunc_call_v(fr_Env env, void *param, void *ret) {
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


    retValue.h = sys_BindFunc_call(env, arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7, arg_8);
    *((fr_Value*)ret) = retValue;
}

int sys_Int__allocSize__() {return sizeof(struct sys_Int_);}

void sys_Int_fromStr_v(fr_Env env, void *param, void *ret) {
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


    retValue.i = sys_Int_fromStr(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_random_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    retValue.i = sys_Int_random(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_privateMake_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    sys_Int_privateMake_val(env, arg_0);
}

void sys_Int_equals_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.b = sys_Int_equals_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_compare_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_compare_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_negate_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_negate_val(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_increment_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_increment_val(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_decrement_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_decrement_val(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_mult_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_mult_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_multFloat_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.f = sys_Int_multFloat_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_div_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_div_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_divFloat_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.f = sys_Int_divFloat_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_mod_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_mod_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_modFloat_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.f = sys_Int_modFloat_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_plus_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_plus_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_plusFloat_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.f = sys_Int_plusFloat_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_minus_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_minus_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_minusFloat_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Float arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.f;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.f = sys_Int_minusFloat_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_not__v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_not__val(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_and__v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_and__val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_or__v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_or__val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_xor__v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_xor__val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_shiftl_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_shiftl_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_shiftr_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_shiftr_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_shifta_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_shifta_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_pow_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.i = sys_Int_pow_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_toStr_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.h = sys_Int_toStr_val(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_toHex_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.h = sys_Int_toHex_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_toRadix_v(fr_Env env, void *param, void *ret) {
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


    retValue.h = sys_Int_toRadix_val(env, arg_0, arg_1, arg_2);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_toChar_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.h = sys_Int_toChar_val(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_toCode_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.h = sys_Int_toCode_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Int_toFloat_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.f = sys_Int_toFloat_val(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_NativeC_toId_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    retValue.i = sys_NativeC_toId(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_NativeC_typeName_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    retValue.h = sys_NativeC_typeName(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_NativeC_print_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    sys_NativeC_print(env, arg_0);
}

void sys_NativeC_printErr_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    sys_NativeC_printErr(env, arg_0);
}

void sys_NativeC_stackTrace_v(fr_Env env, void *param, void *ret) {
    fr_Value retValue;


    retValue.h = sys_NativeC_stackTrace(env);
    *((fr_Value*)ret) = retValue;
}

int sys_Ptr__allocSize__() {return sizeof(struct sys_Ptr_);}

void sys_Ptr_make_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Ptr arg_0; 

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.p;


    sys_Ptr_make_val(env, arg_0);
}

void sys_Ptr_stackAlloc_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Int arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.i;


    retValue.p = sys_Ptr_stackAlloc(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Ptr_load_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Ptr arg_0; 
    fr_Value retValue;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.p;


    retValue.h = sys_Ptr_load_val(env, arg_0);
    *((fr_Value*)ret) = retValue;
}

void sys_Ptr_store_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Ptr arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.p;


    sys_Ptr_store_val(env, arg_0, arg_1);
}

void sys_Ptr_plus_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Ptr arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.p;


    retValue.p = sys_Ptr_plus_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Ptr_set_v(fr_Env env, void *param, void *ret) {
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


    sys_Ptr_set_val(env, arg_0, arg_1, arg_2);
}

void sys_Ptr_get_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Ptr arg_0; 
    fr_Value value_1;
    fr_Int arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.i;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.p;


    retValue.h = sys_Ptr_get_val(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

void sys_Str_format_v(fr_Env env, void *param, void *ret) {
    fr_Value value_0;
    fr_Obj arg_0; 
    fr_Value value_1;
    fr_Obj arg_1; 
    fr_Value retValue;

    fr_getParam(env, param, &value_1, 1);
    arg_1 = value_1.h;

    fr_getParam(env, param, &value_0, 0);
    arg_0 = value_0.h;


    retValue.h = sys_Str_format(env, arg_0, arg_1);
    *((fr_Value*)ret) = retValue;
}

