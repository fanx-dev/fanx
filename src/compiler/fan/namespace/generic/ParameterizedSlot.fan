//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Jul 06  Brian Frank  Creation
//


**************************************************************************
** ParameterizedField
**************************************************************************

class ParameterizedField : CField
{
  new make(ParameterizedType parent, CField generic)
  {
    this.parent = parent
    this.generic = generic
    this.fieldType = parent.parameterize(generic.fieldType)
    this.getter = generic.getter == null ? null : ParameterizedMethod(parent, generic.getter)
    this.setter = generic.setter == null ? null : ParameterizedMethod(parent, generic.setter)
  }

  override Str name()  { generic.name }
  override Str qname() { generic.qname }
  override Str signature() { generic.signature }
  override Int flags() { generic.flags }
  override CFacet? facet(Str qname) { generic.facet(qname) }

  override CType fieldType
  override CMethod? getter
  override CMethod? setter
  override CType inheritedReturnType() { fieldType }

  override Bool isParameterized() { true }

  override CType parent { private set }
  override CField? generic { private set }
}

**************************************************************************
** ParameterizedMethod
**************************************************************************

**
** ParameterizedMethod models a parameterized CMethod
**
class ParameterizedMethod : CMethod
{
  new make(ParameterizedType parent, CMethod generic)
  {
    this.parent = parent
    this.generic = generic

    this.returnType = parent.parameterize(generic.returnType)
    this.params = generic.params.map |CParam p->CParam|
    {
      if (!p.paramType.hasGenericParameter)
        return p
      else
        return ParameterizedMethodParam(parent, p)
    }

    signature = "$returnType $name(" + params.join(", ") + ")"
  }

  override Str name()  { generic.name }
  override Str qname() { generic.qname }
  override Int flags() { generic.flags }
  override CFacet? facet(Str qname) { generic.facet(qname) }

  override Bool isParameterized()  { true }

  override CType inheritedReturnType()  { generic.inheritedReturnType }

  override CType parent     { private set }
  override Str signature    { private set }
  override CMethod? generic { private set }
  override CType returnType { private set }
  override CParam[] params  { private set }
}

**************************************************************************
** ParameterizedMethodParam
**************************************************************************

class ParameterizedMethodParam : CParam
{
  new make(ParameterizedType parent, CParam generic)
  {
    this.generic = generic
    this.paramType = parent.parameterize(generic.paramType)
  }

  override Str name() { generic.name }
  override Bool hasDefault() { generic.hasDefault }
  override Str toStr() { "$paramType $name" }

  override CType paramType { private set }
  private CParam generic { private set }
}