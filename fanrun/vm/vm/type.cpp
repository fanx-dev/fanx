#include "fcode/FPod.h"
#include "fni_private.h"
#include "Env.h"
#include "ir/FCodeUtil.hpp"

void convertFromFType(Env* env, FType* ftype, fr_Type type) {
    type->interfaceVTableIndex[0].type = NULL;
    type->interfaceVTableIndex[0].vtableOffset = 0;
    type->name = strdup((ftype->c_pod->name + "::" + ftype->c_name).c_str());
    type->flags = ftype->meta.flags;
    type->allocSize = ftype->c_allocSize;
    type->staticInited = false;

    if (ftype->meta.base != 0xFFFF) {
        FType* base = env->podManager->getType(env, ftype->c_pod, ftype->meta.base);
        type->base = fr_fromFType((fr_Env)env, base);
    }

    type->fieldCount = ftype->fields.size();
    type->fieldList = (struct fr_Field_*)malloc(sizeof(struct fr_Field_) * ftype->fields.size());
    for (int i = 0; i < ftype->fields.size(); ++i) {
        FField& field = ftype->fields[i];
        fr_Field f = type->fieldList+i;
        std::string fieldName = ftype->c_pod->names[field.name];
        f->name = strdup(fieldName.c_str());

        std::string typeName = FCodeUtil::getTypeRawName(ftype->c_pod, field.type);
        f->type = strdup(typeName.c_str());
        f->flags = field.flags;
        f->offset = field.c_offset;
        f->parent = type;

        bool isValType = FCodeUtil::isBuildinVal(typeName);
        f->isValType = isValType;
        f->isStatic = (field.flags & FFlags::Static) != 0;
        if (f->isStatic || (field.flags & FFlags::Storage) == 0) {
            f->offset = -1;
        }
        if (f->isStatic) {
            fr_Value* sfield = env->podManager->getStaticFieldValue(&field);
            f->pointer = sfield;
        }
        else {
            f->pointer = NULL;
        }
        f->internalSlot = &field;
        field.c_reflectSlot = f;
    }
    
    type->methodCount = ftype->methods.size();
    type->methodList = (struct fr_Method_*)malloc(sizeof(struct fr_Method_) * ftype->methods.size());
    for (int i = 0; i < ftype->methods.size(); ++i) {
        FMethod& method = ftype->methods[i];
        fr_Method f = type->methodList + i;
        std::string fieldName = ftype->c_pod->names[method.name];
        f->name = strdup(fieldName.c_str());

        std::string typeName = FCodeUtil::getTypeRawName(ftype->c_pod, method.returnType);
        f->retType = strdup(typeName.c_str());
        f->flags = method.flags;
        f->func = NULL;
        f->parent = type;
        f->paramsCount = method.paramCount;
        f->paramsList = (struct fr_MethodParam_*)malloc(sizeof(struct fr_MethodParam_) * method.paramCount);

        for (int j = 0; j < method.paramCount; ++j) {
            FMethodVar& var = method.vars[j];
            std::string name = ftype->c_pod->names[var.name];
            type->methodList[i].paramsList[j].name = strdup(name.c_str());
            std::string paramTypeName = FCodeUtil::getTypeRawName(ftype->c_pod, var.type);
            type->methodList[i].paramsList[j].type = strdup(paramTypeName.c_str());
            type->methodList[i].paramsList[j].flags = var.flags;
        }
        f->internalSlot = &method;
        method.c_reflectSlot = f;
    }
    type->internalType = ftype;
    ftype->c_reflectType = type;
}


fr_Type fr_fromFType(fr_Env env, FType* ftype) {
	if (ftype->c_reflectType == NULL) {
		fr_Type type = (fr_Type)calloc(1, sizeof(struct fr_Class_));
		convertFromFType((Env*)env, ftype, type);
	}
	return (fr_Type)ftype->c_reflectType;
}

