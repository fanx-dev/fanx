//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   5 Jun 06  Brian Frank  Creation
//

**
** PodDef models the pod being compiled.
**
class PodDef : Node
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  new make(Loc loc, Str name)
    : super(loc)
  {
    this.name = name
    this.units = CompilationUnit[,]
  }

//////////////////////////////////////////////////////////////////////////
// CPod
//////////////////////////////////////////////////////////////////////////

  Version version() { throw UnsupportedErr("PodDef.version") }

  Depend[] depends := [,]

  File file() { throw UnsupportedErr() }

//  override CType? resolveType(Str name, Bool checked)
//  {
//    t := typeDefs[name]
//    if (t != null) return t
//    if (checked) throw UnknownTypeErr("${this.name}::${name}")
//    return null
//  }

  TypeDef[] types()
  {
    return typeDefs.vals
  }

//////////////////////////////////////////////////////////////////////////
// Tree
//////////////////////////////////////////////////////////////////////////

  override Void print(AstWriter out)
  {
    out.nl
    out.w("======================================").nl
    out.w("pod $name").nl
    out.w("======================================").nl
    units.each |CompilationUnit unit| { unit.print(out) }
    out.nl
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

//  override CNamespace? ns            // compiler's namespace
  const Str name           // simple pod name
  Str:Str meta := Str:Str[:]        // pod meta-data props
  Str:Obj index := Str:Obj[:]       // pod index props (vals are Str or Str[])
  CompilationUnit[] units           // Tokenize
  [Str:TypeDef]? typeDefs           // ScanForUsingsAndTypes

}