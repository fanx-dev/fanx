//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   5 Jul 06  Brian Frank  Creation
//

**
** TypeRef models a type reference such as an extends clause or a
** method parameter.  Really it is just an AST node wrapper for a
** CType that let's us keep track of the source code Loc.
**
class TypeRef : Node, CType
{
  CTypeImp imp
//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  new make(Loc loc, Str? pod, Str name)
    : super(loc)
  {
    podName := pod ?: ""
    imp = CTypeImp(podName, name)
  }

//////////////////////////////////////////////////////////////////////////
// Debug
//////////////////////////////////////////////////////////////////////////

  override Void print(AstWriter out)
  {
    out.w(toStr)
  }
  
  static TypeRef? objType(Loc loc) { TypeRef(loc, "sys", "Obj") }
  static TypeRef? voidType(Loc loc) { TypeRef(loc, "sys", "Void") }
  static TypeRef? errorType(Loc loc) { TypeRef(loc, "sys", "Error") }
  static TypeRef? nothingType(Loc loc) { TypeRef(loc, "sys", "Nothing") }
  static TypeRef? boolType(Loc loc) { TypeRef(loc, "sys", "Bool") }
  static TypeRef? enumType(Loc loc) { TypeRef(loc, "sys", "Enum") }
  static TypeRef? facetType(Loc loc) { TypeRef(loc, "sys", "Facet") }
  static TypeRef? intType(Loc loc) { TypeRef(loc, "sys", "Int") }
  static TypeRef? thisType(Loc loc) { TypeRef(loc, "sys", "This") }
  
  override Str toStr() {
    imp.toStr
  }
  
  override CType toNullable() {
    imp.toNullable
  }
  
  override CTypeDef typeDef() {
    imp.typeDef
  }
  
  override Void resolveTo(CTypeDef typeDef) {
    imp.resolveTo(typeDef)
  }
  
  override Str extName() { imp.extName }
  
//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  override Str name() { imp.name }
  override Str podName() { imp.name }
  
  override TypeRef[]? genericArgs { get {imp.genericArgs} set{imp.genericArgs = it} }
  override Bool isNullable() { imp.isNullable }
  
  override GenericParamDef? attachedGenericParam { get {imp.attachedGenericParam} set{imp.attachedGenericParam = it} }
}