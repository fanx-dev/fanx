//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   6 Jan 06  Brian Frank  Creation
//

**
** Field is a slot which models the ability to get and set a value.
**
@Serializable { simple = true }
native const class Field : Slot
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Construct a function which sets zero or more fields on a target
  ** object.  The function can be passed to a constructor which
  ** takes an it-block to reflectively set const fields.  Example:
  **
  **   const class Foo
  **   {
  **     new make(|This|? f := null) { f?.call(this) }
  **     const Int x
  **   }
  **
  **   f := Field.makeSetFunc([Foo#x: 7])
  **   Foo foo := Foo#.make([f])
  **
  static |Obj| makeSetFunc(Field:Obj? vals)

  **
  ** Private constructor.
  **
  private static new privateMake()

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  **
  ** Type stored by the field.
  **
  Type type()

//////////////////////////////////////////////////////////////////////////
// Reflection
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the field for the specified instance.  If the field is
  ** static, then the instance parameter is ignored.  If the getter
  ** is non-null, then it is used to get the field.
  **
  virtual Obj? get(Obj? instance := null)

  **
  ** Set the field for the specified instance.  If the field is
  ** static, then the instance parameter is ignored.  If the setter
  ** is non-null, then it is used to set the field.
  **
  virtual Void set(Obj? instance, Obj? value)

  @NoDoc
  virtual Void _set(Obj? instance, Obj? value, Bool checkConst)

}