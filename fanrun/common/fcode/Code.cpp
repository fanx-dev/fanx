//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by chunquedong on 15/6/26.
//

#include "Code.h"
#include <stdlib.h>


FOpArg OpArgList[] =
{
    FOpArg::None,         //   0 Nop
    FOpArg::None,         //   1 LoadNull
    FOpArg::None,         //   2 LoadFalse
    FOpArg::None,         //   3 LoadTrue
    FOpArg::Int,      //   4 LoadInt
    FOpArg::Float,    //   5 LoadFloat
    FOpArg::Decimal,  //   6 LoadDecimal
    FOpArg::Str,      //   7 LoadStr
    FOpArg::Duration,      //   8 LoadDuration
    FOpArg::TypeRef,     //   9 LoadType
    FOpArg::Uri,      //  10 LoadUri
    FOpArg::Register,      //  11 LoadVar
    FOpArg::Register,      //  12 StoreVar
    FOpArg::FieldRef,    //  13 LoadInstance
    FOpArg::FieldRef,    //  14 StoreInstance
    FOpArg::FieldRef,    //  15 LoadStatic
    FOpArg::FieldRef,    //  16 StoreStatic
    FOpArg::FieldRef,    //  17 LoadMixinStatic
    FOpArg::FieldRef,    //  18 StoreMixinStatic
    FOpArg::MethodRef,   //  19 CallNew
    FOpArg::MethodRef,   //  20 CallCtor
    FOpArg::MethodRef,   //  21 CallStatic
    FOpArg::MethodRef,   //  22 CallVirtual
    FOpArg::MethodRef,   //  23 CallNonVirtual
    FOpArg::MethodRef,   //  24 CallMixinStatic
    FOpArg::MethodRef,   //  25 CallMixinVirtual
    FOpArg::MethodRef,   //  26 CallMixinNonVirtual
    FOpArg::JumpA,      //  27 Jump
    FOpArg::JumpA,      //  28 JumpTrue
    FOpArg::JumpA,      //  29 JumpFalse
    FOpArg::TypePair,  //  30 CompareEQ
    FOpArg::TypePair,  //  31 CompareNE
    FOpArg::TypePair,  //  32 Compare
    FOpArg::TypePair,  //  33 CompareLE
    FOpArg::TypePair,  //  34 CompareLT
    FOpArg::TypePair,  //  35 CompareGT
    FOpArg::TypePair,  //  36 CompareGE
    FOpArg::None,         //  37 CompareSame
    FOpArg::None,         //  38 CompareNotSame
    FOpArg::TypeRef,     //  39 CompareNull
    FOpArg::TypeRef,     //  40 CompareNotNull
    FOpArg::None,         //  41 Return
    FOpArg::TypeRef,     //  42 Pop
    FOpArg::TypeRef,     //  43 Dup
    FOpArg::TypeRef,     //  44 Is
    FOpArg::TypeRef,     //  45 As
    FOpArg::TypePair,  //  46 Coerce
    FOpArg::None,         //  47 Switch
    FOpArg::None,         //  48 Throw
    FOpArg::JumpA,      //  49 Leave
    FOpArg::JumpA,      //  50 JumpFinally
    FOpArg::None,         //  51 CatchAllStart
    FOpArg::TypeRef,     //  52 CatchErrStart
    FOpArg::None,         //  53 CatchEnd
    FOpArg::None,         //  54 FinallyStart
    FOpArg::None,         //  55 FinallyEnd
    FOpArg::MethodRef,   //  56 CallSuper
    FOpArg::FieldRef,    //  57 LoadFieldLiteral
    FOpArg::MethodRef,   //  58 LoadMethodLiteral
    FOpArg::Register,     // AddressOfVar  59
    FOpArg::FieldRef,     // AddressOfInstance  60
    FOpArg::FieldRef,     // AddressOfStatic    61
    FOpArg::TypeRef,      // SizeOf             62
    FOpArg::MethodRef,    // LoadFuncHandle     63  load func handle and put func obj on stack
    FOpArg::MethodRef,    // CallFunc           64
};

const char* OpNames[] =
{
    "Nop",                //   0
    "LoadNull",           //   1
    "LoadFalse",          //   2
    "LoadTrue",           //   3
    "LoadInt",            //   4
    "LoadFloat",          //   5
    "LoadDecimal",        //   6
    "LoadStr",            //   7
    "LoadDuration",       //   8
    "LoadType",           //   9
    "LoadUri",            //  10
    "LoadVar",            //  11
    "StoreVar",           //  12
    "LoadInstance",       //  13
    "StoreInstance",      //  14
    "LoadStatic",         //  15
    "StoreStatic",        //  16
    "LoadMixinStatic",    //  17
    "StoreMixinStatic",   //  18
    "CallNew",            //  19
    "CallCtor",           //  20
    "CallStatic",         //  21
    "CallVirtual",        //  22
    "CallNonVirtual",     //  23
    "CallMixinStatic",    //  24
    "CallMixinVirtual",   //  25
    "CallMixinNonVirtual",  //  26
    "Jump",               //  27
    "JumpTrue",           //  28
    "JumpFalse",          //  29
    "CompareEQ",          //  30
    "CompareNE",          //  31
    "Compare",            //  32
    "CompareLE",          //  33
    "CompareLT",          //  34
    "CompareGT",          //  35
    "CompareGE",          //  36
    "CompareSame",        //  37
    "CompareNotSame",     //  38
    "CompareNull",        //  39
    "CompareNotNull",     //  40
    "Return",             //  41
    "Pop",                //  42
    "Dup",                //  43
    "Is",                 //  44
    "As",                 //  45
    "Coerce",             //  46
    "Switch",             //  47
    "Throw",              //  48
    "Leave",              //  49
    "JumpFinally",        //  50
    "CatchAllStart",      //  51
    "CatchErrStart",      //  52
    "CatchEnd",           //  53
    "FinallyStart",       //  54
    "FinallyEnd",         //  55
    "CallSuper",          //  56
    "LoadFieldLiteral",   //  57
    "LoadMethodLiteral",  //  58
    "AddressOfVar",       //  59
    "AddressOfInstance",  //  60
    "AddressOfStatic",    //  61
    "SizeOf",             //  62
    "LoadFuncHandle",     //  63  load func handle and put func obj on stack
    "CallFunc",           //  64
};


Code::Code() {
}

void Code::readSwitch(Buffer &buffer, FOpObj &op) {
    uint16_t count = buffer.readUInt16();
    uint16_t *table = (uint16_t*)malloc(sizeof(uint16_t)*count);
    for (int i=0; i<count; ++i) {
        table[i] = buffer.readUInt16();
    }
    op.i1 = count;
    op.table = table;
}

bool Code::read(Buffer &buffer) {
    data = buffer.readBufData(len, true);
    return true;
}

bool Code::initOps() {
    bool ok = true;
    FOpObj op;
    Buffer buf;
    buf.reset(data, len, false);

    while(!buf.isEof()) {
        ok = readOp(buf, op);
        if (!ok) {
            break;
        }
        ops.push_back(op);
    }
    return ok;
}

bool Code::readOp(Buffer &buffer, FOpObj &op) {
    int pos = (int)buffer.getPos();
    FOp opCode = (FOp)buffer.readUInt8();
    FOpArg arg = OpArgList[(int)opCode];
    op.opcode = opCode;
    op.arg = arg;
    op.i1 = 0;
    op.i2 = 0;
    op.table = NULL;
    op.pos = pos;
    
    if (opCode == FOp::Switch) {
        readSwitch(buffer, op);
    }
    else switch (arg)
    {
        case FOpArg::None:      //print();
            break;
        case FOpArg::Int:
            op.i1 = buffer.readUInt16();
            break;
        case FOpArg::Float:
            op.i1 = buffer.readUInt16();
            break;
        case FOpArg::Str:
            op.i1 = buffer.readUInt16();
            break;
        case FOpArg::Duration:
            op.i1 = buffer.readUInt16();
            break;
        case FOpArg::Uri:
            op.i1 = buffer.readUInt16();
            break;
        case FOpArg::Register:
            op.i1 = buffer.readUInt16();
            break;
        case FOpArg::TypeRef:
            op.i1 = buffer.readUInt16();
            break;
        case FOpArg::FieldRef:
            op.i1 = buffer.readUInt16();
            break;
        case FOpArg::MethodRef:
            op.i1 = buffer.readUInt16();
            break;
        case FOpArg::JumpA:
            op.i1 = buffer.readUInt16();
            break;
        case FOpArg::TypePair:
            op.i1 = buffer.readUInt16();
            op.i2 = buffer.readUInt16();
            break;
        default:
            return false;
    }
    return true;
}
