#include "fni_ext.h"
#include "pod_std_native.h"
#if FR_VM
#include <string>
#include "Env.h"
#else
#include "Vm.hpp"
#include "Env.hpp"
#endif


#if FR_VM

void std_PodList_doInit(fr_Env env, fr_Obj self) {
    /*Env* e = (Env*)env;
    fr_Type type = fr_findType(env, "std", "Pod");
    fr_Method method = fr_findMethod(env, type, "make");

    fr_Type ttype = fr_getObjType(env, self);
    fr_Method addMethod = fr_findMethod(env, ttype, "addPod");

    for (auto itr = e->podManager->podLoader.allPods().begin(); itr != e->podManager->podLoader.allPods().end(); ++itr) {
        FPod* pod = itr->second;
        fr_Obj name = fr_newStrUtf8(env, pod->name.c_str());
        fr_Obj version = fr_newStrUtf8(env, pod->version.c_str());
        fr_Obj depends = fr_newStrUtf8(env, pod->depends.c_str());

        fr_Value vpod = fr_newObj(env, type, method, 3, name, version, depends);

        fr_callMethod(env, addMethod, 1, vpod);
    }*/
}

#else
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
#endif