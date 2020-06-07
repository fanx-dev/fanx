//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by chunquedong on 15/6/26.
//

#ifndef __zip__Code__
#define __zip__Code__

#include <stdio.h>
#include "Buffer.h"
#include <vector>

enum class FOp {
    Nop             =   0, // ()        no operation
    LoadNull        =   1, // ()        load null literal onto stack
    LoadFalse       =   2, // ()        load false literal onto stack
    LoadTrue        =   3, // ()        load true literal onto stack
    LoadInt         =   4, // (int)     load Int const by index onto stack
    LoadFloat       =   5, // (float)   load Float const by index onto stack
    LoadDecimal     =   6, // (decimal)  load Decimal const by index onto stack
    LoadStr         =   7, // (str)     load Str const by index onto stack
    LoadDuration    =   8, // (dur)     load Duration const by index onto stack
    LoadType        =   9, // (type)    load Type instance by index onto stack
    LoadUri         =  10, // (uri)     load Uri const by index onto stack
    LoadVar         =  11, // (reg)     local var register index (0 is this)
    StoreVar        =  12, // (reg)     local var register index (0 is this)
    LoadInstance    =  13, // (field)   load field from storage
    StoreInstance   =  14, // (field)   store field to storage
    LoadStatic      =  15, // (field)   load static field from storage
    StoreStatic     =  16, // (field)   store static field to storage
    LoadMixinStatic =  17, // (field)   load static on mixin field from storage
    StoreMixinStatic =  18, // (field)   store static on mixin field to storage
    CallNew         =  19, // (method)  alloc new object and call constructor
    CallCtor        =  20, // (method)  call constructor (used for constructor chaining)
    CallStatic      =  21, // (method)  call static method
    CallVirtual     =  22, // (method)  call virtual instance method
    CallNonVirtual  =  23, // (method)  call instance method non-virtually (private or super only b/c of Java invokespecial)
    CallMixinStatic =  24, // (method)  call static mixin method
    CallMixinVirtual =  25, // (method)  call virtual mixin method
    CallMixinNonVirtual =  26, // (method)  call instance mixin method non-virtually (named super)
    Jump            =  27, // (jmp)     unconditional jump
    JumpTrue        =  28, // (jmp)     jump if bool true
    JumpFalse       =  29, // (jmp)     jump if bool false
    CompareEQ       =  30, // (typePair)  a.equals(b)
    CompareNE       =  31, // (typePair)  !a.equals(b)
    Compare         =  32, // (typePair)  a.compare(b)
    CompareLE       =  33, // (typePair)  a.compare(b) <= 0
    CompareLT       =  34, // (typePair)  a.compare(b) < 0
    CompareGT       =  35, // (typePair)  a.compare(b) > 0
    CompareGE       =  36, // (typePair)  a.compare(b) >= 0
    CompareSame     =  37, // ()        a === b
    CompareNotSame  =  38, // ()        a !== b
    CompareNull     =  39, // (type)    a == null
    CompareNotNull  =  40, // (type)    a != null
    Return          =  41, // ()        return from method
    Pop             =  42, // (type)    pop top object off stack
    Dup             =  43, // (type)    duplicate object ref on top of stack
    Is              =  44, // (type)    is operator
    As              =  45, // (type)    as operator
    Coerce          =  46, // (typePair)  from->to coercion value/reference/nullable
    Switch          =  47, // ()        switch jump table 2 count + 2*count
    Throw           =  48, // ()        throw Err on top of stack
    Leave           =  49, // (jmp)     jump out of a try or catch block
    _JumpFinally     =  50, // (jmp)     jump to a finally block
    CatchAllStart   =  51, // ()        start catch all block - do not leave Err on stack
    CatchErrStart   =  52, // (type)    start catch block - leave typed Err on stack
    _CatchEnd        =  53, // ()        start catch block - leave typed Err on stack
    FinallyStart    =  54, // ()        starting instruction of a finally block
    FinallyEnd      =  55, // ()        ending instruction of a finally block
    CallSuper       =  56, // (method) call super method
    LoadFieldLiteral = 57, //  (FOpArg.FieldRef),   //  57
    LoadMethodLiteral = 58, // (FOpArg.MethodRef)   //  58
    AddressOfVar      = 59, // (FOpArg.Register),   //  59
    AddressOfInstance = 60, // (FOpArg.FieldRef),   //  60
    AddressOfStatic   = 61, // (FOpArg.FieldRef),   //  61
    SizeOf            = 62, // (FOpArg.TypeRef),    //  62
    LoadFuncHandle    = 63, // (FOpArg.MethodRef),  //  63  load func handle and put func obj on stack
    CallFunc          = 64, // (FOpArg.MethodRef)   //  64
};

extern const char* OpNames[];

enum class FOpArg
{
    None,
    Int,
    Float,
    Decimal,
    Str,
    Duration,
    Uri,
    Register,
    TypeRef,
    FieldRef,
    MethodRef,
    JumpA,
    TypePair
};

extern FOpArg OpArgList[];

struct FOpObj {
    int pos;
    FOp opcode;
    FOpArg arg;
    uint16_t i1;
    uint16_t i2;
    uint16_t *table;
    bool blockBegin;
};

class FPod;
class FMethodVar;
class FMethod;

class Code {
public:
    Buffer buf;
    std::vector<FOpObj> ops;
public:
    Code();
    bool read(Buffer &buffer);
    bool initOps();
    bool isEmpty() { return buf.size() == 0; }
private:
    void readSwitch(Buffer &buffer, FOpObj &op);
    bool readOp(Buffer &buffer, FOpObj &op);
};

#endif /* defined(__zip__Code__) */
