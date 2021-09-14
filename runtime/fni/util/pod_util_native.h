#include "fni_ext.h"
CF_BEGIN

void util_SeededRandom_init(fr_Env env, fr_Obj self);
fr_Int util_SeededRandom_next(fr_Env env, fr_Obj self, fr_Obj r);
fr_Bool util_SeededRandom_nextBool(fr_Env env, fr_Obj self);
fr_Float util_SeededRandom_nextFloat(fr_Env env, fr_Obj self);
fr_Obj util_SeededRandom_nextBuf(fr_Env env, fr_Obj self, fr_Int size);
void util_SecureRandom_init(fr_Env env, fr_Obj self);
fr_Int util_SecureRandom_next(fr_Env env, fr_Obj self, fr_Obj r);
fr_Bool util_SecureRandom_nextBool(fr_Env env, fr_Obj self);
fr_Float util_SecureRandom_nextFloat(fr_Env env, fr_Obj self);
fr_Obj util_SecureRandom_nextBuf(fr_Env env, fr_Obj self, fr_Int size);
fr_Obj util_Unit_define(fr_Env env, fr_Obj s);
fr_Obj util_Unit_fromStr(fr_Env env, fr_Obj s, fr_Bool checked);
fr_Obj util_Unit_list(fr_Env env);
fr_Obj util_Unit_quantities(fr_Env env);
fr_Obj util_Unit_quantity(fr_Env env, fr_Obj quantity);
fr_Bool util_Unit_equals(fr_Env env, fr_Obj self, fr_Obj that);
fr_Int util_Unit_hash(fr_Env env, fr_Obj self);
fr_Obj util_Unit_toStr(fr_Env env, fr_Obj self);
fr_Obj util_Unit_ids(fr_Env env, fr_Obj self);
fr_Obj util_Unit_name(fr_Env env, fr_Obj self);
fr_Obj util_Unit_symbol(fr_Env env, fr_Obj self);
fr_Float util_Unit_scale(fr_Env env, fr_Obj self);
fr_Float util_Unit_offset(fr_Env env, fr_Obj self);
fr_Obj util_Unit_definition(fr_Env env, fr_Obj self);
fr_Obj util_Unit_dim(fr_Env env, fr_Obj self);
fr_Int util_Unit_kg(fr_Env env, fr_Obj self);
fr_Int util_Unit_m(fr_Env env, fr_Obj self);
fr_Int util_Unit_sec(fr_Env env, fr_Obj self);
fr_Int util_Unit_K(fr_Env env, fr_Obj self);
fr_Int util_Unit_A(fr_Env env, fr_Obj self);
fr_Int util_Unit_mol(fr_Env env, fr_Obj self);
fr_Int util_Unit_cd(fr_Env env, fr_Obj self);
fr_Obj util_Unit_mult(fr_Env env, fr_Obj self, fr_Obj that);
fr_Obj util_Unit_div(fr_Env env, fr_Obj self, fr_Obj b);
fr_Float util_Unit_convertTo(fr_Env env, fr_Obj self, fr_Float scalar, fr_Obj unit);

CF_END
