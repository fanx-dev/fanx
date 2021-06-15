#include "vm.h"
#include "pod_sys_struct.h"
#include "pod_sys_native.h"

fr_Bool sys_Bool_fromStr(fr_Env env, fr_Obj s, fr_Bool checked) {
    return false;
}
void sys_Bool_privateMake(fr_Env env, fr_Bool self) {
    return;
}
fr_Bool sys_Bool_equals(fr_Env env, fr_Bool self, fr_Obj obj) {
    fr_Type type;
    bool eq = false;
    if (obj == NULL) {
        return false;
    }
    type = fr_toType(env, fr_vtBool);
    
    if (!fr_isInstanceOf(env, obj, type)) {
        return false;
    }
    
    //fr_lock(env);
    struct sys_Bool_ *other = (struct sys_Bool_ *)fr_getPtr(env, obj);
    eq = self == other->value;
    //fr_unlock(env);
    return eq;
}

fr_Bool sys_Bool_not(fr_Env env, fr_Bool self) {
    return !self;
}
fr_Bool sys_Bool_and(fr_Env env, fr_Bool self, fr_Bool b) {
    return self && b;
}
fr_Bool sys_Bool_or(fr_Env env, fr_Bool self, fr_Bool b) {
    return self || b;
}
fr_Bool sys_Bool_xor(fr_Env env, fr_Bool self, fr_Bool b) {
    return self != b;
}
void sys_Bool_static__init(fr_Env env) {
    fr_Value val;
    //val.type = fr_vtBool;
    val.b = false;
    fr_setStaticFieldS(env, "sys", "Bool", "defVal", &val);
    return;
}
