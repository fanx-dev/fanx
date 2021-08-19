#include "fni_ext.h"
#include "pod_std_native.h"
#include <stdlib.h>
#include <locale>

fr_Obj std_NativeCharset_fromStr(fr_Env env, fr_Obj name) {
    static fr_Obj cur;
    const char* namec = fr_getStrUtf8(env, name);
    if (std::locale("").name() == namec) {
        if (cur == NULL) {
            fr_Obj c = fr_newObjS(env, "std", "NativeCharset", "make", 0);
            cur = fr_newGlobalRef(env, c);
        }
        return cur;
    }
    return NULL;
}
fr_Int std_NativeCharset_encode(fr_Env env, fr_Obj self, fr_Int ch, fr_Obj out) {
    static fr_Method writeM = fr_findMethod(env, fr_getObjType(env, out), "write");

    uint8_t buf[12];
    wchar_t wc = ch;
    int len = wctomb((char*)buf, wc);

    for (int i = 0; i < len; ++i) {
        fr_Int v = buf[i];
        fr_callMethod(env, writeM, 2, out, v);
    }
    return len;
}
fr_Int std_NativeCharset_encodeArray(fr_Env env, fr_Obj self, fr_Int ch, fr_Obj out, fr_Int offset) {
    uint8_t buf[12];
    wchar_t wc = ch;
    int len = wctomb((char*)buf, wc);
    
    for (int i = 0; i < len; ++i) {
        fr_Value v;
        v.i = buf[i];
        fr_arraySet(env, out, offset + i, &v);
    }
    return len;
}
fr_Int std_NativeCharset_decode(fr_Env env, fr_Obj self, fr_Obj in) {
    wchar_t wc;
    uint8_t buf[12];

    static fr_Method readM = fr_findMethod(env, fr_getObjType(env, in), "read");
    static fr_Method unreadM = fr_findMethod(env, fr_getObjType(env, in), "unread");

    int bufLen = 0;
    int decodeLen;
    for (int i=0; i < sizeof(buf); ++i) {
        buf[i] = fr_callMethod(env, readM, 1, in).i;
        bufLen = i + 1;
        decodeLen = mbtowc(&wc, (char*)buf, bufLen);
        if (decodeLen <= 0) continue;
        if (decodeLen < bufLen) {
            fr_callMethod(env, unreadM, 2, in, (fr_Int)buf[i]);
            break;
        }
    }
    return decodeLen;
}
