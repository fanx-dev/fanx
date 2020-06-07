#include "vm.h"
#include "pod_sys_struct.h"
#include "pod_sys_native.h"

void sys_Ptr_make_f(fr_Env env, fr_Ptr self) {

}
fr_Ptr sys_Ptr_stackAlloc_f(fr_Env env, fr_Int size) {
  return 0;
}
fr_Obj sys_Ptr_load_f(fr_Env env, fr_Ptr self) {
  return 0;
}
void sys_Ptr_store_f(fr_Env env, fr_Ptr self, fr_Obj v) {
}
fr_Ptr sys_Ptr_plus_f(fr_Env env, fr_Ptr self, fr_Int b) {
  return self + b;
}
void sys_Ptr_set_f(fr_Env env, fr_Ptr self, fr_Int index, fr_Obj item) {
  //self[index] = fr_getPtr(env, item);
}
fr_Obj sys_Ptr_get_f(fr_Env env, fr_Ptr self, fr_Int index) {
  //return fr_toHandle(env, self[index]);
    return 0;
}
