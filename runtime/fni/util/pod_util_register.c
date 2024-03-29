#include "fni_ext.h"

void util_SeededRandom_init_v(fr_Env env, void *param, void *ret);
void util_SeededRandom_next_v(fr_Env env, void *param, void *ret);
void util_SeededRandom_nextBool_v(fr_Env env, void *param, void *ret);
void util_SeededRandom_nextFloat_v(fr_Env env, void *param, void *ret);
void util_SeededRandom_nextBuf_v(fr_Env env, void *param, void *ret);
void util_SecureRandom_init_v(fr_Env env, void *param, void *ret);
void util_SecureRandom_next_v(fr_Env env, void *param, void *ret);
void util_SecureRandom_nextBool_v(fr_Env env, void *param, void *ret);
void util_SecureRandom_nextFloat_v(fr_Env env, void *param, void *ret);
void util_SecureRandom_nextBuf_v(fr_Env env, void *param, void *ret);
void util_Unit_define_v(fr_Env env, void *param, void *ret);
void util_Unit_fromStr_v(fr_Env env, void *param, void *ret);
void util_Unit_list_v(fr_Env env, void *param, void *ret);
void util_Unit_quantities_v(fr_Env env, void *param, void *ret);
void util_Unit_quantity_v(fr_Env env, void *param, void *ret);
void util_Unit_equals_v(fr_Env env, void *param, void *ret);
void util_Unit_hash_v(fr_Env env, void *param, void *ret);
void util_Unit_toStr_v(fr_Env env, void *param, void *ret);
void util_Unit_ids_v(fr_Env env, void *param, void *ret);
void util_Unit_name_v(fr_Env env, void *param, void *ret);
void util_Unit_symbol_v(fr_Env env, void *param, void *ret);
void util_Unit_scale_v(fr_Env env, void *param, void *ret);
void util_Unit_offset_v(fr_Env env, void *param, void *ret);
void util_Unit_definition_v(fr_Env env, void *param, void *ret);
void util_Unit_dim_v(fr_Env env, void *param, void *ret);
void util_Unit_kg_v(fr_Env env, void *param, void *ret);
void util_Unit_m_v(fr_Env env, void *param, void *ret);
void util_Unit_sec_v(fr_Env env, void *param, void *ret);
void util_Unit_K_v(fr_Env env, void *param, void *ret);
void util_Unit_A_v(fr_Env env, void *param, void *ret);
void util_Unit_mol_v(fr_Env env, void *param, void *ret);
void util_Unit_cd_v(fr_Env env, void *param, void *ret);
void util_Unit_mult_v(fr_Env env, void *param, void *ret);
void util_Unit_div_v(fr_Env env, void *param, void *ret);
void util_Unit_convertTo_v(fr_Env env, void *param, void *ret);

void util_register(fr_Fvm vm) {
    fr_registerMethod(vm, "util_SeededRandom_init", util_SeededRandom_init_v);
    fr_registerMethod(vm, "util_SeededRandom_next", util_SeededRandom_next_v);
    fr_registerMethod(vm, "util_SeededRandom_nextBool", util_SeededRandom_nextBool_v);
    fr_registerMethod(vm, "util_SeededRandom_nextFloat", util_SeededRandom_nextFloat_v);
    fr_registerMethod(vm, "util_SeededRandom_nextBuf", util_SeededRandom_nextBuf_v);
    fr_registerMethod(vm, "util_SecureRandom_init", util_SecureRandom_init_v);
    fr_registerMethod(vm, "util_SecureRandom_next", util_SecureRandom_next_v);
    fr_registerMethod(vm, "util_SecureRandom_nextBool", util_SecureRandom_nextBool_v);
    fr_registerMethod(vm, "util_SecureRandom_nextFloat", util_SecureRandom_nextFloat_v);
    fr_registerMethod(vm, "util_SecureRandom_nextBuf", util_SecureRandom_nextBuf_v);
    fr_registerMethod(vm, "util_Unit_define", util_Unit_define_v);
    fr_registerMethod(vm, "util_Unit_fromStr", util_Unit_fromStr_v);
    fr_registerMethod(vm, "util_Unit_list", util_Unit_list_v);
    fr_registerMethod(vm, "util_Unit_quantities", util_Unit_quantities_v);
    fr_registerMethod(vm, "util_Unit_quantity", util_Unit_quantity_v);
    fr_registerMethod(vm, "util_Unit_equals", util_Unit_equals_v);
    fr_registerMethod(vm, "util_Unit_hash", util_Unit_hash_v);
    fr_registerMethod(vm, "util_Unit_toStr", util_Unit_toStr_v);
    fr_registerMethod(vm, "util_Unit_ids", util_Unit_ids_v);
    fr_registerMethod(vm, "util_Unit_name", util_Unit_name_v);
    fr_registerMethod(vm, "util_Unit_symbol", util_Unit_symbol_v);
    fr_registerMethod(vm, "util_Unit_scale", util_Unit_scale_v);
    fr_registerMethod(vm, "util_Unit_offset", util_Unit_offset_v);
    fr_registerMethod(vm, "util_Unit_definition", util_Unit_definition_v);
    fr_registerMethod(vm, "util_Unit_dim", util_Unit_dim_v);
    fr_registerMethod(vm, "util_Unit_kg", util_Unit_kg_v);
    fr_registerMethod(vm, "util_Unit_m", util_Unit_m_v);
    fr_registerMethod(vm, "util_Unit_sec", util_Unit_sec_v);
    fr_registerMethod(vm, "util_Unit_K", util_Unit_K_v);
    fr_registerMethod(vm, "util_Unit_A", util_Unit_A_v);
    fr_registerMethod(vm, "util_Unit_mol", util_Unit_mol_v);
    fr_registerMethod(vm, "util_Unit_cd", util_Unit_cd_v);
    fr_registerMethod(vm, "util_Unit_mult", util_Unit_mult_v);
    fr_registerMethod(vm, "util_Unit_div", util_Unit_div_v);
    fr_registerMethod(vm, "util_Unit_convertTo", util_Unit_convertTo_v);
}
