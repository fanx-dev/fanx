//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   10 Jul 09  Andy Frank  Creation
//

using compiler

**
** JsSlot
**
abstract class JsSlot : JsNode
{
  new make(JsCompilerSupport s, SlotDef def) : super(s, def)
  {
    this.parent      = qnameToJs(def.parentDef)
    this.origName    = def.name
    this.name        = vnameToJs(def.name)
    this.flags       = def.flags
    this.facets      = def.facets?.map |f| { JsFacet(s, f) } ?: [,]
    this.isAbstract  = def.isAbstract
    this.isStatic    = def.isStatic
    this.isNative    = def.isNative
    this.isSynthetic = def.isSynthetic
    this.isPrivate   = def.isPrivate
    this.isInternal  = def.isInternal
    //checkName
  }

  private Void checkName()
  {
    if (isPrivate && !isSynthetic && !isStatic)
    {
      s := parent.split('.')
      this.name = "_${s[1]}_${s[2]}_${name}_"
    }
  }

  Str parent        // qname of slot parent
  Str origName      // unescaped slot name
  Str name          // slot name
  Int flags         // slot flags
  JsFacet[] facets  // slot facets
  Bool isAbstract   // is slot abstract
  Bool isSynthetic  // is slot syntethi
  Bool isStatic     // is slot static
  Bool isNative     // is slot native
  Bool isPrivate    // is slot private
  Bool isInternal   // is slot internal
}

**************************************************************************
** JsSlotRef
**************************************************************************

**
** JsSlotRef
**
class JsSlotRef : JsNode
{
  new make(JsCompilerSupport cs, CSlot s) : super(cs)
  {
    this.cslot        = s
    this.loc         = s is Node ? ((Node)s).loc : null
    this.parent      = qnameToJs(s.parent)
    this.name        = vnameToJs(s.name)
    this.flags       = s.flags
    this.isAbstract  = s.isAbstract
    this.isSynthetic = s.isSynthetic
    this.isStatic    = s.isStatic
    this.isPrivate   = s.isPrivate
    this.isInternal  = s.isInternal
    //checkName
  }

  private Void checkName()
  {
    if (isPrivate && !isSynthetic && !isStatic)
    {
      s := parent.split('.')
      this.name = "_${s[1]}_${s[2]}_${name}_"
    }
  }

  override Void write(JsWriter out)
  {
    out.w(name, loc)
  }

  CSlot cslot
  Str parent        // qname of slot parent
  Str name          // qname of type ref
  Int flags         // slot flags
  Bool isAbstract   // is slot abstract
  Bool isSynthetic  // is slot syntethic
  Bool isStatic     // is slot static
  Bool isPrivate    // is slot private
  Bool isInternal   // is slot internal
}
