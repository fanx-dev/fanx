#include "vm.h"

CF_BEGIN

struct sys_Obj_struct {
    char __unused__; //C not allow empty struct
};

struct sys_Int_struct {
    int64_t _val;
};
struct sys_Float_struct {
    double _val;
};
struct sys_Bool_struct {
    bool _val;
};

struct sys_Array_struct {
    fr_Array _val;
};

struct sys_Func_struct {
    char __unused__; //C not allow empty struct
};

struct sys_Ptr_struct {
    void *_val;
};

CF_END
