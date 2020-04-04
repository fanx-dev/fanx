//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//

@NoDoc
@Extern
final native const class Lock
{

  ** Acquires the lock only if it is free at the time of invocation.
  Bool tryLock(Int nanoTime := -1)

  Void lock()

  Void unlock()

  Obj? sync(|->Obj?| f)
}