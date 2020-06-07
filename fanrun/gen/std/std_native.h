//
//  std_native.h
//  run
//
//  Created by yangjiandong on 2020/3/22.
//  Copyright © 2020 yangjiandong. All rights reserved.
//

#ifndef std_native_h
#define std_native_h
#ifdef  __cplusplus
extern  "C" {
#endif
    
    struct std_AtomicInt_struct {
        int64_t _val;
    };
    
    struct std_Unsafe_struct {
        sys_Obj_null _val;
    };
    
    struct std_Lazy_struct {
        sys_Obj_null _val;
    };
    
    struct std_AtomicRef_struct {
        sys_Obj_null _val;
    };
    
    struct std_Lock_struct {
        sys_Obj_null _val;
    };
    
    struct std_SoftRef_struct {
        sys_Obj_null _val;
    };
    
    struct std_AtomicBool_struct {
        sys_Bool _val;
    };
    
    
    struct std_Decimal_struct {
        sys_Float _val;
    };
    
    struct std_RegexMatcher_struct {
        
    };
    
    struct std_Env_struct {
        
    };
    
#ifdef  __cplusplus
} //end "C"
#endif

#endif /* std_native_h */
