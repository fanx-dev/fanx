#include "fni_ext.h"
#include "pod_std_native.h"
#if FR_VM
#include <string>
#include "Env.h"
#else
#include "Vm.hpp"
#include "Env.hpp"
#endif

//void std_PodList_doInit(fr_Env env, fr_Obj self) {}

#ifndef FR_VM
fr_Obj std_PodList_makePod(fr_Env env, fr_Obj aname) {
    Env *e = (Env*)env;
    Vm *vm = e->vm;

    const char* cname = fr_getStrUtf8(env, aname);

    auto itr = vm->pods.find(cname);
    if (itr == vm->pods.end()) {
        return NULL;
    }

    struct fr_Pod_* pod = itr->second;
    fr_Obj name = fr_newStrUtf8(env, pod->name);
    fr_Obj version = fr_newStrUtf8(env, pod->version);
    fr_Obj depends = fr_newStrUtf8(env, pod->depends);

    fr_Obj vpod = fr_newObjS(env, "std", "Pod", "make", 3, name, version, depends);
    return vpod;
}
#endif