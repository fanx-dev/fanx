#include "vm.h"
#include "pod_sys_struct.h"
#include "pod_sys_native.h"

//#include "FType.h"

fr_Int sys_NativeC_toId(fr_Env env, fr_Obj self) {
    return (fr_Int)self;
}
fr_Obj sys_NativeC_typeName(fr_Env env, fr_Obj self) {
    const char *name = fr_getTypeName(env, fr_getPtr(env, self));
    return fr_newStrUtf8(env, name, -1);
}
void sys_NativeC_print(fr_Env env, fr_Obj utf8) {
    fr_Array *a;
    a = (fr_Array *)fr_getPtr(env, utf8);
    puts((const char*)a->data);
}
void sys_NativeC_printErr(fr_Env env, fr_Obj utf8) {
    fr_Array *a;
    a = (fr_Array *)fr_getPtr(env, utf8);
    fprintf( stderr, "%s\n", (const char*)a->data);
}
fr_Obj sys_NativeC_stackTrace(fr_Env env) {
    return fr_newStrUtf8(env, "TODO", -1);
}
fr_Obj sys_Str_format(fr_Env env, fr_Obj format, fr_Obj args) {
    return 0;
}
