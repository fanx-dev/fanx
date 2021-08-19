//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Jul 06  Brian Frank  Creation
//


**************************************************************************
** NopStmt
**************************************************************************

**
** NopStmt is no operation do nothing statement.
**
class NopStmt : LowerLevelStmt
{
  new make(Loc loc) : super(loc, StmtId.nop) {}

  override Bool isExit() { false }

  override Bool isDefiniteAssign(|Expr lhs->Bool| f) { false }

  override Void print(AstWriter out)
  {
    out.w("nop").nl
  }
}

**************************************************************************
** Lower level Stmt
**************************************************************************

abstract class LowerLevelStmt : Stmt {
  new make(Loc loc, StmtId id) : super(loc, id) {}
  override Bool isExit() { false }
  override Bool isDefiniteAssign(|Expr lhs->Bool| f) { false }
}

class TargetLabel : LowerLevelStmt {
  Int pos := -1
  Int[] backpatchs := [,]

  new make(Loc loc) : super(loc, StmtId.targetLable) {}
  
  override Void print(AstWriter out)
  {
    out.w("label_$pos:").nl
  }
}

class JumpStmt : LowerLevelStmt {
  Expr? condition
  TargetLabel? target
  //is leave protected region
  Bool isLeave := false
  Bool ifFalse := true //jump when condition is false

  new make(Loc loc, Expr? condition)
    : super(loc, StmtId.jumpStmt)
  {
    this.condition = condition
  }
  
  new makeGoto(Loc loc) : this.make(loc, null) {
  }
  
  override Void walkChildren(Visitor v, VisitDepth depth)
  {
    condition = walkExpr(v, depth, condition)
  }
  
  override Void print(AstWriter out)
  {
    out.w("if ($condition) goto ")
    target.print(out)
  }
}

class SwitchTable : LowerLevelStmt {
  Expr condition
  TargetLabel?[] jumps
  TargetLabel? defJump
  TargetLabel endLabel

  new make(Loc loc, Expr? condition)
    : super(loc, StmtId.switchTable)
  {
    this.condition = condition
    jumps = [,]
    endLabel = TargetLabel(loc)
  }
  
  override Void walkChildren(Visitor v, VisitDepth depth)
  {
    condition = walkExpr(v, depth, condition)
  }
  
  override Void print(AstWriter out)
  {
    out.w("switch ($condition) {").nl
    jumps.each |jmp,i| { out.w(i).w("->").w(jmp).nl }
    if (defJump != null) out.w("default:").w(defJump.id).nl
    out.w("}").nl
  }
}

class Exception : LowerLevelStmt {
  TargetLabel exceptionEnd

  Int tryStart
  ExceptionHandler tryEnd
  ExceptionHandler[] catchStarts
  ExceptionHandler[] catchEnds
  ExceptionHandler? finallyStart
  ExceptionHandler? finallyEnd
  
  TryStmt stmt

  new make(Loc loc, TryStmt stmt)
    : super(loc, StmtId.exception)
  {
    catchStarts = ExceptionHandler[,]
    catchEnds = ExceptionHandler[,]
    this.tryEnd = ExceptionHandler(loc, ExceptionHandler.typeTryEnd, this)
    this.exceptionEnd = TargetLabel(loc)
    this.stmt = stmt
  }
  
  Bool hasFinally() { stmt.finallyBlock != null }
  
  override Void print(AstWriter out)
  {
    out.w("try {").nl
  }
}

class ExceptionHandler : LowerLevelStmt {
  static const Int typeTryEnd := 1
  static const Int typeCatchStart := 2
  static const Int typeCatchEnd := 3
  static const Int typeFinallyStart := 4
  static const Int typeFinallyEnd := 5
  
  Int type
  CType? errType
  Exception parent
  Int pos := -1

  new make(Loc loc, Int type, Exception parent)
    : super(loc, StmtId.exceptionHandler)
  {
    this.type = type
    this.parent = parent
  }
  
  override Void print(AstWriter out)
  {
    switch (type) {
      case typeTryEnd:
      out.w("}").nl
      case typeCatchStart:
      out.w("catch($errType){").nl
      case typeCatchEnd:
      out.w("}").nl
      case typeFinallyStart:
      out.w("finally {").nl
      case typeFinallyEnd:
      out.w("}").nl
    }
  }
}
