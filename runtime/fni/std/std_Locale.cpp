#include "fni_ext.h"
#include "pod_std_native.h"
#include <locale>

thread_local fr_Obj curLocale = NULL;
fr_Obj std_Locale_defaultLocale = NULL;


fr_Obj std_Locale_getDefaultLocale(fr_Env env) {
    std::string name = std::locale("").name();
    //printf("locale:%s\n", name.c_str());
    fr_Obj c = fr_newObjS(env, "std", "Locale", "make", 2, fr_newStrUtf8(env, name.c_str()), NULL);
    return c;
}

fr_Obj std_Locale_cur(fr_Env env) {
    fr_Obj cur = curLocale;
    if (cur == NULL) {
        if (std_Locale_defaultLocale == NULL) {
            fr_Obj c = std_Locale_getDefaultLocale(env);
            std_Locale_defaultLocale = fr_newGlobalRef(env, c);
        }
        return std_Locale_defaultLocale;
    }
    return cur;
}

void std_Locale_setCur(fr_Env env, fr_Obj locale) {
    fr_Obj cur = curLocale;
    if (cur) fr_deleteGlobalRef(env, cur);
    cur = fr_newGlobalRef(env, locale);
    curLocale = cur;
}
