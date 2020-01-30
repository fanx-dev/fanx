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
class TypeRef : Node
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  new make(Loc loc, Str? pod, Str name)
    : super(loc)
  {
    this.podName = pod
    this.type = name
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
    s := StrBuf()
    if (podName != null) {
      s.add(podName).add("::")
    }
    
    s.add(type)
    
    if (extName != null) {
      s.add(extName)
    }
    if (genericArgs != null) {
      s.add("<").add(genericArgs.join(",")).add(">")
    }
    if (isNullable) {
      s.add("?")
    }
    return s.toStr
  }
  
  This toNullable() {
    isNullable = true
    return this
  }
  
//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  Str type
  Str? podName
  TypeRef[]? genericArgs
  Str? extName
  Bool isFuncType
  Bool isNullable := false
}