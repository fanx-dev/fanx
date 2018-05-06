//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//    2 Jun 06  Brian Frank  Ported from Java to Fan
//

**
** CompilerLog manages logging compiler messages.  The default
** writes everything to standard output.
**
class CompilerLog
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Construct for specified output stream.
  **
  new make(OutStream out := Env.cur.out)
  {
    this.out = out
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Is debug level enabled
  **
  Bool isDebug()
  {
    return level <= LogLevel.debug
  }

  **
  ** Indent the output.
  **
  Void indent()
  {
    indentation++
  }

  **
  ** Unindent the output.
  **
  Void unindent()
  {
    indentation--
    if (indentation < 0) indentation = 0
  }

  **
  ** Log an error level message.
  **
  Void err(Str msg, Err? err := null)
  {
    log(LogRec(DateTime.now, LogLevel.err, "compiler", msg, err))
  }

  **
  ** Log a warn level message.
  **
  Void warn(Str msg, Err? err := null)
  {
    log(LogRec(DateTime.now, LogLevel.warn, "compiler", msg, err))
  }

  **
  ** Log an info level message.
  **
  Void info(Str msg, Err? err := null)
  {
    log(LogRec(DateTime.now, LogLevel.info, "compiler", msg, err))
  }

  **
  ** Log an debug level message.
  **
  Void debug(Str msg, Err? err := null)
  {
    log(LogRec(DateTime.now, LogLevel.debug, "compiler", msg, err))
  }

  **
  ** Generate a log entry.  The log entry is only generated
  ** if the specified level is greater than or equal to
  ** the configured level field.
  **
  virtual Void log(LogRec rec)
  {
    if (rec.level < this.level) return
    if (rec.level >= LogLevel.warn) print(rec.level.toStr.upper).print(": ")
    else print(Str.spaces(indentation*2))
    printLine(rec.msg)

    if (rec.err != null)
    {
      if (isDebug)
        rec.err.trace(out)
      else
        print(Str.spaces(indentation*2+4)).printLine(rec.err)
    }
  }

//////////////////////////////////////////////////////////////////////////
// CompilerErr
//////////////////////////////////////////////////////////////////////////

  **
  ** Log a CompilerErr
  **
  virtual Void compilerErr(CompilerErr err)
  {
    if (err.level < this.level) return
    loc := err.loc.toLocStr
    if (err.isWarn)
      printLine("$loc: WARN $err.msg")
    else
      printLine("$loc: $err.msg")
    if (isDebug) err.trace(out)
  }

//////////////////////////////////////////////////////////////////////////
// IO
//////////////////////////////////////////////////////////////////////////

  **
  ** Print a string without trailing newline.
  **
  CompilerLog print(Obj? s)
  {
    out.print(s)
    return this
  }

  **
  ** Print a line.
  **
  CompilerLog printLine(Obj? s := "")
  {
    out.printLine(s).flush
    return this
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  ** Max severity of log entries to report
  LogLevel level := LogLevel.info

  ** Current level of indentation
  Int indentation := 0

  ** Sink for all output
  OutStream? out := null

}