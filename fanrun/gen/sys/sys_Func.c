//
//  sys_Func.c
//  run
//
//  Created by yangjiandong on 2017/12/17.
//  Copyright © 2017年 yangjiandong. All rights reserved.
//

#include "sys.h"


//fr_Err sys_Func_make(fr_Env __env, sys_Func_ref __self){ return 0; }
//fr_Err sys_Func_callList(fr_Env __env, sys_Obj_null *__ret, sys_Func_ref __self, sys_List_null args) { return 0; }
//fr_Err sys_Func_callOn(fr_Env __env, sys_Obj_null *__ret, sys_Func_ref __self, sys_Obj_null target, sys_List_null args){ return 0; }
//fr_Err sys_Func_bind(fr_Env __env, sys_Func *__ret, sys_Func_ref __self, sys_List args){ return 0; }

fr_Err sys_Func_call(fr_Env __env, sys_Obj_null *__ret, sys_Func_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d, sys_Obj_null e, sys_Obj_null f, sys_Obj_null g, sys_Obj_null h) {
    return sys_Func_call__7(__env, __ret, __self, a, b, c, d, e, f, g);
}
fr_Err sys_Func_call__8(fr_Env __env, sys_Obj_null *__ret, sys_Func_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d, sys_Obj_null e, sys_Obj_null f, sys_Obj_null g, sys_Obj_null h) {
    return sys_Func_call__7(__env, __ret, __self, a, b, c, d, e, f, g);
}
fr_Err sys_Func_call__7(fr_Env __env, sys_Obj_null *__ret, sys_Func_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d, sys_Obj_null e, sys_Obj_null f, sys_Obj_null g) {
    return sys_Func_call__6(__env, __ret, __self, a, b, c, d, e, f);
}
fr_Err sys_Func_call__6(fr_Env __env, sys_Obj_null *__ret, sys_Func_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d, sys_Obj_null e, sys_Obj_null f) {
    return sys_Func_call__5(__env, __ret, __self, a, b, c, d, e);
}
fr_Err sys_Func_call__5(fr_Env __env, sys_Obj_null *__ret, sys_Func_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d, sys_Obj_null e) {
    return sys_Func_call__4(__env, __ret, __self, a, b, c, d);
}
fr_Err sys_Func_call__4(fr_Env __env, sys_Obj_null *__ret, sys_Func_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d) {
    return sys_Func_call__3(__env, __ret, __self, a, b, c);
}
fr_Err sys_Func_call__3(fr_Env __env, sys_Obj_null *__ret, sys_Func_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c) {
    return sys_Func_call__2(__env, __ret, __self, a, b);
}
fr_Err sys_Func_call__2(fr_Env __env, sys_Obj_null *__ret, sys_Func_ref __self, sys_Obj_null a, sys_Obj_null b) {
    return sys_Func_call__1(__env, __ret, __self, a);
}
fr_Err sys_Func_call__1(fr_Env __env, sys_Obj_null *__ret, sys_Func_ref __self, sys_Obj_null a) {
    return sys_Func_call__0(__env, __ret, __self);
}
fr_Err sys_Func_call__0(fr_Env __env, sys_Obj_null *__ret, sys_Func_ref __self) {
    FR_RET_ALLOC_THROW(sys_ArgErr);
}


fr_Err sys_BindFunc_call__0(fr_Env __env, sys_Obj_null *__ret, sys_BindFunc_ref __self) {
    return sys_BindFunc_callList(__env, __ret, __self, NULL);
}
fr_Err sys_BindFunc_call__1(fr_Env __env, sys_Obj_null *__ret, sys_BindFunc_ref __self, sys_Obj_null a) {
    FR_BEGIN_FUNC
    sys_List args;
    sys_List_make(__env, &args, 0);
    FR_VCALL(0, sys_List, add, &args, args, a);
    return sys_BindFunc_callList(__env, __ret, __self, args);
__errTable:
    return __err;
}
fr_Err sys_BindFunc_call__2(fr_Env __env, sys_Obj_null *__ret, sys_BindFunc_ref __self, sys_Obj_null a, sys_Obj_null b) {
    FR_BEGIN_FUNC
    sys_List args;
    sys_List_make(__env, &args, 0);
    FR_VCALL(0, sys_List, add, &args, args, a);
    FR_VCALL(0, sys_List, add, &args, args, b);
    return sys_BindFunc_callList(__env, __ret, __self, args);
__errTable:
    return __err;
}
fr_Err sys_BindFunc_call__3(fr_Env __env, sys_Obj_null *__ret, sys_BindFunc_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c) {
    FR_BEGIN_FUNC
    sys_List args;
    sys_List_make(__env, &args, 0);
    FR_VCALL(0, sys_List, add, &args, args, a);
    FR_VCALL(0, sys_List, add, &args, args, b);
    FR_VCALL(0, sys_List, add, &args, args, c);
    return sys_BindFunc_callList(__env, __ret, __self, args);
__errTable:
    return __err;
}
fr_Err sys_BindFunc_call__4(fr_Env __env, sys_Obj_null *__ret, sys_BindFunc_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d) {
    FR_BEGIN_FUNC
    sys_List args;
    sys_List_make(__env, &args, 0);
    FR_VCALL(0, sys_List, add, &args, args, a);
    FR_VCALL(0, sys_List, add, &args, args, b);
    FR_VCALL(0, sys_List, add, &args, args, c);
    FR_VCALL(0, sys_List, add, &args, args, d);
    return sys_BindFunc_callList(__env, __ret, __self, args);
__errTable:
    return __err;
}
fr_Err sys_BindFunc_call__5(fr_Env __env, sys_Obj_null *__ret, sys_BindFunc_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d, sys_Obj_null e) {
    FR_BEGIN_FUNC
    sys_List args;
    sys_List_make(__env, &args, 0);
    FR_VCALL(0, sys_List, add, &args, args, a);
    FR_VCALL(0, sys_List, add, &args, args, b);
    FR_VCALL(0, sys_List, add, &args, args, c);
    FR_VCALL(0, sys_List, add, &args, args, d);
    FR_VCALL(0, sys_List, add, &args, args, e);
    return sys_BindFunc_callList(__env, __ret, __self, args);
__errTable:
    return __err;
}
fr_Err sys_BindFunc_call__6(fr_Env __env, sys_Obj_null *__ret, sys_BindFunc_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d, sys_Obj_null e, sys_Obj_null f) {
    FR_BEGIN_FUNC
    sys_List args;
    sys_List_make(__env, &args, 0);
    FR_VCALL(0, sys_List, add, &args, args, a);
    FR_VCALL(0, sys_List, add, &args, args, b);
    FR_VCALL(0, sys_List, add, &args, args, c);
    FR_VCALL(0, sys_List, add, &args, args, d);
    FR_VCALL(0, sys_List, add, &args, args, e);
    FR_VCALL(0, sys_List, add, &args, args, f);
    return sys_BindFunc_callList(__env, __ret, __self, args);
__errTable:
    return __err;
}
fr_Err sys_BindFunc_call__7(fr_Env __env, sys_Obj_null *__ret, sys_BindFunc_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d, sys_Obj_null e, sys_Obj_null f, sys_Obj_null g) {
    FR_BEGIN_FUNC
    sys_List args;
    sys_List_make(__env, &args, 0);
    FR_VCALL(0, sys_List, add, &args, args, a);
    FR_VCALL(0, sys_List, add, &args, args, b);
    FR_VCALL(0, sys_List, add, &args, args, c);
    FR_VCALL(0, sys_List, add, &args, args, d);
    FR_VCALL(0, sys_List, add, &args, args, e);
    FR_VCALL(0, sys_List, add, &args, args, f);
    FR_VCALL(0, sys_List, add, &args, args, g);
    return sys_BindFunc_callList(__env, __ret, __self, args);
__errTable:
    return __err;
}
fr_Err sys_BindFunc_call(fr_Env __env, sys_Obj_null *__ret, sys_BindFunc_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d, sys_Obj_null e, sys_Obj_null f, sys_Obj_null g, sys_Obj_null h) {
    FR_BEGIN_FUNC
    sys_List args;
    sys_List_make(__env, &args, 0);
    FR_VCALL(0, sys_List, add, &args, args, a);
    FR_VCALL(0, sys_List, add, &args, args, b);
    FR_VCALL(0, sys_List, add, &args, args, c);
    FR_VCALL(0, sys_List, add, &args, args, d);
    FR_VCALL(0, sys_List, add, &args, args, e);
    FR_VCALL(0, sys_List, add, &args, args, f);
    FR_VCALL(0, sys_List, add, &args, args, h);
    return sys_BindFunc_callList(__env, __ret, __self, args);
__errTable:
    return __err;
}
