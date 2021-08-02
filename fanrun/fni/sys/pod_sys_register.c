#include "fni_ext.h"

void sys_Obj_trap_v(fr_Env env, void *param, void *ret);
void sys_Obj_isImmutable_v(fr_Env env, void *param, void *ret);
void sys_Enum_doFromStr_v(fr_Env env, void *param, void *ret);
void sys_Array_make_v(fr_Env env, void *param, void *ret);
void sys_Array_size_v(fr_Env env, void *param, void *ret);
void sys_Array_get_v(fr_Env env, void *param, void *ret);
void sys_Array_set_v(fr_Env env, void *param, void *ret);
void sys_Array_realloc_v(fr_Env env, void *param, void *ret);
void sys_Array_arraycopy_v(fr_Env env, void *param, void *ret);
void sys_Array_fill_v(fr_Env env, void *param, void *ret);
void sys_Array_finalize_v(fr_Env env, void *param, void *ret);
void sys_Bool_equals_v(fr_Env env, void *param, void *ret);
void sys_Bool_not__v(fr_Env env, void *param, void *ret);
void sys_Bool_and__v(fr_Env env, void *param, void *ret);
void sys_Bool_or__v(fr_Env env, void *param, void *ret);
void sys_Bool_xor__v(fr_Env env, void *param, void *ret);
void sys_Float_makeBits_v(fr_Env env, void *param, void *ret);
void sys_Float_makeBits32_v(fr_Env env, void *param, void *ret);
void sys_Float_fromStr_v(fr_Env env, void *param, void *ret);
void sys_Float_random_v(fr_Env env, void *param, void *ret);
void sys_Float_equals_v(fr_Env env, void *param, void *ret);
void sys_Float_isNaN_v(fr_Env env, void *param, void *ret);
void sys_Float_negate_v(fr_Env env, void *param, void *ret);
void sys_Float_mult_v(fr_Env env, void *param, void *ret);
void sys_Float_multInt_v(fr_Env env, void *param, void *ret);
void sys_Float_div_v(fr_Env env, void *param, void *ret);
void sys_Float_divInt_v(fr_Env env, void *param, void *ret);
void sys_Float_mod_v(fr_Env env, void *param, void *ret);
void sys_Float_modInt_v(fr_Env env, void *param, void *ret);
void sys_Float_plus_v(fr_Env env, void *param, void *ret);
void sys_Float_plusInt_v(fr_Env env, void *param, void *ret);
void sys_Float_minus_v(fr_Env env, void *param, void *ret);
void sys_Float_minusInt_v(fr_Env env, void *param, void *ret);
void sys_Float_bits_v(fr_Env env, void *param, void *ret);
void sys_Float_bits32_v(fr_Env env, void *param, void *ret);
void sys_Float_toStr_v(fr_Env env, void *param, void *ret);
void sys_Float_toInt_v(fr_Env env, void *param, void *ret);
void sys_Float_toLocale_v(fr_Env env, void *param, void *ret);
void sys_Func_call_v(fr_Env env, void *param, void *ret);
void sys_Func_call__0_v(fr_Env env, void *param, void *ret);
void sys_Func_call__1_v(fr_Env env, void *param, void *ret);
void sys_Func_call__2_v(fr_Env env, void *param, void *ret);
void sys_Func_call__3_v(fr_Env env, void *param, void *ret);
void sys_Func_call__4_v(fr_Env env, void *param, void *ret);
void sys_Func_call__5_v(fr_Env env, void *param, void *ret);
void sys_Func_call__6_v(fr_Env env, void *param, void *ret);
void sys_Func_call__7_v(fr_Env env, void *param, void *ret);
void sys_BindFunc_call_v(fr_Env env, void *param, void *ret);
void sys_BindFunc_call__0_v(fr_Env env, void *param, void *ret);
void sys_BindFunc_call__1_v(fr_Env env, void *param, void *ret);
void sys_BindFunc_call__2_v(fr_Env env, void *param, void *ret);
void sys_BindFunc_call__3_v(fr_Env env, void *param, void *ret);
void sys_BindFunc_call__4_v(fr_Env env, void *param, void *ret);
void sys_BindFunc_call__5_v(fr_Env env, void *param, void *ret);
void sys_BindFunc_call__6_v(fr_Env env, void *param, void *ret);
void sys_BindFunc_call__7_v(fr_Env env, void *param, void *ret);
void sys_Int_fromStr_v(fr_Env env, void *param, void *ret);
void sys_Int_random_v(fr_Env env, void *param, void *ret);
void sys_Int_privateMake_v(fr_Env env, void *param, void *ret);
void sys_Int_equals_v(fr_Env env, void *param, void *ret);
void sys_Int_compare_v(fr_Env env, void *param, void *ret);
void sys_Int_negate_v(fr_Env env, void *param, void *ret);
void sys_Int_increment_v(fr_Env env, void *param, void *ret);
void sys_Int_decrement_v(fr_Env env, void *param, void *ret);
void sys_Int_mult_v(fr_Env env, void *param, void *ret);
void sys_Int_multFloat_v(fr_Env env, void *param, void *ret);
void sys_Int_div_v(fr_Env env, void *param, void *ret);
void sys_Int_divFloat_v(fr_Env env, void *param, void *ret);
void sys_Int_mod_v(fr_Env env, void *param, void *ret);
void sys_Int_modFloat_v(fr_Env env, void *param, void *ret);
void sys_Int_plus_v(fr_Env env, void *param, void *ret);
void sys_Int_plusFloat_v(fr_Env env, void *param, void *ret);
void sys_Int_minus_v(fr_Env env, void *param, void *ret);
void sys_Int_minusFloat_v(fr_Env env, void *param, void *ret);
void sys_Int_not__v(fr_Env env, void *param, void *ret);
void sys_Int_and__v(fr_Env env, void *param, void *ret);
void sys_Int_or__v(fr_Env env, void *param, void *ret);
void sys_Int_xor__v(fr_Env env, void *param, void *ret);
void sys_Int_shiftl_v(fr_Env env, void *param, void *ret);
void sys_Int_shiftr_v(fr_Env env, void *param, void *ret);
void sys_Int_shifta_v(fr_Env env, void *param, void *ret);
void sys_Int_pow_v(fr_Env env, void *param, void *ret);
void sys_Int_toStr_v(fr_Env env, void *param, void *ret);
void sys_Int_toHex_v(fr_Env env, void *param, void *ret);
void sys_Int_toRadix_v(fr_Env env, void *param, void *ret);
void sys_Int_toChar_v(fr_Env env, void *param, void *ret);
void sys_Int_toCode_v(fr_Env env, void *param, void *ret);
void sys_Int_toFloat_v(fr_Env env, void *param, void *ret);
void sys_NativeC_toId_v(fr_Env env, void *param, void *ret);
void sys_NativeC_typeName_v(fr_Env env, void *param, void *ret);
void sys_NativeC_print_v(fr_Env env, void *param, void *ret);
void sys_NativeC_printErr_v(fr_Env env, void *param, void *ret);
void sys_NativeC_stackTrace_v(fr_Env env, void *param, void *ret);
void sys_Ptr_make_v(fr_Env env, void *param, void *ret);
void sys_Ptr_stackAlloc_v(fr_Env env, void *param, void *ret);
void sys_Ptr_load_v(fr_Env env, void *param, void *ret);
void sys_Ptr_store_v(fr_Env env, void *param, void *ret);
void sys_Ptr_plus_v(fr_Env env, void *param, void *ret);
void sys_Ptr_set_v(fr_Env env, void *param, void *ret);
void sys_Ptr_get_v(fr_Env env, void *param, void *ret);
void sys_Str_intern_v(fr_Env env, void *param, void *ret);
void sys_Str_format_v(fr_Env env, void *param, void *ret);

void sys_register(fr_Fvm vm) {
    fr_registerMethod(vm, "sys_Obj_trap", sys_Obj_trap_v);
    fr_registerMethod(vm, "sys_Obj_isImmutable", sys_Obj_isImmutable_v);
    fr_registerMethod(vm, "sys_Enum_doFromStr", sys_Enum_doFromStr_v);
    fr_registerMethod(vm, "sys_Array_make", sys_Array_make_v);
    fr_registerMethod(vm, "sys_Array_size", sys_Array_size_v);
    fr_registerMethod(vm, "sys_Array_get", sys_Array_get_v);
    fr_registerMethod(vm, "sys_Array_set", sys_Array_set_v);
    fr_registerMethod(vm, "sys_Array_realloc", sys_Array_realloc_v);
    fr_registerMethod(vm, "sys_Array_arraycopy", sys_Array_arraycopy_v);
    fr_registerMethod(vm, "sys_Array_fill", sys_Array_fill_v);
    fr_registerMethod(vm, "sys_Array_finalize", sys_Array_finalize_v);
    fr_registerMethod(vm, "sys_Bool_equals", sys_Bool_equals_v);
    fr_registerMethod(vm, "sys_Bool_not", sys_Bool_not__v);
    fr_registerMethod(vm, "sys_Bool_and", sys_Bool_and__v);
    fr_registerMethod(vm, "sys_Bool_or", sys_Bool_or__v);
    fr_registerMethod(vm, "sys_Bool_xor", sys_Bool_xor__v);
    fr_registerMethod(vm, "sys_Float_makeBits", sys_Float_makeBits_v);
    fr_registerMethod(vm, "sys_Float_makeBits32", sys_Float_makeBits32_v);
    fr_registerMethod(vm, "sys_Float_fromStr", sys_Float_fromStr_v);
    fr_registerMethod(vm, "sys_Float_random", sys_Float_random_v);
    fr_registerMethod(vm, "sys_Float_equals", sys_Float_equals_v);
    fr_registerMethod(vm, "sys_Float_isNaN", sys_Float_isNaN_v);
    fr_registerMethod(vm, "sys_Float_negate", sys_Float_negate_v);
    fr_registerMethod(vm, "sys_Float_mult", sys_Float_mult_v);
    fr_registerMethod(vm, "sys_Float_multInt", sys_Float_multInt_v);
    fr_registerMethod(vm, "sys_Float_div", sys_Float_div_v);
    fr_registerMethod(vm, "sys_Float_divInt", sys_Float_divInt_v);
    fr_registerMethod(vm, "sys_Float_mod", sys_Float_mod_v);
    fr_registerMethod(vm, "sys_Float_modInt", sys_Float_modInt_v);
    fr_registerMethod(vm, "sys_Float_plus", sys_Float_plus_v);
    fr_registerMethod(vm, "sys_Float_plusInt", sys_Float_plusInt_v);
    fr_registerMethod(vm, "sys_Float_minus", sys_Float_minus_v);
    fr_registerMethod(vm, "sys_Float_minusInt", sys_Float_minusInt_v);
    fr_registerMethod(vm, "sys_Float_bits", sys_Float_bits_v);
    fr_registerMethod(vm, "sys_Float_bits32", sys_Float_bits32_v);
    fr_registerMethod(vm, "sys_Float_toStr", sys_Float_toStr_v);
    fr_registerMethod(vm, "sys_Float_toInt", sys_Float_toInt_v);
    fr_registerMethod(vm, "sys_Float_toLocale", sys_Float_toLocale_v);
    fr_registerMethod(vm, "sys_Func_call", sys_Func_call_v);
    fr_registerMethod(vm, "sys_Func_call$0", sys_Func_call__0_v);
    fr_registerMethod(vm, "sys_Func_call$1", sys_Func_call__1_v);
    fr_registerMethod(vm, "sys_Func_call$2", sys_Func_call__2_v);
    fr_registerMethod(vm, "sys_Func_call$3", sys_Func_call__3_v);
    fr_registerMethod(vm, "sys_Func_call$4", sys_Func_call__4_v);
    fr_registerMethod(vm, "sys_Func_call$5", sys_Func_call__5_v);
    fr_registerMethod(vm, "sys_Func_call$6", sys_Func_call__6_v);
    fr_registerMethod(vm, "sys_Func_call$7", sys_Func_call__7_v);
    fr_registerMethod(vm, "sys_BindFunc_call", sys_BindFunc_call_v);
    fr_registerMethod(vm, "sys_BindFunc_call$0", sys_BindFunc_call__0_v);
    fr_registerMethod(vm, "sys_BindFunc_call$1", sys_BindFunc_call__1_v);
    fr_registerMethod(vm, "sys_BindFunc_call$2", sys_BindFunc_call__2_v);
    fr_registerMethod(vm, "sys_BindFunc_call$3", sys_BindFunc_call__3_v);
    fr_registerMethod(vm, "sys_BindFunc_call$4", sys_BindFunc_call__4_v);
    fr_registerMethod(vm, "sys_BindFunc_call$5", sys_BindFunc_call__5_v);
    fr_registerMethod(vm, "sys_BindFunc_call$6", sys_BindFunc_call__6_v);
    fr_registerMethod(vm, "sys_BindFunc_call$7", sys_BindFunc_call__7_v);
    fr_registerMethod(vm, "sys_Int_fromStr", sys_Int_fromStr_v);
    fr_registerMethod(vm, "sys_Int_random", sys_Int_random_v);
    fr_registerMethod(vm, "sys_Int_privateMake", sys_Int_privateMake_v);
    fr_registerMethod(vm, "sys_Int_equals", sys_Int_equals_v);
    fr_registerMethod(vm, "sys_Int_compare", sys_Int_compare_v);
    fr_registerMethod(vm, "sys_Int_negate", sys_Int_negate_v);
    fr_registerMethod(vm, "sys_Int_increment", sys_Int_increment_v);
    fr_registerMethod(vm, "sys_Int_decrement", sys_Int_decrement_v);
    fr_registerMethod(vm, "sys_Int_mult", sys_Int_mult_v);
    fr_registerMethod(vm, "sys_Int_multFloat", sys_Int_multFloat_v);
    fr_registerMethod(vm, "sys_Int_div", sys_Int_div_v);
    fr_registerMethod(vm, "sys_Int_divFloat", sys_Int_divFloat_v);
    fr_registerMethod(vm, "sys_Int_mod", sys_Int_mod_v);
    fr_registerMethod(vm, "sys_Int_modFloat", sys_Int_modFloat_v);
    fr_registerMethod(vm, "sys_Int_plus", sys_Int_plus_v);
    fr_registerMethod(vm, "sys_Int_plusFloat", sys_Int_plusFloat_v);
    fr_registerMethod(vm, "sys_Int_minus", sys_Int_minus_v);
    fr_registerMethod(vm, "sys_Int_minusFloat", sys_Int_minusFloat_v);
    fr_registerMethod(vm, "sys_Int_not", sys_Int_not__v);
    fr_registerMethod(vm, "sys_Int_and", sys_Int_and__v);
    fr_registerMethod(vm, "sys_Int_or", sys_Int_or__v);
    fr_registerMethod(vm, "sys_Int_xor", sys_Int_xor__v);
    fr_registerMethod(vm, "sys_Int_shiftl", sys_Int_shiftl_v);
    fr_registerMethod(vm, "sys_Int_shiftr", sys_Int_shiftr_v);
    fr_registerMethod(vm, "sys_Int_shifta", sys_Int_shifta_v);
    fr_registerMethod(vm, "sys_Int_pow", sys_Int_pow_v);
    fr_registerMethod(vm, "sys_Int_toStr", sys_Int_toStr_v);
    fr_registerMethod(vm, "sys_Int_toHex", sys_Int_toHex_v);
    fr_registerMethod(vm, "sys_Int_toRadix", sys_Int_toRadix_v);
    fr_registerMethod(vm, "sys_Int_toChar", sys_Int_toChar_v);
    fr_registerMethod(vm, "sys_Int_toCode", sys_Int_toCode_v);
    fr_registerMethod(vm, "sys_Int_toFloat", sys_Int_toFloat_v);
    fr_registerMethod(vm, "sys_NativeC_toId", sys_NativeC_toId_v);
    fr_registerMethod(vm, "sys_NativeC_typeName", sys_NativeC_typeName_v);
    fr_registerMethod(vm, "sys_NativeC_print", sys_NativeC_print_v);
    fr_registerMethod(vm, "sys_NativeC_printErr", sys_NativeC_printErr_v);
    fr_registerMethod(vm, "sys_NativeC_stackTrace", sys_NativeC_stackTrace_v);
    fr_registerMethod(vm, "sys_Ptr_make", sys_Ptr_make_v);
    fr_registerMethod(vm, "sys_Ptr_stackAlloc", sys_Ptr_stackAlloc_v);
    fr_registerMethod(vm, "sys_Ptr_load", sys_Ptr_load_v);
    fr_registerMethod(vm, "sys_Ptr_store", sys_Ptr_store_v);
    fr_registerMethod(vm, "sys_Ptr_plus", sys_Ptr_plus_v);
    fr_registerMethod(vm, "sys_Ptr_set", sys_Ptr_set_v);
    fr_registerMethod(vm, "sys_Ptr_get", sys_Ptr_get_v);
    fr_registerMethod(vm, "sys_Str_intern", sys_Str_intern_v);
    fr_registerMethod(vm, "sys_Str_format", sys_Str_format_v);
}
