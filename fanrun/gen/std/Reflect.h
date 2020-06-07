//
//  Reflect.hpp
//  run
//
//  Created by yangjiandong on 2020/3/31.
//  Copyright © 2020 yangjiandong. All rights reserved.
//

#ifndef Reflect_hpp
#define Reflect_hpp

#include <stdio.h>


#define FR_STR(str) fr_newStrUtf8(__env, str, -1)

#define FR_REG_POD(name, version, depends) \
  std_Pod pod = FR_ALLOC(std_Pod);\
  FR_VOID_CALL(0, std_Pod, make, FR_STR(name),FR_STR(version), FR_STR(depends));\
  std_PodList_addPod(__env, pod);

#define FR_REG_TYPE(pod, varName, name, signature, flags) \
  std_Type varName = FR_ALLOC(std_Type);\
  FR_VOID_CALL(0, std_Type, privateMake, varName, FR_STR(name), FR_STR(signature), flags);\
  std_Pod_addType(__env, varName);

#define FR_REG_FIELD(varName, parent, name, doc, flags, type, id) \
  std_Field varName = FR_ALLOC(std_Field);\
  FR_VOID_CALL(0, std_Method, make, varName, parent, FR_STR(name),FR_STR(doc), flags, FR_STR(returns), id);\
  std_Type_addSlot(__env, parent, varName);

#define FR_REG_METHOD(varName, parent, name, doc, flags, returns, id) \
  std_Method varName = FR_ALLOC(std_Method);\
  FR_VOID_CALL(0, std_Method, make, varName, parent, FR_STR(name),FR_STR(doc), flags, FR_STR(returns), id);\
  std_Type_addSlot(__env, parent, varName);

#define FR_REG_PARAM(method, name, type, mask) \
  FR_VOID_CALL(0, std_Method, addParam, FR_STR(name), FR_STR(type), mask);

#endif /* Reflect_hpp */
