//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   17 Nov 08  Brian Frank  Creation
//

using compiler

**
** JavaPod is the CPod wrapper for a Java package.
**
class JavaPod : CPod
{

  new make(JavaBridge bridge, ClassPathPackage package)
  {
    this.bridge      = bridge
    this.name        = "[java]" + package
    this.packageName = package.name
    this.isInterop   = (package.name == "fanx.interop")

    this.types = [,]
    package.classes.each |file, name|
    {
      this.types.add(JavaType.makeDasm(this, name, file))
    }
  }

  new makePrimitives(JavaBridge bridge)
  {
    this.bridge      = bridge
    this.name        = "[java]"
    this.packageName = ""
    this.types       = CType[,]
  }

  override CNamespace ns() { return bridge.ns }

  override const Str name

  override File file() { throw UnsupportedErr() }

  const Str packageName

  override const Version version := Version.defVal

  override const CDepend[] depends := [,]

  override JavaBridge? bridge

  override Bool isForeign() { return true }

  override CType[] types

  override CType? resolveType(Str typeName, Bool checked)
  {
    if (typeName[0] == '[') {
      JavaType? jt := resolveType(typeName[1..-1], checked)
      return jt?.toArrayOf
    }
    if (packageName == "java.lang" && typeName == "Void") {
      return ns.voidType
    }

    x := types.find |JavaType t->Bool| { return t.name == typeName }
    if (x != null) return x
    if (checked) throw UnknownTypeErr(name + "::" + typeName)
    return null
  }

  ** Is this the fanx.interop package?
  const Bool isInterop

}