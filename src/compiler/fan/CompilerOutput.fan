//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Nov 06  Brian Frank  Creation
//

**
** CompilerOutput encapsulates the result of a compile.  The compiler
** can output in three modes:
**   - 'transientPod': compiles to an in-memory pod
**   - 'podFile': compile a pod file to the file system, but don't
**     automatically load it.
**   - 'js': runs through frontend of compiler to build AST and
**     generates JavaScript code (doesn't perform any backend
**     fcode or pod generation)
**
class CompilerOutput
{
  **
  ** Mode indicates the type of this output
  **
  CompilerOutputMode? mode

  **
  ** If `CompilerOutputMode.transientPod` mode, this is loaded pod.
  **
  Pod? transientPod

  **
  ** If `CompilerOutputMode.podFile` mode, the pod zip file written to disk.
  **
  File? podFile

  **
  ** If `CompilerOutputMode.js` mode, the JavaScript code string.
  **
  Str? js
}

**************************************************************************
** CompilerOutputMode
**************************************************************************

**
** Input source from the file system - see `CompilerOutput`
**
enum class CompilerOutputMode
{
  transientPod,
  podFile,
  js
}

