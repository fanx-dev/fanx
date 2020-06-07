#include "vm.h"
#include "pod_sys_struct.h"
#include "pod_sys_native.h"
#include <math.h>
#include <wctype.h>
#include <stdlib.h>

fr_Int sys_Int_fromStr_f(fr_Env env, fr_Obj s, fr_Int radix, fr_Bool checked) {
    return 0;
}
fr_Int sys_Int_random_f(fr_Env env, fr_Obj r) {
    //TODO
    return rand();
}
void sys_Int_privateMake_f(fr_Env env, fr_Int self) {
    //return 0;
}
fr_Bool sys_Int_equals_f(fr_Env env, fr_Int self, fr_Obj obj) {
    fr_Type type;
    bool eq = false;
    
    if (obj == NULL) {
        return false;
    }
    type = fr_toType(env, fr_vtInt);
    
    if (!fr_isInstanceOf(env, obj, type)) {
        return false;
    }
    
    //fr_lock(env);
    struct sys_Int_ *other = (struct sys_Int_ *)fr_getPtr(env, obj);
    eq = self == other->value;
    //fr_unlock(env);
    return eq;
}
fr_Int sys_Int_compare_f(fr_Env env, fr_Int self, fr_Obj obj) {
    fr_Type type;
    fr_Int result;
    
    if (obj == NULL) {
        return 0;
    }
    type = fr_toType(env, fr_vtInt);
    
    if (!fr_isInstanceOf(env, obj, type)) {
        fr_throwNew(env, "sys", "CastErr", "can not compare with int");
        return 0;
    }
    
    //fr_lock(env);
    struct sys_Int_ *other = (struct sys_Int_ *)fr_getPtr(env, obj);
    result = self - other->value;
    //fr_unlock(env);
    return result;
}
fr_Int sys_Int_negate_f(fr_Env env, fr_Int self) {
    return -self;
}
fr_Int sys_Int_increment_f(fr_Env env, fr_Int self) {
    return ++self;
}
fr_Int sys_Int_decrement_f(fr_Env env, fr_Int self) {
    return --self;
}
fr_Int sys_Int_mult_f(fr_Env env, fr_Int self, fr_Int b) {
    return self * b;
}
fr_Float sys_Int_multFloat_f(fr_Env env, fr_Int self, fr_Float b) {
    return self * b;
}
fr_Int sys_Int_div_f(fr_Env env, fr_Int self, fr_Int b) {
    return self / b;
}
fr_Float sys_Int_divFloat_f(fr_Env env, fr_Int self, fr_Float b) {
    return self / b;
}
fr_Int sys_Int_mod_f(fr_Env env, fr_Int self, fr_Int b) {
    return self % b;
}
fr_Float sys_Int_modFloat_f(fr_Env env, fr_Int self, fr_Float b) {
    return self / b;
}
fr_Int sys_Int_plus_f(fr_Env env, fr_Int self, fr_Int b) {
    return self + b;
}
fr_Float sys_Int_plusFloat_f(fr_Env env, fr_Int self, fr_Float b) {
    return self + b;
}
fr_Int sys_Int_minus_f(fr_Env env, fr_Int self, fr_Int b) {
    return self - b;
}
fr_Float sys_Int_minusFloat_f(fr_Env env, fr_Int self, fr_Float b) {
    return self - b;
}
fr_Int sys_Int_not_f(fr_Env env, fr_Int self) {
    return ~self;
}
fr_Int sys_Int_and_f(fr_Env env, fr_Int self, fr_Int b) {
    return self & b;
}
fr_Int sys_Int_or_f(fr_Env env, fr_Int self, fr_Int b) {
    return self | b;
}
fr_Int sys_Int_xor_f(fr_Env env, fr_Int self, fr_Int b) {
    return self ^ b;
}
fr_Int sys_Int_shiftl_f(fr_Env env, fr_Int self, fr_Int b) {
    return self << b;
}
fr_Int sys_Int_shiftr_f(fr_Env env, fr_Int self, fr_Int b) {
    return self >> b;
}
//TODO
fr_Int sys_Int_shifta_f(fr_Env env, fr_Int self, fr_Int b) {
    return self >> b;
}
/*
fr_Int sys_Int_abs_f(fr_Env env, fr_Int self) {
    if (self < 0) {
        return -self;
    }
    return (self);
}
fr_Int sys_Int_min_f(fr_Env env, fr_Int self, fr_Int that) {
    if (self < that) {
        return self;
    }
    return that;
}
fr_Int sys_Int_max_f(fr_Env env, fr_Int self, fr_Int that) {
    if (self > that) {
        return self;
    }
    return that;
}
*/
fr_Int sys_Int_pow_f(fr_Env env, fr_Int self, fr_Int apow) {
    return powl(self, apow);
}
/*
fr_Bool sys_Int_isEven_f(fr_Env env, fr_Int self) {
    return (1 & self) == 0;
}
fr_Bool sys_Int_isOdd_f(fr_Env env, fr_Int self) {
    return (1 & self) != 0;
}
fr_Bool sys_Int_isSpace_f(fr_Env env, fr_Int self) {
    return iswspace((wchar_t)self);
}
fr_Bool sys_Int_isAlpha_f(fr_Env env, fr_Int self) {
    return iswalpha((wchar_t)self);
}
fr_Bool sys_Int_isAlphaNum_f(fr_Env env, fr_Int self) {
    return iswalnum((wchar_t)self);
}
fr_Bool sys_Int_isUpper_f(fr_Env env, fr_Int self) {
    return iswupper((wchar_t)self);
}
fr_Bool sys_Int_isLower_f(fr_Env env, fr_Int self) {
    return iswlower((wchar_t)self);
}
fr_Int sys_Int_upper_f(fr_Env env, fr_Int self) {
    return towupper((wchar_t)self);
}
fr_Int sys_Int_lower_f(fr_Env env, fr_Int self) {
    return towlower((wchar_t)self);
}
fr_Bool sys_Int_isDigit_f(fr_Env env, fr_Int self, fr_Int radix) {
    if (radix == 16) {
        return iswxdigit((wchar_t)self);
    }
    else if (radix == 10) {
        return iswdigit((wchar_t)self);
    }
    else {
        //TODO;
        return false;
    }
}

fr_Obj sys_Int_toDigit_f(fr_Env env, fr_Int self, fr_Int radix) {
    return 0;
}
fr_Obj sys_Int_fromDigit_f(fr_Env env, fr_Int self, fr_Int radix) {
    return 0;
}
fr_Bool sys_Int_equalsIgnoreCase_f(fr_Env env, fr_Int self, fr_Int ch) {
    return 0;
}
fr_Bool sys_Int_localeIsUpper_f(fr_Env env, fr_Int self) {
    return 0;
}
fr_Bool sys_Int_localeIsLower_f(fr_Env env, fr_Int self) {
    return 0;
}
fr_Int sys_Int_localeUpper_f(fr_Env env, fr_Int self) {
    return 0;
}
fr_Int sys_Int_localeLower_f(fr_Env env, fr_Int self) {
    return 0;
}*/
fr_Obj sys_Int_toStr_f(fr_Env env, fr_Int self) {
    char buf[128];
    buf[0] = 0;
    fr_Obj str;
    
    snprintf(buf, 128, "%lld", self);
    str = fr_newStrUtf8(env, buf);
    return str;
}
fr_Obj sys_Int_toHex_f(fr_Env env, fr_Int self, fr_Int width) {
    return 0;
}
fr_Obj sys_Int_toRadix_f(fr_Env env, fr_Int self, fr_Int radix, fr_Int width) {
    return 0;
}
fr_Obj sys_Int_toChar_f(fr_Env env, fr_Int self) {
    return 0;
}
fr_Obj sys_Int_toCode_f(fr_Env env, fr_Int self, fr_Int base) {
    return 0;
}
fr_Float sys_Int_toFloat_f(fr_Env env, fr_Int self) { return self; }

void sys_Int_make_f(fr_Env env, fr_Int self) {
    return;
}
void sys_Int_static__init_f(fr_Env env) {
    fr_Value val;
    //val.type = fr_vtInt;
    val.i = 0;
    fr_setStaticFieldS(env, "sys", "Int", "defVal", &val);
    val.i = INT64_MAX;
    fr_setStaticFieldS(env, "sys", "Int", "maxVal", &val);
    val.i = INT64_MIN;
    fr_setStaticFieldS(env, "sys", "Int", "minVal", &val);
    return;
}
