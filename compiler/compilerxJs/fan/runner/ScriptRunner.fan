//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Jul 09  Andy Frank  Creation
//
/*
using compiler
using compiler::Compiler as FanCompiler
using [java] java.lang
using [java] javax.script

**
** ScriptRunner compiles a Fan script into JavaScript
** and runs inside Rhino.
**
class ScriptRunner
{

  Void main(Str[] args := Env.cur.args)
  {
    if (args.size == 0)
    {
      help
      return
    }

    file := args.first.toUri.toFile  // workDir?
    if (!file.exists) { echo("$file not found"); return }
    js := compile(file.in.readAllStr)

    dump := args.size > 1 ? args[1] == "-d" : false
    if (dump)
    {
      echo("--- JavaScript ---")
      echo(js)
      echo("------------------")
    }

    exec(js)
  }

  Void help()
  {
    echo("compilerJs Script Runner");
    echo("Usage:");
    echo("  sc <file> [option]");
    echo("Options:");
    echo("  -d     dump the compiled JavaScript");
  }

  Str compile(Str text)
  {
    input := CompilerInput()
    input.podName   = "temp"
    input.summary   = ""
    input.version   = Version("0")
    input.log.level = LogLevel.silent
    input.isScript  = true
    input.srcStr    = text
    input.srcStrLoc = Loc("")
    input.mode      = CompilerInputMode.str
    input.output    = CompilerOutputMode.js

    // compile the source
    compiler := FanCompiler(input)
    CompilerOutput? co := null
    try co = compiler.compile; catch {}
    if (co == null)
    {
      buf := StrBuf()
      compiler.errs.each |err| { buf.add("$err.line:$err.col:$err.msg\n") }
      echo(buf)
      Env.cur.exit(-1)
    }
    return compiler.js
  }

  Void exec(Str js)
  {
    engine := ScriptEngineManager().getEngineByName("js");
    try
    {
      // TODO - pull in other pods
      engine.eval(Pod.find("sys").file(`/sys.js`).readAllStr)
      engine.eval((Env.cur.homeDir + `etc/sys/tz.js`).readAllStr)
    }
    catch (Err err)
    {
      echo("*** SYS FAILED ***")
      err.trace
      return
    }
    engine.eval(
     "try
      {
      $js
      fan.temp.Main.make().main();
      }
      catch (err) { print('ERROR: ' + err + '\\n'); }
      ")
  }
}
*/