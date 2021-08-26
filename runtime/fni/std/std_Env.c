#include "fni_ext.h"
#include "pod_std_native.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#ifdef _WIN64
#include <Windows.h>
#else
#include <unistd.h>
#include <sys/utsname.h>
#endif

CF_BEGIN

extern fr_Obj fr_argsArray;
extern const char* fr_homeDir;
extern const char* fr_envPaths[];
extern char** environ;
void fr_onExit();

CF_END


void std_Env_init(fr_Env env, fr_Obj self) {
    atexit(fr_onExit);
    return;
}

fr_Obj std_Env_os(fr_Env env, fr_Obj self) {
#ifdef _WIN64
    return fr_newStrUtf8(env, "windows");
#elif __APPLE__
    return fr_newStrUtf8(env, "macosx");
#else
    return fr_newStrUtf8(env, "linux");
#endif
}

static const char* getBuild() { //Get current architecture, detectx nearly every architecture. Coded by Freak
#if defined(__x86_64__) || defined(_M_X64)
    return "x86_64";
#elif defined(i386) || defined(__i386__) || defined(__i386) || defined(_M_IX86)
    return "x86_32";
#elif defined(__ARM_ARCH_2__)
    return "ARM2";
#elif defined(__ARM_ARCH_3__) || defined(__ARM_ARCH_3M__)
    return "ARM3";
#elif defined(__ARM_ARCH_4T__) || defined(__TARGET_ARM_4T)
    return "ARM4T";
#elif defined(__ARM_ARCH_5_) || defined(__ARM_ARCH_5E_)
    return "ARM5"
#elif defined(__ARM_ARCH_6T2_) || defined(__ARM_ARCH_6T2_)
    return "ARM6T2";
#elif defined(__ARM_ARCH_6__) || defined(__ARM_ARCH_6J__) || defined(__ARM_ARCH_6K__) || defined(__ARM_ARCH_6Z__) || defined(__ARM_ARCH_6ZK__)
    return "ARM6";
#elif defined(__ARM_ARCH_7__) || defined(__ARM_ARCH_7A__) || defined(__ARM_ARCH_7R__) || defined(__ARM_ARCH_7M__) || defined(__ARM_ARCH_7S__)
    return "ARM7";
#elif defined(__ARM_ARCH_7A__) || defined(__ARM_ARCH_7R__) || defined(__ARM_ARCH_7M__) || defined(__ARM_ARCH_7S__)
    return "ARM7A";
#elif defined(__ARM_ARCH_7R__) || defined(__ARM_ARCH_7M__) || defined(__ARM_ARCH_7S__)
    return "ARM7R";
#elif defined(__ARM_ARCH_7M__)
    return "ARM7M";
#elif defined(__ARM_ARCH_7S__)
    return "ARM7S";
#elif defined(__aarch64__) || defined(_M_ARM64)
    return "ARM64";
#elif defined(mips) || defined(__mips__) || defined(__mips)
    return "MIPS";
#elif defined(__sh__)
    return "SUPERH";
#elif defined(__powerpc) || defined(__powerpc__) || defined(__powerpc64__) || defined(__POWERPC__) || defined(__ppc__) || defined(__PPC__) || defined(_ARCH_PPC)
    return "POWERPC";
#elif defined(__PPC64__) || defined(__ppc64__) || defined(_ARCH_PPC64)
    return "POWERPC64";
#elif defined(__sparc__) || defined(__sparc)
    return "SPARC";
#elif defined(__m68k__)
    return "M68K";
#else
    return "UNKNOWN";
#endif
}

fr_Obj std_Env_arch(fr_Env env, fr_Obj self) {
    const char* arch = getBuild();
    return fr_newStrUtf8(env, arch);
}

fr_Obj std_Env_runtime(fr_Env env, fr_Obj self) {
#if FR_VM
    return fr_newStrUtf8(env, "fr_vm");
#else
    return fr_newStrUtf8(env, "fr_gen");
#endif
}
fr_Bool std_Env_isJs(fr_Env env, fr_Obj self) {
    return false;
}
fr_Int std_Env_javaVersion(fr_Env env, fr_Obj self) {
    return 0;
}
fr_Obj std_Env_args(fr_Env env, fr_Obj self) {
    return fr_argsArray;
}
fr_Obj std_Env_vars(fr_Env env, fr_Obj self) {
    
    fr_Obj list = fr_newObjS(env, "std", "CaseInsensitiveMap", "make", 1, (fr_Int)64);
    for (int i = 0; environ[i] != NULL; ++i) {
        const char* cstr = environ[i];
        const char* p = strchr(cstr, '=');
        if (p == NULL) continue;
        int len = p - cstr;

        char buf[1024] = { 0 };
        strncpy(buf, cstr, len);
        fr_Obj key = fr_newStrUtf8(env, buf);

        strncpy(buf, p+1, 1024);
        fr_Obj val = fr_newStrUtf8(env, buf);

        fr_callOnObj(env, list, "set", 2, key, val);
    }
    return list;
}
fr_Obj std_Env_diagnostics(fr_Env env, fr_Obj self) {
    return 0;
}
void std_Env_gc(fr_Env env, fr_Obj self) {
    fr_gc(env);
}
fr_Obj std_Env_host(fr_Env env, fr_Obj self) {
#ifdef _WIN64
    char strBuffer[512] = { 0 };
    DWORD dwSize = 512;
    GetComputerNameA(strBuffer, &dwSize);
    return fr_newStrUtf8(env, strBuffer);
#else
    char buf[128];
    gethostname(buf, 128);
    return fr_newStrUtf8(env, buf);
#endif
}
fr_Obj std_Env_user(fr_Env env, fr_Obj self) {
#ifdef _WIN64
    char strBuffer[512] = { 0 };
    DWORD dwSize = 512;
    GetUserNameA(strBuffer, &dwSize);
    return fr_newStrUtf8(env, strBuffer);
#else
    struct utsname uts;
    uname(&uts);
    char* n = uts.nodename;
    return fr_newStrUtf8(env, n);
#endif
}

void std_SysOutStream_setNativePeer(fr_Env env, fr_Obj obj, FILE* file);
void std_SysInStream_setNativePeer(fr_Env env, fr_Obj obj, FILE* file);

fr_Obj std_Env_in(fr_Env env, fr_Obj self) {
    static fr_Obj sout = NULL;
    if (sout == NULL) {
        fr_Obj out = fr_newObjS(env, "std", "SysInStream", "make", 0);
        std_SysInStream_setNativePeer(env, out, stdin);
        sout = out;
    }
    return sout;
}
fr_Obj std_Env_out(fr_Env env, fr_Obj self) {
    static fr_Obj sout = NULL;
    if (sout == NULL) {
        fr_Obj out = fr_newObjS(env, "std", "SysOutStream", "make", 0);
        std_SysOutStream_setNativePeer(env, out, stdout);
        sout = out;
    }
    return sout;
}
fr_Obj std_Env_err(fr_Env env, fr_Obj self) {
    static fr_Obj sout = NULL;
    if (sout == NULL) {
        fr_Obj out = fr_newObjS(env, "std", "SysOutStream", "make", 0);
        std_SysOutStream_setNativePeer(env, out, stderr);
        sout = out;
    }
    return sout;
}
fr_Obj std_Env_promptPassword(fr_Env env, fr_Obj self, fr_Obj msg) {
    char buf[256];
    printf("%s\n", fr_getStrUtf8(env, msg));
    
#if (__STDC_VERSION__ >= 201101L)
    const char *str = gets_s(buf, 256);
#else
    const char *str = gets(buf);
#endif
    return fr_newStrUtf8(env, str);
}
fr_Obj std_Env_homeDirPath(fr_Env env, fr_Obj self) {
    return fr_newStrUtf8(env, fr_homeDir);
}
fr_Obj std_Env_getEnvPaths(fr_Env env, fr_Obj self) {
    fr_Obj list = fr_arrayNew(env, fr_findType(env, "sys", "Str"), sizeof(fr_Obj), 64);
    for (int i = 0; fr_envPaths[i] != NULL; ++i) {
        const char* cstr = fr_envPaths[i];
        fr_Obj str = fr_newStrUtf8(env, cstr);
        fr_Value val;
        val.h = str;
        fr_arraySet(env, list, i, &val);
    }
    return list;
}

void std_Env_exit(fr_Env env, fr_Obj self, fr_Int status) {
    fr_onExit();
    exit((int)status);
}

