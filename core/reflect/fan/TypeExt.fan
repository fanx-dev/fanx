

native class TypeExt {

  **
  ** Parent pod which defines this type.  For parameterized types derived
  ** from List, Map, or Func, this method always returns the sys pod.
  **
  ** Examples:
  **   Str#.pod         => sys
  **   acme::Foo#.pod   => acme
  **   acme::Foo[]#.pod => sys
  **
  static extension Pod? pod(Type type)

  **
  ** If this is a parameterized type, then return the map of names to
  ** types.  If this is not a parameterized type return an empty map.
  **
  ** Examples:
  **   Str#.params => [:]
  **   Str[]#.params => ["V":Str, "L":Str[]]
  **   Int:Slot#.params => ["K":Int, "V":Slot, "M":Int:Slot]
  **   |Int x, Float y->Bool|#.params => ["A":Int, "B":Float, "R":Bool]
  **
  //static extension Str:Type params(Type type)

  **
  ** If this is a generic type, then dynamically create a new parameterized
  ** type with the specified name to type map.  If this type is not generic
  ** then throw UnsupportedErr.  Throw ArgErr if params fails to specify
  ** the required parameters:
  **    List => V required
  **    Map  => K, V required
  **    Func => R required, A-H optional
  **
  ** Examples:
  **   List#.parameterize(["V":Bool#]) => Bool[]
  **   Map#.parameterize(["K":Str#, "V":Obj#]) => Str:Obj
  **
  //static extension Type parameterize(Type type, Str:Type params)

  **
  ** List of the all defined fields (including inherited fields).
  **
  static extension Field[] fields(Type type)

  **
  ** List of the all defined methods (including inherited methods).
  **
  static extension Method[] methods(Type type)

  **
  ** List of the all defined slots, both fields and methods (including
  ** inherited slots).
  **
  static extension Slot[] slots(Type type)

  **
  ** Convenience for (Field)slot(name, checked)
  **
  static extension Field? field(Type type, Str name, Bool checked := true)

  **
  ** Convenience for (Method)slot(name, checked)
  **
  static extension Method? method(Type type, Str name, Bool checked := true)

  **
  ** Lookup a slot by name.  If the slot doesn't exist and checked
  ** is false then return null, otherwise throw UnknownSlotErr.
  ** Slots are any field or method in this type's scope including
  ** those defined directly by this type and those inherited from
  ** super class or mixins.
  **
  static extension Slot? slot(Type type, Str name, Bool checked := true)
}