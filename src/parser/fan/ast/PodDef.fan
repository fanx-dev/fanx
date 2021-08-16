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

  override Version version = Version("1.0")

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
    if (typesCache != null) return typesCache
    typesCache = typeDefs.vals
    return typesCache
  }
  
  **
  ** Add a synthetic type
  **
  Void addTypeDef(TypeDef t)
  {
    t.unit.addTypeDef(t)
    this.typeDefs.add(t.name, t)
    typesCache = null
  }
  
  Void updateCompilationUnit(CompilationUnit? unit, CompilationUnit? old, CompilerLog log) {
    if (old != null) {
      old.types.each |t| {
        this.typeDefs.remove(t.name)
        this.closures.removeAll(t.closures)
      }
    }
    typesCache = null
    if (unit == null) return
    unit.types.each |t| {
      if (this.typeDefs.containsKey(t.name)) {
        log.err("Duplicate type name '$t.name'", unit.loc)
      }
      this.typeDefs[t.name] = t
      this.closures.addAll(t.closures)
    }
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
    //units.each |CompilationUnit unit| { unit.print(out) }
    out.nl
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

//  override CNamespace? ns            // compiler's namespace
  override const Str name           // simple pod name
  Str:Str meta := Str:Str[:]        // pod meta-data props
  Str:Obj index := Str:Obj[:]       // pod index props (vals are Str or Str[])
  //[Str:CompilationUnit] units := [:]           // Tokenize
  [Str:TypeDef] typeDefs           // ScanForUsingsAndTypes
  ClosureExpr[]? closures := [,]           // Parse
//  TypeDef[]? orderedTypeDefs
  private TypeDef[]? typesCache
}