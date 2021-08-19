//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   10 Nov 05  Brian Frank  Creation
//    3 Jun 06  Brian Frank  Ported from Java to Fantom - Megan's b-day!
//

**
** DefNode is the abstract base class for definition nodes such as TypeDef,
** MethodDef, and FieldDef.  All definitions may be documented using a
** Javadoc style FanDoc comment.
**
abstract class DefNode : Node
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

  abstract CNamespace ns()

  Void walkFacets(Visitor v, VisitDepth depth)
  {
    if (facets != null && depth >= VisitDepth.expr)
    {
      facets.each |FacetDef f| { f.walk(v) }
    }
  }

  CFacet? facet(Str qname)
  {
    if (facets == null) return null
    return facets.find |f| { f.type.qname == qname }
  }

  Void addFacet(CompilerSupport support, CType type, [Str:Obj]? vals := null)
  {
    if (facets == null) facets = FacetDef[,]
    loc := this.loc
    f := FacetDef(loc, type)
    vals?.each |v, n|
    {
      f.names.add(n)
      f.vals.add(Expr.makeForLiteral(loc, ns, v))
    }
    facets.add(f)
  }

  Void printFacets(AstWriter out)
  {
    if (facets == null) return
    facets.each |FacetDef f| { f.print(out) }
  }

  **
  ** Return if this type or slot should be documented:
  **   - public or protected
  **   - not synthentic
  **   - not a subclass of sys::Test
  **
  ** If a public type/slot is annotated with @NoDoc we
  ** we still generate the docs to make it available for
  ** reflection
  **
  internal Bool isDocumented()
  {
    if (flags.and(FConst.Synthetic) != 0) return false
    if (flags.and(FConst.Public) == 0 && flags.and(FConst.Protected) == 0) return false
    if (this is TypeDef)
    {
      // check compiler input to override default behavior
      if (ns.c != null && ns.c.input.docTests) return true

      // don't document test concrete subclasses
      t := (TypeDef)this
      
      if (t.podName == "sys") return true
      
      if (t.base != null && t.base.fits(ns.testType))
        return t.isAbstract
    }
    else if (this is MethodDef)
    {
      m := (MethodDef)this
      if (m.isFieldAccessor) return false
    }
    return true
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  DocDef? doc         // lines of fandoc comment or null
  Int flags := 0      // type/slot flags
  FacetDef[]? facets  // facet declarations or null

}

**************************************************************************
** DocDef
**************************************************************************

**
** Type or slot documentation in plain text fandoc format
**
class DocDef : Node
{
  new make(Loc loc, Str[] lines)
    : super(loc)
  {
    this.lines = lines
  }

  override Void print(AstWriter out)
  {
    lines.each |line| { out.w("** ").w(line).nl }
  }

  Str[] lines
}