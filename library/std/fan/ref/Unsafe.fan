//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   8 Feb 09  Brian Frank  Creation
//

**
** Unsafe is used to wrap a non-const mutable objects so that
** it can be passed as an immutable reference.
**
rtconst final class Unsafe<T>
{
  private Obj? value
  **
  ** Wrap specified object.
  **
  new make(T val) { value = val }

  **
  ** Get the wrapped object.
  **
  T val() { value }

  **
  ** Get the wrapped object.
  **
  T get() { value }

  override Bool isImmutable() { true }

  override Unsafe<T> toImmutable() { this }
}