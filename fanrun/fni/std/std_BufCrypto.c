#include "fni_ext.h"
#include "pod_std_native.h"

#include "zip.h"
#include "md5.h"

fr_Obj std_BufCrypto_toDigest(fr_Env env, fr_Obj buf, fr_Obj algorithm) {
    const char* name = fr_getStrUtf8(env, algorithm);
    if (strcmp(name, "MD5") == 0) {
        MD5_CTX md5_calc;
        unsigned char md5[16];
        MD5Init(&md5_calc);

        fr_Int oldPos = fr_callOnObj(env, buf, "pos", 0).i;
        fr_Int size = fr_callOnObj(env, buf, "size", 0).i;
        fr_Obj input = fr_callOnObj(env, buf, "in", 0).h;
        fr_Obj array = fr_arrayNew(env, fr_findType(env, "sys", "Array"), 1, 1024);
        fr_callOnObj(env, buf, "pos", 1, (fr_Int)0);
        fr_Int total = 0;

        fr_Method readBytes = fr_findMethod(env, fr_getObjType(env, input), "readBytes");
        while (total < size) {
            fr_Int n = fr_callMethod(env, readBytes, 4, input, array, (fr_Int)0, (fr_Int)min(1024, size - total)).i;
            if (n < 0) break;
            unsigned char* c = fr_arrayData(env, array);
            MD5Update(&md5_calc, c, n);
            total += n;
        }
        MD5Final(md5, &md5_calc);
        fr_callOnObj(env, buf, "pos", 1, oldPos);

        fr_Obj md5array = fr_arrayNew(env, fr_findType(env, "sys", "Int"), 1, sizeof(md5));
        void* p = fr_arrayData(env, md5array);
        memcpy(p, md5, sizeof(md5));
        fr_Obj md5buf = fr_newObjS(env, "std", "MemBuf", "makeBuf", 1, md5array);
        return md5buf;
    }
    else {
        fr_throwUnsupported(env);
    }
    return NULL;
}
fr_Int std_BufCrypto_crc(fr_Env env, fr_Obj buf, fr_Obj algorithm) {
    const char* name = fr_getStrUtf8(env, algorithm);
    if (strcmp(name, "CRC-32") == 0) {
        uLong crc = crc32(0L, Z_NULL, 0);

        fr_Obj data = fr_callOnObj(env, buf, "unsafeArray", 0).h;
        if (!data) {
            return NULL;
        }
        char* buffer = (char*)fr_arrayData(env, data);
        int len = fr_callOnObj(env, buf, "size", 0).i;

        crc = crc32(crc, buffer, len);
        return crc;
    }
    if (strcmp(name, "CRC-32-Adler") == 0) {
        uLong crc = adler32(0L, Z_NULL, 0);

        fr_Obj data = fr_callOnObj(env, buf, "unsafeArray", 0).h;
        if (!data) {
            return NULL;
        }
        char* buffer = (char*)fr_arrayData(env, data);
        int len = fr_callOnObj(env, buf, "size", 0).i;

        crc = adler32(crc, buffer, len);
        return crc;
    }
    else {
        fr_throwUnsupported(env);
    }
    return 0;
}
fr_Obj std_BufCrypto_hmac(fr_Env env, fr_Obj buf, fr_Obj algorithm, fr_Obj key) {
    fr_throwUnsupported(env);
    return 0;
}
fr_Obj std_BufCrypto_pbk(fr_Env env, fr_Obj algorithm, fr_Obj password, fr_Obj salt, fr_Int iterations, fr_Int keyLen) {
    fr_throwUnsupported(env);
    return 0;
}
