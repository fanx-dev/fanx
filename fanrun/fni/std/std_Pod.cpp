#include "vm.h"
#include "pod_std_native.h"
#include "Vm.hpp"
#include "ThreadEnv.hpp"

void std_Pod_doInit(fr_Env env, fr_Obj self) {
    Env *e = (Env*)env;
    Vm *vm = e->vm;
    
    //get pod name
    fr_Type podType = fr_getObjType(env, self);
    fr_Field field = fr_findField(env, podType, "_name");
    fr_Value args[2];
    args[0].h = self;
    fr_getInstanceField(env, args, field, args+1);
    std::string podName = fr_getStrUtf8(env, args[1].h);
    Vm::ClassMap &classList = vm->typeDb[podName];
    
    fr_Type baseType = fr_findType(env, "std", "BaseType");
    fr_Method makeMethod = fr_findMethod(env, baseType, "privateMake");
    
    fr_Method addMethod = fr_findMethod(env, podType, "addType");
    
    for (auto itr = classList.begin(); itr != classList.end(); ++itr) {
        fr_Value args2[7];
        args2[0].h = self;
        args2[1].h = fr_newStrUtf8(env, itr->second->name);
        args2[2].h = fr_newStrUtf8(env, itr->second->name);//signature
        args2[3].i = itr->second->flags;
        
        if (itr->second->base) {
            args2[4].h = fr_newStrUtf8(env, itr->second->base->name);//baseName
        }
        else {
            args2[4].h = NULL;
        }
        std::string mixinsName;
        for (int i=0; itr->second->mixinCount; ++i) {
            if (i == 0) {
                mixinsName += itr->second->base[i+1].name;
            }
            else {
                mixinsName += std::string("/") + itr->second->base[i+1].name;
            }
        }
        args2[5].h = fr_newStrUtf8(env, mixinsName.c_str());
        fr_newObjA(env, baseType, makeMethod, 6, args2, args2+6);
        
        fr_callMethod(env, addMethod, 2, self, args2[6].o);
    }
    return;
}
fr_Obj std_Pod_load(fr_Env env, fr_Obj in) {
    return 0;
}
fr_Obj std_Pod_files(fr_Env env, fr_Obj self) {
    return 0;
}
fr_Obj std_Pod_file(fr_Env env, fr_Obj self, fr_Obj uri, fr_Bool checked) {
    return 0;
}
