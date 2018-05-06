//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 May 06  Brian Frank  Creation
//

**
** CompilerErr - instances should always be created via CompilerStep.err().
**
const class CompilerErr : Err
{

  new make(Str msg, Loc? loc, Err? cause := null, LogLevel level := LogLevel.err)
    : super(msg, cause)
  {
    this.level = level
    if (loc != null)
    {
      this.file = loc.file
      this.line = loc.line
      this.col  = loc.col
    }
  }

  Loc loc() { Loc(file ?: "Unknown", line, col) }

  Bool isErr() { level === LogLevel.err }

  Bool isWarn() { level === LogLevel.warn }

  const LogLevel level
  const Str? file
  const Int? line
  const Int? col
}