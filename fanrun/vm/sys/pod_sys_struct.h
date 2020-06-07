#include "vm.h"

CF_BEGIN

struct sys_Obj_{
    fr_ObjHeader super;
};

struct sys_Bool_{
    struct sys_Obj_ super;
    fr_Bool value;
};

struct sys_Num_{
    struct sys_Obj_ super;
};

struct sys_Float_{
    struct sys_Num_ super;
    fr_Float value;
};

struct sys_Int_{
    struct sys_Num_ super;
    fr_Int value;
};

struct sys_Array_{
    fr_Array data;
};

struct sys_Func_{
    struct sys_Obj_ super;
};

struct sys_Ptr_ {
    struct sys_Obj_ super;
    void *ptr;
};

CF_END
