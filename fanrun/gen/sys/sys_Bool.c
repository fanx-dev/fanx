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

fr_Err sys_Bool_equals_val(fr_Env __env, sys_Bool *__ret, sys_Bool_val __self, sys_Obj_null obj){
    if (!obj) *__ret = false;
    if (FR_TYPE_IS(obj, sys_Bool)) {
        sys_Bool_ref other = (sys_Bool_ref)obj;
        *__ret = __self == other->_val;
    }
    *__ret = false;
    return 0;
}
fr_Err sys_Bool_not__val(fr_Env __env, sys_Bool *__ret, sys_Bool_val __self){
    *__ret = !__self;
    return 0;
}
fr_Err sys_Bool_and__val(fr_Env __env, sys_Bool *__ret, sys_Bool_val __self, sys_Bool b){
    *__ret = __self && b;
    return 0;
}
fr_Err sys_Bool_or__val(fr_Env __env, sys_Bool *__ret, sys_Bool_val __self, sys_Bool b){
    *__ret = __self || b;
    return 0;
}
fr_Err sys_Bool_xor__val(fr_Env __env, sys_Bool *__ret, sys_Bool_val __self, sys_Bool b){
    *__ret = __self ^ b;
    return 0;
}

fr_Err sys_Bool_static__init(fr_Env __env) { return 0; }

