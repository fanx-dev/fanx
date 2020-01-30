//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Jul 06  Brian Frank  Creation
//

**
** SlotDef models a slot definition - a FieldDef or MethodDef
**
abstract class SlotDef : DefNode
{
  Bool isAbstract()  { flags.and(FConst.Abstract)  != 0 }
  Bool isAccessor()  { flags.and(FConst.Getter.or(FConst.Setter)) != 0 }
  Bool isConst()     { flags.and(FConst.Const)     != 0 }
  Bool isReadonly()  { flags.and(FConst.Readonly)  != 0 }
  Bool isCtor()      { flags.and(FConst.Ctor)      != 0 }
  Bool isEnum()      { flags.and(FConst.Enum)      != 0 }
  Bool isGetter()    { flags.and(FConst.Getter)    != 0 }
  Bool isInternal()  { flags.and(FConst.Internal)  != 0 }
  Bool isNative()    { flags.and(FConst.Native)    != 0 }
  Bool isOverride()  { flags.and(FConst.Override)  != 0 }
  Bool isPrivate()   { flags.and(FConst.Private)   != 0 }
  Bool isProtected() { flags.and(FConst.Protected) != 0 }
  Bool isPublic()    { flags.and(FConst.Public)    != 0 }
  Bool isSetter()    { flags.and(FConst.Setter)    != 0 }
  Bool isStatic()    { flags.and(FConst.Static)    != 0 }
  Bool isStorage()   { flags.and(FConst.Storage)   != 0 }
  Bool isSynthetic() { flags.and(FConst.Synthetic) != 0 }
  Bool isVirtual()   { flags.and(FConst.Virtual)   != 0 }

  Bool isInstanceCtor() { isCtor && !isStatic }
  Bool isStaticCtor() { isCtor && isStatic }
  
//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  new make(Loc loc, TypeDef parentDef)
    : super(loc)
  {
    this.parentDef = parentDef
  }

//////////////////////////////////////////////////////////////////////////
// DefNode
//////////////////////////////////////////////////////////////////////////

//  override CNamespace ns() { parent.ns }

//////////////////////////////////////////////////////////////////////////
// CSlot
//////////////////////////////////////////////////////////////////////////

  TypeDef parent() { parentDef }
  Str qname() { "${parent.qname}.${name}" }

//////////////////////////////////////////////////////////////////////////
// Tree
//////////////////////////////////////////////////////////////////////////

  abstract Void walk(Visitor v, VisitDepth depth)

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  TypeDef parentDef             // parent TypeDef
  Str name := "?"      // slot name
  Bool overridden := false      // set by Inherit when successfully overridden

}