//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//

@NoDoc
final native const class Lock
{
  //native padding
  private const Int handle0
  private const Int handle1
  private const Int handle2
  private const Int handle3
  private const Int handle4
  private const Int handle5
  private const Int handle6
  private const Int handle7
  private const Int handle8
  private const Int handle9
  private const Int handle10
  private const Int handle11
  private const Int handle12
  private const Int handle13
  private const Int handle14
  private const Int handle15
  private const Int handle16
  private const Int handle17
  private const Int handle18
  private const Int handle19

  new make() { init() }
  private native Void init()

  ** Acquires the lock only if it is free at the time of invocation.
  Bool tryLock(Int nanoTime := -1)

  Void lock()

  Void unlock()

  Obj? sync(|->Obj?| f) {
    lock
    try {
      return f.call()
    }
    finally {
      unlock
    }
    return null
  }

  protected native override Void finalize()
}