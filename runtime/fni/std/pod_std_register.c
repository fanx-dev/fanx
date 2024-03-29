#ifdef FR_VM
#include "fni_ext.h"

void std_AtomicInt_init_v(fr_Env env, void *param, void *ret);
void std_AtomicInt_val_v(fr_Env env, void *param, void *ret);
void std_AtomicInt_val__1_v(fr_Env env, void *param, void *ret);
void std_AtomicInt_getAndSet_v(fr_Env env, void *param, void *ret);
void std_AtomicInt_compareAndSet_v(fr_Env env, void *param, void *ret);
void std_AtomicInt_getAndAdd_v(fr_Env env, void *param, void *ret);
void std_AtomicInt_addAndGet_v(fr_Env env, void *param, void *ret);
void std_AtomicInt_finalize_v(fr_Env env, void *param, void *ret);
void std_AtomicRef_init_v(fr_Env env, void *param, void *ret);
void std_AtomicRef_val_v(fr_Env env, void *param, void *ret);
void std_AtomicRef_val__1_v(fr_Env env, void *param, void *ret);
void std_AtomicRef_getAndSet_v(fr_Env env, void *param, void *ret);
void std_AtomicRef_compareAndSet_v(fr_Env env, void *param, void *ret);
void std_AtomicRef_finalize_v(fr_Env env, void *param, void *ret);
void std_Lock_init_v(fr_Env env, void *param, void *ret);
void std_Lock_tryLock_v(fr_Env env, void *param, void *ret);
void std_Lock_lock_v(fr_Env env, void *param, void *ret);
void std_Lock_unlock_v(fr_Env env, void *param, void *ret);
void std_Lock_finalize_v(fr_Env env, void *param, void *ret);
void std_AtomicBool_init_v(fr_Env env, void *param, void *ret);
void std_AtomicBool_val_v(fr_Env env, void *param, void *ret);
void std_AtomicBool_val__1_v(fr_Env env, void *param, void *ret);
void std_AtomicBool_getAndSet_v(fr_Env env, void *param, void *ret);
void std_AtomicBool_compareAndSet_v(fr_Env env, void *param, void *ret);
void std_AtomicBool_finalize_v(fr_Env env, void *param, void *ret);
void std_Math_ceil_v(fr_Env env, void *param, void *ret);
void std_Math_floor_v(fr_Env env, void *param, void *ret);
void std_Math_round_v(fr_Env env, void *param, void *ret);
void std_Math_exp_v(fr_Env env, void *param, void *ret);
void std_Math_log_v(fr_Env env, void *param, void *ret);
void std_Math_log10_v(fr_Env env, void *param, void *ret);
void std_Math_pow_v(fr_Env env, void *param, void *ret);
void std_Math_sqrt_v(fr_Env env, void *param, void *ret);
void std_Math_acos_v(fr_Env env, void *param, void *ret);
void std_Math_asin_v(fr_Env env, void *param, void *ret);
void std_Math_atan_v(fr_Env env, void *param, void *ret);
void std_Math_atan2_v(fr_Env env, void *param, void *ret);
void std_Math_cos_v(fr_Env env, void *param, void *ret);
void std_Math_cosh_v(fr_Env env, void *param, void *ret);
void std_Math_sin_v(fr_Env env, void *param, void *ret);
void std_Math_sinh_v(fr_Env env, void *param, void *ret);
void std_Math_tan_v(fr_Env env, void *param, void *ret);
void std_Math_tanh_v(fr_Env env, void *param, void *ret);
void std_Process_env_v(fr_Env env, void *param, void *ret);
void std_Process_outToIn_v(fr_Env env, void *param, void *ret);
void std_Process_run_v(fr_Env env, void *param, void *ret);
void std_Process_join_v(fr_Env env, void *param, void *ret);
void std_Process_kill_v(fr_Env env, void *param, void *ret);
void std_Decimal_fromStr_v(fr_Env env, void *param, void *ret);
void std_Decimal_toDecimal_v(fr_Env env, void *param, void *ret);
void std_Decimal_privateMake_v(fr_Env env, void *param, void *ret);
void std_Decimal_equals_v(fr_Env env, void *param, void *ret);
void std_Decimal_compare_v(fr_Env env, void *param, void *ret);
void std_Decimal_hash_v(fr_Env env, void *param, void *ret);
void std_Decimal_negate_v(fr_Env env, void *param, void *ret);
void std_Decimal_increment_v(fr_Env env, void *param, void *ret);
void std_Decimal_decrement_v(fr_Env env, void *param, void *ret);
void std_Decimal_mult_v(fr_Env env, void *param, void *ret);
void std_Decimal_multInt_v(fr_Env env, void *param, void *ret);
void std_Decimal_multFloat_v(fr_Env env, void *param, void *ret);
void std_Decimal_div_v(fr_Env env, void *param, void *ret);
void std_Decimal_divInt_v(fr_Env env, void *param, void *ret);
void std_Decimal_divFloat_v(fr_Env env, void *param, void *ret);
void std_Decimal_mod_v(fr_Env env, void *param, void *ret);
void std_Decimal_modInt_v(fr_Env env, void *param, void *ret);
void std_Decimal_modFloat_v(fr_Env env, void *param, void *ret);
void std_Decimal_plus_v(fr_Env env, void *param, void *ret);
void std_Decimal_plusInt_v(fr_Env env, void *param, void *ret);
void std_Decimal_plusFloat_v(fr_Env env, void *param, void *ret);
void std_Decimal_minus_v(fr_Env env, void *param, void *ret);
void std_Decimal_minusInt_v(fr_Env env, void *param, void *ret);
void std_Decimal_minusFloat_v(fr_Env env, void *param, void *ret);
void std_Decimal_abs_v(fr_Env env, void *param, void *ret);
void std_Decimal_min_v(fr_Env env, void *param, void *ret);
void std_Decimal_max_v(fr_Env env, void *param, void *ret);
void std_Decimal_toStr_v(fr_Env env, void *param, void *ret);
void std_Decimal_toCode_v(fr_Env env, void *param, void *ret);
void std_Decimal_toInt_v(fr_Env env, void *param, void *ret);
void std_Decimal_toFloat_v(fr_Env env, void *param, void *ret);
void std_Decimal_toLocale_v(fr_Env env, void *param, void *ret);
void std_Zip_open_v(fr_Env env, void *param, void *ret);
void std_Zip_read_v(fr_Env env, void *param, void *ret);
void std_Zip_write_v(fr_Env env, void *param, void *ret);
void std_Zip_contents_v(fr_Env env, void *param, void *ret);
void std_Zip_readNext_v(fr_Env env, void *param, void *ret);
void std_Zip_readEntry_v(fr_Env env, void *param, void *ret);
void std_Zip_writeEntry_v(fr_Env env, void *param, void *ret);
void std_Zip_finish_v(fr_Env env, void *param, void *ret);
void std_Zip_finalize_v(fr_Env env, void *param, void *ret);
void std_Zip_gzipOutStream_v(fr_Env env, void *param, void *ret);
void std_Zip_gzipInStream_v(fr_Env env, void *param, void *ret);
void std_Zip_deflateOutStream_v(fr_Env env, void *param, void *ret);
void std_Zip_deflateInStream_v(fr_Env env, void *param, void *ret);
void std_Regex_init_v(fr_Env env, void *param, void *ret);
void std_Regex_matches_v(fr_Env env, void *param, void *ret);
void std_Regex_matcher_v(fr_Env env, void *param, void *ret);
void std_Regex_split_v(fr_Env env, void *param, void *ret);
void std_Regex_finalize_v(fr_Env env, void *param, void *ret);
void std_RegexMatcher_matches_v(fr_Env env, void *param, void *ret);
void std_RegexMatcher_find_v(fr_Env env, void *param, void *ret);
void std_RegexMatcher_replaceFirst_v(fr_Env env, void *param, void *ret);
void std_RegexMatcher_replaceAll_v(fr_Env env, void *param, void *ret);
void std_RegexMatcher_groupCount_v(fr_Env env, void *param, void *ret);
void std_RegexMatcher_group_v(fr_Env env, void *param, void *ret);
void std_RegexMatcher_start_v(fr_Env env, void *param, void *ret);
void std_RegexMatcher_end_v(fr_Env env, void *param, void *ret);
void std_RegexMatcher_finalize_v(fr_Env env, void *param, void *ret);
void std_UuidFactory_resolveMacAddr_v(fr_Env env, void *param, void *ret);
void std_Env_init_v(fr_Env env, void *param, void *ret);
void std_Env_os_v(fr_Env env, void *param, void *ret);
void std_Env_arch_v(fr_Env env, void *param, void *ret);
void std_Env_runtime_v(fr_Env env, void *param, void *ret);
void std_Env_isJs_v(fr_Env env, void *param, void *ret);
void std_Env_javaVersion_v(fr_Env env, void *param, void *ret);
void std_Env_idHash_v(fr_Env env, void *param, void *ret);
void std_Env_args_v(fr_Env env, void *param, void *ret);
void std_Env_vars_v(fr_Env env, void *param, void *ret);
void std_Env_diagnostics_v(fr_Env env, void *param, void *ret);
void std_Env_gc_v(fr_Env env, void *param, void *ret);
void std_Env_host_v(fr_Env env, void *param, void *ret);
void std_Env_user_v(fr_Env env, void *param, void *ret);
void std_Env_in_v(fr_Env env, void *param, void *ret);
void std_Env_out_v(fr_Env env, void *param, void *ret);
void std_Env_err_v(fr_Env env, void *param, void *ret);
void std_Env_promptPassword_v(fr_Env env, void *param, void *ret);
void std_Env_homeDirPath_v(fr_Env env, void *param, void *ret);
void std_Env_getEnvPaths_v(fr_Env env, void *param, void *ret);
void std_Env_exit_v(fr_Env env, void *param, void *ret);
void std_PodList_makePod_v(fr_Env env, void *param, void *ret);
void std_Pod_doInit_v(fr_Env env, void *param, void *ret);
void std_Type_typeof__v(fr_Env env, void *param, void *ret);
void std_BaseType_doInit_v(fr_Env env, void *param, void *ret);
void std_Field_getDirectly_v(fr_Env env, void *param, void *ret);
void std_Field_setDirectly_v(fr_Env env, void *param, void *ret);
void std_Method_call_v(fr_Env env, void *param, void *ret);
void std_Method_call__0_v(fr_Env env, void *param, void *ret);
void std_Method_call__1_v(fr_Env env, void *param, void *ret);
void std_Method_call__2_v(fr_Env env, void *param, void *ret);
void std_Method_call__3_v(fr_Env env, void *param, void *ret);
void std_Method_call__4_v(fr_Env env, void *param, void *ret);
void std_Method_call__5_v(fr_Env env, void *param, void *ret);
void std_Method_call__6_v(fr_Env env, void *param, void *ret);
void std_Method_call__7_v(fr_Env env, void *param, void *ret);
void std_MethodFunc_call_v(fr_Env env, void *param, void *ret);
void std_MethodFunc_call__0_v(fr_Env env, void *param, void *ret);
void std_MethodFunc_call__1_v(fr_Env env, void *param, void *ret);
void std_MethodFunc_call__2_v(fr_Env env, void *param, void *ret);
void std_MethodFunc_call__3_v(fr_Env env, void *param, void *ret);
void std_MethodFunc_call__4_v(fr_Env env, void *param, void *ret);
void std_MethodFunc_call__5_v(fr_Env env, void *param, void *ret);
void std_MethodFunc_call__6_v(fr_Env env, void *param, void *ret);
void std_MethodFunc_call__7_v(fr_Env env, void *param, void *ret);
void std_BufCrypto_toDigest_v(fr_Env env, void *param, void *ret);
void std_BufCrypto_crc_v(fr_Env env, void *param, void *ret);
void std_BufCrypto_hmac_v(fr_Env env, void *param, void *ret);
void std_BufCrypto_pbk_v(fr_Env env, void *param, void *ret);
void std_NioBuf_init_v(fr_Env env, void *param, void *ret);
void std_NioBuf_alloc_v(fr_Env env, void *param, void *ret);
void std_NioBuf_size_v(fr_Env env, void *param, void *ret);
void std_NioBuf_size__1_v(fr_Env env, void *param, void *ret);
void std_NioBuf_capacity_v(fr_Env env, void *param, void *ret);
void std_NioBuf_capacity__1_v(fr_Env env, void *param, void *ret);
void std_NioBuf_pos_v(fr_Env env, void *param, void *ret);
void std_NioBuf_pos__1_v(fr_Env env, void *param, void *ret);
void std_NioBuf_getByte_v(fr_Env env, void *param, void *ret);
void std_NioBuf_setByte_v(fr_Env env, void *param, void *ret);
void std_NioBuf_getBytes_v(fr_Env env, void *param, void *ret);
void std_NioBuf_setBytes_v(fr_Env env, void *param, void *ret);
void std_NioBuf_close_v(fr_Env env, void *param, void *ret);
void std_NioBuf_sync_v(fr_Env env, void *param, void *ret);
void std_FileBuf_init_v(fr_Env env, void *param, void *ret);
void std_FileBuf_size_v(fr_Env env, void *param, void *ret);
void std_FileBuf_size__1_v(fr_Env env, void *param, void *ret);
void std_FileBuf_capacity_v(fr_Env env, void *param, void *ret);
void std_FileBuf_capacity__1_v(fr_Env env, void *param, void *ret);
void std_FileBuf_pos_v(fr_Env env, void *param, void *ret);
void std_FileBuf_pos__1_v(fr_Env env, void *param, void *ret);
void std_FileBuf_getByte_v(fr_Env env, void *param, void *ret);
void std_FileBuf_setByte_v(fr_Env env, void *param, void *ret);
void std_FileBuf_getBytes_v(fr_Env env, void *param, void *ret);
void std_FileBuf_setBytes_v(fr_Env env, void *param, void *ret);
void std_FileBuf_close_v(fr_Env env, void *param, void *ret);
void std_FileBuf_sync_v(fr_Env env, void *param, void *ret);
void std_NativeCharset_fromStr_v(fr_Env env, void *param, void *ret);
void std_NativeCharset_encode_v(fr_Env env, void *param, void *ret);
void std_NativeCharset_encodeArray_v(fr_Env env, void *param, void *ret);
void std_NativeCharset_decode_v(fr_Env env, void *param, void *ret);
void std_SysOutStream_write_v(fr_Env env, void *param, void *ret);
void std_SysOutStream_writeBytes_v(fr_Env env, void *param, void *ret);
void std_SysOutStream_sync_v(fr_Env env, void *param, void *ret);
void std_SysOutStream_flush_v(fr_Env env, void *param, void *ret);
void std_SysOutStream_close_v(fr_Env env, void *param, void *ret);
void std_SysInStream_toSigned_v(fr_Env env, void *param, void *ret);
void std_SysInStream_avail_v(fr_Env env, void *param, void *ret);
void std_SysInStream_read_v(fr_Env env, void *param, void *ret);
void std_SysInStream_skip_v(fr_Env env, void *param, void *ret);
void std_SysInStream_readBytes_v(fr_Env env, void *param, void *ret);
void std_SysInStream_unread_v(fr_Env env, void *param, void *ret);
void std_SysInStream_close_v(fr_Env env, void *param, void *ret);
void std_FileSystem_exists_v(fr_Env env, void *param, void *ret);
void std_FileSystem_size_v(fr_Env env, void *param, void *ret);
void std_FileSystem_modified_v(fr_Env env, void *param, void *ret);
void std_FileSystem_setModified_v(fr_Env env, void *param, void *ret);
void std_FileSystem_uriToPath_v(fr_Env env, void *param, void *ret);
void std_FileSystem_pathToUri_v(fr_Env env, void *param, void *ret);
void std_FileSystem_list_v(fr_Env env, void *param, void *ret);
void std_FileSystem_normalize_v(fr_Env env, void *param, void *ret);
void std_FileSystem_createDirs_v(fr_Env env, void *param, void *ret);
void std_FileSystem_createFile_v(fr_Env env, void *param, void *ret);
void std_FileSystem_moveTo_v(fr_Env env, void *param, void *ret);
void std_FileSystem_copyTo_v(fr_Env env, void *param, void *ret);
void std_FileSystem_delete__v(fr_Env env, void *param, void *ret);
void std_FileSystem_isReadable_v(fr_Env env, void *param, void *ret);
void std_FileSystem_isWritable_v(fr_Env env, void *param, void *ret);
void std_FileSystem_isExecutable_v(fr_Env env, void *param, void *ret);
void std_FileSystem_isDir_v(fr_Env env, void *param, void *ret);
void std_FileSystem_tempDir_v(fr_Env env, void *param, void *ret);
void std_FileSystem_osRoots_v(fr_Env env, void *param, void *ret);
void std_FileSystem_getSpaceInfo_v(fr_Env env, void *param, void *ret);
void std_FileSystem_fileSep_v(fr_Env env, void *param, void *ret);
void std_FileSystem_pathSep_v(fr_Env env, void *param, void *ret);
void std_LocalFile_in_v(fr_Env env, void *param, void *ret);
void std_LocalFile_out_v(fr_Env env, void *param, void *ret);
void std_TimeZone_listFullNames_v(fr_Env env, void *param, void *ret);
void std_TimeZone_fromName_v(fr_Env env, void *param, void *ret);
void std_TimeZone_cur_v(fr_Env env, void *param, void *ret);
void std_TimeZone_dstOffset_v(fr_Env env, void *param, void *ret);
void std_Locale_cur_v(fr_Env env, void *param, void *ret);
void std_Locale_setCur_v(fr_Env env, void *param, void *ret);
void std_TimePoint_nowMillis_v(fr_Env env, void *param, void *ret);
void std_TimePoint_nanoTicks_v(fr_Env env, void *param, void *ret);
void std_TimePoint_nowUnique_v(fr_Env env, void *param, void *ret);
void std_DateTime_fromTicks_v(fr_Env env, void *param, void *ret);
void std_DateTime_make_v(fr_Env env, void *param, void *ret);
void std_DateTime_dayOfYear_v(fr_Env env, void *param, void *ret);
void std_DateTime_weekOfYear_v(fr_Env env, void *param, void *ret);
void std_DateTime_hoursInDay_v(fr_Env env, void *param, void *ret);
void std_DateTime_toLocale_v(fr_Env env, void *param, void *ret);
void std_DateTime_fromLocale_v(fr_Env env, void *param, void *ret);
void std_DateTime_weekdayInMonth_v(fr_Env env, void *param, void *ret);

void std_register(fr_Fvm vm) {
    fr_registerMethod(vm, "std_AtomicInt_init", std_AtomicInt_init_v);
    fr_registerMethod(vm, "std_AtomicInt_val", std_AtomicInt_val_v);
    fr_registerMethod(vm, "std_AtomicInt_val$1", std_AtomicInt_val__1_v);
    fr_registerMethod(vm, "std_AtomicInt_getAndSet", std_AtomicInt_getAndSet_v);
    fr_registerMethod(vm, "std_AtomicInt_compareAndSet", std_AtomicInt_compareAndSet_v);
    fr_registerMethod(vm, "std_AtomicInt_getAndAdd", std_AtomicInt_getAndAdd_v);
    fr_registerMethod(vm, "std_AtomicInt_addAndGet", std_AtomicInt_addAndGet_v);
    fr_registerMethod(vm, "std_AtomicInt_finalize", std_AtomicInt_finalize_v);
    fr_registerMethod(vm, "std_AtomicRef_init", std_AtomicRef_init_v);
    fr_registerMethod(vm, "std_AtomicRef_val", std_AtomicRef_val_v);
    fr_registerMethod(vm, "std_AtomicRef_val$1", std_AtomicRef_val__1_v);
    fr_registerMethod(vm, "std_AtomicRef_getAndSet", std_AtomicRef_getAndSet_v);
    fr_registerMethod(vm, "std_AtomicRef_compareAndSet", std_AtomicRef_compareAndSet_v);
    fr_registerMethod(vm, "std_AtomicRef_finalize", std_AtomicRef_finalize_v);
    fr_registerMethod(vm, "std_Lock_init", std_Lock_init_v);
    fr_registerMethod(vm, "std_Lock_tryLock", std_Lock_tryLock_v);
    fr_registerMethod(vm, "std_Lock_lock", std_Lock_lock_v);
    fr_registerMethod(vm, "std_Lock_unlock", std_Lock_unlock_v);
    fr_registerMethod(vm, "std_Lock_finalize", std_Lock_finalize_v);
    fr_registerMethod(vm, "std_AtomicBool_init", std_AtomicBool_init_v);
    fr_registerMethod(vm, "std_AtomicBool_val", std_AtomicBool_val_v);
    fr_registerMethod(vm, "std_AtomicBool_val$1", std_AtomicBool_val__1_v);
    fr_registerMethod(vm, "std_AtomicBool_getAndSet", std_AtomicBool_getAndSet_v);
    fr_registerMethod(vm, "std_AtomicBool_compareAndSet", std_AtomicBool_compareAndSet_v);
    fr_registerMethod(vm, "std_AtomicBool_finalize", std_AtomicBool_finalize_v);
    fr_registerMethod(vm, "std_Math_ceil", std_Math_ceil_v);
    fr_registerMethod(vm, "std_Math_floor", std_Math_floor_v);
    fr_registerMethod(vm, "std_Math_round", std_Math_round_v);
    fr_registerMethod(vm, "std_Math_exp", std_Math_exp_v);
    fr_registerMethod(vm, "std_Math_log", std_Math_log_v);
    fr_registerMethod(vm, "std_Math_log10", std_Math_log10_v);
    fr_registerMethod(vm, "std_Math_pow", std_Math_pow_v);
    fr_registerMethod(vm, "std_Math_sqrt", std_Math_sqrt_v);
    fr_registerMethod(vm, "std_Math_acos", std_Math_acos_v);
    fr_registerMethod(vm, "std_Math_asin", std_Math_asin_v);
    fr_registerMethod(vm, "std_Math_atan", std_Math_atan_v);
    fr_registerMethod(vm, "std_Math_atan2", std_Math_atan2_v);
    fr_registerMethod(vm, "std_Math_cos", std_Math_cos_v);
    fr_registerMethod(vm, "std_Math_cosh", std_Math_cosh_v);
    fr_registerMethod(vm, "std_Math_sin", std_Math_sin_v);
    fr_registerMethod(vm, "std_Math_sinh", std_Math_sinh_v);
    fr_registerMethod(vm, "std_Math_tan", std_Math_tan_v);
    fr_registerMethod(vm, "std_Math_tanh", std_Math_tanh_v);
    fr_registerMethod(vm, "std_Process_env", std_Process_env_v);
    fr_registerMethod(vm, "std_Process_outToIn", std_Process_outToIn_v);
    fr_registerMethod(vm, "std_Process_run", std_Process_run_v);
    fr_registerMethod(vm, "std_Process_join", std_Process_join_v);
    fr_registerMethod(vm, "std_Process_kill", std_Process_kill_v);
    fr_registerMethod(vm, "std_Decimal_fromStr", std_Decimal_fromStr_v);
    fr_registerMethod(vm, "std_Decimal_toDecimal", std_Decimal_toDecimal_v);
    fr_registerMethod(vm, "std_Decimal_privateMake", std_Decimal_privateMake_v);
    fr_registerMethod(vm, "std_Decimal_equals", std_Decimal_equals_v);
    fr_registerMethod(vm, "std_Decimal_compare", std_Decimal_compare_v);
    fr_registerMethod(vm, "std_Decimal_hash", std_Decimal_hash_v);
    fr_registerMethod(vm, "std_Decimal_negate", std_Decimal_negate_v);
    fr_registerMethod(vm, "std_Decimal_increment", std_Decimal_increment_v);
    fr_registerMethod(vm, "std_Decimal_decrement", std_Decimal_decrement_v);
    fr_registerMethod(vm, "std_Decimal_mult", std_Decimal_mult_v);
    fr_registerMethod(vm, "std_Decimal_multInt", std_Decimal_multInt_v);
    fr_registerMethod(vm, "std_Decimal_multFloat", std_Decimal_multFloat_v);
    fr_registerMethod(vm, "std_Decimal_div", std_Decimal_div_v);
    fr_registerMethod(vm, "std_Decimal_divInt", std_Decimal_divInt_v);
    fr_registerMethod(vm, "std_Decimal_divFloat", std_Decimal_divFloat_v);
    fr_registerMethod(vm, "std_Decimal_mod", std_Decimal_mod_v);
    fr_registerMethod(vm, "std_Decimal_modInt", std_Decimal_modInt_v);
    fr_registerMethod(vm, "std_Decimal_modFloat", std_Decimal_modFloat_v);
    fr_registerMethod(vm, "std_Decimal_plus", std_Decimal_plus_v);
    fr_registerMethod(vm, "std_Decimal_plusInt", std_Decimal_plusInt_v);
    fr_registerMethod(vm, "std_Decimal_plusFloat", std_Decimal_plusFloat_v);
    fr_registerMethod(vm, "std_Decimal_minus", std_Decimal_minus_v);
    fr_registerMethod(vm, "std_Decimal_minusInt", std_Decimal_minusInt_v);
    fr_registerMethod(vm, "std_Decimal_minusFloat", std_Decimal_minusFloat_v);
    fr_registerMethod(vm, "std_Decimal_abs", std_Decimal_abs_v);
    fr_registerMethod(vm, "std_Decimal_min", std_Decimal_min_v);
    fr_registerMethod(vm, "std_Decimal_max", std_Decimal_max_v);
    fr_registerMethod(vm, "std_Decimal_toStr", std_Decimal_toStr_v);
    fr_registerMethod(vm, "std_Decimal_toCode", std_Decimal_toCode_v);
    fr_registerMethod(vm, "std_Decimal_toInt", std_Decimal_toInt_v);
    fr_registerMethod(vm, "std_Decimal_toFloat", std_Decimal_toFloat_v);
    fr_registerMethod(vm, "std_Decimal_toLocale", std_Decimal_toLocale_v);
    fr_registerMethod(vm, "std_Zip_open", std_Zip_open_v);
    fr_registerMethod(vm, "std_Zip_read", std_Zip_read_v);
    fr_registerMethod(vm, "std_Zip_write", std_Zip_write_v);
    fr_registerMethod(vm, "std_Zip_contents", std_Zip_contents_v);
    fr_registerMethod(vm, "std_Zip_readNext", std_Zip_readNext_v);
    fr_registerMethod(vm, "std_Zip_readEntry", std_Zip_readEntry_v);
    fr_registerMethod(vm, "std_Zip_writeEntry", std_Zip_writeEntry_v);
    fr_registerMethod(vm, "std_Zip_finish", std_Zip_finish_v);
    fr_registerMethod(vm, "std_Zip_finalize", std_Zip_finalize_v);
    fr_registerMethod(vm, "std_Zip_gzipOutStream", std_Zip_gzipOutStream_v);
    fr_registerMethod(vm, "std_Zip_gzipInStream", std_Zip_gzipInStream_v);
    fr_registerMethod(vm, "std_Zip_deflateOutStream", std_Zip_deflateOutStream_v);
    fr_registerMethod(vm, "std_Zip_deflateInStream", std_Zip_deflateInStream_v);
    fr_registerMethod(vm, "std_Regex_init", std_Regex_init_v);
    fr_registerMethod(vm, "std_Regex_matches", std_Regex_matches_v);
    fr_registerMethod(vm, "std_Regex_matcher", std_Regex_matcher_v);
    fr_registerMethod(vm, "std_Regex_split", std_Regex_split_v);
    fr_registerMethod(vm, "std_Regex_finalize", std_Regex_finalize_v);
    fr_registerMethod(vm, "std_RegexMatcher_matches", std_RegexMatcher_matches_v);
    fr_registerMethod(vm, "std_RegexMatcher_find", std_RegexMatcher_find_v);
    fr_registerMethod(vm, "std_RegexMatcher_replaceFirst", std_RegexMatcher_replaceFirst_v);
    fr_registerMethod(vm, "std_RegexMatcher_replaceAll", std_RegexMatcher_replaceAll_v);
    fr_registerMethod(vm, "std_RegexMatcher_groupCount", std_RegexMatcher_groupCount_v);
    fr_registerMethod(vm, "std_RegexMatcher_group", std_RegexMatcher_group_v);
    fr_registerMethod(vm, "std_RegexMatcher_start", std_RegexMatcher_start_v);
    fr_registerMethod(vm, "std_RegexMatcher_end", std_RegexMatcher_end_v);
    fr_registerMethod(vm, "std_RegexMatcher_finalize", std_RegexMatcher_finalize_v);
    fr_registerMethod(vm, "std_UuidFactory_resolveMacAddr", std_UuidFactory_resolveMacAddr_v);
    fr_registerMethod(vm, "std_Env_init", std_Env_init_v);
    fr_registerMethod(vm, "std_Env_os", std_Env_os_v);
    fr_registerMethod(vm, "std_Env_arch", std_Env_arch_v);
    fr_registerMethod(vm, "std_Env_runtime", std_Env_runtime_v);
    fr_registerMethod(vm, "std_Env_isJs", std_Env_isJs_v);
    fr_registerMethod(vm, "std_Env_javaVersion", std_Env_javaVersion_v);
    fr_registerMethod(vm, "std_Env_idHash", std_Env_idHash_v);
    fr_registerMethod(vm, "std_Env_args", std_Env_args_v);
    fr_registerMethod(vm, "std_Env_vars", std_Env_vars_v);
    fr_registerMethod(vm, "std_Env_diagnostics", std_Env_diagnostics_v);
    fr_registerMethod(vm, "std_Env_gc", std_Env_gc_v);
    fr_registerMethod(vm, "std_Env_host", std_Env_host_v);
    fr_registerMethod(vm, "std_Env_user", std_Env_user_v);
    fr_registerMethod(vm, "std_Env_in", std_Env_in_v);
    fr_registerMethod(vm, "std_Env_out", std_Env_out_v);
    fr_registerMethod(vm, "std_Env_err", std_Env_err_v);
    fr_registerMethod(vm, "std_Env_promptPassword", std_Env_promptPassword_v);
    fr_registerMethod(vm, "std_Env_homeDirPath", std_Env_homeDirPath_v);
    fr_registerMethod(vm, "std_Env_getEnvPaths", std_Env_getEnvPaths_v);
    fr_registerMethod(vm, "std_Env_exit", std_Env_exit_v);
    fr_registerMethod(vm, "std_PodList_makePod", std_PodList_makePod_v);
    fr_registerMethod(vm, "std_Pod_doInit", std_Pod_doInit_v);
    fr_registerMethod(vm, "std_Type_typeof", std_Type_typeof__v);
    fr_registerMethod(vm, "std_BaseType_doInit", std_BaseType_doInit_v);
    fr_registerMethod(vm, "std_Field_getDirectly", std_Field_getDirectly_v);
    fr_registerMethod(vm, "std_Field_setDirectly", std_Field_setDirectly_v);
    fr_registerMethod(vm, "std_Method_call", std_Method_call_v);
    fr_registerMethod(vm, "std_Method_call$0", std_Method_call__0_v);
    fr_registerMethod(vm, "std_Method_call$1", std_Method_call__1_v);
    fr_registerMethod(vm, "std_Method_call$2", std_Method_call__2_v);
    fr_registerMethod(vm, "std_Method_call$3", std_Method_call__3_v);
    fr_registerMethod(vm, "std_Method_call$4", std_Method_call__4_v);
    fr_registerMethod(vm, "std_Method_call$5", std_Method_call__5_v);
    fr_registerMethod(vm, "std_Method_call$6", std_Method_call__6_v);
    fr_registerMethod(vm, "std_Method_call$7", std_Method_call__7_v);
    fr_registerMethod(vm, "std_MethodFunc_call", std_MethodFunc_call_v);
    fr_registerMethod(vm, "std_MethodFunc_call$0", std_MethodFunc_call__0_v);
    fr_registerMethod(vm, "std_MethodFunc_call$1", std_MethodFunc_call__1_v);
    fr_registerMethod(vm, "std_MethodFunc_call$2", std_MethodFunc_call__2_v);
    fr_registerMethod(vm, "std_MethodFunc_call$3", std_MethodFunc_call__3_v);
    fr_registerMethod(vm, "std_MethodFunc_call$4", std_MethodFunc_call__4_v);
    fr_registerMethod(vm, "std_MethodFunc_call$5", std_MethodFunc_call__5_v);
    fr_registerMethod(vm, "std_MethodFunc_call$6", std_MethodFunc_call__6_v);
    fr_registerMethod(vm, "std_MethodFunc_call$7", std_MethodFunc_call__7_v);
    fr_registerMethod(vm, "std_BufCrypto_toDigest", std_BufCrypto_toDigest_v);
    fr_registerMethod(vm, "std_BufCrypto_crc", std_BufCrypto_crc_v);
    fr_registerMethod(vm, "std_BufCrypto_hmac", std_BufCrypto_hmac_v);
    fr_registerMethod(vm, "std_BufCrypto_pbk", std_BufCrypto_pbk_v);
    fr_registerMethod(vm, "std_NioBuf_init", std_NioBuf_init_v);
    fr_registerMethod(vm, "std_NioBuf_alloc", std_NioBuf_alloc_v);
    fr_registerMethod(vm, "std_NioBuf_size", std_NioBuf_size_v);
    fr_registerMethod(vm, "std_NioBuf_size$1", std_NioBuf_size__1_v);
    fr_registerMethod(vm, "std_NioBuf_capacity", std_NioBuf_capacity_v);
    fr_registerMethod(vm, "std_NioBuf_capacity$1", std_NioBuf_capacity__1_v);
    fr_registerMethod(vm, "std_NioBuf_pos", std_NioBuf_pos_v);
    fr_registerMethod(vm, "std_NioBuf_pos$1", std_NioBuf_pos__1_v);
    fr_registerMethod(vm, "std_NioBuf_getByte", std_NioBuf_getByte_v);
    fr_registerMethod(vm, "std_NioBuf_setByte", std_NioBuf_setByte_v);
    fr_registerMethod(vm, "std_NioBuf_getBytes", std_NioBuf_getBytes_v);
    fr_registerMethod(vm, "std_NioBuf_setBytes", std_NioBuf_setBytes_v);
    fr_registerMethod(vm, "std_NioBuf_close", std_NioBuf_close_v);
    fr_registerMethod(vm, "std_NioBuf_sync", std_NioBuf_sync_v);
    fr_registerMethod(vm, "std_FileBuf_init", std_FileBuf_init_v);
    fr_registerMethod(vm, "std_FileBuf_size", std_FileBuf_size_v);
    fr_registerMethod(vm, "std_FileBuf_size$1", std_FileBuf_size__1_v);
    fr_registerMethod(vm, "std_FileBuf_capacity", std_FileBuf_capacity_v);
    fr_registerMethod(vm, "std_FileBuf_capacity$1", std_FileBuf_capacity__1_v);
    fr_registerMethod(vm, "std_FileBuf_pos", std_FileBuf_pos_v);
    fr_registerMethod(vm, "std_FileBuf_pos$1", std_FileBuf_pos__1_v);
    fr_registerMethod(vm, "std_FileBuf_getByte", std_FileBuf_getByte_v);
    fr_registerMethod(vm, "std_FileBuf_setByte", std_FileBuf_setByte_v);
    fr_registerMethod(vm, "std_FileBuf_getBytes", std_FileBuf_getBytes_v);
    fr_registerMethod(vm, "std_FileBuf_setBytes", std_FileBuf_setBytes_v);
    fr_registerMethod(vm, "std_FileBuf_close", std_FileBuf_close_v);
    fr_registerMethod(vm, "std_FileBuf_sync", std_FileBuf_sync_v);
    fr_registerMethod(vm, "std_NativeCharset_fromStr", std_NativeCharset_fromStr_v);
    fr_registerMethod(vm, "std_NativeCharset_encode", std_NativeCharset_encode_v);
    fr_registerMethod(vm, "std_NativeCharset_encodeArray", std_NativeCharset_encodeArray_v);
    fr_registerMethod(vm, "std_NativeCharset_decode", std_NativeCharset_decode_v);
    fr_registerMethod(vm, "std_SysOutStream_write", std_SysOutStream_write_v);
    fr_registerMethod(vm, "std_SysOutStream_writeBytes", std_SysOutStream_writeBytes_v);
    fr_registerMethod(vm, "std_SysOutStream_sync", std_SysOutStream_sync_v);
    fr_registerMethod(vm, "std_SysOutStream_flush", std_SysOutStream_flush_v);
    fr_registerMethod(vm, "std_SysOutStream_close", std_SysOutStream_close_v);
    fr_registerMethod(vm, "std_SysInStream_toSigned", std_SysInStream_toSigned_v);
    fr_registerMethod(vm, "std_SysInStream_avail", std_SysInStream_avail_v);
    fr_registerMethod(vm, "std_SysInStream_read", std_SysInStream_read_v);
    fr_registerMethod(vm, "std_SysInStream_skip", std_SysInStream_skip_v);
    fr_registerMethod(vm, "std_SysInStream_readBytes", std_SysInStream_readBytes_v);
    fr_registerMethod(vm, "std_SysInStream_unread", std_SysInStream_unread_v);
    fr_registerMethod(vm, "std_SysInStream_close", std_SysInStream_close_v);
    fr_registerMethod(vm, "std_FileSystem_exists", std_FileSystem_exists_v);
    fr_registerMethod(vm, "std_FileSystem_size", std_FileSystem_size_v);
    fr_registerMethod(vm, "std_FileSystem_modified", std_FileSystem_modified_v);
    fr_registerMethod(vm, "std_FileSystem_setModified", std_FileSystem_setModified_v);
    fr_registerMethod(vm, "std_FileSystem_uriToPath", std_FileSystem_uriToPath_v);
    fr_registerMethod(vm, "std_FileSystem_pathToUri", std_FileSystem_pathToUri_v);
    fr_registerMethod(vm, "std_FileSystem_list", std_FileSystem_list_v);
    fr_registerMethod(vm, "std_FileSystem_normalize", std_FileSystem_normalize_v);
    fr_registerMethod(vm, "std_FileSystem_createDirs", std_FileSystem_createDirs_v);
    fr_registerMethod(vm, "std_FileSystem_createFile", std_FileSystem_createFile_v);
    fr_registerMethod(vm, "std_FileSystem_moveTo", std_FileSystem_moveTo_v);
    fr_registerMethod(vm, "std_FileSystem_copyTo", std_FileSystem_copyTo_v);
    fr_registerMethod(vm, "std_FileSystem_delete", std_FileSystem_delete__v);
    fr_registerMethod(vm, "std_FileSystem_isReadable", std_FileSystem_isReadable_v);
    fr_registerMethod(vm, "std_FileSystem_isWritable", std_FileSystem_isWritable_v);
    fr_registerMethod(vm, "std_FileSystem_isExecutable", std_FileSystem_isExecutable_v);
    fr_registerMethod(vm, "std_FileSystem_isDir", std_FileSystem_isDir_v);
    fr_registerMethod(vm, "std_FileSystem_tempDir", std_FileSystem_tempDir_v);
    fr_registerMethod(vm, "std_FileSystem_osRoots", std_FileSystem_osRoots_v);
    fr_registerMethod(vm, "std_FileSystem_getSpaceInfo", std_FileSystem_getSpaceInfo_v);
    fr_registerMethod(vm, "std_FileSystem_fileSep", std_FileSystem_fileSep_v);
    fr_registerMethod(vm, "std_FileSystem_pathSep", std_FileSystem_pathSep_v);
    fr_registerMethod(vm, "std_LocalFile_in", std_LocalFile_in_v);
    fr_registerMethod(vm, "std_LocalFile_out", std_LocalFile_out_v);
    fr_registerMethod(vm, "std_TimeZone_listFullNames", std_TimeZone_listFullNames_v);
    fr_registerMethod(vm, "std_TimeZone_fromName", std_TimeZone_fromName_v);
    fr_registerMethod(vm, "std_TimeZone_cur", std_TimeZone_cur_v);
    fr_registerMethod(vm, "std_TimeZone_dstOffset", std_TimeZone_dstOffset_v);
    fr_registerMethod(vm, "std_Locale_cur", std_Locale_cur_v);
    fr_registerMethod(vm, "std_Locale_setCur", std_Locale_setCur_v);
    fr_registerMethod(vm, "std_TimePoint_nowMillis", std_TimePoint_nowMillis_v);
    fr_registerMethod(vm, "std_TimePoint_nanoTicks", std_TimePoint_nanoTicks_v);
    fr_registerMethod(vm, "std_TimePoint_nowUnique", std_TimePoint_nowUnique_v);
    fr_registerMethod(vm, "std_DateTime_fromTicks", std_DateTime_fromTicks_v);
    fr_registerMethod(vm, "std_DateTime_make", std_DateTime_make_v);
    fr_registerMethod(vm, "std_DateTime_dayOfYear", std_DateTime_dayOfYear_v);
    fr_registerMethod(vm, "std_DateTime_weekOfYear", std_DateTime_weekOfYear_v);
    fr_registerMethod(vm, "std_DateTime_hoursInDay", std_DateTime_hoursInDay_v);
    fr_registerMethod(vm, "std_DateTime_toLocale", std_DateTime_toLocale_v);
    fr_registerMethod(vm, "std_DateTime_fromLocale", std_DateTime_fromLocale_v);
    fr_registerMethod(vm, "std_DateTime_weekdayInMonth", std_DateTime_weekdayInMonth_v);
}

#endif //FR_VM
