//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 Feb 10 Brian Frank  Creation
//

**
** AtomicRef is used to manage a object reference shared
** between actor/threads with atomic updates.  Only immutable
** objects may be shared.
**
@Js
final const class AtomicRef
{

  **
  ** Construct with initial value.
  ** Throw NotImmutableErr if initialized to a mutable value.
  **
  new make(Obj? val := null) { this.val = val }

  **
  ** The current value.
  ** Throw NotImmutableErr if set to a mutable value.
  **
  native Obj? val

  **
  ** Atomically set the value and return the previous value.
  ** Throw NotImmutableErr if 'val' is mutable.
  **
  native Obj? getAndSet(Obj? val)

  **
  ** Atomically set the value to 'update' if current value is
  ** equivalent to the 'expect' value compared using '===' operator.
  ** Return true if updated, or false if current value was not equal
  ** to the expected value. Throw NotImmutableErr if 'update' is mutable.
  **
  native Bool compareAndSet(Obj? expect, Obj? update)

  **
  ** Return 'val.toStr'
  **
  override Str toStr() { val?.toStr ?: "null" }

}