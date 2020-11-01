#include "vm.h"

int sys_Obj__allocSize__();
void sys_Obj_trap(fr_Env env, void *param, void *ret);
int sys_Int__allocSize__();
void sys_Int_fromStr(fr_Env env, void *param, void *ret);
void sys_Int_random(fr_Env env, void *param, void *ret);
void sys_Int_privateMake(fr_Env env, void *param, void *ret);
void sys_Int_equals(fr_Env env, void *param, void *ret);
void sys_Int_compare(fr_Env env, void *param, void *ret);
void sys_Int_negate(fr_Env env, void *param, void *ret);
void sys_Int_increment(fr_Env env, void *param, void *ret);
void sys_Int_decrement(fr_Env env, void *param, void *ret);
void sys_Int_mult(fr_Env env, void *param, void *ret);
void sys_Int_multFloat(fr_Env env, void *param, void *ret);
void sys_Int_div(fr_Env env, void *param, void *ret);
void sys_Int_divFloat(fr_Env env, void *param, void *ret);
void sys_Int_mod(fr_Env env, void *param, void *ret);
void sys_Int_modFloat(fr_Env env, void *param, void *ret);
void sys_Int_plus(fr_Env env, void *param, void *ret);
void sys_Int_plusFloat(fr_Env env, void *param, void *ret);
void sys_Int_minus(fr_Env env, void *param, void *ret);
void sys_Int_minusFloat(fr_Env env, void *param, void *ret);
void sys_Int_not(fr_Env env, void *param, void *ret);
void sys_Int_and(fr_Env env, void *param, void *ret);
void sys_Int_or(fr_Env env, void *param, void *ret);
void sys_Int_xor(fr_Env env, void *param, void *ret);
void sys_Int_shiftl(fr_Env env, void *param, void *ret);
void sys_Int_shiftr(fr_Env env, void *param, void *ret);
void sys_Int_shifta(fr_Env env, void *param, void *ret);
void sys_Int_pow(fr_Env env, void *param, void *ret);
void sys_Int_toStr(fr_Env env, void *param, void *ret);
void sys_Int_toHex(fr_Env env, void *param, void *ret);
void sys_Int_toRadix(fr_Env env, void *param, void *ret);
void sys_Int_toChar(fr_Env env, void *param, void *ret);
void sys_Int_toCode(fr_Env env, void *param, void *ret);
void sys_Int_toFloat(fr_Env env, void *param, void *ret);
int sys_Func__allocSize__();
void sys_Func_call(fr_Env env, void *param, void *ret);
void sys_BindFunc_call(fr_Env env, void *param, void *ret);
void sys_Str_format(fr_Env env, void *param, void *ret);
int sys_Bool__allocSize__();
void sys_Bool_equals(fr_Env env, void *param, void *ret);
void sys_Bool_not(fr_Env env, void *param, void *ret);
void sys_Bool_and(fr_Env env, void *param, void *ret);
void sys_Bool_or(fr_Env env, void *param, void *ret);
void sys_Bool_xor(fr_Env env, void *param, void *ret);
int sys_Ptr__allocSize__();
void sys_Ptr_make(fr_Env env, void *param, void *ret);
void sys_Ptr_stackAlloc(fr_Env env, void *param, void *ret);
void sys_Ptr_load(fr_Env env, void *param, void *ret);
void sys_Ptr_store(fr_Env env, void *param, void *ret);
void sys_Ptr_plus(fr_Env env, void *param, void *ret);
void sys_Ptr_set(fr_Env env, void *param, void *ret);
void sys_Ptr_get(fr_Env env, void *param, void *ret);
int sys_Array__allocSize__();
void sys_Array_make(fr_Env env, void *param, void *ret);
void sys_Array_size(fr_Env env, void *param, void *ret);
void sys_Array_get(fr_Env env, void *param, void *ret);
void sys_Array_set(fr_Env env, void *param, void *ret);
void sys_Array_realloc(fr_Env env, void *param, void *ret);
void sys_Array_arraycopy(fr_Env env, void *param, void *ret);
void sys_Array_fill(fr_Env env, void *param, void *ret);
void sys_Array_finalize(fr_Env env, void *param, void *ret);
void sys_NativeC_toId(fr_Env env, void *param, void *ret);
void sys_NativeC_typeName(fr_Env env, void *param, void *ret);
void sys_NativeC_print(fr_Env env, void *param, void *ret);
void sys_NativeC_printErr(fr_Env env, void *param, void *ret);
void sys_NativeC_stackTrace(fr_Env env, void *param, void *ret);
int sys_Float__allocSize__();
void sys_Float_makeBits(fr_Env env, void *param, void *ret);
void sys_Float_makeBits32(fr_Env env, void *param, void *ret);
void sys_Float_fromStr(fr_Env env, void *param, void *ret);
void sys_Float_random(fr_Env env, void *param, void *ret);
void sys_Float_equals(fr_Env env, void *param, void *ret);
void sys_Float_isNaN(fr_Env env, void *param, void *ret);
void sys_Float_negate(fr_Env env, void *param, void *ret);
void sys_Float_mult(fr_Env env, void *param, void *ret);
void sys_Float_multInt(fr_Env env, void *param, void *ret);
void sys_Float_div(fr_Env env, void *param, void *ret);
void sys_Float_divInt(fr_Env env, void *param, void *ret);
void sys_Float_mod(fr_Env env, void *param, void *ret);
void sys_Float_modInt(fr_Env env, void *param, void *ret);
void sys_Float_plus(fr_Env env, void *param, void *ret);
void sys_Float_plusInt(fr_Env env, void *param, void *ret);
void sys_Float_minus(fr_Env env, void *param, void *ret);
void sys_Float_minusInt(fr_Env env, void *param, void *ret);
void sys_Float_bits(fr_Env env, void *param, void *ret);
void sys_Float_bits32(fr_Env env, void *param, void *ret);
void sys_Float_toStr(fr_Env env, void *param, void *ret);
void sys_Float_toInt(fr_Env env, void *param, void *ret);
void sys_Float_toLocale(fr_Env env, void *param, void *ret);
void sys_Enum_doFromStr(fr_Env env, void *param, void *ret);

void sys_register(fr_Fvm vm) {
    fr_registerMethod(vm, "sys_Obj__allocSize__", (fr_NativeFunc)sys_Obj__allocSize__);
    fr_registerMethod(vm, "sys_Obj_trap", sys_Obj_trap);
    fr_registerMethod(vm, "sys_Int__allocSize__", (fr_NativeFunc)sys_Int__allocSize__);
    fr_registerMethod(vm, "sys_Int_fromStr", sys_Int_fromStr);
    fr_registerMethod(vm, "sys_Int_random", sys_Int_random);
    fr_registerMethod(vm, "sys_Int_privateMake", sys_Int_privateMake);
    fr_registerMethod(vm, "sys_Int_equals", sys_Int_equals);
    fr_registerMethod(vm, "sys_Int_compare", sys_Int_compare);
    fr_registerMethod(vm, "sys_Int_negate", sys_Int_negate);
    fr_registerMethod(vm, "sys_Int_increment", sys_Int_increment);
    fr_registerMethod(vm, "sys_Int_decrement", sys_Int_decrement);
    fr_registerMethod(vm, "sys_Int_mult", sys_Int_mult);
    fr_registerMethod(vm, "sys_Int_multFloat", sys_Int_multFloat);
    fr_registerMethod(vm, "sys_Int_div", sys_Int_div);
    fr_registerMethod(vm, "sys_Int_divFloat", sys_Int_divFloat);
    fr_registerMethod(vm, "sys_Int_mod", sys_Int_mod);
    fr_registerMethod(vm, "sys_Int_modFloat", sys_Int_modFloat);
    fr_registerMethod(vm, "sys_Int_plus", sys_Int_plus);
    fr_registerMethod(vm, "sys_Int_plusFloat", sys_Int_plusFloat);
    fr_registerMethod(vm, "sys_Int_minus", sys_Int_minus);
    fr_registerMethod(vm, "sys_Int_minusFloat", sys_Int_minusFloat);
    fr_registerMethod(vm, "sys_Int_not", sys_Int_not);
    fr_registerMethod(vm, "sys_Int_and", sys_Int_and);
    fr_registerMethod(vm, "sys_Int_or", sys_Int_or);
    fr_registerMethod(vm, "sys_Int_xor", sys_Int_xor);
    fr_registerMethod(vm, "sys_Int_shiftl", sys_Int_shiftl);
    fr_registerMethod(vm, "sys_Int_shiftr", sys_Int_shiftr);
    fr_registerMethod(vm, "sys_Int_shifta", sys_Int_shifta);
    fr_registerMethod(vm, "sys_Int_pow", sys_Int_pow);
    fr_registerMethod(vm, "sys_Int_toStr", sys_Int_toStr);
    fr_registerMethod(vm, "sys_Int_toHex", sys_Int_toHex);
    fr_registerMethod(vm, "sys_Int_toRadix", sys_Int_toRadix);
    fr_registerMethod(vm, "sys_Int_toChar", sys_Int_toChar);
    fr_registerMethod(vm, "sys_Int_toCode", sys_Int_toCode);
    fr_registerMethod(vm, "sys_Int_toFloat", sys_Int_toFloat);
    fr_registerMethod(vm, "sys_Func__allocSize__", (fr_NativeFunc)sys_Func__allocSize__);
    fr_registerMethod(vm, "sys_Func_call", sys_Func_call);
    fr_registerMethod(vm, "sys_BindFunc_call", sys_BindFunc_call);
    fr_registerMethod(vm, "sys_Str_format", sys_Str_format);
    fr_registerMethod(vm, "sys_Bool__allocSize__", (fr_NativeFunc)sys_Bool__allocSize__);
    fr_registerMethod(vm, "sys_Bool_equals", sys_Bool_equals);
    fr_registerMethod(vm, "sys_Bool_not", sys_Bool_not);
    fr_registerMethod(vm, "sys_Bool_and", sys_Bool_and);
    fr_registerMethod(vm, "sys_Bool_or", sys_Bool_or);
    fr_registerMethod(vm, "sys_Bool_xor", sys_Bool_xor);
    fr_registerMethod(vm, "sys_Ptr__allocSize__", (fr_NativeFunc)sys_Ptr__allocSize__);
    fr_registerMethod(vm, "sys_Ptr_make", sys_Ptr_make);
    fr_registerMethod(vm, "sys_Ptr_stackAlloc", sys_Ptr_stackAlloc);
    fr_registerMethod(vm, "sys_Ptr_load", sys_Ptr_load);
    fr_registerMethod(vm, "sys_Ptr_store", sys_Ptr_store);
    fr_registerMethod(vm, "sys_Ptr_plus", sys_Ptr_plus);
    fr_registerMethod(vm, "sys_Ptr_set", sys_Ptr_set);
    fr_registerMethod(vm, "sys_Ptr_get", sys_Ptr_get);
    fr_registerMethod(vm, "sys_Array__allocSize__", (fr_NativeFunc)sys_Array__allocSize__);
    fr_registerMethod(vm, "sys_Array_make", sys_Array_make);
    fr_registerMethod(vm, "sys_Array_size", sys_Array_size);
    fr_registerMethod(vm, "sys_Array_get", sys_Array_get);
    fr_registerMethod(vm, "sys_Array_set", sys_Array_set);
    fr_registerMethod(vm, "sys_Array_realloc", sys_Array_realloc);
    fr_registerMethod(vm, "sys_Array_arraycopy", sys_Array_arraycopy);
    fr_registerMethod(vm, "sys_Array_fill", sys_Array_fill);
    fr_registerMethod(vm, "sys_Array_finalize", sys_Array_finalize);
    fr_registerMethod(vm, "sys_NativeC_toId", sys_NativeC_toId);
    fr_registerMethod(vm, "sys_NativeC_typeName", sys_NativeC_typeName);
    fr_registerMethod(vm, "sys_NativeC_print", sys_NativeC_print);
    fr_registerMethod(vm, "sys_NativeC_printErr", sys_NativeC_printErr);
    fr_registerMethod(vm, "sys_NativeC_stackTrace", sys_NativeC_stackTrace);
    fr_registerMethod(vm, "sys_Float__allocSize__", (fr_NativeFunc)sys_Float__allocSize__);
    fr_registerMethod(vm, "sys_Float_makeBits", sys_Float_makeBits);
    fr_registerMethod(vm, "sys_Float_makeBits32", sys_Float_makeBits32);
    fr_registerMethod(vm, "sys_Float_fromStr", sys_Float_fromStr);
    fr_registerMethod(vm, "sys_Float_random", sys_Float_random);
    fr_registerMethod(vm, "sys_Float_equals", sys_Float_equals);
    fr_registerMethod(vm, "sys_Float_isNaN", sys_Float_isNaN);
    fr_registerMethod(vm, "sys_Float_negate", sys_Float_negate);
    fr_registerMethod(vm, "sys_Float_mult", sys_Float_mult);
    fr_registerMethod(vm, "sys_Float_multInt", sys_Float_multInt);
    fr_registerMethod(vm, "sys_Float_div", sys_Float_div);
    fr_registerMethod(vm, "sys_Float_divInt", sys_Float_divInt);
    fr_registerMethod(vm, "sys_Float_mod", sys_Float_mod);
    fr_registerMethod(vm, "sys_Float_modInt", sys_Float_modInt);
    fr_registerMethod(vm, "sys_Float_plus", sys_Float_plus);
    fr_registerMethod(vm, "sys_Float_plusInt", sys_Float_plusInt);
    fr_registerMethod(vm, "sys_Float_minus", sys_Float_minus);
    fr_registerMethod(vm, "sys_Float_minusInt", sys_Float_minusInt);
    fr_registerMethod(vm, "sys_Float_bits", sys_Float_bits);
    fr_registerMethod(vm, "sys_Float_bits32", sys_Float_bits32);
    fr_registerMethod(vm, "sys_Float_toStr", sys_Float_toStr);
    fr_registerMethod(vm, "sys_Float_toInt", sys_Float_toInt);
    fr_registerMethod(vm, "sys_Float_toLocale", sys_Float_toLocale);
    fr_registerMethod(vm, "sys_Enum_doFromStr", sys_Enum_doFromStr);
}