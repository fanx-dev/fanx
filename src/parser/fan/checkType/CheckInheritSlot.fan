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
class CheckInheritSlot : CompilerStep
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
    debug("CheckInheritSlot")

    // at this point OrderByInheritance should have everything
    // ordered correctly to just do a simple walk
    walk(pod, VisitDepth.typeDef)
  }

  override Void visitTypeDef(TypeDef t)
  {
    inheriSlots := [Str:CSlot[]][:]
    t.inheritances.each |bt| {
      bt.slots.each |v,k| {
        if (v.isAccessor || v.isOverload) return
        list := inheriSlots[k]
        if (list == null) {
          inheriSlots[k] = [v]
          return
        }
        if (list.contains(v)) return
        
        //select
        nlist := [,]
        for (i:=0; i<list.size; ++i) {
          old := list[i]
          kp := CTypeDef.keep(old, v)
          if (kp != null) {
            nlist.add(kp)
          }
          else {
            nlist.add(old).add(v)
          }
        }
        inheriSlots[k] = nlist
      }
    }
    
    // check overrides all overrode something
    t.slotDefs.each |SlotDef slot|
    {
      if (slot.isAccessor || slot.isOverload) return
      
      dupDef := t.slotDef(slot.name)
      if (dupDef !== slot) {
        f := slot as MethodDef
        if (f != null && f.isStaticInit) {}
        else
          err("Duplicate slot name '$slot.name'", slot.loc)
      }
      parentSlots := inheriSlots[slot.name]
      if (parentSlots == null) {
        if (slot.isOverride)
          err("Invalid override", slot.loc)
        return
      }
      
      parentSlot := parentSlots.first
      if (!slot.isOverride) {
        checkNameConfilic(t, parentSlot)
        return
      }
      
      parentSlots.each |oldSlot| {
        checkOverride(t, oldSlot, slot)
      }
    }
    
    inheriSlots.each |v,k| {
      
      if (t.hasSlotDef(k)) return
      
      impCounst := 0
      v.each { if (!it.isAbstract) ++impCounst }
    
      if (impCounst > 1) {
        if (!t.hasSlotDef(k)) err("Must override ambiguous inheritance '${v[0].qname}' and '${v[1].qname}'", t.loc)
      }
      else if (impCounst == 0 && !t.isAbstract) {
        err("Must override abstract slot '${v[0].qname}'", t.loc)
      }
    
      for (i:=0; i<v.size-1; ++i) {
        if (!matchingSignatures(v[i], v[i+1])) {
          err("Inherited slots have conflicting signatures '${v[i].qname}' and '${v[i+1].qname}'", t.loc)
          break
        }
      }
    }
  }

//////////////////////////////////////////////////////////////////////////
// Inherit
//////////////////////////////////////////////////////////////////////////
  
  
  //do not allow same name slot for invokevirtual on private methods
  private Void checkNameConfilic(TypeDef t, CSlot parentSlot) {
    if (parentSlot.isCtor) return
    if ((parentSlot.isPrivate && parentSlot.parent.podName == t.podName) ||
         (parentSlot.isInternal && parentSlot.parent.podName != t.podName)) {
      name := parentSlot.name
      selfSlot := t.slot(name)
      if (selfSlot != null) {
        loc := t.loc
        if (selfSlot is SlotDef) {
          loc = ((SlotDef)selfSlot).loc
        }
        err("Can not override private $parentSlot with $selfSlot", loc)
      }
    }
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
  ** Check that def is a valid override of the base slot.
  **
  private Void checkOverride(TypeDef t, CSlot base, SlotDef def)
  {
    loc := def.loc

    // check base is virtual
    if (!base.isVirtual)
      err("Cannot override non-virtual slot '$base.qname'", loc)

    // check override keyword was specified
    if (!def.isOverride)
      err("Must specify override keyword to override '$base.qname'", loc)

    // check protection scope
    if (isOverrideProtectionErr(base, def))
      err("Override narrows protection scope of '$base.qname'", loc)

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
    err("Invalid slot override of '$base.qname'", def.loc)
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
        err("Return in override of '$base.qname' must be This", loc)
    }
    else
    {
      // check return types
      if (defRet != baseRet)
      {
        // check if new return type is a subtype of original
        // return type (we allow covariant return types)
        if (!defRet.fits(baseRet) || (defRet.isVoid && !baseRet.isVoid) || defRet.isNullable != baseRet.isNullable)
          err("Return type mismatch in override of '$base.qname' - '$baseRet' != '$defRet'", loc)

        // can't use covariance with value types
        //TODO check
        //if (defRet.isVal || baseRet.isVal)
        //  err("Cannot use covariance with value types '$base.qname' - '$baseRet' != '$defRet'", loc)
      }

      // if the definition already has a covariant return type, then
      // it must be exactly the same type as this new override (we
      // can't have conflicting covariant overrides
      if (def.inheritedRet != null && def.inheritedRet != base.inheritedReturnType)
        err("Conflicting covariant returns: '$def.inheritedRet' and '$base.inheritedReturnType'", loc)
    }

    // save original return type
    def.inheritedRet = base.inheritedReturnType

    // check that we have same parameter count
    if (!base.hasSameParams(def)) {
      err("Parameter mismatch in override of '$base.qname' - '$base.nameAndParamTypesToStr' != '$def.nameAndParamTypesToStr'", loc)
      return
    }
    
    // check override has matching defaults
    base.params.each |b, i|
    {
      d := def.params[i]
      if (b.hasDefault == d.hasDefault) return
      if (d.hasDefault)
        err("Parameter '$d.name' must not have default to match overridden method", loc)
      else
        err("Parameter '$d.name' must have default to match overridden method", loc)
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
        err("Type mismatch in override of '$base.qname' - '$rt' != '$ft'", loc)

      // can't use covariance with value types
      if (ft.isVal || rt.isVal)
        err("Cannot use covariance with value types '$base.qname' - '$rt' != '$ft'", loc)
    }

    // check that field isn't static
    if (def.isStatic)
      err("Cannot override virtual method with static field '$def.name'", loc)

    // check that method has no parameters
    if (!base.params.isEmpty)
      err("Field '$def.name' cannot override method with params '$base.qname'", loc)

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
      err("Type mismatch in override of '$base.qname' - '$base.fieldType' != '$def.fieldType'", loc)

    // if overriding a field which has storage, then don't duplicate storage
    if (!base.isAbstract)
      def.concreteBase = base

    // const field cannot override a field (const fields cannot be set,
    // therefore they can override only methods)
    if (def.isConst || def.isReadonly)
      err("Const field '$def.name' cannot override field '$base.qname'", loc)

    // correct override
    return
  }


}