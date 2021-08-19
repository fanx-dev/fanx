#include "fni_ext.h"
#include "pod_std_native.h"
#include <time.h>

fr_Obj std_TimeZone_listFullNames(fr_Env env) {
    fr_Obj list = fr_callMethodS(env, "sys", "List", "make", 1, (fr_Int)16).h;
    return list;
}
fr_Obj std_TimeZone_fromName(fr_Env env, fr_Obj name) {
    return 0;
}
fr_Obj std_TimeZone_cur(fr_Env env) {
    static fr_Obj cur;

    if (cur == NULL) {
        time_t time_utc = 0;
        struct tm* p_tm_time;
        int time_zone = 0;

        p_tm_time = localtime(&time_utc);
        time_zone = (p_tm_time->tm_hour > 12) ? (p_tm_time->tm_hour -= 24) : p_tm_time->tm_hour;

        fr_Obj name = fr_newStrUtf8(env, "local");
        cur = fr_newObjS(env, "std", "TimeZone", "make", 3, name, name, (fr_Int)time_zone);
        cur = fr_newGlobalRef(env, cur);
    }
    return cur;
}
fr_Obj std_TimeZone_dstOffset(fr_Env env, fr_Obj self, fr_Int year) {
    return NULL;
}
