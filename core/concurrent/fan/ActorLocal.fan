//
// Copyright (c) 2018, chunquedong
// Licensed under the LGPL
// History:
//   2017-08-12  Jed Young  Creation
//

final const class ActorLocal<T> {
  private static const AtomicInt counter := AtomicInt()
  private const Str key := counter.incrementAndGet.toStr
  private const |->T|? initial

  new make(|->T|? initial := null) {
    this.initial = initial
  }

  ** Returns the value in the current actor.
  T? get() {
    val := Actor.locals[key]
    if (val == null && initial != null) {
      val = initial()
      Actor.locals[key] = val
    }
    return val
  }

  ** Sets the current actor's variable to the specified value.
  This set(T val) {
    Actor.locals[key] = val
    return this
  }

  ** Removes the current actor's value
  Void remove() {
    Actor.locals.remove(key)
  }
}