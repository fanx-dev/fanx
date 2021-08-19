//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   9 Jul 09  Andy Frank  Creation
//

using compilerx

**
** JsBlock
**
class JsBlock : JsNode
{
  new make(JsCompilerSupport support, Block block) : super(support)
  {
    this.stmts = block.stmts.map |s->JsStmt| { JsStmt.makeFor(support, s) }
  }

  override Void write(JsWriter out)
  {
    stmts.each |s|
    {
      s.write(out)
      out.w(";").nl
    }
  }

  JsStmt[] stmts   // statements for this block
}