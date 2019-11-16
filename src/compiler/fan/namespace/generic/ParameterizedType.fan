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
class ParameterizedType : ProxyType {
  override Bool hasGenericParameter
  CType[] genericArgs
  Bool defaultParameterized { private set } //generic param is absent

  static new create(CType baseType, CType[] params := [,]) {
    defaultParameterized := params.size == 0
    if (baseType.qname == "sys::List") {
      if (defaultParameterized) {
        params = [baseType.ns.objType.toNullable]
      }
      return ListType(params.first, defaultParameterized)
    }
    else if (baseType.qname == "std::Map") {
      if (defaultParameterized) {
        objType := baseType.ns.objType.toNullable
        params = [objType, objType]
      }

      return MapType(params.first, params.last, defaultParameterized)
    }
    else if (baseType.qname == "sys::Func") {
      if (defaultParameterized) {
        objType := baseType.ns.objType.toNullable
        params = [objType]
      }
      ret := params.first
      types := CType[,]
      names := Str[,]
      for (i:=1; i<params.size; ++i) {
        types.add(params[i])
        names.add(('a'+i-1).toCode)
      }
      return FuncType(types, names, params.first, defaultParameterized)
    }
    else {
      return ParameterizedType.make(baseType, params, defaultParameterized)
    }
  }

  protected new make(CType baseType, CType[] params, Bool defaultParameterized)
    : super(baseType)
  {
    this.genericArgs = params
    this.defaultParameterized = defaultParameterized
    hasGenericParameter = params.any { it.hasGenericParameter }
  }

//////////////////////////////////////////////////////////////////////////
// CType
//////////////////////////////////////////////////////////////////////////

  override Bool isVal() { false }

  override Bool isNullable() { false }
  override once CType toNullable() { NullableType(this) }
  override CType toNonNullable() { return this }

  //override Bool isGeneric() { root.isGeneric }
  override Bool isParameterized() { true }

  override once CType toListOf() { ListType(this) }

  override once COperators operators() { COperators(this) }

  private [Str:CSlot]? parameterizeSlots
  override Str:CSlot slots() {
    if (parameterizeSlots != null && parameterizeSlots.size == root.slots.size) return parameterizeSlots
    parameterizeSlots = root.slots.map |CSlot slot->CSlot| {
      s := parameterizeSlot(slot)
      return s
    }
    return parameterizeSlots
  }

  override Bool isValid() { root.isValid && genericArgs.all { it.isValid }}

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

  override Bool fits(CType ty)
  {
    //echo("fits: $this <=> $ty")
    t := ty.deref.raw.toNonNullable

    // everything fits Obj
    if (t.isObj) return true

    // short circuit if myself
    if (this == t) return true

    if (t.qname == root.qname) {
      if (t.isGeneric && t isnot ParameterizedType) {
        return true
      }
      if(defaultParameterized) return true
      ParameterizedType o := t.deref.raw.toNonNullable
      if (o.defaultParameterized) return true

      if (this.genericArgs.size != o.genericArgs.size) {
        //echo("fits1: $this != $t: size: ${this.genericArgs.size}!=${o.genericArgs.size}; $this.typeof $t.typeof")
        return false
      }
      for (i:=0; i<genericArgs.size; ++i) {
        if (!this.genericArgs[i].fits(o.genericArgs[i]) && !o.genericArgs[i].fits(this.genericArgs[i])) {
          //echo("fits2: $this != $ty, param:$i; $this.typeof $t.typeof")
          return false
        }
      }
      return true
    }

    // recurse extends
    if (base != null && base.fits(t)) return true

    // recuse mixins
    for (i:=0; i<mixins.size; ++i)
      if (mixins[i].fits(t)) return true

    return false
  }

  private Bool isTypeErasure() {
    return qname != "sys::Array" && qname != "sys::Ptr"
  }

  private CSlot parameterizeSlot(CSlot slot)
  {
    if (slot is CMethod)
    {
      CMethod m := slot
      if (!m.isGeneric && isTypeErasure) return slot
      p := ParameterizedMethod(this, m)
      return p
    }
    else
    {
      f := (CField)slot
      if (!f.isGeneric && isTypeErasure) return slot
      p := ParameterizedField(this, f)
      return p
    }
  }

  internal CType parameterize(CType t)
  {
    if (!t.hasGenericParameter) return t
    //can't use t.isNullable because the GenericParameter as nullable
    nullable := t.deref is NullableType
    nn := t.toNonNullable

    if (nn is ParameterizedType) {
      pt := (ParameterizedType)nn
      params := pt.genericArgs.map |p|{ parameterize(p) }
      t = ParameterizedType.create(pt.root, params)
    }
    else {
      t = doParameterize(((GenericParameter)nn).paramName)
    }
    t = nullable ? t.toNullable : t
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

  override once CType? base() {
    parameterize(root.base)
  }

  override once CType[] mixins() {
    root.mixins.map { parameterize(it) }
  }

  override once Str extName() {
    if (defaultParameterized) return "<>"
    return "<"+genericArgs.join(",",|s|{ s.signature })+">"
  }
}

**************************************************************************
** ListType
**************************************************************************

**
** ListType models a parameterized List type.
**
class ListType : ParameterizedType
{
  new make(CType v, Bool defaultParameterized := false)
    : super(v.ns.listType, [v], defaultParameterized)
  {
    this.v = v
  }

  CType v { private set }
}

**************************************************************************
** MapType
**************************************************************************

**
** MapType models a parameterized Map type.
**
class MapType : ParameterizedType
{
  new make(CType k, CType v, Bool defaultParameterized := false)
    : super(k.ns.mapType, [k,v], defaultParameterized)
  {
    this.k = k
    this.v = v
  }

  CType k { private set }        // keytype
  CType v { private set }        // value type
}

