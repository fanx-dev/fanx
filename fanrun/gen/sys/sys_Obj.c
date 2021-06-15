//
//  sys_Obj.c
//  run
//
//  Created by yangjiandong on 2017/12/17.
//  Copyright © 2017年 yangjiandong. All rights reserved.
//

#include "sys.h"
#include <stdio.h>

sys_Obj_null sys_Obj_trap(fr_Env __env, sys_Obj_ref __self, sys_Str name, sys_List_null args) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }

sys_Enum_null sys_Enum_doFromStr(fr_Env __env, sys_Str type, sys_Str name, sys_Bool checked) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0; }


sys_Bool sys_Obj_isImmutable(fr_Env __env, sys_Obj_ref __self) {
	fr_Type t = fr_getClass(__env, __self);
	if (t->flags & 0x00000002) return true;
	return false;
}
