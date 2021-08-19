//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 May 09  Brian Frank  Creation
//

**
** RegexDslPlugin is used to create a Regex instance from a raw string.
**
class RegexDslPlugin : DslPlugin
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Constructor with associated compiler.
  **
  new make(CompilerContext c) : super(c) {}

//////////////////////////////////////////////////////////////////////////
// Namespace
//////////////////////////////////////////////////////////////////////////

  **
  ** Find a DSL plugin for the given anchor type.  If there
  ** is a problem then log an error and return null.
  **
  override Expr compile(DslExpr dsl)
  {
    regexType := ns.resolveType("std::Regex")
    fromStr := regexType.method("fromStr")
    args := [Expr.makeForLiteral(dsl.loc, dsl.src)]
    return CallExpr.makeWithMethod(dsl.loc, null, fromStr, args)
  }

}