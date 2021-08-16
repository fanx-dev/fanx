//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//    2 Jun 06  Brian Frank  Ported from Java to Fan
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
  **
  ** Output directory to write pod to, defaults to the
  ** current environment's working lib directory
  **
  File outDir := Env.cur.workDir + `lib/fan/`
 
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
  File[]? srcFiles
  
  **
  ** List of resource files or directories containing resource files
  ** to include in the pod zip.  Uris are relative to `baseDir`.
  ** This field is used only in file mode.  If a file has a "jar"
  ** extension then its contents are unzipped into the target pod.
  **
  File[]? resFiles
  
  **
  ** List of JavaScript files or directories containing JavaScript files
  ** to include in the JavaScript output.  Uris are relative to `baseDir`.
  ** This field is used only in file mode.
  **
  File[]? jsFiles
  
  
  **
  ** Fantom source code to compile (str mode only)
  **
  Str? srcStr
  
  **
  ** Location to use for SourceFile facet (str mode only)
  **
  Str? srcStrLoc
  
  **
  ** compile to javascript
  **
  Bool compileJs := false
  
  **
  ** only compile to javascript file
  **
  Bool onlyJs := false

  **
  ** If set to true, then generate apidocs for test subclasses
  **
  Bool docTests := false
  
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
  ** Flag to indicate if we are are compiling a script.  Scripts
  ** don't require explicit depends and can import any type via the
  ** using statement or with qualified type names.
  **
  Bool isScript := false
  
  **
  ** Namespace used to resolve dependency pods/types.
  **
  CNamespace? ns := null
  
  
  **
  ** empty pod for hold pod config info
  ** 
  PodDef? podDef
}
