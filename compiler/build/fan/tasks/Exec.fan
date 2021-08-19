//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Nov 06  Brian Frank  Creation
//

**
** Exec is used to run an external OS process
**
class Exec : Task
{

  new make(BuildScript script, Str[] cmd, File? dir := null)
    : super(script)
  {
    this.process = Process(cmd, dir)
  }

  override Void run()
  {
    cmd := process.command.join(" ")
    try
    {
      log.info("Exec [$cmd]")
      result := process.run.join
      if (result != 0) throw Err.make
    }
    catch (Err err)
    {
      if (log.isDebug) err.trace
      throw fatal("Exec failed [$cmd]")
    }
  }

  **
  ** Given a executable file turn it into a path to use for Exec:
  **   - if running on Window's add the '.exe' extension
  **   - return `sys::File.osPath`
  **
  static Str exePath(File exe)
  {
    path := exe.osPath
    if (Env.cur.os == "win32") path += ".exe"
    return path
  }

  Process process
}