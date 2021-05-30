//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   6 Jan 06  Brian Frank  Creation
//

**
** Param represents one parameter definition of a Func (or Method).
**
@NoNative native final rtconst class Param
{
  private const Str _name
  private const Str _typeName
  private Type? _type
  private const Int _mask

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Private constructor.
  **
  internal new make(Str name, Str typeName, Int mask) {
    _name = name
    _typeName = typeName
    _mask = mask
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Name of the parameter.
  **
  Str name() { _name }

  **
  ** Type of the parameter.
  **
  Type type() {
    if (_type == null) {
      _type = Type.find(_typeName)
    }
    return _type
  }

  **
  ** Return if this parameter has a default value.  If true,
  ** then callers are not required to specify an argument.
  **
  Bool hasDefault() { _mask.and(0x01) != 0 }

  **
  ** Return "$type $name"
  **
  override Str toStr() { "$type $name" }

  override Bool isImmutable() {
    true
  }

  override Obj toImmutable() {
    this
  }

}