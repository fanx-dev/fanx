//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   11 Sep 09  Andy Frank  Creation
//

using compiler

**
** JsStmt
**
abstract class JsStmt : JsNode
{
  new make(JsCompilerSupport s, Stmt? stmt := null) : super(s, stmt)
  {
  }

  static JsStmt makeFor(JsCompilerSupport s, Stmt stmt)
  {
    switch (stmt.id)
    {
      case StmtId.nop:          return JsNoOpStmt(s)
      case StmtId.expr:         return JsExprStmt(s, stmt)
      case StmtId.localDef:     return JsLocalDefStmt(s, stmt)
      case StmtId.ifStmt:       return JsIfStmt(s, stmt)
      case StmtId.returnStmt:   return JsReturnStmt(s, stmt)
      case StmtId.throwStmt:    return JsThrowStmt(s, stmt)
      case StmtId.forStmt:      return JsForStmt(s, stmt)
      case StmtId.whileStmt:    return JsWhileStmt(s, stmt)
      case StmtId.breakStmt:    return JsBreakStmt(s)
      case StmtId.continueStmt: return JsContinueStmt(s)
      case StmtId.tryStmt:      return JsTryStmt(s, stmt)
      case StmtId.switchStmt:   return JsSwitchStmt(s, stmt)
      default: throw s.err("Unknown StmtId: $stmt.id", stmt.loc)
    }
  }
}

**************************************************************************
** JsNoOpStmt
**************************************************************************

class JsNoOpStmt : JsStmt
{
  new make(JsCompilerSupport s) : super(s) {}
  override Void write(JsWriter out) {}
}

**************************************************************************
** JsExprStmt
**************************************************************************

class JsExprStmt : JsStmt
{
  new make(JsCompilerSupport s, ExprStmt stmt) : super(s, stmt)
  {
    this.expr = JsExpr.makeFor(s, stmt.expr)
  }
  override Void write(JsWriter out)
  {
    expr.write(out)
  }
  JsExpr expr
}

**************************************************************************
** JsLocalDefStmt
**************************************************************************

class JsLocalDefStmt : JsStmt
{
  new make(JsCompilerSupport s, LocalDefStmt lds) : super(s, lds)
  {
    this.lds  = lds
    this.name = lds.name
    this.init = (lds.init != null) ? JsExpr.makeFor(s, lds.init) : null
  }
  override Void write(JsWriter out)
  {
    out.w("var ", lds.loc)
    if (init == null) out.w(name, lds.loc)
    else init.write(out)
  }
  LocalDefStmt lds
  Str name
  JsExpr? init
}

**************************************************************************
** JsIfStmt
**************************************************************************

class JsIfStmt : JsStmt
{
  new make(JsCompilerSupport s, IfStmt fs) : super(s)
  {
    this.cond = JsExpr.makeFor(s, fs.condition)
    this.trueBlock  = JsBlock(s, fs.trueBlock)
    this.falseBlock = (fs.falseBlock != null) ? JsBlock(s, fs.falseBlock) : null
  }

  override Void write(JsWriter out)
  {
    out.w("if ("); cond.write(out); out.w(")").nl
    out.w("{").nl
    out.indent
    trueBlock.write(out)
    out.unindent
    out.w("}").nl
    if (falseBlock != null)
    {
      out.w("else").nl
      out.w("{").nl
      out.indent
      falseBlock.write(out)
      out.unindent
      out.w("}").nl
    }
  }

  JsExpr cond
  JsBlock trueBlock
  JsBlock? falseBlock
}

**************************************************************************
** JsReturnStmt
**************************************************************************

class JsReturnStmt : JsStmt
{
  new make(JsCompilerSupport s, ReturnStmt rs) : super(s)
  {
    expr = (rs.expr != null) ? JsExpr.makeFor(s, rs.expr) : null
  }
  override Void write(JsWriter out)
  {
    out.w("return")
    if (expr != null)
    {
      out.w(" ")
      expr.write(out)
    }
  }
  JsExpr? expr
}

**************************************************************************
** JsThrowStmt
**************************************************************************

class JsThrowStmt : JsStmt
{
  new make(JsCompilerSupport s, ThrowStmt ts) : super(s)
  {
    this.expr = JsExpr.makeFor(s, ts.exception)
  }
  override Void write(JsWriter out)
  {
    out.w("throw ")
    expr.write(out)
  }
  JsExpr? expr
}

**************************************************************************
** JsForStmt
**************************************************************************

class JsForStmt : JsStmt
{
  new make(JsCompilerSupport s, ForStmt fs) : super(s)
  {
    this.init   = (fs.init != null) ? JsStmt.makeFor(s, fs.init) : null
    this.cond   = (fs.condition != null) ? JsExpr.makeFor(s, fs.condition) : null
    this.update = (fs.update != null) ? JsExpr.makeFor(s, fs.update) : null
    this.block  = (fs.block != null) ? JsBlock(s, fs.block) : null
  }

  override Void write(JsWriter out)
  {
    out.w("for ("); init?.write(out); out.w("; ")
      cond?.write(out); out.w("; ")
      update?.write(out); out.w(")").nl
    out.w("{").nl
    out.indent
    block?.write(out)
    out.unindent
    out.w("}").nl
  }

  JsStmt? init
  JsExpr? cond
  JsExpr? update
  JsBlock? block
}

**************************************************************************
** JsWhileStmt
**************************************************************************

class JsWhileStmt : JsStmt
{
  new make(JsCompilerSupport s, WhileStmt ws) : super(s)
  {
    this.cond  = JsExpr.makeFor(s, ws.condition)
    this.block = JsBlock(s, ws.block)
  }

  override Void write(JsWriter out)
  {
    out.w("while ("); cond.write(out); out.w(")").nl
    out.w("{").nl
    out.indent
    block.write(out)
    out.unindent
    out.w("}").nl
  }

  JsExpr cond
  JsBlock block
}

**************************************************************************
** JsBreakStmt
**************************************************************************

class JsBreakStmt : JsStmt
{
  new make(JsCompilerSupport s) : super(s) {}
  override Void write(JsWriter out) { out.w("break") }
}

**************************************************************************
** JsContinueStmt
**************************************************************************

class JsContinueStmt : JsStmt
{
  new make(JsCompilerSupport s) : super(s) {}
  override Void write(JsWriter out) { out.w("continue") }
}

**************************************************************************
** JsTryStmt
**************************************************************************

class JsTryStmt : JsStmt
{
  new make(JsCompilerSupport s, TryStmt ts) : super(s)
  {
    this.block  = (ts.block != null) ? JsBlock(s, ts.block) : null
    this.catches = ts.catches.map |c->JsCatch| { JsCatch(s, c) }
    this.finallyBlock = (ts.finallyBlock != null) ? JsBlock(s, ts.finallyBlock) : null
  }

  override Void write(JsWriter out)
  {
    out.w("try").nl
    out.w("{").nl
    out.indent
    block?.write(out)
    out.unindent
    out.w("}").nl

    if (!catches.isEmpty) writeCatches(out)

    if (finallyBlock != null)
    {
      out.w("finally").nl
      out.w("{").nl
      out.indent
      finallyBlock.write(out)
      out.unindent
      out.w("}").nl
    }
  }

  private Void writeCatches(JsWriter out)
  {
    var := support.unique
    hasTyped    := catches.any |c| { c.qname != null }
    hasCatchAll := catches.any |c| { c.qname == null }

    out.w("catch ($var)").nl
    out.w("{").nl
    out.indent
    if (hasTyped) out.w("$var = fan.sys.Err.make($var);").nl

    doElse := false
    catches.each |c|
    {
      if (c.qname != null)
      {
        if (doElse) out.w("else ")
        else doElse = true

        out.w("if ($var instanceof $c.qname)").nl
        out.w("{").nl
        out.indent
        out.w("var $c.var = $var;").nl
        c.write(out)
        out.unindent
        out.w("}").nl
      }
      else
      {
        hasElse := catches.size > 1
        if (hasElse)
        {
          out.w("else").nl
          out.w("{").nl
          out.indent
        }
        c.write(out)
        if (hasElse)
        {
          out.unindent
          out.w("}").nl
        }
      }
    }

    if (!hasCatchAll)
    {
      out.w("else").nl
      out.w("{").nl
      out.indent
      out.w("throw $var;").nl
      out.unindent
      out.w("}").nl
    }
    out.unindent
    out.w("}").nl
  }

  JsBlock? block         // try block
  JsCatch[] catches      // catch blocks
  JsBlock? finallyBlock  // finally block
}

**************************************************************************
** JsCatch
**************************************************************************

class JsCatch : JsNode
{
  new make(JsCompilerSupport s, Catch c) : super(s)
  {
    this.var   = c.errVariable ?: support.unique
    this.qname = (c.errType != null) ? qnameToJs(c.errType) : null
    this.block = (c.block != null) ? JsBlock(s, c.block) : null
  }
  override Void write(JsWriter out)
  {
    block?.write(out)
  }
  Str var          // name of expection variable
  Str? qname       // qname of err type
  JsBlock? block   // catch block
}

**************************************************************************
** JsSwitchStmt
**************************************************************************

class JsSwitchStmt : JsStmt
{
  new make(JsCompilerSupport s, SwitchStmt ss) : super(s)
  {
    this.cond  = JsExpr.makeFor(s, ss.condition)
    this.cases = ss.cases.map |c->JsCase| { JsCase(s, c) }
    this.defBlock = (ss.defaultBlock != null) ? JsBlock(s, ss.defaultBlock) : null
  }

  override Void write(JsWriter out)
  {
    var := support.unique
    out.w("var $var = "); cond.write(out); out.w(";").nl
    cases.each |c, i|
    {
      if (i > 0) out.w("else ")
      out.w("if (")
      c.cases.each |e, j|
      {
        if (j > 0) out.w(" || ")
        out.w("fan.sys.ObjUtil.equals($var,"); e.write(out); out.w(")")
      }
      out.w(")").nl
      out.w("{").nl
      out.indent
      c.block?.write(out)
      out.unindent
      out.w("}").nl
    }
    if (defBlock != null)
    {
      if (!cases.isEmpty)
      {
        out.w("else").nl
        out.w("{").nl
        out.indent
        defBlock.write(out)
        out.unindent
        out.w("}").nl
      }
      else { defBlock.write(out) }
    }
  }

  JsExpr cond         // switch condition
  JsCase[] cases      // case stmts
  JsBlock? defBlock   // default case

}

**************************************************************************
** JsCase
**************************************************************************

class JsCase : JsNode
{
  new make(JsCompilerSupport s, Case c) : super(s)
  {
    this.cases = c.cases.map |ex->JsExpr| { JsExpr.makeFor(s, ex) }
    this.block = (c.block != null) ? JsBlock(s, c.block) : null
  }
  override Void write(JsWriter out)
  {
    block?.write(out)
  }
  JsExpr[] cases
  JsBlock? block
}
