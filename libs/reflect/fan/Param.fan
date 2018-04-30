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
native final const class Param
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Private constructor.
  **
  private new make()

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Name of the parameter.
  **
  Str name()

  **
  ** Type of the parameter.
  **
  Type type()

  **
  ** Return if this parameter has a default value.  If true,
  ** then callers are not required to specify an argument.
  **
  Bool hasDefault()

  **
  ** Return "$type $name"
  **
  override Str toStr()

}