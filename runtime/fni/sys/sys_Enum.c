#include "fni_ext.h"
//#include "pod_sys_struct.h"
#include "pod_sys_native.h"

fr_Obj sys_Enum_doFromStr(fr_Env env, fr_Obj type, fr_Obj name, fr_Bool checked) {
    return fr_callMethodS(env, "std", "Type", "enumFromStr", 3, type, name, checked).h;
}
