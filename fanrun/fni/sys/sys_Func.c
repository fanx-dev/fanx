#include "vm.h"
//#include "pod_sys_struct.h"
#include "pod_sys_native.h"

//void sys_Func_make(fr_Env env, fr_Obj self) {
//    //struct sys_Func_ *p = (struct sys_Func_*)fr_getPtr(env, self);
//    return;
//}
//fr_Obj sys_Func_callList(fr_Env env, fr_Obj self, fr_Obj args) {
//    return 0;
//}
//fr_Obj sys_Func_callOn(fr_Env env, fr_Obj self, fr_Obj target, fr_Obj args) {
//    return 0;
//}
//fr_Obj sys_Func_bind(fr_Env env, fr_Obj self, fr_Obj args) {
//    return 0;
//}
void sys_Func_static__init(fr_Env env) {
    return;
}
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
    fr_Value args[2];
    args[0].i = 10;
    fr_newObjS(env, "sys", "List", "make", 1, args, args+1);
    
    fr_Value args2[2];
    args2[0].h = self;
    fr_callMethodS(env, "sys", "BindFunc", "bind", 0, args2, args2+1);
    
    fr_Value args3[3];
    args3[0].h = args[1].h;
    args3[1].h = args2[1].h;
    
    fr_callMethodS(env, "sys", "List", "addAll", 1, args3, args3+2);
    
//    fr_Value args4[2];
//    args4[0].h = a;
//    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    
    fr_Value args5[2];
    args5[0].h = args[1].h;
    fr_callMethodS(env, "sys", "BindFunc", "callList", 1, args5, args5+1);
    return args5[1].h;
}
fr_Obj sys_BindFunc_call__1(fr_Env env, fr_Obj self, fr_Obj a) {
    fr_Value args[2];
    args[0].i = 10;
    fr_newObjS(env, "sys", "List", "make", 1, args, args+1);
    
    fr_Value args2[2];
    args2[0].h = self;
    fr_callMethodS(env, "sys", "BindFunc", "bind", 0, args2, args2+1);
    
    fr_Value args3[3];
    args3[0].h = args[1].h;
    args3[1].h = args2[1].h;
    
    fr_callMethodS(env, "sys", "List", "addAll", 1, args3, args3+2);
    
    fr_Value args4[2];
    args4[0].h = a;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);

    fr_Value args5[2];
    args5[0].h = args[1].h;
    fr_callMethodS(env, "sys", "BindFunc", "callList", 1, args5, args5+1);
    return args5[1].h;
}
fr_Obj sys_BindFunc_call__2(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b) {
    fr_Value args[2];
    args[0].i = 10;
    fr_newObjS(env, "sys", "List", "make", 1, args, args+1);
    
    fr_Value args2[2];
    args2[0].h = self;
    fr_callMethodS(env, "sys", "BindFunc", "bind", 0, args2, args2+1);
    
    fr_Value args3[3];
    args3[0].h = args[1].h;
    args3[1].h = args2[1].h;
    
    fr_callMethodS(env, "sys", "List", "addAll", 1, args3, args3+2);
    
    fr_Value args4[2];
    args4[0].h = a;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = b;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    
    fr_Value args5[2];
    args5[0].h = args[1].h;
    fr_callMethodS(env, "sys", "BindFunc", "callList", 1, args5, args5+1);
    return args5[1].h;
}
fr_Obj sys_BindFunc_call__3(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c) {
    fr_Value args[2];
    args[0].i = 10;
    fr_newObjS(env, "sys", "List", "make", 1, args, args+1);
    
    fr_Value args2[2];
    args2[0].h = self;
    fr_callMethodS(env, "sys", "BindFunc", "bind", 0, args2, args2+1);
    
    fr_Value args3[3];
    args3[0].h = args[1].h;
    args3[1].h = args2[1].h;
    
    fr_callMethodS(env, "sys", "List", "addAll", 1, args3, args3+2);
    
    fr_Value args4[2];
    args4[0].h = a;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = b;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = c;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    
    fr_Value args5[2];
    args5[0].h = args[1].h;
    fr_callMethodS(env, "sys", "BindFunc", "callList", 1, args5, args5+1);
    return args5[1].h;
}
fr_Obj sys_BindFunc_call__4(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d) {
    fr_Value args[2];
    args[0].i = 10;
    fr_newObjS(env, "sys", "List", "make", 1, args, args+1);
    
    fr_Value args2[2];
    args2[0].h = self;
    fr_callMethodS(env, "sys", "BindFunc", "bind", 0, args2, args2+1);
    
    fr_Value args3[3];
    args3[0].h = args[1].h;
    args3[1].h = args2[1].h;
    
    fr_callMethodS(env, "sys", "List", "addAll", 1, args3, args3+2);
    
    fr_Value args4[2];
    args4[0].h = a;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = b;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = c;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = d;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    
    fr_Value args5[2];
    args5[0].h = args[1].h;
    fr_callMethodS(env, "sys", "BindFunc", "callList", 1, args5, args5+1);
    return args5[1].h;
}
fr_Obj sys_BindFunc_call__5(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e) {
    fr_Value args[2];
    args[0].i = 10;
    fr_newObjS(env, "sys", "List", "make", 1, args, args+1);
    
    fr_Value args2[2];
    args2[0].h = self;
    fr_callMethodS(env, "sys", "BindFunc", "bind", 0, args2, args2+1);
    
    fr_Value args3[3];
    args3[0].h = args[1].h;
    args3[1].h = args2[1].h;
    
    fr_callMethodS(env, "sys", "List", "addAll", 1, args3, args3+2);
    
    fr_Value args4[2];
    args4[0].h = a;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = b;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = c;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = d;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = e;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    
    fr_Value args5[2];
    args5[0].h = args[1].h;
    fr_callMethodS(env, "sys", "BindFunc", "callList", 1, args5, args5+1);
    return args5[1].h;
}
fr_Obj sys_BindFunc_call__6(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e, fr_Obj f) {
    fr_Value args[2];
    args[0].i = 10;
    fr_newObjS(env, "sys", "List", "make", 1, args, args+1);
    
    fr_Value args2[2];
    args2[0].h = self;
    fr_callMethodS(env, "sys", "BindFunc", "bind", 0, args2, args2+1);
    
    fr_Value args3[3];
    args3[0].h = args[1].h;
    args3[1].h = args2[1].h;
    
    fr_callMethodS(env, "sys", "List", "addAll", 1, args3, args3+2);
    
    fr_Value args4[2];
    args4[0].h = a;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = b;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = c;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = d;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = e;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = f;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    
    fr_Value args5[2];
    args5[0].h = args[1].h;
    fr_callMethodS(env, "sys", "BindFunc", "callList", 1, args5, args5+1);
    return args5[1].h;
}
fr_Obj sys_BindFunc_call__7(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e, fr_Obj f, fr_Obj g) {
    fr_Value args[2];
    args[0].i = 10;
    fr_newObjS(env, "sys", "List", "make", 1, args, args+1);
    
    fr_Value args2[2];
    args2[0].h = self;
    fr_callMethodS(env, "sys", "BindFunc", "bind", 0, args2, args2+1);
    
    fr_Value args3[3];
    args3[0].h = args[1].h;
    args3[1].h = args2[1].h;
    
    fr_callMethodS(env, "sys", "List", "addAll", 1, args3, args3+2);
    
    fr_Value args4[2];
    args4[0].h = a;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = b;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = c;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = d;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = e;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = f;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = g;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    
    fr_Value args5[2];
    args5[0].h = args[1].h;
    fr_callMethodS(env, "sys", "BindFunc", "callList", 1, args5, args5+1);
    return args5[1].h;
}
fr_Obj sys_BindFunc_call(fr_Env env, fr_Obj self, fr_Obj a, fr_Obj b, fr_Obj c, fr_Obj d, fr_Obj e, fr_Obj f, fr_Obj g, fr_Obj h) {
    fr_Value args[2];
    args[0].i = 10;
    fr_newObjS(env, "sys", "List", "make", 1, args, args+1);
    
    fr_Value args2[2];
    args2[0].h = self;
    fr_callMethodS(env, "sys", "BindFunc", "bind", 0, args2, args2+1);
    
    fr_Value args3[3];
    args3[0].h = args[1].h;
    args3[1].h = args2[1].h;
    
    fr_callMethodS(env, "sys", "List", "addAll", 1, args3, args3+2);
    
    fr_Value args4[2];
    args4[0].h = a;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = b;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = c;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = d;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = e;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = f;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = g;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    args4[0].h = h;
    fr_callMethodS(env, "sys", "List", "add", 1, args4, args4+1);
    
    fr_Value args5[2];
    args5[0].h = args[1].h;
    fr_callMethodS(env, "sys", "BindFunc", "callList", 1, args5, args5+1);
    return args5[1].h;
}
