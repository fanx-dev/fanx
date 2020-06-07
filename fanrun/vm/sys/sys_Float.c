#include "vm.h"
#include "pod_sys_struct.h"
#include "pod_sys_native.h"

#include <math.h>
#include <float.h>

#define cf_Math_pi 3.14159265358979323846

fr_Float sys_Float_makeBits_f(fr_Env env, fr_Int bits) {
    return 0;
}
fr_Float sys_Float_makeBits32_f(fr_Env env, fr_Int bits) {
    return 0;
}
fr_Float sys_Float_fromStr_f(fr_Env env, fr_Obj s, fr_Bool checked) {
    return 0;
}
fr_Float sys_Float_random_f(fr_Env env) {
    return 0;
}
void sys_Float_privateMake_f(fr_Env env, fr_Float self) {
    //return 0;
}
fr_Bool sys_Float_equals_f(fr_Env env, fr_Float self, fr_Obj obj) {
    fr_Type type;
    bool eq = false;
    
    if (obj == NULL) {
        return false;
    }
    type = fr_toType(env, fr_vtFloat);
    
    if (!fr_isInstanceOf(env, obj, type)) {
        return false;
    }
    
    //fr_lock(env);
    struct sys_Float_ *other = (struct sys_Float_ *)fr_getPtr(env, obj);
    eq = self == other->value;
    //fr_unlock(env);
    return eq;
}
/*
fr_Bool sys_Float_approx_f(fr_Env env, fr_Float self, fr_Float r, fr_Obj tolerance) {
    return 0;
}
fr_Int sys_Float_compare_f(fr_Env env, fr_Float self, fr_Obj obj) {
    fr_Type type;
    fr_Int result;
    
    if (obj == NULL) {
        return 0;
    }
    type = fr_toType(env, fr_vtFloat);
    
    if (!fr_isInstanceOf(env, obj, type)) {
        fr_throwNew(env, "sys", "CastErr", "can not compare with float");
        return 0;
    }
    
    //fr_lock(env);
    struct sys_Float_ *other = (struct sys_Float_ *)fr_getPtr(env, obj);
    result = self - other->value;
    //fr_unlock(env);
    return result;
}
 */
fr_Bool sys_Float_isNaN_f(fr_Env env, fr_Float self) {
    return isnan(self);
}
/*
fr_Bool sys_Float_isNegZero_f(fr_Env env, fr_Float self) {
    return self == -0.0;
}
fr_Float sys_Float_normNegZero_f(fr_Env env, fr_Float self) {
    return 0.0;
}
fr_Int sys_Float_hash_f(fr_Env env, fr_Float self) {
    return *((fr_Int*)(&self));
}
*/
fr_Float sys_Float_negate_f(fr_Env env, fr_Float self) {
    return -self;
}
/*
fr_Float sys_Float_increment_f(fr_Env env, fr_Float self) {
    return ++self;
}
fr_Float sys_Float_decrement_f(fr_Env env, fr_Float self) {
    return --self;
}
 */
fr_Float sys_Float_mult_f(fr_Env env, fr_Float self, fr_Float b) {
    return self * b;
}
fr_Float sys_Float_multInt_f(fr_Env env, fr_Float self, fr_Int b) {
    return self * b;
}
fr_Float sys_Float_div_f(fr_Env env, fr_Float self, fr_Float b) {
    return self / b;
}
fr_Float sys_Float_divInt_f(fr_Env env, fr_Float self, fr_Int b) {
    return self / b;
}
fr_Float sys_Float_mod_f(fr_Env env, fr_Float self, fr_Float b) {
    //TODO
    return 0;//self % b;
}
fr_Float sys_Float_modInt_f(fr_Env env, fr_Float self, fr_Int b) {
    return 0;
}
fr_Float sys_Float_plus_f(fr_Env env, fr_Float self, fr_Float b) {
    return self + b;
}
fr_Float sys_Float_plusInt_f(fr_Env env, fr_Float self, fr_Int b) {
    return self + b;
}
fr_Float sys_Float_minus_f(fr_Env env, fr_Float self, fr_Float b) {
    return self - b;
}
fr_Float sys_Float_minusInt_f(fr_Env env, fr_Float self, fr_Int b) {
    return self - b;
}
/*
fr_Float sys_Float_abs_f(fr_Env env, fr_Float self) {
    return fabs(self);
}
fr_Float sys_Float_min_f(fr_Env env, fr_Float self, fr_Float that) {
    if (self < that) {
        return self;
    }
    return that;
}
fr_Float sys_Float_max_f(fr_Env env, fr_Float self, fr_Float that) {
    if (self > that) {
        return self;
    }
    return that;
}
fr_Float sys_Float_ceil_f(fr_Env env, fr_Float self) {
    return ceil(self);
}
fr_Float sys_Float_floor_f(fr_Env env, fr_Float self) {
    return floor(self);
}
fr_Float sys_Float_round_f(fr_Env env, fr_Float self) {
    return round(self);
}
fr_Float sys_Float_exp_f(fr_Env env, fr_Float self) {
    return exp(self);
}
fr_Float sys_Float_log_f(fr_Env env, fr_Float self) {
    return log(self);
}
fr_Float sys_Float_log10_f(fr_Env env, fr_Float self) {
    return log10(self);
}
fr_Float sys_Float_pow_f(fr_Env env, fr_Float self, fr_Float pow) {
    //TODO
    return 0;//pow(self, pow);
}
fr_Float sys_Float_sqrt_f(fr_Env env, fr_Float self) {
    return sqrt(self);
}
fr_Float sys_Float_acos_f(fr_Env env, fr_Float self) {
    return acos(self);
}
fr_Float sys_Float_asin_f(fr_Env env, fr_Float self) {
    return asin(self);
}
fr_Float sys_Float_atan_f(fr_Env env, fr_Float self) {
    return atan(self);
}
fr_Float sys_Float_atan2_f(fr_Env env, fr_Float y, fr_Float x) {
    return atan2(y, x);
}
fr_Float sys_Float_cos_f(fr_Env env, fr_Float self) {
    return cos(self);
}
fr_Float sys_Float_cosh_f(fr_Env env, fr_Float self) {
    return cosh(self);
}
fr_Float sys_Float_sin_f(fr_Env env, fr_Float self) {
    return sin(self);
}
fr_Float sys_Float_sinh_f(fr_Env env, fr_Float self) {
    return sinh(self);
}
fr_Float sys_Float_tan_f(fr_Env env, fr_Float self) {
    return tan(self);
}
fr_Float sys_Float_tanh_f(fr_Env env, fr_Float self) {
    return tanh(self);
}
fr_Float sys_Float_toDegrees_f(fr_Env env, fr_Float self) {
    return ((self)/cf_Math_pi*180.0);
}
fr_Float sys_Float_toRadians_f(fr_Env env, fr_Float self) {
    return ((self)/180.0*cf_Math_pi);
}
*/
fr_Int sys_Float_bits_f(fr_Env env, fr_Float self) {
    return 0;
}
fr_Int sys_Float_bits32_f(fr_Env env, fr_Float self) {
    return 0;
}
fr_Obj sys_Float_toStr_f(fr_Env env, fr_Float self) {
    char buf[128];
    buf[0] = 0;
    fr_Obj str;
    
    snprintf(buf, 128, "%g", self);
    str = fr_newStrUtf8(env, buf);
    
    return str;
}
/*
fr_Obj sys_Float_toCode_f(fr_Env env, fr_Float self) {
    return sys_Float_toStr_f(env, self);
}
*/
void sys_Float_make_f(fr_Env env, fr_Float self) {
    return;
}
void sys_Float_static__init_f(fr_Env env) {
    fr_Value val;
    //val.type = fr_vtFloat;
    val.i = 0;
    fr_setStaticFieldS(env, "sys", "Float", "defVal", &val);
    val.i = INFINITY;
    fr_setStaticFieldS(env, "sys", "Float", "posInf", &val);
    val.i = -INFINITY;
    fr_setStaticFieldS(env, "sys", "Float", "negInf", &val);
    val.i = NAN;
    fr_setStaticFieldS(env, "sys", "Float", "nan", &val);
    val.i = 2.71828182845904523536;
    fr_setStaticFieldS(env, "sys", "Float", "e", &val);
    val.i = cf_Math_pi;
    fr_setStaticFieldS(env, "sys", "Float", "pi", &val);
    return;
}
fr_Obj sys_Float_toLocale_f(fr_Env env, fr_Float selfj, fr_Obj pattern){ return 0; }

fr_Int sys_Float_toInt_f(fr_Env env, fr_Float self) { return (fr_Int)self; }
