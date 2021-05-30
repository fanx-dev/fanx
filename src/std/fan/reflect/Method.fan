//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   6 Jan 06  Brian Frank  Creation
//

**
** Method models a function with a formal parameter list and
** return value (or Void if no return).
**
@NoNative native rtconst class Method : Slot
{
  private const Str _returnsName
  private Type? _returns
  private const Int _id
  private Param[] _params := [,]

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Private constructor.
  **
  internal new privateMake(Type parent, Str name, Str? doc, Int flags, 
      Str returnsName, Int id)
    : super.make(parent, name, doc, flags) {
    _returnsName = returnsName
    _id = id
  }

  internal Void addParam(Str name, Str typeName, Int mask) {
    p := Param(name, typeName, mask)
    _params.add(p)
  }

//////////////////////////////////////////////////////////////////////////
// Signature
//////////////////////////////////////////////////////////////////////////

  **
  ** Type returned by the method or sys::Void if no return value.
  ** Convenience for 'func.returns'.
  **
  Type returns() {
    if (_returns == null) {
      _returns = Type.find(_returnsName)
    }
    return _returns
  }

  **
  ** Get the parameters of the method.
  ** Convenience for 'func.params'.
  **
  Param[] params() { _params }

  **
  ** Get the function body of this method.
  **
  Func func(Int arity := -1) {
    return |Obj a, Obj b, Obj c, Obj d, Obj e, Obj f, Obj g, Obj h->Obj| {
      return this.call(a, b, c, d, e, f, g, h)
    }
  }

  **
  ** Evaluate the parameter default using reflection.  If this method is
  ** static or a constructor, then instance should be null.  Raise an exception
  ** if the parameter default cannot be evaluated independently (such as using
  ** an expression with previous parameters).
  **
  //Obj? paramDef(Param param, Obj? instance := null)

  override Str signature() {
    sb := StrBuf()
    sb.add(returns).add(" ").add(name).add("(")
    params.each |p, i| {
      if (i>0) sb.add(", ");
      sb.add(p)
    }
    sb.add(")")
    return sb.toStr
  }

//////////////////////////////////////////////////////////////////////////
// Call Conveniences
//////////////////////////////////////////////////////////////////////////

  ** Convenience for 'func.callList'
  Obj? callList(Obj?[]? args) { func.callList(args) }

  ** Convenience for 'func.callOn'
  Obj? callOn(Obj? target, Obj?[]? args) { func.callOn(target, args) }

  ** Convenience for 'func.call'
  native Obj? call(Obj? a := null, Obj? b := null, Obj? c := null, Obj? d := null,
            Obj? e := null, Obj? f := null, Obj? g := null, Obj? h := null)

}