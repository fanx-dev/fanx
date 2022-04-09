//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//    2 Jun 06  Brian Frank  Ported from Java to Fan
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
      this.loc = loc
    }
    else {
      this.loc = Loc.makeUnknow
    }
  }

  //Loc loc() { Loc(file ?: "Unknown", line, col) }

  Bool isErr() { level === LogLevel.err }

  Bool isWarn() { level === LogLevel.warn }
  
  override Str toStr() {
    return loc.toLocStr + ": " + level.name.upper + " " + msg
  }

  const LogLevel level
  const Loc loc
}

**
** CompilerLog manages logging compiler messages.  The default
** writes everything to standard output.
**
class CompilerLog {
  CompilerErr[] errs        // accumulated errors
  CompilerErr[] warns       // accumulated warnings
  
  OutStream out
  
  ** Max severity of log entries to report
  LogLevel level
  
  Bool suppressErr := false    // throw SuppressedErr instead of CompilerErr
  
  new make(OutStream out := Env.cur.out)
  {
    this.errs       = CompilerErr[,]
    this.warns      = CompilerErr[,]
    this.out = out
    this.level = Log.get(CompilerLog#.pod.name).level
  }

  Void clearByFile(Str file) {
    //path := file.osPath
    errs = errs.findAll { it.loc.file != file }
  }
  
  **
  ** Create, log, and return a CompilerErr.
  **
  virtual CompilerErr err(Str msg, Loc? loc := null)
  {
    if (suppressErr) throw SuppressedErr.make
    return errReport(CompilerErr(msg, loc))
  }

  **
  ** Create, log, and return a warning CompilerErr.
  **
  virtual CompilerErr warn(Str msg, Loc? loc := null)
  {
    if (suppressErr) throw SuppressedErr.make
    return errReport(CompilerErr(msg, loc, null, LogLevel.warn))
  }

  **
  ** Log, store, and return the specified CompilerErr.
  **
  CompilerErr errReport(CompilerErr e)
  {
    if (suppressErr) throw SuppressedErr.make
    locs := e.loc.toLocStr
    if (e.isWarn) {
      warns.add(e)
    }
    else if (e.isErr) {
      errs.add(e)
    }
    
    if (e.level >= this.level) {
      out.printLine(e.toStr).flush
    }
    return e
  }
  
  **
  ** Log an debug level message.
  **
  Void debug(Str msg, Loc? loc := null) {
    if (LogLevel.debug < this.level) return
    locs := loc == null ? "" : loc.toLocStr
    out.printLine("$locs: DEBUG $msg").flush
  }
  
  **
  ** Log an info level message.
  **
  Void info(Str msg, Loc? loc := null) {
    if (LogLevel.debug < this.level) return
    locs := loc == null ? "" : loc.toLocStr
    out.printLine("$locs: INFO $msg").flush
  }
  
  override Str toStr() {
    s := StrBuf()
    errs.each { s.add(it).add("\n") }
    warns.each { s.add(it).add("\n") }
    return s.toStr
  }
}
**************************************************************************
** SuppressedErr
**************************************************************************

internal const class SuppressedErr : Err
{
  new make() : super("", null) {}
}