//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Jan 06  Brian Frank  Creation
//

**
** Type defines the contract of an Obj by the slots its supports.
** Types model the inheritance relationships and provide a mapping
** for all the slots both inherited and declared.
**
native const class TypeExt
{
  private new privateMake()

//////////////////////////////////////////////////////////////////////////
// Naming
//////////////////////////////////////////////////////////////////////////

  **
  ** Parent pod which defines this type.  For parameterized types derived
  ** from List, Map, or Func, this method always returns the sys pod.
  **
  ** Examples:
  **   Str#.pod         => sys
  **   acme::Foo#.pod   => acme
  **   acme::Foo[]#.pod => sys
  **
  static extension Pod? pod(Type self)

//////////////////////////////////////////////////////////////////////////
// Slots
//////////////////////////////////////////////////////////////////////////

  **
  ** List of the all defined fields (including inherited fields).
  **
  static extension Field[] fields(Type self)

  **
  ** List of the all defined methods (including inherited methods).
  **
  static extension Method[] methods(Type self)

  **
  ** List of the all defined slots, both fields and methods (including
  ** inherited slots).
  **
  static extension Slot[] slots(Type self)

  **
  ** Convenience for (Field)slot(name, checked)
  **
  static extension Field? field(Type self, Str name, Bool checked := true)

  **
  ** Convenience for (Method)slot(name, checked)
  **
  static extension Method? method(Type self, Str name, Bool checked := true)

  **
  ** Lookup a slot by name.  If the slot doesn't exist and checked
  ** is false then return null, otherwise throw UnknownSlotErr.
  ** Slots are any field or method in this type's scope including
  ** those defined directly by this type and those inherited from
  ** super class or mixins.
  **
  static extension Slot? slot(Type self, Str name, Bool checked := true)

  **
  ** Create a new instance of this Type using the following rules:
  **   1. Call public constructor 'make' with specified arguments
  **   2. If no public constructor called 'make' or invalid number of
  **      of required arguments, then return value of 'defVal' slot (must
  **      be static field or static method with zero params)
  **   3. If no public 'defVal' field, then throw Err
  **
  static extension Obj make(Type self, Obj[]? args := null)

//////////////////////////////////////////////////////////////////////////
// Facets
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the list of facets defined on this type or return an empty
  ** list if no facets are defined. If looking up a facet by type, then
  ** use the `facet` method which will provide better performance.
  ** See [Facets Doc]`docLang::Facets` for details.
  **
  static extension Facet[] facets(Type self)

  **
  ** Get a facet by its type.  If not found on this type then
  ** return null or throw UnknownFacetErr based on check flag.
  ** See [Facets Doc]`docLang::Facets` for details.
  **
  static extension Facet? facet(Type self, Type type, Bool checked := true)

  **
  ** Return if this type has the specified facet defined.
  **
  static extension Bool hasFacet(Type self, Type type)

//////////////////////////////////////////////////////////////////////////
// Documentation
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the raw fandoc for this type or null if not available.
  **
  static extension Str? doc(Type self)

}