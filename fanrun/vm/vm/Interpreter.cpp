//
//  Interpreter.cpp
//  vm
//
//  Created by yangjiandong on 15/9/26.
//  Copyright (c) 2015, yangjiandong. All rights reserved.
//

#include "Interpreter.h"
#include <assert.h>
#include "Env.h"

#define F_STR_BUF_SIZE 256


struct InterStackFrame : public StackFrame {
    friend Interpreter;
private:
    unsigned char*code;
    int codeLen;
    int pc;
    
    FErrTable *_errTable;
    bool errTableInited;
    
    FPod *curPod;
    
    fr_TagValue *locals;
    fr_TagValue *param;
};

bool Interpreter::run(Env *env) {
    StackFrame *frame = context->curFrame;
    int localCount = 0;
    int maxStack = 16;
    FMethod *method = frame->method;
    
    if (method) {
        localCount = method->localCount;
        maxStack = method->maxStack;
    }
    frame->paddingSize = sizeof(InterStackFrame) - sizeof(StackFrame);
    
    int frameSize = frame->paddingSize + (localCount * sizeof(fr_TagValue));
    int expaedSize = frameSize + (maxStack * sizeof(fr_TagValue)) + 128;
    if (context->stackTop + expaedSize > context->stackMemEnd) {
        printf("ERROR: out of stack\n");
        return false;
    }
    context->stackTop = context->stackTop + frameSize;
    
    InterStackFrame *iframe = (InterStackFrame*)frame;
    
    iframe->locals = ((fr_TagValue*)(iframe+1));
    fr_TagValue *param = ((fr_TagValue*)frame) - frame->paramCount;
    iframe->param = param;
    
    iframe->_errTable = nullptr;
    iframe->errTableInited = false;
    
    if (method) {
        iframe->curPod = method->c_parent->c_pod;
    } else {
        iframe->curPod = nullptr;
    }
    
    iframe->code = frame->method->code.data;
    iframe->codeLen = frame->method->code.len;
    
    //init local vars
    this->initVars();

    this->runCode();
    return true;
}

void Interpreter::initVars() {
    FMethod *method = frame()->method;
    fr_TagValue *locals = frame()->locals;
    
    //set local vars
    for (int i=method->paramCount,vCount=method->paramCount + method->localCount
         ; i<vCount; ++i) {
        FMethodVar &var = method->vars[i];
        int j = i - method->paramCount;
        locals[j].any.i = 0;
        fr_ValueType vtype = context->podManager->getValueType(context
                                                , frame()->curPod, var.type);
        locals[j].type = vtype;
    }
}

FErrTable *Interpreter::getErrTable() {
    if (frame()->errTableInited) {
        return frame()->_errTable;
    }
    frame()->errTableInited = true;
    
    FMethod *method = frame()->method;
    
    FErrTable *attr = nullptr;
    for (int i=0; i<method->attrs.size(); ++i) {
        attr = dynamic_cast<FErrTable*>(method->attrs[i]);
        if (attr) {
            break;
        }
    }
    frame()->_errTable = attr;
    return frame()->_errTable;
}

bool Interpreter::exception() {
    
    FErrTable *errTable = getErrTable();
    if (!errTable) {
        return false;
    }
    
    FObj * err = context->getError();
    if (err == nullptr) {
        return true;
    }
    
    int pos = frame()->pc;
    for (size_t j=0,n=errTable->traps.size(); j<n; ++j) {
        FTrap &trap = errTable->traps[j];
        if (trap.start <= pos && trap.end > pos) {
            fr_TagValue val;
            val.type = fr_vtObj;
            val.any.o = err;
            FType *type = context->podManager->getInstanceType(context, val);
            bool fit = context->podManager->fitType(context
                                    , type, frame()->curPod, trap.type);
            if (fit) {
                frame()->pc = trap.handler;
                //frame()->code->seek(frame()->pc);
                pushObj(err);
                context->clearError();
                return true;
            }
        }
    }

    return false;
}

void Interpreter::runCode() {
    frame()->pc = 0;
    //frame()->code->seek(0);
    do {
        if (frame()->pc >= frame()->codeLen) {
            break;
        }
        if (!exeStep()) {
            break;
        }
    } while (true);
}

bool Interpreter::exeStep() {
    Buffer code(frame()->code, frame()->codeLen, false);
    code._seek(frame()->pc);

    FOp opcode = (FOp)code.readUInt8();
    
    if (context->trace) {
        const char *opName = OpNames[(int)opcode];
        int pc = frame()->pc;
        printf("%d:%s\n", pc, opName);
    }
    
    int16_t i1 = 0;
    int16_t i2 = 0;
    FOpArg arg = OpArgList[(int)opcode];
    
    switch (arg)
    {
        case FOpArg::None:
            break;
        case FOpArg::Int:
            i1 = code.readUInt16();
            break;
        case FOpArg::Float:
            i1 = code.readUInt16();
            break;
        case FOpArg::Str:
            i1 = code.readUInt16();
            break;
        case FOpArg::Duration:
            i1 = code.readUInt16();
            break;
        case FOpArg::Uri:
            i1 = code.readUInt16();
            break;
        case FOpArg::Register:
            i1 = code.readUInt16();
            break;
        case FOpArg::TypeRef:
            i1 = code.readUInt16();
            break;
        case FOpArg::FieldRef:
            i1 = code.readUInt16();
            break;
        case FOpArg::MethodRef:
            i1 = code.readUInt16();
            break;
        case FOpArg::JumpA:
            i1 = code.readUInt16();
            break;
        case FOpArg::TypePair:
            i1 = code.readUInt16();
            i2 = code.readUInt16();
            break;
        default:
            break;
    }
    
    switch (opcode)
    {
        case FOp::Nop:
            break;
        case FOp::LoadNull: {
            //operandStack.pushNull();
            fr_TagValue entry;
            memset(&entry.any, 0, sizeof(fr_TagValue));
            entry.type = fr_vtObj;
            context->push(&entry);
            break;
        }
        case FOp::LoadFalse: {
            //operandStack.pushBool(false);
            fr_TagValue entry;
            entry.any.b = false;
            entry.type = fr_vtBool;
            context->push(&entry);
            break;
        }
        case FOp::LoadTrue: {
            //operandStack.pushBool(true);
            fr_TagValue entry;
            entry.any.b = true;
            entry.type = fr_vtBool;
            context->push(&entry);
            break;
        }
        case FOp::LoadInt: {
            fr_Int i = frame()->curPod->constantas.ints[i1];
            //operandStack.pushInt(i);
            fr_TagValue entry;
            entry.any.i = i;
            entry.type = fr_vtInt;
            context->push(&entry);
            break;
        }
        case FOp::LoadFloat: {
            double f = frame()->curPod->constantas.reals[i1];
            //operandStack.pushFloat(i);
            fr_TagValue entry;
            entry.any.f = f;
            entry.type = fr_vtFloat;
            context->push(&entry);
            break;
        }
        case FOp::LoadDecimal: {
            double i = frame()->curPod->constantas.reals[i1];
            //operandStack.pushFloat(i);
            //TODO
            break;
        }
        case FOp::LoadStr: {
            FObj * obj = context->podManager->objFactory.getString(context
                                                        , frame()->curPod, i1);
            //addLocalRef(obj);
            //operandStack.pushObj(obj);
            fr_TagValue entry;
            entry.any.o = obj;
            entry.type = fr_vtObj;
            context->push(&entry);
            break;
        }
        case FOp::LoadDuration: {
            //TODO
            break;
        }
        case FOp::LoadUri: {
            //TODO
            break;
        }
        case FOp::LoadType: {
            FType *type = context->podManager->getType(context, frame()->curPod, i1);
//          FObj * wtype = context->podManager->getWrappedType(context, type);
            //operandStack.pushObj(wtype);
            
            fr_TagValue entry;
            entry.any.p = type;
            entry.type = fr_vtOther;
            context->push(&entry);
            break;
        }
        case FOp::LoadVar: {
            fr_TagValue *entry;
            if (i1 >= frame()->paramCount) {
                entry = frame()->locals + i1 - frame()->paramCount;
            } else {
                entry = frame()->param + i1;
            }
            context->push(entry);
            break;
        }
        case FOp::StoreVar: {
            fr_TagValue val;
            context->pop(&val);
            fr_TagValue *entry;
            if (i1 >= frame()->paramCount) {
                entry = frame()->locals + i1 - frame()->paramCount;
            } else {
                entry = frame()->param + i1;
            }
            *entry = val;
            break;
        }
        case FOp::LoadInstance: {
            fr_TagValue val;
            context->pop(&val);
            FField *f = context->podManager->getField(context, frame()->curPod, i1);
            
            context->getInstanceField((FObj*)val.any.o, f, &val.any);
            val.type = context->podManager->getValueType(context, frame()->curPod, f->type);
            context->push(&val);
            break;
        }
        case FOp::StoreInstance: {
            fr_TagValue var;
            context->pop(&var);
            fr_TagValue obj;
            context->pop(&obj);
            
            FField *f = context->podManager->getField(context, frame()->curPod, i1);
            context->setInstanceField((FObj*)obj.any.o, f, &var.any);
            break;
        }
        case FOp::LoadStatic:
        case FOp::LoadMixinStatic: {
            FField *f = context->podManager->getField(context, frame()->curPod, i1);
            fr_TagValue val;
            context->getStaticField(f, &val.any);
            val.type = context->podManager->getValueType(context, frame()->curPod, f->type);
            context->push(&val);
            break;
        }
        case FOp::StoreStatic:
        case FOp::StoreMixinStatic:{
            FField *f = context->podManager->getField(context, frame()->curPod, i1);
            fr_TagValue var;
            context->pop(&var);
            context->setStaticField(f, &var.any);
            break;
        }
        // route method calls to FMethodRef
        case FOp::CallNew:
            callNew(i1);
            break;
        case FOp::CallCtor:
            callMethod(i1, false);
            break;
        case FOp::CallStatic:
            callMethod(i1, false);
            break;
        case FOp::CallMixinStatic:
            callMethod(i1, false);
            break;
        case FOp::CallVirtual:
            callMethod(i1, true);
            break;
        case FOp::CallMixinVirtual:
            callMethod(i1, true);
            break;
        case FOp::CallNonVirtual:
            callMethod(i1, false);
            break;
        case FOp::CallSuper:
            callMethod(i1, false);
            break;
        case FOp::CallMixinNonVirtual:
            callMethod(i1, false);
            break;
            
        case FOp::Jump: {
            if (frame()->pc > i1) {
                context->checkSafePoint();
            }
            frame()->pc = i1;
            goto Step_jump;
            break;
        }
        case FOp::JumpTrue:{
            if (frame()->pc > i1) {
                context->checkSafePoint();
            }
            bool b = popBool();
            
            if (b) {
                frame()->pc = i1;
                goto Step_jump;
            }
            break;
        }
        case FOp::JumpFalse:{
            if (frame()->pc > i1) {
                context->checkSafePoint();
            }
            bool b = popBool();

            if (!b) {
                frame()->pc = i1;
                goto Step_jump;
            }
            break;
        }
        case FOp::CompareEQ: {
            compareEq(i1, i2, false);
            break;
        }
        case FOp::CompareNE:{
            compareEq(i1, i2, true);
            break;
        }
        case FOp::Compare:{
            compare(i1, i2, nullptr);
            break;
        }
        case FOp::CompareLT:{
            fr_Int i;
            compare(i1, i2, &i);
            pushBool(i < 0);
            break;
        }
        case FOp::CompareLE:{
            fr_Int i;
            compare(i1, i2, &i);
            pushBool(i <= 0);
            break;
        }
        case FOp::CompareGE:{
            fr_Int i;
            compare(i1, i2, &i);
            pushBool(i >= 0);
            break;
        }
        case FOp::CompareGT:{
            fr_Int i;
            compare(i1, i2, &i);
            pushBool(i > 0);
            break;
        }
        case FOp::CompareSame:{
            bool same = compareSame();
            pushBool(same);
            break;
        }
        case FOp::CompareNotSame:{
            bool same = compareSame();
            pushBool(!same);
            break;
        }
        case FOp::CompareNull:{
            bool isNull = compareNull();
            pushBool(isNull);
            break;
        }
        case FOp::CompareNotNull:{
            bool isNull = compareNull();
            pushBool(!isNull);
            break;
        }
        case FOp::Return: {
            goto Step_return;
            break;
        }
        case FOp::Pop: {
            fr_TagValue entry;
            context->pop(&entry);
            break;
        }
        case FOp::Dup: {
            fr_TagValue entry;
            entry = *context->peek();
            context->push(&entry);
            break;
        }
        case FOp::Is: {
            bool fit = isTypeof(i1, true);
            pushBool(fit);
            break;
        }
        case FOp::As: {
            fr_TagValue entry;
            bool fit = isTypeof(i1, false);
            if (!fit) {
                context->pop(&entry);
                pushObj(nullptr);
            }
            break;
        }
        case FOp::Coerce: {
            std::string msg;
            bool fit = isTypeof(i2, false, &msg);
            if (!fit) {
                fr_TagValue val = *context->peek();
                if (val.type == fr_vtObj && val.any.o == NULL) {

                    bool toNullable = context->podManager->isNullableType(context
                        , frame()->curPod, i2);
                    if (toNullable) {
                        break;
                    }
                    else {
                        context->throwNew("sys", "CastErr", msg.c_str(), 1);
                        goto Step_throw;
                        break;
                    }
                }
            }
            bool fromNullable = context->podManager->isNullableType(context
                                                    , frame()->curPod, i1);
            bool toNullable = context->podManager->isNullableType(context
                                                    , frame()->curPod, i2);
            //TODO
            if (fromNullable && !toNullable) {
                fr_TagValue entry;
                entry = *context->peek();
                
                if (entry.type == fr_vtObj && entry.any.o == nullptr) {
                    context->throwNew("sys", "NullErr", "", 1);
                    goto Step_throw;
                }
            }
            
            bool fromPrimitive = context->podManager->isPrimitiveType(context
                                                    , frame()->curPod, i1);
            bool toPrimitive = context->podManager->isPrimitiveType(context
                                                , frame()->curPod, i2);
            if (fromPrimitive && !toPrimitive) {
                fr_TagValue *entry;
                entry = context->peek();
                entry->any.o = context->box(entry->any, entry->type);
                entry->type = fr_vtObj;
            } else if (!fromPrimitive && toPrimitive) {
                fr_TagValue *entry;
                entry = context->peek();
                //fr_ValueType vtype = context->podManager->getValueType(context, curPod, i2);
                fr_Value out;
                context->unbox((FObj*)entry->any.o, out);
                entry->any = out;
                entry->type = context->podManager->getValueType(context
                                                        , frame()->curPod, i2);
            }
            break;
        }
        case FOp::Switch: {
            uint16_t count = code.readUInt16();
            uint16_t *table = (uint16_t*)malloc(sizeof(uint16_t)*count);
            for (int i=0; i<count; ++i) {
                table[i] = code.readUInt16();
            }
            fr_Int i = popInt();
            
            frame()->pc = table[i];
            goto Step_jump;
            break;
        }
        case FOp::Throw: {
            fr_TagValue val;
            val = *context->peek();
            context->throwError((FObj*)val.any.o);
            goto Step_throw;
            break;
        }
        case FOp::Leave: {
            frame()->pc = i1;
            goto Step_jump;
            break;
        }
        case FOp::_JumpFinally:{
            frame()->pc = i1;
            goto Step_jump;
            break;
        }
        case FOp::CatchAllStart: {
            FObj * obj;
            fr_TagValue entry;
            bool rc = context->pop(&entry);
            assert(rc);
            assert(entry.type == fr_vtObj);
            obj = (FObj*)entry.any.o;
            break;
        }
        case FOp::CatchErrStart: {
            break;
        }
        case FOp::_CatchEnd:
            break;
            
        case FOp::FinallyStart:
            break;
            
        case FOp::FinallyEnd:
            break;
        case FOp::LoadFieldLiteral:
            //TODO
            break;
        case FOp::LoadMethodLiteral:
            //TODO
            break;
        default:
            break;
    }
    
    if (context->getError()) {
        goto Step_throw;
    }

Step_next:
    frame()->pc = (int)code.getPos();
    return true;
    
Step_jump:
    code.seek(frame()->pc);
    return true;
    
Step_return:
    return false;
    
Step_throw:
    if (!exception()) {
        return false;
    }
    return true;
}

void Interpreter::compareEq(int16_t t1, int16_t t2, bool notEq) {
    fr_TagValue p1;
    fr_TagValue p2;
    context->pop(&p2);
    context->pop(&p1);
    bool ret = false;
    
    bool isPrimitive1 = context->podManager->isPrimitiveType(context, frame()->curPod, t1);
    bool isPrimitive2 = context->podManager->isPrimitiveType(context, frame()->curPod, t2);
    if (isPrimitive1 && isPrimitive2) {
        ret = p1.any.o == p2.any.o;
    }
    else if (isPrimitive1) {
        fr_Value any;
        if (p2.any.o != nullptr) {
            context->unbox((FObj*)p2.any.o, any);
            ret = p1.any.o == any.o;
        }
    }
    else if (isPrimitive2) {
        fr_Value any;
        if (p1.any.o != nullptr) {
            context->unbox((FObj*)p1.any.o, any);
            ret = p2.any.o == any.o;
        }
    }
    else {
        context->push(&p1);
        context->push(&p2);
        context->callVirtualByName("equals", 1);
        if (notEq) {
            fr_TagValue entry;
            bool rc = context->pop(&entry);
            assert(rc);
            assert(entry.type == fr_vtBool);
            bool b = entry.any.b;
            
            entry.any.b = !b;
            context->push(&entry);
//            operandStack.popBool(ret);
//            operandStack.pushBool(!ret);
        }
        return;
    }
    
    if (notEq) {
        ret = !ret;
    }
    pushBool(ret);
}

void Interpreter::compare(int16_t t1, int16_t t2, fr_Int *ret) {
    fr_TagValue p1;
    fr_TagValue p2;
    context->pop(&p2);
    context->pop(&p1);
    
    fr_Int res = 0;
    bool isPrimitive1 = context->podManager->isPrimitiveType(context, frame()->curPod, t1);
    bool isPrimitive2 = context->podManager->isPrimitiveType(context, frame()->curPod, t2);
    if (isPrimitive1 && isPrimitive2) {
        res = (char*)p1.any.o - (char*)p2.any.o;
    }
    else if (isPrimitive1) {
        fr_Value any;
        if (p2.any.o != nullptr) {
            context->unbox((FObj*)p2.any.o, any);
            res = (char*)p1.any.o - (char*)any.o;
        } else {
            res = 1;
        }
    }
    else if (isPrimitive2) {
        fr_Value any;
        if (p1.any.o != nullptr) {
            context->unbox((FObj*)p1.any.o, any);
            res = (char*)any.o - (char*)p2.any.o;
        } else {
            res = -1;
        }
    }
    else {
        context->push(&p1);
        context->push(&p2);
        context->callVirtualByName("compare", 1);
        if (ret) {
            res = popInt();
        }
        return;
    }

    if (ret) {
        *ret = res;
    } else {
        fr_TagValue entry;
        entry.any.i = res;
        entry.type = fr_vtInt;
        context->push(&entry);
    }
}

bool Interpreter::compareSame() {
    fr_TagValue p1;
    fr_TagValue p2;
    context->pop(&p2);
    context->pop(&p1);
    
    if (p1.type != p2.type) {
        return false;
    }
    else if (p1.type == fr_vtObj) {
        return (p1.any.o == p2.any.o);
    }
    else {
        return (p1.any.i == p2.any.i);
    }
}

bool Interpreter::compareNull() {
    fr_TagValue p1;
    context->pop(&p1);
    
    if (p1.type == fr_vtObj && p1.any.o == NULL) {
        return true;
    } else {
        return false;
    }
}

bool Interpreter::isTypeof(uint16_t tid, bool pop, std::string *msg) {
    fr_TagValue val;
    if (pop) {
        context->pop(&val);
    } else {
        val = *context->peek();
    }
    if (val.type == fr_vtObj && val.any.o == NULL) {
        return false;
    }
    FType *type = context->podManager->getInstanceType(context, val);
    bool fit = context->podManager->fitType(context, type, frame()->curPod, tid);
    
    if (!fit && msg) {
        char buf[256];
        buf[0] = 0;
        FType *toType = context->podManager->getType(context, frame()->curPod, tid);
        snprintf(buf, 256, "cast %s to %s", type->c_name.c_str(), toType->c_name.c_str());
        *msg = buf;
    }
    return fit;
}

void Interpreter::callNew(int16_t mid) {
    FMethod *method = nullptr;
    FMethodRef &methodRef = frame()->curPod->methodRefs[mid];
    int paramCount = methodRef.paramCount;
    
    method = context->podManager->getMethod(context, frame()->curPod, methodRef);
    
    
    if (method->c_parent->c_mangledName == "sys_Array") {
        FTypeRef &typeRef = frame()->curPod->typeRefs[methodRef.parent];
        std::string extName = typeRef.extName.substr(1, typeRef.extName.size()-2);
        
        FType *elemType = NULL;
        size_t elemSize = sizeof(void*);
        fr_ValueType valueType;
        elemType = context->podManager->findElemType(context, extName, &elemSize, &valueType);
        
        fr_Array *a = context->arrayNew(elemType, elemSize, popInt());
        pushObj((FObj*)a);
        return;
    }

    FObj * obj = context->allocObj(method->c_parent, 1);
    
    fr_TagValue self;
    self.type = fr_vtObj;
    self.any.o = obj;
    context->insertBack(&self, paramCount);
    
    context->call(method, paramCount);
    
    pushObj(obj);
}

void Interpreter::callMethod(int16_t mid, bool isVirtual) {
    FMethod *method = nullptr;
    FMethodRef &methodRef = frame()->curPod->methodRefs[mid];
    int paramCount = methodRef.paramCount;
    if (isVirtual) {
        fr_TagValue entry;
        //method = context->podManager->getMethod(context, frame()->curPod, mid, &paramCount);
        
        int pos = -paramCount-1;
        entry = *context->peek(pos);
        FType *type = context->podManager->getInstanceType(context, entry);
        //bool isSetter = method->flags & FFlags::Setter;
        method = context->podManager->getVirtualMethod(context, type, frame()->curPod, &methodRef);
    } else {
        method = context->podManager->getMethod(context, frame()->curPod, methodRef);
    }
    
    
    if (method->c_parent->c_mangledName == "sys_Array") {
        
        if (method->c_mangledName == "sys_Array_get") {
            size_t index = popInt();
            fr_TagValue entry;
            context->pop(&entry);
            fr_Array *array = (fr_Array*)entry.any.o;
            fr_TagValue retVal;
            context->arrayGet(array, index, &retVal.any);
            retVal.type = (fr_ValueType)array->valueType;
            context->push(&retVal);
            return;
        }
        else if (method->c_mangledName == "sys_Array_set") {
            fr_TagValue val;
            context->pop(&val);
            size_t index = popInt();
            fr_TagValue entry;
            context->pop(&entry);
            fr_Array *array = (fr_Array*)entry.any.o;
            context->arraySet(array, index, &val.any);
            return;
        }
        else if (method->c_mangledName == "sys_Array_size") {
            fr_TagValue entry;
            context->pop(&entry);
            fr_Array *array = (fr_Array*)entry.any.o;
            fr_TagValue retVal;
            retVal.type = fr_vtInt;
            retVal.any.i = array->size;
            context->push(&retVal);
            return;
        }
    }
    else if (method->c_parent->c_mangledName == "sys_Ptr") {
        if (method->c_mangledName == "sys_Ptr_get") {
            FTypeRef &typeRef = frame()->curPod->typeRefs[methodRef.parent];
            std::string extName = typeRef.extName.substr(1, typeRef.extName.size()-2);
            
            FType *elemType = NULL;
            size_t elemSize = sizeof(void*);
            fr_ValueType valueType;
            elemType = context->podManager->findElemType(context, extName, &elemSize, &valueType);
            
            size_t index = popInt();
            fr_TagValue entry;
            context->pop(&entry);
            
            fr_TagValue resVal;
            if (valueType == fr_vtInt) {
                switch (elemSize) {
                    case 1: {
                        int8_t *t = (int8_t*)entry.any.p;
                        resVal.any.i = t[index];
                        resVal.type = fr_vtInt;
                        break;
                    }
                    case 2: {
                        int16_t *t = (int16_t*)entry.any.p;
                        resVal.any.i = t[index];
                        resVal.type = fr_vtInt;
                        break;
                    }
                    case 4: {
                        int32_t *t = (int32_t*)entry.any.p;
                        resVal.any.i = *t;
                        resVal.type = fr_vtInt;
                        break;
                    }
                    case 8: {
                        int64_t *t = (int64_t*)entry.any.p;
                        resVal.any.i = *t;
                        resVal.type = fr_vtInt;
                        break;
                    }
                }
            }
            context->push(&resVal);
            return;
        }
        else if (method->c_mangledName == "sys_Ptr_set") {
            FTypeRef &typeRef = frame()->curPod->typeRefs[methodRef.parent];
            std::string extName = typeRef.extName.substr(1, typeRef.extName.size()-2);
            
            FType *elemType = NULL;
            size_t elemSize = sizeof(void*);
            fr_ValueType valueType;
            elemType = context->podManager->findElemType(context, extName, &elemSize, &valueType);
            
            fr_TagValue val;
            context->pop(&val);
            
            size_t index = popInt();
            fr_TagValue entry;
            context->pop(&entry);
            
            if (valueType == fr_vtInt) {
                switch (elemSize) {
                    case 1: {
                        int8_t *t = (int8_t*)entry.any.p;
                        t[index] = val.any.i;
                        break;
                    }
                    case 2: {
                        int16_t *t = (int16_t*)entry.any.p;
                        t[index] = val.any.i;
                        break;
                    }
                    case 4: {
                        int32_t *t = (int32_t*)entry.any.p;
                        t[index] = (int32_t)val.any.i;
                        break;
                    }
                    case 8: {
                        int64_t *t = (int64_t*)entry.any.p;
                        t[index] = val.any.i;
                        break;
                    }
                }
            }
            return;
        }
    }
    
    context->call(method, paramCount);
}
