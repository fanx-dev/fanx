//
//  sys_Func.c
//  run
//
//  Created by yangjiandong on 2017/12/17.
//  Copyright © 2017年 yangjiandong. All rights reserved.
//

#include "sys.h"


sys_Obj_null sys_Func_call(fr_Env __env, sys_Func_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d, sys_Obj_null e, sys_Obj_null f, sys_Obj_null g, sys_Obj_null h) {
    return sys_Func_call__7(__env, __self, a, b, c, d, e, f, g);
}
sys_Obj_null sys_Func_call__8(fr_Env __env, sys_Func_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d, sys_Obj_null e, sys_Obj_null f, sys_Obj_null g, sys_Obj_null h) {
    return sys_Func_call__7(__env, __self, a, b, c, d, e, f, g);
}
sys_Obj_null sys_Func_call__7(fr_Env __env, sys_Func_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d, sys_Obj_null e, sys_Obj_null f, sys_Obj_null g) {
    return sys_Func_call__6(__env, __self, a, b, c, d, e, f);
}
sys_Obj_null sys_Func_call__6(fr_Env __env, sys_Func_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d, sys_Obj_null e, sys_Obj_null f) {
    return sys_Func_call__5(__env, __self, a, b, c, d, e);
}
sys_Obj_null sys_Func_call__5(fr_Env __env, sys_Func_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d, sys_Obj_null e) {
    return sys_Func_call__4(__env, __self, a, b, c, d);
}
sys_Obj_null sys_Func_call__4(fr_Env __env, sys_Func_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d) {
    return sys_Func_call__3(__env, __self, a, b, c);
}
sys_Obj_null sys_Func_call__3(fr_Env __env, sys_Func_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c) {
    return sys_Func_call__2(__env, __self, a, b);
}
sys_Obj_null sys_Func_call__2(fr_Env __env, sys_Func_ref __self, sys_Obj_null a, sys_Obj_null b) {
    return sys_Func_call__1(__env, __self, a);
}
sys_Obj_null sys_Func_call__1(fr_Env __env, sys_Func_ref __self, sys_Obj_null a) {
    return sys_Func_call__0(__env, __self);
}
sys_Obj_null sys_Func_call__0(fr_Env __env, sys_Func_ref __self) {
    FR_SET_ERROR_MAKE(sys_ArgErr, "Func.call not override");
    return 0;
}


sys_Obj_null sys_BindFunc_call__0(fr_Env __env, sys_BindFunc_ref __self) {
    return sys_BindFunc_callList(__env, __self, NULL);
}
sys_Obj_null sys_BindFunc_call__1(fr_Env __env, sys_BindFunc_ref __self, sys_Obj_null a) {
    sys_List args = sys_List_make(__env, 1);
    FR_VCALL(sys_List, add, args, a);
    return sys_BindFunc_callList(__env, __self, args);
}
sys_Obj_null sys_BindFunc_call__2(fr_Env __env, sys_BindFunc_ref __self, sys_Obj_null a, sys_Obj_null b) {
    sys_List args = sys_List_make(__env, 2);
    FR_VCALL(sys_List, add, args, a);
    FR_VCALL(sys_List, add, args, b);
    return sys_BindFunc_callList(__env, __self, args);
}
sys_Obj_null sys_BindFunc_call__3(fr_Env __env, sys_BindFunc_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c) {
    sys_List args = sys_List_make(__env, 3);
    FR_VCALL(sys_List, add, args, a);
    FR_VCALL(sys_List, add, args, b);
    FR_VCALL(sys_List, add, args, c);
    return sys_BindFunc_callList(__env, __self, args);
}
sys_Obj_null sys_BindFunc_call__4(fr_Env __env, sys_BindFunc_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d) {
    sys_List args = sys_List_make(__env, 4);
    FR_VCALL(sys_List, add, args, a);
    FR_VCALL(sys_List, add, args, b);
    FR_VCALL(sys_List, add, args, c);
    FR_VCALL(sys_List, add, args, d);
    return sys_BindFunc_callList(__env, __self, args);
}
sys_Obj_null sys_BindFunc_call__5(fr_Env __env, sys_BindFunc_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d, sys_Obj_null e) {
    sys_List args = sys_List_make(__env, 5);
    FR_VCALL(sys_List, add, args, a);
    FR_VCALL(sys_List, add, args, b);
    FR_VCALL(sys_List, add, args, c);
    FR_VCALL(sys_List, add, args, d);
    FR_VCALL(sys_List, add, args, e);
    return sys_BindFunc_callList(__env, __self, args);
}
sys_Obj_null sys_BindFunc_call__6(fr_Env __env, sys_BindFunc_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d, sys_Obj_null e, sys_Obj_null f) {
    sys_List args = sys_List_make(__env, 6);
    FR_VCALL(sys_List, add, args, a);
    FR_VCALL(sys_List, add, args, b);
    FR_VCALL(sys_List, add, args, c);
    FR_VCALL(sys_List, add, args, d);
    FR_VCALL(sys_List, add, args, e);
    FR_VCALL(sys_List, add, args, f);
    return sys_BindFunc_callList(__env, __self, args);
}
sys_Obj_null sys_BindFunc_call__7(fr_Env __env, sys_BindFunc_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d, sys_Obj_null e, sys_Obj_null f, sys_Obj_null g) {
    sys_List args = sys_List_make(__env, 7);
    FR_VCALL(sys_List, add, args, a);
    FR_VCALL(sys_List, add, args, b);
    FR_VCALL(sys_List, add, args, c);
    FR_VCALL(sys_List, add, args, d);
    FR_VCALL(sys_List, add, args, e);
    FR_VCALL(sys_List, add, args, f);
    FR_VCALL(sys_List, add, args, g);
    return sys_BindFunc_callList(__env, __self, args);
}
sys_Obj_null sys_BindFunc_call(fr_Env __env, sys_BindFunc_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d, sys_Obj_null e, sys_Obj_null f, sys_Obj_null g, sys_Obj_null h) {
    sys_List args = sys_List_make(__env, 8);
    FR_VCALL(sys_List, add, args, a);
    FR_VCALL(sys_List, add, args, b);
    FR_VCALL(sys_List, add, args, c);
    FR_VCALL(sys_List, add, args, d);
    FR_VCALL(sys_List, add, args, e);
    FR_VCALL(sys_List, add, args, f);
    FR_VCALL(sys_List, add, args, g);
    FR_VCALL(sys_List, add, args, h);
    return sys_BindFunc_callList(__env, __self, args);
}
