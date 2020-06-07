#include "std.h"

fr_Err std_TimeZone_listFullNames(fr_Env __env, sys_List *__ret) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_TimeZone_fromName(fr_Env __env, std_TimeZone_null *__ret, sys_Str name) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_TimeZone_cur(fr_Env __env, std_TimeZone *__ret) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_TimeZone_dstOffset(fr_Env __env, std_Duration_null *__ret, std_TimeZone_ref __self, sys_Int year) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }



fr_Err std_Locale_cur(fr_Env __env, std_Locale *__ret) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Locale_setCur(fr_Env __env, std_Locale locale) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }


fr_Err std_TimePoint_nowMillis(fr_Env __env, sys_Int *__ret) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_TimePoint_nanoTicks(fr_Env __env, sys_Int *__ret) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_TimePoint_nowUnique(fr_Env __env, sys_Int *__ret) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }



fr_Err std_DateTime_now(fr_Env __env, std_DateTime *__ret, std_Duration_null tolerance) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_DateTime_nowUtc(fr_Env __env, std_DateTime *__ret, std_Duration_null tolerance) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_DateTime_fromTicks(fr_Env __env, std_DateTime *__ret, sys_Int ticks, std_TimeZone tz) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_DateTime_make(fr_Env __env, std_DateTime *__ret, sys_Int year, std_Month month, sys_Int day, sys_Int hour, sys_Int min, sys_Int sec, sys_Int ns, std_TimeZone tz) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_DateTime_dayOfYear(fr_Env __env, sys_Int *__ret, std_DateTime_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_DateTime_weekOfYear(fr_Env __env, sys_Int *__ret, std_DateTime_ref __self, std_Weekday startOfWeek) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_DateTime_hoursInDay(fr_Env __env, sys_Int *__ret, std_DateTime_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_DateTime_toLocale(fr_Env __env, sys_Str *__ret, std_DateTime_ref __self, sys_Str_null pattern, std_Locale locale) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_DateTime_fromLocale(fr_Env __env, std_DateTime_null *__ret, sys_Str str, sys_Str pattern, std_TimeZone_null tz, sys_Bool checked) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_DateTime_weekdayInMonth(fr_Env __env, sys_Int *__ret, sys_Int year, std_Month mon, std_Weekday weekday, sys_Int pos) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }



