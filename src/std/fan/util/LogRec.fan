//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   22 Dec 07  Brian Frank  Revamp
//

**
** LogRec all the information of a single logging event.
** See `docLang::Logging` for details.
**
const class LogRec
{

  **
  ** Constructor with all the fields
  **
  new make(DateTime time, LogLevel level, Str logName, Str message, Err? err := null) {
    this.time = time
    this.level = level
    this.logName = logName
    this.msg = message
    this.err = err
  }

  **
  ** Timestamp of log event
  **
  const DateTime time

  **
  ** Severity level of event
  **
  const LogLevel level

  **
  ** Name of `Log` which generated the event
  **
  const Str logName

  **
  ** Message text event
  **
  const Str msg

  **
  ** Exception if applicable
  **
  const Err? err

  **
  ** Return standard log format.
  **
  override Str toStr() {
    ts := time.toLocale("YYYY-MM-DD hh:mm:ss");
    s := StrBuf()
    s.addChar('[').add(ts).addChar(']')
     .addChar(' ').addChar('[').add(level).addChar(']')
     .addChar(' ').addChar('[').add(logName).addChar(']')
     .addChar(' ').add(msg);
    return s.toStr
  }

  **
  ** Print to the specified output stream.
  **
  Void print(OutStream out := Env.cur.out) {
    Log.printLogRec(this, out)
  }
}