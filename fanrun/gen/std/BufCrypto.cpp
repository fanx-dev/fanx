#include "std.h"

fr_Err std_BufCrypto_toDigest(fr_Env __env, std_Buf *__ret, std_Buf buf, sys_Str algorithm) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_BufCrypto_crc(fr_Env __env, sys_Int *__ret, std_Buf buf, sys_Str algorithm) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_BufCrypto_hmac(fr_Env __env, std_Buf *__ret, std_Buf buf, sys_Str algorithm, std_Buf key) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_BufCrypto_pbk(fr_Env __env, std_Buf *__ret, sys_Str algorithm, sys_Str password, std_Buf salt, sys_Int iterations, sys_Int keyLen) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }

