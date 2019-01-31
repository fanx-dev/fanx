//
// Copyright (c) 2019, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2019-01-19  Jed Young Creation
//

class ExprFlat : CompilerStep
{
  private Stmt[] stmts := [,]
  
  new make(Compiler compiler)
    : super(compiler)
  {
  }

  override Void run()
  {
    log.debug("ExprDecom")
    walk(compiler, VisitDepth.slotDef)
    bombIfErr
  }

  override Void visitMethodDef(MethodDef def) {
    if (def.code == null) return
    if ((curMethod.flags.and(FConst.Async)) == 0) return

    stmts.clear
    def.code.stmts.each |Stmt s| { stmt(s) }
 
    def.code.stmts = stmts.dup

    //curType.dump
  }

  private Void stmt(Stmt stmt)
  {
    switch (stmt.id)
    {
      case StmtId.nop:             addStmt(stmt)
      case StmtId.expr:            processExpr(((ExprStmt)stmt))
      case StmtId.localDef:        processExpr((LocalDefStmt)stmt)
      case StmtId.jumpStmt:        processExpr((JumpStmt)stmt)
      case StmtId.returnStmt:      processExpr((ReturnStmt)stmt)
      case StmtId.targetLable:     addStmt(stmt)
      case StmtId.throwStmt:       processExpr((ThrowStmt)stmt)
      case StmtId.switchTable:     addStmt(stmt)
      case StmtId.exception:       addStmt(stmt)
      case StmtId.exceptionHandler:addStmt(stmt)
      default:                     throw Err(stmt.id.toStr)
    }
  }
  
  private Void addStmt(Stmt stmt) {
    stmts.add(stmt)
  }
  
  private Expr toTempVar(Expr expr) {
    if (expr.id === ExprId.localVar) return expr

    var := curMethod.addLocalVar(expr.ctype, null, null)
    lvar := LocalVarExpr(expr.loc, var)
    assign := BinaryExpr.makeAssign(lvar, expr)
    addStmt(assign.toStmt)
    return lvar
  }
  
  private Void processExpr(Stmt stmt) {

    hasYield := false
    hasBool := false
    count := 0
    stmt.walk(ExprVisitor(|Expr t->Expr| {
      if (t.id === ExprId.awaitExpr) {
        hasYield = true
      }
      else if (t.id === ExprId.boolOr || t.id === ExprId.boolAnd || t.id === ExprId.ternary) {
        hasBool = true
      }
      ++count
      return t
    }), VisitDepth.expr)

    if (hasYield) {
      if (hasBool) throw err("unsupport await int expr")

      stmt.walk(ExprVisitor.make|Expr e->Expr| {
        //localDef init
        if (e.id === ExprId.assign) return e
        return toTempVar(e)
      }, VisitDepth.expr)

      //already become a local var
      if (stmt.id != StmtId.expr) {
        addStmt(stmt)
      }
    }
    else {
      addStmt(stmt)
    }
  }

}