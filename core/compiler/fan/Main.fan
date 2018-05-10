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
    file := args.first.toUri.toFile
    props := file.in.readProps

    podName := props.get("podName", file.basename)
    summary := props.get("summary","$podName lib")

    //get depends
    dependsStr := props.get("depends", null)
    Depend[]? depends
    if (dependsStr == null) {
      if (podName == "sys") depends = Depend[,]
      else depends = [Depend("sys 1.0")]
    }
    else {
      depends = dependsStr.split(',').map{ Depend(it) }
    }

    //get srcDirs
    srcDirs := Uri[,]
    props.get("srcDirs", null)?.split(',')?.each |d| {
      if (d.endsWith("*")) {
        srcUri := d[0..<-1].toUri
        dirs := allDir(file.uri, srcUri)
        srcDirs.addAll(dirs)
      }
      else {
        srcDirs.add(d.toUri)
      }
    }
    if (srcDirs.isEmpty) {
      srcDirs = allDir(file.uri, `fan/`)
    }

    //get outPodDir
    Uri? outPodDir
    outPodDirStr := props.get("outPodDir", null)
    if (outPodDirStr != null) outPodDir = outPodDirStr.toUri
    else {
      devHomeDir := Pod.find("build").config("devHome")
      if (devHomeDir != null) outPodDir = devHomeDir.toUri + `lib/fan/`
      if (outPodDir == null) {
        outPodDir = Env.cur.workDir.plus(`lib/fan/`).uri
      }
    }
    echo("src:$srcDirs")

    // map my config to CompilerInput structure
    ci := CompilerInput()
    //ci.inputLoc    = Loc.makeFile(scriptFile)
    ci.podName     = podName
    ci.summary     = summary
    ci.version     = Version("1.0")
    ci.depends     = depends
    ci.baseDir     = file.parent
    ci.srcFiles    = srcDirs
    //ci.resFiles    = resDirs
    //ci.jsFiles     = jsDirs
    ci.mode        = CompilerInputMode.file
    ci.outDir      = outPodDir.toFile
    ci.output      = CompilerOutputMode.podFile

    //echo("namespace: $ci.ns")

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