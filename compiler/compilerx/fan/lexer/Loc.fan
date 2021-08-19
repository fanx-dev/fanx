//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 May 06  Brian Frank  Creation
//

**
** Loc provides a source file, line number, and column number.
**
const class Loc
{
  new make(Str file, Int line := -1, Int? col := -1, Int offset := -1)
  {
    this.file = file
    this.line = line
    this.col  = col
    this.offset = offset
  }

  new makeFile(File? file, Int line := -1, Int col := -1, Int offset := -1)
  {
    if (file != null)
    {
      osPath := file.osPath
      if (osPath != null)
        this.file = osPath
      else
        this.file = file.pathStr
    }
    else {
      this.file = "Unknown"
    }
    this.line = line
    this.col  = col
    this.offset = offset
  }
  
  const static Loc invalidLoc := make("Unknown")

  static Loc makeUnknow() { invalidLoc }
  
  Str? filename()
  {
    f := file
    slash := f.indexr("/")
    if (slash == null) slash = f.indexr("\\")
    if (slash != null) f = f[slash+1..-1]
    return f
  }

  Str? fileUri()
  {
    try
    {
      return File.os(file).uri.toStr
    }
    catch
    {
      return file
    }
  }

  override Int hash()
  {
    hash := file.hash
    if (line != -1) hash = hash.xor(line.hash)
    if (col  != -1) hash = hash.xor(col.hash)
    return hash
  }

  override Bool equals(Obj? that)
  {
    x := that as Loc
    if (x == null) return false
    return file == x.file && line == x.line && col == x.col
  }

  override Int compare(Obj that)
  {
    x := (Loc)that
    if (file != x.file) return file <=> x.file
    if (line != x.line) return line <=> x.line
    return col <=> x.col
  }

  override Str toStr()
  {
    StrBuf s := StrBuf()
    if (true)
    {
      s.add("(").add(line)
      s.add(",").add(col)
      s.add(")")
    }
    return s.toStr
  }

  Str toLocStr()
  {
    StrBuf s := StrBuf()
    s.add(file)
    if (line != -1)
    {
      s.add("(").add(line)
      if (col != -1) s.add(",").add(col)
      s.add(")")
    }
    return s.toStr
  }

  const Str file
  const Int line
  const Int col
  const Int offset
}