#include "std.h"

#include <time.h>

std_DateTime std_DateTime_now(fr_Env __env, std_Duration_null tolerance) {
	time_t timer;
	time(&timer);

	return std_DateTime_fromTicks(__env, timer*1000, std_TimeZone_cur(__env));
}

std_DateTime std_DateTime_nowUtc(fr_Env __env, std_Duration_null tolerance) {
	time_t rawtime;
	struct tm* info;
	time(&rawtime);
	info = gmtime(&rawtime);

	std_DateTime dt = FR_ALLOC(std_DateTime);
	FR_CALL(std_DateTime, privateMake, dt, info->tm_year, info->tm_mon, info->tm_mday, info->tm_hour, info->tm_min, info->tm_sec
		, 0, rawtime * 1000, 0, 0, std_TimeZone_cur(__env));
	return dt;
}
std_DateTime std_DateTime_fromTicks(fr_Env __env, sys_Int ticks, std_TimeZone tz) {
	time_t timer = ticks/1000;
	struct tm* info;
	info = localtime(&timer);

	std_DateTime dt = FR_ALLOC(std_DateTime);
	FR_CALL(std_DateTime, privateMake, dt, info->tm_year, info->tm_mon, info->tm_mday, info->tm_hour, info->tm_min, info->tm_sec
		, (ticks%1000)*1000000, ticks * 1000, 0, 0, tz);
	return dt;
}
std_DateTime std_DateTime_make(fr_Env __env, sys_Int year, std_Month month, sys_Int day, sys_Int hour, sys_Int min, sys_Int sec, sys_Int ns, std_TimeZone tz) {
	time_t ret;
	struct tm info;
	int imonth = 0;
	info.tm_year = year - 1900;
	info.tm_mon = imonth;//TODO: FR_CALL(std_Month, ordinal, month) - 1;
	info.tm_mday = day;
	info.tm_hour = hour;
	info.tm_min = min;
	info.tm_sec = sec;
	info.tm_isdst = tz->baseOffset;
	ret = mktime(&info);

	std_DateTime dt = FR_ALLOC(std_DateTime);
	FR_CALL(std_DateTime, privateMake, dt, year, imonth, day, hour, min, sec, ns, ret * 1000 + ns / 1000000, 0, 0, tz);
	return dt;
}

sys_Int std_DateTime_dayOfYear(fr_Env __env, std_DateTime_ref __self) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
sys_Int std_DateTime_weekOfYear(fr_Env __env, std_DateTime_ref __self, std_Weekday startOfWeek) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
sys_Int std_DateTime_hoursInDay(fr_Env __env, std_DateTime_ref __self) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
sys_Str std_DateTime_toLocale(fr_Env __env, std_DateTime_ref __self, sys_Str_null pattern, std_Locale locale) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
std_DateTime_null std_DateTime_fromLocale(fr_Env __env, sys_Str str, sys_Str pattern, std_TimeZone_null tz, sys_Bool checked) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
sys_Int std_DateTime_weekdayInMonth(fr_Env __env, sys_Int year, std_Month mon, std_Weekday weekday, sys_Int pos) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }


std_Locale std_Locale_cur(fr_Env __env) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
void std_Locale_setCur(fr_Env __env, std_Locale locale) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); }



sys_Int std_TimePoint_nowMillis(fr_Env __env) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
sys_Int std_TimePoint_nanoTicks(fr_Env __env) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
sys_Int std_TimePoint_nowUnique(fr_Env __env) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }

sys_List std_TimeZone_listFullNames(fr_Env __env) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
std_TimeZone_null std_TimeZone_fromName(fr_Env __env, sys_Str name) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }
std_TimeZone std_TimeZone_cur(fr_Env __env) {
	static std_TimeZone cur = NULL;
	if (!cur) {
		time_t time_utc = 0;
		struct tm* p_tm_time;
		int time_zone = 0;

		p_tm_time = localtime(&time_utc);
		time_zone = (p_tm_time->tm_hour > 12) ? (p_tm_time->tm_hour -= 24) : p_tm_time->tm_hour;

		cur = FR_ALLOC(std_TimeZone);
		FR_CALL(std_TimeZone, make, cur, (sys_Str)fr_newStrUtf8(__env, "local", -1), (sys_Str)fr_newStrUtf8(__env, "local", -1), time_zone);

		fr_addStaticRef(__env, (fr_Obj*)(&cur));
	}
	return cur;
}
std_Duration_null std_TimeZone_dstOffset(fr_Env __env, std_TimeZone_ref __self, sys_Int year) { return NULL; }

