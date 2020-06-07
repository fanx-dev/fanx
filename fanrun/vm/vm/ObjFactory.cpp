//
//  ObjFactory.cpp
//  vm
//
//  Created by yangjiandong on 15/10/4.
//  Copyright (c) 2015, yangjiandong. All rights reserved.
//

#include "ObjFactory.h"
#include "Env.h"
//#include "StackFrame.h"

extern  "C"  {
#if 1
    //void sys_register(fr_Fvm vm) {}
#endif

  FObj * sys_Str_fromUtf8_(fr_Env env__, const char *cstr) {
//      fr_Value args[2];
//      fr_Value ret;
//      args[0].p = (void*)cstr;
//      args[1].i = strlen(cstr);
//      fr_callMethodS(env__, "sys", "Str", "fromCStr", 2, args, &ret);
//      return fr_getPtr(env__, ret.h);
      
      Env *e = (Env*)env__;
      static FMethod *m = NULL;
      if (!m) {
          m = e->findMethod("sys", "Str", "fromCStr");
      }
      fr_TagValue args[2];
      args[0].type = fr_vtPtr;
      args[0].any.p = (void*)cstr;
      args[1].type = fr_vtInt;
      args[1].any.i = strlen(cstr);
      e->push(&args[0]);
      e->push(&args[1]);
      e->call(m, 2);
      
      fr_TagValue ret;
      e->pop(&ret);
      return ret.any.o;
  }
  char *sys_Str_getUtf8(fr_Env env__, FObj * self__) {
//      fr_Value args;
//      fr_Value ret;
//      args.o = self__;
//      fr_callMethodS(env__, "sys", "Str", "toUtf8", 1, &args, &ret);
//      fr_Array *a = (fr_Array*)fr_getPtr(env__, ret.h);
//      return (char*)a->data;
      
      Env *e = (Env*)env__;
      static FMethod *m = NULL;
      if (!m) {
          m = e->findMethod("sys", "Str", "toUtf8");
      }
      fr_TagValue args[2];
      args[0].type = fr_vtObj;
      args[0].any.o = self__;
      e->push(&args[0]);
      e->call(m, 0);
      
      fr_TagValue ret;
      e->pop(&ret);
      fr_Array *a = (fr_Array*)ret.any.o;
      return (char*)a->data;
  }
}

ObjFactory::ObjFactory()
    : trueObj(NULL), falseObj(NULL)
{
}

FObj * ObjFactory::allocObj(Env *env, FType *type, int addRef, int size) {
    if (!type) {
        printf("WAIN: allocObj with null type");
        return NULL;
    }
    FType *ftype = type;
    
    env->podManager->initTypeAllocSize(env, ftype);
    
    if (ftype->c_allocSize > size) {
        size = ftype->c_allocSize;
    }
    
    FObj * obj = (FObj *)env->vm->gc->alloc(ftype, size);
    //obj->type = ftype;
//    for (int i=0; i<ftype->fields.size(); ++i) {
//        FField &f = ftype->fields[i];
//        if (f.flags & FFlags::Static) {
//            //pass;
//        } else {
//            fr_Value *val = env->podManager->getInstanceFieldValue(obj, &f);
//            fr_ValueType vtype = env->podManager->getValueType(env, ftype->c_pod, f.type);
//            val->type = vtype;
//        }
//    }
    
    return obj;
}

CF_BEGIN

FObj * sys_Int_box__(fr_Env self, fr_Int i, int addRef);
FObj * sys_Float_box__(fr_Env self, fr_Float i, int addRef);
FObj * sys_Bool_box__(fr_Env self, fr_Bool i, int addRef);
fr_Int sys_Int_unbox__(fr_Env self, FObj * i);
fr_Float sys_Float_unbox__(fr_Env self, FObj * i);
fr_Bool sys_Bool_unbox__(fr_Env self, FObj * i);

CF_END

#define FR_DUMMY_BOX
#ifdef FR_DUMMY_BOX
FObj * sys_Int_box__(fr_Env self, fr_Int i, int addRef) {
    Env *e = (Env*)self;
    FType *type = e->toType(fr_vtInt);
    int size = sizeof(fr_ObjHeader) + sizeof(fr_Int);
    
    FObj * obj = e->allocObj(type, addRef, size);
    //FObj * obj = fr_allocObj(self, type, addRef, size);
    
    fr_Int *val = (fr_Int*)(((char*)obj) + sizeof(fr_ObjHeader));
    *val = i;
    return obj;
}
fr_Int sys_Int_unbox__(fr_Env self, FObj * i) {
    assert(i);
    fr_Int *val = (fr_Int*)(((char*)i) + sizeof(fr_ObjHeader));
    return *val;
}

FObj * sys_Float_box__(fr_Env self, fr_Float i, int addRef) {
    Env *e = (Env*)self;
    FType *type = e->toType(fr_vtFloat);
    int size = sizeof(fr_ObjHeader) + sizeof(fr_Float);
    
    FObj * obj = e->allocObj(type, addRef, size);
    //FObj * obj = fr_allocObj(self, type, addRef, size);
    
    fr_Float *val = (fr_Float*)(((char*)obj) + sizeof( fr_ObjHeader));
    *val = i;
    return obj;
}
fr_Float sys_Float_unbox__(fr_Env self, FObj * i) {
    assert(i);
    fr_Float *val = (fr_Float*)(((char*)i) + sizeof( fr_ObjHeader));
    return *val;
}

FObj * sys_Bool_box__(fr_Env self, fr_Bool i, int addRef) {
    Env *e = (Env*)self;
    FType *type = e->toType(fr_vtBool);
    int size = sizeof( fr_ObjHeader) + sizeof(fr_Bool);
    
    FObj * obj = e->allocObj(type, addRef, size);
    //FObj * obj = fr_allocObj(self, type, addRef, size);
    
    fr_Bool *val = (fr_Bool*)(((char*)obj) + sizeof( fr_ObjHeader));
    *val = i;
    return obj;
}
fr_Bool sys_Bool_unbox__(fr_Env self, FObj * i) {
    assert(i);
    fr_Bool *val = (fr_Bool*)(((char*)i) + sizeof( fr_ObjHeader));
    return *val;
}
#endif

FObj * ObjFactory::box(Env *env, fr_Value &any, fr_ValueType vtype) {
    FObj * obj = nullptr;
    switch (vtype) {
    case fr_vtInt: {
        fr_Int i = any.i;
        bool cache = (i < 256) && (i > -256);
        if (cache) {
            auto found = boxedInt.find(i);
            if (found != boxedInt.end()) {
                obj = fr_getPtr(env, found->second);
            }
        }
        obj = sys_Int_box__(env, i, 1);
        
        if (cache) {
            fr_Obj objRef = env->newGlobalRef(obj);
            boxedInt[i] = objRef;
            //env->addGlobal(obj);
        }
    }
        break;
    case fr_vtFloat: {
        obj = sys_Float_box__(env, any.f, 1);
    }
        break;
    case fr_vtBool: {
        if (!trueObj) {
            obj = sys_Bool_box__(env, true, 0);
            trueObj = env->newGlobalRef(obj);
            obj = sys_Bool_box__(env, false, 0);
            falseObj = env->newGlobalRef(obj);
        }
        if (any.b) {
            obj = fr_getPtr(env, trueObj);
        } else {
            obj = fr_getPtr(env, falseObj);
        }
    }
        break;
    default:
        break;
    }
    return obj;
}

bool ObjFactory::unbox(Env *env, FObj * &obj, fr_Value &value) {
    fr_ValueType type = env->podManager->getValueTypeByType(env, fr_getFType(env, obj));
    if (type == fr_vtInt) {
        value.i = sys_Int_unbox__(env, obj);
    } else if (type == fr_vtFloat) {
        value.f = sys_Float_unbox__(env, obj);
    } else if (type == fr_vtBool) {
        value.b = sys_Bool_unbox__(env, obj);
    } else {
        value.o = obj;
        return false;
    }
    //value.type = type;
    return true;
}

FObj *ObjFactory::getString(Env *env, FPod *curPod, uint16_t sid) {
    if (curPod->constantas.c_strings.size() != curPod->constantas.strings.size()) {
        curPod->constantas.c_strings.resize(curPod->constantas.strings.size());
    }
    
    fr_Obj objRef = (fr_Obj)curPod->constantas.c_strings[sid];
    if (objRef) {
        return fr_getPtr(env, objRef);
    }
    
    const std::string &utf8 = curPod->constantas.strings[sid];
    FObj *obj = (FObj *)sys_Str_fromUtf8_(env, utf8.c_str());
    objRef = env->newGlobalRef(obj);
    curPod->constantas.c_strings[sid] = (void*)objRef;
    
    return fr_getPtr(env, objRef);
}

FObj * ObjFactory::newString(Env *env, const char *utf8) {
    FObj * obj = (FObj *)sys_Str_fromUtf8_(env, utf8);
    return obj;
}

const char *ObjFactory::getStrUtf8(Env *env, FObj *obj) {
    return sys_Str_getUtf8(env, obj);
}

//FObj *ObjFactory::getWrappedType(Env *env, FType *type) {
//    if (!type->c_wrappedType) {
//        FObj *obj = sys_Type_fromFType(env, type);
//        fr_Obj objRef = env->newGlobalRef(obj);
//        type->c_wrappedType = (void*)objRef;
//    }
//    return fr_getPtr(env, (fr_Obj)type->c_wrappedType);
//}
//
//FType *ObjFactory::getFType(Env *env, FObj *otype) {
//    return sys_Type_toFType(env, otype);
//}
