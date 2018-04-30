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
@Serializable { simple = true }
native const class Method : Slot
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Private constructor.
  **
  private static new privateMake()

//////////////////////////////////////////////////////////////////////////
// Signature
//////////////////////////////////////////////////////////////////////////

  **
  ** Type returned by the method or sys::Void if no return value.
  ** Convenience for 'func.returns'.
  **
  Type returns()

  **
  ** Get the parameters of the method.
  ** Convenience for 'func.params'.
  **
  Param[] params()

  **
  ** Get the function body of this method.
  **
  Func func()

//////////////////////////////////////////////////////////////////////////
// Call Conveniences
//////////////////////////////////////////////////////////////////////////

  ** Convenience for 'func.callList'
  Obj? callList(Obj?[]? args)

  ** Convenience for 'func.callOn'
  Obj? callOn(Obj? target, Obj?[]? args)

  ** Convenience for 'func.call'
  Obj? call(Obj? a := null, Obj? b := null, Obj? c := null, Obj? d := null,
            Obj? e := null, Obj? f := null, Obj? g := null, Obj? h := null)

}