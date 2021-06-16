//
//  GenType.c
//  gen
//
//  Created by yangjiandong on 2017/9/10.
//  Copyright © 2017年 yangjiandong. All rights reserved.
//

#include "TypeGen.h"
#include "util/escape.h"
#include "PodGen.hpp"
#include "MethodGen.h"
#include "ir/FCodeUtil.hpp"
#include <stdlib.h>

TypeGen::TypeGen(FType *type, IRType *irType)
: type(type), irType(irType) {
    name = type->c_mangledName;
    podName = type->c_pod->name;
    isValueType = FCodeUtil::isValueType(type);
}

std::string TypeGen::getTypeNsName(uint16_t tid) {
    FPod *pod = type->c_pod;
    return FCodeUtil::getTypeNsName(pod, tid);
}

void TypeGen::genTypeDeclare(Printer *printer) {
    printer->println("struct %s_struct;", name.c_str());
    printer->println("typedef struct %s_struct *%s_ref;", name.c_str(), name.c_str());
    printer->println("typedef %s_ref %s_null;", name.c_str(), name.c_str());
    if (isValueType) {
        if (!FCodeUtil::isBuildinValType(type)) {
            printer->println("typedef struct %s_struct %s_val;", name.c_str(), name.c_str());
            printer->println("typedef %s_ref %s_pass;", name.c_str(), name.c_str());
        }
        else {
            printer->println("typedef %s_val %s_pass;", name.c_str(), name.c_str());
        }
        printer->println("typedef %s_val %s;", name.c_str(), name.c_str());
    } else {
        printer->println("typedef %s_ref %s;", name.c_str(), name.c_str());
        printer->println("typedef %s_ref %s_pass;", name.c_str(), name.c_str());
    }
}

void TypeGen::genStruct(Printer *printer) {
//    if (FCodeUtil::isBuildinValType(type)) return;
    if (type->c_isNative) {
        printer->println("//native struct %s_struct", name.c_str());
        return;
    }
    
    std::string baseName = getTypeNsName(type->meta.base);
    
    printer->println("struct %s_struct {", name.c_str());
    
    printer->indent();
    if (name == "sys_Obj" || baseName == "sys_Obj") {
        //printer->println("fr_Obj super__;");
    } else {
        printer->println("struct %s_struct super__;", baseName.c_str());
    }
    /*
    std::string base;
    for (int i=0; i<type->meta.mixin.size(); ++i) {
        base = podGen->getTypeRefName(type->meta.mixin[i]);
        printer->println("struct %s_struct %s_super__;", base.c_str(), base.c_str());
    }
    */
    genField(printer);
    printer->unindent();
    
    printer->println("};");
}

void TypeGen::genInline(Printer *printer) {
    
}

void TypeGen::genImple(Printer *printer) {
    
    //if (name != "testlib_GcTest") return;
    
    genStaticField(printer, false);
    printer->newLine();
    for (int i=0; i<type->methods.size(); ++i) {
        FMethod *method = &type->methods[i];
        
        MethodGen gmethod(this, method);
        
        gmethod.genImples(printer);
        
        if (!gmethod.isStatic && isValueType) {
            gmethod.genImplesToVal(printer);
        }
        printer->newLine();
    }
    genTypeInit(printer);
    printer->newLine();
}

void TypeGen::genVTable(Printer *printer) {
    
    printer->println("struct %s_vtable {", name.c_str());
    printer->indent();
    
    irType->initVTable();
//    if ((type->meta.flags & FFlags::Mixin) == 0) {
//        if (type->meta.base != 0xFFFF) {
//            std::string base = FCodeUtil::getTypeRefName(podGen->pod, type->meta.base, false);
//            printer->println("struct %s_vtable super__;", base.c_str());
//        }
//    }
    int count = 0;
    IRVTable *vtable = irType->vtables[0];
    for (int i = 0; i<vtable->functions.size(); ++i) {
        IRVirtualMethod &method = vtable->functions[i];
        if (method.method->c_parent != type) {
            TypeGen tempType(method.method->c_parent, irType->module->defType(method.method->c_parent));
            MethodGen gmethod(&tempType, method.method);
            gmethod.genDeclares(printer, true, false);
            continue;
        }
        MethodGen gmethod(this, method.method);
        gmethod.genDeclares(printer, true, false);
        ++count;
    }

    if (count == 0) {
        printer->println("char __unused__; //C not allow empty struct");
    }
    
    printer->unindent();
    
    printer->println("};");
    
    //printer->println("fr_Type %s_class__(fr_Env __env);", name.c_str());
    printer->println("extern fr_Type %s_class__;", name.c_str());
    
//    printer->println("void %s_initClass__(fr_Env __env, fr_Type type);"
//                     , name.c_str(), name.c_str());
}

void TypeGen::genTypeMetadata(Printer *printer) {
    FTypeRef &typeRef = type->c_pod->typeRefs[type->meta.self];
    std::string &rawTypeName = type->c_pod->names[typeRef.typeName];
    printer->println("type->name = \"%s\";", rawTypeName.c_str());
    printer->println("type->flags = %d;", type->meta.flags);
    printer->println("type->allocSize = sizeof(struct %s_struct);", name.c_str());
    printer->println("type->staticInited = false;");
    
    std::string baseName = getTypeNsName(type->meta.base);
    //sys::Obj's base class is NULL
    if (baseName.size() == 0) {
        printer->println("type->base = (fr_Type)NULL;");
    }
    else {
        printer->println("type->base = (fr_Type)%s_class__;", baseName.c_str());
    }
    printer->println("type->fieldCount = %d;", type->fields.size());
    printer->println("type->fieldList = (struct fr_Field_*)malloc(sizeof(struct fr_Field_)*%d);", type->fields.size());
    //int offset = 0;
    for (int i=0; i<type->fields.size(); ++i) {
        FField &field = type->fields[i];
        std::string fieldName = type->c_pod->names[field.name];
        std::string fieldIdName = fieldName;
        FCodeUtil::escapeIdentifierName(fieldIdName);
        
        printer->println("type->fieldList[%d].name = \"%s\";", i, fieldName.c_str());
        std::string typeName = getTypeNsName(field.type);
        printer->println("type->fieldList[%d].type = \"%s\";", i, typeName.c_str());
        printer->println("type->fieldList[%d].flags = %d;", i, field.flags);
    
        bool isValType = FCodeUtil::isBuildinVal(typeName);
        printer->println("type->fieldList[%d].isValType = %s;", i, isValType ? "true" : "false");
        
        if (field.flags & FFlags::Static) {
            printer->println("type->fieldList[%d].isStatic = true;", i);
            printer->println("type->fieldList[%d].pointer = (void*)(&%s_%s);"
                             , i, name.c_str(), fieldIdName.c_str());
            printer->println("type->fieldList[%d].offset = -1;//is static", i);
        } else if ((field.flags & FFlags::Storage) == 0) {
            printer->println("type->fieldList[%d].isStatic = false;", i);
            printer->println("type->fieldList[%d].offset = -1;//no storage", i);
        } else {
            printer->println("type->fieldList[%d].isStatic = false;", i);
            
            printer->println("type->fieldList[%d].offset = offsetof(struct %s_struct, %s);"
                         , i, name.c_str(), fieldIdName.c_str());
        }
        
    }
    
    printer->println("type->methodCount = %d;", type->methods.size());
    printer->println("type->methodList = (struct fr_Method_*)malloc(sizeof(struct fr_Method_)*%d);", type->methods.size());
    //int offset = 0;
    for (int i=0; i<type->methods.size(); ++i) {
        FMethod &method = type->methods[i];
        std::string fieldName = type->c_pod->names[method.name];
        std::string fieldIdName = fieldName;
        FCodeUtil::escapeIdentifierName(fieldIdName);
        
        printer->println("type->methodList[%d].name = \"%s\";", i, fieldName.c_str());
        std::string typeName = getTypeNsName(method.returnType);
        printer->println("type->methodList[%d].retType = \"%s\";", i, typeName.c_str());
        printer->println("type->methodList[%d].flags = %d;", i, method.flags);
        
        if ((method.flags & FFlags::Abstract) != 0 || type->c_mangledName.find("sys_Libc") != std::string::npos ) {
            printer->println("type->methodList[%d].func = (fr_Function)NULL;", i);
        }
        else {
            printer->println("type->methodList[%d].func = (fr_Function)%s;", i, method.c_mangledName.c_str());
        }
        
        printer->println("type->methodList[%d].paramsCount = %d;", i, method.paramCount);
        printer->println("type->methodList[%d].paramsList = (struct fr_MethodParam_*)malloc(sizeof(struct fr_MethodParam_)*%d);"
                         , i, method.paramCount);
        
        for (int j=0; j<method.paramCount; ++j) {
            FMethodVar &var = method.vars[j];
            std::string name = type->c_pod->names[var.name];
            printer->println("type->methodList[%d].paramsList[%d].name = \"%s\";", i, j, name.c_str());
            name = type->c_pod->names[var.type];
            printer->println("type->methodList[%d].paramsList[%d].type = \"%s\";", i, j, name.c_str());
            printer->println("type->methodList[%d].paramsList[%d].flags = %d;", i, j, var.flags);
        }
    }
    
    printer->println("fr_registerClass(__env, \"%s\", \"%s\", (fr_Type)%s_class__);"
                     , podName.c_str(), rawTypeName.c_str(), name.c_str());
}

void TypeGen::genVTableInit(Printer *printer) {
    irType->initVTable();
    printer->println("void **vtable = (void**)(type+1);");

    printer->println("if (%d >= MAX_INTERFACE_SIZE) abort();", irType->vtables.size()-1);
    int pos = 0;
    int i = 0;
    for (; i<irType->vtables.size(); ++i) {
        IRVTable *vtable = irType->vtables[i];
        if (i != 0) {
            printer->println("type->interfaceVTableIndex[%d].type = %s_class__;", i-1, vtable->type->ftype->c_mangledName.c_str());
            printer->println("type->interfaceVTableIndex[%d].vtableOffset = %d;", i-1, pos);
        }
        
        for (IRVirtualMethod &method : vtable->functions) {
            //MethodGen gmethod(this, method.method);
            if (method.method->flags & FFlags::Abstract) {
                printer->println("vtable[%d] = NULL;", pos);
            }
            else {
                printer->println("vtable[%d] = (void*)%s;", pos, method.method->c_mangledName.c_str());
            }
            ++pos;
        }
    }
    printer->println("type->interfaceVTableIndex[%d].type = NULL;", i-1);
    printer->println("type->interfaceVTableIndex[%d].vtableOffset = 0;", i-1);
}

void TypeGen::genTypeInit(Printer *printer) {
    printer->println("fr_Type %s_class__ = NULL;", name.c_str());
    
    printer->println("void %s_initClass__(fr_Env __env, struct fr_Class_ *type) {", name.c_str());
    printer->indent();
    
    genVTableInit(printer);
    genTypeMetadata(printer);
    
    printer->unindent();
    printer->println("};");
}

void TypeGen::genMethodDeclare(Printer *printer) {
    for (int i=0; i<type->methods.size(); ++i) {
        FMethod *method = &type->methods[i];
        MethodGen gmethod(this, method);
        gmethod.genDeclares(printer, false, false);
        
        bool isStatic = (method->flags & FFlags::Static);
        if (!isStatic && isValueType) {
            gmethod.genDeclares(printer, false, true);
        }
        
        //printer->newLine();
    }
}

void TypeGen::genNativePrototype(Printer *printer) {
    if (type->c_isNative) {
        //gen static fields
        for (int i=0; i<type->fields.size(); ++i) {
            FField *field = &type->fields[i];
            if ((field->flags & FFlags::Static) == 0) {
                continue;
            }
            auto name = FCodeUtil::getIdentifierName(type->c_pod, field->name);
            auto typeName = getTypeNsName(field->type);
            printer->println("%s %s_%s = 0;", typeName.c_str(), this->name.c_str(), name.c_str());
        }
        printer->newLine();
    }
    
    for (int i=0; i<type->methods.size(); ++i) {
        FMethod *method = &type->methods[i];
        
        if ((method->flags & FFlags::Native) == 0 && (method->c_parent->meta.flags & FFlags::Native) == 0) {
            continue;
        }
        if ((method->flags & FFlags::Abstract) != 0) {
            continue;
        }
        if (!method->code.isEmpty()) {
            continue;
        }
        
        std::string &methodName = method->c_stdName;
        if (!method->code.isEmpty() && methodName != "static$init" && methodName != "instance$init$") {
            continue;
        }
        
        MethodGen gmethod(this, method);
        
        bool isStatic = (method->flags & FFlags::Static);
        if (!isStatic && isValueType) {
            gmethod.genNativePrototype(printer, false, true);
        }
        else {
            gmethod.genNativePrototype(printer, false, false);
        }
    }
}

void TypeGen::genField(Printer *printer) {
    int count = 0;
    for (int i=0; i<type->fields.size(); ++i) {
        FField *field = &type->fields[i];
        if ((field->flags & FFlags::Static) != 0) {
            continue;
        }
        if ((field->flags & FFlags::Storage) == 0) {
            continue;
        }
        auto name = FCodeUtil::getIdentifierName(type->c_pod, field->name);
        std::string typeName = FCodeUtil::getTypeDeclName(type->c_pod, field->type);
        printer->println("%s %s;", typeName.c_str(), name.c_str());
        ++count;
    }
    if (count == 0) {
        printer->println("char __unused__; //C not allow empty struct");
    }
}

void TypeGen::genStaticField(Printer *printer, bool isExtern) {
//    if ((type->meta.flags & FFlags::Native) != 0) {
//        isExtern = true;
//    }
//    if (type->c_isNative) {
//        isExtern = true;
//    }
    
    for (int i=0; i<type->fields.size(); ++i) {
        FField *field = &type->fields[i];
        if ((field->flags & FFlags::Static) == 0) {
            continue;
        }
        auto name = FCodeUtil::getIdentifierName(type->c_pod, field->name);
        auto typeName = FCodeUtil::getTypeDeclName(type->c_pod, field->type);
        if (isExtern) {
            printer->printf("extern ");
            printer->println("%s %s_%s;", typeName.c_str(), this->name.c_str(), name.c_str());
        } else {
            if (FCodeUtil::isBuildinVal(typeName)) {
                printer->println("%s %s_%s = 0;", typeName.c_str(), this->name.c_str(), name.c_str());
            } else {
                printer->println("%s %s_%s;", typeName.c_str(), this->name.c_str(), name.c_str());
            }
        }
    }
}

