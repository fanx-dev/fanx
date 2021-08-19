//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 Feb 10 Brian Frank  Creation
//

**
** AtomicBool is used to manage a boolean variable shared
** between actor/threads with atomic updates.
**
final const native class AtomicBool
{
  private const Int handle0
  private const Int handle1

  **
  ** Construct with initial value
  **
  new make(Bool val := false) { init(val) }
  private native Void init(Bool val)

  **
  ** The current boolean value
  **
  native Bool val

  **
  ** Atomically set the value and return the previous value.
  **
  native Bool getAndSet(Bool val)

  **
  ** Atomically set the value to 'update' if current value is
  ** equivalent to the 'expect' value.  Return true if updated, or
  ** false if current value was not equal to the expected value.
  **
  native Bool compareAndSet(Bool expect, Bool update)

  **
  ** Return 'val.toStr'
  **
  override Str toStr() { val.toStr }


  protected native override Void finalize()

}