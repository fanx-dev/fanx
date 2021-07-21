#include "fni_ext.h"
#include "pod_std_native.h"
#include "Vm.hpp"
#include "Env.hpp"

void std_PodList_doInit(fr_Env env, fr_Obj self) {
    Env *e = (Env*)env;
    Vm *vm = e->vm;
    
    fr_Type type = fr_findType(env, "std", "Pod");
    fr_Method method = fr_findMethod(env, type, "make");
    
    fr_Type ttype = fr_getObjType(env, self);
    fr_Method addMethod = fr_findMethod(env, ttype, "addPod");
    
    for (auto itr = vm->pods.begin(); itr != vm->pods.end(); ++itr) {
        struct fr_Pod_ *pod = itr->second;
        fr_Obj name = fr_newStrUtf8(env, pod->name);
        fr_Obj version = fr_newStrUtf8(env, pod->version);
        fr_Obj depends = fr_newStrUtf8(env, pod->depends);
        
        fr_Value vpod = fr_newObj(env, type, method, 3, name, version, depends);
        
        fr_callMethod(env, addMethod, 1, vpod);
    }
    return;
}
