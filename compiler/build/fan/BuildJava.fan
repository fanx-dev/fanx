//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Nov 06  Brian Frank  Creation
//

**
** BuildJava is the base class for build scripts used to manage
** building Java source code into a Java jar file.
**
abstract class BuildJava : BuildScript
{

//////////////////////////////////////////////////////////////////////////
// Pod Meta-Data
//////////////////////////////////////////////////////////////////////////

  **
  ** Required target jar file to build
  **
  Uri? jar

  **
  ** Required list of dotted package names to compile.  Each of these
  ** packages must have a corresponding source directory relative to the
  ** script directory.
  **
  Str[]? packages

  **
  ** List of files to include in compiler classpath.  The core
  ** Java rt.jar is always implied and should not be specified.
  ** These URIs are relative to the script dir.
  **
  Uri[]? cp

  **
  ** Main class name to add to manifest if not null.
  **
  Str? mainClass

//////////////////////////////////////////////////////////////////////////
// Validate
//////////////////////////////////////////////////////////////////////////

  private Void validate()
  {
    if (jar == null) throw fatal("Must set BuildJava.jar")
    if (packages == null) throw fatal("Must set BuildJava.packages")

    // boot strap checking - ensure that we aren't overwriting sys.jar
    if (jar.name == "sys.jar")
    {
      if (Env.cur.homeDir == devHomeDir)
        throw fatal("Must update 'devHome' for bootstrap build")
    }
  }

//////////////////////////////////////////////////////////////////////////
// Dump Env
//////////////////////////////////////////////////////////////////////////

  override Void dumpEnv()
  {
    super.dumpEnv

    oldLevel := log.level
    log.level = LogLevel.silent
    try
      log.out.printLine("  javaHome:      ${JdkTask(this).jdkHomeDir}")
    catch (Err e)
      log.out.printLine("  javaHome:      $e")
    finally
      log.level = oldLevel
  }

//////////////////////////////////////////////////////////////////////////
// Compile
//////////////////////////////////////////////////////////////////////////

  **
  ** Compile Java source into jar
  **
  @Target { help = "Compile Java source into jar" }
  Void compile()
  {
    validate

    log.info("compile [${scriptDir.name}]")
    log.indent

    temp     := scriptDir + `temp/`
    jdk      := JdkTask(this)
    jarExe   := jdk.jarExe
    manifest := temp + `Manifest.mf`
    jar      := this.jar.toFile

    // make temp dir
    CreateDir(this, temp).run

    // find all the packages which have out of date files
    outOfDate := findOutOfDateDirs(temp)
    if (outOfDate.isEmpty)
    {
      log.unindent
      log.info("Up to date!")
      return
    }

    // compile out of date packages
    javac := CompileJava(this)
    javac.src = outOfDate
    javac.cp.add(temp)
    if (cp != null) javac.cp.addAll(resolveFilesOrDirs(cp))
    javac.outDir = temp
    javac.run

    // write manifest
    log.info("Write Manifest [${manifest.osPath}]")
    out := manifest.out
    out.printLine("Manifest-Version: 1.0")
    if (mainClass != null) out.printLine("Main-Class: $mainClass")
    out.close

    // ensure jar target directory exists
    CreateDir(this, jar.parent).run

    // jar up temp directory
    log.info("Jar [${jar.osPath}]")
    Exec(this, [jarExe, "cfm", jar.osPath, manifest.osPath, "-C", temp.osPath, "."], temp).run

    log.unindent
  }

  private File[] findOutOfDateDirs(File temp)
  {
    acc := File[,]
    packages.each |Str p|
    {
      path := Uri.fromStr(p.replace(".", "/") + "/")
      srcDir := scriptDir + path
      outDir := temp + path
      if (anyOutOfDate(srcDir, outDir))
        acc.add(srcDir)
    }
    return acc
  }

  private Bool anyOutOfDate(File srcDir, File outDir)
  {
    return srcDir.list.any |File src->Bool|
    {
      if (src.ext != "java") return false
      out := outDir + (src.basename + ".class").toUri
      return !out.exists || out.modified < src.modified
    }
  }

//////////////////////////////////////////////////////////////////////////
// Clean
//////////////////////////////////////////////////////////////////////////

  **
  ** Delete all intermediate and target files
  **
  @Target { help = "Delete all intermediate and target files" }
  Void clean()
  {
    log.info("clean [${scriptDir.name}]")
    log.indent
    Delete(this, scriptDir + `temp/`).run
    Delete(this, jar.toFile).run
    log.unindent
  }

//////////////////////////////////////////////////////////////////////////
// Full
//////////////////////////////////////////////////////////////////////////

  **
  ** Run clean, compile
  **
  @Target { help = "Run clean, compile" }
  Void full()
  {
    clean
    compile
  }

}