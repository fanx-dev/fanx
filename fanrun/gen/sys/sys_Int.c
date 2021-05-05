#include "sys.h"
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>

sys_Int sys_Int_defVal = 0;
sys_Int sys_Int_maxVal = INT64_MAX;
sys_Int sys_Int_minVal = INT64_MIN;

sys_Int sys_Int_fromStr(fr_Env __env, sys_Str s, sys_Int radix, sys_Bool checked) {
    char *str_end;
    const char *str = (const char*)s->utf8->data;
    sys_Int res = strtoll(str, &str_end, (int)radix);
    if (checked && str_end == str) {
        sys_ParseErr e = FR_ALLOC(sys_ParseErr);
        FR_SET_ERROR(e); return 0;
    }
    return res;
}

sys_Int sys_Int_random(fr_Env __env, sys_Range_null r) {
    if (r == NULL) {
        sys_Int t = rand();
        sys_Int p = rand();
        sys_Int res = t | (p << 32);
        return res;
    }
    else {
        sys_Int res = rand();
        sys_Int size = r->_end - r->_start;
        res = r->_start + (res % size);
        return res;
    }
}

void sys_Int_privateMake_val(fr_Env __env, sys_Int_pass __self) { return 0; }

sys_Bool sys_Int_equals_val(fr_Env __env, sys_Int_pass __self, sys_Obj_null obj) {
    if (!obj) return false;
    if (FR_TYPE_IS(obj, sys_Int)) {
        sys_Int_ref other = (sys_Int_ref)obj;
        return __self == other->_val;
    }
    return false;
}

sys_Int sys_Int_compare_val(fr_Env __env, sys_Int_pass __self, sys_Obj obj) {
    if (!obj) { FR_SET_ERROR_NPE(); return 0; }
    if (FR_TYPE_IS(obj, sys_Int)) {
        sys_Int_ref other = (sys_Int_ref)obj;
        return __self - other->_val;
    }
    else {
        sys_Int other = (sys_Int)obj;
        return __self - other;
    }
}

sys_Int sys_Int_negate_val(fr_Env __env, sys_Int_pass __self) { return -__self; }

sys_Int sys_Int_increment_val(fr_Env __env, sys_Int_pass __self) { return ++__self; }

sys_Int sys_Int_decrement_val(fr_Env __env, sys_Int_pass __self) { return --__self; }

sys_Int sys_Int_mult_val(fr_Env __env, sys_Int_pass __self, sys_Int b) { return __self * b; }

sys_Float sys_Int_multFloat_val(fr_Env __env, sys_Int_pass __self, sys_Float b) { return __self * b; }

sys_Int sys_Int_div_val(fr_Env __env, sys_Int_pass __self, sys_Int b) { return __self / b; }

sys_Float sys_Int_divFloat_val(fr_Env __env, sys_Int_pass __self, sys_Float b) { return __self / b; }

sys_Int sys_Int_mod_val(fr_Env __env, sys_Int_pass __self, sys_Int b) { return __self% b; }

sys_Float sys_Int_modFloat_val(fr_Env __env, sys_Int_pass __self, sys_Float b) { return fmod(__self, b); }

sys_Int sys_Int_plus_val(fr_Env __env, sys_Int_pass __self, sys_Int b) { return __self + b; }

sys_Float sys_Int_plusFloat_val(fr_Env __env, sys_Int_pass __self, sys_Float b) { return __self + b; }

sys_Int sys_Int_minus_val(fr_Env __env, sys_Int_pass __self, sys_Int b) { return __self - b; }

sys_Float sys_Int_minusFloat_val(fr_Env __env, sys_Int_pass __self, sys_Float b) { return __self - b; }

sys_Int sys_Int_not__val(fr_Env __env, sys_Int_pass __self) { return ~__self; }

sys_Int sys_Int_and__val(fr_Env __env, sys_Int_pass __self, sys_Int b) { return __self & b; }

sys_Int sys_Int_or__val(fr_Env __env, sys_Int_pass __self, sys_Int b) { return __self | b; }

sys_Int sys_Int_xor__val(fr_Env __env, sys_Int_pass __self, sys_Int b) { return __self ^ b; }

sys_Int sys_Int_shiftl_val(fr_Env __env, sys_Int_pass __self, sys_Int b) { return __self << b; }

sys_Int sys_Int_shiftr_val(fr_Env __env, sys_Int_pass __self, sys_Int b) { return __self >> b; }

sys_Int sys_Int_shifta_val(fr_Env __env, sys_Int_pass __self, sys_Int b) { return ((uint64_t)__self) >> b; }

sys_Int sys_Int_pow_val(fr_Env __env, sys_Int_pass __self, sys_Int pow) {
    if (pow < 0) {
        sys_ArgErr e = FR_ALLOC(sys_ArgErr);
        FR_SET_ERROR(e); return 0;
    }
    return powf(__self, pow);
}

sys_Str sys_Int_toStr_val(fr_Env __env, sys_Int_pass __self) {
    char buf[256];
    snprintf(buf, 256, "%lld", __self);
    return (sys_Str)fr_newStrUtf8(__env, buf, -1);
}

sys_Str sys_Int_toHex_val(fr_Env __env, sys_Int_pass __self, sys_Int width) {
    char format[256];
    char buf[256];

    if (!width) {
        snprintf(buf, 256, "%llx", __self);
    }
    else {
        snprintf(format, 256, "%%0%lldllx", __self);
        snprintf(buf, 256, format, __self);
    }
    return (sys_Str)fr_newStrUtf8(__env, buf, -1);
}

sys_Str sys_Int_toRadix_val(fr_Env __env, sys_Int_pass __self, sys_Int radix, sys_Int width) {
    if (radix == 10) {
        char format[256];
        char buf[256];

        if (!width) {
            snprintf(buf, 256, "%lld", __self);
        }
        else {
            snprintf(format, 256, "%%0%lldlld", __self);
            snprintf(buf, 256, format, __self);
        }
        return (sys_Str)fr_newStrUtf8(__env, buf, -1);
    }
    else if (radix == 16) {
        return sys_Int_toHex_val(__env, __self, width);
    }
    FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return 0;
}

size_t utf8encode(wchar_t* us, char* des, size_t n, int* illegal);

sys_Str sys_Int_toChar_val(fr_Env __env, sys_Int_pass __self) {
    wchar_t buf[2] = { 0 };
    buf[0] = (wchar_t)__self;
    char out[16];
    size_t len = utf8encode(buf, out, 16, NULL);
    return (sys_Str)fr_newStrUtf8(__env, out, len);
}

sys_Str sys_Int_toCode_val(fr_Env __env, sys_Int_pass __self, sys_Int base) {
    if (base == 10) {
        char buf[256];
        snprintf(buf, 256, "%lld", __self);
        return (sys_Str)fr_newStrUtf8(__env, buf, -1);
    }
    else if (base == 16) {
        char buf[256];
        snprintf(buf, 256, "%llx", __self);
        return (sys_Str)fr_newStrUtf8(__env, buf, -1);
    }
    FR_SET_ERROR_MAKE(sys_UnsupportedErr, ""); return NULL;
}

sys_Float sys_Int_toFloat_val(fr_Env __env, sys_Int_pass __self) { return (double)__self; }


void sys_Int_static__init(fr_Env __env) {}

