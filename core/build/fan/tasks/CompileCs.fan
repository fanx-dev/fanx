//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   10 Jan 06  Andy Frank  Creation
//

using compiler

**
** Run the C# compiler to produce an exe or dll.
**
class CompileCs : Task
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Initialize the .NET environment fields for csc.exe.
  **
  new make(BuildScript script)
    : super(script)
  {
    // dotnetHomeDir
    dotnetHomeDir = script.configDir("dotnetHome") ?:
      throw fatal("Must config build prop 'dotnetHome'")

    // derived files
    cscExe = dotnetHomeDir + `csc.exe`
  }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  **
  ** Run the csc task
  **
  override Void run()
  {
    log.info("CompileCs")

    try
    {
      // build command
      cmd := [cscExe.osPath]

      // default paramaters
      cmd.add("/nologo")
      cmd.add("/fullpaths")
      cmd.add("/debug:full")

      // /out:output
      if (output != null)
      {
        cmd.add("/out:$output.osPath")
      }

      // /target:targetType
      if (targetType != null)
      {
        cmd.add("/target:$targetType")
      }

      // /r:<libs>
      if (libs != null && !libs.isEmpty)
      {
        s := libs.join(";") |File f->Str| { return f.osPath }
        cmd.add("/r:$s")
      }

      // src files/dirs
      src.each |File f|
      {
        if (f.isDir)
          cmd.add((f + `x`).osPath[0..-2] + "*.cs")
        else
          cmd.add(f.osPath)
      }

      log.debug(cmd.join(" "))
      r := Process(cmd).run.join
      if (r != 0) throw Err.make
    }
    catch (Err err)
    {
      throw fatal("CompileCs failed")
    }
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  ** Home directory for .NET installation
  ** configured via config prop
  File? dotnetHomeDir

  ** C# compiler executable: {dotnetHomeDir}/csc.exe
  File cscExe

  ** Output file created by the compiler.
  File? output

  ** Output target type
  Str? targetType

  ** List of dll libraries to link in
  File[]? libs

  ** List of source files or directories to compile
  File[] src := File[,]

}
