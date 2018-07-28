//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Jul 06  Brian Frank  Creation
//

//using concurrent

class UsafeLogRec {
  LogRec? logRec := null
  static const Unsafe<UsafeLogRec> cur := Unsafe(UsafeLogRec())
}

**
** LogTest
**
class LogTest : Test
{

//////////////////////////////////////////////////////////////////////////
// LogLevel
//////////////////////////////////////////////////////////////////////////

  Void testLogLevel()
  {
    verifyEq(LogLevel#.qname, "std::LogLevel")
    verifyEq(LogLevel.vals, [LogLevel.debug, LogLevel.info, LogLevel.warn, LogLevel.err, LogLevel.silent])
    verifyEq(LogLevel.vals.isImmutable, true)

    verifyEq(LogLevel.debug.ordinal,  0)
    verifyEq(LogLevel.info.ordinal,   1)
    verifyEq(LogLevel.warn.ordinal,   2)
    verifyEq(LogLevel.err.ordinal,    3)
    verifyEq(LogLevel.silent.ordinal, 4)

    verifySame(LogLevel.fromStr("warn"), LogLevel.warn)

    verify(LogLevel.silent > LogLevel.err)
    verify(LogLevel.err    > LogLevel.debug)
    verify(LogLevel.err    > LogLevel.warn)
    verify(LogLevel.warn   > LogLevel.info)
  }

//////////////////////////////////////////////////////////////////////////
// Make
//////////////////////////////////////////////////////////////////////////

  Void testMake()
  {
    log := log()
    verifyErr(ArgErr#) { x := TestLog.make(log.name, true) }
    verifyEq(log.name, "testSys.TestLog")
    verifyEq(log.level, LogLevel.info)
// TODO
//    verifySame("/sys/logs/$log.name".toUri.resolve.obj, log)

    verify(Log.list.contains(log))
    verifySame(Log.get(log.name),  log)
    verifySame(Log.find(log.name), log)
    verifySame(Log.find(log.name, true), log)
    verifyEq(Log.find("testSys.foobar", false), null)
    verifyErr(Err#) { Log.find("testSys.foobar") }
    verifyErr(Err#) { Log.find("testSys.foobar", true) }
    verifyErr(NameErr#) { Log.get("@badName") }
    verifyErr(NameErr#) { x := Log.make("no good", true) }
    verifyErr(NameErr#) { x := TestLog.make("no good", false) }

    // unregistered
    unreg := Log("testSysUnreg", false)
    verifyEq(unreg.name, "testSysUnreg")
    verifyEq(Log.list.contains(unreg), false)
    verifyEq(Log.find(unreg.name, false), null)

    // unregistered dups allowed
    unreg2 := TestLog("testSysUnreg", false)
    verifyNotSame(unreg, unreg2)
    verifyEq(unreg2.name, "testSysUnreg")
    verifyEq(Log.list.contains(unreg2), false)
    verifyEq(Log.find(unreg2.name, false), null)
  }

//////////////////////////////////////////////////////////////////////////
// Error
//////////////////////////////////////////////////////////////////////////

  Void testError()
  {
    log := log()
    err := Err.make

    log.level = LogLevel.silent
    reset
    log.err("xyz")
    verifyLog(null)
    reset
    log.err("xyz", err)
    verifyLog(null)

    verifyFalse(log.isEnabled(LogLevel.err))
    verifyFalse(log.isErr)
    verifyFalse(log.isWarn)
    verifyFalse(log.isInfo)
    verifyFalse(log.isDebug);

    [LogLevel.err, LogLevel.warn, LogLevel.info, LogLevel.debug].each |LogLevel level|
    {
      log.level = level
      reset
      log.err("xyz")
      verifyLog(LogLevel.err, "xyz", null)
      reset
      log.err("xyz", err)
      verifyLog(LogLevel.err, "xyz", err)
    }
  }



//////////////////////////////////////////////////////////////////////////
// Warning
//////////////////////////////////////////////////////////////////////////

  Void testWarning()
  {
    log := log()
    err := Err.make;

    [LogLevel.silent, LogLevel.err].each |LogLevel level|
    {
      log.level = level
      reset
      log.warn("xyz")
      verifyLog(null)
      reset
      log.warn("xyz", err)
      verifyLog(null);
    };

    [LogLevel.warn, LogLevel.info, LogLevel.debug].each |LogLevel level|
    {
      log.level = level
      reset
      log.warn("xyz")
      verifyLog(LogLevel.warn, "xyz", null)
      reset
      log.warn("xyz", err)
      verifyLog(LogLevel.warn, "xyz", err)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Info
//////////////////////////////////////////////////////////////////////////

  Void testInfo()
  {
    log := log()
    err := Err.make;

    [LogLevel.silent, LogLevel.err, LogLevel.warn].each |LogLevel level|
    {
      log.level = level
      reset
      log.info("xyz")
      verifyLog(null)
      reset
      log.info("xyz", err)
      verifyLog(null);
    };

    [LogLevel.info, LogLevel.debug].each |LogLevel level|
    {
      log.level = level
      reset
      log.info("xyz")
      verifyLog(LogLevel.info, "xyz", null)
      reset
      log.info("xyz", err)
      verifyLog(LogLevel.info, "xyz", err)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Debug
//////////////////////////////////////////////////////////////////////////

  Void testDebug()
  {
    log := log()
    err := Err.make;

    [LogLevel.silent, LogLevel.err, LogLevel.warn, LogLevel.info].each |LogLevel level|
    {
      log.level = level
      reset
      log.debug("xyz")
      verifyLog(null)
      reset
      log.debug("xyz", err)
      verifyLog(null);
    };

    [LogLevel.debug].each |LogLevel level|
    {
      log.level = level
      reset
      log.debug("xyz")
      verifyLog(LogLevel.debug, "xyz", null)
      reset
      log.debug("xyz", err)
      verifyLog(LogLevel.debug, "xyz", err)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Handlers
//////////////////////////////////////////////////////////////////////////

  Void testHandlers()
  {
    console := Log.handlers.first
    Log.removeHandler(console)
    try
    {
      h := |LogRec rec|
      {
        UsafeLogRec.cur.val.logRec = rec
      }

      Log.addHandler(h)
      verify(Log.handlers.contains(h))
      verifyErr(NotImmutableErr#) { Log.addHandler { mutableHandler(it) } }

      reset
      Log.get("testSys.LogTestToo").info("what")
      verifyLog(LogLevel.info, "what", null)

      Log.removeHandler(h)
      verify(!Log.handlers.contains(h))

      reset
      Log.get("testSys.LogTestToo").info("what")
      verifyLog(null)
    }
    finally
    {
      Log.addHandler(console)
    }
  }

  Void mutableHandler(LogRec rec) {}

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  Void verifyLog(LogLevel? level, Str? msg := null, Err? err := null)
  {
    log := log()
    LogRec? rec := UsafeLogRec.cur.val.logRec
    if (level == null)
    {
      verifyEq(level, null)
    }
    else
    {
      verify(start->ticks <= rec.time->ticks && rec.time->ticks < (Int)start->ticks + (Int)1sec->ticks)
      verifyEq(rec.level, level)
      verifyEq(rec.msg,  msg)
      verifyEq(rec.err,  err)
    }
  }

  Void reset()
  {
    UsafeLogRec.cur.val.logRec = null
  }

  // Lazy Log Construction
  static TestLog log()
  {
    log := Log.find("testSys.TestLog", false)
    if (log == null) log = TestLog("testSys.TestLog", true)
    return (TestLog)log
  }

  DateTime start := DateTime.now
}

//////////////////////////////////////////////////////////////////////////
// TestLog
//////////////////////////////////////////////////////////////////////////

const class TestLog : Log
{
  new make(Str name, Bool reg) : super(name, reg) {}

  override Void log(LogRec rec)
  {
    // super.log(time, level, msg, err)
    if (isEnabled(level))
      UsafeLogRec.cur.val.logRec = rec
  }

}