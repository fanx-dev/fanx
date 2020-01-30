
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

class ParserSupport {
  CompilerErr[] errs        // accumulated errors
  CompilerErr[] warns       // accumulated warnings
  
  new make()
  {
    this.errs       = CompilerErr[,]
    this.warns      = CompilerErr[,]
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
    if (e.isWarn)
      warns.add(e)
    else
      errs.add(e)
    return e
  }
}
