//
// Copyright (c) 2007, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   9 Jul 07  Brian Frank  Split from Method
//

**
** Func models an executable function.  Functions are typed by a
** formal parameter list and return value (or Void if no return).
** Functions are typically defined as method slots on a type, but
** may also be defined via closures.
**
** An immutable function is one proven to be thread safe:
**   - Method functions are always immutable - see `sys::Method.func`
**   - Closures which only capture final, const variables are always
**     immutable; toImmutable always returns this
**   - Closures which capture non-final or non-const variables are
**     always mutable; toImmutable always throws NotImmutableErr
**   - Closure which capture non-final variables which aren't known
**     to be immutable until runtime (such as Obj or List) will return
**     false for isImmutable, but will provide a toImmutable method which
**     attempts to bind to the current variables by calling toImmutable
**     on each one
**   - Functions created by [Func.bind]`sys::Func.bind` are immutable if
**     the original function is immutable *and* every bound argument is
**     immutable
**
** The definition of a *final variable* is a variable which is never reassigned
** after it is initialized.  Any variable which is reassigned is considered
** a non-final variable.
**
** See `docLang::Functions` for details.
**
@Extern
final rtconst native class Func<R,A,B,C,D,E,F,G,H>
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Private constructor.
  **
  private new make()

//////////////////////////////////////////////////////////////////////////
// Signature
//////////////////////////////////////////////////////////////////////////

  **
  ** Type returned by the function or sys::Void if no return value.
  **
  //Type returns()

  **
  ** Convenience for 'params.size'
  **
  //Int arity()

  **
  ** Get the formal parameters of the function.
  **
  //Param[] params()

  **
  ** Return the associated method if this function implements a
  ** method slot.  Otherwise return 'null'.
  **
  ** Examples:
  **   Int#plus.func.method  =>  sys::Int.plus
  **
  //Method? method()

//////////////////////////////////////////////////////////////////////////
// Reflection
//////////////////////////////////////////////////////////////////////////

  **
  ** Dynamically invoke this function with the specified arguments and return
  ** the result.  If the function has Void return type, then null is returned.
  ** The argument list must match the number and type of required parameters.
  ** If this function represents an instance method (not static and not a
  ** constructor) then the first argument must be the target object.  If the
  ** function supports default parameters, omit arguments to use the defaults.
  ** It is permissible to pass more arguments then the number of method
  ** parameters - the additional arguments are ignored.  If no arguments are
  ** required, you may pass null for args.
  **
  virtual R callList(Obj?[]? args)

  **
  ** Convenience for dynamically invoking an instance method with
  ** specified target and arguments.  If this method maps to an
  ** instance method, then it is semantically equivalent to
  ** 'callList([target, args[0], args[1] ...])'.  Throw UnsupportedErr
  ** if called on a function which is not an instance method.
  **
  virtual R callOn(Obj? target, Obj?[]? args)

  **
  ** Optimized convenience for `callList` for zero to eight parameters.
  **
  virtual R call(A? a := null, B? b := null, C? c := null, D? d := null,
                 E? e := null, F? f := null, G? g := null, H? h := null)

  **
  ** Create a new function by binding the specified arguments to
  ** this function's parameters.  The new function which takes the
  ** remaining unbound parameters.
  **
  ** The resulting function is immutable if this function is
  ** immutable and all the args are immutable.
  **
  Func bind(Obj?[] args)

  **
  ** Return a new function which wraps this function but with
  ** a different reflective type signature.  No verification is
  ** done that this function actually conforms to new signature.
  ** Throw ArgErr if 't' isn't a parameterized function type.
  **
  ** Examples:
  **   f := |a,b->Obj| { "$a, $b" }
  **   g := f.retype(|Int,Int->Str|#)
  **   f.type  =>  |Obj?,Obj?->Obj|
  **   g.type  =>  |Int,Int->Str|
  **
  //Func retype(Type t)

  //internal native Void enterCtor(Obj obj)
  //internal native Void exitCtor()
  //internal native Void checkInCtor(Obj obj)
}