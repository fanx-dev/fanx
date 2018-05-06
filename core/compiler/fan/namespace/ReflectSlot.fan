//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   29 Aug 06  Brian Frank  Creation
//

**
** ReflectSlot is the implementation of CSlot for a slot imported
** from a precompiled pod (as opposed to a SlotDef within the
** compilation units being compiled).
**
abstract class ReflectSlot : CSlot
{
  override Str name()       { slot.name }
  override Str qname()      { slot.qname }
  override Str signature()  { slot.signature }
  override once Int flags() { slot->flags } // undocumented trap
  abstract Slot slot()

  override CFacet? facet(Str qname)
  {
    try
      return ReflectFacet.map(ns, slot.facet(Type.find(qname), false))
    catch (Err e)
      e.trace
    return null
  }
}

**************************************************************************
** ReflectField
**************************************************************************

class ReflectField : ReflectSlot, CField
{
  new make(ReflectNamespace ns, CType parent, Field f)
  {
    this.ns = ns
    this.parent = parent
    this.f = f
    this.fieldType = ns.importType(f.type)
    get := (Method?)f->getter; if (get != null) this.getter = ns.importMethod(get)
    set := (Method?)f->setter; if (set != null) this.setter = ns.importMethod(set)
  }

  override ReflectNamespace ns
  override CType parent

  override Slot slot() { f }

  override CType inheritedReturnType()
  {
    if (!isOverride || getter == null) return fieldType
    else return getter.inheritedReturnType
  }

  override CType fieldType { private set }
  override CMethod? getter { private set }
  override CMethod? setter { private set }
  Field f                  { private set }
}

**************************************************************************
** ReflectMethod
**************************************************************************

class ReflectMethod : ReflectSlot, CMethod
{
  new make(ReflectNamespace ns, CType parent, Method m)
  {
    this.ns = ns
    this.parent = parent
    this.m = m
    this.returnType = ns.importType(m.returns)
    this.params = m.params.map |Param p->CParam| { ReflectParam(ns, p) }
    this.isGeneric = calcGeneric(this)
  }

  override ReflectNamespace ns
  override CType parent

  override Slot slot() { m }

  override CType inheritedReturnType()
  {
    // use trap to access undocumented hook
    if (isOverride || returnType.isThis)
      return ns.importType((Type)m->inheritedReturnType)
    else
      return returnType
  }

  override CType returnType { private set }
  override CParam[] params  { private set }
  override Bool isGeneric   { private set }
  Method m                  { private set }
}

**************************************************************************
** ReflectParam
**************************************************************************

class ReflectParam : CParam
{
  new make(ReflectNamespace ns, Param p)
  {
    this.p = p
    this.paramType = ns.importType(p.type)
  }

  override Str name() { p.name }
  override Bool hasDefault() { p.hasDefault }

  override CType paramType { private set }
  Param p                  { private set }
}

**************************************************************************
** ReflectFacet
**************************************************************************

class ReflectFacet : CFacet
{
  static ReflectFacet? map(ReflectNamespace ns, Facet? f)
  {
    if (f == null) return null
    return make(f)
  }
  private new make(Facet f) { this.f = f }
  override Str qname() { f.typeof.qname }
  override Obj? get(Str name) { f.typeof.field(name, false)?.get(f) }
  override Str toStr() { f.toStr }
  Facet f
}