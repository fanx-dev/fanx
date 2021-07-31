#include "fni_ext.h"
#include "pod_std_native.h"
//#include "Vm.hpp"
//#include "Env.hpp"
#include <string>

void std_BaseType_doInit(fr_Env env, fr_Obj self) {
    //Env *e = (Env*)env;
    
    fr_Type typeType = fr_getObjType(env, self);
    fr_Field field = fr_findField(env, typeType, "_qname");
    fr_Value args[2];
    args[0].h = self;
    fr_getInstanceField(env, args, field, args+1);
    std::string qname = fr_getStrUtf8(env, args[1].h);
    std::string::size_type p = qname.find("::");
    if (p == std::string::npos) abort();
    std::string podName = qname.substr(0, p);
    std::string typeName = qname.substr(p+2);
    
    fr_Type ftype = fr_findType(env, podName.c_str(), typeName.c_str());
    
    fr_Method addMethod = fr_findMethod(env, typeType, "addSlot");
    
    fr_Type methodType = fr_findType(env, "std", "Method");
    fr_Method methodMake = fr_findMethod(env, methodType, "privateMake");
    fr_Method addParam = fr_findMethod(env, methodType, "addParam");
    
    fr_Type fieldType = fr_findType(env, "std", "Field");
    fr_Method fieldMake =  fr_findMethod(env, fieldType, "privateMake");
    
    for (int i=0; i<ftype->methodCount; ++i) {
        fr_Method m = ftype->methodList+i;
        
        fr_Value om = fr_newObj(env, methodType, methodMake, 6, self, fr_newStrUtf8(env, m->name), NULL, m->flags,
                  fr_newStrUtf8(env, m->retType), (fr_Int)m);
        
        for (int j=0; j<m->paramsCount; ++j) {
            fr_MethodParam_ *p = m->paramsList+j;
            fr_callMethod(env, addParam, 4, om, fr_newStrUtf8(env, p->name),
                          fr_newStrUtf8(env, p->type), p->flags);
        }
        fr_callMethod(env, addMethod, 2, self, om.h);
    }
    
    for (int i=0; i<ftype->fieldCount; ++i) {
        fr_Field m = ftype->fieldList+i;
        
        fr_Value om = fr_newObj(env, fieldType, fieldMake, 6, self, fr_newStrUtf8(env, m->name), NULL, m->flags,
                  fr_newStrUtf8(env, m->type), (fr_Int)m);
        
        fr_callMethod(env, addMethod, 2, self, om.h);
    }
}
