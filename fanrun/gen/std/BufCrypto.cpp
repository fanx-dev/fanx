#include "std.h"


std_Buf std_BufCrypto_toDigest(fr_Env __env, std_Buf buf, sys_Str algorithm) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Int std_BufCrypto_crc(fr_Env __env, std_Buf buf, sys_Str algorithm) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_Buf std_BufCrypto_hmac(fr_Env __env, std_Buf buf, sys_Str algorithm, std_Buf key) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
std_Buf std_BufCrypto_pbk(fr_Env __env, sys_Str algorithm, sys_Str password, std_Buf salt, sys_Int iterations, sys_Int keyLen) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }


