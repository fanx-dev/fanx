#include "fni_private.h"
//#include "pod_sys_struct.h"
#include "pod_sys_native.h"


fr_Obj sys_Obj_trap(fr_Env env, fr_Obj self, fr_Obj name, fr_Obj args) {
    return fr_callMethodS(env, "std", "Type", "objTrap", 3, self, name, args).h;
}

fr_Bool sys_Obj_isImmutable(fr_Env env, fr_Obj self) {
    fr_Type t = fr_getObjType(env, self);
    
    if (t->flags & FFlags_Const/*0x00000002*/) return true;

    return false;
}

