//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//    3 Jun 06  Brian Frank  Ported from Java to Fantom - Megan's b-day
//

**
** Main is the main entry point for the Fantom compiler.
** Originally it was used for "fanc" command line, but it
** encapsualtes static methods used by sys.
**
class Main
{

  **
  ** mini build for boost
  **
  virtual Void main(Str[] args)
  {

    scriptDir := args.first.toUri.toFile

    podName := scriptDir.name
    summary := podName + " lib"

    Depend[]? depends := null
    if (podName == "sys") {
      depends = [,]
    }
    else {
      depends = [Depend("sys 1.0")]
    }

    srcDirs := allDir(scriptDir.uri, `fan/`)
    if (podName == "std") {
      srcDirs = [
        scriptDir.uri+`fan/collection/`,
        scriptDir.uri+`fan/time/`,
        scriptDir.uri+`fan/io/`,
        scriptDir.uri+`fan/util/`,
      ]
    }
    else if (podName == "testlib") {
      srcDirs = [ scriptDir.uri+`test/` ]
    }

    echo("src:$srcDirs")

    devHomeDir := Pod.find("build").config("devHome")
    outPodDir := devHomeDir.toUri + `lib/fan/`

    // map my config to CompilerInput structure
    ci := CompilerInput()
    //ci.inputLoc    = Loc.makeFile(scriptFile)
    ci.podName     = podName
    ci.summary     = summary
    ci.version     = Version("1.0")
    ci.depends     = depends
    ci.baseDir     = scriptDir
    ci.srcFiles    = srcDirs
    //ci.resFiles    = resDirs
    //ci.jsFiles     = jsDirs
    ci.mode        = CompilerInputMode.file
    ci.outDir      = outPodDir.toFile
    ci.output      = CompilerOutputMode.podFile

    echo("namespace: $ci.ns")

    try
    {
      Compiler(ci).compile
    }
    catch (CompilerErr err)
    {
      // all errors should already be logged by Compiler
      throw err
    }
    catch (Err err)
    {
      err.trace
    }
  }

  static Uri[] allDir(Uri base, Uri dir)
  {
    Uri[] subs := [,]
    (base + dir).toFile.walk |File f|
    {
      if(f.isDir)
      {
        rel := f.uri.relTo(base)
        subs.add(rel)
      }
    }
    return subs
  }

  **
  ** Compile the script file into a transient pod.
  ** See `sys::Env.compileScript` for option definitions.
  **
  static Pod compileScript(Str podName, File file, [Str:Obj]? options := null)
  {
    input := CompilerInput.make
    input.podName        = podName
    input.summary        = "script"
    input.version        = Version("0")
    input.log.level      = LogLevel.warn
    input.includeDoc     = true
    input.isScript       = true
    input.srcStr         = file.readAllStr
    input.srcStrLoc      = Loc.makeFile(file)
    input.mode           = CompilerInputMode.str
    input.output         = CompilerOutputMode.transientPod

    if (options != null)
    {
      log := options["log"]
      if (log != null) input.log = log

      logOut := options["logOut"]
      if (logOut != null) input.log = CompilerLog(logOut)

      logLevel := options["logLevel"]
      if (logLevel != null) input.log.level = logLevel

      fcodeDump := options["fcodeDump"]
      if (fcodeDump == true) input.fcodeDump = true
    }

    return Compiler(input).compile.transientPod
  }

}