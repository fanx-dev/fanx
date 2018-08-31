//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Jul 06  Brian Frank  Creation
//  21 Dec 07  Brian Frank  Revamp
//

/*
internal class LogMgr {
  private Str:Log map := [:]
  private |LogRec rec|[] handlers := [,]
  private Lock lock := Lock()

  new make() {
    handlers.add |r|{ r.print }
  }

  Log[] logs() { lock.sync { map.vals } }

  Log find(Str name, Bool checked) {
    res := lock.sync { map.get(name) }
    if (checked && res == null) throw Err()
    return res
  }

  Void doRegister(Log log) {
    lock.sync {
      map[log.name] = log
    }
  }
}
*/

**
** LogLevel provides a set of discrete levels used to customize logging.
** See `docLang::Logging` for details.
**
enum class LogLevel
{
  debug,
  info,
  warn,
  err,
  silent
}

**
** Log provides a simple, but standardized mechanism for logging.
**
** See `docLang::Logging` for details and [examples]`examples::sys-logging`.
**
const class Log
{
//////////////////////////////////////////////////////////////////////////
// Factory
//////////////////////////////////////////////////////////////////////////

  **
  ** Return a list of all the active logs which
  ** have been registered since system startup.
  **
  native static Log[] list()

  **
  ** Find a registered log by name.  If the log doesn't exist and
  ** checked is false then return null, otherwise throw Err.
  **
  native static Log? find(Str name, Bool checked := true)

  **
  ** Find an existing registered log by name or if not found then
  ** create a new registered Log instance with the given name.
  ** Name must be valid according to `Uri.isName` otherwise
  ** NameErr is thrown.
  **
  static Log get(Str name) {
    Uri.checkName(name)
    l := find(name, false)
    if (l == null) {
      l = make(name, true)
    }
    return l
  }

  **
  ** Create a new log by name.  The log is added to the VM log registry
  ** only if 'register' is true.  If register is true and a log has already
  ** been created for the specified name then throw ArgErr.  Name must
  ** be valid according to `Uri.isName` otherwise NameErr is thrown.
  **
  new make(Str name, Bool register) {
    Uri.checkName(name)
    this.name = name
    val := Env.cur.props(Int#.pod, `log.props`, 1min).get(name)
    if (val != null) level = LogLevel(val)
    if (register) doRegister(this)
  }

  private native static Void doRegister(Log log)

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Return name of the log.
  **
  const Str name

  **
  ** Return name.
  **
  override Str toStr() { name }

//////////////////////////////////////////////////////////////////////////
// Severity Level
//////////////////////////////////////////////////////////////////////////

  **
  ** The log level field defines which log entries are reported
  ** versus ignored.  Anything which equals or is more severe than
  ** the log level is logged.  Anything less severe is ignored.
  ** If the level is set to silent, then logging is disabled.
  **
  native LogLevel level
  //native Void setLevel(LogLevel level)

  **
  ** Return if this log is enabled for the specified level.
  **
  Bool isEnabled(LogLevel level) { this.level.ordinal <= level.ordinal }

  **
  ** Return if error level is enabled.
  **
  Bool isErr() { isEnabled(LogLevel.err) }

  **
  ** Return if warn level is enabled.
  **
  Bool isWarn() { isEnabled(LogLevel.warn) }

  **
  ** Return if info level is enabled.
  **
  Bool isInfo() { isEnabled(LogLevel.info) }

  **
  ** Return if debug level is enabled.
  **
  Bool isDebug() { isEnabled(LogLevel.debug) }

//////////////////////////////////////////////////////////////////////////
// Logging
//////////////////////////////////////////////////////////////////////////

  **
  ** Generate a `LogLevel.err` log entry.
  **
  Void err(Str msg, Err? err := null) {
    log(LogRec.make(DateTime.now, LogLevel.err, name, msg, err))
  }

  **
  ** Generate a `LogLevel.warn` log entry.
  **
  Void warn(Str msg, Err? err := null) {
    log(LogRec.make(DateTime.now, LogLevel.warn, name, msg, err))
  }

  **
  ** Generate a `LogLevel.info` log entry.
  **
  Void info(Str msg, Err? err := null) {
    log(LogRec.make(DateTime.now, LogLevel.info, name, msg, err))
  }

  **
  ** Generate a `LogLevel.debug` log entry.
  **
  Void debug(Str msg, Err? err := null) {
    log(LogRec.make(DateTime.now, LogLevel.debug, name, msg, err))
  }

  ** static log
  native static Void slog(Str name, LogRec rec)

  **
  ** Publish a log entry.  The convenience methods `err`, `warn`
  ** `info`, and `debug` all route to this method for centralized
  ** handling.  The standard implementation is to call each of the
  ** installed `handlers` if the specified level is enabled.
  **
  native virtual Void log(LogRec rec)

//////////////////////////////////////////////////////////////////////////
// Handlers
//////////////////////////////////////////////////////////////////////////

  **
  ** List all the handler functions installed to process log events.
  **
  native static |LogRec rec|[] handlers()

  **
  ** Install a handler to receive callbacks on logging events.
  ** If the handler func is not immutable, then throw NotImmutableErr.
  **
  native static Void addHandler(|LogRec rec| handler)

  **
  ** Uninstall a log handler.
  **
  native static Void removeHandler(|LogRec rec| handler)


  internal native static Void printLogRec(LogRec rec, OutStream out)
}