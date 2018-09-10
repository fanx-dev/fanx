//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   9 Apr 09  Brian Frank  Creation
//

**
** MockSlot are special slots used between the compiler
** and runtime but not publically exposed by reflection.
**
abstract class MockSlot : CSlot
{
  new make(CType parent, Str name, Int flags)
  {
    this.parent = parent
    this.name   = name
    this.flags  = flags
  }

  override CType parent
  override Str name
  override Int flags
  override Str qname() { parent.qname + "." + name }
  override Str signature() { qname }
  override CFacet? facet(Str qname) { null }
}

**************************************************************************
** MockField
**************************************************************************

class MockField : MockSlot, CField
{
  new make(CType parent, Str name, Int flags, CType of)
    : super(parent, name, flags)
  {
    this.fieldType = of
  }

  override CType fieldType
  override CMethod? getter() { null }
  override CMethod? setter() { null }
  override CType inheritedReturnType() { fieldType }
}

**************************************************************************
** MockMethod
**************************************************************************

class MockMethod : MockSlot, CMethod
{
  new make(CType parent, Str name, Int flags, CType ret, CType[] params)
    : super(parent, name, flags)
  {
    this.parent = parent
    this.returnType = ret
    this.params = params.map |CType p, Int i->CParam| { MockParam("p$i", p) }
  }

  override CType returnType
  override CType inheritedReturnType() { returnType }
  override CParam[] params
}

**************************************************************************
** MockParam
**************************************************************************

class MockParam : CParam
{
  new make(Str name, CType of)
  {
    this.name = name
    this.paramType = of
  }

  override Str name
  override CType paramType
  override Bool hasDefault() { false }
}