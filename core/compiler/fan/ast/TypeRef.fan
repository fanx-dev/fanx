//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   5 Jul 06  Brian Frank  Creation
//

**
** TypeRef models a type reference such as an extends clause or a
** method parameter.  Really it is just an AST node wrapper for a
** CType that let's us keep track of the source code Loc.
**
class TypeRef : Node, CType
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  new make(Loc loc, CType t)
    : super(loc)
  {
    this.t = t
  }

//////////////////////////////////////////////////////////////////////////
// CType
//////////////////////////////////////////////////////////////////////////

  override CNamespace ns() { t.ns }
  override CPod pod()      { t.pod }
  override Str name()      { t.name }
  override Str qname()     { t.qname }
  override Str extName()   { t.extName }
  //override Str signature() { t.signature }
  override CType deref()   { t }
  override Bool isForeign() { t.isForeign }
  override Int flags()     { t.flags }

  override CFacet? facet(Str qname) { t.facet(qname) }

  override CType? base() { t.base }
  override CType[] mixins() { t.mixins }
  override Bool fits(CType that) { t.fits(that) }

  override Bool isValid() { t.isValid }

  override Bool isVal() { t.isVal }

  override Bool isNullable() { t.isNullable }
  override CType toNullable() { t.toNullable }
  override CType toNonNullable() { t.toNonNullable }

  override CType inferredAs() { t.inferredAs }

  override Bool isGeneric() { t.isGeneric }
  override Bool isParameterized() { t.isParameterized }
  override Bool isGenericParameter() { t.isGenericParameter }
  override CType parameterizeThis(CType thisType) { t.parameterizeThis(thisType) }
  override CType toListOf() { t.toListOf }

  override CSlot? slot(Str name) { t.slot(name) }
  override CField? field(Str name) { t.field(name) }
  override CMethod? method(Str name) { t.method(name) }
  override Str:CSlot slots() { t.slots }
  override COperators operators() { t.operators }

//////////////////////////////////////////////////////////////////////////
// Debug
//////////////////////////////////////////////////////////////////////////

  override Void print(AstWriter out)
  {
    out.w(t.toStr)
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  CType t { private set }

}