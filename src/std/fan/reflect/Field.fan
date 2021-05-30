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
@NoNative native rtconst class Field : Slot
{
  private const Str _typeName
  private Type? _type
  private const Int _id

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
  @NoDoc
  static |Obj| makeSetFunc([Field:Obj?] vals) {
    return |Obj obj| {
      vals.each |v, k| {
        k._unsafeSet(obj, v, false)
      }
    }
  }

  **
  ** Private constructor.
  **
  internal new privateMake(Type parent, Str name, Str? doc, Int flags, Str typeName, Int id)
    : super.make(parent, name, doc, flags) {
    _typeName = typeName
    _id = id
  }

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  **
  ** Type stored by the field.
  **
  Type type() {
    if (_type == null) {
      _type = Type.find(_typeName)
    }
    return _type
  }

  override Str signature() {
    "$type $name"
  }

//////////////////////////////////////////////////////////////////////////
// Reflection
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the field for the specified instance.  If the field is
  ** static, then the instance parameter is ignored.  If the getter
  ** is non-null, then it is used to get the field.
  **
  native virtual Obj? get(Obj? instance := null)

  **
  ** Set the field for the specified instance.  If the field is
  ** static, then the instance parameter is ignored.  If the setter
  ** is non-null, then it is used to set the field.
  **
  virtual Void set(Obj? instance, Obj? value) {
    _unsafeSet(instance, value, true)
  }

  @NoDoc
  native virtual Void _unsafeSet(Obj? instance, Obj? value, Bool checkConst)

}