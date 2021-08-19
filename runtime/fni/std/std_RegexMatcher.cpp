#include "fni_ext.h"
#include "pod_std_native.h"
#include <regex>

static std::cmatch* getMatcher(fr_Env env, fr_Obj self) {
    static fr_Field f = fr_findField(env, fr_getObjType(env, self), "handle");
    fr_Value val;
    fr_getInstanceField(env, self, f, &val);
    std::cmatch* raw = (std::cmatch*)(val.i);
    return raw;
}

fr_Bool std_RegexMatcher_matches(fr_Env env, fr_Obj self) {
    std::cmatch* m = getMatcher(env, self);
    return !m->empty();
}
fr_Bool std_RegexMatcher_find(fr_Env env, fr_Obj self) {
    std::cmatch* m = getMatcher(env, self);
    return 0;
}
fr_Obj std_RegexMatcher_replaceFirst(fr_Env env, fr_Obj self, fr_Obj replacement) {
    std::cmatch* m = getMatcher(env, self);
    return 0;
}
fr_Obj std_RegexMatcher_replaceAll(fr_Env env, fr_Obj self, fr_Obj replacement) {
    std::cmatch* m = getMatcher(env, self);
    return 0;
}
fr_Int std_RegexMatcher_groupCount(fr_Env env, fr_Obj self) {
    std::cmatch* m = getMatcher(env, self);
    return 0;
}
fr_Obj std_RegexMatcher_group(fr_Env env, fr_Obj self, fr_Int group) {
    std::cmatch* m = getMatcher(env, self);
    return 0;
}
fr_Int std_RegexMatcher_start(fr_Env env, fr_Obj self, fr_Int group) {
    std::cmatch* m = getMatcher(env, self);
    return 0;
}
fr_Int std_RegexMatcher_end(fr_Env env, fr_Obj self, fr_Int group) {
    std::cmatch* m = getMatcher(env, self);
    return 0;
}
void std_RegexMatcher_finalize(fr_Env env, fr_Obj self) {
    std::cmatch* m = getMatcher(env, self);
    delete m;
}
