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
@Serializable { simple = true }
native const class Type
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Private constructor.
  **
  private new privateMake()

//////////////////////////////////////////////////////////////////////////
// Management
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the class Type of the given instance.  Also
  ** see `Obj.typeof` which provides the same functionality.
  **
  static Type of(Obj obj)

  **
  ** Find a Type by it's qualified name "pod::Type".  If the type
  ** doesn't exist and checked is false then return null, otherwise
  ** throw UnknownTypeErr.
  **
  static Type? find(Str qname, Bool checked := true)

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
  //Pod? pod()

  **
  ** Simple name of the type such as "Str".  For parameterized types derived
  ** from List, Map, or Func, this method always returns "List", "Map",
  ** or "Func" respectively.
  **
  ** Examples:
  **   Str#.name         => "Str"
  **   acme::Foo#.name   => "Foo"
  **   acme::Foo[]#.name => "List"
  **
  Str name()

  **
  ** Qualified name formatted as "pod::name".  For parameterized
  ** types derived from List, Map, or Func, this method always returns
  ** "sys::List", "sys::Map", or "sys::Func" respectively.  If this
  ** a nullable type, the qname does *not* include the "?".
  **
  ** Examples:
  **   Str#.qname         => "sys::Str"
  **   Str?#.qname        => "sys::Str"
  **   acme::Foo#.qname   => "acme::Foo"
  **   acme::Foo[]#.qname => "sys::List"
  **
  Str qname()

  **
  ** Return the formal signature of this type.  In the case of
  ** non-parameterized types the signature is the same as qname.
  ** For parameterized types derived from List, Map, or Func the
  ** signature uses the following special syntax:
  **   List => V[]
  **   Map  => [K:V]
  **   Func => |A,B...->R|
  **
  ** If this is a nullable type, the signature ends with "?" such
  ** as "sys::Int?".
  **
  ** Examples:
  **   Str#.signature => "sys::Str"
  **   Str?#.signature => "sys::Str?"
  **   Int[]#.signature => "sys::Int[]"
  **   Int:Str#.signature => "[sys::Int:sys::Str]"
  **   Str:Buf[]#.signature => [sys::Str:sys::Buf[]]
  **   |Float x->Bool|#.signature => "|sys::Float->sys::Bool|"
  **   |Float x, Int y|#.signature => |sys::Float,sys::Int->sys::Void|
  **
  Str signature()

//////////////////////////////////////////////////////////////////////////
// Inheritance
//////////////////////////////////////////////////////////////////////////

  **
  ** The direct super class of this type (null for Obj).
  ** Return sys::Obj for all mixin types.
  **
  ** Examples:
  **   Obj#.base        =>  null
  **   Int#.base        =>  sys::Num
  **   OutStream#.base  =>  sys::Obj
  **
  Type? base()

  **
  ** Return the mixins directly implemented by this type.
  **
  ** Examples:
  **   Obj#.mixins        =>  [,]
  **   Buf#.mixins        =>  [sys::InStream, sys::OutStream]
  **   OutStream#.mixins  =>  [,]
  **
  Type[] mixins()

  **
  ** Return a recursive flattened list of all the types this type
  ** inherits from.  The result list always includes this type itself.
  ** The result of this method represents the complete list of types
  ** implemented by this type - instances of this type are assignable
  ** to any type in this list.  All types (including mixins) will
  ** include sys::Obj in this list.
  **
  ** Examples:
  **   Obj#.inheritance  =>  [sys::Obj]
  **   Int#.inheritance  =>  [sys::Int, sys::Num, sys::Obj]
  **
  Type[] inheritance()

  **
  ** Does this type implement the specified type.  If true, then
  ** this type is assignable to the specified type (although the
  ** converse is not necessarily true).  This method provides the
  ** same semantics as the 'is' operator, but between two types
  ** rather than an instance and a type.  All types (including
  ** mixin types) fit 'sys::Obj'.
  **
  ** Example:
  **   Float#.fits(Float#) =>  true
  **   Float#.fits(Num#)   =>  true
  **   Float#.fits(Obj#)   =>  true
  **   Float#.fits(Str#)   =>  false
  **   Obj#.fits(Float#)   =>  false
  **
  Bool fits(Type t)

//////////////////////////////////////////////////////////////////////////
// Value Types
//////////////////////////////////////////////////////////////////////////

  **
  ** Is this a value type.  Fantom supports three implicit value
  ** types: `Bool`, `Int`, and `Float`.
  **
  Bool isVal()

//////////////////////////////////////////////////////////////////////////
// Nullable
//////////////////////////////////////////////////////////////////////////

  **
  ** Is this a nullable type.  Nullable types can store the 'null'
  ** value, but non-nullables are never null.  Null types are indicated
  ** with a trailing "?".
  **
  Bool isNullable()

  **
  ** Return this type as a nullable type.  If this type is already
  ** nullable then return this.
  **
  Type toNullable()

  **
  ** Return this type as a non-nullable type.  If this type is already
  ** non-nullable then return this.
  **
  Type toNonNullable()

//////////////////////////////////////////////////////////////////////////
// Generics
//////////////////////////////////////////////////////////////////////////

  **
  ** A generic type contains slot signatures which may be parameterized - for
  ** example Map's key and value types are generic as K and V.  Fantom supports
  ** three built-in generic types: List, Map, and Func.   A parameterized
  ** type such as Str[] is not a generic type (all of its generic parameters
  ** have been filled in).  User defined generic types are not supported in Fantom.
  **
  ** Examples:
  **   Str#.isGeneric   => false
  **   List#.isGeneric  => true
  **   Str[]#.isGeneric => false
  **
  Bool isGeneric()

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
  //Str:Type params()

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
  //Type parameterize(Str:Type params)

  **
  ** Convenience for List#.parameterize(["V":this])
  **
  ** Examples:
  **   Int#.toListOf => Int[]
  **   Str[]#.toListOf => Str[][]
  **
  Type toListOf()

  **
  ** Return an immutable empty list of this type.  Since immutable
  ** lists can be used safely everywhere, this allows signficant memory
  ** savings instead allocating new empty lists.
  **
  ** Examples:
  **   Str#.emptyList  =>  Str[,]
  **
  Obj[] emptyList()

//////////////////////////////////////////////////////////////////////////
// Flags
//////////////////////////////////////////////////////////////////////////

  **
  ** Return if this Type is abstract and cannot be instantiated.  This
  ** method will always return true if the type is a mixin.
  **
  Bool isAbstract()

  **
  ** Return if this Type is a class (as opposed to enum or mixin)
  **
  Bool isClass()

  **
  ** Return if this is a const class which means instances of this
  ** class are immutable.
  **
  Bool isConst()

  **
  ** Return if this Type is an Enum type.
  **
  Bool isEnum()

  **
  ** Return if this Type is an Facet type.
  **
  Bool isFacet()

  **
  ** Return if this Type is marked final which means it may not be subclassed.
  **
  Bool isFinal()

  **
  ** Return if this Type has internal protection scope.
  **
  Bool isInternal()

  **
  ** Return if this Type is a mixin type and cannot be instantiated.
  **
  Bool isMixin()

  **
  ** Return if this Type has public protection scope.
  **
  Bool isPublic()

  **
  ** Return if this Type was generated by the compiler.
  **
  Bool isSynthetic()

//////////////////////////////////////////////////////////////////////////
// Slots
//////////////////////////////////////////////////////////////////////////
  /*
  **
  ** List of the all defined fields (including inherited fields).
  **
  Field[] fields()

  **
  ** List of the all defined methods (including inherited methods).
  **
  Method[] methods()

  **
  ** List of the all defined slots, both fields and methods (including
  ** inherited slots).
  **
  Slot[] slots()

  **
  ** Convenience for (Field)slot(name, checked)
  **
  Field? field(Str name, Bool checked := true)

  **
  ** Convenience for (Method)slot(name, checked)
  **
  Method? method(Str name, Bool checked := true)

  **
  ** Lookup a slot by name.  If the slot doesn't exist and checked
  ** is false then return null, otherwise throw UnknownSlotErr.
  ** Slots are any field or method in this type's scope including
  ** those defined directly by this type and those inherited from
  ** super class or mixins.
  **
  Slot? slot(Str name, Bool checked := true)

  */

  **
  ** Create a new instance of this Type using the following rules:
  **   1. Call public constructor 'make' with specified arguments
  **   2. If no public constructor called 'make' or invalid number of
  **      of required arguments, then return value of 'defVal' slot (must
  **      be static field or static method with zero params)
  **   3. If no public 'defVal' field, then throw Err
  **
  Obj make(Obj[]? args := null)

//////////////////////////////////////////////////////////////////////////
// Facets
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the list of facets defined on this type or return an empty
  ** list if no facets are defined. If looking up a facet by type, then
  ** use the `facet` method which will provide better performance.
  ** See [Facets Doc]`docLang::Facets` for details.
  **
  Facet[] facets()

  **
  ** Get a facet by its type.  If not found on this type then
  ** return null or throw UnknownFacetErr based on check flag.
  ** See [Facets Doc]`docLang::Facets` for details.
  **
  Facet? facet(Type type, Bool checked := true)

  **
  ** Return if this type has the specified facet defined.
  **
  Bool hasFacet(Type type)

//////////////////////////////////////////////////////////////////////////
// Documentation
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the raw fandoc for this type or null if not available.
  **
  Str? doc()

//////////////////////////////////////////////////////////////////////////
// Conversion
//////////////////////////////////////////////////////////////////////////

  **
  ** Always return signature().
  **
  override Str toStr()

  **
  ** Return `signature`.  This method is used to enable 'toLocale' to
  ** be used with duck typing across most built-in types.  Note: we may
  ** change the specification of this method in the future to allow
  ** localized type names.
  **
  Str toLocale()

}