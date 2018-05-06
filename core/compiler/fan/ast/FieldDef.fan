//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//   21 Jul 06  Brian Frank  Ported from Java to Fan
//

**
** FieldDef models a field definition
**
public class FieldDef : SlotDef, CField
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  new make(Loc loc, TypeDef parent, Str name := "?", Int flags := 0)
     : super(loc, parent)
  {
    this.name = name
    this.flags = flags
    this.fieldType = parent.ns.errType
  }

//////////////////////////////////////////////////////////////////////////
// Access
//////////////////////////////////////////////////////////////////////////

  Bool hasGet() { get != null && !get.isSynthetic }
  Bool hasSet() { set != null && !set.isSynthetic }

  FieldExpr makeAccessorExpr(Loc loc, Bool useAccessor)
  {
    Expr? target
    if (isStatic)
      target = StaticTargetExpr(loc, parent)
    else
      target = ThisExpr(loc)

    return FieldExpr(loc, target, this, useAccessor)
  }

//////////////////////////////////////////////////////////////////////////
// CField
//////////////////////////////////////////////////////////////////////////

  override Str signature() { qname }
  override CMethod? getter() { get }
  override CMethod? setter() { set }

  override CType inheritedReturnType()
  {
    if (inheritedRet != null)
      return inheritedRet
    else
      return fieldType
  }

//////////////////////////////////////////////////////////////////////////
// Tree
//////////////////////////////////////////////////////////////////////////

  override Void walk(Visitor v, VisitDepth depth)
  {
    v.enterFieldDef(this)
    walkFacets(v, depth)
    if (depth >= VisitDepth.expr && init != null && walkInit)
      init = init.walk(v)
    v.visitFieldDef(this)
    v.exitFieldDef(this)
  }

//////////////////////////////////////////////////////////////////////////
// Debug
//////////////////////////////////////////////////////////////////////////

  override Void print(AstWriter out)
  {
    printFacets(out)
    out.flags(flags)
    out.w(fieldType).w(" ")
    out.w(name)
    if (init != null) { out.w(" := "); init.print(out) }
    out.nl.nl
   }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  override CType fieldType  // field type
  Field? field              // resolved finalized field
  Expr? init                // init expression or null
  Bool walkInit := true     // tree walk init expression
  MethodDef? get            // getter MethodDef
  MethodDef? set            // setter MethodDef
  CField? concreteBase      // if I override a concrete virtual field
  CType? inheritedRet       // if covariant override of method
  Bool requiresNullCheck    // flags that ctor needs runtime check to ensure it-block set it
  EnumDef? enumDef          // if an enum name/ordinal pair
  Str? closureInfo          // if this is a closure wrapper field

}