

internal mixin FConst
{
  const static Int Abstract   := 0x00000001
  const static Int Const      := 0x00000002
  const static Int Ctor       := 0x00000004
  const static Int Enum       := 0x00000008
  const static Int Facet      := 0x00000010
  const static Int Final      := 0x00000020
  const static Int Getter     := 0x00000040
  const static Int Internal   := 0x00000080
  const static Int Mixin      := 0x00000100
  const static Int Native     := 0x00000200
  const static Int Override   := 0x00000400
  const static Int Private    := 0x00000800
  const static Int Protected  := 0x00001000
  const static Int Public     := 0x00002000
  const static Int Setter     := 0x00004000
  const static Int Static     := 0x00008000
  const static Int Storage    := 0x00010000
  const static Int Synthetic  := 0x00020000
  const static Int Virtual    := 0x00040000
  const static Int FlagsMask  := 0x0007ffff
}

native mixin TypeExt {

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