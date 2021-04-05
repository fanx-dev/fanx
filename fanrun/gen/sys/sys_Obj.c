//
//  sys_Obj.c
//  run
//
//  Created by yangjiandong on 2017/12/17.
//  Copyright © 2017年 yangjiandong. All rights reserved.
//

#include "sys.h"
#include <stdio.h>

sys_Obj_null sys_Obj_trap(fr_Env __env, sys_Obj_ref __self, sys_Str name, sys_List_null args) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); }

sys_Enum_null sys_Enum_doFromStr(fr_Env __env, sys_Str type, sys_Str name, sys_Bool checked) { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); }


