//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   13 May 10  Andy Frank  Creation
//

using compiler

**
** JsCompilerSupport provides support for JavaScript compiler pipeline.
**
class JsCompilerSupport : CompilerSupport
{
  **
  ** Constructor.
  **
  new make(CompilerSupport s) : super(s.compiler)
  {
    this.suppressErr = s.suppressErr
    this.podClosures = JsPodClosures(this)
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
