#include "std.h"
#include <regex>

void std_Regex_init(fr_Env __env, std_Regex_ref __self) {
}

sys_Bool std_Regex_matches(fr_Env __env, std_Regex_ref __self, sys_Str s) {
	std::regex* r = new std::regex(fr_getStrUtf8(__env, __self->source, NULL));
	return std::regex_match(fr_getStrUtf8(__env, s, NULL), *r);
}

std_RegexMatcher std_Regex_matcher(fr_Env __env, std_Regex_ref __self, sys_Str s) { 
	std::cmatch *cm = new std::cmatch();
	std::regex* e = new std::regex(fr_getStrUtf8(__env, __self->source, NULL));
	std::regex_match(fr_getStrUtf8(__env, s, NULL), *cm, *e);
	std_RegexMatcher r = FR_ALLOC(std_RegexMatcher);
	r->cmatch = cm;
	return r;
}

sys_List std_Regex_split(fr_Env __env, std_Regex_ref __self, sys_Str s, sys_Int limit) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }


void std_RegexMatcher_make(fr_Env __env, std_RegexMatcher_ref __self) {
	__self->cmatch = NULL;
}

sys_Bool std_RegexMatcher_matches(fr_Env __env, std_RegexMatcher_ref __self) {
	std::cmatch* cm = (std::cmatch*)__self->cmatch;
	return cm->size() > 0;
}

sys_Bool std_RegexMatcher_find(fr_Env __env, std_RegexMatcher_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Str std_RegexMatcher_replaceFirst(fr_Env __env, std_RegexMatcher_ref __self, sys_Str replacement) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Str std_RegexMatcher_replaceAll(fr_Env __env, std_RegexMatcher_ref __self, sys_Str replacement) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Int std_RegexMatcher_groupCount(fr_Env __env, std_RegexMatcher_ref __self) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Str_null std_RegexMatcher_group(fr_Env __env, std_RegexMatcher_ref __self, sys_Int group) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Int std_RegexMatcher_start(fr_Env __env, std_RegexMatcher_ref __self, sys_Int group) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }
sys_Int std_RegexMatcher_end(fr_Env __env, std_RegexMatcher_ref __self, sys_Int group) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); return 0; }

void std_RegexMatcher_finalize(fr_Env __env, std_RegexMatcher_ref __self) {
	std::cmatch* cm = (std::cmatch*)__self->cmatch;
	delete cm;
	__self->cmatch = NULL;
}