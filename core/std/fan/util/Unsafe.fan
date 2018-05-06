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
native const final class Unsafe
{

  **
  ** Wrap specified object.
  **
  new make(Obj? val)

  **
  ** Get the wrapped object.
  **
  Obj? val()

}