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
rtconst native class Func<R,A,B,C,D,E,F,G,H>
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Private constructor.
  **
  internal new make() {}

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
  virtual Obj? callList(Obj?[]? args) {
    size := (args == null) ? 0 : args.size
    switch (size) {
    case 0:
      return call();
    case 1:
      return call(args.get(0));
    case 2:
      return call(args.get(0), args.get(1));
    case 3:
      return call(args.get(0), args.get(1), args.get(2));
    case 4:
      return call(args.get(0), args.get(1), args.get(2), args.get(3));
    case 5:
      return call(args.get(0), args.get(1), args.get(2), args.get(3), args.get(4));
    case 6:
      return call(args.get(0), args.get(1), args.get(2), args.get(3), args.get(4), args.get(5));
    case 7:
      return call(args.get(0), args.get(1), args.get(2), args.get(3), args.get(4), args.get(5), args.get(6));
    case 8:
      return call(args.get(0), args.get(1), args.get(2), args.get(3), args.get(4), args.get(5), args.get(6),
          args.get(7));
    }
    throw ArgErr.make("too many args:" + size);
  }

  **
  ** Convenience for dynamically invoking an instance method with
  ** specified target and arguments.  If this method maps to an
  ** instance method, then it is semantically equivalent to
  ** 'callList([target, args[0], args[1] ...])'.  Throw UnsupportedErr
  ** if called on a function which is not an instance method.
  **
  virtual Obj? callOn(Obj? target, Obj?[]? args) {
    size := (args == null) ? 1 : args.size + 1;
    switch (size) {
    case 0:
      return call();
    case 1:
      return call(target);
    case 2:
      return call(target, args.get(0));
    case 3:
      return call(target, args.get(0), args.get(1));
    case 4:
      return call(target, args.get(0), args.get(1), args.get(2));
    case 5:
      return call(target, args.get(0), args.get(1), args.get(2), args.get(3));
    case 6:
      return call(target, args.get(0), args.get(1), args.get(2), args.get(3), args.get(4));
    case 7:
      return call(target, args.get(0), args.get(1), args.get(2), args.get(3), args.get(4), args.get(5));
    case 8:
      return call(target, args.get(0), args.get(1), args.get(2), args.get(3), args.get(4), args.get(5),
          args.get(6));
    }
    
    throw ArgErr.make("too many args:" + size);
  }

  **
  ** Optimized convenience for `callList` for zero to eight parameters.
  **
  native virtual R call(A? a := null, B? b := null, C? c := null, D? d := null,
                 E? e := null, F? f := null, G? g := null, H? h := null)

  **
  ** Create a new function by binding the specified arguments to
  ** this function's parameters.  The new function which takes the
  ** remaining unbound parameters.
  **
  ** The resulting function is immutable if this function is
  ** immutable and all the args are immutable.
  **
  Func bind(Obj?[] args) {
    if (args.size == 0)
      return this;
    return BindFunc(this, args);
  }

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

@NoPeer
internal rtconst class BindFunc<R,A,B,C,D,E,F,G,H> : Func<R,A,B,C,D,E,F,G,H> {
    const Func orig
    private Obj?[] bound
    private Bool? _isImmutable

    new make(Func orig, Obj?[] bound) {
      this.orig = orig
      this.bound = bound.ro
    }

    override Bool isImmutable() {
      if (this._isImmutable == null) {
        isImu := false;
        if (orig.isImmutable()) {
          isImu = true;
          for (i := 0; i < bound.size; ++i) {
            obj := bound.get(i);
            if (obj != null && !obj.isImmutable) {
              isImu = false;
              break;
            }
          }
        }
        this._isImmutable = isImu
      }
      return this._isImmutable
    }

    native override R call(A? a := null, B? b := null, C? c := null, D? d := null,
                 E? e := null, F? f := null, G? g := null, H? h := null)

    override Obj? callList(Obj?[]? args) {
      if (args == null) {
        args = List.defVal;
      }

      Obj?[] temp = List.make(10);
      for (i := 0; i < bound.size; ++i) {
        temp.add(bound.get(i));
      }
      for (j := 0; j < args.size; ++j) {
        temp.add(args.get(j));
      }

      return orig.callList(temp);
    }

    override Obj? callOn(Obj? obj, Obj?[]? args) {
      if (args == null) {
        args = List.defVal;
      }

      Obj?[] temp = List.make(10);
      for (i := 0; i < bound.size; ++i) {
        temp.add(bound.get(i));
      }
      temp.add(obj);
      for (j := 0; j < args.size; ++j) {
        temp.add(args.get(j));
      }
      return orig.callList(temp);
    }
  }