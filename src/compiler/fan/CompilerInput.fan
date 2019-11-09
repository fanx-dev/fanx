//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Nov 06  Brian Frank  Creation
//

**
** CompilerInput encapsulates all the input needed run the compiler.
** The compiler can be run in one of two modes - file or str.  In
** file mode the source code and resource files are read from the
** file system.  In str mode we compile a single source file from
** an in-memory string.
**
class CompilerInput
{

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  **
  ** Location to use for reporting errors associated with the input
  ** itself - typically this is mapped to the build script.
  **
  Loc inputLoc := Loc("CompilerInput")

  **
  ** Name of output pod - required in all modes.
  **
  Str? podName

  **
  ** Flag to indicate if we are are compiling a script.  Scripts
  ** don't require explicit depends and can import any type via the
  ** using statement or with qualified type names.
  **
  Bool isScript := false

  **
  ** Version to include in ouput pod's manifest.
  **
  Version? version

  **
  ** Summary description for pod
  **
  Str? summary

  **
  ** List of this pod's dependencies used for both the
  ** compiler checking and output in the pod's manifest.
  **
  Depend[] depends := Depend[,]

  **
  ** Namespace used to resolve dependency pods/types.
  ** Default implementation uses reflection of the compiler's VM.
  **
  CNamespace ns := FPodNamespace(null)

  **
  ** Pod meta-data name/value pairs
  **
  Str:Str meta := Str:Str[:]

  **
  ** Pod indexing name/value pairs.  The index values can be
  ** a single Str or a Str[] if there are multiple values
  ** mapped to one key.
  **
  Str:Obj index := Str:Obj[:]

  **
  ** What type of output should be generated - the compiler
  ** can be used to generate a transient in-memory pod, write a
  ** pod zip file to disk, or generate JavaScript code.
  **
  CompilerOutputMode? output := null

  **
  ** Log used for reporting compile status
  **
  CompilerLog log := CompilerLog.make

  **
  ** Output directory to write pod to, defaults to the
  ** current environment's working lib directory
  **
  File outDir := Env.cur.workDir + `lib/fan/`

  **
  ** Include fandoc in output pod, default is false
  **
  Bool includeDoc := false

  **
  ** Include source code in output pod, default is false
  **
  Bool includeSrc := false

  **
  ** Is this compile process being run inside a test, default is false
  **
  Bool isTest := false

  **
  ** If set to true, then disassembled fcode is dumped to 'log.out'.
  **
  Bool fcodeDump := false

  **
  ** This mode determines whether the source code is input
  ** from the file system or from an in-memory string.
  **
  CompilerInputMode? mode := null

  **
  ** If set to true, then generate apidocs for test subclasses
  **
  Bool docTests := false

//////////////////////////////////////////////////////////////////////////
// CompilerInputMode.file
//////////////////////////////////////////////////////////////////////////

  **
  ** Base directory of source tree - this directory is used to create
  ** the relative paths of the source and resource files in the pod zip.
  **
  File? baseDir

  **
  ** List of Fantom source files or directories containing Fantom
  ** source files to compile.  Uris are relative to `baseDir`.  This
  ** field is used only in file mode.
  **
  Uri[]? srcFiles

  **
  ** List of resource files or directories containing resource files
  ** to include in the pod zip.  Uris are relative to `baseDir`.
  ** This field is used only in file mode.  If a file has a "jar"
  ** extension then its contents are unzipped into the target pod.
  **
  Uri[]? resFiles

  **
  ** List of JavaScript files or directories containing JavaScript files
  ** to include in the JavaScript output.  Uris are relative to `baseDir`.
  ** This field is used only in file mode.
  **
  Uri[]? jsFiles

  Bool compileJs := false

//////////////////////////////////////////////////////////////////////////
// CompilerInputMode.str
//////////////////////////////////////////////////////////////////////////

  **
  ** Fantom source code to compile (str mode only)
  **
  Str? srcStr

  **
  ** Location to use for SourceFile facet (str mode only)
  **
  Loc? srcStrLoc

//////////////////////////////////////////////////////////////////////////
// Validation
//////////////////////////////////////////////////////////////////////////

  **
  ** Validate the CompilerInput is correctly
  ** configured, throw CompilerErr is not.
  **
  internal Void validate()
  {
    validateReqField("podName")
    validateReqField("version")
    validateReqField("summary")
    validateReqField("output")
    validateReqField("outDir")
    validateReqField("mode")
    switch (mode)
    {
      case CompilerInputMode.file:
        validateReqField("baseDir")
      case CompilerInputMode.str:
        validateReqField("srcStr")
        validateReqField("srcStrLoc")
    }
  }

  **
  ** Check that the specified field is non-null, if not
  ** then log an error and return false.
  **
  private Void validateReqField(Str field)
  {
    val := this.typeof.field(field).get(this)
    if (val == null)
      throw ArgErr("CompilerInput.${field} not set", null)
  }
}

**************************************************************************
** CompilerInputMode
**************************************************************************

**
** Input source from the file system
**
enum class CompilerInputMode
{
  file,
  str
}