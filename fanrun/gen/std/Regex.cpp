#include "std.h"

fr_Err std_Regex_init(fr_Env __env, std_Regex_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Regex_matches(fr_Env __env, sys_Bool *__ret, std_Regex_ref __self, sys_Str s) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Regex_matcher(fr_Env __env, std_RegexMatcher *__ret, std_Regex_ref __self, sys_Str s) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Regex_split(fr_Env __env, sys_List *__ret, std_Regex_ref __self, sys_Str s, sys_Int limit) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }



fr_Err std_RegexMatcher_make(fr_Env __env, std_RegexMatcher_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_RegexMatcher_matches(fr_Env __env, sys_Bool *__ret, std_RegexMatcher_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_RegexMatcher_find(fr_Env __env, sys_Bool *__ret, std_RegexMatcher_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_RegexMatcher_replaceFirst(fr_Env __env, sys_Str *__ret, std_RegexMatcher_ref __self, sys_Str replacement) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_RegexMatcher_replaceAll(fr_Env __env, sys_Str *__ret, std_RegexMatcher_ref __self, sys_Str replacement) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_RegexMatcher_groupCount(fr_Env __env, sys_Int *__ret, std_RegexMatcher_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_RegexMatcher_group(fr_Env __env, sys_Str_null *__ret, std_RegexMatcher_ref __self, sys_Int group) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_RegexMatcher_start(fr_Env __env, sys_Int *__ret, std_RegexMatcher_ref __self, sys_Int group) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_RegexMatcher_end(fr_Env __env, sys_Int *__ret, std_RegexMatcher_ref __self, sys_Int group) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
