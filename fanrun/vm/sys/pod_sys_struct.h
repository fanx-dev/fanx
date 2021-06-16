#include "vm.h"

CF_BEGIN

struct sys_Obj_{
    char __unused__;
};

struct sys_Bool_{
    fr_Bool value;
};

struct sys_Num_{
    char __unused__;
};

struct sys_Float_{
    fr_Float value;
};

struct sys_Int_{
    fr_Int value;
};

struct sys_Array_{
    fr_Array data;
};

struct sys_Func_{
    char __unused__;
};

struct sys_Ptr_ {
    void *ptr;
};

CF_END
