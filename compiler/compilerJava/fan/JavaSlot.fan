//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   17 Nov 08  Brian Frank  Creation
//

using compiler

**
** JavaSlot is the implementation of CSlot for a Java member.
**
abstract class JavaSlot : CSlot
{
  new make(CType parent, Str name, Int flags)
  {
    this.parent = parent
    this.name   = name
    this.flags  = flags
  }

  override CNamespace ns() { return parent.ns }
  override CType parent
  override Str name
  override once Str qname() { return parent.qname + "." + name }
  override Int flags
  override CFacet? facet(Str qname) { null }

  override Bool isForeign() { return true }

  ** Clone without next linked list
  abstract This dup()

  ** linked list of overloaded methods (first one
  ** may be field or method)
  JavaMethod? next
}

**************************************************************************
** JavaField
**************************************************************************

**
** JavaField is the implementation of CField for a Java field.
**
class JavaField : JavaSlot, CField
{
  new make(CType parent, Str name, Int flags, CType type)
    : super(parent, name, flags)
  {
    this.fieldType = type
  }

  override This dup() { make(parent, name, flags, fieldType) }

  override CType fieldType
  override CMethod? getter
  override CMethod? setter

  override Str signature() { return "$fieldType $name" }
  override CType inheritedReturnType() { return fieldType }

}

**************************************************************************
** JavaMethod
**************************************************************************

**
** JavaMethod is the implementation of CMethod for a Java method.
**
class JavaMethod : JavaSlot, CMethod
{
  new make(CType parent, Str name, Int flags, CType ret, CParam[] params := [,])
    : super(parent, name, flags)
  {
    this.returnType = ret
    this.params = params
  }

  override CType parent
  override CType returnType
  override CParam[] params
  override Bool isGeneric

  override This dup() { make(parent, name, flags, returnType, params) }

  override Str signature() { return "$returnType $name(" + params.join(",") + ")" }
  override CType inheritedReturnType() { return returnType }

  Void setParamTypes(CType[] types)
  {
    params = types.map |CType t, Int i->CParam| { JavaParam("p$i", t) }
  }

  override CFacet? facet(Str qname)
  {
    // automatically give get/set methods the Operator facet
    if (qname == "sys::Operator")
    {
      if ((name == "get" && params.size == 1) ||
          (name == "set" && params.size == 2))
        return MarkerFacet(qname)
    }
    return null
  }

  ** Does given method have the exact same signature (ignoring declaring class)
  Bool sigsEqual(JavaMethod m)
  {
    this.name == m.name &&
    this.params.size == m.params.size &&
    this.params.all |p, i| { p.paramType == m.params[i].paramType }
  }
}

**************************************************************************
** JavaParam
**************************************************************************

**
** JavaParam is the implementation of CParam for a Java method parameter.
**
class JavaParam : CParam
{
  new make(Str n, CType t) { name = n; paramType = t }
  override Str name
  override Bool hasDefault
  override CType paramType
  override Str toStr() { return "$paramType $name" }
}