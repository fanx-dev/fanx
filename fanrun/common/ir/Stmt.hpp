//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by yangjiandong on 16/9/10.
//

#ifndef Stmt_hpp
#define Stmt_hpp

#include "../fcode/Code.h"
#include "../fcode/FPod.h"
//#include "common.h"
#include "../fcode/Printer.h"

class IRMethod;
class Block;
struct Var;

struct TypeInfo {
    friend Var;
    
    std::string pod;
    std::string name;
    std::string extName;
    
    bool isNullable;
    bool isBuildin;
    bool isValue;
    bool isMixin;
    bool isPass;
    
    int32_t typeRef;
    
    std::string getName() const;
    
    bool isValueType() { return isValue && !isNullable && (!isPass || isBuildin); }
    
private:
    TypeInfo() : isNullable(false), isBuildin(false), isValue(false), typeRef(-1), isMixin(false), isPass(false) {}
public:
    TypeInfo(const std::string &pod, const std::string &name, bool isValue, bool isBuildin, bool isNullable);
    TypeInfo(FPod *curPod, uint16_t typeRefId) { setFromTypeRef(curPod, typeRefId); }
    
    static TypeInfo makeInt();
    static TypeInfo makeBool();
    
    void setFromTypeRef(FPod *curPod, uint16_t typeRefId);
public:
    bool isThis();
    bool isVoid();
    
    bool operator==(const TypeInfo &other) const {
        if (pod != other.pod) return false;
        if (name != other.name) return false;
        if (isNullable != other.isNullable) return false;
        if (isValue != other.isValue) return false;
        return true;
    }
};

//Ref of var
struct Expr {
    //index of parent
    int index;
    
    //parent of block
    Block *block;
    
    Expr() : block(nullptr), index(-1) {}
    
    std::string getName(bool deRef = false);
    TypeInfo &getType();
    std::string getTypeName();
    bool isValueType();
};

struct Var {
    //position in block
    int index;
    //parent block
    Block *block;
    
    //ref by other block, true is leftValue, false is rightValue
    bool isExport;
    
    //global index in function vars
    int newIndex;
    
    //name of var
    std::string name;
    
    //type of var
    TypeInfo type;
    
    bool isArg;
    
    Var() : index(-1), newIndex(-1), block(nullptr),
    isExport(false), isArg(false) {
    }
    
    Expr asRef();
};

enum class StmtType {
  Const, Store, Field, Call, Alloc, Compare, Return, Jump, Throw, Exception, Coerce, TypeCheck, Switch
};

class Stmt {
public:
    FPod *curPod;
    IRMethod *method;
    Block *block;
    int pos;
    virtual void print(Printer& printer) = 0;
    Stmt() : curPod(nullptr), method(nullptr), pos(-1) {}
    virtual StmtType stmtType() = 0;
};

class ConstStmt : public Stmt {
public:
    Expr dst;
    FOpObj opObj;
    
    virtual void print(Printer& printer) override;
    TypeInfo getType();
    
    virtual StmtType stmtType() override { return StmtType::Const; }
};

class StoreStmt : public Stmt {
public:
    Expr src;
    Expr dst;
    
    virtual void print(Printer& printer) override;
    
    virtual StmtType stmtType() override { return StmtType::Store; }
};

class FieldStmt : public Stmt {
public:
    bool isLoad;
    bool isStatic;
    Expr instance;
    FFieldRef *fieldRef;
    Expr value;
    
    virtual void print(Printer& printer) override;
    
    virtual StmtType stmtType() override { return StmtType::Field; }
};

class CallStmt : public Stmt {
public:
    FMethodRef *methodRef;
    
    std::string typeName;
    std::string mthName;
    std::string extName;
    
    std::vector<Expr> params;
    Expr retValue;
    bool isVoid;
    bool isStatic;
    bool isVirtual;
    bool isMixin;
    bool isCtor;
    
    //for compare which no methodRef
    //std::vector<std::string> argsType;
    
    CallStmt() : methodRef(NULL), isCtor(false) {}
    
    virtual void print(Printer& printer) override;
    
    virtual StmtType stmtType() override { return StmtType::Call; }
};

class AllocStmt : public Stmt {
public:
    uint16_t type;
    Expr obj;
    
    virtual void print(Printer& printer) override;
    
    virtual StmtType stmtType() override { return StmtType::Alloc; }
};

class CompareStmt : public Stmt {
public:
    Expr param1;
    Expr param2;
    Expr result;
    FOpObj opObj;
    
    virtual void print(Printer& printer) override;
    
    virtual StmtType stmtType() override { return StmtType::Compare; }
};

class ReturnStmt : public Stmt {
public:
    Expr retValue;
    bool isVoid;
    
    virtual void print(Printer& printer) override;
    
    virtual StmtType stmtType() override { return StmtType::Return; }
};

class Block;
class JumpStmt : public Stmt {
public:
    enum JmpType {
        allJmp,
        trueJmp,
        falseJmp,
        leaveJmp,
        finallyJmp,
    };
    
    JmpType jmpType;
    Expr expr;
    uint16_t selfPos;
    uint16_t targetPos;
    
    Block *targetBlock;
    
    virtual void print(Printer& printer) override;
    
    virtual StmtType stmtType() override { return StmtType::Jump; }
};

class ThrowStmt : public Stmt {
public:
    Expr var;
    
    virtual void print(Printer& printer) override;
    
    virtual StmtType stmtType() override { return StmtType::Throw; }
};

class ExceptionStmt : public Stmt {
public:
    enum EType { TryStart, TryEnd, CatchStart, CatchEnd, FinallyStart, FinallyEnd };
    EType etype;
    
    int32_t catchType;//err type to catch
    Expr catchVar;
    int32_t handler;
    int pos;
    
    std::vector<ExceptionStmt*> handlerStmt;
    
    ExceptionStmt() : catchType(-1), handler(-1), pos(-1) {}
    
    virtual void print(Printer& printer) override;
    
    virtual StmtType stmtType() override { return StmtType::Exception; }
};

class CoerceStmt : public Stmt {
public:
    //enum CType { nonNull, boxing, unboxing, other };
    //CType coerceType;
    Expr from;
    Expr to;
    
    int fromType;
    int toType;
    
    //can direct cast
    bool safe;
    //throw err if can't cast
    bool checked;
    
    CoerceStmt() : safe(true), checked(true), fromType(-1), toType(-1) {}
    
    virtual void print(Printer& printer) override;
    
    virtual StmtType stmtType() override { return StmtType::Coerce; }
};

class TypeCheckStmt : public Stmt {
public:
    Expr obj;
    uint16_t type;
    Expr result;
    
    virtual void print(Printer& printer) override;
    
    virtual StmtType stmtType() override { return StmtType::TypeCheck; }
};


class SwitchStmt : public Stmt {
public:
    Expr var;
    uint16_t* table;
    int tableSize;

    virtual void print(Printer& printer) override;

    virtual StmtType stmtType() override { return StmtType::Switch; }
};

#endif /* Stmt_hpp */
