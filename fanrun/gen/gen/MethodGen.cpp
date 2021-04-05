//
//  CodeGen.c
//  gen
//
//  Created by yangjiandong on 2017/9/16.
//  Copyright © 2017年 yangjiandong. All rights reserved.
//

#include "MethodGen.h"
#include "ir/MBuilder.hpp"
#include "PodGen.hpp"
#include "ir/FCodeUtil.hpp"

static const char* getUnionTagName(std::string &type) {
    const char* tagName = "";
    if (type == "sys_Int") {
        tagName = "i";
    }
    else if (type == "sys_Bool") {
        tagName = "b";
    }
    else if (type == "sys_Float") {
        tagName = "f";
    }
    else {
        tagName = "o";
    }
    return tagName;
}

MethodGen::MethodGen(TypeGen *parent, FMethod *method) : parent(parent), method(method) {
    name = method->c_mangledSimpleName;//FCodeUtil::getIdentifierName(parent->podGen->pod, method->name);
    isStatic = (method->flags & FFlags::Static);
}

std::string MethodGen::getTypeDeclName(uint16_t tid, bool forPass) {
    FPod *pod = parent->type->c_pod;
    return FCodeUtil::getTypeDeclName(pod, tid, forPass);
}

bool MethodGen::genPrototype(Printer *printer, bool funcPtr, bool isValType) {
    int paramNum = method->paramCount;
    
    auto typeName = getTypeDeclName(method->returnType);
    
    if (typeName == "sys_Void") {
        typeName = "void";
    }
    else if (typeName == "sys_This") {
        typeName = parent->name;
    }
    
    const char *valFlag = "";
    if (isValType) valFlag = "_val";
    
    if (funcPtr) {
        //void (*foo3_val)(
        printer->printf("%s (*%s%s)(", typeName.c_str(), name.c_str(), valFlag);
    } else {
        //void sys_Int_foo3_val(
        printer->printf("%s %s_%s%s(", typeName.c_str(), parent->name.c_str(), name.c_str(), valFlag);
    }
    
    printer->printf("fr_Env __env");
    
    if (!isStatic) {
        if (isValType) {
            printer->printf(", %s_pass __self", parent->name.c_str());
        } else {
            printer->printf(", %s_ref __self", parent->name.c_str());
        }
    }
    
    for (int j=0; j<paramNum; ++j) {
        FMethodVar &var = method->vars[j];
        auto var_name = FCodeUtil::getIdentifierName(parent->type->c_pod, var.name);
        auto var_typeName = getTypeDeclName(var.type, true);
        
        printer->printf(", %s %s", var_typeName.c_str(), var_name.c_str());
    }
    printer->printf(")");
    return true;
}

void MethodGen::genDeclares(Printer *printer, bool funcPtr, bool isValType) {
    genPrototype(printer, funcPtr, isValType);
    printer->println(";");
}

void MethodGen::genNativePrototype(Printer *printer, bool funcPtr, bool isValType) {
    genPrototype(printer, funcPtr, isValType);
    printer->println(" { FR_SET_ERROR_ALLOC(sys_UnsupportedErr); }");
}

void MethodGen::genImples(Printer *printer) {
    //if (name != "flatten") return;
    
    bool isVal = !isStatic && parent->isValueType;
    if ((method->flags & FFlags::Native) != 0  && method->code.isEmpty()) {
        return;
    }
    if ((method->flags & FFlags::Abstract) != 0) {
        return;
    }
    
    if ((parent->name == "sys_BindFunc" || parent->name == "sys_Func") && parent->type->c_pod->names[method->name] == "call") {
        return;
    }
    
    if (parent->type->c_isExtern) {
        //skip Func
        if (parent->name == "sys_Array") {
            return;
        }
   
        std::string &methodName = method->c_stdName;
        if (!method->code.isEmpty() && methodName != "static$init" && methodName != "instance$init$") {
            //has code
        }
        else {
            return;
        }
    }
    
    if ((parent->type->meta.flags & FFlags::Native) != 0 && method->code.isEmpty()) return;
    
    genPrototype(printer, false, isVal);
    printer->println(" {");
    
    IRMethod irMethod(parent->type->c_pod, method);
    irMethod.name = this->name;
    MBuilder builder(method->code, irMethod);
    builder.buildMethod(method);
    
    printer->indent();
    irMethod.print(*printer, 1);
    printer->unindent();

    printer->println("}");
}

/**
 ** gen for value type. e.g.
 ** void foo(Obj __self, Int arg) {
 **     foo_val(UNBOXING(__self), arg)
 ** }
 **/
void MethodGen::genImplesToVal(Printer *printer) {
    genPrototype(printer, false, false);
    printer->println(" {");
    printer->indent();
    
    auto typeName = getTypeDeclName(method->returnType);
    
    //std::string retVar;
    if (typeName != "sys_Void") {
        printer->printf("return ");
    }
    
    //int i = method->paramCount;
    if (FCodeUtil::isBuildinValType(method->c_parent)) {
        printer->printf("%s_%s_val(__env, FR_UNBOXING_VAL(__self, %s)"
                        , parent->name.c_str(), name.c_str(), parent->name.c_str());
    } else {
        printer->printf("%s_%s_val(__env, __self"
                        , parent->name.c_str(), name.c_str());
    }
    
    int paramNum = method->paramCount;
    for (int j=0; j<paramNum; ++j) {
        FMethodVar &var = method->vars[j];
        auto var_name = FCodeUtil::getIdentifierName(parent->type->c_pod, var.name);
        printer->printf(", %s", var_name.c_str());
    }
    printer->println(");");
    printer->unindent();
    printer->println("}");
}

/**
 ** Gen stub to call VM in native code:
    Type foo(__env, __self, Int arg1, Int arg2) {
      static fr_Method method = NULL;
      fr_Value args[3];
      fr_Value __ret;
 
      if (!method) method = fr_findMethod(__env, Class_foo);
      args[0].o = __self;
      args[1].o = arg1;
      args[2].o = arg2;
      __ret = fr_callMethod(__env, method, args, 3)
    }
 **
 **/
//unused code
void MethodGen::genMethodStub(Printer *printer, bool isValType) {
    genPrototype(printer, false, isValType);
    printer->println(" {");
    
    int paramNum = method->paramCount;
    auto retTypeName = getTypeDeclName(method->returnType);
    
    printer->indent();
    printer->println("static fr_Method method = NULL;");
    if (isStatic) {
        printer->println("fr_Value args[%d];", paramNum);
    } else {
        printer->println("fr_Value args[%d];", paramNum+1);
    }
    
    if (retTypeName != "sys_Void") {
        printer->println("fr_Value __ret;");
    }
    printer->println("if (!method) method = fr_findMethod(__env, \"%s\", \"%s\");"
                    , parent->name.c_str(), name.c_str());
    
    if (!isStatic) {
        if (isValType) {
            printer->println("args[0].%s = __self;", getUnionTagName(parent->name));
        } else {
            printer->println("args[0].o = __self;");
        }
    }
    
    for (int j=0; j<paramNum; ++j) {
        FMethodVar &var = method->vars[j];
        auto var_name = FCodeUtil::getIdentifierName(parent->type->c_pod, var.name);
        auto var_typeName = getTypeDeclName(var.type);
        const char *tag = getUnionTagName(var_typeName);
        if (isStatic) {
            printer->println("args[%d].%s = %s;", j, tag, var_name.c_str());
        } else {
            printer->println("args[%d].%s = %s;", j+1, tag, var_name.c_str());
        }
    }
    
    if (retTypeName != "sys_Void") {
        printer->println("fr_callMethod(__env, method, args, %d, &__ret);", paramNum);
        printer->println("return (%s)__ret.%s;", retTypeName.c_str(), getUnionTagName(retTypeName));
    } else {
        printer->println("fr_callMethod(__env, method, args, %d, NULL);", paramNum);
    }
    printer->unindent();
    printer->println("}");
}

//unused code
void MethodGen::genStub(Printer *printer) {
    
    if (parent->name == "sys_Func") return;
    
    genMethodStub(printer, false);
    if (!isStatic && parent->isValueType) {
        genMethodStub(printer, true);
    }
}

/**
 ** gen register native to VM
 **/
//unused code
void MethodGen::genRegister(Printer *printer) {
    if (!isStatic && FCodeUtil::isBuildinValType(method->c_parent)) {
        printer->println("fr_registerMethod(vm, \"%s_%s%d_val\", %s_%s%d_val_wrap__);"
                         , parent->name.c_str(), name.c_str(), method->paramCount
                         , parent->name.c_str(), name.c_str(), method->paramCount);

    }
    else {
        printer->println("fr_registerMethod(vm, \"%s_%s%d\", %s_%s%d_wrap__);"
                     , parent->name.c_str(), name.c_str(), method->paramCount
                     , parent->name.c_str(), name.c_str(), method->paramCount);
    }
}
/**
 ** gen wrap to call native code for VM
 ** 
   void foo_wrap(__env, args, fr_Value *__retVal) {
      Type __self = args[0].o;
      Type2 arg1 = args[1].o;
      Type3 arg2 = args[2].o;
      __retVal.o = foo(__env, __self, arg1, arg2);
   }
 **/
//unused code
void MethodGen::genRegisterWrap(Printer *printer, bool isValType) {
    const char *valFlag = "";
    if (isValType) valFlag = "_val";
    
    printer->println("void %s_%s%d%s_wrap__(fr_Env __env, fr_Value *__args, fr_Value *__retVal) {"
                     , parent->name.c_str(), name.c_str(), method->paramCount, valFlag);
    printer->indent();
    int paramNum = method->paramCount;
    auto retTypeName = getTypeDeclName(method->returnType);
    
    if (!isStatic) {
        printer->println("%s __self = __args[0].%s;", parent->name.c_str(), getUnionTagName(parent->name));
    }
    for (int j=0; j<paramNum; ++j) {
        FMethodVar &var = method->vars[j];
        auto var_name = FCodeUtil::getIdentifierName(parent->type->c_pod, var.name);
        auto var_typeName = getTypeDeclName(var.type);
        
        if (isStatic) {
            printer->println("%s %s = __args[%d].%s;"
                    , var_typeName.c_str(), var_name.c_str(), j, getUnionTagName(var_typeName));
        } else {
            printer->println("%s %s = __args[%d].%s;"
                    , var_typeName.c_str(), var_name.c_str(), j+1, getUnionTagName(var_typeName));
        }
    }
    
    if (retTypeName != "sys_Void") {
        printer->printf("__retVal->%s = ", getUnionTagName(retTypeName));
    }
    
    printer->printf("%s_%s%d%s(__env", parent->name.c_str(), name.c_str(), method->paramCount, valFlag);
    if (!isStatic) {
        printer->printf(", __self");
    }
    for (int j=0; j<paramNum; ++j) {
        FMethodVar &var = method->vars[j];
        auto var_name = FCodeUtil::getIdentifierName(parent->type->c_pod, var.name);
        printer->printf(", %s", var_name.c_str());
    }
    printer->println(");");
    
    printer->unindent();
    printer->println("}");
}
