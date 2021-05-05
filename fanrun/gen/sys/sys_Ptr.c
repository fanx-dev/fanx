

#include "sys.h"


sys_Ptr sys_Ptr_nil = 0;

void sys_Ptr_make_val(fr_Env __env, sys_Ptr_pass __self) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); }
sys_Ptr sys_Ptr_stackAlloc(fr_Env __env, sys_Int size) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); }
sys_Obj_null sys_Ptr_load_val(fr_Env __env, sys_Ptr_pass __self) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); }
void sys_Ptr_store_val(fr_Env __env, sys_Ptr_pass __self, sys_Obj_null v) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); }
sys_Ptr sys_Ptr_plus_val(fr_Env __env, sys_Ptr_pass __self, sys_Int b) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); }
void sys_Ptr_set_val(fr_Env __env, sys_Ptr_pass __self, sys_Int index, sys_Obj_null item) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); }
sys_Obj_null sys_Ptr_get_val(fr_Env __env, sys_Ptr_pass __self, sys_Int index) { FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); }
