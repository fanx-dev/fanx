
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
  
  override Str toStr() {
    return loc.toLocStr + ": " + level.name.upper + " " + msg
  }

  const LogLevel level
  const Str? file
  const Int? line
  const Int? col
}

**
** CompilerLog manages logging compiler messages.  The default
** writes everything to standard output.
**
class CompilerLog {
  CompilerErr[] errs        // accumulated errors
  CompilerErr[] warns       // accumulated warnings
  
  OutStream out
  
  new make(OutStream out := Env.cur.out)
  {
    this.errs       = CompilerErr[,]
    this.warns      = CompilerErr[,]
    this.out = out
  }
  
  **
  ** Create, log, and return a CompilerErr.
  **
  virtual CompilerErr err(Str msg, Loc? loc := null)
  {
    return errReport(CompilerErr(msg, loc))
  }

  **
  ** Create, log, and return a warning CompilerErr.
  **
  virtual CompilerErr warn(Str msg, Loc? loc := null)
  {
    return errReport(CompilerErr(msg, loc, null, LogLevel.warn))
  }

  **
  ** Log, store, and return the specified CompilerErr.
  **
  CompilerErr errReport(CompilerErr e)
  {
    locs := e.loc.toLocStr
    if (e.isWarn) {
      warns.add(e)
      out.printLine("$locs: WARN $e.msg").flush
    }
    else {
      errs.add(e)
      out.printLine("$locs: ERROR $e.msg").flush
    }
    return e
  }
  
  **
  ** Log an debug level message.
  **
  Void debug(Str msg, Loc? loc := null) {
    locs := loc == null ? "" : loc.toLocStr
    out.printLine("$locs: DEBUG $msg").flush
  }
  
  **
  ** Log an info level message.
  **
  Void info(Str msg, Loc? loc := null) {
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
