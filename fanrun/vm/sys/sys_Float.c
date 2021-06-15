#include "vm.h"
#include "pod_sys_struct.h"
#include "pod_sys_native.h"

#include <math.h>
#include <float.h>

#define cf_Math_pi 3.14159265358979323846

fr_Float sys_Float_makeBits(fr_Env env, fr_Int bits) {
    return 0;
}
fr_Float sys_Float_makeBits32(fr_Env env, fr_Int bits) {
    return 0;
}
fr_Float sys_Float_fromStr(fr_Env env, fr_Obj s, fr_Bool checked) {
    return 0;
}
fr_Float sys_Float_random(fr_Env env) {
    return 0;
}
void sys_Float_privateMake(fr_Env env, fr_Float self) {
    //return 0;
}
fr_Bool sys_Float_equals(fr_Env env, fr_Float self, fr_Obj obj) {
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
fr_Bool sys_Float_approx(fr_Env env, fr_Float self, fr_Float r, fr_Obj tolerance) {
    return 0;
}
fr_Int sys_Float_compare(fr_Env env, fr_Float self, fr_Obj obj) {
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
fr_Bool sys_Float_isNaN(fr_Env env, fr_Float self) {
    return isnan(self);
}
/*
fr_Bool sys_Float_isNegZero(fr_Env env, fr_Float self) {
    return self == -0.0;
}
fr_Float sys_Float_normNegZero(fr_Env env, fr_Float self) {
    return 0.0;
}
fr_Int sys_Float_hash(fr_Env env, fr_Float self) {
    return *((fr_Int*)(&self));
}
*/
fr_Float sys_Float_negate(fr_Env env, fr_Float self) {
    return -self;
}
/*
fr_Float sys_Float_increment(fr_Env env, fr_Float self) {
    return ++self;
}
fr_Float sys_Float_decrement(fr_Env env, fr_Float self) {
    return --self;
}
 */
fr_Float sys_Float_mult(fr_Env env, fr_Float self, fr_Float b) {
    return self * b;
}
fr_Float sys_Float_multInt(fr_Env env, fr_Float self, fr_Int b) {
    return self * b;
}
fr_Float sys_Float_div(fr_Env env, fr_Float self, fr_Float b) {
    return self / b;
}
fr_Float sys_Float_divInt(fr_Env env, fr_Float self, fr_Int b) {
    return self / b;
}
fr_Float sys_Float_mod(fr_Env env, fr_Float self, fr_Float b) {
    //TODO
    return 0;//self % b;
}
fr_Float sys_Float_modInt(fr_Env env, fr_Float self, fr_Int b) {
    return 0;
}
fr_Float sys_Float_plus(fr_Env env, fr_Float self, fr_Float b) {
    return self + b;
}
fr_Float sys_Float_plusInt(fr_Env env, fr_Float self, fr_Int b) {
    return self + b;
}
fr_Float sys_Float_minus(fr_Env env, fr_Float self, fr_Float b) {
    return self - b;
}
fr_Float sys_Float_minusInt(fr_Env env, fr_Float self, fr_Int b) {
    return self - b;
}
/*
fr_Float sys_Float_abs(fr_Env env, fr_Float self) {
    return fabs(self);
}
fr_Float sys_Float_min(fr_Env env, fr_Float self, fr_Float that) {
    if (self < that) {
        return self;
    }
    return that;
}
fr_Float sys_Float_max(fr_Env env, fr_Float self, fr_Float that) {
    if (self > that) {
        return self;
    }
    return that;
}
fr_Float sys_Float_ceil(fr_Env env, fr_Float self) {
    return ceil(self);
}
fr_Float sys_Float_floor(fr_Env env, fr_Float self) {
    return floor(self);
}
fr_Float sys_Float_round(fr_Env env, fr_Float self) {
    return round(self);
}
fr_Float sys_Float_exp(fr_Env env, fr_Float self) {
    return exp(self);
}
fr_Float sys_Float_log(fr_Env env, fr_Float self) {
    return log(self);
}
fr_Float sys_Float_log10(fr_Env env, fr_Float self) {
    return log10(self);
}
fr_Float sys_Float_pow(fr_Env env, fr_Float self, fr_Float pow) {
    //TODO
    return 0;//pow(self, pow);
}
fr_Float sys_Float_sqrt(fr_Env env, fr_Float self) {
    return sqrt(self);
}
fr_Float sys_Float_acos(fr_Env env, fr_Float self) {
    return acos(self);
}
fr_Float sys_Float_asin(fr_Env env, fr_Float self) {
    return asin(self);
}
fr_Float sys_Float_atan(fr_Env env, fr_Float self) {
    return atan(self);
}
fr_Float sys_Float_atan2(fr_Env env, fr_Float y, fr_Float x) {
    return atan2(y, x);
}
fr_Float sys_Float_cos(fr_Env env, fr_Float self) {
    return cos(self);
}
fr_Float sys_Float_cosh(fr_Env env, fr_Float self) {
    return cosh(self);
}
fr_Float sys_Float_sin(fr_Env env, fr_Float self) {
    return sin(self);
}
fr_Float sys_Float_sinh(fr_Env env, fr_Float self) {
    return sinh(self);
}
fr_Float sys_Float_tan(fr_Env env, fr_Float self) {
    return tan(self);
}
fr_Float sys_Float_tanh(fr_Env env, fr_Float self) {
    return tanh(self);
}
fr_Float sys_Float_toDegrees(fr_Env env, fr_Float self) {
    return ((self)/cf_Math_pi*180.0);
}
fr_Float sys_Float_toRadians(fr_Env env, fr_Float self) {
    return ((self)/180.0*cf_Math_pi);
}
*/
fr_Int sys_Float_bits(fr_Env env, fr_Float self) {
    return 0;
}
fr_Int sys_Float_bits32(fr_Env env, fr_Float self) {
    return 0;
}
fr_Obj sys_Float_toStr(fr_Env env, fr_Float self) {
    char buf[128];
    buf[0] = 0;
    fr_Obj str;
    
    snprintf(buf, 128, "%g", self);
    str = fr_newStrUtf8(env, buf);
    
    return str;
}
/*
fr_Obj sys_Float_toCode(fr_Env env, fr_Float self) {
    return sys_Float_toStr(env, self);
}
*/
void sys_Float_make(fr_Env env, fr_Float self) {
    return;
}
void sys_Float_static__init(fr_Env env) {
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
fr_Obj sys_Float_toLocale(fr_Env env, fr_Float selfj, fr_Obj pattern){ return 0; }

fr_Int sys_Float_toInt(fr_Env env, fr_Float self) { return (fr_Int)self; }
