//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Nov 06  Brian Frank  Creation
//

**
** FatalBuildErr is thrown to immediately terminate
** the current build script.
**
const class FatalBuildErr : Err
{
  new make(Str msg := "", Err? cause := null)
    : super(msg, cause)
  {
  }
}