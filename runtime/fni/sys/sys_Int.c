#include "fni_ext.h"
//#include "pod_sys_struct.h"
#include "pod_sys_native.h"
#include <math.h>
#include <wctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <wchar.h>
#include <string.h>
#include "util/utf8.h"

fr_Int sys_Int_fromStr(fr_Env env, fr_Obj s, fr_Int radix, fr_Bool checked) {
    const char *str = fr_getStrUtf8(env, s);
    char *pos = NULL;
    fr_Int val = strtoll(str, &pos, (int)radix);
    
    if (checked && ((pos-str) != strlen(str)) ) {
        char buf[128];
        snprintf(buf, 128, "Invalid Int: %s", str);
        fr_throwNew(env, "sys", "ParseErr", buf);
    }
    return val;
}
fr_Int sys_Int_randomNext(fr_Env env) {
    return rand();
}
void sys_Int_privateMake_val(fr_Env env, fr_Int self) {
    //return 0;
}
fr_Bool sys_Int_equals_val(fr_Env env, fr_Int self, fr_Obj obj) {
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
    fr_Int *other = (fr_Int *)fr_getPtr(env, obj);
    eq = self == *other;
    //fr_unlock(env);
    return eq;
}
fr_Int sys_Int_compare_val(fr_Env env, fr_Int self, fr_Obj obj) {
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
    fr_Int *other = (fr_Int *)fr_getPtr(env, obj);
    result = self - *other;
    //fr_unlock(env);
    return result;
}
fr_Int sys_Int_negate_val(fr_Env env, fr_Int self) {
    return -self;
}
fr_Int sys_Int_increment_val(fr_Env env, fr_Int self) {
    return ++self;
}
fr_Int sys_Int_decrement_val(fr_Env env, fr_Int self) {
    return --self;
}
fr_Int sys_Int_mult_val(fr_Env env, fr_Int self, fr_Int b) {
    return self * b;
}
fr_Float sys_Int_multFloat_val(fr_Env env, fr_Int self, fr_Float b) {
    return self * b;
}
fr_Int sys_Int_div_val(fr_Env env, fr_Int self, fr_Int b) {
    return self / b;
}
fr_Float sys_Int_divFloat_val(fr_Env env, fr_Int self, fr_Float b) {
    return self / b;
}
fr_Int sys_Int_mod_val(fr_Env env, fr_Int self, fr_Int b) {
    return self % b;
}
fr_Float sys_Int_modFloat_val(fr_Env env, fr_Int self, fr_Float b) {
    return self / b;
}
fr_Int sys_Int_plus_val(fr_Env env, fr_Int self, fr_Int b) {
    return self + b;
}
fr_Float sys_Int_plusFloat_val(fr_Env env, fr_Int self, fr_Float b) {
    return self + b;
}
fr_Int sys_Int_minus_val(fr_Env env, fr_Int self, fr_Int b) {
    return self - b;
}
fr_Float sys_Int_minusFloat_val(fr_Env env, fr_Int self, fr_Float b) {
    return self - b;
}
fr_Int sys_Int_not__val(fr_Env env, fr_Int self) {
    return ~self;
}
fr_Int sys_Int_and__val(fr_Env env, fr_Int self, fr_Int b) {
    return self & b;
}
fr_Int sys_Int_or__val(fr_Env env, fr_Int self, fr_Int b) {
    return self | b;
}
fr_Int sys_Int_xor__val(fr_Env env, fr_Int self, fr_Int b) {
    return self ^ b;
}
fr_Int sys_Int_shiftl_val(fr_Env env, fr_Int self, fr_Int b) {
    return self << b;
}
fr_Int sys_Int_shiftr_val(fr_Env env, fr_Int self, fr_Int b) {
    return ((uint64_t)self) >> b;
}

fr_Int sys_Int_shifta_val(fr_Env env, fr_Int self, fr_Int b) {
    return self >> b;
}

fr_Int sys_Int_pow_val(fr_Env env, fr_Int self, fr_Int apow) {
    return powl(self, apow);
}

fr_Obj sys_Int_toStr_val(fr_Env env, fr_Int self) {
    char buf[128];
    buf[0] = 0;
    fr_Obj str;
    
    snprintf(buf, 128, "%lld", self);
    str = fr_newStrUtf8(env, buf);
    return str;
}
fr_Obj sys_Int_toHex_val(fr_Env env, fr_Int self, fr_Int width) {
    char buf[128];
    buf[0] = 0;
    fr_Obj str;
    
    snprintf(buf, 128, "%0*x", (int)width, (int)self);
    str = fr_newStrUtf8(env, buf);
    return str;
}
fr_Obj sys_Int_toRadix_val(fr_Env env, fr_Int self, fr_Int radix, fr_Int width) {
    char buf[128];
    buf[0] = 0;
    fr_Obj str;
    switch (radix) {
        case 16:
            snprintf(buf, 128, "%0*x", (int)width, (int)self);
            break;
        case 10:
            snprintf(buf, 128, "%0*d", (int)width, (int)self);
            break;
        case 8:
            snprintf(buf, 128, "%0*o", (int)width, (int)self);
            break;
        case 2:
            //TODO
            abort();
            break;
    }
    str = fr_newStrUtf8(env, buf);
    return str;
}
fr_Obj sys_Int_toChar_val(fr_Env env, fr_Int self) {
    char buf[128];
    buf[0] = 0;
    fr_Obj str;
    if (self < 0) {
        char buf2[128];
        snprintf(buf2, 128, "Invalid unicode char: %d", (int)self);
        fr_throwNew(env, "sys", "Err", buf2);
        return NULL;
    }
    else if (self < 128) {
        snprintf(buf, 128, "%c", (int)self);
    }
    else {
        wchar_t w[2];
        w[0] = (wchar_t)self;
        w[1] = 0;
        utf8encode(w, buf, 128, NULL);
    }
    str = fr_newStrUtf8(env, buf);
    return str;
}
fr_Obj sys_Int_toCode_val(fr_Env env, fr_Int self, fr_Int base) {
    if (base == 10) return sys_Int_toStr_val(env, self);
    if (base == 16) {
        char buf[128];
        buf[0] = 0;
        fr_Obj str;
        //TODO unicode
        snprintf(buf, 128, "%#x", (int)self);
        str = fr_newStrUtf8(env, buf);
        return str;
    }
    char buf[128];
    snprintf(buf, 128, "Invalid base %d", (int)base);
    fr_throwNew(env, "sys", "ArgErr", buf);
    return 0;
}
fr_Float sys_Int_toFloat_val(fr_Env env, fr_Int self) { return self; }

void sys_Int_make_val(fr_Env env, fr_Int self) {
    return;
}
