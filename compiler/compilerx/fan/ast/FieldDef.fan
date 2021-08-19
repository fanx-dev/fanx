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
    this.fieldType = CType.error(loc)
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
      target = StaticTargetExpr(loc, parent.asRef())
    else
      target = ThisExpr(loc)

    return FieldExpr(loc, target, this.name, useAccessor)
  }
  
  override Int enumOrdinal() {
    enumDef := parentDef.enumDef(name)
    if (enumDef != null) return enumDef.ordinal
    return -1
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
  
  override Void getChildren(CNode[] list, [Str:Obj]? options) {
    if (facets != null) {
      facets.each |FacetDef f| {
        list.add(f)
      }
    }
    
    if (init != null) {
      list.add(init)
    }
    
    if (get != null && !get.isSynthetic) {
      list.add(get)
    }
    if (set != null && !set.isSynthetic) {
      list.add(set)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Debug
//////////////////////////////////////////////////////////////////////////

  override Void print(AstWriter out)
  {
    super.print(out)
    
    if (isConst) out.w("const ")
    else if (isReadonly) out.w("let ")
    else out.w("var ")
    
    out.w(name).w(" : ")
    out.w(fieldType)
    
    if (init != null) { out.w(" := "); init.print(out) }
    out.nl.nl
   }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  override CType fieldType  // field type
//  Field? field              // resolved finalized field
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