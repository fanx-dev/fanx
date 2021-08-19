//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//

**
** call initial when val is null
**
final rtconst class Lazy<T>
{
  private Obj? value
  private const Lock lock := Lock()
  private const |->T| initial
  
  new make(|->T| initial) {
    this.initial = initial.toImmutable
  }

  T get() {
    if (value == null) {
      lock.lock
      try {
        res := initial.call()
        value = res.toImmutable
      }
      finally {
        lock.unlock
      }
    }
    return value
  }

  override Bool isImmutable() { true }

  override Lazy<T> toImmutable() { this }
}