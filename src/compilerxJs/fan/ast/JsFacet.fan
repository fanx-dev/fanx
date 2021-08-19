//
// Copyright (c) 2011, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   27 May 2011  Andy Frank  Creation
//

using compilerx

**
** JsFacet
**
class JsFacet : JsNode
{
  new make(JsCompilerSupport s, FacetDef f) : super(s)
  {
    this.type = JsTypeRef(s, f.type, f.loc)
    this.val  = f.serialize
  }

  override Void write(JsWriter out)
  {
    out.w(val)
  }

  JsTypeRef type  // facet type
  Str val         // serialized facet value
}
