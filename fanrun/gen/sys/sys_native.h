//
//  sys_native.h
//  run
//
//  Created by yangjiandong on 2017/12/17.
//  Copyright © 2017年 yangjiandong. All rights reserved.
//

#ifndef sys_native_h
#define sys_native_h


/////////////////////////////////
#ifdef  __cplusplus
extern  "C" {
#endif
    
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
    fr_Type elemType;
    int32_t valueType;
    int32_t elemSize;
    int64_t size;
    fr_Obj data[0];
};

struct sys_Func_struct {
    char __unused__; //C not allow empty struct
};

struct sys_Ptr_struct {
    void *_val;
};

sys_Obj_null sys_Func_call__8(fr_Env __env, sys_Func_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d, sys_Obj_null e, sys_Obj_null f, sys_Obj_null g, sys_Obj_null h);
sys_Obj_null sys_Func_call__7(fr_Env __env, sys_Func_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d, sys_Obj_null e, sys_Obj_null f, sys_Obj_null g);
sys_Obj_null sys_Func_call__6(fr_Env __env, sys_Func_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d, sys_Obj_null e, sys_Obj_null f);
sys_Obj_null sys_Func_call__5(fr_Env __env, sys_Func_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d, sys_Obj_null e);
sys_Obj_null sys_Func_call__4(fr_Env __env, sys_Func_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c, sys_Obj_null d);
sys_Obj_null sys_Func_call__3(fr_Env __env, sys_Func_ref __self, sys_Obj_null a, sys_Obj_null b, sys_Obj_null c);
sys_Obj_null sys_Func_call__2(fr_Env __env, sys_Func_ref __self, sys_Obj_null a, sys_Obj_null b);
sys_Obj_null sys_Func_call__1(fr_Env __env, sys_Func_ref __self, sys_Obj_null a);
sys_Obj_null sys_Func_call__0(fr_Env __env, sys_Func_ref __self);

#ifdef  __cplusplus
} //end "C"
#endif

#endif /* sys_native_h */
