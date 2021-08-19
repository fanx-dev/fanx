//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   7 Oct 08  Brian Frank  Creation
//

**
** NullableType wraps another CType as nullable with trailing "?".
**
class NullableType : ProxyType
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  new make(CType root) : super(root)
  {
    if (root.isNullable && (root.deref isnot GenericParameter)) throw Err("Cannot wrap $root as NullableType")
    this.extName = root.extName + "?"
  }

//////////////////////////////////////////////////////////////////////////
// CType
//////////////////////////////////////////////////////////////////////////

  override Str extName

  override Bool isNullable() { true }
  override CType toNullable() { this }
  override CType toNonNullable() { root }

  override CType parameterizeThis(CType thisType) {
    x := root.parameterizeThis(thisType)
    if (x === root) return this
    return x.toNullable
  }
  override CType inferredAs()
  {
    x := root.inferredAs
    if (x === root) return this
    return x.toNullable
  }
  override CType raw() {
    x := root.raw
    if (x === root) return this
    return x.toNullable
  }
  override CType deref() {
    x := root.deref
    if (x === root) return this
    return x.toNullable
  }

  override once CType toListOf() { ListType(this) }
}