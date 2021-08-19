//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Nov 06  Brian Frank  Creation
//

**
** TargetMethod wraps a build target method which may be executed independently
** within a build script.  Targets are the top level unit for organizing
** build scripts - each script publishes its available targets via
** `BuildScript.targets`.
**
class TargetMethod
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Construct a target to run under the specified build script.
  ** The name is the key used to invoke this target from the command
  ** line. Description is used for usage summary.  Func is invoked
  ** when this target is executed.
  **
  new make(BuildScript script, Method method)
  {
    this.script  = script
    this.method  = method
  }

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the parent build script associated with this task.
  **
  BuildScript script { private set }

  **
  ** Method to invoke when this target is executed.
  **
  Method method { private set }

  **
  ** Method of the target.
  **
  virtual Str name() { method.name }

  **
  ** Summary description for usage help, derived
  ** from `Target` facet on method.
  **
  virtual Str help() { method.facet(Target#)->help }

  **
  ** Return name.
  **
  override Str toStr() { name }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  **
  ** Run this target by invoking the target's method.  If the target
  ** fails to run then it should report errors via the log and throw
  ** FatalBuildErr.
  **
  virtual Void run()
  {
    try
    {
      method.callOn(script, [,])
    }
    catch (FatalBuildErr err)
    {
      throw err
    }
    catch (Err err)
    {
      script.log.err("Target '$name' failed [$script.toStr]")
      err.trace
      throw FatalBuildErr("", err)
    }
  }

}