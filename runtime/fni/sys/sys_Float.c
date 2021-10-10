#include "fni_ext.h"
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
    
    if (checked && ((pos-str) != strlen(str)) ) {
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

fr_Bool sys_Float_isNaN_val(fr_Env env, fr_Float self) {
    return isnan(self);
}

fr_Float sys_Float_negate_val(fr_Env env, fr_Float self) {
    return -self;
}

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

void sys_Float_make_val(fr_Env env, fr_Float self) {
    return;
}

fr_Obj sys_Float_toLocale_val(fr_Env env, fr_Float selfj, fr_Obj pattern){
    return sys_Float_toStr_val(env, selfj);
}

fr_Int sys_Float_toInt_val(fr_Env env, fr_Float self) { return (fr_Int)self; }
