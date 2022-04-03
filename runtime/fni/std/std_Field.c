#include "fni_ext.h"
#include "pod_std_native.h"
//#include "type.h"

bool isBuildValueType(const char *name, fr_ValueType *vt);

fr_Obj std_Field_getDirectly(fr_Env env, fr_Obj self, fr_Obj instance) {
    fr_Type type = fr_getObjType(env, self);
    fr_Field field = fr_findField(env, type, "_id");
    fr_Value fargs[2];
    fr_getInstanceField(env, self, field, fargs+1);
    fr_Field m = (fr_Field)fargs[1].i;
    
    if ((m->flags & FFlags_Static) == 0) {
        fr_Value args[2];
        fr_getInstanceField(env, instance, m, args+1);
        
        
        fr_ValueType vt;
        if (m->isValType &&isBuildValueType(m->type, &vt)) {
            args[1].h = fr_box(env, args+1, vt);
        }
        return args[1].h;
    }
    else {
        fr_Value ret;
        fr_getStaticField(env, m, &ret);
        
        fr_ValueType vt;
        if (m->isValType &&isBuildValueType(m->type, &vt)) {
            ret.h = fr_box(env, &ret, vt);
        }
        return ret.h;
    }
}

void std_Field_setDirectly(fr_Env env, fr_Obj self, fr_Obj instance, fr_Obj value) {
    fr_Type type = fr_getObjType(env, self);
    fr_Field field = fr_findField(env, type, "_id");
    fr_Value fargs[2];
    fr_getInstanceField(env, self, field, fargs+1);
    fr_Field m = (fr_Field)fargs[1].i;
    
    fr_Value args;
    
    if (m->isValType && isBuildValueType(m->type, NULL)) {
        fr_unbox(env, value, &args);
    }
    else {
        args.h = value;
    }
    
    fr_setInstanceField(env, instance, m, &args);
}
