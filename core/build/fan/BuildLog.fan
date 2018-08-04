//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Nov 06  Brian Frank  Creation
//

using compiler

**
** BuildLog is used for logging build scripts
**
class BuildLog : CompilerLog
{

  new make(OutStream out := Env.cur.out)
    : super(out)
  {
  }

}