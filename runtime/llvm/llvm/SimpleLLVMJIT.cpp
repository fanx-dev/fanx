//
//  LLVMCodeGen.cpp
//  vm
//
//  Created by yangjiandong on 16/9/16.
//  Copyright © 2017 chunquedong. All rights reserved.
//

#include "SimpleLLVMJIT.hpp"
#include "Env.h"
#include "LLVMCodeGen.hpp"

SimpleLLVMJIT::SimpleLLVMJIT() : EE(nullptr) {
    init();
}
SimpleLLVMJIT::~SimpleLLVMJIT() {
    delete EE;
    llvm_shutdown();
}

void SimpleLLVMJIT::init() {
    InitializeNativeTarget();
    InitializeNativeTargetAsmPrinter();
}

std::unique_ptr<Module> SimpleLLVMJIT::gen(Env *env, FMethod *method
                                           , std::string &name, uint16_t &jitLocalCount) {
    printf("compile=========\n");
    FPod *curPod = method->c_parent->c_pod;
    //method->code.initOps();
    IRMethod com(curPod, method);
    //com.compile();
    
    //jitLocalCount = com.refLocalsCount;
    
    //Printer printer;
    //com.print(env->podManager, printer, 0);
    
    std::unique_ptr<Module> Owner = make_unique<Module>("test", Context);
    Module *M = Owner.get();
    
    LLVMCodeGen codeGen(Context, &com, name);
    Function *function = function = codeGen.gen(M);
    return std::move(Owner);
}

int32_t jit_callMethod(Env *env, FMethod *method, int32_t paramCount, int32_t type) {
    //StackFrame *frame = env->curFrame;
    //fr_Value *val = (fr_Value *)(frame+1);
    
    int argCount = paramCount;
    bool isStatic = (method->flags & FFlags::Static) != 0;
    if (!isStatic) {
        ++argCount;
    }
    
    std::vector<fr_TagValue> args;
    FPod *curPod = method->c_parent->c_pod;
    for (int i=0; i<argCount; ++i) {
        fr_Value v = ((fr_Value*)env->stackTop)[i];
        fr_TagValue tv;
        tv.any = v;
        if (!isStatic && i == 0) {
            tv.type = env->podManager->getValueTypeByType(env, method->c_parent);
        } else {
            tv.type = env->podManager->getValueType(env, curPod, method->vars[i].type);
        }
        args.push_back(tv);
    }
    
    for (fr_TagValue &v : args) {
        env->push(&v);
    }
    
    env->call(method, paramCount);
    
    printf("hi\n");
    return 0;
}

typedef void (*jitType)(void *env);

bool SimpleLLVMJIT::run(Env *env) {
    StackFrame *frame = env->curFrame;
    FMethod *method = frame->method;
    if (!method->c_jit) {
        
        std::string name = method->c_parent->c_pod->names[method->name];
        
        uint16_t jitLocalCount;
        std::unique_ptr<Module> Module = gen(env, method, name, jitLocalCount);
        
        outs() << "We just constructed this LLVM module:\n\n" << *Module.get();
        
        Function *callee = Module->getFunction("jit_callMethod");
        
        // Now we create the JIT.
        if (!EE) {
            EE = EngineBuilder(std::move(Module)).create();
        } else {
            EE->addModule(std::move(Module));
        }
        
        EE->addGlobalMapping(callee, (void*)jit_callMethod);

        method->c_jit = (jitType)EE->getFunctionAddress(name);
        method->c_jitLocalCount = jitLocalCount * sizeof(fr_Value);
    }
    
    int frameSize = (method->c_jitLocalCount);
    if (env->stackTop + frameSize > env->stackMemEnd) {
        printf("ERROR: out of stack\n");
        return false;
    }
    env->stackTop = env->stackTop + frameSize;

    outs() << "\n\nRunning foo: ";
    outs().flush();
    method->c_jit(env);
    //outs() << "Result: " << gv.IntVal << "\n";
    return true;
}
