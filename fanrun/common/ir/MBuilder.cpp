//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by yangjiandong on 16/9/10.
//

#include "MBuilder.hpp"
#include "FCodeUtil.hpp"
#include <stdlib.h>

MBuilder::MBuilder(Code &code, IRMethod &irMethod) :
        curPod(irMethod.curPod), code(code)
        , irMethod(irMethod), errTable(NULL) {
    Block *b = new Block();
    b->curPod = curPod;
    methodVars = b;
}

void MBuilder::rewriteLocals() {
    allLocalsCount = 0;
    
    for (int j=0; j<methodVars->locals.size(); ++j) {
        Var &var = methodVars->locals[j];
        var.newIndex = allLocalsCount;
        var.isExport = true;
        ++allLocalsCount;
        
        if (j >= irMethod.paramCount) {
            var.name = var.name + "_" + std::to_string(var.index);
        }
        FCodeUtil::escapeIdentifierName(var.name);
    }
    
    for (int i=0; i<blocks.size(); ++i) {
        Block *b = blocks[i];
        for (int j=0; j<b->locals.size(); ++j) {
            Var &var = b->locals[j];
            var.newIndex = allLocalsCount;
            ++allLocalsCount;
            
            if (var.name.empty()) {
                var.name = "_t_" + std::to_string(var.block->index) +"_"+ std::to_string(var.index);
            }
        }
    }
}
/*
bool MBuilder::buildDefParam(FMethod *method, int paramNum, bool isVal) {
    if (paramNum < 0 || paramNum >= method->paramCount) {
        printf("ERROR paramNum out of index\n");
        return false;
    }
    
    irMethod.paramCount = paramNum;
    bool isStatic = (method->flags & FFlags::Static) != 0;
    if (!isStatic) {
        Var &var = newVar(irMethod.selfType);
        var.name = "__self";
        irMethod.paramCount++;
    }
    
    for(int i=0; i<paramNum+1; ++i) {
        FMethodVar *fvar = &method->vars[i];
        Var &var = newVar(fvar->type);
        //var.methodVar = fvar;
        //var.typeRef = fvar->type;
        var.name = curPod->names[fvar->name];
    }
    
    doBuild();
    
    for (Block *b : blocks) {
        if (b->stack.size() > 0) {
            //-----------------------------------
            //store default param value
            StoreStmt *storeStmt = new StoreStmt();
            TypeInfo &defVarTypeName = blocks[0]->locals[irMethod.paramCount].type;
            storeStmt->src = asType(b, b->pop(), defVarTypeName);
            storeStmt->dst.index = irMethod.paramCount;
            storeStmt->dst.block = methodVars;
            b->stmts.push_back(storeStmt);
            
            //-----------------------------------
            //call self
            CallStmt *stmt = new CallStmt();
            stmt->isStatic = isStatic;
            stmt->isVirtual = (method->flags & FFlags::Virtual) != 0;
            stmt->isMixin = (method->c_parent->meta.flags & FFlags::Mixin) != 0;
            stmt->curPod = curPod;
            //stmt->methodRefId = -1;
            //stmt->methodRef = nullptr;
            //stmt->method = method;
        
            stmt->typeName = FCodeUtil::getTypeRefName(curPod
                                                       , method->c_parent->meta.self, false);
            stmt->mthName = FCodeUtil::getIdentifierName(curPod, method->name);
            stmt->mthName += std::to_string(paramNum+1);
//            if (isVal) {
//                stmt->mthName += "_val";
//            }
            
            for (int i=0; i<irMethod.paramCount+1; ++i) {
                Expr expr;
                expr.index = i;
                expr.block = methodVars;
                stmt->params.push_back(expr);
            }
            
            TypeInfo retType;
            retType.setFromTypeRef(curPod, method->returnType);
            if (retType.isThis()) {
                retType.setFromTypeRef(curPod, method->c_parent->meta.self);
            }
            
            stmt->isVoid = retType.isVoid();
            if (!stmt->isVoid) {
                Var &var = b->newVar(method->returnType);
                var.type = retType;
                stmt->retValue = var.asRef();
                b->push(stmt->retValue);
            }
            b->stmts.push_back(stmt);
            
            //-----------------------------------
            //add return
            RetStmt *retStmt = new RetStmt();
            retStmt->isVoid = stmt->isVoid;
            if (!stmt->isVoid) {
                retStmt->retValue = asType(b, b->pop(), retType);
            }
            b->stmts.push_back(retStmt);
        }
    }
    
    rewriteLocals();
    //irMethod.locals.swap(this->locals);
    irMethod.blocks.swap(this->blocks);
    return true;
}
*/

bool MBuilder::buildMethod(FMethod *method) {
    for (FAttr *itr : method->attrs) {
        FErrTable *et = dynamic_cast<FErrTable*>(itr);
        if (et != nullptr) {
            if (this->errTable) {
                printf("ERROR: errTable already exist\n");
            }
            this->errTable = et;
        }
    }
    
    irMethod.paramCount = method->paramCount;
    bool isStatic = (method->flags & FFlags::Static) != 0;
    if (!isStatic) {
        Var &var = newVar(irMethod.selfType);
        //var.typeRef = method->c_parent->meta.self;
        var.name = "__self";
        var.isArg = true;
        var.type.isPass = true;
        irMethod.paramCount++;
    }
    
    for(int i=0; i<method->vars.size(); ++i) {
        FMethodVar *fvar = &method->vars[i];
        Var &var = newVar(fvar->type);
        //var.methodVar = fvar;
        //var.typeRef = fvar->type;
        if (i < method->paramCount) {
            var.isArg = true;
            var.type.isPass = true;
        }
        var.name = curPod->names[fvar->name];
    }
    
    doBuild();
    rewriteLocals();
    //irMethod.locals.swap(this->locals);
    irMethod.blocks.swap(this->blocks);
    irMethod.errTable = (this->errTable);
    irMethod.methodVars = methodVars;
    return true;
}

Var &MBuilder::newVar(int typeRef) {
    return methodVars->newVar(typeRef);
}

void MBuilder::doBuild() {
    code.initOps();
    
    initJumpTarget();
    initBlock();
    linkBlock();
    
    for (auto *b : blocks) {
        parseBlock(b, nullptr);
    }
    
    insertException();
}

void MBuilder::initJumpTarget() {
    std::unordered_map<int16_t, FOpObj*> posToOp;
    for (int i=0; i<code.ops.size(); ++i) {
        FOpObj *opObj = &code.ops[i];
        posToOp[opObj->pos] = opObj;
        opObj->blockBegin = false;
    }
    
    for (int i=0; i<code.ops.size(); ++i) {
        FOpObj &opObj = code.ops[i];
        if (i == 0) {
            opObj.blockBegin = true;
            continue;
        }
        switch (opObj.opcode) {
            case FOp::Jump:
            case FOp::JumpTrue:
            case FOp::JumpFalse:
            case FOp::Leave:
            case FOp::_JumpFinally: {
                int16_t pos = opObj.i1;
                FOpObj *op = posToOp[pos];
                if (op) {
                    op->blockBegin = true;
                }
                if (i+1 < code.ops.size()) {
                    FOpObj *next = &code.ops[i+1];
                    next->blockBegin = true;
                }
                
                break;
            }
            default:
                break;
        }
    }
    
    //find block in error table
    if (errTable) {
        for (FTrap &trap : errTable->traps) {
            FOpObj *opObj = posToOp[trap.start];
            opObj->blockBegin = true;
            FOpObj *eObj = posToOp[trap.end];
            eObj->blockBegin = true;
            FOpObj *op = posToOp[trap.handler];
            op->blockBegin = true;
        }
    }
}

void MBuilder::linkBlock() {
    //std::unordered_map<int16_t, Block*> posToBlock;
    for (auto *b : blocks) {
        posToBlock[b->pos] = b;
    }
    
    for (int i=0; i<blocks.size(); ++i) {
        Block *b = blocks[i];
        if (b->endOp == 0) continue;
        FOpObj &lastOp = code.ops[b->endOp-1];
        switch (lastOp.opcode) {
            case FOp::JumpTrue:
            case FOp::JumpFalse: {
                if (i+1 < blocks.size()) {
                    Block *next = blocks[i+1];
                    b->branchs.push_back(next);
                    next->incoming.push_back(b);
                }
                Block *target = posToBlock[lastOp.i1];
                b->branchs.push_back(target);
                target->incoming.push_back(b);
            }
                break;
            case FOp::Jump:
            case FOp::Leave:
            case FOp::_JumpFinally:{
                Block *target = posToBlock[lastOp.i1];
                b->branchs.push_back(target);
                target->incoming.push_back(b);
            }
                break;
            case FOp::Return:
            case FOp::Throw:
                break;
            default: {
                if (i+1 < blocks.size()) {
                    Block *next = blocks[i+1];
                    b->branchs.push_back(next);
                    next->incoming.push_back(b);
                    b->isForward = true;
                }
            }
                break;
        }
    }
}

void MBuilder::insertException() {
    uint16_t start = -1;
    uint16_t end = -1;
    
    ExceptionStmt *tryStart = nullptr;
    ExceptionStmt *tryEnd = nullptr;
    
    if (!errTable) return;
    for (FTrap &trap : errTable->traps) {
        if (trap.start != start || trap.end != end) {
            tryStart = new ExceptionStmt();
            tryStart->curPod = curPod;
            tryStart->etype = ExceptionStmt::TryStart;
            
            Block *b = posToBlock[trap.start];
            b->stmts.insert(b->stmts.begin(), tryStart);
            
            start = trap.start;
            end = trap.end;
            
            tryEnd = new ExceptionStmt();
            tryEnd->curPod = curPod;
            tryEnd->etype = ExceptionStmt::TryEnd;
            tryEnd->catchType = trap.type;
            tryEnd->handler = trap.handler;
            Block *eb = posToBlock[trap.end];
            eb = this->blocks.at(eb->index-1);
            eb->addStmt(tryEnd);
        }
        
        Block *cb = posToBlock[trap.handler];
        trap.c_handler = cb;
        ExceptionStmt *handlerStmt = NULL;
        for (Stmt *s : cb->stmts) {
            ExceptionStmt *catchStart = dynamic_cast<ExceptionStmt*>(s);
            if (!catchStart) continue;
            if (catchStart->pos == trap.handler) {
                handlerStmt = (catchStart);
                break;
            }
        }
        if (handlerStmt == NULL) {
            printf("ERROR: not found catch handlerStmt\n");
        }
        tryEnd->handlerStmt.push_back(handlerStmt);
    }
}

void MBuilder::initBlock() {
    for (int i=0; i<code.ops.size(); ++i) {
        FOpObj &opObj = code.ops[i];
        if (opObj.blockBegin) {
            Block *b = new Block();
            b->curPod = curPod;
            b->index = (int)blocks.size();
            b->pos = opObj.pos;
            b->beginOp = i;
            b->isVisited = false;
            
            if (blocks.size() > 0) {
                Block *block = blocks.back();
                block->endOp = i;
            }
            
            blocks.push_back(b);
        }
    }
    
    if (blocks.size() > 0) {
        Block *block = blocks.back();
        block->endOp = code.ops.size();
    }
}

void MBuilder::call(Block *block, FOpObj &opObj, bool isVirtual, bool isStatic
                    , bool isMixin, bool isAlloc) {
    CallStmt *stmt = new CallStmt();
    stmt->isStatic = isStatic;
    stmt->isVirtual = isVirtual;
    stmt->isMixin = isMixin;
    stmt->isCtor = isAlloc;
    stmt->curPod = curPod;
    stmt->pos = opObj.pos;
    stmt->block = block;
    //stmt->methodRefId = opObj.i1;
    FMethodRef *methodRef = &curPod->methodRefs[opObj.i1];
    stmt->methodRef = methodRef;
    
    stmt->typeName = FCodeUtil::getTypeNsName(curPod, methodRef->parent);
    FTypeRef parentRef = curPod->typeRefs[methodRef->parent];
    if (stmt->typeName == "sys_Array" || stmt->typeName == "sys_Ptr") {
        if (parentRef.extName.size() > 0) {
            stmt->extName = FCodeUtil::getExtTypeName(parentRef.extName);
        }
    }
    
    std::string mthName = curPod->names[methodRef->name];
    if (methodRef->flags & (FFlags::RefOverload | FFlags::RefSetter)) {
        mthName += "$";
        mthName += std::to_string(methodRef->paramCount);
    }
    FCodeUtil::escapeIdentifierName(mthName);
    stmt->mthName = mthName;
    
    for (int i=methodRef->paramCount-1; i>=0; --i) {
        TypeInfo fvarType(curPod, methodRef->params.at(i));
        stmt->params.insert(stmt->params.begin(), asType(block, block->pop(), fvarType, opObj.pos));
    }
    
    if (!isStatic) {
        TypeInfo selfType(curPod, methodRef->parent);
        stmt->params.insert(stmt->params.begin(), asType(block, block->pop(), selfType, opObj.pos));
    }
    
    TypeInfo retType(curPod, methodRef->retType);
    stmt->isVoid = retType.isVoid();
    if (!stmt->isVoid) {
        bool isThis = retType.isThis();
        if (!isThis) {
            FType *ftype = FCodeUtil::getFTypeFromTypeRef(curPod, methodRef->parent);
            std::string name = curPod->names[methodRef->name];
            if (methodRef->flags & FFlags::RefSetter) {
                name += "$";
                name += std::to_string(methodRef->paramCount);
            }
            else if (methodRef->flags & FFlags::RefOverload) {
                name += "$";
                name += std::to_string(methodRef->paramCount);
            }
            FMethod *fmethod = ftype->c_methodMap[name];
            if (fmethod) {
                std::string returnType = FCodeUtil::getTypeNsName(ftype->c_pod, fmethod->returnType);
                isThis = returnType == "sys_This";
            }
        }
        if (isThis) {
            retType.setFromTypeRef(curPod, methodRef->parent);
        }
        Var &var = block->newVarAs(retType);
        stmt->retValue = var.asRef();
        block->push(stmt->retValue);
    }
    block->addStmt(stmt);
}

Expr MBuilder::asType(Block *block, Expr expr, TypeInfo &expectedType, int pos) {
    if (expr.getType() == expectedType) return expr;
    CoerceStmt *stmt = new CoerceStmt();
    stmt->pos = pos;
    stmt->block = block;
    stmt->from = expr;
    
    Var &var = block->newVarAs(expectedType);
    stmt->to = var.asRef();
    
    block->addStmt(stmt);
    return var.asRef();
}

void MBuilder::parseBlock(Block *block, Block *previous) {
    
    if (previous != nullptr && previous->stack.size() > 0) {
        if (block->incoming.size() > 1) {
            /*分支合并的时候如果操作数栈中还有值，
             那么我们需要把里面的临时变量赋给下一块的变量，这样就能将不同路径的值合并。
             这相当于变换SSA中的PHI结点的过程
             */
            for (int i=0; i<previous->stack.size(); ++i) {
                Expr &srcExpr = previous->stack[i];
                /*
                if (srcExpr.block) {
                    Var &tv = srcExpr.block->locals.at(srcExpr.index);
                    tv.isExport = true;
                }
                */
                
                //make receive var
                Var newVar;
                if (block->isVisited) {
                    if (i < block->locals.size()) {
                        newVar = block->locals[i];
                        block->locals[i].isExport = true;
                    }
                } else {
                    Var &tVar = block->newVarAs(srcExpr.getType());
                    tVar.isExport = true;
                    newVar = tVar;
                    
                    Expr newExpr = newVar.asRef();
                    block->push(newExpr);
                }
                
                if (newVar.index == -1 && newVar.block == nullptr) {
                    printf("ERROR\n");
                    abort();
                }
                
                StoreStmt *stmt = new StoreStmt();
                stmt->curPod = curPod;
                stmt->dst = newVar.asRef();
                
                //cast if type not match
                CoerceStmt *coerceStmt = nullptr;
                TypeInfo &expectedType = newVar.type;
                if (srcExpr.getType() == expectedType) {
                    stmt->src = srcExpr;
                }
                else {
                    coerceStmt = new CoerceStmt();
                    coerceStmt->from = srcExpr;
                    Var &var = previous->newVarAs(expectedType);
                    coerceStmt->to = var.asRef();
                    stmt->src = var.asRef();
                }
                
            
                //insert stmt to previous block
                if (previous->stmts.size() == 0 || previous->isForward) {
                    if (coerceStmt) previous->stmts.push_back(coerceStmt);
                    previous->stmts.push_back(stmt);
                } else {
                    auto insertPoint = previous->stmts.begin() + previous->stmts.size()-1;
                    previous->stmts.insert(insertPoint, stmt);
                    insertPoint = previous->stmts.begin() + previous->stmts.size()-1;
                    if (coerceStmt) previous->stmts.insert(insertPoint, coerceStmt);
                }
            }
        } else if (!block->isVisited) {
            for (int i=0; i<previous->stack.size(); ++i) {
                Expr &expr = previous->stack[i];
                if (expr.block) {
                    Block *tb = expr.block;
                    Var &tv = tb->locals.at(expr.index);
                    tv.isExport = true;
                }
            }
            block->stack = (previous->stack);
        }
    }
    
    if (block->isVisited) {
        return;
    }
    block->isVisited = true;
    
//    if (irMethod.method->c_mangledName == "sys_ArrayList_make") {
//        printf("");
//    }
    
    for (int i=block->beginOp; i<block->endOp; ++i) {
        FOpObj &opObj = code.ops[i];
        switch (opObj.opcode)
        {
            case FOp::Nop:
                break;
            case FOp::LoadNull:
            case FOp::LoadFalse:
            case FOp::LoadTrue:
            case FOp::LoadInt:
            case FOp::LoadFloat:
            case FOp::LoadDecimal:
            case FOp::LoadStr:
            case FOp::LoadDuration:
            case FOp::LoadUri:
            case FOp::LoadType:{
                ConstStmt *stmt = new ConstStmt();
                stmt->curPod = curPod;
                stmt->pos = opObj.pos;
                stmt->block = block;
                stmt->opObj = opObj;
                Var &var = block->newVarAs(stmt->getType());
                stmt->dst = var.asRef();
                
                block->addStmt(stmt);
                block->push(stmt->dst);
                break;
            }
            case FOp::LoadVar: {
                Expr var;
                var.index = opObj.i1;
                var.block = methodVars;
                block->push(var);
                break;
            }
            case FOp::StoreVar: {
                StoreStmt *stmt = new StoreStmt();
                stmt->curPod = curPod;
                stmt->pos = opObj.pos;
                stmt->block = block;
                stmt->dst.index = opObj.i1;
                stmt->dst.block = methodVars;
                
                stmt->src = asType(block, block->pop(), stmt->dst.getType(), opObj.pos);
                block->addStmt(stmt);
                break;
            }
            case FOp::LoadInstance: {
                FieldStmt *stmt = new FieldStmt();
                stmt->curPod = curPod;
                stmt->pos = opObj.pos;
                stmt->block = block;
                stmt->isLoad = true;
                stmt->isStatic = false;
                stmt->instance = block->pop();
                stmt->fieldRef = &curPod->fieldRefs[opObj.i1];
                
                Var &var = block->newVar(stmt->fieldRef->type);
                //var.typeRef = stmt->fieldRef->type;
                stmt->value = var.asRef();
                block->push(stmt->value);
                
                block->addStmt(stmt);
                break;
            }
            case FOp::StoreInstance: {
                FieldStmt *stmt = new FieldStmt();
                stmt->curPod = curPod;
                stmt->pos = opObj.pos;
                stmt->block = block;
                stmt->isLoad = false;
                stmt->isStatic = false;
                stmt->fieldRef = &curPod->fieldRefs[opObj.i1];
                
                TypeInfo type(curPod, stmt->fieldRef->type);
                stmt->value = asType(block, block->pop(), type, opObj.pos);
                stmt->instance = block->pop();
          
                block->addStmt(stmt);
                break;
            }
            case FOp::LoadStatic:
            case FOp::LoadMixinStatic: {
                FieldStmt *stmt = new FieldStmt();
                stmt->curPod = curPod;
                stmt->pos = opObj.pos;
                stmt->block = block;
                stmt->isLoad = true;
                stmt->isStatic = true;
                stmt->fieldRef = &curPod->fieldRefs[opObj.i1];
                
                Var &var = block->newVar(stmt->fieldRef->type);
                //var.typeRef = stmt->fieldRef->type;
                stmt->value = var.asRef();
                block->push(stmt->value);
                
                block->addStmt(stmt);
                break;
            }
            case FOp::StoreStatic:
            case FOp::StoreMixinStatic:{
                FieldStmt *stmt = new FieldStmt();
                stmt->curPod = curPod;
                stmt->pos = opObj.pos;
                stmt->block = block;
                stmt->isLoad = false;
                stmt->isStatic = true;
                stmt->fieldRef = &curPod->fieldRefs[opObj.i1];
                
                TypeInfo type(curPod, stmt->fieldRef->type);
                stmt->value = asType(block, block->pop(), type, opObj.pos);
                
                block->addStmt(stmt);
                break;
            }
            // route method calls to FMethodRef
            case FOp::CallNew: {
                uint16_t typeId = curPod->methodRefs[opObj.i1].parent;
                Var &var = block->newVar(typeId);
                Expr value = var.asRef();
                
                AllocStmt *stmt = new AllocStmt();
                stmt->curPod = curPod;
                stmt->pos = opObj.pos;
                stmt->block = block;
                stmt->type = typeId;
                stmt->obj = value;
                block->addStmt(stmt);
                
                //block->push(value);//put on stack top
                FMethodRef *methodRef = &curPod->methodRefs[opObj.i1];
                size_t insertPos = block->stack.size() - methodRef->paramCount;
                block->stack.insert(block->stack.begin()+insertPos, value);
                
                call(block, opObj, false, false, false, true);
                //ctor is void, so push again
                block->push(value);
                break;
            }
            case FOp::CallStatic:
            case FOp::CallMixinStatic: {
                call(block, opObj, false, true, false);
                break;
            }
            case FOp::CallVirtual: {
                call(block, opObj, true, false, false);
                break;
            }
            case FOp::CallMixinVirtual: {
                call(block, opObj, true, false, true);
                break;
            }
                
            case FOp::CallCtor:
            case FOp::CallNonVirtual:
            case FOp::CallSuper: {
                call(block, opObj, false, false, false);
                break;
            }
            case FOp::CallMixinNonVirtual: {
                call(block, opObj, false, false, true);
                break;
            }
                
            case FOp::Jump: {
                JumpStmt *stmt = new JumpStmt();
                stmt->curPod = curPod;
                stmt->pos = opObj.pos;
                stmt->block = block;
                stmt->jmpType = JumpStmt::allJmp;
                //stmt->opObj = opObj;
                stmt->selfPos = opObj.pos;
                stmt->targetPos = opObj.i1;
                stmt->targetBlock = posToBlock[opObj.i1];
                
                block->addStmt(stmt);
                break;
            }
            case FOp::JumpTrue:{
                JumpStmt *stmt = new JumpStmt();
                stmt->curPod = curPod;
                stmt->pos = opObj.pos;
                stmt->block = block;
                stmt->jmpType = JumpStmt::trueJmp;
                stmt->expr = block->pop();
                //stmt->opObj = opObj;
                stmt->selfPos = opObj.pos;
                stmt->targetPos = opObj.i1;
                stmt->targetBlock = posToBlock[opObj.i1];
                
                block->addStmt(stmt);
                break;
            }
            case FOp::JumpFalse:{
                JumpStmt *stmt = new JumpStmt();
                stmt->curPod = curPod;
                stmt->pos = opObj.pos;
                stmt->block = block;
                stmt->jmpType = JumpStmt::falseJmp;
                stmt->expr = block->pop();
                //stmt->opObj = opObj;
                stmt->selfPos = opObj.pos;
                stmt->targetPos = opObj.i1;
                stmt->targetBlock = posToBlock[opObj.i1];
                
                block->addStmt(stmt);
                break;
            }
            case FOp::Compare: {
                CompareStmt *stmt = new CompareStmt();
                stmt->curPod = curPod;
                stmt->pos = opObj.pos;
                stmt->block = block;
                stmt->param2 = block->pop();
                stmt->param1 = block->pop();
                stmt->opObj = opObj;
                TypeInfo type = TypeInfo::makeInt();
                Var &var = block->newVarAs(type);;
                stmt->result = var.asRef();
                block->addStmt(stmt);
                
                block->push(stmt->result);
                break;
            }
            case FOp::CompareEQ:
            case FOp::CompareNE:
            case FOp::CompareLT:
            case FOp::CompareLE:
            case FOp::CompareGE:
            case FOp::CompareGT:
            case FOp::CompareSame:
            case FOp::CompareNotSame: {
                CompareStmt *stmt = new CompareStmt();
                stmt->curPod = curPod;
                stmt->pos = opObj.pos;
                stmt->block = block;
                stmt->param2 = block->pop();
                stmt->param1 = block->pop();
                stmt->opObj = opObj;
                TypeInfo type = TypeInfo::makeBool();
                Var &var = block->newVarAs(type);
                stmt->result = var.asRef();
                block->addStmt(stmt);
                
                block->push(stmt->result);
                break;
            }
            case FOp::CompareNull:
            case FOp::CompareNotNull:{
                CompareStmt *stmt = new CompareStmt();
                stmt->curPod = curPod;
                stmt->pos = opObj.pos;
                stmt->block = block;
                stmt->param1 = block->pop();
                stmt->opObj = opObj;
                TypeInfo type = TypeInfo::makeBool();
                Var &var = block->newVarAs(type);
                stmt->result = var.asRef();
                block->addStmt(stmt);
                
                block->push(stmt->result);
                break;
            }
            case FOp::Return: {
                ReturnStmt *stmt = new ReturnStmt();
                stmt->curPod = curPod;
                stmt->pos = opObj.pos;
                stmt->block = block;
                TypeInfo type(curPod, irMethod.returnType);
                stmt->isVoid = type.isVoid();
                if (!stmt->isVoid) {
                    if (type.isThis()) {
                        type.setFromTypeRef(curPod, irMethod.selfType);
                    }
                    stmt->retValue = asType(block, block->pop(), type, opObj.pos);
                }
                
                block->addStmt(stmt);
                break;
            }
            case FOp::Pop: {
                block->pop();
                break;
            }
            case FOp::Dup: {
                Expr entry = block->pop();
                block->push(entry);
                block->push(entry);
                break;
            }
            case FOp::Is: {
                TypeCheckStmt *stmt = new TypeCheckStmt();
                stmt->curPod = curPod;
                stmt->pos = opObj.pos;
                stmt->block = block;
                //stmt->isOrAs = false;
                stmt->type = opObj.i1;
                stmt->obj = block->pop();
                
                TypeInfo type = TypeInfo::makeBool();
                Var &var = block->newVarAs(type);
                Expr value = var.asRef();
                block->push(value);
                stmt->result = value;
                
                block->addStmt(stmt);
                break;
            }
            case FOp::As: {
                CoerceStmt *stmt = new CoerceStmt();
                stmt->curPod = curPod;
                stmt->pos = opObj.pos;
                stmt->block = block;
                stmt->from = block->pop();
                stmt->toType = opObj.i1;
                Var &var = block->newVar(opObj.i1);
                
                Expr value = var.asRef();
                block->push(value);
                stmt->to = value;
                stmt->safe = false;
                stmt->checked = false;
                
                block->addStmt(stmt);
                break;
            }
            case FOp::Coerce: {
                CoerceStmt *stmt = new CoerceStmt();
                stmt->curPod = curPod;
                stmt->pos = opObj.pos;
                stmt->block = block;
                stmt->from = block->pop();
                stmt->fromType = opObj.i1;
                stmt->toType = opObj.i2;
                Var &var = block->newVar(opObj.i2);
                
                Expr value = var.asRef();
                block->push(value);
                stmt->to = value;
                stmt->safe = false;
                
                block->addStmt(stmt);
                break;
            }
            case FOp::Switch: {
                //newBlock();
                break;
            }
            case FOp::Throw: {
                ThrowStmt *stmt = new ThrowStmt();
                stmt->curPod = curPod;
                stmt->pos = opObj.pos;
                stmt->block = block;
                stmt->var = block->pop();
                
                block->addStmt(stmt);
                break;
            }
            case FOp::Leave: {
                JumpStmt *stmt = new JumpStmt();
                stmt->curPod = curPod;
                stmt->pos = opObj.pos;
                stmt->block = block;
                stmt->jmpType = JumpStmt::leaveJmp;
                //stmt->opObj = opObj;
                stmt->selfPos =
                stmt->targetPos = opObj.i1;
                stmt->targetBlock = posToBlock[opObj.i1];
                
                block->addStmt(stmt);
                break;
            }
            case FOp::_JumpFinally:{
                JumpStmt *stmt = new JumpStmt();
                stmt->curPod = curPod;
                stmt->pos = opObj.pos;
                stmt->block = block;
                stmt->jmpType = JumpStmt::finallyJmp;
                //stmt->opObj = opObj;
                stmt->selfPos = opObj.pos;
                stmt->targetPos = opObj.i1;
                stmt->targetBlock = posToBlock[opObj.i1];
                
                block->addStmt(stmt);
                break;
            }
            case FOp::CatchAllStart: {
                ExceptionStmt *estmt = new ExceptionStmt();
                estmt->curPod = curPod;
                estmt->pos = opObj.pos;
                estmt->block = block;
                estmt->etype = ExceptionStmt::CatchStart;
                estmt->catchType = -1;
                estmt->pos = opObj.pos;
                block->addStmt(estmt);
            }
                break;
                
            case FOp::CatchErrStart: {
                Var &var = block->newVar(opObj.i1);
                var.isExport = true;
                //var.typeRef = opObj.i1;
                Expr value = var.asRef();
                block->push(value);
                
                ExceptionStmt *estmt = new ExceptionStmt();
                estmt->curPod = curPod;
                estmt->pos = opObj.pos;
                estmt->block = block;
                estmt->etype = ExceptionStmt::CatchStart;
                estmt->catchVar = value;
                estmt->catchType = opObj.i1;
                estmt->pos = opObj.pos;
                block->addStmt(estmt);
            }
                break;
            case FOp::_CatchEnd: {
                ExceptionStmt *stmt = new ExceptionStmt();
                stmt->curPod = curPod;
                stmt->pos = opObj.pos;
                stmt->block = block;
                stmt->etype = ExceptionStmt::CatchEnd;
                block->addStmt(stmt);
            }
                break;
                
            case FOp::FinallyStart: {
                ExceptionStmt *stmt = new ExceptionStmt();
                stmt->curPod = curPod;
                stmt->pos = opObj.pos;
                stmt->block = block;
                stmt->pos = opObj.pos;
                stmt->etype = ExceptionStmt::FinallyStart;
                block->addStmt(stmt);
            }
                break;
                
            case FOp::FinallyEnd: {
                ExceptionStmt *stmt = new ExceptionStmt();
                stmt->curPod = curPod;
                stmt->pos = opObj.pos;
                stmt->block = block;
                stmt->etype = ExceptionStmt::FinallyEnd;
                block->addStmt(stmt);
            }
                break;
            case FOp::LoadFieldLiteral: {
                //TODO
            }
                break;
            case FOp::LoadMethodLiteral: {
                //TODO
            }
                break;
            default:
                printf("ERROR: unkonw opcode\n");
                break;
        }
        
    }
    
    for (Block *b : block->branchs) {
        parseBlock(b, block);
    }
}
