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
native rtconst class Method : Slot
{
  private const Str _returnsName
  private const Bool _isNullable
  private Type? _returns
  private const Int _id
  private Param[] _params := [,]
  private MethodFunc _func

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Private constructor.
  **
  internal new privateMake(Type parent, Str name, Str? doc, Int flags, 
      Str returnsName, Int id)
    : super.make(parent, name, doc, flags) {

    _isNullable = returnsName[returnsName.size-1] == '?'
    if (_isNullable) {
      _returnsName = returnsName[0..<-1]
    }
    else {
      _returnsName = returnsName
    }

    _id = id
    _func = MethodFunc(this)
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
      t := Type.find(_returnsName)
      _returns = _isNullable ? t.toNullable : t
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
    _func
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

  override Bool isImmutable() {
    true
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

native internal rtconst class MethodFunc<R,A,B,C,D,E,F,G,H> : Func<R,A,B,C,D,E,F,G,H> {
    private Method method

    new make(Method m) {
      method = m
    }

    native override R call(A? a := null, B? b := null, C? c := null, D? d := null,
                 E? e := null, F? f := null, G? g := null, H? h := null)

    override Bool isImmutable() {
      true
    }
}
