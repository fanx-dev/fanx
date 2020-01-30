//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//   26 Aug 06  Brian Frank  Ported from Java to Fan
//

**
** Vistor is used to walk the abstract syntax tree and visit key nodes.
** The walk for each node type entails:
**   1. enter
**   2. children
**   3. exit
**   4. visit
**
mixin Visitor
{

//////////////////////////////////////////////////////////////////////////
// Visit
//////////////////////////////////////////////////////////////////////////

  **
  ** Peform a walk of the abstract syntax tree down
  ** to the specified depth.
  **
  Void walk(CompilationUnit cunit, VisitDepth depth)
  {
    cunit.types.each |TypeDef def| { def.walk(this, depth) }
  }

//////////////////////////////////////////////////////////////////////////
// CompilationUnit Callbacks
//////////////////////////////////////////////////////////////////////////

  **
  ** Callback when entering a compilation unit.
  **
  virtual Void enterUnit(CompilationUnit unit) {}

  **
  ** Callback when existing a compilation unit.
  **
  virtual Void exitUnit(CompilationUnit unit) {}

//////////////////////////////////////////////////////////////////////////
// TypeDef Callbacks
//////////////////////////////////////////////////////////////////////////

  **
  ** Callback when entering a type definition.
  **
  virtual Void enterTypeDef(TypeDef def) {}

  **
  ** Callback when exiting a type definition.
  **
  virtual Void exitTypeDef(TypeDef def) {}

  **
  ** Callback when visiting a type definition.
  **
  virtual Void visitTypeDef(TypeDef def) {}

//////////////////////////////////////////////////////////////////////////
// FieldDef Callbacks
//////////////////////////////////////////////////////////////////////////

  **
  ** Callback when entering a field definition.
  **
  virtual Void enterFieldDef(FieldDef def) {}

  **
  ** Callback when exiting a field definition.
  **
  virtual Void exitFieldDef(FieldDef def) {}

  **
  ** Callback when visiting a field definition.
  **
  virtual Void visitFieldDef(FieldDef def) {}

//////////////////////////////////////////////////////////////////////////
// MethodDef Callbacks
//////////////////////////////////////////////////////////////////////////

  **
  ** Callback when entering a method.
  **
  virtual Void enterMethodDef(MethodDef def) {}

  **
  ** Callback when exiting a method.
  **
  virtual Void exitMethodDef(MethodDef def) {}

  **
  ** Callback when visiting a method.
  **
  virtual Void visitMethodDef(MethodDef def) {}

//////////////////////////////////////////////////////////////////////////
// Block Callbacks
//////////////////////////////////////////////////////////////////////////

  **
  ** Callback when entering a block.
  **
  virtual Void enterBlock(Block block) {}

  **
  ** Callback when exiting a block.
  **
  virtual Void exitBlock(Block block) {}

  **
  ** Callback when visiting a block.
  **
  virtual Void visitBlock(Block block) {}

//////////////////////////////////////////////////////////////////////////
// Stmt Callbacks
//////////////////////////////////////////////////////////////////////////

  **
  ** Callback when entering a stmt.
  **
  virtual Void enterStmt(Stmt stmt) {}

  **
  ** Callback when exiting a stmt.
  **
  virtual Void exitStmt(Stmt stmt) {}

  **
  ** Callback when visiting a stmt.  Return a list to replace
  ** the statement with new statements, or return null to
  ** keep existing statement.
  **
  virtual Stmt[]? visitStmt(Stmt stmt) { null }

  **
  ** Callback when entering a finally block
  **
  virtual Void enterFinally(TryStmt stmt) {}

  **
  ** Callback when exiting a finally block
  **
  virtual Void exitFinally(TryStmt stmt) {}

//////////////////////////////////////////////////////////////////////////
// Expr Callbacks
//////////////////////////////////////////////////////////////////////////

  **
  ** Call to visit an expression.  Return expr or a new
  ** expression if doing a replacement for the expression in
  ** the abstract syntax tree.
  **
  virtual Expr visitExpr(Expr expr) { expr }
}

**************************************************************************
** VisitDepth
**************************************************************************

**
** VisitDepth enumerates how deep to traverse the AST
**
enum class VisitDepth { typeDef, slotDef, stmt, expr }

**************************************************************************
** ExprVisitor
**************************************************************************

**
** ExprVisitor implements a Visitor which visits
** each expr using a closure.
**
internal class ExprVisitor : Visitor
{
  new make(|Expr expr->Expr| func)
  {
    this.func = func
  }

  override Expr visitExpr(Expr expr)
  {
    return (Expr)func.call(expr)
  }

  |Expr expr->Expr| func
}

**************************************************************************
** TreeWriter
**************************************************************************

/*
class TreeWriter : AstWriter mixin Visitor
{
  new make(OutStream out := Env.cur.out) : super(out) {}
  override Void enterTypeDef(TypeDef def) { w(def.qname).nl; indent }
  override Void exitTypeDef(TypeDef def) { unindent }

  override Void enterFieldDef(FieldDef def) { w(def).nl; indent }
  override Void exitFieldDef(FieldDef def) { unindent }

  override Void enterMethodDef(MethodDef def) { w(def).nl; indent }
  override Void exitMethodDef(MethodDef def) { unindent }

  override Void enterBlock(Block b) { w("{").nl; indent }
  override Void exitBlock(Block b) { unindent; w("}").nl }

  override Void enterStmt(Stmt s) { w(s.id).nl; indent }
  override Void exitStmt(Stmt s) { unindent }

  override Void enterExpr(Expr expr) { w(expr).nl; indent }
  override Void exitExpr(Expr expr) { unindent  }
  override Expr visitExpr(Expr expr) {  return expr }
}
*/