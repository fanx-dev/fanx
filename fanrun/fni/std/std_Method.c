#include "fni_ext.h"
#include "pod_std_native.h"
#include <stdarg.h>
//#include "type.h"
#include <string.h>

bool isBuildValueType(const char *name, fr_ValueType *vt) {
    if (strcmp(name, "sys::Bool") == 0) {
        if (vt) *vt = fr_vtBool;
        return true;
    }
    if (strcmp(name, "sys::Int") == 0) {
        if (vt) *vt = fr_vtInt;
        return true;
    }
    if (strcmp(name, "sys::Float") == 0) {
        if (vt) *vt = fr_vtFloat;
        return true;
    }
    return false;
}

fr_Obj std_Method_invoke(fr_Env env, fr_Obj self, fr_Int argCount, ...) {
    fr_Type type = fr_getObjType(env, self);
    fr_Field field = fr_findField(env, type, "_id");
    fr_Value fargs[2];
    fargs[0].h = self;
    fr_getInstanceField(env, fargs, field, fargs+1);
    fr_Method method = (fr_Method)fargs[1].i;
    
    bool unboxSelf = false;
    if ((method->flags & FFlags_Static) == 0) {
        fr_Obj firstArgType = fr_callMethodS(env, "std", "Slot", "parent", 1, self).h;
        fr_Obj firstArgTypeName = fr_callMethodS(env, "std", "Type", "qname", 1, firstArgType).h;
        const char *name = fr_getStrUtf8(env, firstArgTypeName);
        if (isBuildValueType(name, NULL)) {
            unboxSelf = true;
        }
    }
    
    va_list args;
    fr_Value ret;
    va_start(args, argCount);
    
    fr_Value valueArgs[10] = {0};
    for(int i=0; i<argCount; i++) {
        int paramIndex = i;
        if ((method->flags & FFlags_Static) == 0) {
            --paramIndex;
        }
        if (paramIndex == -1) {
            if (unboxSelf) {
                fr_Obj p = va_arg(args, fr_Obj);
                fr_unbox(env, p, valueArgs+i);
            }
            else {
                valueArgs[i].i = va_arg(args, int64_t);
            }
            continue;
        }
        //unbox
        if (isBuildValueType(method->paramsList[paramIndex].type, NULL)) {
            fr_Obj p = va_arg(args, fr_Obj);
            fr_unbox(env, p, valueArgs+i);
        }
        else {
            valueArgs[i].i = va_arg(args, int64_t);
        }
    }
    ret.i = 0;
    fr_callMethodA(env, method, (int)argCount, valueArgs, &ret);
    
    va_end(args);
    
    fr_ValueType vt;
    if (isBuildValueType(method->retType, &vt)) {
        ret.h = fr_box(env, &ret, vt);
    }
    return ret.h;
}

fr_Obj std_Method_call__0(fr_Env env, fr_Obj self) {
    return std_Method_invoke(env, self, 0);
}
fr_Obj std_Method_call__1(fr_Env env, fr_Obj self, fr_Obj a) {
    return std_Method_invoke(env, self, 1, a);
}
fr_Obj std_Method_call__2(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b) {
    return std_Method_invoke(env, self, 2, a, b);
}
fr_Obj std_Method_call__3(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c) {
    return std_Method_invoke(env, self, 3, a, b, c);
}
fr_Obj std_Method_call__4(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d) {
    return std_Method_invoke(env, self, 4, a, b, c, d);
}
fr_Obj std_Method_call__5(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e) {
    return std_Method_invoke(env, self, 5, a, b, c, d, e);
}
fr_Obj std_Method_call__6(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e, fr_Obj f) {
    return std_Method_invoke(env, self, 6, a, b, c, d, e, f);
}
fr_Obj std_Method_call__7(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e, fr_Obj f, fr_Obj g) {
    return std_Method_invoke(env, self, 7, a, b, c, d, e, f, g);
}
fr_Obj std_Method_call(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e, fr_Obj f, fr_Obj g, fr_Obj h) {
    return std_Method_invoke(env, self, 8, a, b, c, d, e, f, g, h);
}


fr_Obj std_MethodFunc_call__0(fr_Env env, fr_Obj self) {
    fr_Type type = fr_getObjType(env, self);
    fr_Field field = fr_findField(env, type, "method");
    fr_Value fargs[2];
    fargs[0].h = self;
    fr_getInstanceField(env, fargs, field, fargs+1);
    fr_Obj method = fargs[1].h;
    
    return std_Method_invoke(env, method, 0);
}
fr_Obj std_MethodFunc_call__1(fr_Env env, fr_Obj self, fr_Obj a) {
    fr_Type type = fr_getObjType(env, self);
    fr_Field field = fr_findField(env, type, "method");
    fr_Value fargs[2];
    fargs[0].h = self;
    fr_getInstanceField(env, fargs, field, fargs+1);
    fr_Obj method = fargs[1].h;
    
    return std_Method_invoke(env, method, 1, a);
}
fr_Obj std_MethodFunc_call__2(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b) {
    fr_Type type = fr_getObjType(env, self);
    fr_Field field = fr_findField(env, type, "method");
    fr_Value fargs[2];
    fargs[0].h = self;
    fr_getInstanceField(env, fargs, field, fargs+1);
    fr_Obj method = fargs[1].h;
    
    return std_Method_invoke(env, method, 2, a, b);
}
fr_Obj std_MethodFunc_call__3(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c) {
    fr_Type type = fr_getObjType(env, self);
    fr_Field field = fr_findField(env, type, "method");
    fr_Value fargs[2];
    fargs[0].h = self;
    fr_getInstanceField(env, fargs, field, fargs+1);
    fr_Obj method = fargs[1].h;
    
    return std_Method_invoke(env, method, 3, a, b, c);
}
fr_Obj std_MethodFunc_call__4(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d) {
    fr_Type type = fr_getObjType(env, self);
    fr_Field field = fr_findField(env, type, "method");
    fr_Value fargs[2];
    fargs[0].h = self;
    fr_getInstanceField(env, fargs, field, fargs+1);
    fr_Obj method = fargs[1].h;
    
    return std_Method_invoke(env, method, 4, a, b, c, d);
}
fr_Obj std_MethodFunc_call__5(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e) {
    fr_Type type = fr_getObjType(env, self);
    fr_Field field = fr_findField(env, type, "method");
    fr_Value fargs[2];
    fargs[0].h = self;
    fr_getInstanceField(env, fargs, field, fargs+1);
    fr_Obj method = fargs[1].h;
    
    return std_Method_invoke(env, method, 5, a, b, c, d, e);
}
fr_Obj std_MethodFunc_call__6(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e, fr_Obj f) {
    fr_Type type = fr_getObjType(env, self);
    fr_Field field = fr_findField(env, type, "method");
    fr_Value fargs[2];
    fargs[0].h = self;
    fr_getInstanceField(env, fargs, field, fargs+1);
    fr_Obj method = fargs[1].h;
    
    return std_Method_invoke(env, method, 6, a, b, c, d, e, f);
}
fr_Obj std_MethodFunc_call__7(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e, fr_Obj f, fr_Obj g) {
    fr_Type type = fr_getObjType(env, self);
    fr_Field field = fr_findField(env, type, "method");
    fr_Value fargs[2];
    fargs[0].h = self;
    fr_getInstanceField(env, fargs, field, fargs+1);
    fr_Obj method = fargs[1].h;
    
    return std_Method_invoke(env, method, 7, a, b, c, d, e, f, g);
}
fr_Obj std_MethodFunc_call(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e, fr_Obj f, fr_Obj g, fr_Obj h) {
    fr_Type type = fr_getObjType(env, self);
    fr_Field field = fr_findField(env, type, "method");
    fr_Value fargs[2];
    fargs[0].h = self;
    fr_getInstanceField(env, fargs, field, fargs+1);
    fr_Obj method = fargs[1].h;
    
    return std_Method_invoke(env, method, 8, a, b, c, d, e, f, g, h);
}
