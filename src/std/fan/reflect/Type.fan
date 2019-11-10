//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Jan 06  Brian Frank  Creation
//

internal mixin TypeConst
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
  const static Int Struct     := 0x00080000
  const static Int Extension  := 0x00100000
  const static Int RuntimeConst:=0x00200000
  const static Int Readonly   := 0x00400000
  const static Int Async      := 0x00800000
  const static Int Overload   := 0x01000000 //imples param default by Overload
  const static Int FlagsMask  := 0x0fffffff
}

**
** Type defines the contract of an Obj by the slots its supports.
** Types model the inheritance relationships and provide a mapping
** for all the slots both inherited and declared.
**
abstract native const class Type
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Private constructor.
  **
  protected new privateMake() {
  }

//////////////////////////////////////////////////////////////////////////
// Management
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the 'Type' instance which represents this object's class.
  ** Also see`Type.of` or `Pod.of`.
  **
  native static extension Type typeof(Obj obj)

  **
  ** Get the class Type of the given instance.  Also
  ** see `Obj.typeof` which provides the same functionality.
  **
  static Type of(Obj obj) { typeof(obj) }

  **
  ** Find a Type by it's qualified name "pod::Type".  If the type
  ** doesn't exist and checked is false then return null, otherwise
  ** throw UnknownTypeErr.
  **
  static Type? find(Str qname, Bool checked := true) {
    i := qname.find("::")
    podName := qname[0..<i]
    name := qname[i+2..-1]
    pod := Pod.find(podName, checked)
    return pod.type(name, checked)
  }

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
  abstract Pod? pod()

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
  abstract Str name()

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
  abstract Str qname()

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
  abstract Str signature()

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
  abstract Type? base()

  **
  ** Return the mixins directly implemented by this type.
  **
  ** Examples:
  **   Obj#.mixins        =>  [,]
  **   Buf#.mixins        =>  [sys::InStream, sys::OutStream]
  **   OutStream#.mixins  =>  [,]
  **
  abstract Type[] mixins()

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
  abstract Type[] inheritance()

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
  virtual Bool fits(Type t) {
    return inheritance.contains(t)
  }

//////////////////////////////////////////////////////////////////////////
// Value Types
//////////////////////////////////////////////////////////////////////////

  protected abstract Int flags()

  **
  ** Is this a value type.  Fantom supports three implicit value
  ** types: `Bool`, `Int`, and `Float`.
  **
  virtual Bool isVal() { flags.and(TypeConst.Struct) != 0 }

//////////////////////////////////////////////////////////////////////////
// Nullable
//////////////////////////////////////////////////////////////////////////

  **
  ** Is this a nullable type.  Nullable types can store the 'null'
  ** value, but non-nullables are never null.  Null types are indicated
  ** with a trailing "?".
  **
  virtual Bool isNullable() { false }

  **
  ** Return this type as a nullable type.  If this type is already
  ** nullable then return this.
  **
  abstract Type toNullable()

  **
  ** Return this type as a non-nullable type.  If this type is already
  ** non-nullable then return this.
  **
  virtual  Type toNonNullable() { this }

//////////////////////////////////////////////////////////////////////////
// Generics
//////////////////////////////////////////////////////////////////////////

  **
  ** A generic type contains slot signatures which may be parameterized - for
  ** example Map's key and value types are generic as K and V.  Fantom supports
  ** three built-in generic types: List, Map, and Func.   A parameterized
  ** type such as Str[] is not a generic type (all of its generic parameters
  ** have been filled in).
  **
  ** Examples:
  **   Str#.isGeneric   => false
  **   List#.isGeneric  => true
  **   Str[]#.isGeneric => false
  **
  virtual Bool isGeneric() { false }

  **
  ** A parameterized type is a type which has parameterized a generic type
  ** and replaced all the generic parameter types with generic argument
  ** types.  The type Str[] is a parameterized type of the generic type
  ** List (V is replaced with Str).  A parameterized type always has a
  ** signature which is different from the qname.
  **
  virtual Bool isParameterized() { false }

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
  //Type toListOf()

  **
  ** Return an immutable empty list of this type.  Since immutable
  ** lists can be used safely everywhere, this allows signficant memory
  ** savings instead allocating new empty lists.
  **
  ** Examples:
  **   Str#.emptyList  =>  Str[,]
  **
  virtual Obj[] emptyList() { List.defVal }

//////////////////////////////////////////////////////////////////////////
// Flags
//////////////////////////////////////////////////////////////////////////

  **
  ** Return if this Type is abstract and cannot be instantiated.  This
  ** method will always return true if the type is a mixin.
  **
  Bool isAbstract() { flags.and(TypeConst.Abstract) != 0 }

  **
  ** Return if this Type is a class (as opposed to enum or mixin)
  **
  Bool isClass() { flags.and(TypeConst.Mixin) == 0 }

  **
  ** Return if this is a const class which means instances of this
  ** class are immutable.
  **
  Bool isConst() { flags.and(TypeConst.Const) != 0 }

  **
  ** Return if this Type is an Enum type.
  **
  Bool isEnum() { flags.and(TypeConst.Enum) != 0 }

  **
  ** Return if this Type is an Facet type.
  **
  Bool isFacet() { flags.and(TypeConst.Facet) != 0 }

  **
  ** Return if this Type is marked final which means it may not be subclassed.
  **
  Bool isFinal() { flags.and(TypeConst.Final) != 0 }

  **
  ** Return if this Type has internal protection scope.
  **
  Bool isInternal() { flags.and(TypeConst.Internal) != 0 }

  **
  ** Return if this Type is a mixin type and cannot be instantiated.
  **
  Bool isMixin() { flags.and(TypeConst.Mixin) != 0 }

  **
  ** Return if this Type has public protection scope.
  **
  Bool isPublic() { flags.and(TypeConst.Public) != 0 }

  **
  ** Return if this Type was generated by the compiler.
  **
  Bool isSynthetic() { flags.and(TypeConst.Synthetic) != 0 }

//////////////////////////////////////////////////////////////////////////
// Slots
//////////////////////////////////////////////////////////////////////////

  **
  ** List of the all defined fields (including inherited fields).
  **
  abstract Field[] fields()

  **
  ** List of the all defined methods (including inherited methods).
  **
  abstract Method[] methods()

  **
  ** List of the all defined slots, both fields and methods (including
  ** inherited slots).
  **
  abstract Slot[] slots()

  **
  ** Convenience for (Field)slot(name, checked)
  **
  Field? field(Str name, Bool checked := true) {
    (Field)slot(name, checked)
  }

  **
  ** Convenience for (Method)slot(name, checked)
  **
  Method? method(Str name, Bool checked := true) {
    (Method)slot(name, checked)
  }

  **
  ** Lookup a slot by name.  If the slot doesn't exist and checked
  ** is false then return null, otherwise throw UnknownSlotErr.
  ** Slots are any field or method in this type's scope including
  ** those defined directly by this type and those inherited from
  ** super class or mixins.
  **
  abstract Slot? slot(Str name, Bool checked := true)

  **
  ** Create a new instance of this Type using the following rules:
  **   1. Call public constructor 'make' with specified arguments
  **   2. If no public constructor called 'make' or invalid number of
  **      of required arguments, then return value of 'defVal' slot (must
  **      be static field or static method with zero params)
  **   3. If no public 'defVal' field, then throw Err
  **
  virtual Obj make(Obj[]? args := null) {
    m := method("make", false)
    if (m != null && m.isPublic) {
      numArgs := args == null ? 0 : args.size
      params := m.params
      if ((numArgs == params.size) ||
          (numArgs < params.size && params.get(numArgs).hasDefault)) {
        return m.callList(args)
      }
    }
    //fallback to defVal
    if (args == null || args.size == 0) {
      f := slot("defVal", false)
      if (f != null && f.isStatic) {
        if (f is Field) return ((Field)f).get
        return ((Method)f).call
      }
    }

    throw Err.make("Type missing 'make' or 'defVal' slots: " + this + ", method:" + m);
  }

//////////////////////////////////////////////////////////////////////////
// Facets
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the list of facets defined on this type or return an empty
  ** list if no facets are defined. If looking up a facet by type, then
  ** use the `facet` method which will provide better performance.
  ** See [Facets Doc]`docLang::Facets` for details.
  **
  abstract Facet[] facets()

  **
  ** Get a facet by its type.  If not found on this type then
  ** return null or throw UnknownFacetErr based on check flag.
  ** See [Facets Doc]`docLang::Facets` for details.
  **
  abstract Facet? facet(Type type, Bool checked := true)

  **
  ** Return if this type has the specified facet defined.
  **
  Bool hasFacet(Type type) {
    facet(type, false) != null
  }

//////////////////////////////////////////////////////////////////////////
// Documentation
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the raw fandoc for this type or null if not available.
  **
  virtual Str? doc() { null }

//////////////////////////////////////////////////////////////////////////
// Conversion
//////////////////////////////////////////////////////////////////////////

  **
  ** Always return signature().
  **
  override Str toStr() { signature }

  **
  ** Return `signature`.  This method is used to enable 'toLocale' to
  ** be used with duck typing across most built-in types.  Note: we may
  ** change the specification of this method in the future to allow
  ** localized type names.
  **
  //Str toLocale()

  /**
   * Return if this is a JavaType which represents a Java
   * class imported into the Fantom type system via the Java FFI.
   */
  @NoDoc
  virtual Bool isJava() { false }

  /*
  override Bool isImmutable() {
    true
  }

  override Obj toImmutable() {
    this
  }
  */
}

internal const class BaseType : Type
{
  private const Pod _pod
  private const Str _typeName
  private const Str _qname
  private const Str _signature
  private const Type? _base
  private const Type[] _mixins
  private const Int _flags

  private const Type[] _inheritance
  private const Type nullable

  private const Field[] _fields
  private const Method[] _methods
  private const Slot[] _slots
  private const [Str:Slot] slotMap

  private const Facet[] _facets
  private const [Type:Facet] facetMap

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Private constructor.
  **
  protected new privateMake(Pod pod, Str name, Str signature, Int flags, Type? base, Type[] mixins,
    Slot[] slots, Facet[] facets)
    : super.privateMake() {
    _pod = pod
    _typeName = name
    _qname = pod.name+"::"+name
    _signature = signature
    _flags = flags
    _base = base
    _mixins = mixins

    //make inheritance
    [Type:Obj?] inher := [:]
    inher[this] = null
    if (base != null) {
      base.inheritance.each |v| {
        inher[v] = null
      }
    }
    mixins.each |v| {
      inher[v] = null
    }
    _inheritance = inher.keys
    
    //make slots
    fields := Field[,]
    methods := Method[,]
    slotMapTmp := [Str:Slot][:]
    slots.each |s| {
      if (s is Field) fields.add((Field)s)
      else methods.add((Method)s)
      slotMapTmp[s.name] = s
    }
    _slots = slots
    _fields = fields
    _methods = methods
    slotMap = slotMapTmp

    //make facet
    facetMapTmp := [Type:Facet][:]
    facets.each {
      facetMapTmp[it.typeof] = it
    }
    _facets = facets
    facetMap = facetMapTmp

    nullable = NullableType.privateMake(this)
  }

  protected override Int flags() { _flags }

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
  override Pod? pod() { null }

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
  override Str name() { _typeName }

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
  override Str qname() { _qname }

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
  override Str signature() { _signature }

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
  override Type? base() { _base }

  **
  ** Return the mixins directly implemented by this type.
  **
  ** Examples:
  **   Obj#.mixins        =>  [,]
  **   Buf#.mixins        =>  [sys::InStream, sys::OutStream]
  **   OutStream#.mixins  =>  [,]
  **
  override Type[] mixins() { _mixins }

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
  override Type[] inheritance() { _inheritance }

//////////////////////////////////////////////////////////////////////////
// Nullable
//////////////////////////////////////////////////////////////////////////

  **
  ** Return this type as a nullable type.  If this type is already
  ** nullable then return this.
  **
  override Type toNullable() { nullable }

//////////////////////////////////////////////////////////////////////////
// Slots
//////////////////////////////////////////////////////////////////////////

  **
  ** List of the all defined fields (including inherited fields).
  **
  override Field[] fields() { _fields }

  **
  ** List of the all defined methods (including inherited methods).
  **
  override Method[] methods() { _methods }

  **
  ** List of the all defined slots, both fields and methods (including
  ** inherited slots).
  **
  override Slot[] slots() { _slots }

  **
  ** Lookup a slot by name.  If the slot doesn't exist and checked
  ** is false then return null, otherwise throw UnknownSlotErr.
  ** Slots are any field or method in this type's scope including
  ** those defined directly by this type and those inherited from
  ** super class or mixins.
  **
  override Slot? slot(Str name, Bool checked := true) {
    slotMap.getChecked(name, checked)
  }

//////////////////////////////////////////////////////////////////////////
// Facets
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the list of facets defined on this type or return an empty
  ** list if no facets are defined. If looking up a facet by type, then
  ** use the `facet` method which will provide better performance.
  ** See [Facets Doc]`docLang::Facets` for details.
  **
  override Facet[] facets() { _facets }

  **
  ** Get a facet by its type.  If not found on this type then
  ** return null or throw UnknownFacetErr based on check flag.
  ** See [Facets Doc]`docLang::Facets` for details.
  **
  override Facet? facet(Type type, Bool checked := true) {
    facetMap.getChecked(type, checked)
  }

//////////////////////////////////////////////////////////////////////////
// Documentation
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the raw fandoc for this type or null if not available.
  **
  //Str? doc()
}

internal const class ProxyType : Type {
  const Type root

  new privateMake(Type root) : 
    super.privateMake() {
    this.root = root
  }

  override Pod? pod() { root.pod }
  override Str name() { root.name }
  override Str qname() { root.qname }
  override Str signature() { root.signature }
  override Type? base() { root.base }
  override Type[] mixins() { root.mixins }
  override Type[] inheritance() { root.inheritance }
  protected override Int flags() { root.flags }
  override Type toNullable() { root.toNullable }

  override Field[] fields() { root.fields }
  override Method[] methods() { root.methods }
  override Slot[] slots() { root.slots }
  override Slot? slot(Str name, Bool checked := true) { root.slot(name, checked) }
  override Facet[] facets() { root.facets }
  override Facet? facet(Type type, Bool checked := true) { root.facet(type, checked) }
}

internal const class NullableType : ProxyType {

  new privateMake(Type root) : super.privateMake(root) {}

  override Str signature() { root.signature + "?" }

  **
  ** Is this a value type.  Fantom supports three implicit value
  ** types: `Bool`, `Int`, and `Float`.
  **
  override Bool isVal() { return false }

//////////////////////////////////////////////////////////////////////////
// Nullable
//////////////////////////////////////////////////////////////////////////

  **
  ** Is this a nullable type.  Nullable types can store the 'null'
  ** value, but non-nullables are never null.  Null types are indicated
  ** with a trailing "?".
  **
  override Bool isNullable() { true }

  **
  ** Return this type as a nullable type.  If this type is already
  ** nullable then return this.
  **
  override Type toNullable() { this }

  **
  ** Return this type as a non-nullable type.  If this type is already
  ** non-nullable then return this.
  **
  override Type toNonNullable() { root }
}

internal const class ParameterizedType : ProxyType {
  private const Str _signature
  private const Type nullable

  new privateMake(Type root, Str signature) : super.privateMake(root) {
    this._signature = signature
    nullable = NullableType(this)
  }

  override Str signature() { this._signature }

  override Bool isParameterized() { true }

  override Type toNullable() { nullable }
}

