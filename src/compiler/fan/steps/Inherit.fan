//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//    2 Dec 05  Brian Frank  Creation (originally InitShimSlots)
//   23 Sep 06  Brian Frank  Ported from Java to Fan
//

**
** Inherit processes each TypeDef to resolve the inherited slots.
** This step is used to check invalid inheritances due to conflicting
** slots and invalid overrides.
**
class Inherit : CompilerStep
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
    log.debug("Inherit")

    // at this point OrderByInheritance should have everything
    // ordered correctly to just do a simple walk
    walk(compiler, VisitDepth.typeDef)
  }

  override Void visitTypeDef(TypeDef t)
  {
    // inherit all parent types
    inheritType(t, t.base)
    t.mixins.each |CType m| { inheritType(t, m) }

    // check overrides all overrode something
    t.slotDefs.each |SlotDef slot|
    {
      if (slot.isOverride && !slot.overridden && !slot.isAccessor)
        err("Override of unknown virtual slot '$slot.name'", slot.loc)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Inherit
//////////////////////////////////////////////////////////////////////////

  private Void inheritType(TypeDef t, CType? parent)
  {
    if (parent == null)
    {
      if (t.qname == "sys::Obj") return
      else throw err("Illegal state", t.loc)
    }

    closure := |CSlot s|
    {
      if (parent.isMixin && s.parent.isObj) return
      try
      {
        inheritSlot(t, s)
      }
      catch (CompilerErr e)
      {
      }
      checkNameConfilic(t, s)
    }

    // inherit each slot from parent type (if test then
    // sort the slots to test errors in consistent order)
    if (compiler.input.isTest)
      parent.slots.vals.sort(|CSlot a, CSlot b->Int| {return a.name <=> b.name}).each(closure)
    else
      parent.slots.each(closure)
  }

  //do not allow same name slot for invokevirtual on private methods
  private Void checkNameConfilic(TypeDef t, CSlot parentSlot) {
    if (parentSlot.isCtor) return
    if ((parentSlot.isPrivate && parentSlot.parent.pod == t.pod) ||
         (parentSlot.isInternal && parentSlot.parent.pod != t.pod)) {
      name := parentSlot.name
      selfSlot := t.slot(name)
      if (selfSlot != null) {
        loc := t.loc
        if (selfSlot is SlotDef) {
          loc = ((SlotDef)selfSlot).loc
        }
        throw err("Can not override private $parentSlot with $selfSlot", loc)
      }
    }
  }

  private Void inheritSlot(TypeDef t, CSlot newSlot)
  {
    // TODO: I think we need a lot more checking here, especially if
    // private/internal is public in the Java VM, because right now
    // we just ignore all ctor, privates, and internals - but they might
    // cause us real conflicts at JVM/IL emit time if we didn't detect
    // here.  Plus right now overrides of private/internal show up
    // as unknown virtuals, when in reality we could check them here
    // as scope errors.  So this method needs some refactoring to fully
    // handle all the cases (along with a comprehensive test)

    // we never inherit constructors, private slots,
    // or internal slots outside of the pod
    if (newSlot.isCtor || newSlot.isPrivate || newSlot.isStatic ||
        (newSlot.isInternal && newSlot.parent.pod != t.pod))
      return

    // check if there is already a slot mapped by that name
    name := newSlot.name
    oldSlot := t.slot(name)

    // if a new slot, add it to the type and we are done
    if (oldSlot == null)
    {
      t.addSlot(newSlot)
      return
    }

    // if we've inherited the exact same slot from two different
    // class hiearchies, then no need to continue
    if (newSlot === oldSlot) return

    // if this is one of the type's slot definitions, then check
    // that we have a valid inheritance override, in which case
    // we leave the old slot as the definition for this slot
    // name - otherwise we will log and throw an error; in all
    // cases we mark this slot overridden so that we don't report
    // spurious "Override of unknown virtual slot" errors
    if (oldSlot.parent === t && !newSlot.isCtor)
    {
      slotDef := (SlotDef)oldSlot
      slotDef.overridden = true
      checkOverride(t, newSlot, slotDef)
      return
    }

    // if the two slots don't have matching signatures
    // then this is an inheritance conflict
    if (!matchingSignatures(oldSlot, newSlot))
      throw err("Inherited slots have conflicting signatures '$oldSlot.qname' and '$newSlot.qname'", t.loc)

    // check if there is a clear keeper between old and new slots
    keep := keep(oldSlot, newSlot)
    if (keep != null)
    {
      if (keep === newSlot) t.replaceSlot(oldSlot, newSlot)
      return
    }

    // if both are virtual, then subclass must remove ambiguous
    if (oldSlot.isVirtual && newSlot.isVirtual)
      throw err("Must override ambiguous inheritance '$oldSlot.qname' and '$newSlot.qname'", t.loc)

    // anything else is an unfixable inheritance conflict
    throw err("Inheritance conflict '$oldSlot.qname' and '$newSlot.qname'", t.loc)
  }

  **
  ** Return if two slots have matching signatures
  **
  private Bool matchingSignatures(CSlot a, CSlot b)
  {
    fa := a as CField
    fb := b as CField
    ma := a as CMethod
    mb := b as CMethod

    if (fa != null && fb != null)
      return fa.fieldType == fb.fieldType

    if (ma != null && mb != null)
      return ma.returnType == mb.returnType &&
             ma.inheritedReturnType == mb.inheritedReturnType &&
             ma.hasSameParams(mb)

    if (fa != null && mb != null)
      return fa.fieldType == mb.returnType &&
             fa.fieldType == mb.inheritedReturnType &&
             mb.params.size == 0

    if (ma != null && fb != null)
      return ma.returnType == fb.fieldType &&
             ma.inheritedReturnType == fb.fieldType &&
             ma.params.size == 0

    return false
  }

  **
  ** Return if there is a clear keeper between a and b - if so
  ** return the one to keep otherwise return null.
  **
  private CSlot? keep(CSlot a, CSlot b)
  {
    // if one is abstract and one concrete we keep the concrete one
    if (a.isAbstract && !b.isAbstract) return b
    if (!a.isAbstract && b.isAbstract) return a

    // keep one if it is a clear override from the other
    if (a.parent.fits(b.parent)) return a
    if (b.parent.fits(a.parent)) return b

    return null
  }

  **
  ** Check that def is a valid override of the base slot.
  **
  private Void checkOverride(TypeDef t, CSlot base, SlotDef def)
  {
    loc := def.loc

    // check base is virtual
    if (!base.isVirtual)
      throw err("Cannot override non-virtual slot '$base.qname'", loc)

    // check override keyword was specified
    if (!def.isOverride)
      throw err("Must specify override keyword to override '$base.qname'", loc)

    // check protection scope
    if (isOverrideProtectionErr(base, def))
      throw err("Override narrows protection scope of '$base.qname'", loc)

    // if overriding a FFI slot give bridge a hook
    if (base.isForeign)
      base.bridge.checkOverride(t, base, def)

    // check if this is a method/method override
    if (base is CMethod && def is MethodDef)
    {
      checkMethodMethodOverride(t, (CMethod)base, (MethodDef)def)
      return
    }

    // check if this is a method/field override
    if (base is CMethod && def is FieldDef)
    {
      checkMethodFieldOverride(t, (CMethod)base, (FieldDef)def)
      return
    }

    // check if this is a field/field override
    if (base is CField && def is FieldDef)
    {
      checkFieldFieldOverride(t, (CField)base, (FieldDef)def)
      return
    }

    // TODO otherwise this is a potential inheritance conflict
    throw err("Invalid slot override of '$base.qname'", def.loc)
  }

  private Bool isOverrideProtectionErr(CSlot base, SlotDef def)
  {
    if (def.isPublic)
      return false

    if (def.isProtected)
      return base.isPublic || base.isInternal

    if (def.isInternal)
      return base.isPublic || base.isProtected

    return true
  }

  private Void checkMethodMethodOverride(TypeDef t, CMethod base, MethodDef def)
  {
    loc := def.loc

    defRet := def.returnType
    baseRet := base.returnType

    // if the base is defined as This, then all overrides must be This
    if (baseRet.isThis)
    {
      if (!defRet.isThis)
        throw err("Return in override of '$base.qname' must be This", loc)
    }
    else
    {
      // check return types
      if (defRet != baseRet)
      {
        // check if new return type is a subtype of original
        // return type (we allow covariant return types)
        if (!defRet.fits(baseRet) || (defRet.isVoid && !baseRet.isVoid) || defRet.isNullable != baseRet.isNullable)
          throw err("Return type mismatch in override of '$base.qname' - '$baseRet.inferredAs' != '$defRet'", loc)

        // can't use covariance with value types
        if (defRet.isVal || baseRet.isVal)
          throw err("Cannot use covariance with value types '$base.qname' - '$baseRet' != '$defRet'", loc)
      }

      // if the definition already has a covariant return type, then
      // it must be exactly the same type as this new override (we
      // can't have conflicting covariant overrides
      if (def.inheritedRet != null && def.inheritedRet != base.inheritedReturnType)
        throw err("Conflicting covariant returns: '$def.inheritedRet' and '$base.inheritedReturnType'", loc)
    }

    // save original return type
    def.inheritedRet = base.inheritedReturnType

    // check that we have same parameter count
    if (!base.hasSameParams(def))
      throw err("Parameter mismatch in override of '$base.qname' - '$base.nameAndParamTypesToStr' != '$def.nameAndParamTypesToStr'", loc)

    // check override has matching defaults
    base.params.each |b, i|
    {
      d := def.params[i]
      if (b.hasDefault == d.hasDefault) return
      if (d.hasDefault)
        throw err("Parameter '$d.name' must not have default to match overridden method", loc)
      else
        throw err("Parameter '$d.name' must have default to match overridden method", loc)
    }

    // correct override
    return
  }

  private Void checkMethodFieldOverride(TypeDef t, CMethod base, FieldDef def)
  {
    loc := def.loc

    // check that types match
    ft := def.fieldType
    rt := base.returnType
    if (ft != rt)
    {
      // we allow field to be covariant typed
      if (!ft.fits(rt) || ft.isNullable != rt.isNullable)
        throw err("Type mismatch in override of '$base.qname' - '$rt' != '$ft'", loc)

      // can't use covariance with value types
      if (ft.isVal || rt.isVal)
        throw err("Cannot use covariance with value types '$base.qname' - '$rt' != '$ft'", loc)
    }

    // check that field isn't static
    if (def.isStatic)
      throw err("Cannot override virtual method with static field '$def.name'", loc)

    // check that method has no parameters
    if (!base.params.isEmpty)
      throw err("Field '$def.name' cannot override method with params '$base.qname'", loc)

    // save original return type
    def.inheritedRet = base.inheritedReturnType

    // correct override
    return
  }

  private Void checkFieldFieldOverride(TypeDef t, CField base, FieldDef def)
  {
    loc := def.loc

    // check that types match
    if (!CMethod.sameType(base.fieldType, def.fieldType))
      throw err("Type mismatch in override of '$base.qname' - '$base.fieldType' != '$def.fieldType'", loc)

    // if overriding a field which has storage, then don't duplicate storage
    if (!base.isAbstract)
      def.concreteBase = base

    // const field cannot override a field (const fields cannot be set,
    // therefore they can override only methods)
    if (def.isConst || def.isReadonly)
      throw err("Const field '$def.name' cannot override field '$base.qname'", loc)

    // correct override
    return
  }


}