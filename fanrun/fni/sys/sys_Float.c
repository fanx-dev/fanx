#include "vm.h"
//#include "pod_sys_struct.h"
#include "pod_sys_native.h"

#include <math.h>
#include <float.h>
#include <string.h>
#include <stdlib.h>

#define cf_Math_pi 3.14159265358979323846

fr_Float sys_Float_makeBits(fr_Env env, fr_Int bits) {
    double *d = (double*)(&bits);
    return *d;
}
fr_Float sys_Float_makeBits32(fr_Env env, fr_Int bits) {
    int32_t i = (int32_t)bits;
    float *d = (float*)(&i);
    return *d;
}
fr_Float sys_Float_fromStr(fr_Env env, fr_Obj s, fr_Bool checked) {
    const char *str = fr_getStrUtf8(env, s);
    char *pos = NULL;
    fr_Float val = strtod(str, &pos);
    
    if (checked && ((str-pos) != strlen(str)) ) {
        char buf[128];
        snprintf(buf, 128, "Invalid Float: %s", str);
        fr_throwNew(env, "sys", "ParseErr", buf);
    }
    return val;
}
fr_Float sys_Float_random(fr_Env env) {
    fr_Float v = (double)(rand()) / RAND_MAX;
    return v;
}
//void sys_Float_privateMake_val(fr_Env env, fr_Float self) {
//    //return 0;
//}
fr_Bool sys_Float_equals_val(fr_Env env, fr_Float self, fr_Obj obj) {
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
    fr_Float *other = (fr_Float *)fr_getPtr(env, obj);
    eq = self == *other;
    //fr_unlock(env);
    return eq;
}
/*
fr_Bool sys_Float_approx_val(fr_Env env, fr_Float self, fr_Float r, fr_Obj tolerance) {
    return 0;
}
fr_Int sys_Float_compare_val(fr_Env env, fr_Float self, fr_Obj obj) {
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
fr_Bool sys_Float_isNaN_val(fr_Env env, fr_Float self) {
    return isnan(self);
}
/*
fr_Bool sys_Float_isNegZero_val(fr_Env env, fr_Float self) {
    return self == -0.0;
}
fr_Float sys_Float_normNegZero_val(fr_Env env, fr_Float self) {
    return 0.0;
}
fr_Int sys_Float_hash_val(fr_Env env, fr_Float self) {
    return *((fr_Int*)(&self));
}
*/
fr_Float sys_Float_negate_val(fr_Env env, fr_Float self) {
    return -self;
}
/*
fr_Float sys_Float_increment_val(fr_Env env, fr_Float self) {
    return ++self;
}
fr_Float sys_Float_decrement_val(fr_Env env, fr_Float self) {
    return --self;
}
 */
fr_Float sys_Float_mult_val(fr_Env env, fr_Float self, fr_Float b) {
    return self * b;
}
fr_Float sys_Float_multInt_val(fr_Env env, fr_Float self, fr_Int b) {
    return self * b;
}
fr_Float sys_Float_div_val(fr_Env env, fr_Float self, fr_Float b) {
    return self / b;
}
fr_Float sys_Float_divInt_val(fr_Env env, fr_Float self, fr_Int b) {
    return self / b;
}
fr_Float sys_Float_mod_val(fr_Env env, fr_Float self, fr_Float b) {
    return fmod(self, b);
}
fr_Float sys_Float_modInt_val(fr_Env env, fr_Float self, fr_Int b) {
    return fmod(self, b);
}
fr_Float sys_Float_plus_val(fr_Env env, fr_Float self, fr_Float b) {
    return self + b;
}
fr_Float sys_Float_plusInt_val(fr_Env env, fr_Float self, fr_Int b) {
    return self + b;
}
fr_Float sys_Float_minus_val(fr_Env env, fr_Float self, fr_Float b) {
    return self - b;
}
fr_Float sys_Float_minusInt_val(fr_Env env, fr_Float self, fr_Int b) {
    return self - b;
}
/*
fr_Float sys_Float_abs_val(fr_Env env, fr_Float self) {
    return fabs(self);
}
fr_Float sys_Float_min_val(fr_Env env, fr_Float self, fr_Float that) {
    if (self < that) {
        return self;
    }
    return that;
}
fr_Float sys_Float_max_val(fr_Env env, fr_Float self, fr_Float that) {
    if (self > that) {
        return self;
    }
    return that;
}
fr_Float sys_Float_ceil_val(fr_Env env, fr_Float self) {
    return ceil(self);
}
fr_Float sys_Float_floor_val(fr_Env env, fr_Float self) {
    return floor(self);
}
fr_Float sys_Float_round_val(fr_Env env, fr_Float self) {
    return round(self);
}
fr_Float sys_Float_exp_val(fr_Env env, fr_Float self) {
    return exp(self);
}
fr_Float sys_Float_log_val(fr_Env env, fr_Float self) {
    return log(self);
}
fr_Float sys_Float_log10_val(fr_Env env, fr_Float self) {
    return log10(self);
}
fr_Float sys_Float_pow_val(fr_Env env, fr_Float self, fr_Float pow) {
    //TODO
    return 0;//pow(self, pow);
}
fr_Float sys_Float_sqrt_val(fr_Env env, fr_Float self) {
    return sqrt(self);
}
fr_Float sys_Float_acos_val(fr_Env env, fr_Float self) {
    return acos(self);
}
fr_Float sys_Float_asin_val(fr_Env env, fr_Float self) {
    return asin(self);
}
fr_Float sys_Float_atan_val(fr_Env env, fr_Float self) {
    return atan(self);
}
fr_Float sys_Float_atan2(fr_Env env, fr_Float y, fr_Float x) {
    return atan2(y, x);
}
fr_Float sys_Float_cos_val(fr_Env env, fr_Float self) {
    return cos(self);
}
fr_Float sys_Float_cosh_val(fr_Env env, fr_Float self) {
    return cosh(self);
}
fr_Float sys_Float_sin_val(fr_Env env, fr_Float self) {
    return sin(self);
}
fr_Float sys_Float_sinh_val(fr_Env env, fr_Float self) {
    return sinh(self);
}
fr_Float sys_Float_tan_val(fr_Env env, fr_Float self) {
    return tan(self);
}
fr_Float sys_Float_tanh_val(fr_Env env, fr_Float self) {
    return tanh(self);
}
fr_Float sys_Float_toDegrees_val(fr_Env env, fr_Float self) {
    return ((self)/cf_Math_pi*180.0);
}
fr_Float sys_Float_toRadians_val(fr_Env env, fr_Float self) {
    return ((self)/180.0*cf_Math_pi);
}
*/
fr_Int sys_Float_bits_val(fr_Env env, fr_Float self) {
    int64_t *v = (int64_t*)(&self);
    return *v;
}
fr_Int sys_Float_bits32_val(fr_Env env, fr_Float self) {
    float f = self;
    int32_t *v = (int32_t*)(&f);
    return *v;
}
fr_Obj sys_Float_toStr_val(fr_Env env, fr_Float self) {
    char buf[128];
    buf[0] = 0;
    fr_Obj str;
    
    if (self == -0.0) {
        return fr_newStrUtf8(env, "-0.0");
    }
    else if (isnan(self)) {
        return fr_newStrUtf8(env, "NaN");
    }
    else if (isinf(self)) {
        if (self > 0) {
            return fr_newStrUtf8(env, "INF");
        }
        else {
            return fr_newStrUtf8(env, "-INF");
        }
    }
    
    snprintf(buf, 128, "%g", self);
    str = fr_newStrUtf8(env, buf);
    
    return str;
}
/*
fr_Obj sys_Float_toCode_val(fr_Env env, fr_Float self) {
    return sys_Float_toStr(env, self);
}
*/
void sys_Float_make_val(fr_Env env, fr_Float self) {
    return;
}
//void sys_Float_static__init(fr_Env env) {
//    fr_Value val;
//    //val.type = fr_vtFloat;
//    val.i = 0;
//    fr_setStaticFieldS(env, "sys", "Float", "defVal", &val);
//    val.i = INFINITY;
//    fr_setStaticFieldS(env, "sys", "Float", "posInf", &val);
//    val.i = -INFINITY;
//    fr_setStaticFieldS(env, "sys", "Float", "negInf", &val);
//    val.i = NAN;
//    fr_setStaticFieldS(env, "sys", "Float", "nan", &val);
//    val.i = 2.71828182845904523536;
//    fr_setStaticFieldS(env, "sys", "Float", "e", &val);
//    val.i = cf_Math_pi;
//    fr_setStaticFieldS(env, "sys", "Float", "pi", &val);
//    return;
//}
fr_Obj sys_Float_toLocale_val(fr_Env env, fr_Float selfj, fr_Obj pattern){
    return sys_Float_toStr_val(env, selfj);
}

fr_Int sys_Float_toInt_val(fr_Env env, fr_Float self) { return (fr_Int)self; }
