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
native rtconst class Field : Slot
{
  private const Str _typeName
  private Type? _type
  private const Int _id

  internal Method? getter
  internal Method? setter

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

  override Obj? trap(Str name, Obj?[]? args := null) {
    // private undocumented access
    if (name == "getter")
      return getter
    if (name == "setter")
      return setter
    return super.trap(name, args)
  }

  **
  ** Get the field for the specified instance.  If the field is
  ** static, then the instance parameter is ignored.  If the getter
  ** is non-null, then it is used to get the field.
  **
  virtual Obj? get(Obj? instance := null) {
    if (getter != null) {
      return getter.call(instance)
    }
    return getDirectly(instance)
  }


  private native Obj? getDirectly(Obj? instance)
  private native Void setDirectly(Obj? instance, Obj? value)

  **
  ** Set the field for the specified instance.  If the field is
  ** static, then the instance parameter is ignored.  If the setter
  ** is non-null, then it is used to set the field.
  **
  virtual Void set(Obj? instance, Obj? value) {
    _unsafeSet(instance, value, true)
  }

  @NoDoc
  virtual Void _unsafeSet(Obj? instance, Obj? value, Bool checkConst) {
    if (flags.and(ConstFlags.Const) != 0) {
      if (checkConst)
        throw ReadonlyErr.make("Cannot set const field " + qname());
      else if (value != null && !value.isImmutable())
        throw ReadonlyErr.make("Cannot set const field " + qname() + " with mutable value");
    }

    // check static
    if (flags.and(ConstFlags.Static) != 0)
      throw ReadonlyErr.make("Cannot set static field " + qname());

    // use the setter by default, however if we have a storage field and
    // the setter was auto-generated then falldown to set the actual field
    // to avoid private setter implicit overrides
    if ((setter != null && !setter.isSynthetic())) {
      setter.call(instance, value);
      return;
    }

    setDirectly(instance, value)
  }

}