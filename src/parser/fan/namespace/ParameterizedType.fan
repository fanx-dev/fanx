//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Jul 06  Brian Frank  Creation
//

**************************************************************************
** Parameterized
**************************************************************************

**
** common parameterized type for user define generic type ref
**
class ParameterizedType : CTypeDef {
  CTypeDef root
  
//  Bool hasGenericParameter
  CType[] genericArgs
  Bool defaultParameterized { private set } //generic param is absent
  override once Str:TypeDef parameterizedTypeCache() { [:] }

  static new create(CTypeDef baseType, CType[]? params) {
    defaultParameterized := params == null
    
    if (defaultParameterized) {
       params.size.times { params.add(CTypeImp.make("sys", "Obj").toNullable) }
    }
    
    return ParameterizedType.make(baseType, params, defaultParameterized)
  }

  protected new make(CTypeDef baseType, CType[] params, Bool defaultParameterized)
  {
    this.root = baseType
    this.genericArgs = params
    this.defaultParameterized = defaultParameterized
//    hasGenericParameter = params.any { it.hasGenericParameter }
  }
  
  override CFacet[]? facets() { root.facets }
  
  protected override GenericParamDef[]? genericParameters() { null }
  
  override Str podName() { root.podName }
  
  override Str name() { root.name }

//////////////////////////////////////////////////////////////////////////
// CType
//////////////////////////////////////////////////////////////////////////

//  override Bool isVal() { false }
//  override Bool isNullable() { false }
//  override once CType toNullable() { NullableType(this) }
//  override CType toNonNullable() { return this }

  //override Bool isGeneric() { root.isGeneric }
//  override Bool isParameterized() { true }

//  override once CType toListOf() { ListType(this) }
//  override once COperators operators() { COperators(this) }

  private CSlot[]? parameterizeSlotDefs
  override CSlot[] slotDefs() {
    if (parameterizeSlotDefs != null && parameterizeSlotDefs.size == root.slotDefs.size)
      return parameterizeSlotDefs
    parameterizeSlotDefs = root.slotDefs.map |CSlot slot->CSlot| {
      s := parameterizeSlot(slot)
      return s
    }
    return parameterizeSlotDefs
  }
  
  protected override Str:CSlot slotsCache := [:]

//  override Bool isValid() { root.isValid && genericArgs.all { it.isValid }}

  override Int flags()
  {
    baseFlags := root.flags
    if (root.isPublic && genericArgs.all { it.isPublic })
      baseFlags = baseFlags.or(FConst.Public)
    else {
      baseFlags = baseFlags.and(FConst.Public.not)
      baseFlags = baseFlags.or(FConst.Internal)
    }
    return baseFlags
  }

  private CSlot parameterizeSlot(CSlot slot)
  {
    if (slot is CMethod)
    {
      CMethod m := slot
      if (!m.isGeneric) return slot
      p := ParameterizedMethod(this, m)
      return p
    }
    else
    {
      f := (CField)slot
      if (!f.isGeneric) return slot
      p := ParameterizedField(this, f)
      return p
    }
  }

  internal CType parameterize(CType t)
  {
    if (!t.hasGenericParameter) return t
    nn := t.typeDef
    
    if (nn is GenericParamDef) {
      gp := (GenericParamDef)nn
      real := doParameterize(gp.paramName).typeDef
      t.resolveTo(real)
      t.attachedGenericParam = gp
    }
    else {
      t.genericArgs = t.genericArgs.map |p|{ parameterize(p) }
      //redo parameterized
      t.resolveTo(nn)
    }

    //special with func to nonullable
//    if (qname == "sys::Func") return t

    return t
  }

  virtual CType doParameterize(Str name)
  {
    gp := root.getGenericParameter(name)
    if (gp == null) {
      throw Err(name)
    }

    return genericArgs.getSafe(gp.index, gp.bound)
  }
  
  override CType[] inheritances() {
    root.inheritances.map { parameterize(it) }
  }

  override once Str extName() {
    if (defaultParameterized) return "<>"
    return "<"+genericArgs.join(",",|s|{ s.signature })+">"
  }
}

//
//**
//** A single generic parameter replaced by generic argument.
//** e.g.
//** ParameterizedGenericParam for V as Int
//** ParameterizedType for List<V> as List<Int>
//** 
//class ParameterizedGenericParam : CTypeDef {
//  CTypeDef root
//  GenericParamDef genericParamDef
//  
//  protected new make(GenericParamDef genericParamDef, CTypeDef real)
//  {
//    this.genericParamDef = genericParamDef
//    this.root = real
//  }
//  
//  override Str podName() { root.podName }
//  override Str name() { root.name }
//  
//  override CType[] inheritances() { root.inheritances }
//  override CFacet[]? facets() { root.facets }
//  override Int flags() { root.flags }
//  
//  override CSlot[] slotDefs() { root.slotDefs }
//  protected override Str:CSlot slotMap() { root.slotMap }
//  
//  override Str:TypeDef parameterizedTypeCache() { root.parameterizedTypeCache }
//  protected override GenericParamDef[]? genericParameters() { root.genericParameters }
//}
