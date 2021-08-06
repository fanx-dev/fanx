#include "fni_ext.h"
//#include "pod_sys_struct.h"
#include "pod_sys_native.h"


//void sys_Func_static__init(fr_Env env) {
//    return;
//}
fr_Obj sys_Func_call__0(fr_Env env, fr_Obj self) {
    fr_throwNew(env, "sys", "ArgErr", "arg size err");
    return NULL;
}
fr_Obj sys_Func_call__1(fr_Env env, fr_Obj self, fr_Obj a) {
    return sys_Func_call__0(env, self);
}
fr_Obj sys_Func_call__2(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b) {
    return sys_Func_call__1(env, self, a);
}
fr_Obj sys_Func_call__3(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c) {
    return sys_Func_call__2(env, self, a, b);
}
fr_Obj sys_Func_call__4(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d) {
    return sys_Func_call__3(env, self, a, b, c);
}
fr_Obj sys_Func_call__5(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e) {
    return sys_Func_call__4(env, self, a, b, c, d);
}
fr_Obj sys_Func_call__6(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e, fr_Obj f) {
    return sys_Func_call__5(env, self, a, b, c, d, e);
}
fr_Obj sys_Func_call__7(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e, fr_Obj f, fr_Obj g) {
    return sys_Func_call__6(env, self, a, b, c, d, e, f);
}
fr_Obj sys_Func_call(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e, fr_Obj f, fr_Obj g, fr_Obj h) {
    return sys_Func_call__7(env, self, a, b, c, d, e, f, g);
}

fr_Obj sys_BindFunc_call__0(fr_Env env, fr_Obj self) {
    fr_Obj list = fr_callMethodS(env, "sys", "List", "make", 1, 10).h;

    //fr_callMethodS(env, "sys", "List", "add", 2, list, a);
    
    fr_Obj res = fr_callMethodS(env, "sys", "BindFunc", "callList", 1, list).h;
    return res;
}

fr_Obj sys_BindFunc_call__1(fr_Env env, fr_Obj self, fr_Obj a) {
    fr_Obj list = fr_callMethodS(env, "sys", "List", "make", 1, 10).h;

    fr_callMethodS(env, "sys", "List", "add", 2, list, a);

    fr_Obj res = fr_callMethodS(env, "sys", "BindFunc", "callList", 1, list).h;
    return res;
}
fr_Obj sys_BindFunc_call__2(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b) {
    fr_Obj list = fr_callMethodS(env, "sys", "List", "make", 1, 10).h;

    fr_callMethodS(env, "sys", "List", "add", 2, list, a);
    fr_callMethodS(env, "sys", "List", "add", 2, list, b);

    fr_Obj res = fr_callMethodS(env, "sys", "BindFunc", "callList", 1, list).h;
    return res;
}
fr_Obj sys_BindFunc_call__3(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c) {
    fr_Obj list = fr_callMethodS(env, "sys", "List", "make", 1, 10).h;

    fr_callMethodS(env, "sys", "List", "add", 2, list, a);
    fr_callMethodS(env, "sys", "List", "add", 2, list, b);
    fr_callMethodS(env, "sys", "List", "add", 2, list, c);

    fr_Obj res = fr_callMethodS(env, "sys", "BindFunc", "callList", 1, list).h;
    return res;
}
fr_Obj sys_BindFunc_call__4(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d) {
    fr_Obj list = fr_callMethodS(env, "sys", "List", "make", 1, 10).h;

    fr_callMethodS(env, "sys", "List", "add", 2, list, a);
    fr_callMethodS(env, "sys", "List", "add", 2, list, b);
    fr_callMethodS(env, "sys", "List", "add", 2, list, c);
    fr_callMethodS(env, "sys", "List", "add", 2, list, d);

    fr_Obj res = fr_callMethodS(env, "sys", "BindFunc", "callList", 1, list).h;
    return res;
}
fr_Obj sys_BindFunc_call__5(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e) {
    fr_Obj list = fr_callMethodS(env, "sys", "List", "make", 1, 10).h;

    fr_callMethodS(env, "sys", "List", "add", 2, list, a);
    fr_callMethodS(env, "sys", "List", "add", 2, list, b);
    fr_callMethodS(env, "sys", "List", "add", 2, list, c);
    fr_callMethodS(env, "sys", "List", "add", 2, list, d);
    fr_callMethodS(env, "sys", "List", "add", 2, list, e);

    fr_Obj res = fr_callMethodS(env, "sys", "BindFunc", "callList", 1, list).h;
    return res;
}
fr_Obj sys_BindFunc_call__6(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e, fr_Obj f) {
    fr_Obj list = fr_callMethodS(env, "sys", "List", "make", 1, 10).h;

    fr_callMethodS(env, "sys", "List", "add", 2, list, a);
    fr_callMethodS(env, "sys", "List", "add", 2, list, b);
    fr_callMethodS(env, "sys", "List", "add", 2, list, c);
    fr_callMethodS(env, "sys", "List", "add", 2, list, d);
    fr_callMethodS(env, "sys", "List", "add", 2, list, e);
    fr_callMethodS(env, "sys", "List", "add", 2, list, f);

    fr_Obj res = fr_callMethodS(env, "sys", "BindFunc", "callList", 1, list).h;
    return res;
}
fr_Obj sys_BindFunc_call__7(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e, fr_Obj f, fr_Obj g) {
    fr_Obj list = fr_callMethodS(env, "sys", "List", "make", 1, 10).h;

    fr_callMethodS(env, "sys", "List", "add", 2, list, a);
    fr_callMethodS(env, "sys", "List", "add", 2, list, b);
    fr_callMethodS(env, "sys", "List", "add", 2, list, c);
    fr_callMethodS(env, "sys", "List", "add", 2, list, d);
    fr_callMethodS(env, "sys", "List", "add", 2, list, e);
    fr_callMethodS(env, "sys", "List", "add", 2, list, f);
    fr_callMethodS(env, "sys", "List", "add", 2, list, g);

    fr_Obj res = fr_callMethodS(env, "sys", "BindFunc", "callList", 1, list).h;
    return res;
}
fr_Obj sys_BindFunc_call(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e, fr_Obj f, fr_Obj g, fr_Obj h) {
    fr_Obj list = fr_callMethodS(env, "sys", "List", "make", 1, 10).h;

    fr_callMethodS(env, "sys", "List", "add", 2, list, a);
    fr_callMethodS(env, "sys", "List", "add", 2, list, b);
    fr_callMethodS(env, "sys", "List", "add", 2, list, c);
    fr_callMethodS(env, "sys", "List", "add", 2, list, d);
    fr_callMethodS(env, "sys", "List", "add", 2, list, e);
    fr_callMethodS(env, "sys", "List", "add", 2, list, f);
    fr_callMethodS(env, "sys", "List", "add", 2, list, g);
    fr_callMethodS(env, "sys", "List", "add", 2, list, h);

    fr_Obj res = fr_callMethodS(env, "sys", "BindFunc", "callList", 1, list).h;
    return res;
}
