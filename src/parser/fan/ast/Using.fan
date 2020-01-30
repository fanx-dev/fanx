//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//    3 Jun 06  Brian Frank  Ported from Java to Fantom - Megan's b-day!
//   11 Oct 06  Brian Frank  Switch from import keyword to using
//

**
** Using models an using import statement.
**
class Using : Node
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  new make(Loc loc)
    : super(loc)
  {
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  ** Does this using import the entire pod
  Bool isPod() { typeName == null }

  override Void print(AstWriter out)
  {
    out.w(toStr).nl
  }

  override Str toStr()
  {
    s := "using $podName"
    if (typeName != null) s += "::$typeName"
    if (asName != null) s += " as $asName"
    return s
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  Str podName := "?"   // pod name (including [ffi] if specified)
  Str? typeName        // type name or null
  Str? asName          // rename if using as
//  CPod? resolvedPod    // ResolveImports
//  CType? resolvedType  // ResolveImports

}