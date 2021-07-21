#include "vm.h"
#include "pod_std_native.h"

void std_Env_make(fr_Env env, fr_Obj self) {
    return;
}
fr_Obj std_Env_platform(fr_Env env, fr_Obj self) {
    return 0;
}
fr_Obj std_Env_os(fr_Env env, fr_Obj self) {
    return 0;
}
fr_Obj std_Env_arch(fr_Env env, fr_Obj self) {
    return 0;
}
fr_Obj std_Env_runtime(fr_Env env, fr_Obj self) {
    return fr_newStrUtf8(env, "fanrun");
}
fr_Bool std_Env_isJs(fr_Env env, fr_Obj self) {
    return 0;
}
fr_Int std_Env_javaVersion(fr_Env env, fr_Obj self) {
    return 0;
}
fr_Int std_Env_idHash(fr_Env env, fr_Obj self, fr_Obj obj) {
    return 0;
}
fr_Obj std_Env_args(fr_Env env, fr_Obj self) {
    return 0;
}
fr_Obj std_Env_vars(fr_Env env, fr_Obj self) {
    return 0;
}
fr_Obj std_Env_diagnostics(fr_Env env, fr_Obj self) {
    return 0;
}
void std_Env_gc(fr_Env env, fr_Obj self) {
    return;
}
fr_Obj std_Env_host(fr_Env env, fr_Obj self) {
    return 0;
}
fr_Obj std_Env_user(fr_Env env, fr_Obj self) {
    return 0;
}
fr_Obj std_Env_in(fr_Env env, fr_Obj self) {
    return 0;
}
fr_Obj std_Env_out(fr_Env env, fr_Obj self) {
    return 0;
}
fr_Obj std_Env_err(fr_Env env, fr_Obj self) {
    return 0;
}
fr_Obj std_Env_promptPassword(fr_Env env, fr_Obj self, fr_Obj msg) {
    return 0;
}
fr_Obj std_Env_homeDir(fr_Env env, fr_Obj self) {
    return 0;
}
fr_Obj std_Env_workDir(fr_Env env, fr_Obj self) {
    return 0;
}
fr_Obj std_Env_tempDir(fr_Env env, fr_Obj self) {
    return 0;
}
fr_Obj std_Env_findFile(fr_Env env, fr_Obj self, fr_Obj uri, fr_Bool checked) {
    return 0;
}
fr_Obj std_Env_findAllFiles(fr_Env env, fr_Obj self, fr_Obj uri) {
    return 0;
}
fr_Obj std_Env_findPodFile(fr_Env env, fr_Obj self, fr_Obj podName) {
    return 0;
}
fr_Obj std_Env_findAllPodNames(fr_Env env, fr_Obj self) {
    return 0;
}
fr_Obj std_Env_compileScript(fr_Env env, fr_Obj self, fr_Obj f, fr_Obj options) {
    return 0;
}
fr_Obj std_Env_index(fr_Env env, fr_Obj self, fr_Obj key) {
    return 0;
}
fr_Obj std_Env_indexKeys(fr_Env env, fr_Obj self) {
    return 0;
}
fr_Obj std_Env_indexPodNames(fr_Env env, fr_Obj self, fr_Obj key) {
    return 0;
}
fr_Obj std_Env_props(fr_Env env, fr_Obj self, fr_Obj pod, fr_Obj uri, fr_Obj maxAge) {
    return 0;
}
fr_Obj std_Env_config(fr_Env env, fr_Obj self, fr_Obj pod, fr_Obj key, fr_Obj defV) {
    return 0;
}
fr_Obj std_Env_locale(fr_Env env, fr_Obj self, fr_Obj pod, fr_Obj key, fr_Obj defV, fr_Obj locale) {
    return 0;
}
void std_Env_exit(fr_Env env, fr_Obj self, fr_Int status) {
    return;
}
void std_Env_addShutdownHook(fr_Env env, fr_Obj self, fr_Obj hook) {
    return;
}
fr_Bool std_Env_removeShutdownHook(fr_Env env, fr_Obj self, fr_Obj hook) {
    return 0;
}
