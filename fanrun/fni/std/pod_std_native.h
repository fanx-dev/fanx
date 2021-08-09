#include "fni_ext.h"
CF_BEGIN

fr_Obj std_BufCrypto_toDigest(fr_Env env, fr_Obj buf, fr_Obj algorithm);
fr_Int std_BufCrypto_crc(fr_Env env, fr_Obj buf, fr_Obj algorithm);
fr_Obj std_BufCrypto_hmac(fr_Env env, fr_Obj buf, fr_Obj algorithm, fr_Obj key);
fr_Obj std_BufCrypto_pbk(fr_Env env, fr_Obj algorithm, fr_Obj password, fr_Obj salt, fr_Int iterations, fr_Int keyLen);
fr_Obj std_NativeCharset_fromStr(fr_Env env, fr_Obj name);
fr_Int std_NativeCharset_encode(fr_Env env, fr_Obj self, fr_Int ch, fr_Obj out);
fr_Int std_NativeCharset_encodeArray(fr_Env env, fr_Obj self, fr_Int ch, fr_Obj out, fr_Int offset);
fr_Int std_NativeCharset_decode(fr_Env env, fr_Obj self, fr_Obj in);
fr_Bool std_FileSystem_exists(fr_Env env, fr_Obj path);
fr_Int std_FileSystem_size(fr_Env env, fr_Obj path);
fr_Int std_FileSystem_modified(fr_Env env, fr_Obj path);
fr_Bool std_FileSystem_setModified(fr_Env env, fr_Obj path, fr_Int time);
fr_Obj std_FileSystem_uriToPath(fr_Env env, fr_Obj uri);
fr_Obj std_FileSystem_pathToUri(fr_Env env, fr_Obj ospath);
fr_Obj std_FileSystem_list(fr_Env env, fr_Obj path);
fr_Obj std_FileSystem_normalize(fr_Env env, fr_Obj path);
fr_Bool std_FileSystem_createDirs(fr_Env env, fr_Obj path);
fr_Bool std_FileSystem_createFile(fr_Env env, fr_Obj path);
fr_Bool std_FileSystem_moveTo(fr_Env env, fr_Obj path, fr_Obj to);
fr_Bool std_FileSystem_copyTo(fr_Env env, fr_Obj path, fr_Obj to);
fr_Bool std_FileSystem_delete_(fr_Env env, fr_Obj path);
fr_Bool std_FileSystem_isReadable(fr_Env env, fr_Obj path);
fr_Bool std_FileSystem_isWritable(fr_Env env, fr_Obj path);
fr_Bool std_FileSystem_isExecutable(fr_Env env, fr_Obj path);
fr_Bool std_FileSystem_isDir(fr_Env env, fr_Obj path);
fr_Obj std_FileSystem_tempDir(fr_Env env);
fr_Obj std_FileSystem_osRoots(fr_Env env);
fr_Bool std_FileSystem_getSpaceInfo(fr_Env env, fr_Obj path, fr_Obj out);
fr_Obj std_FileSystem_fileSep(fr_Env env);
fr_Obj std_FileSystem_pathSep(fr_Env env);
fr_Obj std_LocalFile_in(fr_Env env, fr_Obj self, fr_Int bufferSize);
fr_Obj std_LocalFile_out(fr_Env env, fr_Obj self, fr_Bool append, fr_Int bufferSize);
fr_Bool std_FileBuf_init(fr_Env env, fr_Obj self, fr_Obj file, fr_Obj mode);
fr_Int std_FileBuf_size(fr_Env env, fr_Obj self);
void std_FileBuf_size__1(fr_Env env, fr_Obj self, fr_Int it);
fr_Int std_FileBuf_capacity(fr_Env env, fr_Obj self);
void std_FileBuf_capacity__1(fr_Env env, fr_Obj self, fr_Int it);
fr_Int std_FileBuf_pos(fr_Env env, fr_Obj self);
void std_FileBuf_pos__1(fr_Env env, fr_Obj self, fr_Int it);
fr_Int std_FileBuf_getByte(fr_Env env, fr_Obj self, fr_Int index);
void std_FileBuf_setByte(fr_Env env, fr_Obj self, fr_Int index, fr_Int byte);
fr_Int std_FileBuf_getBytes(fr_Env env, fr_Obj self, fr_Int pos, fr_Obj dst, fr_Int off, fr_Int len);
void std_FileBuf_setBytes(fr_Env env, fr_Obj self, fr_Int pos, fr_Obj src, fr_Int off, fr_Int len);
fr_Bool std_FileBuf_close(fr_Env env, fr_Obj self);
fr_Obj std_FileBuf_sync(fr_Env env, fr_Obj self);
fr_Int std_SysInStream_toSigned(fr_Env env, fr_Int val, fr_Int byteNum);
fr_Int std_SysInStream_avail(fr_Env env, fr_Obj self);
fr_Int std_SysInStream_read(fr_Env env, fr_Obj self);
fr_Int std_SysInStream_skip(fr_Env env, fr_Obj self, fr_Int n);
fr_Int std_SysInStream_readBytes(fr_Env env, fr_Obj self, fr_Obj ba, fr_Int off, fr_Int len);
fr_Obj std_SysInStream_unread(fr_Env env, fr_Obj self, fr_Int n);
fr_Bool std_SysInStream_close(fr_Env env, fr_Obj self);
void std_NioBuf_init(fr_Env env, fr_Obj self, fr_Obj file, fr_Obj mode, fr_Int pos, fr_Obj size);
void std_NioBuf_alloc(fr_Env env, fr_Obj self, fr_Int size);
fr_Int std_NioBuf_size(fr_Env env, fr_Obj self);
void std_NioBuf_size__1(fr_Env env, fr_Obj self, fr_Int it);
fr_Int std_NioBuf_capacity(fr_Env env, fr_Obj self);
void std_NioBuf_capacity__1(fr_Env env, fr_Obj self, fr_Int it);
fr_Int std_NioBuf_pos(fr_Env env, fr_Obj self);
void std_NioBuf_pos__1(fr_Env env, fr_Obj self, fr_Int it);
fr_Int std_NioBuf_getByte(fr_Env env, fr_Obj self, fr_Int index);
void std_NioBuf_setByte(fr_Env env, fr_Obj self, fr_Int index, fr_Int byte);
fr_Int std_NioBuf_getBytes(fr_Env env, fr_Obj self, fr_Int pos, fr_Obj dst, fr_Int off, fr_Int len);
void std_NioBuf_setBytes(fr_Env env, fr_Obj self, fr_Int pos, fr_Obj src, fr_Int off, fr_Int len);
fr_Bool std_NioBuf_close(fr_Env env, fr_Obj self);
fr_Obj std_NioBuf_sync(fr_Env env, fr_Obj self);
fr_Obj std_SysOutStream_write(fr_Env env, fr_Obj self, fr_Int byte);
fr_Obj std_SysOutStream_writeBytes(fr_Env env, fr_Obj self, fr_Obj ba, fr_Int off, fr_Int len);
fr_Obj std_SysOutStream_sync(fr_Env env, fr_Obj self);
fr_Obj std_SysOutStream_flush(fr_Env env, fr_Obj self);
fr_Bool std_SysOutStream_close(fr_Env env, fr_Obj self);
void std_AtomicBool_init(fr_Env env, fr_Obj self, fr_Bool val);
fr_Bool std_AtomicBool_val(fr_Env env, fr_Obj self);
void std_AtomicBool_val__1(fr_Env env, fr_Obj self, fr_Bool it);
fr_Bool std_AtomicBool_getAndSet(fr_Env env, fr_Obj self, fr_Bool val);
fr_Bool std_AtomicBool_compareAndSet(fr_Env env, fr_Obj self, fr_Bool expect, fr_Bool update);
void std_AtomicBool_finalize(fr_Env env, fr_Obj self);
void std_AtomicInt_init(fr_Env env, fr_Obj self, fr_Int val);
fr_Int std_AtomicInt_val(fr_Env env, fr_Obj self);
void std_AtomicInt_val__1(fr_Env env, fr_Obj self, fr_Int it);
fr_Int std_AtomicInt_getAndSet(fr_Env env, fr_Obj self, fr_Int val);
fr_Bool std_AtomicInt_compareAndSet(fr_Env env, fr_Obj self, fr_Int expect, fr_Int update);
fr_Int std_AtomicInt_getAndAdd(fr_Env env, fr_Obj self, fr_Int delta);
fr_Int std_AtomicInt_addAndGet(fr_Env env, fr_Obj self, fr_Int delta);
void std_AtomicInt_finalize(fr_Env env, fr_Obj self);
void std_AtomicRef_init(fr_Env env, fr_Obj self, fr_Obj val);
fr_Obj std_AtomicRef_val(fr_Env env, fr_Obj self);
void std_AtomicRef_val__1(fr_Env env, fr_Obj self, fr_Obj it);
fr_Obj std_AtomicRef_getAndSet(fr_Env env, fr_Obj self, fr_Obj val);
fr_Bool std_AtomicRef_compareAndSet(fr_Env env, fr_Obj self, fr_Obj expect, fr_Obj update);
void std_AtomicRef_finalize(fr_Env env, fr_Obj self);
void std_Lock_init(fr_Env env, fr_Obj self);
fr_Bool std_Lock_tryLock(fr_Env env, fr_Obj self, fr_Int nanoTime);
void std_Lock_lock(fr_Env env, fr_Obj self);
void std_Lock_unlock(fr_Env env, fr_Obj self);
void std_Lock_finalize(fr_Env env, fr_Obj self);
fr_Obj std_Field_getDirectly(fr_Env env, fr_Obj self, fr_Obj instance);
void std_Field_setDirectly(fr_Env env, fr_Obj self, fr_Obj instance, fr_Obj value);
fr_Obj std_Method_call(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e, fr_Obj f, fr_Obj g, fr_Obj h);
fr_Obj std_Method_call__0(fr_Env env, fr_Obj self);
fr_Obj std_Method_call__1(fr_Env env, fr_Obj self, fr_Obj a);
fr_Obj std_Method_call__2(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b);
fr_Obj std_Method_call__3(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c);
fr_Obj std_Method_call__4(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d);
fr_Obj std_Method_call__5(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e);
fr_Obj std_Method_call__6(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e, fr_Obj f);
fr_Obj std_Method_call__7(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e, fr_Obj f, fr_Obj g);
fr_Obj std_MethodFunc_call(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e, fr_Obj f, fr_Obj g, fr_Obj h);
fr_Obj std_MethodFunc_call__0(fr_Env env, fr_Obj self);
fr_Obj std_MethodFunc_call__1(fr_Env env, fr_Obj self, fr_Obj a);
fr_Obj std_MethodFunc_call__2(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b);
fr_Obj std_MethodFunc_call__3(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c);
fr_Obj std_MethodFunc_call__4(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d);
fr_Obj std_MethodFunc_call__5(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e);
fr_Obj std_MethodFunc_call__6(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e, fr_Obj f);
fr_Obj std_MethodFunc_call__7(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e, fr_Obj f, fr_Obj g);
void std_PodList_doInit(fr_Env env, fr_Obj self);
void std_Pod_doInit(fr_Env env, fr_Obj self);
fr_Obj std_Pod_load(fr_Env env, fr_Obj in);
fr_Obj std_Pod_files(fr_Env env, fr_Obj self);
fr_Obj std_Pod_file(fr_Env env, fr_Obj self, fr_Obj uri, fr_Bool checked);
fr_Obj std_Type_typeof_(fr_Env env, fr_Obj obj);
void std_BaseType_doInit(fr_Env env, fr_Obj self);
fr_Obj std_DateTime_fromTicks(fr_Env env, fr_Int ticks, fr_Obj tz);
fr_Obj std_DateTime_make(fr_Env env, fr_Int year, fr_Obj month, fr_Int day, fr_Int hour, fr_Int min, fr_Int sec, fr_Int ns, fr_Obj tz);
fr_Int std_DateTime_dayOfYear(fr_Env env, fr_Obj self);
fr_Int std_DateTime_weekOfYear(fr_Env env, fr_Obj self, fr_Obj startOfWeek);
fr_Int std_DateTime_hoursInDay(fr_Env env, fr_Obj self);
fr_Obj std_DateTime_toLocale(fr_Env env, fr_Obj self, fr_Obj pattern, fr_Obj locale);
fr_Obj std_DateTime_fromLocale(fr_Env env, fr_Obj str, fr_Obj pattern, fr_Obj tz, fr_Bool checked);
fr_Int std_DateTime_weekdayInMonth(fr_Env env, fr_Int year, fr_Obj mon, fr_Obj weekday, fr_Int pos);
fr_Obj std_Locale_cur(fr_Env env);
void std_Locale_setCur(fr_Env env, fr_Obj locale);
fr_Int std_TimePoint_nowMillis(fr_Env env);
fr_Int std_TimePoint_nanoTicks(fr_Env env);
fr_Int std_TimePoint_nowUnique(fr_Env env);
fr_Obj std_TimeZone_listFullNames(fr_Env env);
fr_Obj std_TimeZone_fromName(fr_Env env, fr_Obj name);
fr_Obj std_TimeZone_cur(fr_Env env);
fr_Obj std_TimeZone_dstOffset(fr_Env env, fr_Obj self, fr_Int year);
fr_Obj std_Decimal_fromStr(fr_Env env, fr_Obj s, fr_Bool checked);
fr_Obj std_Decimal_toDecimal(fr_Env env, fr_Obj f);
void std_Decimal_privateMake(fr_Env env, fr_Obj self);
fr_Bool std_Decimal_equals(fr_Env env, fr_Obj self, fr_Obj obj);
fr_Int std_Decimal_compare(fr_Env env, fr_Obj self, fr_Obj obj);
fr_Int std_Decimal_hash(fr_Env env, fr_Obj self);
fr_Obj std_Decimal_negate(fr_Env env, fr_Obj self);
fr_Obj std_Decimal_increment(fr_Env env, fr_Obj self);
fr_Obj std_Decimal_decrement(fr_Env env, fr_Obj self);
fr_Obj std_Decimal_mult(fr_Env env, fr_Obj self, fr_Obj b);
fr_Obj std_Decimal_multInt(fr_Env env, fr_Obj self, fr_Int b);
fr_Obj std_Decimal_multFloat(fr_Env env, fr_Obj self, fr_Float b);
fr_Obj std_Decimal_div(fr_Env env, fr_Obj self, fr_Obj b);
fr_Obj std_Decimal_divInt(fr_Env env, fr_Obj self, fr_Int b);
fr_Obj std_Decimal_divFloat(fr_Env env, fr_Obj self, fr_Float b);
fr_Obj std_Decimal_mod(fr_Env env, fr_Obj self, fr_Obj b);
fr_Obj std_Decimal_modInt(fr_Env env, fr_Obj self, fr_Int b);
fr_Obj std_Decimal_modFloat(fr_Env env, fr_Obj self, fr_Float b);
fr_Obj std_Decimal_plus(fr_Env env, fr_Obj self, fr_Obj b);
fr_Obj std_Decimal_plusInt(fr_Env env, fr_Obj self, fr_Int b);
fr_Obj std_Decimal_plusFloat(fr_Env env, fr_Obj self, fr_Float b);
fr_Obj std_Decimal_minus(fr_Env env, fr_Obj self, fr_Obj b);
fr_Obj std_Decimal_minusInt(fr_Env env, fr_Obj self, fr_Int b);
fr_Obj std_Decimal_minusFloat(fr_Env env, fr_Obj self, fr_Float b);
fr_Obj std_Decimal_abs(fr_Env env, fr_Obj self);
fr_Obj std_Decimal_min(fr_Env env, fr_Obj self, fr_Obj that);
fr_Obj std_Decimal_max(fr_Env env, fr_Obj self, fr_Obj that);
fr_Obj std_Decimal_toStr(fr_Env env, fr_Obj self);
fr_Obj std_Decimal_toCode(fr_Env env, fr_Obj self);
fr_Int std_Decimal_toInt(fr_Env env, fr_Obj self);
fr_Float std_Decimal_toFloat(fr_Env env, fr_Obj self);
fr_Obj std_Decimal_toLocale(fr_Env env, fr_Obj self, fr_Obj pattern);
void std_Env_init(fr_Env env, fr_Obj self);
fr_Obj std_Env_os(fr_Env env, fr_Obj self);
fr_Obj std_Env_arch(fr_Env env, fr_Obj self);
fr_Obj std_Env_runtime(fr_Env env, fr_Obj self);
fr_Bool std_Env_isJs(fr_Env env, fr_Obj self);
fr_Int std_Env_javaVersion(fr_Env env, fr_Obj self);
fr_Obj std_Env_args(fr_Env env, fr_Obj self);
fr_Obj std_Env_vars(fr_Env env, fr_Obj self);
fr_Obj std_Env_diagnostics(fr_Env env, fr_Obj self);
void std_Env_gc(fr_Env env, fr_Obj self);
fr_Obj std_Env_host(fr_Env env, fr_Obj self);
fr_Obj std_Env_user(fr_Env env, fr_Obj self);
fr_Obj std_Env_in(fr_Env env, fr_Obj self);
fr_Obj std_Env_out(fr_Env env, fr_Obj self);
fr_Obj std_Env_err(fr_Env env, fr_Obj self);
fr_Obj std_Env_promptPassword(fr_Env env, fr_Obj self, fr_Obj msg);
fr_Obj std_Env_homeDir(fr_Env env, fr_Obj self);
fr_Obj std_Env_getEnvPaths(fr_Env env, fr_Obj self);
void std_Env_exit(fr_Env env, fr_Obj self, fr_Int status);
fr_Float std_Math_ceil(fr_Env env, fr_Float self);
fr_Float std_Math_floor(fr_Env env, fr_Float self);
fr_Float std_Math_round(fr_Env env, fr_Float self);
fr_Float std_Math_exp(fr_Env env, fr_Float self);
fr_Float std_Math_log(fr_Env env, fr_Float self);
fr_Float std_Math_log10(fr_Env env, fr_Float self);
fr_Float std_Math_pow(fr_Env env, fr_Float self, fr_Float pow);
fr_Float std_Math_sqrt(fr_Env env, fr_Float self);
fr_Float std_Math_acos(fr_Env env, fr_Float self);
fr_Float std_Math_asin(fr_Env env, fr_Float self);
fr_Float std_Math_atan(fr_Env env, fr_Float self);
fr_Float std_Math_atan2(fr_Env env, fr_Float y, fr_Float x);
fr_Float std_Math_cos(fr_Env env, fr_Float self);
fr_Float std_Math_cosh(fr_Env env, fr_Float self);
fr_Float std_Math_sin(fr_Env env, fr_Float self);
fr_Float std_Math_sinh(fr_Env env, fr_Float self);
fr_Float std_Math_tan(fr_Env env, fr_Float self);
fr_Float std_Math_tanh(fr_Env env, fr_Float self);
fr_Obj std_Process_env(fr_Env env, fr_Obj self);
fr_Obj std_Process_outToIn(fr_Env env, fr_Obj self);
fr_Obj std_Process_run(fr_Env env, fr_Obj self);
fr_Int std_Process_join(fr_Env env, fr_Obj self);
fr_Obj std_Process_kill(fr_Env env, fr_Obj self);
void std_Regex_init(fr_Env env, fr_Obj self, fr_Obj source);
fr_Bool std_Regex_matches(fr_Env env, fr_Obj self, fr_Obj s);
fr_Obj std_Regex_matcher(fr_Env env, fr_Obj self, fr_Obj s);
fr_Obj std_Regex_split(fr_Env env, fr_Obj self, fr_Obj s, fr_Int limit);
void std_Regex_finalize(fr_Env env, fr_Obj self);
fr_Bool std_RegexMatcher_matches(fr_Env env, fr_Obj self);
fr_Bool std_RegexMatcher_find(fr_Env env, fr_Obj self);
fr_Obj std_RegexMatcher_replaceFirst(fr_Env env, fr_Obj self, fr_Obj replacement);
fr_Obj std_RegexMatcher_replaceAll(fr_Env env, fr_Obj self, fr_Obj replacement);
fr_Int std_RegexMatcher_groupCount(fr_Env env, fr_Obj self);
fr_Obj std_RegexMatcher_group(fr_Env env, fr_Obj self, fr_Int group);
fr_Int std_RegexMatcher_start(fr_Env env, fr_Obj self, fr_Int group);
fr_Int std_RegexMatcher_end(fr_Env env, fr_Obj self, fr_Int group);
void std_RegexMatcher_finalize(fr_Env env, fr_Obj self);
fr_Int std_UuidFactory_resolveMacAddr(fr_Env env);
fr_Obj std_Zip_open(fr_Env env, fr_Obj file);
fr_Obj std_Zip_read(fr_Env env, fr_Obj in);
fr_Obj std_Zip_write(fr_Env env, fr_Obj out);
fr_Obj std_Zip_contents(fr_Env env, fr_Obj self);
fr_Obj std_Zip_readNext(fr_Env env, fr_Obj self);
fr_Obj std_Zip_readEntry(fr_Env env, fr_Obj self, fr_Obj path);
void std_Zip_writeEntry(fr_Env env, fr_Obj self, fr_Obj data, fr_Obj path, fr_Obj modifyTime, fr_Obj opts);
fr_Bool std_Zip_finish(fr_Env env, fr_Obj self);
void std_Zip_finalize(fr_Env env, fr_Obj self);
fr_Obj std_Zip_gzipOutStream(fr_Env env, fr_Obj out);
fr_Obj std_Zip_gzipInStream(fr_Env env, fr_Obj in);
fr_Obj std_Zip_deflateOutStream(fr_Env env, fr_Obj out, fr_Obj opts);
fr_Obj std_Zip_deflateInStream(fr_Env env, fr_Obj in, fr_Obj opts);

CF_END
