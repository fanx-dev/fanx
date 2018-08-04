//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Nov 06  Brian Frank  Creation
//

**
** Task is the base class for commands to run in build scripts.
** The library of Task subclasses represent the reusable units of
** work which are composed together to implement build script
** Targets.
**
abstract class Task
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Construct with parent script.
  **
  new make(BuildScript script)
  {
    this.script = script
  }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  **
  ** Run this task.  If there is an error, the report them via
  ** the script's log and throw FatalBuildErr if the script should
  ** be terminated.
  **
  abstract Void run()

//////////////////////////////////////////////////////////////////////////
// Env
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the parent build script associated with this task.
  **
  BuildScript script { private set }

  **
  ** Convenience for script.log
  **
  BuildLog log() { return script.log }

  **
  ** Log an error and return a FatalBuildErr instance
  **
  FatalBuildErr fatal(Str msg, Err? err := null)
  {
    log.err(msg, err)
    return FatalBuildErr(msg, err)
  }

}