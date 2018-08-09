//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-18 Jed Young Creation
//

final native const class ThreadLocal<T> {

  new make(|->T|? initial := null)

  ** Returns the value in the current thread's copy of this thread-local variable.
  T? get()

  ** Sets the current thread's copy of this thread-local variable to the specified value.
  This set(T val)

  ** Removes the current thread's value for this thread-local variable
  Void remove()
}