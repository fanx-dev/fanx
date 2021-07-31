#include "fni_private.h"
//#include "pod_sys_struct.h"
#include "pod_sys_native.h"


//void sys_Obj_make(fr_Env env, fr_Obj self) {
//    return;
//}
//fr_Bool sys_Obj_equals(fr_Env env, fr_Obj self, fr_Obj that) {
//    return self == that;
//}
//fr_Int sys_Obj_compare(fr_Env env, fr_Obj self, fr_Obj that) {
//    return (char*)self - (char*)that;
//}
//fr_Int sys_Obj_hash(fr_Env env, fr_Obj self) {
//    return (fr_Int)self;
//}
//fr_Obj sys_Obj_toStr(fr_Env env, fr_Obj self) {
//
//    char buf[128];
//    buf[0] = 0;
//
//    fr_Type ftype = fr_getObjType(env, self);
//    std::string &name = ((FType*)ftype)->c_name;
//
//    snprintf(buf, 128, "%p@%s", (void*)self, name.c_str());
//    return fr_newStrUtf8(env, buf);
//}
fr_Obj sys_Obj_trap(fr_Env env, fr_Obj self, fr_Obj name, fr_Obj args) {
    return fr_callMethodS(env, "std", "Type", "objTrap", 3, self, name, args).h;
}
//
fr_Bool sys_Obj_isImmutable(fr_Env env, fr_Obj self) {
    fr_Type t = fr_getObjType(env, self);
    
    if (t->flags & FFlags_Const/*0x00000002*/) return true;

    return false;
}
//fr_Obj sys_Obj_toImmutable(fr_Env env, fr_Obj self) {
//    return 0;
//}
//fr_Obj sys_Obj_typeof(fr_Env env, fr_Obj self) {
//    fr_Type ftype = fr_getObjType(env, self);
//    fr_Obj obj = fr_toTypeObj(env, ftype);
//    return obj;
//}
//void sys_Obj_finalize(fr_Env env, fr_Obj self) {
//    return;
//}

//void sys_Obj_echo(fr_Env env, fr_Obj x) {
//    fr_Obj str;
//    const char *utf8;
//    fr_Value val;
//    val.h = x;
//
//    str = fr_objToStr(env, val, fr_vtHandle);
//
//    utf8 = fr_getStrUtf8(env, str, nullptr);
//
//    puts(utf8);
//    return;
//}

//void sys_Obj_static__init(fr_Env env) {
//    return;
//}

