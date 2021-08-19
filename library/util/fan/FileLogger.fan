//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   8 Apr 08  Brian Frank  Creation
//

using concurrent

**
** FileLogger appends Str log entries to a file.  You
** can add a FileLogger as a Log handler:
**
**    sysLogger := FileLogger
**    {
**      dir = scriptDir
**      filename = "sys-{YYMM}.log"
**    }
**    Log.addHandler |rec| { sysLogger.writeLogRec(rec) }
**
** See `filename` for specifying a datetime pattern for your log files.
**
const class FileLogger : ActorPool
{

  **
  ** Constructor must set `dir` and `filename`
  **
  new make(|This|? f := null) : super(f) {}

  **
  ** Directory used to store log file(s).
  **
  const File dir

  **
  ** Log filename pattern.  The name may contain a pattern between
  ** '{}' using the pattern format of `sys::DateTime.toLocale`.  For
  ** example to maintain a log file per month, use a filename such
  ** as "mylog-{YYYY-MM}.log".
  **
  const Str filename

  **
  ** Callback called each time the file logger opens an existing
  ** or new log file.  Callback should write any header information
  ** to the given output stream.  The callback will occur on the logger's
  ** actor, so take care not incur additional actor messaging.
  **
  const |OutStream|? onOpen

  **
  ** Append string log message to file.
  **
  Void writeLogRec(LogRec rec)
  {
    actor.send(rec)
  }

  **
  ** Append string log message to file.
  **
  Void writeStr(Str msg)
  {
    actor.send(msg)
  }

  **
  ** Run the script
  **
  internal Obj? receive(Obj msg)
  {
    try
    {
      // get or initialize current state
      state := Actor.locals["state"] as FileLoggerState
      if (state == null)
        Actor.locals["state"] = state = FileLoggerState(this)

      // append to current file
      if (msg is LogRec)
      {
        rec := (LogRec)msg
        state.out.printLine(rec)
        if (rec.err != null) rec.err.traceTo(state.out)
        state.out.flush
      }
      else
      {
        state.out.printLine(msg).flush
      }
    }
    catch (Err e)
    {
      log.err("FileLogger.receive", e)
    }
    return null
  }

  private const static Log log := Log.get("logger")
  private const Actor actor := Actor(this) |msg| { receive(msg) }

}

internal class FileLoggerState
{
  new make(FileLogger logger)
  {
    this.logger   = logger
    this.dir      = logger.dir
    this.filename = logger.filename
    i := filename.index("{")
    if (i != null)
      this.pattern = filename[i+1 ..< filename.index("}")]
    else
      open(dir + filename.toUri)
  }

  OutStream out()
  {
    // check if we need to open a new file
    if (pattern != null && DateTime.now.toLocale(pattern) != curPattern)
    {
      // if we currently have a file open, then close it
      curOut?.close

      // open new file with new pattern
      curPattern = DateTime.now.toLocale(pattern)
      newName := filename[0..<filename.index("{")] +
                 curPattern +
                 filename[filename.index("}")+1..-1]
      curFile := dir + newName.toUri
      return open(curFile)
    }

    // current output stream
    return curOut
  }

  OutStream open(File curFile)
  {
    try
    {
      this.curOut = curFile.out(true)
    }
    catch (Err e)
    {
      echo("ERROR: Cannot open log file: $curFile")
      e.trace
      this.curOut =  NilOutStream()
    }

    try
      logger.onOpen?.call(this.curOut)
    catch (Err e)
      curOut.printLine("ERROR: FileLogger.onOpen\n${e.traceToStr}")

    return this.curOut
  }

  const FileLogger logger
  const Str filename
  const File dir
  Str? pattern
  Str curPattern := ""
  OutStream? curOut
}

internal class NilOutStream : OutStream
{
  new make() : super() {}
  override This write(Int byte) { this }
  override This writeBuf(Buf buf, Int n := buf.remaining) { this }
  override This flush()  { this }
  override This sync() { this }
  override Bool close() { true }
  override This writeBytes(Array<Int8> ba, Int off := 0, Int len := ba.size) { this }
  override Endian endian := Endian.big
  override Charset charset := Charset.utf8
}