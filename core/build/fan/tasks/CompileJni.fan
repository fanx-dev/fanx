//
// Copyright (c) 2013, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   30 May 2013  Andy Frank  Creation
//

**
** Compile JNI C source code.
**
class CompileJni : Task
{
  ** Constructor.
  new make(BuildScript script) : super(script) {}

  ** List of source files or directories to compile
  File[] src := File[,]

  ** Library for compiler output.
  Str? lib

  ** Output directory for compiler.
  File? out

  ** Run JNI task
  override Void run()
  {
    log.info("CompileJni")
    try
    {
      // build command
      cmd := Str[,]

      // platform-specific parameters
      switch (Env.cur.os)
      {
        case "win32":
          // cl ...
          throw Err("win32 not yet implemented")

        case "macosx":
          cmd.add("gcc")
          cmd.add("-dynamiclib")
          cmd.add("-o"); cmd.add((out + platLib).osPath)
          cmd.add("-I/System/Library/Frameworks/JavaVM.framework/Headers")

        default:
          // assume gcc/linux for all other platforms
          cc := script.config("cc") ?: "gcc"
          jdkHome := script.configDir("jdkHome")
          cmd.add(cc)
          cmd.add("-shared")
          cmd.add("-fpic")
          cmd.add("-o"); cmd.add((out + platLib).osPath)
          cmd.add("-I${jdkHome}include")
          cmd.add("-I${jdkHome}include.linux")
      }

      // src files
      src.each |dir| { addFiles(dir, cmd) }

      // run cc
      log.debug(cmd.join(" "))
      r := Process(cmd).run.join
      if (r != 0) throw Err.make
    }
    catch (Err err)
    {
      err.trace
      throw fatal("CompileJni failed")
    }
  }

  ** Get platform-specific library name.
  internal Uri platLib()
  {
    switch (Env.cur.os)
    {
      case "win32":  return `${lib}.dll`
      case "macosx": return `lib${lib}.jnilib`
      default:       return `lib${lib}.so`
    }
  }

  private Void addFiles(File file, Str[] cmd)
  {
    if (file.isDir) file.listFiles.each |f| { addFiles(f, cmd) }
    else if (file.ext == "c") cmd.add(file.osPath)
  }
}
