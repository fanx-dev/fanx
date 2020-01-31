//
// Copyright (c) 2007, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   30 Aug 07  Brian Frank  Creation
//

**
** FacetDef models a facet declaration.
**
class FacetDef : Node, CFacet
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  new make(Loc loc, TypeRef type)
    : super(loc)
  {
    this.type = type
  }

//////////////////////////////////////////////////////////////////////////
// Facet
//////////////////////////////////////////////////////////////////////////

  override Str qname() { type.qname }

  override Obj? get(Str name)
  {
    i := names.index(name)
    if (i == -1) return null
    literal := vals[i] as LiteralExpr
    if (literal == null) return null
    return literal.val
  }

//  Str serialize()
//  {
//    if (names.isEmpty) return ""
//    s := StrBuf()
//
//    // serialized FFI types as name/value map for easy parsing
//    if (type.isForeign)
//    {
//      s.addChar('[')
//      names.each |n, i|
//      {
//        s.add(n.toCode).addChar(':').add(vals[i].serialize).addChar(',')
//      }
//      s.addChar(']')
//    }
//
//    // serialize normal Fantom types as a complex
//    else
//    {
//      s.add(type.qname).addChar('{')
//      names.each |n, i|
//      {
//        s.add(n).addChar('=').add(vals[i].serialize).addChar(';')
//      }
//      s.addChar('}')
//    }
//
//    return s.toStr
//  }

//////////////////////////////////////////////////////////////////////////
// Tree
//////////////////////////////////////////////////////////////////////////

  Void walk(Visitor v)
  {
    vals = Expr.walkExprs(v, vals)
  }

//////////////////////////////////////////////////////////////////////////
// Debug
//////////////////////////////////////////////////////////////////////////

  override Str toStr() { "@$type" }

  override Void print(AstWriter out) { out.w(toStr).nl }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  TypeRef type
  Str[] names := Str[,]
  Expr[] vals := Expr[,]
}