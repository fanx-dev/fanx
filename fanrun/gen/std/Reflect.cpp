#include "std.h"

fr_Err std_PodList_doInit(fr_Env __env, std_PodList_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Pod_doInit(fr_Env __env, std_Pod_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_BaseType_doInit(fr_Env __env, std_BaseType_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }



fr_Err std_Pod_load(fr_Env __env, std_Pod *__ret, std_InStream in) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Pod_files(fr_Env __env, sys_List *__ret, std_Pod_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Pod_file(fr_Env __env, std_File_null *__ret, std_Pod_ref __self, std_Uri uri, sys_Bool checked) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }



fr_Err std_Type_typeof_(fr_Env __env, std_Type *__ret, sys_Obj obj) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }

fr_Err sys_Enum_doFromStr(fr_Env __env, sys_Enum_null *__ret, sys_Str type, sys_Str name, sys_Bool checked) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }



//fr_Err std_Field_privateMake(fr_Env __env, std_Field *__ret) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
//fr_Err std_Field_type(fr_Env __env, std_Type *__ret, std_Field_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Field_get(fr_Env __env, sys_Obj_null *__ret, std_Field_ref __self, sys_Obj_null instance) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Field__unsafeSet(fr_Env __env, std_Field_ref __self, sys_Obj_null instance, sys_Obj_null value, sys_Bool checkConst) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }

//fr_Err std_Method_privateMake(fr_Env __env, std_Method *__ret) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
//fr_Err std_Method_returns(fr_Env __env, std_Type *__ret, std_Method_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
//fr_Err std_Method_params(fr_Env __env, sys_List *__ret, std_Method_ref __self) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
//fr_Err std_Method_func(fr_Env __env, sys_Func *__ret, std_Method_ref __self, sys_Int arity) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
fr_Err std_Method_call(fr_Env __env, sys_Obj_null *__ret, std_Method_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d, sys_Obj_null e, sys_Obj_null f, sys_Obj_null g, sys_Obj_null h) { FR_RET_ALLOC_THROW(sys_UnsupportedErr); }
