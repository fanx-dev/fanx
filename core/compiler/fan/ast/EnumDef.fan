//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Apr 06  Brian Frank  Creation
//   19 Jul 06  Brian Frank  Ported from Java to Fan
//

**
** EnumDef is used to define one ordinal/named enum value in
** an enum TypeDef.  If using a custom constructor, it includes
** the constructor arguments.
**
class EnumDef : Node
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  new make(Loc loc, DocDef? doc, FacetDef[]? facets, Str name, Int ordinal)
    : super(loc)
  {
    this.doc      = doc
    this.facets   = facets
    this.name     = name
    this.ordinal  = ordinal
    this.ctorArgs = Expr[,]
  }

//////////////////////////////////////////////////////////////////////////
// Debug
//////////////////////////////////////////////////////////////////////////

  override Str toStr()
  {
    return "$ordinal:$name"
  }

  override Void print(AstWriter out)
  {
    out.w(name)
    if (!ctorArgs.isEmpty)
      out.w("(").w(ctorArgs.join(", ")).w(")")
    out.w("  // ").w(ordinal).nl
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  DocDef? doc
  FacetDef[]? facets
  Int ordinal
  Str name
  Expr[] ctorArgs
}