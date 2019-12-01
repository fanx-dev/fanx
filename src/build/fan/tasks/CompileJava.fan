//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Nov 06  Brian Frank  Creation
//

using compiler

**
** Run the Java compiler to produce a directory of Java classfiles.
**
class CompileJava : JdkTask
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Construct uninitialized javac task
  **
  new make(BuildScript script)
    : super(script)
  {
    this.params = (script.config("javacParams") ?: "").split.findAll |s| { !s.isEmpty }
  }

//////////////////////////////////////////////////////////////////////////
// Configuration
//////////////////////////////////////////////////////////////////////////

  **
  ** Extra parameters to pass to javac.  Default is
  ** to target 1.5 classfiles.
  **
  Str[] params

//////////////////////////////////////////////////////////////////////////
// Add
//////////////////////////////////////////////////////////////////////////

  **
  ** Add all the jars found in lib/java/ext and lib/java/ext/os
  ** to the class path.
  **
  Void cpAddExtJars()
  {
    cpAddJars(script.devHomeDir + `lib/java/ext/`)
    cpAddJars(script.devHomeDir + `lib/java/ext/$Env.cur.platform/`)
  }

  **
  ** Add all the jar files found in the specified
  ** directory to the classpath.
  **
  Void cpAddJars(File dir)
  {
    dir.list.each |File f| { if (f.ext == "jar") cp.add(f) }
  }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  **
  ** Run the javac task
  **
  override Void run()
  {
    log.info("CompileJava")
    cmd := Str[,]
    try
    {
      // build command
      cmd.add(javacExe)

      // always assume UTF-8
      cmd.add("-encoding").add("utf-8")

      cmd.addAll(params)

      // -d outDir
      if (outDir != null)
      {
        cmd.add("-d").add(outDir.osPath)
      }

      // Only add files from java.home if the JDK being used to compile is for
      // Java 8 or earlier.
      if (Env.cur.javaVersion <= 8)
      {
        // -bootclasspath rt.jar for current environment; this might
        // different from jdkHomeDir if cross-compiling; this logic is a
        // simpler version of what compilerJava::ClassPath does in Java FFI
        javaLib := File.os(Env.cur.vars.get("java.home", "") + File.sep + "lib")
        bootJars := [javaLib+`rt.jar`, javaLib+`jce.jar`]
        cmd.add("-bootclasspath")
        cmd.add(bootJars.join(File.pathSep) |File f->Str| { return f.osPath })
      }

      // -cp <classpath>
      cmd.add("-cp")
      cmd.add(cp.join(File.pathSep) |File f->Str| { return f.osPath })

      // src files/dirs
      cwd := script.scriptDir
      listFiles(cmd, cwd, src)
      log.debug(cmd.join(" "))
      //echo(cmd.join(" "))
      r := Process(cmd, cwd).run.join
      if (r != 0) throw Err.make
    }
    catch (Err e)
    {
      //e.trace
      cmds := cmd.join(" ")
      throw fatal("CompileJava failed: $cmds", e)
    }
  }

  internal Void listFiles(Str[] list, File cwd, File[] files)
  {
    files.each |File f|
    {
      // if directory, then recurse
      if (f.isDir) listFiles(list, cwd, f.list)

      // use dir/*.java on Windows so that command line doesn't
      // get too long but list every file on other operating systems
      if (Env.cur.os == "win32")
      {
        if (f.isDir && f.list.any |x| { x.ext == "java" })
          list.add(f.plus(`*.java`).osPath)
      }
      else if (f.ext == "java")
      {
        list.add(f.osPath)
      }
    }
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  ** Class path - list of jars to compile against,
  ** rt.jar is automatically included
  File[] cp := File[,]

  ** List of source files or directories to compile.  If
  ** a directory is specified, then it is recursively searched
  ** for all ".java" files.
  File[] src := File[,]

  ** Output directory
  File? outDir


}