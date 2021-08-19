#include "fni_ext.h"
#include "pod_std_native.h"
#include <locale>

thread_local fr_Obj curLocale = NULL;
static fr_Obj defaultLocale = NULL;

fr_Obj getDefaultLocale(fr_Env env) {
    if (defaultLocale == NULL) {
        std::string name = std::locale("").name();
        fr_Obj c = fr_newObjS(env, "std", "Locale", "make", 2, fr_newStrUtf8(env, name.c_str()), NULL);
        defaultLocale = fr_newGlobalRef(env, c);
    }
    return defaultLocale;
}

fr_Obj std_Locale_cur(fr_Env env) {
    fr_Obj cur = curLocale;
    if (cur == NULL) {
        return getDefaultLocale(env);
    }
    return cur;
}

void std_Locale_setCur(fr_Env env, fr_Obj locale) {
    fr_Obj cur = curLocale;
    if (cur) fr_deleteGlobalRef(env, cur);
    cur = fr_newGlobalRef(env, locale);
    curLocale = cur;
}
