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
class TypeRef : CType
{
  override Loc loc
  
  new make(Loc loc, Str? pod, Str name)
    : super(pod ?: "", name)
  {
    this.loc = loc
  }
  
  static TypeRef? objType(Loc loc) { TypeRef(loc, "sys", "Obj") }
  static TypeRef? voidType(Loc loc) { TypeRef(loc, "sys", "Void") }
  static TypeRef? errType(Loc loc) { TypeRef(loc, "sys", "Err") }
  static TypeRef? error(Loc loc) { TypeRef(loc, "sys", "Error") }
  static TypeRef? nothingType(Loc loc) { TypeRef(loc, "sys", "Nothing") }
  static TypeRef? boolType(Loc loc) { TypeRef(loc, "sys", "Bool") }
  static TypeRef? enumType(Loc loc) { TypeRef(loc, "sys", "Enum") }
  static TypeRef? facetType(Loc loc) { TypeRef(loc, "sys", "Facet") }
  static TypeRef? intType(Loc loc) { TypeRef(loc, "sys", "Int") }
  static TypeRef? strType(Loc loc) { TypeRef(loc, "sys", "Str") }
  static TypeRef? thisType(Loc loc) { TypeRef(loc, "sys", "This") }
  static TypeRef? listType(Loc loc, CType elemType) {
    t := TypeRef(loc, "sys", "List")
    t.genericArgs = [elemType]
    return t
  }
  static TypeRef? funcType(Loc loc, CType[] params, CType ret) {
    t := TypeRef(loc, "sys", "Func")
    t.genericArgs = [ret].addAll(params)
    return t
  }
  static TypeRef? asyncType(Loc loc) { TypeRef(loc, "concurrent", "Async") }
//  static TypeRef? promiseType(Loc loc) { TypeRef(loc, "concurrent", "Promise") }
  static TypeRef? mapType(Loc loc, CType k, CType v) {
    t := TypeRef(loc, "std", "Map")
    t.genericArgs = [k, v]
    return t
  }
  
    **
  ** Get this type as a nullable type (marked with trailing ?)
  **
  override CType toNullable() {
    if (isNullable) return this
    d := TypeRef(loc, podName, name)
    d.resolvedType = resolvedType
    d._isNullable = true
    d.genericArgs = genericArgs
    return d
  }

  **
  ** Get this type as a non-nullable (if nullable)
  **
  override CType toNonNullable() {
    if (!isNullable) return this
    d := TypeRef(loc, podName, name)
    d.resolvedType = resolvedType
    d._isNullable = false
    d.genericArgs = genericArgs
    return d
  }
}