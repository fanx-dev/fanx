//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Jul 06  Brian Frank  Creation
//

**
** ParamDef models the definition of a method parameter.
**
class ParamDef : MethodVar, CParam
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  new make(Loc loc, CType paramType, Str name, Expr? def := null)
    : super(loc, paramType, name)
  {
//    this.paramType = paramType
//    this.name = name
    this.def  = def
    flags = FConst.Param
  }

//////////////////////////////////////////////////////////////////////////
// CParam
//////////////////////////////////////////////////////////////////////////

  override Bool hasDefault() { def != null }

//////////////////////////////////////////////////////////////////////////
// Debug
//////////////////////////////////////////////////////////////////////////

  override Str toStr()
  {
    return "$paramType $name"
  }

  override Void print(AstWriter out)
  {
    out.w(name).w(" : ").w(paramType)
    if (def != null) { out.w(" = "); def.print(out) }
  }
  
  override ParamDef? paramDef() { this }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  override CType paramType() { super.ctype }   // type of parameter
//  override Str name          // local variable name
  Expr? def                  // default expression

}