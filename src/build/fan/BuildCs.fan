//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   10 Jan 06  Brian Frank  Creation
//

**
** BuildCs is the base class for build scripts used to manage
** building C# source code into a .NET exe or dll.
**
abstract class BuildCs : BuildScript
{

//////////////////////////////////////////////////////////////////////////
// Pod Meta-Data
//////////////////////////////////////////////////////////////////////////

  **
  ** Required output file created by the compiler.
  **
  Uri? output

  **
  ** Required output type. Possible values are 'exe',
  ** 'winexe', 'library' or 'module'.
  **
  Str? targetType

  **
  ** Required list of directories to compile.  All C# source
  ** files in each directory will be compiled.
  **
  Uri[]? srcDirs

  **
  ** List of libraries to link to.
  **
  Uri[] libs := Uri[,]

  **
  ** Should we skip compiling .NET code?  Default only
  ** runs C# compiler if running on Windows.
  **
  Bool skip := Env.cur.os != "win32"

//////////////////////////////////////////////////////////////////////////
// Validate
//////////////////////////////////////////////////////////////////////////

  private Void validate()
  {
    if (output == null) throw fatal("Must set BuildCs.output")
    if (targetType == null) throw fatal("Must set BuildCs.targetType")
    if (srcDirs == null) throw fatal("Must set BuildCs.srcDirs")
  }

//////////////////////////////////////////////////////////////////////////
// Dump Env
//////////////////////////////////////////////////////////////////////////

  override Void dumpEnv()
  {
    super.dumpEnv

    if (skip)
    {
      log.out.printLine("  skipped (not windows)")
      return
    }

    oldLevel := log.level
    log.level = LogLevel.silent
    try
      log.out.printLine("  dotnetHome:    ${CompileCs(this).dotnetHomeDir}")
    catch (Err e)
      log.out.printLine("  dotnetHome:    $e")
    finally
      log.level = oldLevel
  }

//////////////////////////////////////////////////////////////////////////
// Compile
//////////////////////////////////////////////////////////////////////////

  **
  ** Compile C# source into exe or dll
  **
  @Target { help = "Compile C# source into exe or dll" }
  Void compile()
  {
    if (skip)
    {
      log.info("skipping [${scriptDir.name}]")
      return
    }

    validate

    log.info("compile [${scriptDir.name}]")
    log.indent

    // compile source
    csc := CompileCs(this)
    csc.output = output.toFile
    csc.targetType = targetType
    csc.src  = resolveDirs(srcDirs)
    csc.libs = resolveFiles(libs)
    csc.run

    log.unindent
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
    Delete(this, output.toFile).run
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