//
//  Interpreter.cpp
//  vm
//
//  Created by yangjiandong on 15/9/26.
//  Copyright (c) 2015, yangjiandong. All rights reserved.
//

#include "Env.h"
#include <assert.h>
#include "Interpreter.h"
#include "Gc.h"
#include <atomic>

Env::Env(Fvm *vm)
    : vm(vm)
    , error(nullptr)
    , thread(nullptr)
    , trace(false)
    , curFrame(nullptr)
    , blockingFrame(nullptr)
{
    isStoped = (false);
    //needStop = (false);
    Interpreter *interpreter = new Interpreter();
    interpreter->context = this;
    this->interpreter = interpreter;
    
    podManager = vm->podManager;
    //mtx_init(&mutex, mtx_recursive);
    stackMemSize = 1024 * 1024;
    stackBottom = (char*)malloc(stackMemSize);
    stackTop = stackBottom;
    stackMemEnd = ((char*)stackBottom) + stackMemSize;
}

Env::~Env() {
    //mtx_destroy(&mutex);
    free(stackBottom);
    stackBottom = nullptr;
    delete interpreter;
    interpreter = nullptr;
}

void Env::start(const char* podName, const char* type, const char* name, FObj *args) {
    //pushFrame(nullptr, nullptr);
    FMethod *method = findMethod(podName, type, name);
    
    fr_TagValue val;
    val.type = fr_vtObj;
    val.any.o = args;
    if (method->paramCount == 1) {
        push(&val);
    }
    else if (method->paramCount > 1) {
        printf("ERROR:start method arg error\n");
        return;
    }
    
    callNonVirtual(method, method->paramCount);
    
    FObj * err = getError();
    if (err) {
        printError(err);
    }
    
    //popFrame();
}

void printValue(fr_TagValue *val) {
    switch (val->type) {
        case fr_vtBool:
            printf(val->any.b ? "true" : "false");
            break;
        case fr_vtInt:
            printf("%lld", val->any.i);
            break;
        case fr_vtFloat:
            printf("%g", val->any.f);
            break;
        case fr_vtObj:
            if (val->any.o) {
                printf("%s(%p)", fr_getTypeName(NULL, val->any.o), val->any.o);
            } else {
                printf("null");
            }
            break;
        default:
            printf("other:%p", val->any.o);
            break;
    }
}

void Env::printOperandStack() {
    fr_TagValue *val;
    if (curFrame == nullptr) {
        val = (fr_TagValue *)stackBottom;
    }
    else {
        val = (fr_TagValue*)(((char*)(curFrame+1)) + curFrame->paddingSize);
        val = val + curFrame->method->localCount;
    }
    
    printf("operand[");
    while (val < (fr_TagValue *)stackTop) {
        printValue(val);
        printf(", ");
        ++val;
    }
    printf("]");
}

static void printParam(fr_TagValue *paramEnd, int count) {
    printf("param[");
    while (count != 0) {
        fr_TagValue *val = paramEnd - count;
        printValue(val);
        printf(", ");
        --count;
    }
    printf("]");
}

bool Env::popFrame() {
    if (curFrame == nullptr) {
        return false;
    }
    
    StackFrame *nextFrame = curFrame;
    curFrame = curFrame->preFrame;
    
    stackTop = (char*)nextFrame;
    
    this->popAll(nextFrame->paramCount);
    
    if (this->trace) {
        //int frameSize = sizeof(StackFrame) + (curFrame->localCount * sizeof(fr_TagValue));
        FMethod *method = nextFrame->method;
        std::string &name = method->c_parent->c_pod->names[method->name];
        std::string &typeName = method->c_parent->c_name;
        printf("<<<<<<<<< end %s#%s ", typeName.c_str(), name.c_str());
        printf("\n");
    }
    return true;
}

////////////////////////////
// Param
////////////////////////////

void Env::push(fr_TagValue *val) {
    if ((char*)stackTop >= stackMemEnd) {
        printf("ERROR: out of stack\n");
        abort();
        return;
    }
#ifndef NODEBUG
    if (val->type == fr_vtObj) {
        if (!vm->gc->isRef(val->any.o)) {
            abort();
        }
    }
#endif
    *((fr_TagValue*)stackTop) = *val;
    stackTop = (char*)(((fr_TagValue*)stackTop) + 1);
}
bool Env::pop(fr_TagValue *val) {
    if (stackTop - stackBottom <= 0) {
        printf("WARN: pop empty statck\n");
        abort();
        return false;
    }
    stackTop = (char*)(((fr_TagValue*)stackTop) - 1);
    if (val) {
        *val = *((fr_TagValue*)stackTop);
    }
#ifndef NODEBUG
    if (val->type == fr_vtObj) {
        if (!vm->gc->isRef(val->any.o)) {
            abort();
        }
    }
#endif
    return true;
}

bool Env::popAll(int count) {
    stackTop = (char*)(((fr_TagValue*)stackTop) - count);
    if (stackTop < stackBottom) {
        stackTop = stackBottom;
        return false;
    }
    return true;
}

fr_TagValue *Env::peek(int pos) {
    return ((fr_TagValue*)stackTop) + pos;
}

void Env::insertBack(fr_TagValue *entry, int count) {
    fr_TagValue *pos = (((fr_TagValue*)stackTop) - count);
    if (pos < (fr_TagValue*)stackBottom) pos = 0;
    memmove(pos+1, pos, sizeof(fr_TagValue)*count);
    *pos = *entry;
    stackTop = (char*)(((fr_TagValue*)stackTop) + 1);
}

////////////////////////////
// GC
////////////////////////////

void Env::checkSafePoint() {
    if (vm->gc->isStopTheWorld()) {
        isStoped = true;
        while (vm->gc->isStopTheWorld()) {
            System_sleep(5);
        }
        isStoped = false;
    }
    //mtx_lock(&mutex);
}

fr_Obj Env::newLocalRef(FObj * obj) {
//    assert(curFrame->isNative);
//    if (curFrame->nativeVarCount >= curFrame->localCount) {
//        int asize = 32 * sizeof(fr_TagValue);
//        curFrame->operandStack.expandFrameSize(asize);
//        curFrame->localCount += 32;
//    }
//    curFrame->locals[curFrame->nativeVarCount].type = fr_vtObj;
//    curFrame->locals[curFrame->nativeVarCount].any.o = obj;
//    curFrame->nativeVarCount++;
//    fr_Obj fobj = (fr_Obj)(&curFrame->locals[curFrame->nativeVarCount-1].any.o);
//    return fobj;
    fr_TagValue val;
    val.type = fr_vtObj;
    val.any.o = obj;
    this->push(&val);
    fr_TagValue *v = peek();
    fr_Obj fobj = (fr_Obj)(&v->any.o);
    return fobj;
}

void Env::deleteLocalRef(fr_Obj objRef) {
    FObj **obj = reinterpret_cast<FObj**>(objRef);
    *obj = NULL;
}

fr_Obj Env::newGlobalRef(FObj * obj) {
    return vm->newGlobalRef(obj);
}

void Env::deleteGlobalRef(fr_Obj obj) {
    vm->deleteGlobalRef(obj);
}

FObj * Env::allocObj(FType *type, int addRef, int size) {
    return podManager->objFactory.allocObj(this, type, addRef);
}

void Env::walkLocalRoot(Collector *gc) {
    StackFrame *frame;
    for (frame = curFrame; frame != nullptr; frame = frame->preFrame) {
        fr_TagValue *val = (fr_TagValue*)(((char*)(frame+1)) + frame->paddingSize);
        for (; val<(fr_TagValue*)stackTop; ++val) {
            if (val->type == fr_vtObj && val->any.o) {
                gc->onVisit((FObj*)val->any.o);
            }
        }
    }
    
    if (getError()) {
        gc->onVisit(getError());
    }
    if (thread) {
        gc->onVisit(thread);
    }
}

void Env::gc() {
    vm->gc->collect();
}

////////////////////////////
// other
////////////////////////////

FObj * Env::box(fr_Value &value, fr_ValueType vtype) {
    return podManager->objFactory.box(this, value, vtype);
}
bool Env::unbox(FObj * obj, fr_Value &value){
    return podManager->objFactory.unbox(this, obj, value);
}

////////////////////////////
// type
////////////////////////////

FType * Env::findType(std::string pod, std::string type) {
    FType *ftype = podManager->findType(this, pod, type);
    return ftype;
}

FType * Env::toType(fr_ValueType vt) {
    FType *ftype = podManager->getSysType(this, vt);
    return ftype;
}
FType * Env::getInstanceType(fr_TagValue *obj) {
    FType *ftype = podManager->getInstanceType(this, *obj);
    return ftype;
}
bool Env::fitType(FType * a, FType * b) {
    return podManager->fitTypeByType(this, (FType*)a, (FType*)b);
}

////////////////////////////
// call
////////////////////////////

void Env::call(FMethod *method, int paramCount/*without self*/) {
    assert(method);
    //assert(curFrame->operandStack.size() >= paramCount);
    
    if (trace) {
//        if (method->c_mangledName == "sys_Obj_echo") {
//            printf("");
//        }
        printf("before call:");
        printOperandStack();
        printf("\n");
    }
    
//    if (getError()) {
//        return;
//    }
    
    int paramCountWithSelf = method->paramCount;
    bool isStatic = (method->flags & FFlags::Static) != 0;
    if (!isStatic) {
        paramCountWithSelf++;
    }
 
    //push frame
    StackFrame *frameInfo = (StackFrame*)(stackTop);
    frameInfo->method = method;
    //frameInfo->paramDefault = paramDefault;
    frameInfo->preFrame = curFrame;
    frameInfo->paddingSize = 0;
    frameInfo->paramCount = paramCountWithSelf;
    curFrame = frameInfo;
    stackTop = (char*)((StackFrame*)(stackTop) + 1);
    
    //print opstack info
    if (trace) {
        std::string &name = method->c_parent->c_pod->names[method->name];
        std::string &typeName = method->c_parent->c_name;
        printf(">>>>>>>>>call %s#%s,native%d, ", typeName.c_str(), name.c_str(), method->c_native?1:0);
        printParam((fr_TagValue*)curFrame, paramCountWithSelf);
        printStackTrace();
        printf("\n");
    }
    
    //call native
    if (method->c_native) {
        fr_Value ret;
        fr_TagValue *param = ((fr_TagValue*)curFrame) - paramCountWithSelf;
        method->c_native(this, param, &ret);
        
        //context->lock();
        
        this->popFrame();
        
        FPod *curPod = method->c_parent->c_pod;
        FType *reType = this->podManager->getType(this
                                                     , curPod, method->returnType);
        if (!this->podManager->isVoidType(this, reType)) {
            fr_TagValue val;
            val.any = ret;
            val.type = this->podManager->getValueType(this
                                                    , curPod, method->returnType);
            if (val.type == fr_vtObj) {
                val.any.o = fr_getPtr(this, ret.h);
            }
            this->push(&val);
        }
        
        this->checkSafePoint();
        //context->unlock();
    }
    else {
        bool isNative = (method->flags & FFlags::Native) || (method->c_parent->meta.flags & FFlags::Native);
        if (!method->code.isEmpty()) {
            isNative = false;
        }
        if (isNative) {
            std::string &name = method->c_parent->c_pod->names[method->name];
            std::string &typeName = method->c_parent->c_name;
            printf("ERROR: not found native method %s#%s\n", typeName.c_str(), name.c_str());
            this->popFrame();
            return;
        }
        
        if (this->vm->executeEngine) {
            this->vm->executeEngine->run(this);
        } else {
            interpreter->run(this);
            if (getError()) {
                this->popFrame();
            } else {
                FPod *curPod = method->c_parent->c_pod;
                FType *reType = this->podManager->getType(this
                                                          , curPod, method->returnType);
                if (!this->podManager->isVoidType(this, reType)) {
                    fr_TagValue entry;
                    this->pop(&entry);
                    this->popFrame();
                    this->push(&entry);
                } else {
                    this->popFrame();
                }
            }
        }
    }
    
    if (trace) {
        printf("end call:");
        printOperandStack();
        printStackTrace();
        printf("\n");
    }
}

FMethod * Env::findMethod(const char *pod, const char *type, const char *name) {
    return podManager->findMethod(this, pod, type, name, -1);
}
void Env::callNonVirtual(FMethod * method, int paramCount) {
    call(method, paramCount);
}
void Env::newObj(FType *type, FMethod * method, int paramCount) {
    FObj * obj = allocObj(type, 1);
    
    fr_TagValue self;
    self.type = fr_vtObj;
    self.any.o = obj;
    insertBack(&self, paramCount);
    
    callVirtual(method, paramCount);
    
    push(&self);
}
void Env::callVirtual(FMethod * method, int paramCount) {
    fr_TagValue *entry = peek(-paramCount-1);
    FType *type = this->podManager->getInstanceType(this, *entry);
    method = podManager->toVirtualMethod(this, type, method);
    call(method, paramCount);
}

void Env::callVirtualByName(const char *name, int paramCount) {
    FMethod *method = nullptr;
    fr_TagValue *entry = peek(-paramCount-1);
    FType *type = this->podManager->getInstanceType(this, *entry);
    method = this->podManager->findVirtualMethod(this, type, name, paramCount);
    
    call(method, paramCount);
}

void Env::newObjByName(const char * pod, const char * type, const char * name, int paramCount) {
    FMethod *method = nullptr;
    method = podManager->findMethod(this, pod, type, name, paramCount);
    FObj * obj = allocObj(method->c_parent, 1);

    fr_TagValue self;
    self.type = fr_vtObj;
    self.any.o = obj;
    insertBack(&self, paramCount);

    call(method, paramCount);

    push(&self);
}


void Env::setStaticField(FField *field, fr_Value *val) {
    if (!field) {
        return;
    }
    if (field->flags & FFlags::Static) {
        fr_Value *sfield = podManager->getStaticFieldValue(field);
        fr_ValueType vtype = podManager->getValueType(this, field->c_parent->c_pod, field->type);
        //assert(vtype == val->type);
        if (vtype == fr_vtObj) {
//            if (!vm->gc.isRef(val->o)) {
//                abort();
//            }
            *sfield = *val;
            
            if (sfield->o) {
                //gc_setDirty(sfield->o, 1);
                vm->gc->setDirty(sfield->o);
            }
        } else {
            *sfield = *val;
        }
    }
}

bool Env::getStaticField(FField *field, fr_Value *val) {
    if (!field) {
        val->o = nullptr;
        //val->type = fr_vtObj;
        return false;
    }
    if (field->flags & FFlags::Static) {
        fr_Value *sfield = podManager->getStaticFieldValue(field);
        //fr_ValueType vtype = podManager->getValueType(this, field->c_parent->c_pod, field->type);
        *val = *sfield;
        //val->type = vtype;
        return true;
    }
    val->o = nullptr;
    //val->type = fr_vtObj;
    return false;
}

void Env::setInstanceField(fr_Value &bottom, FField *field, fr_Value *val) {
    if ((field->flags & FFlags::Static)==0) {
        fr_Value *sfield = podManager->getInstanceFieldValue(bottom.o, field);
        fr_ValueType vtype = podManager->getValueType(this, field->c_parent->c_pod, field->type);
        //assert(vtype == val->type);
        
        if (vtype == fr_vtObj) {
            *sfield = *val;
            if (sfield->o) {
                //gc_setDirty(sfield->o, 1);
                vm->gc->setDirty(sfield->o);
            }
        } else {
            *sfield = *val;
        }
    }
}
bool Env::getInstanceField(fr_Value &bottom, FField *field, fr_Value *val) {
    if ((field->flags & FFlags::Static)==0) {
        fr_Value *sfield = podManager->getInstanceFieldValue(bottom.o, field);
        //fr_ValueType vtype = podManager->getValueType(this, field->c_parent->c_pod, field->type);
        *val = *sfield;
        //val->type = vtype;
        return true;
    }
    val->o = nullptr;
    //val->type = fr_vtObj;
    return false;
}

////////////////////////////
// exception
////////////////////////////

FObj * Env::getError() {
    return error;
}

void Env::stackTrace(char *buf, int size, const char *delimiter) {
    StackFrame *frame = curFrame;
    while (frame != nullptr) {
        std::string &name = frame->method->c_parent->c_pod->names[frame->method->name];
        std::string &typeName = frame->method->c_parent->c_name;
        buf += snprintf(buf, size, "%s#%s%s", typeName.c_str(), name.c_str(), delimiter);
        frame = frame->preFrame;
    }
}

void Env::printStackTrace() {
    char buf[1024] = {0};
    stackTrace(buf, 1024, "<-");
    printf("stackTrace:(%s)", buf);
}

void Env::throwError(FObj * err) {
    //addGlobal(err);
    error = err;
}

void Env::printError(FObj * err) {
    FType *ftype = fr_getFType(this, err);
    std::string &name = ftype->c_name;
    printf("error: %s\n", name.c_str());
    //TODO call Err.trace
    
    FMethod *method = podManager->findMethodInType(this, ftype, "trace", 0);
    fr_TagValue val;
    val.any.o = err;
    val.type = fr_vtObj;
    push(&val);
    callVirtual(method, 0);
    pop(&val);
}

void Env::throwNPE() {
    FObj * str = podManager->objFactory.newString(this, "null pointer");
    fr_TagValue entry;
    entry.any.o = str;
    entry.type = fr_vtObj;
    this->push(&entry);
    entry.any.o = 0;
    this->push(&entry);
    
    FType *type = podManager->getNpeType(this);
    FMethod *ctor = type->c_methodMap["make"];
    newObj(type, ctor, 2);
    fr_TagValue error = *peek();
    throwError(error.any.o);
}

void Env::throwNew(const char* podName, const char* typeName, const char* msg, int addRef) {
    
    FObj * str = podManager->objFactory.newString(this, msg);
    fr_TagValue entry;
    entry.any.o = str;
    entry.type = fr_vtObj;
    this->push(&entry);
    entry.any.o = 0;
    this->push(&entry);
    
    newObjByName(podName, typeName, "make", 2);
    fr_TagValue error = *peek();
    throwError(error.any.o);
}

void Env::clearError() {
    //removeGlobal(error);
    error = NULL;
}

fr_Array* Env::arrayNew(FType *elemType, size_t elemSize, size_t size) {
    fr_Type arrayType = findType("sys", "Array");
    
    size_t allocSize = sizeof(fr_Array)+(elemSize*(size+1));
    fr_Array *a = (fr_Array*)allocObj(arrayType, 2, (int)allocSize);
    a->elemType = elemType;
    a->elemSize = (int32_t)elemSize;
    a->valueType = podManager->getValueTypeByType(this, elemType);
    
    a->size = size;
    return a;
}

void Env::arrayGet(fr_Array *array, size_t index, fr_Value *val) {
    if (index >= array->size) {
        throwNew("sys", "IndexErr", "out index", 2);
        return;
    }
    //val->h = fr_toHandle(self, a->data[index]);
    
    size_t elemSize = array->elemSize;
    if (array->valueType == fr_vtInt) {
        switch (elemSize) {
            case 1: {
                int8_t *t = (int8_t*)array->data;
                val->i = t[index];
                break;
            }
            case 2: {
                int16_t *t = (int16_t*)array->data;
                val->i = t[index];
                //resVal.type = fr_vtInt;
                break;
            }
            case 4: {
                int32_t *t = (int32_t*)array->data;
                val->i = *t;
                //resVal.type = fr_vtInt;
                break;
            }
            case 8: {
                int64_t *t = (int64_t*)array->data;
                val->i = *t;
                //resVal.type = fr_vtInt;
                break;
            }
        }
    }
}
void Env::arraySet(fr_Array *array, size_t index, fr_Value *val) {
    if (index >= array->size) {
        throwNew("sys", "IndexErr", "out index", 2);
        return;
    }
    //a->data[index] = fr_getPtr(self, val->h);
    
    size_t elemSize = array->elemSize;
    if (array->valueType == fr_vtInt) {
        switch (elemSize) {
            case 1: {
                int8_t *t = (int8_t*)array->data;
                t[index] = val->i;
                break;
            }
            case 2: {
                int16_t *t = (int16_t*)array->data;
                t[index] = val->i;
                break;
            }
            case 4: {
                int32_t *t = (int32_t*)array->data;
                t[index] = (int32_t)val->i;
                break;
            }
            case 8: {
                int64_t *t = (int64_t*)array->data;
                t[index] = val->i;
                break;
            }
        }
    }
}
