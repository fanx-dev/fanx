//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Jun 06  Brian Frank  Creation
//

**
** CPod is a "compiler pod" used for representing a Pod in the compiler.
**
mixin CPod
{

  **
  ** Associated namespace for this pod representation
  **
  abstract CNamespace ns()

  **
  ** Get the pod name
  **
  abstract Str name()

  **
  ** Get the pod version or null if unknown.
  **
  abstract Version version()

  **
  ** Get the pod dependencies
  **
  abstract CDepend[] depends()

  **
  ** List of the all defined types.
  **
  abstract CType[] types()

  **
  ** Pod zip file.  Not all implementations have a backing
  ** file in which case they will throw UnsupportedErr
  **
  abstract File file()

  **
  ** Lookup a type by its simple name.  If the type doesn't
  ** exist and checked is true then throw UnknownTypeErr
  ** otherwise return null.
  **
  abstract CType? resolveType(Str name, Bool checked)

  **
  ** If this a foreign function interface pod.
  **
  virtual Bool isForeign() { false }

  **
  ** If this a foreign function interface return the bridge.
  **
  virtual CBridge? bridge() { null }

  ** support Javascript
  virtual Bool compileJs() { false }

  **
  ** Hash on name.
  **
  override Int hash()
  {
    return name.hash
  }

  **
  ** Equality based on pod name.
  **
  override Bool equals(Obj? t)
  {
    if (this === t) return true
    that := t as CPod
    if (that == null) return false
    return name == that.name
  }

  **
  ** Return name
  **
  override final Str toStr()
  {
    return name
  }

}