//
//  NativeGen.cpp
//  vm
//
//  Created by yangjiandong on 15/9/26.
//  Copyright (c) 2015, yangjiandong. All rights reserved.
//

#include "NativeGen.h"
#include "escape.h"

NativeGen::NativeGen() : genStub(false) {
    
}

static void getValueTypeName(fr_ValueType vtype, std::string &name, std::string &tagName, std::string &typeName) {
    switch (vtype) {
        case fr_vtInt:
            name = "fr_Int";
            tagName = "i";
            typeName = "fr_vtInt";
            break;
        case fr_vtFloat:
            name = "fr_Float";
            tagName = "f";
            typeName = "fr_vtFloat";
            break;
        case fr_vtBool:
            name = "fr_Bool";
            tagName = "b";
            typeName = "fr_vtBool";
            break;
        case fr_vtPtr:
            name = "fr_Ptr";
            tagName = "p";
            typeName = "fr_vtPtr";
            break;
        default:
            name = "fr_Obj";
            tagName = "h";
            typeName = "fr_vtHandle";
            break;
    }
}

void NativeGen::genNativeMethod(FPod *pod, FType *type, FMethod *method, Printer *printer, PrintType printType) {
    bool isStatic = (method->flags & FFlags::Static);
    int count = method->paramCount;
    if (!isStatic) {
        ++count;
    }
    
    for (int j=0; j<count; ++j) {
        std::string varName;
        std::string typeName;
        std::string tagName;
        std::string vtName;
        
        bool nullable = false;
        fr_ValueType vtype = fr_vtObj;
        
        int rIndex = count - j - 1;
        
        if (isStatic) {
            int varIndex = j;
            if (printType == PrintType::pNatiArgGet) {
                varIndex = rIndex;
            }
            FMethodVar &var = method->vars[varIndex];
            varName = pod->names[var.name];
            vtype = podMgr->getExactValueType(pod, var.type, nullable);
            
            if (!nullable) {
                getValueTypeName(vtype, typeName, tagName, vtName);
            } else {
                getValueTypeName(fr_vtObj, typeName, tagName, vtName);
            }
        }
        else {
            if ((printType == PrintType::pNatiArgGet && rIndex == 0)
                || (printType != PrintType::pNatiArgGet && j == 0)) {
                varName = "self";
                vtype = podMgr->getExactValueType(pod, type->meta.self, nullable);
                nullable = false;
                if (!nullable) {
                    getValueTypeName(vtype, typeName, tagName, vtName);
                } else {
                    getValueTypeName(fr_vtObj, typeName, tagName, vtName);
                }
            }
            else {
                int varIndex = j-1;
                if (printType == PrintType::pNatiArgGet) {
                    varIndex = rIndex-1;
                }
                FMethodVar &var = method->vars[varIndex];
                varName = pod->names[var.name];
                escape(varName);
                //escapeKeyword(varName);
                vtype = podMgr->getExactValueType(pod, var.type, nullable);
                
                if (!nullable) {
                    getValueTypeName(vtype, typeName, tagName, vtName);
                } else {
                    getValueTypeName(fr_vtObj, typeName, tagName, vtName);
                }
            }
        }
        
        
        if (printType == PrintType::pImpeDef) {
            //print methods arg list;
            printer->printf(", %s %s", typeName.c_str(), varName.c_str());
        }
        else if (printType == PrintType::pNatiLocalDecl) {
            //print locals declear
            printer->println("fr_Value value_%d;", j);
            printer->println("%s arg_%d; ", typeName.c_str(), j);
        }
        else if (printType == PrintType::pNatiArgGet) {
            //print box and unbox
            printer->println("fr_getParam(env, param, &value_%d, %d);", rIndex, rIndex);
            
            if (vtype != fr_vtObj) {
                printer->println("arg_%d = value_%d.%s;"
                                 , rIndex, rIndex, tagName.c_str());
            } else {
                printer->println("arg_%d = value_%d.%s;"
                                 , rIndex, rIndex , tagName.c_str());
            }
            printer->newLine();
        }
        else if (printType == PrintType::pNatiArgPass) {
            //print call methods param
            printer->printf(", arg_%d", j);
        }
    }
}

void NativeGen::genNativeType(FPod *pod, FType *type, std::string &preName, Printer *printer, PrintType printType) {
    
    //--------------------------------
    // gen struct
    if (printType == PrintType::pStruct
        && (type->c_isNative)) {
        std::string typeName = preName;
        escape(typeName);
        //escapeKeyword(typeName);
        printer->println("struct %s{", typeName.c_str());
        
        printer->indent();
        if (typeName == "sys_Obj_") {
            printer->println("//struct FObj *_ super;");
        } else {
            FTypeRef &typeRef = pod->typeRefs[type->meta.base];
            std::string &podName = pod->names[typeRef.podName];
            std::string &typeName = pod->names[typeRef.typeName];
            std::string preName = podName + "_" + typeName;
            printer->println("//struct %s_struct super;", preName.c_str());
        }
        printer->unindent();
        
        printer->println("};");
        printer->newLine();
    }
    
    //--------------------------------
    // gen allocSize
    if ((type->c_isNative)) {
        std::string typeName = preName;
        escape(typeName);
        //escapeKeyword(typeName);
        
        if (printType == PrintType::pRegisterDef) {
            printer->println("int %s_allocSize__();", typeName.c_str());
            //printer->println("void %sstatic__init(fr_Env self, void *param, void *ret);", typeName.c_str());
        }
        else if (printType == PrintType::pRegisterCode) {
            printer->println("fr_registerMethod(vm, \"%s_allocSize__\", (fr_NativeFunc)%s_allocSize__);"
                             , preName.c_str(), typeName.c_str());
            //printer->println("fr_registerMethod(vm, \"%sstatic$init\", (fr_NativeFunc)%sstatic__init);"
            //                 , preName.c_str(), typeName.c_str());
        }
        else if (printType == PrintType::pNatiAll) {
            printer->println("int %s_allocSize__() {"
                             "return sizeof(struct %sstruct);}"
                             , typeName.c_str(), typeName.c_str());
            //printer->println("void %sstatic__init(fr_Env self, void *param, void *ret);"
            //                 , typeName.c_str(), typeName.c_str());
            printer->newLine();
        }
    }
    
    bool optimize = false;
    if ((preName == "sys_Func_")) {
        optimize = true;
    }
    
    std::string name;
    for (int i=0; i<type->methods.size(); ++i) {
        FMethod *method = &type->methods[i];
        
        if ((type->meta.flags & FFlags::Native)==0
            && (method->flags & FFlags::Native)==0) {
            continue;
        }
        if (!method->code.isEmpty()) {
            continue;
        }
        if (method->flags & FFlags::Abstract) {
            continue;
        }
        
        std::string &methodName = pod->names[method->name];
        if (!optimize && (type->meta.flags & FFlags::Native) != 0 && ((method->flags & FFlags::Native)==0)) {
            if (!method->code.isEmpty() && methodName != "static$init" && methodName != "instance$init$") {
                continue;
            }
        }
        
        name = preName + method->c_stdName;// preName + methodName;
//        if ((method->flags & FFlags::Setter) || (method->flags & FFlags::Overload)) {
//            name += "$";
//            name += std::to_string(method->paramCount);
//        }
        
        std::string escapeName = method->c_mangledName;
        //escape(escapeName);
        //escapeKeyword(escapeName);
        
        const char *valFlag = "";
        if ((method->flags & FFlags::Static) == 0) {
            if (type->c_mangledName == "sys_Int" ||
                type->c_mangledName == "sys_Float" ||
                type->c_mangledName == "sys_Bool"||
                type->c_mangledName == "sys_Ptr")
            valFlag = "_val";
        }
        
        //--------------------------------
        //get return type
        std::string retTypeName;
        std::string retTagName;
        std::string retVtName;
        bool retNullable = false;
        fr_ValueType rtVType = fr_vtObj;
        bool isVoid = false;
        rtVType = podMgr->getExactValueType(pod, method->returnType, retNullable, &isVoid);
        if (!retNullable) {
            getValueTypeName(rtVType, retTypeName, retTagName, retVtName);
        } else {
            getValueTypeName(fr_vtObj, retTypeName, retTagName, retVtName);
        }
        
        if (printType == PrintType::pRegisterDef) {
            printer->println("void %s_v(fr_Env env, void *param, void *ret);", escapeName.c_str());
        }
        else if (printType == PrintType::pRegisterCode) {
            printer->println("fr_registerMethod(vm, \"%s\", %s_v);", name.c_str(), escapeName.c_str());
        }
        else if (printType == PrintType::pNatiAll) {
            
            //--------------------------------
            // get arg method
            printer->println("void %s_v(fr_Env env, void *param, void *ret) {", escapeName.c_str());
            printer->indent();
            genNativeMethod(pod, type, method, printer, PrintType::pNatiLocalDecl);
            
            if (!isVoid) {
                printer->println("fr_Value retValue;");
            }
            
            printer->newLine();
            genNativeMethod(pod, type, method, printer, PrintType::pNatiArgGet);
            
            printer->newLine();
            
            //--------------------------------
            // gen method call
            if (!isVoid) {
                printer->printf("retValue.%s = ", retTagName.c_str());
            }
            printer->printf("%s%s(env", escapeName.c_str(), valFlag);
            genNativeMethod(pod, type, method, printer, PrintType::pNatiArgPass);
            printer->println(");");
            if (!isVoid) {
                //printer->println("retValue.type = %s;", retVtName.c_str());
                printer->println("*((fr_Value*)ret) = retValue;");
            }
            
            printer->unindent();
            printer->println("}");
            printer->newLine();
            
        } else if (printType == PrintType::pImpeDef) {
            //--------------------------------
            // method declare
            if (!isVoid) {
                printer->printf("%s", retTypeName.c_str());
            } else {
                printer->printf("void");
            }
            printer->printf(" %s%s(fr_Env env", escapeName.c_str(), valFlag);
            genNativeMethod(pod, type, method, printer, PrintType::pImpeDef);
            printer->println(");");
            
        } else if (printType == PrintType::pImpeStub) {
            //--------------------------------
            // method stub
            if (!isVoid) {
                printer->printf("%s", retTypeName.c_str());
            } else {
                printer->printf("void");
            }
            printer->printf(" %s%s(fr_Env env", escapeName.c_str(), valFlag);
            genNativeMethod(pod, type, method, printer, PrintType::pImpeDef);
            printer->println(") {");
            printer->indent();
            if (!isVoid) {
                printer->println("return 0;");
            } else {
                printer->println("return;");
            }
            printer->unindent();
            printer->println("}");
        }
    }
}

static bool hasNative(FType *type) {
    if ((type->meta.flags & FFlags::Native) != 0) return true;
    for (int i=0; i<type->methods.size(); ++i) {
        FMethod *method = &type->methods[i];
        if ((method->flags & FFlags::Native) != 0) {
            return true;
        }
    }
    return false;
}

void NativeGen::genNativePod(std::string &path, FPod *pod, Printer *printer, PrintType printType) {
    
    for (int i=0; i<pod->types.size(); ++i) {
        FType *type = &pod->types[i];
        if (!hasNative(type)) {
            continue;
        }
        
        FTypeRef &typeRef = pod->typeRefs[type->meta.self];
        std::string &podName = pod->names[typeRef.podName];
        std::string &typeName = pod->names[typeRef.typeName];
        std::string preName = podName + "_" + typeName + "_";
        
        if (typeName == "Libc") continue;
        
        if (printType != PrintType::pImpeStub) {
            genNativeType(pod, type, preName, printer, printType);
        }
        else {
            std::string file = path + podName + "_" + typeName + ".c";
            Printer typePrinter(file.c_str());
            typePrinter.println("#include \"vm.h\"");
            typePrinter.println("#include \"pod_%s_struct.h\"", podName.c_str());
            typePrinter.println("#include \"pod_%s_native.h\"", podName.c_str());
            typePrinter.newLine();
            genNativeType(pod, type, preName, &typePrinter, printType);
        }
    }
}

void NativeGen::genNative(std::string path, std::string podName, PodManager *podMgr) {
    this->podMgr = podMgr;
    FPod *pod = podMgr->findPod(podName);
    if (!pod) {
        return;
    }
    
    //---------------------------register
    std::string initFile = path + "pod_" + podName + "_register.c";
    Printer printer(initFile.c_str());
    
    printer.println("#include \"vm.h\"");
    printer.newLine();
    genNativePod(path, pod, &printer, PrintType::pRegisterDef);
    
    printer.println("");
    
    printer.println("void %s_register(fr_Fvm vm) {", podName.c_str());
    printer.indent();
    genNativePod(path, pod, &printer, PrintType::pRegisterCode);
    printer.unindent();
    printer.println("}");
    
    //---------------------------struct
    if (genStub) {
        std::string initFile0 = path + "pod_" + podName + "_struct.h";
        Printer printer0(initFile0.c_str());
        
        printer0.println("#include \"vm.h\"");
        printer0.println("CF_BEGIN");
        printer0.newLine();
        
        //gen methods implements
        genNativePod(path, pod, &printer0, PrintType::pStruct);
        printer0.newLine();
        printer0.println("CF_END");
    }
    //---------------------------header file
    std::string initFile1 = path + "pod_" + podName + "_native.h";
    Printer printer1(initFile1.c_str());
    
    printer1.println("#include \"vm.h\"");
    printer1.println("CF_BEGIN");
    printer1.newLine();
    
    //gen methods implements
    genNativePod(path, pod, &printer1, PrintType::pImpeDef);
    printer1.newLine();
    printer1.println("CF_END");
    
    //---------------------------native
    std::string initFile2 = path + "pod_" + podName + "_native.c";
    Printer printer2(initFile2.c_str());
    printer2.println("#include \"pod_%s_native.h\"", podName.c_str());
    printer2.println("#include \"pod_%s_struct.h\"", podName.c_str());
    printer2.newLine();
    
    //gen methods implements
    genNativePod(path, pod, &printer2, PrintType::pNatiAll);
    
    //---------------------------stub
    if (genStub) {
        genNativePod(path, pod, nullptr, PrintType::pImpeStub);
    }
}
