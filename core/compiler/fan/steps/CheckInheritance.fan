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

  new make(Compiler compiler)
    : super(compiler)
  {
  }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  override Void run()
  {
    log.debug("CheckInheritance")
    walk(compiler, VisitDepth.typeDef)
    bombIfErr
  }

  override Void visitTypeDef(TypeDef t)
  {
    // check out of order base vs mixins first
    if (!checkOutOfOrder(t)) return

    // check extends
    checkExtends(t, t.base)

    // check each mixin
    t.mixins.each |CType m| { checkMixin(t, m) }
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
    if (!base.isParameterized && base.isGeneric)
      err("Class '$t.name' cannot extend generic type '$base'", t.loc)

    // check extends final
    if (base.isFinal)
      err("Class '$t.name' cannot extend final class '$base'", t.loc)

    // check extends internal scoped outside my pod
    if (base.isInternal && t.pod != base.pod)
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
    if (m.isInternal && t.pod != m.pod)
      err("Type '$t.name' cannot access internal scoped mixin '$m'", t.loc)
  }

}