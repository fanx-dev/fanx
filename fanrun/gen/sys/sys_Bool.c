//
//  sys_Bool.c
//  run
//
//  Created by yangjiandong on 2017/12/17.
//  Copyright © 2017年 yangjiandong. All rights reserved.
//

#include "sys.h"
#include <wchar.h>

sys_Bool sys_Bool_defVal = false;


sys_Bool sys_Bool_equals_val(fr_Env __env, sys_Bool_pass __self, sys_Obj_null obj) {
    if (!obj) return false;
    if (FR_TYPE_IS(obj, sys_Bool)) {
        sys_Bool_ref other = (sys_Bool_ref)obj;
        return __self == other->_val;
    }
    return false;
}

sys_Bool sys_Bool_not__val(fr_Env __env, sys_Bool_pass __self) { return !__self; }
sys_Bool sys_Bool_and__val(fr_Env __env, sys_Bool_pass __self, sys_Bool b) { return __self && b; }
sys_Bool sys_Bool_or__val(fr_Env __env, sys_Bool_pass __self, sys_Bool b) { return __self || b; }
sys_Bool sys_Bool_xor__val(fr_Env __env, sys_Bool_pass __self, sys_Bool b) { return __self ^ b; }

void sys_Bool_static__init(fr_Env __env) {}

