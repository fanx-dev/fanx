//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   13 May 10  Andy Frank  Creation
//

using compilerx

**
** JsCompilerSupport provides support for JavaScript compiler pipeline.
**
class JsCompilerSupport
{
  CompilerContext compiler
  
  **
  ** Constructor.
  **
  new make(CompilerContext s)
  {
    this.compiler = s
    //this.suppressErr = s.suppressErr
    this.podClosures = JsPodClosures(this)
  }
  
  **
  ** Create, log, and return a CompilerErr.
  **
  CompilerErr err(Str msg, Loc? loc := null)
  {
    compiler.log.err(msg, loc)
  }

  **
  ** Create, log, and return a warning CompilerErr.
  **
  CompilerErr warn(Str msg, Loc? loc := null)
  {
    compiler.log.warn(msg, loc)
  }

  **
  ** The name of the 'this' var.
  **
  Str thisName := "this"

  **
  ** Return a unique identifier name.
  **
  Str unique()
  {
    s := "\$_u$id"
    id++
    return s
  }
  private Int id := 0


  Str:JsTypeRef typeRef := Str:JsTypeRef[:]  // typeRef map

  JsPodClosures podClosures // JsPod
}
