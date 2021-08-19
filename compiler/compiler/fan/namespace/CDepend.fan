//
// Copyright (c) 2011, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   14 Dec 11  Brian Frank  Creation
//

**
** CDepend is a compiler dependency which wraps `sys::Depend`
**
class CDepend
{
  static CDepend fromStr(Str s) { make(Depend.fromStr(s), null) }

  new make(Depend d, CPod? p) { this.depend = d; this.pod = p }

  static CDepend[] makeList(Depend[] d) { d.map |x->CDepend| { make(x, null) } }

  ** Depend specification
  const Depend depend

  ** Pod name of the dependency
  Str name() { depend.name }

  ** Resolved pod for the dependency or null if unresolved
  CPod? pod

  ** Return depend.toStr
  override Str toStr() { depend.toStr }

}