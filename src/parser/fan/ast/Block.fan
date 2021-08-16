//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Jul 06  Brian Frank  Creation
//

**
** Block is a list of zero or more Stmts
**
class Block : Node
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  new make(Loc loc)
    : super(loc)
  {
    stmts = Stmt[,]
    vars = MethodVar[,]
  }

//////////////////////////////////////////////////////////////////////////
// Stmts
//////////////////////////////////////////////////////////////////////////

  **
  ** Return is there are no statements
  **
  Bool isEmpty() { stmts.isEmpty }

  **
  ** Return number of statements
  **
  Int size() { stmts.size }

  **
  ** Does this block always cause us to exit the method (does the
  ** last statement return true for Stmt.isExit)
  **
  Bool isExit()
  {
    if (stmts.isEmpty) return false
    return stmts.last.isExit
  }

  **
  ** Return if any of the statements perform definite assignment.
  **
  Bool isDefiniteAssign(|Expr lhs->Bool| f)
  {
    return stmts.any |Stmt s->Bool| { s.isDefiniteAssign(f) }
  }

  **
  ** Append a statement
  **
  Void add(Stmt stmt)
  {
    stmts.add(stmt)
  }

  **
  ** Append a list of statements
  **
  Void addAll(Stmt[] stmts)
  {
    this.stmts.addAll(stmts)
  }

//////////////////////////////////////////////////////////////////////////
// Tree
//////////////////////////////////////////////////////////////////////////

  Void walkExpr(|Expr expr->Expr| closure)
  {
    walk(ExprVisitor(closure), VisitDepth.expr)
  }

  Void walk(Visitor v, VisitDepth depth)
  {
    v.enterBlock(this)
    if (v.isReadOnly) {
        stmts.each |Stmt stmt|
        {
          r := stmt.walk(v, depth)
          if (r != null) throw Err("Expected return null for readonly Visitor")
        }
    }
    else {
        copy := Stmt[,]
        copy.capacity = stmts.size
        stmts.each |Stmt stmt|
        {
          r := stmt.walk(v, depth)
          if (r == null) copy.add(stmt)
          else copy.addAll(r)
        }
        stmts = copy
    }
    v.visitBlock(this)
    v.exitBlock(this)
  }
  
  override Void getChildren(CNode[] list, [Str:Obj]? options) {
    stmts.each |stmt| {
      list.add(stmt)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Debug
//////////////////////////////////////////////////////////////////////////

  override Void print(AstWriter out) { printOpt(out) }

  Void printOpt(AstWriter out, Bool braces := true)
  {
    if (braces) out.w("{").nl
    out.indent
    stmts.each |Stmt stmt| { stmt.print(out) }
    out.unindent
    if (braces) out.w("}").nl
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  Stmt[] stmts
  
  MethodVar[] vars
  
  ClosureExpr? parentClosure
}