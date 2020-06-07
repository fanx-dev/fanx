#include "sys.h"
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>

sys_Int sys_Int_defVal = 0;
sys_Int sys_Int_maxVal = INT64_MAX;
sys_Int sys_Int_minVal = INT64_MIN;



fr_Err sys_Int_fromStr(fr_Env __env, sys_Int *__ret, sys_Str s, sys_Int radix, sys_Bool checked){
    char *str_end;
    const char *str = (const char*)s->utf8->data;
    sys_Int res = strtoll(str, &str_end, (int)radix);
    if (checked && str_end == str) {
        sys_ParseErr e = FR_ALLOC(sys_ParseErr);
        return e;
    }
    *__ret = res;
    return NULL;
}
fr_Err sys_Int_random(fr_Env __env, sys_Int *__ret, sys_Range_null r){
    if (r == NULL) {
        sys_Int t = rand();
        sys_Int p = rand();
        sys_Int res = t | (p<<32);
        *__ret =  res;
    }
    else {
        sys_Int res = rand();
        sys_Int size = r->_end - r->_start;
        res = r->_start + (res % size);
        *__ret =  res;
    }
    return NULL;
}
fr_Err sys_Int_privateMake_val(fr_Env __env, sys_Int_val __self){ return 0; }
fr_Err sys_Int_equals_val(fr_Env __env, sys_Bool *__ret, sys_Int_val __self, sys_Obj_null obj){
    if (!obj) *__ret = false;
    if (FR_TYPE_IS(obj, sys_Int)) {
        sys_Int_ref other = (sys_Int_ref)obj;
        *__ret = __self == other->_val;
    }
    *__ret = false;
    return NULL;
}
fr_Err sys_Int_compare_val(fr_Env __env, sys_Int *__ret, sys_Int_val __self, sys_Obj obj){
    if (!obj) FR_RET_THROW_NPE();
    if (FR_TYPE_IS(obj, sys_Int)) {
        sys_Int_ref other = (sys_Int_ref)obj;
        *__ret =  __self - other->_val;
    }
    else {
        sys_Int other = (sys_Int)obj;
        *__ret =  __self - other;
    }
    return NULL;
}
fr_Err sys_Int_negate_val(fr_Env __env, sys_Int *__ret, sys_Int_val __self){
    *__ret = -__self;
    return NULL;
}
fr_Err sys_Int_increment_val(fr_Env __env, sys_Int *__ret, sys_Int_val __self){
    *__ret = ++__self;
    return NULL;
}
fr_Err sys_Int_decrement_val(fr_Env __env, sys_Int *__ret, sys_Int_val __self){
    *__ret = --__self;
    return NULL;
}
fr_Err sys_Int_mult_val(fr_Env __env, sys_Int *__ret, sys_Int_val __self, sys_Int b){
    *__ret = __self * b;
    return NULL;
}
fr_Err sys_Int_multFloat_val(fr_Env __env, sys_Float *__ret, sys_Int_val __self, sys_Float b){
    *__ret = __self * b;
    return NULL;
}
fr_Err sys_Int_div_val(fr_Env __env, sys_Int *__ret, sys_Int_val __self, sys_Int b){
    *__ret = __self / b;
    return NULL;
}
fr_Err sys_Int_divFloat_val(fr_Env __env, sys_Float *__ret, sys_Int_val __self, sys_Float b){
    *__ret = __self / b;
    return NULL;
}
fr_Err sys_Int_mod_val(fr_Env __env, sys_Int *__ret, sys_Int_val __self, sys_Int b){
    *__ret = __self % b;
    return NULL;
}
fr_Err sys_Int_modFloat_val(fr_Env __env, sys_Float *__ret, sys_Int_val __self, sys_Float b){
    *__ret = fmod(__self, b);
    return NULL;
}
fr_Err sys_Int_plus_val(fr_Env __env, sys_Int *__ret, sys_Int_val __self, sys_Int b){
    *__ret = __self + b;
    return NULL;
}
fr_Err sys_Int_plusFloat_val(fr_Env __env, sys_Float *__ret, sys_Int_val __self, sys_Float b){
    *__ret = __self + b;
    return NULL;
}
fr_Err sys_Int_minus_val(fr_Env __env, sys_Int *__ret, sys_Int_val __self, sys_Int b){
    *__ret = __self - b;
    return NULL;
}
fr_Err sys_Int_minusFloat_val(fr_Env __env, sys_Float *__ret, sys_Int_val __self, sys_Float b){
    *__ret = __self - b;
    return NULL;
}
fr_Err sys_Int_not__val(fr_Env __env, sys_Int *__ret, sys_Int_val __self){
    *__ret = ~__self;
    return NULL;
}
fr_Err sys_Int_and__val(fr_Env __env, sys_Int *__ret, sys_Int_val __self, sys_Int b){
    *__ret = __self & b;
    return NULL;
}
fr_Err sys_Int_or__val(fr_Env __env, sys_Int *__ret, sys_Int_val __self, sys_Int b){
    *__ret = __self | b;
    return NULL;
}
fr_Err sys_Int_xor__val(fr_Env __env, sys_Int *__ret, sys_Int_val __self, sys_Int b){
    *__ret = __self ^ b;
    return NULL;
}
fr_Err sys_Int_shiftl_val(fr_Env __env, sys_Int *__ret, sys_Int_val __self, sys_Int b){
    *__ret = __self << b;
    return NULL;
}
fr_Err sys_Int_shiftr_val(fr_Env __env, sys_Int *__ret, sys_Int_val __self, sys_Int b){
    *__ret = __self >> b;
    return NULL;
}
fr_Err sys_Int_shifta_val(fr_Env __env, sys_Int *__ret, sys_Int_val __self, sys_Int b){
    *__ret = ((uint64_t)__self) >> b;
    return NULL;
}
fr_Err sys_Int_pow_val(fr_Env __env, sys_Int *__ret, sys_Int_val __self, sys_Int pow){
    if (pow < 0) {
        sys_ArgErr e = FR_ALLOC(sys_ArgErr);
        FR_RET_THROW(e);
    }
    *__ret = powf(__self, pow);
    return NULL;
}
fr_Err sys_Int_toStr_val(fr_Env __env, sys_Str *__ret, sys_Int_val __self){
    char buf[256];
    snprintf(buf, 256, "%lld", __self);
    *__ret = (sys_Str)fr_newStrUtf8(__env, buf, -1);
    return NULL;
}
fr_Err sys_Int_toHex_val(fr_Env __env, sys_Str *__ret, sys_Int_val __self, sys_Int width){
    char format[256];
    char buf[256];
    
    if (!width) {
        snprintf(buf, 256, "%llx", __self);
    } else {
        snprintf(format, 256, "%%0%lldllx", __self);
        snprintf(buf, 256, format, __self);
    }
    *__ret =  (sys_Str)fr_newStrUtf8(__env, buf, -1);
    return NULL;
}
fr_Err sys_Int_toRadix_val(fr_Env __env, sys_Str *__ret, sys_Int_val __self, sys_Int radix, sys_Int width){
    if (radix == 10) {
        char format[256];
        char buf[256];
        
        if (!width) {
            snprintf(buf, 256, "%lld", __self);
        } else {
            snprintf(format, 256, "%%0%lldlld", __self);
            snprintf(buf, 256, format, __self);
        }
        *__ret = (sys_Str)fr_newStrUtf8(__env, buf, -1);
    }
    else if (radix == 16) {
        return sys_Int_toHex_val(__env, __ret, __self, width);
    }
    FR_RET_ALLOC_THROW(sys_UnsupportedErr);
    *__ret = NULL;
    return NULL;
}

size_t utf8encode(wchar_t *us, char *des, size_t n, int *illegal);
fr_Err sys_Int_toChar_val(fr_Env __env, sys_Str *__ret, sys_Int_val __self){
    wchar_t buf[2] = {0};
    buf[0] = (wchar_t)__self;
    char out[16];
    size_t len = utf8encode(buf, out, 16, NULL);
    *__ret = (sys_Str)fr_newStrUtf8(__env, out, len);
    return NULL;
}
fr_Err sys_Int_toCode_val(fr_Env __env, sys_Str *__ret, sys_Int_val __self, sys_Int base){
    if (base == 10) {
        char buf[256];
        snprintf(buf, 256, "%lld", __self);
        *__ret = (sys_Str)fr_newStrUtf8(__env, buf, -1);
    }
    else if (base == 16) {
        char buf[256];
        snprintf(buf, 256, "%llx", __self);
        *__ret = (sys_Str)fr_newStrUtf8(__env, buf, -1);
    }
    FR_RET_ALLOC_THROW(sys_UnsupportedErr);
    *__ret = NULL;
    return NULL;
}
fr_Err sys_Int_toFloat_val(fr_Env __env, sys_Float *__ret, sys_Int_val __self){
    *__ret = (double)__self;
    return NULL;
}

fr_Err sys_Int_static__init(fr_Env __env) { return 0; }

