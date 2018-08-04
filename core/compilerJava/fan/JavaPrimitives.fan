//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   17 Nov 08  Brian Frank  Creation
//

using compiler

**
** JavaPrimitives is the pod namespace used to represent primitives:
**   [java]::byte
**   [java]::short
**   [java]::char
**   [java]::int
**   [java]::float
**
class JavaPrimitives : JavaPod
{

  new make(JavaBridge bridge)
    : super.makePrimitives(bridge)
  {
    ns := bridge.ns
    this.booleanType = makeType("boolean", ns.boolType)
    this.byteType    = makeType("byte" ,   ns.intType)
    this.shortType   = makeType("short",   ns.intType)
    this.charType    = makeType("char",    ns.intType)
    this.intType     = makeType("int",     ns.intType)
    this.longType    = makeType("long",    ns.intType)
    this.floatType   = makeType("float",   ns.floatType)
    this.doubleType  = makeType("double",  ns.floatType)
  }

  private JavaType makeType(Str name, CType fanType)
  {
    t := JavaType.makePrimitive(this, name, fanType.toNullable)
    types.add(t)
    return t
  }

  JavaType byteType
  JavaType shortType
  JavaType charType
  JavaType intType
  JavaType floatType
  JavaType booleanType  // just used for multi-dim arrays
  JavaType longType     // just used for multi-dim arrays
  JavaType doubleType   // just used for multi-dim arrays

}