//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   5 Nov 06  Brian Frank  Creation
//

**
** Process manages spawning external OS processes.
**
final class Process
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Construct a Process instanced used to launch an external
  ** OS process with the specified command arguments.
  ** The first item in the 'cmd' list is the executable
  ** itself, then rest are the parameters.
  **
  new make(Str[] cmd := Str[,], File? dir := null) {
    command = cmd
    this.dir = dir
  }

//////////////////////////////////////////////////////////////////////////
// Configuration
//////////////////////////////////////////////////////////////////////////

  **
  ** Command argument list used to launch process.
  ** The first item is the executable itself, then rest
  ** are the parameters.
  **
  Str[] command

  **
  ** Environment variables to pass to new process as a mutable
  ** map of string key/value pairs.  This map is initialized
  ** with the current process environment.
  **
  native Str:Str env()

  **
  ** Working directory of process.
  **
  File? dir

  **
  ** If true, then stderr is redirected to the output
  ** stream configured via the 'out' field, and the 'err'
  ** field is ignored.  The default is true.
  **
  Bool mergeErr := true

  **
  ** The output stream used to sink the process stdout.
  ** Default is to send to `Env.out`.  If set to null, then
  ** output is silently consumed like /dev/null.
  **
  OutStream? out := Env.cur.out

  **
  ** The output stream used to sink the process stderr.
  ** Default is to send to `Env.err`.  If set to null, then
  ** output is silently consumed like /dev/null.  Note
  ** this field is ignored if `mergeErr` is set
  ** true, in which case stderr goes to the stream configured
  ** via 'out'.
  **
  OutStream? err := Env.cur.err

  **
  ** The input stream used to source the process stdin.
  ** If null, then the new process will block if it attempts
  ** to read stdin.  Default is null.
  **
  InStream? in := null

  **
  ** Returns the output stream connected to the normal input of the subprocess
  **
  native OutStream outToIn()

//////////////////////////////////////////////////////////////////////////
// Lifecycle
//////////////////////////////////////////////////////////////////////////

  **
  ** Spawn this process.  See `join` to wait until the process
  ** finished and to get the exit code.  Return this.
  **
  native This run()

  **
  ** Wait for this process to exit and return the exit code.
  ** This method may only be called once after 'run'.
  **
  native Int join()

  **
  ** Kill this process.  Returns this.
  **
  native This kill()

}