//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   6 Jun 06  Brian Frank  Creation
//

**
** ReflectType is the implementation of CType for a type imported
** from a precompiled pod (as opposed to a TypeDef within the compilation
** units being compiled).
**
class ReflectType : CType
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Construct with loaded Type.
  **
  new make(ReflectNamespace ns, Type t)
  {
    this.pod     = ns.importPod(t.pod)
    this.t       = t
    this.base    = ns.importType(t.base)
    this.mixins  = ns.importTypes(t.mixins)
    //this.isVal   = t.isVal
  }

//////////////////////////////////////////////////////////////////////////
// CType
//////////////////////////////////////////////////////////////////////////

  override ReflectNamespace ns() { pod.ns }
  override Str name()      { t.name }
  override Str qname()     { t.qname }
  override Str extName() { "" }//TODO
  //override Str signature() { t.signature }
  override Int flags()     { (Int)t->flags }

  override Bool isVal() { t.isVal }

  override Bool isNullable() { false }
  override once CType toNullable() { NullableType(this) }

  override Bool isGeneric() { t.isGeneric }
  override Bool isParameterized() { !t.params.isEmpty }
  override Bool isGenericParameter() { pod === ns.sysPod && name.size == 1 }

  override once CType toListOf() { ListType(this) }

  override CFacet? facet(Str qname)
  {
    try
      return ReflectFacet.map(ns, t.facet(Type.find(qname), false))
    catch (Err e)
      e.trace
    return null
  }

  override Str:CSlot slots()
  {
    if (!slotsLoaded)
    {
      slotsLoaded = true
      if (!isGenericParameter)
      {
        t.slots.each |Slot s|
        {
          if (slotMap[s.name] == null)
            slotMap[s.name] = ns.importSlot(s)
        }
      }
    }
    return slotMap
  }

  override once COperators operators() { COperators(this) }

  override CSlot? slot(Str name)
  {
    cs := slotMap[name]
    if (cs == null)
    {
      s := t.slot(name, false)
      if (s != null)
        slotMap[name] = cs = ns.importSlot(s)
    }
    return cs
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  const Type t
  override ReflectPod pod { private set }
  override CType? base    { private set }
  override CType[] mixins { private set }
  private Str:CSlot slotMap := Str:CSlot[:]
  private Bool slotsLoaded := false

}