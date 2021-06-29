//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by yangjiandong on 16/9/10.
//

#include "Stmt.hpp"
#include "IRMethod.h"
#include "FCodeUtil.hpp"
#include "util/escape.h"

extern "C" {
#include "util/utf8.h"
}

TypeInfo::TypeInfo(const std::string &pod, const std::string &name, bool isValue, bool isBuildin, bool isNullable)
: pod(pod), name(name), isValue(isValue), isBuildin(isBuildin), isNullable(isNullable), typeRef(-1), isMixin(false), isPass(false) {
}

std::string TypeInfo::getName() const {
    std::string typeName = pod + "_" + name;
    if (isNullable) {
        typeName += "_null";
    }
    else if (isBuildin) {
        typeName += extName;
    }
    else if (isPass && isValue && !isBuildin && !isNullable) {
        typeName += "_pass";
    }
    escape(typeName);
    return typeName;
}

void TypeInfo::setFromTypeRef(FPod *curPod, uint16_t typeRefId) {
    FTypeRef &typeRef = curPod->typeRefs[typeRefId];
    pod = curPod->names[typeRef.podName];
    name = curPod->names[typeRef.typeName];
    
    extName = FCodeUtil::getExtTypeName(typeRef.extName);
    
    std::string::size_type pos = name.find("^");
    if (pos != std::string::npos) {
        std::string pname = name.substr(0, pos);
        std::string cname = name.substr(pos+1);
        curPod = curPod->c_loader->findPod(pod);
        auto itr = curPod->c_typeMap.find(pname);
        if (itr == curPod->c_typeMap.end()) {
            throw std::string("Unknow Type:")+name;
        }
        FType *ftype = itr->second;
        uint16_t ttid = ftype->findGenericParamBound(cname);
        setFromTypeRef(curPod, ttid);
        return;
    }
    
    isNullable = FCodeUtil::isNullableTypeRef(curPod, typeRefId);
    isValue = FCodeUtil::isValueTypeRef(curPod, typeRefId);
    isBuildin = FCodeUtil::isBuildinVal(pod+"_"+name);
    this->typeRef = typeRefId;
    
    FType *ftype = FCodeUtil::getFTypeFromTypeRef(curPod, typeRefId);
    if (ftype->meta.flags & FFlags::Mixin) {
        this->isMixin = true;
    }
}

TypeInfo TypeInfo::makeInt() {
    TypeInfo ty("sys", "Int", true, true, false);
    return ty;
}

TypeInfo TypeInfo::makeBool() {
    TypeInfo ty("sys", "Bool", true, true, false);
    return ty;
}

bool TypeInfo::isThis() {
    return pod == "sys" && name == "This";
}
bool TypeInfo::isVoid() {
    return pod == "sys" && name == "Void";
}

Expr Var::asRef() {
    if (block == NULL || index == -1) {
        printf("ERROR\n");
    }
    Expr expr;
    expr.index = index;
    expr.block = block;
    return expr;
}

void escapeStr(const std::string &from, std::string &str) {
    long pos = 0;
    while (pos < from.length()) {
        switch (from[pos]) {
            case 0x27:
                str += "\\'";
                break;
            case 0x22:
                str += "\\\"";
                break;
            case 0x3f:
                str += "\\?";
                break;
            case 0x5c:
                str += "\\\\";
                break;
            case 0x07:
                str += "\\a";
                break;
            case 0x08:
                str += "\\b";
                break;
            case 0x0c:
                str += "\\f";
                break;
            case 0x0a:
                str += "\\n";
                break;
            case 0x0d:
                str += "\\r";
                break;
            case 0x09:
                str += "\\t";
                break;
            case 0x0b:
                str += "\\v";
            default:
                str += from[pos];
        }
        ++pos;
    }
}

std::string Expr::getName(bool deRef) {
    Var &var = block->locals.at(index);
    std::string vname = var.name;
    if (deRef && var.type.isPass && var.type.isValue && !var.type.isBuildin && !var.type.isNullable) {
        vname = "(*" +vname+ ")";
    }
    return vname;
}

TypeInfo &Expr::getType() {
    Var &var = block->locals.at(index);
    return var.type;
}

std::string Expr::getTypeName() {
    return getType().getName();
}

bool Expr::isValueType() {
    return getType().isValue;
}

void ConstStmt::print(Printer& printer) {
//    printer.printf("%s = ", dst.getName().c_str());
//    printValue(dst.getName(), printer, curPod, opObj);
//    printer.printf(";");
//
    const std::string &varName = dst.getName();
    
    switch (opObj.opcode) {
        case FOp::LoadNull: {
            printer.printf("%s = NULL;", varName.c_str());
            break;
        }
        case FOp::LoadFalse: {
            printer.printf("%s = false;", varName.c_str());
            break;
        }
        case FOp::LoadTrue: {
            printer.printf("%s = true;", varName.c_str());
            break;
        }
        case FOp::LoadInt: {
            int64_t i = curPod->constantas.ints[opObj.i1];
            printer.printf("%s = %lldLL;", varName.c_str(), i);
            break;
        }
        case FOp::LoadFloat: {
            double i = curPod->constantas.reals[opObj.i1];
            printer.printf("%s = %g;", varName.c_str(), i);
            break;
        }
        case FOp::LoadDecimal: {
            const std::string &i = curPod->constantas.decimals[opObj.i1];
            printer.printf("%s = %s;", varName.c_str(), i.c_str());
            break;
        }
        case FOp::LoadStr: {
            const std::string &rawstr = curPod->constantas.strings[opObj.i1];
            std::string str;
            size_t len = rawstr.size();
            escapeStr(rawstr, str);
            
            
            printer.println("%s = (sys_Str)(%s_ConstPoolStrs[%d]);", varName.c_str(), curPod->name.c_str(), opObj.i1);
            printer.printf("if (%s == NULL) { %s_ConstPoolStrs[%d] = (sys_Str)fr_newStrUtf8(__env, \"%s\", %d);"
                           , varName.c_str(), curPod->name.c_str(), opObj.i1, str.c_str(), len);
            printer.printf("%s = (sys_Str)(%s_ConstPoolStrs[%d]); }", varName.c_str(), curPod->name.c_str(), opObj.i1);
            break;
        }
        case FOp::LoadDuration: {
            int64_t i = curPod->constantas.durations[opObj.i1];
            printer.printf("%s = std_Duration_fromTicks(__env, %lld);", varName.c_str(), i);
            break;
        }
        case FOp::LoadUri: {
            const std::string &rawstr = curPod->constantas.uris[opObj.i1];
            std::string str;
            size_t len = rawstr.size();
            escapeStr(rawstr, str);
            
            printer.println("%s = (std_Uri)(%s_ConstPoolUris[%d]);", varName.c_str(), curPod->name.c_str(), opObj.i1);
            printer.printf("if (%s == NULL) { std_Uri_fromStr__1(__env, (sys_Str)fr_newStrUtf8(__env, \"%s\", %d));"
                           , varName.c_str(), str.c_str(), len);
            printer.printf("%s = (std_Uri)(%s_ConstPoolUris[%d]); }", varName.c_str(), curPod->name.c_str(), opObj.i1);
            break;
        }
        case FOp::LoadType: {
            std::string typeName = FCodeUtil::getTypeNsName(curPod, opObj.i1);
            printer.printf("%s = FR_TYPE(%s);", varName.c_str(), typeName.c_str());
            break;
        }
        default: {
            printer.printf("//other");
            break;
        }
    }
}

TypeInfo ConstStmt::getType() {
    
    std::string pod = "sys";
    std::string name;
    bool isValue = false;
    bool isBuildIn = false;
    switch (opObj.opcode) {
        case FOp::LoadNull: {
            name = "Obj";
            break;
        }
        case FOp::LoadFalse: {
            name = "Bool";
            isValue = true;
            isBuildIn = true;
            break;
        }
        case FOp::LoadTrue: {
            name = "Bool";
            isValue = true;
            isBuildIn = true;
            break;
        }
        case FOp::LoadInt: {
            name = "Int";
            isValue = true;
            isBuildIn = true;
            break;
        }
        case FOp::LoadFloat: {
            name = "Float";
            isValue = true;
            isBuildIn = true;
            break;
        }
        case FOp::LoadDecimal: {
            name = "Decimal";
            isValue = true;
            break;
        }
        case FOp::LoadStr: {
            name = "Str";
            break;
        }
        case FOp::LoadDuration: {
            name = "Duration";
            pod = "std";
            isValue = true;
            break;
        }
        case FOp::LoadUri: {
            name = "Uri";
            pod = "std";
            isValue = true;
            break;
        }
        case FOp::LoadType: {
            name = "Type";
            pod = "std";
            break;
        }
        default: {
            name = "Obj";
            break;
        }
    }
    
    TypeInfo res(pod, name, isValue, isBuildIn, false);
    return res;
}

void StoreStmt::print(Printer& printer) {
    if (dst.getType().isValueType() && !src.getType().isValueType()) {
        printer.printf("%s = *(%s);", dst.getName().c_str(), src.getName().c_str());
    }
    else if (!dst.getType().isValueType() && src.getType().isValueType()) {
        printer.printf("%s = &(%s);", dst.getName().c_str(), src.getName().c_str());
    }
    else {
        printer.printf("%s = %s;", dst.getName().c_str(), src.getName().c_str());
    }
}

void CallStmt::print(Printer& printer) {
    if (!isStatic && !params.at(0).isValueType()) {
        if (typeName == "sys_Array" && mthName == "make") {
            //pass
        }
        else if (isCtor || params.at(0).getType().isNullable) {
            printer.printf("FR_CHECK_NULL(%d, %s);", this->pos, params.at(0).getName().c_str());
        }
    }
    
    if (typeName == "sys_Array") {
        if (mthName == "get") {
            printer.printf("%s = ((%s*)(%s->_val.data))[%s];", retValue.getName().c_str(), extName.c_str(),
                           params[0].getName().c_str(), params[1].getName().c_str());
            return;
        }
        else if (mthName == "set") {
            printer.printf("((%s*)(%s->_val.data))[%s] = %s;", extName.c_str(),
                           params[0].getName().c_str(), params[1].getName().c_str(), params[2].getName().c_str());
            return;
        }
        else if (mthName == "make") {
            int extType = -1;
            std::string elemType;
            if (extName == "sys_Int8") {
                elemType = "sys_Int";
                extType = 1;
            }
            else if (extName == "sys_Int16") {
                elemType = "sys_Int";
                extType = 2;
            }
            else if (extName == "sys_Int32") {
                elemType = "sys_Int";
                extType = 4;
            }
            else if (extName == "sys_Int" || extName == "sys_Int64") {
                elemType = "sys_Int";
                extType = 8;
            }
            else if (extName == "sys_Float" || extName == "sys_Float64") {
                elemType = "sys_Float";
                extType = 8;
            }
            else if (extName == "sys_Float32") {
                elemType = "sys_Float";
                extType = 4;
            }
            else {
                elemType = extName;
            }
            printer.printf("%s = (sys_Array)fr_arrayNew(__env, %s_class__, %d, %s);", params[0].getName().c_str(),
                           elemType.c_str(), extType, params[1].getName().c_str());
            return;
        }
    }
    else if (typeName == "sys_Ptr") {
        if (mthName == "get") {
            printer.printf("%s = ((%s*)(%s))[%s];", retValue.getName().c_str(), extName.c_str(),
                           params[0].getName().c_str(), params[1].getName().c_str());
            return;
        }
        else if (mthName == "set") {
            printer.printf("((%s*)(%s))[%s] = %s;", extName.c_str(),
                           params[0].getName().c_str(), params[1].getName().c_str(), params[2].getName().c_str());
            return;
        }
        else if (mthName == "make") {
            //printer.printf("");
        }
    }
    
    bool isFirstArg = false;
    bool isExternC = false;
    if (isStatic && isSimpleSym) {
        isFirstArg = true;
        isExternC = true;
        if (!isVoid) printer.printf("%s = ", retValue.getName().c_str());
        printer.printf("%s(", mthName.c_str());
    }
    else {
        std::string voidFlag;
        if (!isVoid) printer.printf("%s = (%s)", retValue.getName().c_str(), retValue.getTypeName().c_str());

        bool isValueType = false;
        if (!isStatic && params.at(0).isValueType()) {
            isValueType = true;
            printer.printf("FR_CALL(%s, %s_val", typeName.c_str(), mthName.c_str());
        }
        else if (isVirtual) {
            if (isMixin) {
                printer.printf("FR_ICALL(%s, %s", typeName.c_str(), mthName.c_str());
            }
            else {
                printer.printf("FR_VCALL(%s, %s", typeName.c_str(), mthName.c_str());
            }
        }
        else if (isStatic) {
            printer.printf("FR_SCALL(%s, %s", typeName.c_str(), mthName.c_str());
        }
        else {
            printer.printf("FR_CALL(%s, %s", typeName.c_str(), mthName.c_str());
        }
    }
    
    for (int i=0; i<params.size(); ++i) {
        if (!isFirstArg || i>0) printer.printf(", ");
        TypeInfo &typeInfo = params[i].getType();
        if (typeInfo.isValue && !typeInfo.isBuildin && !typeInfo.isNullable) {
            if (typeInfo.isPass) {
                printer.printf("(%s)%s"
                               , typeInfo.getName().c_str(), params[i].getName().c_str());
            }
            else {
                printer.printf("(%s_pass)&%s"
                           , typeInfo.getName().c_str(), params[i].getName().c_str());
            }
            continue;
        }
        if (!isStatic && i == 0) {
            printer.printf("(%s)%s"
                           , typeName.c_str(), params[i].getName(true).c_str());
        }
        else if (isExternC && params[i].getTypeName() == "sys_Ptr") {
            std::string extName = FCodeUtil::getExtTypeName(params[i].getType().extName, true);
            printer.printf("(%s*)%s", extName.c_str(), params[i].getName(true).c_str());
        }
        else {
            printer.printf("%s", params[i].getName(true).c_str());
        }
    }
    printer.printf(");FR_CHECK_ERR(%d);", this->pos);
}

void FieldStmt::print(Printer& printer) {
    std::string parentName = FCodeUtil::getTypeDeclName(curPod, fieldRef->parent);
    std::string name = FCodeUtil::getIdentifierName(curPod, fieldRef->name);
    bool parentValueType = FCodeUtil::isValueTypeRef(curPod, fieldRef->parent);
    bool isValueType = FCodeUtil::isValueTypeRef(curPod, fieldRef->type);
    std::string typeName = FCodeUtil::getTypeDeclName(curPod, fieldRef->type);
    bool isBuildinType = FCodeUtil::isBuildinVal(typeName);
    
    if (!isStatic && !parentValueType) {
        printer.printf("FR_CHECK_NULL(%d, %s);", this->pos, instance.getName().c_str());
    }
    if (isLoad) {
        //lazy init class
        if (isStatic) {
//            FTypeRef &typeRef = curPod->typeRefs[fieldRef->parent];
//            const std::string &purName = curPod->names[typeRef.typeName];
            FType *ftype = FCodeUtil::getFTypeFromTypeRef(curPod, fieldRef->parent);
            
            auto itr = ftype->c_methodMap.find("static$init");
            if (itr != ftype->c_methodMap.end()) {
                printer.println("FR_STATIC_INIT(%s);", parentName.c_str());
            }
        }
        
        if (isValueType && !isBuildinType) {
            if (isStatic) {
                printer.printf("memcpy(&%s, &(%s_%s), sizeof(%s))", value.getName().c_str(),
                               parentName.c_str(), name.c_str(), typeName.c_str());
            }
            else if (parentValueType) {
                printer.printf("memcpy(&%s, &(%s.%s), sizeof(%s))", value.getName().c_str(),
                               instance.getName(true).c_str(), name.c_str(), typeName.c_str());
            }
            else {
                printer.printf("memcpy(&%s, &(((%s)(%s))->%s), sizeof(%s))", value.getName().c_str(),
                               parentName.c_str(), instance.getName(true).c_str(), name.c_str(), typeName.c_str());
            }
        }
        else {
            printer.printf("%s = ", value.getName().c_str());
            if (isStatic) {
                printer.printf("%s_%s", parentName.c_str(), name.c_str());
            }
            else if (parentValueType) {
                printer.printf("%s.%s", instance.getName(true).c_str(), name.c_str());
            }
            else {
                printer.printf("((%s)(%s))->%s", parentName.c_str(), instance.getName().c_str(), name.c_str());
            }
        }
    } else {
        
        if (isValueType && !isBuildinType) {
            if (isStatic) {
                printer.printf("memcpy(&(%s_%s), &%s, sizeof(%s))", parentName.c_str(), name.c_str(), value.getName().c_str(), typeName.c_str());
            }
            else if (parentValueType) {
                printer.printf("memcpy(&(%s.%s), &%s, sizeof(%s))",
                               instance.getName(true).c_str(), name.c_str(), value.getName().c_str(), typeName.c_str());
            }
            else {
                printer.printf("memcpy(&(((%s)%s)->%s), &%s, sizeof(%s))",
                               parentName.c_str(), instance.getName(true).c_str(), name.c_str(), value.getName().c_str(), typeName.c_str());
            }
        }
        else {
            if (isStatic) {
                printer.printf("%s_%s", parentName.c_str(), name.c_str());
            }
            else if (parentValueType) {
                printer.printf("%s.%s", instance.getName(true).c_str(), name.c_str());
            }
            else {
                printer.printf("((%s)%s)->%s", parentName.c_str(), instance.getName().c_str(), name.c_str());
            }
            printer.printf("= %s", value.getName().c_str());
        }
    }
    
    printer.printf(";");
    if (!isLoad && !isStatic && !isBuildinType) {
        printer.printf("FR_SET_DIRTY(%s);", instance.getName().c_str());
    }
}

void JumpStmt::print(Printer& printer) {
    switch (jmpType) {
        case trueJmp:{
            if (targetPos < selfPos) {
                printer.println("FR_CHECK_POINT();");
            }
            printer.printf("if (%s) goto ", expr.getName().c_str());
        }
            break;
        case falseJmp: {
            if (targetPos < selfPos) {
                printer.println("FR_CHECK_POINT();");
            }
            printer.printf("if (!%s) goto ", expr.getName().c_str());
        }
            break;
        case finallyJmp: {
            //printer.println("fr_clearErr(__env);");
            //printer.println("FR_LEAVE");
            printer.printf("goto ");
        }
            break;
        case leaveJmp : {
            //printer.println("FR_LEAVE");
            printer.printf("goto ");
        }
            break;
        default: {
            if (targetPos < selfPos) {
                printer.println("FR_CHECK_POINT();");
            }
            printer.printf("goto ");
        }
            break;
    }
    printer.printf("l__%d;", targetBlock->pos);
}

void AllocStmt::print(Printer& printer) {
    std::string typeName = FCodeUtil::getTypeNsName(curPod, type);
    if (typeName == "sys_Array") {
        //move to CallStmt
    }
    else if (FCodeUtil::isValueTypeRef(curPod, type)) {
        printer.printf("FR_INIT_VAL(%s, %s);", obj.getName().c_str(), typeName.c_str());
    } else {
        printer.printf("%s = FR_ALLOC(%s);", obj.getName().c_str(), typeName.c_str());
    }
}

void CompareStmt::print(Printer& printer) {
    int cmpType = 0;
    bool isVal1 = false;
    bool isVal2 = false;
    switch (opObj.opcode) {
        case FOp::CompareNull: {
            printer.printf("%s = %s == NULL;"
                           , result.getName().c_str(), param1.getName().c_str());
            return;
        }
        case FOp::CompareNotNull: {
            printer.printf("%s = %s != NULL;"
                           , result.getName().c_str(), param1.getName().c_str());
            return;
        }
        default:
            break;
    }
    
    if (opObj.i1 > 0 || opObj.i2 > 0) {
        isVal1 = TypeInfo(curPod, opObj.i1).isValueType();
        isVal2 = TypeInfo(curPod, opObj.i2).isValueType();
    }
    else {
        isVal1 = param1.getType().isValueType();
        isVal2 = param2.getType().isValueType();
    }
    
    const char *op = "==";
    switch (opObj.opcode) {
        case FOp::Compare: {
            op = "-";
            break;
        }
        case FOp::CompareEQ: {
            op = "==";
            break;
        }
        case FOp::CompareNE: {
            op = "!=";
            break;
        }
        case FOp::CompareLT: {
            op = "<";
            break;
        }
        case FOp::CompareLE: {
            op = "<=";
            break;
        }
        case FOp::CompareGE: {
            op = ">=";
            break;
        }
        case FOp::CompareGT: {
            op = ">";
            break;
        }
        case FOp::CompareSame: {
            op = "==";
            break;
        }
        case FOp::CompareNotSame: {
            op = "!=";
            break;
        }
        case FOp::CompareNull: {
            op = "==";
            break;
        }
        case FOp::CompareNotNull: {
            op = "!=";
            break;
        }
        default:
            printf("ERROR:unknow cmp opcode:%d", opObj.opcode);
    }
    
    //value type
    if (isVal1 && isVal2) {
        printer.printf("%s = %s %s %s;", result.getName().c_str()
                       , param1.getName().c_str(), op, param2.getName().c_str());
    }
    else if (!isVal1 && !isVal2) {
        cmpType = -1;
    }
    else {
        if (!isVal1) {
            printer.printf("if (%s == NULL) FR_THROW_NPE(%d);", param1.getName().c_str(), this->pos);
            printer.printf("if (!FR_TYPE_IS(%s, %s) )"
                           , param1.getName().c_str(), param2.getTypeName().c_str());
            if (opObj.opcode == FOp::Compare) {
                printer.printf("%s = -1;", result.getName().c_str());
            } else {
                printer.printf("%s = false;", result.getName().c_str());
            }
            
            printer.printf("else %s = FR_UNBOXING_VAL(%s, %s) %s %s;", result.getName().c_str()
                           , param1.getName().c_str(), param2.getTypeName().c_str()
                           , op, param2.getName().c_str());
        }
        else if (!isVal2) {
            printer.printf("if (%s == NULL) FR_THROW_NPE(%d);", param2.getName().c_str(), this->pos);
            printer.printf("if (!FR_TYPE_IS(%s, %s) )"
                           , param2.getName().c_str(), param1.getTypeName().c_str());
            if (opObj.opcode == FOp::Compare) {
                printer.printf("%s = -1;", result.getName().c_str());
            } else {
                printer.printf("%s = false;", result.getName().c_str());
            }
            
            printer.printf("else %s = %s %s FR_UNBOXING_VAL(%s, %s);", result.getName().c_str()
                           , param1.getName().c_str(), op
                           , param2.getName().c_str(), param1.getTypeName().c_str());
        }
    }
    
    //pointer object
    if (cmpType == -1) {
        switch (opObj.opcode) {
            case FOp::Compare: {
                printer.printf("%s = FR_VCALL(sys_Obj, compare, (sys_Obj)%s, (sys_Obj)%s);FR_CHECK_ERR(%d);"
                                , result.getName().c_str()
                                , param1.getName().c_str(), param2.getName().c_str()
                                , this->pos);
                break;
            }
            case FOp::CompareEQ: {
                printer.printf("%s = FR_VCALL(sys_Obj, equals, (sys_Obj)%s, (sys_Obj)%s);FR_CHECK_ERR(%d);"
                               , result.getName().c_str()
                               , param1.getName().c_str(), param2.getName().c_str()
                               , this->pos);
                break;
            }
            case FOp::CompareNE: {
                printer.printf("%s = !FR_VCALL(sys_Obj, equals, (sys_Obj)%s, (sys_Obj)%s); FR_CHECK_ERR(%d);"
                               , result.getName().c_str()
                               , param1.getName().c_str(), param2.getName().c_str()
                               , result.getName().c_str(), result.getName().c_str()
                               , this->pos);
                break;
            }
            case FOp::CompareLT: {
                printer.printf("{ %s = FR_VCALL(sys_Obj, compare, (sys_Obj)%s, (sys_Obj)%s) < 0; FR_CHECK_ERR(%d); }"
                               , result.getName().c_str()
                               , param1.getName().c_str(), param2.getName().c_str()
                               , this->pos);
                break;
            }
            case FOp::CompareLE: {
                printer.printf("{ %s = FR_VCALL(sys_Obj, compare, (sys_Obj)%s, (sys_Obj)%s) <= 0; FR_CHECK_ERR(%d); }"
                               , result.getName().c_str()
                               , param1.getName().c_str(), param2.getName().c_str()
                               , this->pos);
                break;
            }
            case FOp::CompareGE: {
                printer.printf("{ %s = FR_VCALL(sys_Obj, compare, (sys_Obj)%s, (sys_Obj)%s) >= 0; FR_CHECK_ERR(%d); }"
                               , result.getName().c_str()
                               , param1.getName().c_str(), param2.getName().c_str()
                               , this->pos);
                break;
            }
            case FOp::CompareGT: {
                printer.printf("{ %s = FR_VCALL(sys_Obj, compare, (sys_Obj)%s, (sys_Obj)%s) > 0; FR_CHECK_ERR(%d); }"
                               , result.getName().c_str()
                               , param1.getName().c_str(), param2.getName().c_str()
                               , this->pos);
                break;
            }
            case FOp::CompareSame: {
                printer.printf("%s = (sys_Obj)%s == (sys_Obj)%s;"
                               , result.getName().c_str()
                               , param1.getName().c_str(), param2.getName().c_str());
                break;
            }
            case FOp::CompareNotSame: {
                printer.printf("%s = (sys_Obj)%s != (sys_Obj)%s;"
                               , result.getName().c_str()
                               , param1.getName().c_str(), param2.getName().c_str());
                break;
            }
            default:
                printf("ERROR:unknow cmp opcode:%d", opObj.opcode);
        }
    }
}

void ReturnStmt::print(Printer& printer) {
    if (isVoid) {
        printer.printf("return;");
    } else {
        printer.printf("return %s;", retValue.getName(true).c_str());
    }
}

void ThrowStmt::print(Printer& printer) {
    printer.printf("FR_THROW(%d, %s);", this->pos, var.getName().c_str());
}

void ExceptionStmt::print(Printer& printer) {
    switch (etype) {
        case TryStart:
            printer.printf("FR_TRY {");
            break;
        case TryEnd: {
            printer.println("} FR_CATCH {");
            printer.indent();
            for (int i=0; i<handlerStmt.size(); ++i) {
                ExceptionStmt *itr = handlerStmt[i];
                if (itr->etype == CatchStart) {
//                    if (itr->catchType > 0) {
//                        std::string typeName = FCodeUtil::getTypeRefName(curPod, itr->catchType, false);
//                        printer.printf("if (FR_ERR_TYPE(%s)) { "
//                                       "%s = (%s)fr_getErr(__env); "
//                                       "fr_clearErr(__env); goto l__%d;}"
//                                ,typeName.c_str(), itr->catchVar.getName().c_str()
//                                , typeName.c_str(), handler);
//                    } else {
//                        printer.println("fr_clearErr(__env); goto l__%d;", handler);
//                    }
                }
                else if (itr->etype == FinallyStart) {
                    //printer.println("goto l__%d;//goto finally", handler);
                }
            }
            printer.unindent();
            printer.newLine();
            printer.println("}//ce");
        }
            break;
        case CatchStart:
            printer.println("//catch start");
            /*
            printer.println(";");
            if (catchType == -1) {
                printer.println("} catch(...) {");
            } else {
                std::string typeName = FCodeUtil::getTypeRefName(curPod, catchType, false);
                printer.printf("} catch(%s ", typeName.c_str());
                catchVar.print(method, printer, 0);
                printer.println(") {");
            }
             */
            if (catchType != -1) {
                printer.println("%s = (%s)__env->error;", catchVar.getName().c_str(), catchVar.getTypeName().c_str());
            }
            else {
                printer.println("__env->error = NULL;");
            }
            break;
        case CatchEnd:
            printer.println("//catch end");
            /*
            printer.println(";");
            printer.println("}//end catch");
             */
            break;
        case FinallyStart:
            printer.println("//finally start");
            /*
            printer.println("} catch(...) {");
             */
            break;
        case FinallyEnd:
            printer.println("//finally end");
            
            //printer.println("if (fr_getErr(__env)) { FR_THROW(fr_getErr(__env)); }");
            
            break;
        default:
            break;
    }
}

void CoerceStmt::print(Printer& printer) {
    std::string typeName1 = from.getTypeName();
    std::string typeName2 = to.getTypeName();
    
    if (typeName1 == typeName2) {
        printer.printf("%s = %s;", to.getName().c_str(), from.getName().c_str());
        return;
    }
    
    bool isVal1 = from.getType().isValueType();
    bool isVal2 = to.getType().isValueType();
    bool isNull1 = from.getType().isNullable;
    bool isNull2 = to.getType().isNullable;
    
    if (!isVal1 && !isVal2) {
        if (isNull1 && !isNull2) {
            printer.printf("FR_NOT_NULL(%d, %s, %s, %s);", this->pos, to.getName().c_str()
                           , from.getName().c_str(), typeName2.c_str());
            return;
        }
        else if (!isNull1 && isNull2) {
            if (from.getType().pod == to.getType().pod && from.getType().name == to.getType().name) {
                //no-null to null
                printer.printf("%s = (%s)(%s);", to.getName().c_str()
                    , typeName2.c_str(), from.getName().c_str());
                return;
            }
        }
    }
    else if (!isVal1 && isVal2) {
        if (FCodeUtil::isBuildinVal(to.getTypeName())) {
            printer.printf("%s = FR_UNBOXING_VAL(%s, %s);"
                           , to.getName().c_str(), from.getName().c_str(), typeName2.c_str());
        } else {
            printer.printf("FR_UNBOXING_STRUCT(%s, %s, %s);"
                       , to.getName().c_str(), from.getName().c_str(), typeName2.c_str());
        }
        return;
    }
    else if (isVal1 && !isVal2) {
        if (typeName1 == "sys_Int" || typeName1 == "sys_Int8" || typeName1 == "sys_Int16" || typeName1 == "sys_Int32" || typeName1 == "sys_Int64") {
            printer.printf("%s = (%s)FR_BOX_INT(%s);"
                           , to.getName().c_str(), typeName2.c_str(), from.getName().c_str());
        }
        else if (typeName1 == "sys_Float" || typeName1 == "sys_Float32" || typeName1 == "sys_Float64") {
            printer.printf("%s = (%s)FR_BOX_FLOAT(%s);"
                           , to.getName().c_str(), typeName2.c_str(), from.getName().c_str());
        }
        else if (typeName1 == "sys_Bool") {
            printer.printf("%s = (%s)FR_BOX_BOOL(%s);"
                           , to.getName().c_str(), typeName2.c_str(), from.getName().c_str());
        }
        else if (typeName1 == "sys_Ptr") {
            printer.printf("FR_BOXING_VAL(%s, %s, %s, %s);"
                , to.getName().c_str(), from.getName(true).c_str()
                , typeName1.c_str(), typeName2.c_str());
        }
        else {
            printer.printf("FR_BOXING_STRUCT(%s, %s, %s, %s);"
                           , to.getName().c_str(), from.getName(true).c_str()
                           , typeName1.c_str(), typeName2.c_str());
        }
        return;
    }
    
    //cast
    if (safe || (isVal1 && isVal2 && !isNull1 && !isNull2)) {
        printer.printf("%s = (%s)(%s);", to.getName().c_str()
                   , typeName2.c_str(), from.getName().c_str());
    } else {
        std::string toTypeName = FCodeUtil::getTypeNsName(curPod, toType);
        
        if (checked) {
            printer.printf("FR_CAST(%d, %s, %s, %s, %s);", this->pos, to.getName().c_str()
                       , from.getName().c_str() , toTypeName.c_str(), typeName2.c_str());
        } else {
            printer.printf("%s = FR_TYPE_AS(%s, %s);", to.getName().c_str()
                           , from.getName().c_str() , toTypeName.c_str());
        }
    }
}

void TypeCheckStmt::print(Printer& printer) {
    if (obj.getType().isValue) {
        bool isFit = FCodeUtil::isInheriteOf(obj.getType().pod, obj.getType().name, curPod, type);
        if (isFit) {
            if (FCodeUtil::isValueTypeRef(curPod, type)) {
                printer.printf("%s = %s;"
                               , result.getName().c_str(), obj.getName().c_str());
            }
            else {
                std::string typeName = FCodeUtil::getTypeNsName(curPod, type);
                printer.printf("FR_BOXING_STRUCT(%s, %s, %s, %s);"
                               , result.getName().c_str(), obj.getName().c_str()
                               , typeName.c_str(), result.getTypeName().c_str());
            }
        }
    } else {
        std::string typeName = FCodeUtil::getTypeNsName(curPod, type);
        printer.printf("%s = FR_TYPE_IS(%s, %s);"
                   , result.getName().c_str(), obj.getName().c_str(), typeName.c_str());
    }
}

void SwitchStmt::print(Printer& printer) {
    printer.println("switch (%s) {", var.getName().c_str());
    printer.indent();
    for (int i = 0; i < tableSize; ++i) {
        printer.println("  case %d: goto l__%d;", i, table[i]);
    }
    printer.unindent();
    printer.println("}");
}
