#include "fni_ext.h"
#include "pod_std_native.h"
#include <math.h>

fr_Float std_Math_ceil(fr_Env env, fr_Float self) {
    return ceil(self);
}
fr_Float std_Math_floor(fr_Env env, fr_Float self) {
    return floor(self);
}
fr_Float std_Math_round(fr_Env env, fr_Float self) {
    return round(self);
}
fr_Float std_Math_exp(fr_Env env, fr_Float self) {
    return exp(self);
}
fr_Float std_Math_log(fr_Env env, fr_Float self) {
    return log(self);
}
fr_Float std_Math_log10(fr_Env env, fr_Float self) {
    return log10(self);
}
fr_Float std_Math_pow(fr_Env env, fr_Float self, fr_Float exponent) {
    return pow(self, exponent);
}
fr_Float std_Math_sqrt(fr_Env env, fr_Float self) {
    return sqrt(self);
}
fr_Float std_Math_acos(fr_Env env, fr_Float self) {
    return acos(self);
}
fr_Float std_Math_asin(fr_Env env, fr_Float self) {
    return asin(self);
}
fr_Float std_Math_atan(fr_Env env, fr_Float self) {
    return atan(self);
}
fr_Float std_Math_atan2(fr_Env env, fr_Float y, fr_Float x) {
    return atan2(y, x);
}
fr_Float std_Math_cos(fr_Env env, fr_Float self) {
    return cos(self);
}
fr_Float std_Math_cosh(fr_Env env, fr_Float self) {
    return cosh(self);
}
fr_Float std_Math_sin(fr_Env env, fr_Float self) {
    return sin(self);
}
fr_Float std_Math_sinh(fr_Env env, fr_Float self) {
    return sinh(self);
}
fr_Float std_Math_tan(fr_Env env, fr_Float self) {
    return tan(self);
}
fr_Float std_Math_tanh(fr_Env env, fr_Float self) {
    return tanh(self);
}
