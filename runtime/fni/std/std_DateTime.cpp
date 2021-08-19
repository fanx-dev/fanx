#include "fni_ext.h"
#include "pod_std_native.h"
#include <time.h>
#include <string>

#include <mutex>

std::recursive_mutex g_datetime_mutex;

static void string_replace(std::string &self, const std::string& src, const std::string& dst) {
    int pos = (int)self.find(src);
    if (pos >= 0) {
        if (pos == 0 || (pos > 0 && self[pos - 1] != '%')) {
            self = self.replace(pos, src.size(), dst);
        }
    }
}

static struct tm* decomposeTicks(fr_Int ticks) {
    time_t timer = ticks / 1000;
    struct tm* info;

    info = localtime(&timer);
    return info;
}

static struct tm* decomposeObj(fr_Env env, fr_Obj dt) {
    fr_Int ticks = fr_getFieldS(env, dt, "ticks").i;
    return decomposeTicks(ticks);
}

fr_Obj std_DateTime_fromTicks(fr_Env env, fr_Int ticks, fr_Obj tz) {
    time_t timer = ticks / 1000;
    struct tm* info;
    std::lock_guard<std::recursive_mutex> guard(g_datetime_mutex);
    info = localtime(&timer);

    fr_Obj dt = fr_newObjS(env, "std", "DateTime", "privateMake", 11, 
        (fr_Int)info->tm_year, (fr_Int)info->tm_mon, (fr_Int)info->tm_mday, (fr_Int)info->tm_hour, (fr_Int)info->tm_min, (fr_Int)info->tm_sec,
        ((fr_Int)(ticks % 1000)) * 1000000, //ns
        (fr_Int)ticks,  //ticks
        (fr_Int)info->tm_isdst, //dst
        (fr_Int)info->tm_wday, //weekday 
        tz);
    return dt;
}
fr_Obj std_DateTime_make(fr_Env env, fr_Int year, fr_Obj month, fr_Int day, fr_Int hour, fr_Int min, fr_Int sec, fr_Int ns, fr_Obj tz) {
    time_t ticks;
    struct tm tm_info;
    struct tm* info;
    std::lock_guard<std::recursive_mutex> guard(g_datetime_mutex);

    int imonth = fr_getFieldS(env, month, "ordinal").i;
    tm_info.tm_year = year - 1900;
    tm_info.tm_mon = imonth;
    tm_info.tm_mday = day;
    tm_info.tm_hour = hour;
    tm_info.tm_min = min;
    tm_info.tm_sec = sec;
    tm_info.tm_isdst = false;// tz->baseOffset;
    ticks = mktime(&tm_info);

    info = localtime(&ticks);

    fr_Obj dt = fr_newObjS(env, "std", "DateTime", "privateMake", 11,
        (fr_Int)info->tm_year+1900, (fr_Int)info->tm_mon, (fr_Int)info->tm_mday, (fr_Int)info->tm_hour, (fr_Int)info->tm_min, (fr_Int)info->tm_sec,
        (fr_Int)ns, //ns
        ((fr_Int)ticks) * 1000,  //ticks
        (fr_Int)info->tm_isdst, //dst
        (fr_Int)info->tm_wday, //weekday 
        tz);
    return dt;
}
fr_Int std_DateTime_dayOfYear(fr_Env env, fr_Obj self) {
    struct tm* info;
    std::lock_guard<std::recursive_mutex> guard(g_datetime_mutex);

    info = decomposeObj(env, self);
    return ((fr_Int)info->tm_yday)+1;
}
fr_Int std_DateTime_weekOfYear(fr_Env env, fr_Obj self, fr_Obj startOfWeek) {
    return 0;
}
fr_Int std_DateTime_hoursInDay(fr_Env env, fr_Obj self) {
    return 24;
}

static void convertToCPattern(std::string & patter) {

    string_replace(patter, "YYYY", "%Y");
    string_replace(patter, "YY", "%y");
    
    string_replace(patter, "MMMM", "%B");
    string_replace(patter, "MMM", "%b");
    string_replace(patter, "MM", "%m");
    string_replace(patter, "M", "%m");


    string_replace(patter, "DD", "%d");
    string_replace(patter, "D", "%e");
    string_replace(patter, "WWWW", "%A");
    string_replace(patter, "WWW", "%a");
    
    string_replace(patter, "VV", "%U");
    string_replace(patter, "V", "%U");
    string_replace(patter, "hh", "%H");
    string_replace(patter, "h", "%H");
    string_replace(patter, "kk", "%I");
    string_replace(patter, "k", "%I");

    string_replace(patter, "mm", "%M");
    string_replace(patter, "m", "%M");
    string_replace(patter, "ss", "%S");
    string_replace(patter, "SS", "%S");
    string_replace(patter, "s", "%S");

    string_replace(patter, "AA", "%p");
    string_replace(patter, "A", "%p");
    string_replace(patter, "aa", "%p");
    string_replace(patter, "a", "%p");

    string_replace(patter, "zzzz", "%Z");
    string_replace(patter, "zzz", "%Z");
    string_replace(patter, "z", "%z");
    string_replace(patter, "'T'", "T");

    //unsupport nano seconds
    string_replace(patter, "F", "0");
    string_replace(patter, "F", "0");
    string_replace(patter, "F", "0");
    string_replace(patter, "F", "0");
    string_replace(patter, "F", "0");
    string_replace(patter, "F", "0");
    string_replace(patter, "F", "0");
    string_replace(patter, "F", "0");
    string_replace(patter, "F", "0");
}

fr_Obj std_DateTime_toLocale(fr_Env env, fr_Obj self, fr_Obj pattern, fr_Obj locale) {
    char buf[1024];
    struct tm* info;

    std::string format = fr_getStrUtf8(env, pattern);
    convertToCPattern(format);

    std::lock_guard<std::recursive_mutex> guard(g_datetime_mutex);
    info = decomposeObj(env, self);

    strftime(buf, 1024, format.c_str(), info);

    return fr_newStrUtf8(env, buf);
}
fr_Obj std_DateTime_fromLocale(fr_Env env, fr_Obj astr, fr_Obj pattern, fr_Obj tz, fr_Bool checked) {
 
    const char* str = fr_getStrUtf8(env, astr);

    //std::string format = fr_getStrUtf8(env, pattern);
    //convertToCPattern(format);

#if _WIN64
    int year, month, day, hour, min, sec;
    sscanf(str, "%d/%d/%dT%d:%d:%d", &year, &month, &day, &hour, &min, &sec);

    time_t ticks;
    struct tm tm_info;
    struct tm* info;

    tm_info.tm_year = year - 1900;
    tm_info.tm_mon = month;
    tm_info.tm_mday = day;
    tm_info.tm_hour = hour;
    tm_info.tm_min = min;
    tm_info.tm_sec = sec;
    tm_info.tm_isdst = false;// tz->baseOffset;
    ticks = mktime(&tm_info);

    info = localtime(&ticks);

    fr_Obj dt = fr_newObjS(env, "std", "DateTime", "privateMake", 11,
        (fr_Int)info->tm_year + 1900, (fr_Int)info->tm_mon, (fr_Int)info->tm_mday, (fr_Int)info->tm_hour, (fr_Int)info->tm_min, (fr_Int)info->tm_sec,
        (fr_Int)0, //ns
        ((fr_Int)ticks) * 1000,  //ticks
        (fr_Int)info->tm_isdst, //dst
        (fr_Int)info->tm_wday, //weekday 
        tz);
    return dt;

#else
    struct tm info;
    std::lock_guard<std::recursive_mutex> guard(g_datetime_mutex);
    strptime(str, format.c_str(), &info);
    time_t ticks = mktime(&info);

    fr_Obj dt = fr_newObjS(env, "std", "DateTime", "privateMake", 8,
        (fr_Int)info.tm_year + 1900, (fr_Int)info.tm_mon, (fr_Int)info.tm_mday, (fr_Int)info.tm_hour, (fr_Int)info.tm_min, (fr_Int)info.tm_sec,
        (((fr_Int)ticks) % 1000) * 1000000, //ns
        ((fr_Int)ticks) * 1000,  //ticks
        info.tm_isdst, //dst
        (fr_Int)info.tm_wday, //weekday 
        tz);
    return dt;
#endif
}
fr_Int std_DateTime_weekdayInMonth(fr_Env env, fr_Int year, fr_Obj mon, fr_Obj weekday, fr_Int pos) {
    return 0;
}
