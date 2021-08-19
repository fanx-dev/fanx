//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 Feb 10 Brian Frank  Creation
//

**
** AtomicInt is used to manage an integer variable shared
** between actor/threads with atomic updates.
**
final const native class AtomicInt
{
  private const Int handle0
  private const Int handle1

  **
  ** Construct with initial value
  **
  new make(Int val := 0) { init(val) }
  private native Void init(Int val)

  **
  ** The current integer value
  **
  native Int val

  **
  ** Atomically set the value and return the previous value.
  **
  native Int getAndSet(Int val)

  **
  ** Atomically set the value to 'update' if current value is
  ** equivalent to the 'expect' value.  Return true if updated, or
  ** false if current value was not equal to the expected value.
  **
  native Bool compareAndSet(Int expect, Int update)

  **
  ** Atomically increment the current value by one and
  ** return the previous value.
  **
  Int getAndIncrement() { getAndAdd(1) }

  **
  ** Atomically decrement the current value by one and
  ** return the previous value.
  **
  Int getAndDecrement() { getAndAdd(-1) }

  **
  ** Atomically add the given value to the current value
  ** and return the previous value.
  **
  native Int getAndAdd(Int delta)

  **
  ** Atomically increment the current value by one and
  ** return the updated value.
  **
  Int incrementAndGet() { addAndGet(1) }

  **
  ** Atomically decrement the current value by one and
  ** return the updated value.
  **
  Int decrementAndGet() { addAndGet(-1) }

  **
  ** Atomically add the given value to the current value and
  ** return the updated value.
  **
  native Int addAndGet(Int delta)

  **
  ** Atomically increment the value by one
  **
  Void increment() { incrementAndGet }

  **
  ** Atomically decrement the value by one
  **
  Void decrement() { decrementAndGet }

  **
  ** Atomically add the given value to the current value
  **
  Void add(Int delta) { addAndGet(delta) }

  **
  ** Return 'val.toStr'
  **
  override Str toStr() { val.toStr }


  protected native override Void finalize()

}