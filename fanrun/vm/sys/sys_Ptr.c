#include "vm.h"
#include "pod_sys_struct.h"
#include "pod_sys_native.h"

void sys_Ptr_make(fr_Env env, fr_Ptr self) {

}
fr_Ptr sys_Ptr_stackAlloc(fr_Env env, fr_Int size) {
  return 0;
}
fr_Obj sys_Ptr_load(fr_Env env, fr_Ptr self) {
  return 0;
}
void sys_Ptr_store(fr_Env env, fr_Ptr self, fr_Obj v) {
}
fr_Ptr sys_Ptr_plus(fr_Env env, fr_Ptr self, fr_Int b) {
  return self + b;
}
void sys_Ptr_set(fr_Env env, fr_Ptr self, fr_Int index, fr_Obj item) {
  //self[index] = fr_getPtr(env, item);
}
fr_Obj sys_Ptr_get(fr_Env env, fr_Ptr self, fr_Int index) {
  //return fr_toHandle(env, self[index]);
    return 0;
}
