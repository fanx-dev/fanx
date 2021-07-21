#include "fni_ext.h"
//#include "pod_sys_struct.h"
#include "pod_sys_native.h"

//fr_Bool sys_Bool_fromStr(fr_Env env, fr_Obj s, fr_Bool checked) {
//    return false;
//}
//void sys_Bool_privateMake_val(fr_Env env, fr_Bool self) {
//    return;
//}
fr_Bool sys_Bool_equals_val(fr_Env env, fr_Bool self, fr_Obj obj) {
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
    fr_Bool *other = (fr_Bool *)fr_getPtr(env, obj);
    eq = self == *other;
    //fr_unlock(env);
    return eq;
}

fr_Bool sys_Bool_not__val(fr_Env env, fr_Bool self) {
    return !self;
}
fr_Bool sys_Bool_and__val(fr_Env env, fr_Bool self, fr_Bool b) {
    return self && b;
}
fr_Bool sys_Bool_or__val(fr_Env env, fr_Bool self, fr_Bool b) {
    return self || b;
}
fr_Bool sys_Bool_xor__val(fr_Env env, fr_Bool self, fr_Bool b) {
    return self != b;
}
//void sys_Bool_static__init(fr_Env env) {
//    fr_Value val;
//    //val.type = fr_vtBool;
//    val.b = false;
//    fr_setStaticFieldS(env, "sys", "Bool", "defVal", &val);
//    return;
//}
