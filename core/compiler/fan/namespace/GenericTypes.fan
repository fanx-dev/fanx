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
  CType[] genericParams
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
    this.genericParams = params
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

  override Bool isGeneric() { false }
  override Bool isParameterized() { true }

  override once CType toListOf() { ListType(this) }

  override once COperators operators() { COperators(this) }

  override once Str:CSlot slots() { parameterizeSlots }

  override Bool isValid() { root.isValid && genericParams.all { it.isValid }}

  override Int flags()
  {
    baseFlags := root.flags
    if (root.isPublic && genericParams.all { it.isPublic })
      baseFlags = baseFlags.or(FConst.Public)
    else
      baseFlags = baseFlags.and(FConst.Public.not)
      baseFlags = baseFlags.or(FConst.Internal)
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
      if (t.isGeneric) return true
      if(defaultParameterized) return true
      ParameterizedType o := t.deref.raw.toNonNullable
      if (o.defaultParameterized) return true
      if (this.genericParams.size != o.genericParams.size) {
        //echo("fits: $this != $t: size: ${this.genericParams.size}!=${o.genericParams.size}")
        return false
      }
      for (i:=0; i<genericParams.size; ++i) {
        if (!this.genericParams[i].fits(o.genericParams[i])) {
          //echo("fits: $this != $ty, param:$i")
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

  private Str:CSlot parameterizeSlots()
  {
    root.slots.map |CSlot slot->CSlot| { parameterizeSlot(slot) }
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
      if (!f.fieldType.hasGenericParameter) return slot
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
      params := pt.genericParams.map |p|{ parameterize(p) }
      t = ParameterizedType.create(pt.root, params)
    }
    else {
      t = doParameterize(((GenericParamType)nn).paramName)
    }
    t = nullable ? t.toNullable : t
    return t
  }

  virtual CType doParameterize(Str name)
  {
    gp := root.getGenericParamType(name)
    if (gp == null) {
      throw Err(name)
    }

    return genericParams.getSafe(gp.index, gp.bound)
  }

  override once Str extName() {
    if (defaultParameterized) return "<>"
    return "<"+genericParams.join(",",|s|{ s.signature })+">"
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

**************************************************************************
** FuncType
**************************************************************************

**
** FuncType models a parameterized Func type.
**
class FuncType : ParameterizedType
{
  new make(CType[] params, Str[] names, CType ret, Bool defaultParameterized := false)
    : super(ret.ns.funcType, [ret].addAll(params), defaultParameterized)
  {
    this.params = params
    this.names  = names
    this.ret    = ret
  }

  new makeItBlock(CType itType)
    : this.make([itType], ["it"], itType.ns.voidType)
  {
    // sanity check
    if (itType.isThis) throw Err("Invalid it-block func signature: $this")
  }

  override Bool fits(CType ty)
  {
    //echo("Func.fits: $this => $ty")
    t := ty.deref.raw.toNonNullable
    if (this == t) return true
    if (t.isObj) return true

    if (this.qname == t.qname) {
      if (defaultParameterized) return true
      if (t.isGeneric) return true
    }
    //TODO: not sure
    //if (t.name.size == 1 && t.pod.name == "sys") return true

    that := t as FuncType
    if (that == null) return false
    if (that.defaultParameterized) return true

    // match return type (if void is needed, anything matches)
    if (!that.ret.isVoid && !this.ret.fits(that.ret)) return false

    // match params - it is ok for me to have less than
    // the type params (if I want to ignore them), but I
    // must have no more
    if (this.params.size > that.params.size) return false
    for (i:=0; i<this.params.size; ++i)
      if (!that.params[i].fits(this.params[i])) return false

    // this method works for the specified method type
    return true;
  }

  Int arity() { params.size }

  FuncType toArity(Int num)
  {
    if (num == params.size) return this
    if (num > params.size) throw Err("Cannot increase arity $this")
    return make(params[0..<num], names[0..<num], ret)
  }

  FuncType mostSpecific(FuncType b)
  {
    a := this
    if (a.arity != b.arity) throw Err("Different arities: $a / $b")
    params := a.params.map |p, i| { toMostSpecific(p, b.params[i]) }
    ret := toMostSpecific(a.ret, b.ret)
    return make(params, b.names, ret)
  }

  static CType toMostSpecific(CType a, CType b)
  {
    if (b.deref.toNonNullable is GenericParamType) return a
    if (a.isObj || a.isVoid || a.hasGenericParameter) return b
    return a
  }

  ParamDef[] toParamDefs(Loc loc)
  {
    p := ParamDef[,]
    p.capacity = params.size
    for (i:=0; i<params.size; ++i)
    {
      p.add(ParamDef(loc, params[i], names[i]))
    }
    return p
  }

  **
  ** Return if this function type has 'This' type in its signature.
  **
  Bool usesThis()
  {
    return ret.isThis || params.any |CType p->Bool| { p.isThis }
  }

  override Bool isValid()
  {
    (ret.isVoid || ret.isValid) && params.all |CType p->Bool| { p.isValid }
  }

  **
  ** Replace any occurance of "sys::This" with thisType.
  **
  override FuncType parameterizeThis(CType thisType)
  {
    if (!usesThis) return this
    f := |CType t->CType| { t.isThis ? thisType : t }
    return FuncType(params.map(f), names, f(ret), defaultParameterized)
  }

  CType[] params { private set } // a, b, c ...
  Str[] names    { private set } // parameter names
  CType ret      { private set } // return type
  Bool unnamed                   // were any names auto-generated
  Bool inferredSignature   // were one or more parameters inferred
}

**************************************************************************
** GenericParameterType
**************************************************************************

**
** GenericParameterType models the generic parameter types
** sys::V, sys::K, etc.
**

class GenericParamType : ProxyType {
  CType bound() { super.root }
  override Str name() { "${parent.name}^${paramName}" }
  override Str qname() { "${parent.qname}^${paramName}" }
  override Str extName()   { "" }
  CType parent
  Str paramName
  Int index

  new make(CNamespace ns, Str name, CType parent, Int index, CType bound := ns.objType.toNullable) : super(bound) {
    this.parent = parent
    this.paramName = name
    this.index = index
  }

  override CPod pod() { parent.pod }

  override CType raw() {
    raw := bound
    if (isNullable) raw = raw.toNullable
    return raw
  }

  override Bool isNullable() { true }

  override Bool hasGenericParameter() { true }
}

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
  private CField generic { private set }
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