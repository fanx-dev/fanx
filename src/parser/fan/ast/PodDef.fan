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
class PodDef : Node, CPod
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  new make(Loc loc, Str name)
    : super(loc)
  {
    this.name = name
    this.typeDefs = [:]
  }

//////////////////////////////////////////////////////////////////////////
// CPod
//////////////////////////////////////////////////////////////////////////

  override Version version() { throw UnsupportedErr("PodDef.version") }

  override Depend[] depends := [,]
  
  **
  ** Map of dependencies keyed by pod name set in ResolveDepends.
  **
  [Str:CPod]? resolvedDepends

  override File? file() { null }

  override CTypeDef? resolveType(Str name, Bool checked)
  {
    t := typeDefs[name]
    if (t != null) return t
    if (checked) throw UnknownTypeErr("${this.name}::${name}")
    return null
  }

  override CTypeDef[] types()
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
  override const Str name           // simple pod name
  Str:Str meta := Str:Str[:]        // pod meta-data props
  Str:Obj index := Str:Obj[:]       // pod index props (vals are Str or Str[])
  [Str:CompilationUnit] units := [:]           // Tokenize
  [Str:TypeDef] typeDefs           // ScanForUsingsAndTypes
  ClosureExpr[]? closures           // Parse
//  TypeDef[]? orderedTypeDefs
}