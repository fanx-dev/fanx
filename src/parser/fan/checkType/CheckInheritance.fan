//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//    2 Dec 05  Brian Frank  Creation (originally InitShimSlots)
//   23 Sep 06  Brian Frank  Ported from Java to Fan
//

**
** CheckInheritance is used to check invalid extends or mixins.
**
class CheckInheritance : CompilerStep
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(CompilerContext compiler)
    : super(compiler)
  {
  }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  override Void run()
  {
    //debug("CheckInheritance")
    walkUnits(VisitDepth.typeDef)
  }

  override Void visitTypeDef(TypeDef t)
  {
    if (t.baseSpecified && t.base != null) {
      if (t.base.qname == "sys::Facet") err("Cannot inherit 'Facet' explicitly", t.loc)
      if (t.base.qname == "sys::Enum")  err("Cannot inherit 'Enum' explicitly", t.loc)
    }
    
    // check out of order base vs mixins first
    if (!checkOutOfOrder(t)) return

    // check extends
    checkExtends(t, t.base)

    // check each mixin
    t.mixins.each |CType m| { checkMixin(t, m) }
    
    
    checkCyclicInheritance(t)
  }

//////////////////////////////////////////////////////////////////////////
// Checks
//////////////////////////////////////////////////////////////////////////

  private Bool checkOutOfOrder(TypeDef t)
  {
    if (!t.baseSpecified)
    {
      cls := t.mixins.find |CType x->Bool| { !x.isMixin }
      if (cls != null)
      {
        err("Invalid inheritance order, ensure class '$cls' comes first before mixins", t.loc)
        return false
      }
    }
    return true
  }

  private Void checkExtends(TypeDef t, CType? base)
  {
    // base is null only for sys::Obj
    if (base == null && t.qname == "sys::Obj")
      return

    // ensure mixin doesn't extend class
    if (t.isMixin && t.baseSpecified)
      err("Mixin '$t.name' cannot extend class '$base'", t.loc)

    // ensure enum doesn't extend class
    if (t.isEnum && t.baseSpecified)
      err("Enum '$t.name' cannot extend class '$base'", t.loc)

    // ensure facet doesn't extend class
    if (t.isFacet && t.baseSpecified)
      err("Facet '$t.name' cannot extend class '$base'", t.loc)

    // check extends a mixin
    if (base.isMixin)
      err("Class '$t.name' cannot extend mixin '$base'", t.loc)

    // check extends parameterized type
    if (!base.isParameterized && base.typeDef.isGeneric)
      err("Class '$t.name' cannot extend generic type '$base'", t.loc)

    // check extends final
    if (base.isFinal)
      err("Class '$t.name' cannot extend final class '$base'", t.loc)

    // check extends internal scoped outside my pod
    if (base.isInternal && t.podName != base.podName)
      err("Class '$t.name' cannot access internal scoped class '$base'", t.loc)
  }

  private Void checkMixin(TypeDef t, CType m)
  {
    // check mixins a class
    if (!m.isMixin)
    {
      if (t.isMixin)
        err("Mixin '$t.name' cannot extend class '$m'", t.loc)
      else
        err("Class '$t.name' cannot mixin class '$m'", t.loc)
    }

    // check extends internal scoped outside my pod
    if (m.isInternal && t.podName != m.podName)
      err("Type '$t.name' cannot access internal scoped mixin '$m'", t.loc)
  }
  
  private Void checkCyclicInheritance(TypeDef t) {
    allInheritances := Str:CType[:]
    getInheritances(allInheritances, t.asRef())
    if (allInheritances.containsKey(t.qname)) {
      err("Cyclic inheritance for '$t.name'", t.loc)
      t.inheritances.clear
      t.inheritances.add(ns.objType)
    }
  }
  
  private Void getInheritances([Str:CType] acc, CType t) {
    t.inheritances.each |p| {
      pt := acc[p.qname]
      if (pt == null) {
        acc[p.qname] = p
        getInheritances(acc, p)
      }
    }
  }

}