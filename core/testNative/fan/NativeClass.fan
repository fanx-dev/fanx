//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 May 10  Brian Frank  Creation
//

**
** NativeClass tests an entire native class, where the
** class is wholly implemented in Java, C#, etc
**
native class NativeClass
{
  new make()

  Int add(Int a, Int b)

  Str readResource(Str name)
}