//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Nov 06  Brian Frank  Creation
//

using compiler

**
** FanScript is used to compile a Fantom script into
** memory and run it via reflection.
**
class FanScript : Task
{
  **
  ** Make with script name, arguments are Fantom arguments
  ** passed to main method (**not** command line string arguments)
  **
  new make(BuildScript script, File file, Obj[]? args := null)
    : super(script)
  {
    this.file = file
    this.args = args ?: [,]
  }

  Pod compile()
  {
    try
    {
      return Env.cur.compileScript(file).pod
    }
    catch (CompilerErr err)
    {
      // all errors should already be logged by Compiler
      throw FatalBuildErr.make
    }
    catch (Err err)
    {
      err.trace
      throw fatal("Cannot load script [$file]")
    }
  }

  override Void run()
  {
    // run main on first type with specified args
    t := compile.types.first
    main := t.method("main")
    if (main.isStatic)
      main.callList(args)
    else
      main.callOn(t.make, args)
  }

  File file
  Obj[] args
}