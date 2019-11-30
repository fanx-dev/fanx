//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Jul 06  Brian Frank  Creation
//

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
    if (ty === ns.funcType) return true

    //echo("Func.fits: $this => $ty")
    t := ty.deref.raw.toNonNullable
    if (this == t) return true
    if (t.isObj) return true

    if (this.qname == t.qname) {
      if (defaultParameterized) return true
    }

    that := t as FuncType
    if (that == null) return false
    if (that.defaultParameterized) return true

    // match return type (if void is needed, anything matches)
    if (!this.ret.fits(that.ret)) {
      //echo("ret: $this.ret not fits $that.ret")
      return false
    }
    // match params - it is ok for me to have less than
    // the type params (if I want to ignore them), but I
    // must have no more
    if (this.params.size > that.params.size) return false
    for (i:=0; i<this.params.size; ++i)
      if (!that.params[i].fits(this.params[i])) {
        //echo("${that.params[i]} not fits ${this.params[i]}")
        if (that.params[i].hasGenericParameter) continue
        return false
      }
    // this method works for the specified method type
    return true;
  }

  Int arity() { params.size }

  FuncType toArity(Int num)
  {
    if (num == params.size) return this
    if (num > params.size) throw Err("Cannot increase arity $this")
    //return make(params[0..<num], names[0..<num], ret)
    return this
  }

  FuncType mostSpecific(FuncType b)
  {
    a := this
    if (a.arity > b.arity) throw Err("Different arities: $a / $b")
    params := a.params.map |p, i| { toMostSpecific(p, b.params[i]) }
    if (a.arity < b.arity) {
      for (i:= a.arity; i<b.arity; ++i) {
        params.add(b.params[i])
      }
    }
    ret := toMostSpecific(a.ret, b.ret)
    return make(params, b.names, ret)
  }

  static CType toMostSpecific(CType a, CType b)
  {
    if (b.deref.toNonNullable is GenericParameter) return a
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

