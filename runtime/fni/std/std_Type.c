#include "fni_ext.h"
#include "pod_std_native.h"
//#include "type.h"

fr_Obj std_Type_typeof_(fr_Env env, fr_Obj obj) {
    fr_Type type = fr_getObjType(env, obj);
    if (type->reflectObj) {
        return type->reflectObj;
    }
    
    fr_Type baseType = fr_findType(env, "std", "Type");
    fr_Method method = fr_findMethodN(env, baseType, "find", 1);
    
    fr_Obj name = fr_newStrUtf8(env, type->name);
    fr_Value reflectObj = fr_callMethod(env, method, 1, name);
    
    type->reflectObj = fr_newGlobalRef(env, reflectObj.h);
    return type->reflectObj;
}
