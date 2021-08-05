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
#include "gc/Gc.h"
#include <atomic>
#include "vm.h"
#include "sys_runtime.h"

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
        //must clear error before printError.
        clearError();
        fr_printError_(this, err);
    }
    
    //popFrame();
}

static const char* getFObjTypeName(FObj* o) {
    if (o == 0) {
        return "";
    }
    FType* type = (FType*)gc_getType(fr_toGcObj(o));
    return type->c_mangledName.c_str();
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
                printf("%s(%p)", getFObjTypeName((FObj*)val->any.o), val->any.o);
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
        if (val->any.o != NULL && !vm->gc->isRef(fr_toGcObj((FObj*)val->any.o))) {
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
        if (val->any.o != NULL && !vm->gc->isRef(fr_toGcObj((FObj*)val->any.o))) {
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
        do {
            System_sleep(1);
        } while (vm->gc->isStopTheWorld());
        isStoped = false;
    }
    //mtx_lock(&mutex);
}

fr_Obj Env::newLocalRef(FObj * obj) {

    fr_TagValue val;
    val.type = fr_vtObj;
    val.any.o = obj;
    this->push(&val);
    fr_TagValue *v = peek();
    fr_Obj fobj = (fr_Obj)(&v->any.o);
    return fobj;
}

void Env::deleteLocalRef(fr_Obj objRef) {
    //TODO reuse
    FObj **obj = reinterpret_cast<FObj**>(objRef);
    *obj = NULL;
}

fr_Obj Env::newGlobalRef(FObj * obj) {
    return vm->newGlobalRef(obj);
}

void Env::deleteGlobalRef(fr_Obj obj) {
    vm->deleteGlobalRef(obj);
}

void Env::walkLocalRoot(Collector *gc) {
    StackFrame *frame;
    for (frame = curFrame; frame != nullptr; frame = frame->preFrame) {
        fr_TagValue *val = (fr_TagValue*)(((char*)(frame+1)) + frame->paddingSize);
        for (; val<(fr_TagValue*)stackTop; ++val) {
            if (val->type == fr_vtObj && val->any.o) {
                gc->onVisit(fr_toGcObj((FObj*)val->any.o));
            }
        }
    }
    
    if (getError()) {
        gc->onVisit(fr_toGcObj(getError()));
    }
    if (thread) {
        gc->onVisit(fr_toGcObj(thread));
    }
}

////////////////////////////
// type
////////////////////////////

FType * Env::findType(const char* pod, const char* type) {
    FType *ftype = podManager->findType(this, pod, type);
    return ftype;
}

FType* Env::toType(fr_ValueType vt) {
    FType* ftype = podManager->getSysType(this, vt);
    return ftype;
}

////////////////////////////
// call
////////////////////////////

void Env::call(FMethod *method, int paramCount/*without self*/) {
    assert(method);
    //assert(curFrame->operandStack.size() >= paramCount);
    if (method->paramCount != paramCount) {
        printf("ERROR: %s paramCount %d != %d\n", method->c_mangledName.c_str() ,method->paramCount, paramCount);
        abort();
    }
    
    if (trace) {
        printf("before call:");
        printOperandStack();
        printf("\n");

        if (method->c_mangledName == "std_PodList_addPod") {
            printf("XX");
        }

        if (method->c_mangledName == "std_MapEntryList_setByKey") {
            printf("XX");
        }
    }
    
//    if (getError()) {
//        return;
//    }
    
    int paramCountWithSelf = method->paramCount;
    bool isStatic = (method->flags & FFlags::Static) != 0;
    if (!isStatic) {
        paramCountWithSelf++;
    }

    //unbox for value type: Bool.toStr
    if (!isStatic && podManager->isPrimitiveType(this, method->c_parent)) {
        fr_TagValue *entry;
        int pos = -method->paramCount - 1;
        entry = this->peek(pos);
        if (entry->type == fr_vtObj) {
            fr_ValueType vt = fr_unbox_(this, (FObj*)entry->any.o, entry->any);
            entry->type = vt;
        }
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
        printf(">>>>>>>>>call %s#%s,isNative:%d, ", typeName.c_str(), name.c_str(), method->c_native?1:0);
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
                val.any.o = fr_getPtr((fr_Env)this, ret.h);
            }
            this->push(&val);
        }
        
        this->checkSafePoint();
        //context->unlock();
    }
    else {
        bool isNative = (method->flags & FFlags::Native) || (method->c_parent->c_isNative);
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
    FObj * obj = fr_allocObj_(this, type, 0);
    
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
    FObj * obj = fr_allocObj_(this, method->c_parent, 0);

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
                vm->gc->setDirty(fr_toGcObj((FObj*)sfield->o));
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

void Env::setInstanceField(FObj *obj, FField *field, fr_Value *val) {
    if ((field->flags & FFlags::Static)==0) {
        fr_Value *sfield = podManager->getInstanceFieldValue(obj, field);
        fr_ValueType vtype = podManager->getValueType(this, field->c_parent->c_pod, field->type);
        //assert(vtype == val->type);
        
        if (vtype == fr_vtObj) {
            *sfield = *val;
            if (sfield->o) {
                //gc_setDirty(sfield->o, 1);
                vm->gc->setDirty(fr_toGcObj((FObj*)sfield->o));
            }
        } else {
            *sfield = *val;
        }
    }
}
bool Env::getInstanceField(FObj* obj, FField *field, fr_Value *val) {
    if ((field->flags & FFlags::Static)==0) {
        fr_Value *sfield = podManager->getInstanceFieldValue(obj, field);
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

void Env::throwNPE() {
    FObj* npe = fr_makeNPE_(this);
    throwError(npe);
}

void Env::clearError() {
    //removeGlobal(error);
    error = NULL;
}
