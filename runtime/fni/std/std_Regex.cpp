#include "fni_ext.h"
#include "pod_std_native.h"
#include <regex>

void std_Regex_finalize(fr_Env env, fr_Obj self);
void std_RegexMatcher_finalize(fr_Env env, fr_Obj self);

static std::regex* getRegex(fr_Env env, fr_Obj self) {
    static fr_Field f = fr_findField(env, fr_getObjType(env, self), "handle");
    fr_Value val;
    fr_getInstanceField(env, self, f, &val);
    std::regex* raw = (std::regex*)(val.i);
    return raw;
}

static void setRegex(fr_Env env, fr_Obj self, std::regex *r) {
    static fr_Field f = fr_findField(env, fr_getObjType(env, self), "handle");
    fr_Value val;
    val.i = (fr_Int)r;
    fr_setInstanceField(env, self, f, &val);
}

void std_Regex_init(fr_Env env, fr_Obj self, fr_Obj src) {
    const char* str = fr_getStrUtf8(env, src);
    std::regex* r = new std::regex(str);
    setRegex(env, self, r);
    
    fr_Type type = fr_getObjType(env, self);
    fr_registerDestructor(env, type, std_Regex_finalize);
}

fr_Bool std_Regex_matches(fr_Env env, fr_Obj self, fr_Obj s) {
    const char* str = fr_getStrUtf8(env, s);
    std::regex* r = getRegex(env, self);
    return std::regex_match(str, *r);
}
fr_Obj std_Regex_matcher(fr_Env env, fr_Obj self, fr_Obj s) {
    std::cmatch* cm = new std::cmatch();
    std::regex* r = getRegex(env, self);
    const char* str = fr_getStrUtf8(env, s);
    std::regex_match(str, *cm, *r);


    fr_Obj matcher = fr_newObjS(env, "std", "RegexMatcher", "make", 1);
    fr_Value val;
    val.i = (fr_Int)cm;
    fr_setFieldS(env, matcher, "handle", val);
    
    fr_Type type = fr_getObjType(env, matcher);
    fr_registerDestructor(env, type, std_RegexMatcher_finalize);
    
    return matcher;
}
fr_Obj std_Regex_split(fr_Env env, fr_Obj self, fr_Obj s, fr_Int limit) {
    return 0;
}
void std_Regex_finalize(fr_Env env, fr_Obj self) {
    std::regex* r = getRegex(env, self);
    delete r;
    return;
}
