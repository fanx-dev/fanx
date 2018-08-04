//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Jun 06  Brian Frank  Creation
//

**
** CType is a "compiler type" which is class used for representing
** the Fantom type system in the compiler.  CTypes map to types within
** the compilation units themsevles as TypeDef and TypeRef or to
** precompiled types in imported pods via ReflectType or FType.
**
mixin CType
{

//////////////////////////////////////////////////////////////////////////
// Naming
//////////////////////////////////////////////////////////////////////////

  **
  ** Associated namespace for this type representation
  **
  abstract CNamespace ns()

  **
  ** Parent pod which defines this type.
  **
  abstract CPod pod()


  virtual Str podName() { pod.name }

  **
  ** Simple name of the type such as "Str".
  **
  abstract Str name()

  **
  ** Qualified name such as "sys:Str".
  **
  abstract Str qname()


  abstract Str extName()

  **
  ** This is the full signature of the type.
  **
  Str signature() { "$qname$extName" }

  **
  ** Return signature
  **
  override final Str toStr() { signature }

  **
  ** If this is a TypeRef, return what it references
  **
  virtual CType deref() { this }

//////////////////////////////////////////////////////////////////////////
// Nullable
//////////////////////////////////////////////////////////////////////////

  **
  ** Is this is a value type (Bool, Int, or Float and their nullables)
  **
  virtual Bool isVal() { flags.and(FConst.Struct) != 0 }

//////////////////////////////////////////////////////////////////////////
// Nullable
//////////////////////////////////////////////////////////////////////////

  **
  ** Is this is a nullable type (marked with trailing ?)
  **
  abstract Bool isNullable()

  **
  ** Get this type as a nullable type (marked with trailing ?)
  **
  abstract CType toNullable()

  **
  ** Get this type as a non-nullable (if nullable)
  **
  virtual CType toNonNullable() { this }

//////////////////////////////////////////////////////////////////////////
// FFI
//////////////////////////////////////////////////////////////////////////

  **
  ** If this a foreign function interface type.
  **
  virtual Bool isForeign() { false }

  **
  ** If this TypeDef extends from a FFI class or implements any
  ** FFI mixins, then return the FFI type otherwise return null.
  **
  CType? foreignInheritance()
  {
    if (base == null) return null
    if (base.isForeign) return base
    m := mixins.find |CType t->Bool| { t.isForeign }
    if (m != null) return m
    return base.foreignInheritance
  }

  **
  ** If this is a foreign function return the bridge.
  **
  CBridge? bridge() { pod.bridge }

  **
  ** If this type is being used for type inference then get the
  ** type as it should be inferred.  Typically we just return this.
  ** However some FFI types such as '[java]::int' are never used
  ** on the stack directly and are inferred to be 'sys::Int'.
  **
  virtual CType inferredAs() { this }

  **
  ** Return if type is supported by the Fantom type system.  For example
  ** the Java FFI will correctly model a Java multi-dimensional array
  ** during compilation, however there is no Fantom representation.  We
  ** check for supported types during CheckErrors when accessing
  ** fields and methods.
  **
  virtual Bool isSupported() { true }

//////////////////////////////////////////////////////////////////////////
// Generics
//////////////////////////////////////////////////////////////////////////

  **
  ** A generic type means that one or more of my slots contain signatures
  ** using a generic parameter (such as V or K).  Fantom supports three built-in
  ** generic types: List, Map, and Func.  A generic instance (such as Str[])
  ** is NOT a generic type (all of its generic parameters have been filled in).
  ** User defined generic types are not supported in Fan.
  **
  abstract Bool isGeneric()

  **
  ** A parameterized type is a type which has parameterized a generic type
  ** and replaced all the generic parameter types with generic argument
  ** types.  The type Str[] is a parameterized type of the generic type
  ** List (V is replaced with Str).  A parameterized type always has a
  ** signature which is different from the qname.
  **
  abstract Bool isParameterized()

  **
  ** Return if this type is a generic parameter (such as V or K) in a
  ** generic type (List, Map, or Method).  Generic parameters serve
  ** as place holders for the parameterization of the generic type.
  ** Fantom has a predefined set of generic parameters which are always
  ** defined in the sys pod with a one character name.
  **
  abstract Bool hasGenericParameter()

  **
  ** Create a parameterized List of this type.
  **
  abstract CType toListOf()

  **
  ** If this type is a generic parameter (V, L, etc), then return
  ** the actual type for the native implementation.  For example V
  ** is Obj, and L is List.  This is the type we actually use when
  ** constructing a signature for the invoke opcode.
  **
  virtual CType raw()
  {
    // if not generic parameter, always use this type
    //if (!isGenericParameter) return this

    // it's possible that this type is a generic unparameterized
    // instance of Method (such as List.each), in which case
    // we should use this type itself
    //if (name.size != 1) return this
    return this
  }

  **
  ** If this is a parameterized type which uses 'This',
  ** then replace 'This' with the specified type.
  **
  virtual CType parameterizeThis(CType thisType) { this }

  virtual GenericParamType? getGenericParamType(Str name) { null }

//////////////////////////////////////////////////////////////////////////
// Inheritance
//////////////////////////////////////////////////////////////////////////

  **
  ** The direct super class of this type (null for Obj).
  **
  abstract CType? base()

  **
  ** Return the mixins directly implemented by this type.
  **
  abstract CType[] mixins()

  **
  ** Hash on signature.
  **
  override Int hash()
  {
    return signature.hash
  }

  **
  ** Equality based on signature.
  **
  override Bool equals(Obj? t)
  {
    if (this === t) return true
    that := t as CType
    if (that == null) return false
    return signature == that.signature
  }

  **
  ** Does this type implement the specified type.  If true, then
  ** this type is assignable to the specified type (although the
  ** converse is not necessarily true).  All types (including
  ** mixin types) fit sys::Obj.
  **
  virtual Bool fits(CType ty)
  {
    //unparameterized generic parameters
    // don't take nullable in consideration
    t := ty.deref.raw.toNonNullable
    m := this.deref.raw.toNonNullable

    // everything fits Obj
    if (t.isObj) return true

    // short circuit if myself
    if (m.qname == t.qname) return true

    // recurse extends
    if (base != null && base.fits(t)) return true

    // recuse mixins
    for (i:=0; i<mixins.size; ++i)
      if (mixins[i].fits(t)) return true

    // let anything fit unparameterized generic parameters like
    // V, K (in case we are using List, Map, or Method directly)
    //if (t.name.size == 1 && t.pod.name == "sys")
    //  return true

    // no fit
    return false
  }

  **
  ** Return if this type fits any of the types in the specified list.
  **
  Bool fitsAny(CType[] types)
  {
    return types.any |CType t->Bool| { this.fits(t) }
  }

  **
  ** Given a list of types, compute the most specific type which they
  ** all share, or at worst return sys::Obj.  This method does not take
  ** into account mixins, only extends class inheritance.
  **
  public static CType common(CNamespace ns, CType[] types)
  {
    // special handling for nothing
    if (types.size == 2)
    {
      if (types[0].isNothing) return types[1]
      if (types[1].isNothing) return types[0]
    }

    // special handling for zero or one types
    if (types.size == 0) return ns.objType.toNullable
    if (types.size == 1) return types.first

    // first-pass iteration is used to:
    //   - check if any one of the types is nullable
    //   - check if any of the types is a parameterized generic
    //   - normalize our types to non-nullable
    mixins := false
    nullable := false
    parameterized := false
    types = types.dup
    types.each |t, i|
    {
      if (t.isParameterized) parameterized = true
      if (t.isNullable) nullable = true
      if (t.isMixin) mixins = true
      types[i] = t.toNonNullable
    }

    // if any one of the items is parameterized then we handle it
    // specially, otherwise we find the most common class
    CType? best
    if (parameterized)
      best = commonParameterized(ns, types)
    else if (mixins)
      best = commonMixin(ns, types)
    else
      best = commonClass(ns, types)

    // if any one of the items was nullable, then whole result is nullable
    return nullable ? best.toNullable : best
  }

  private static CType commonClass(CNamespace ns, CType[] types)
  {
    best := types[0]
    for (Int i:=1; i<types.size; ++i)
    {
      t := types[i]
      while (!t.fits(best))
      {
        bestBase := best.base
        if (bestBase == null) return ns.objType
        best = bestBase
      }
    }
    return best
  }

  private static CType commonMixin(CNamespace ns, CType[] types)
  {
    // mixins must all be same type or else we fallback to Obj
    first := types[0]
    allSame := types.all |t| { t == first }
    return allSame ? first : ns.objType
  }

  private static CType commonParameterized(CNamespace ns, CType[] types)
  {
    // we only support common inference on parameterized lists
    // since they are one dimensional in their parameterization,
    // all other inference is based strictly on exact type
    allList := true
    allMap  := true
    allFunc := true
    types.each |t|
    {
      allList = allList && t is ListType
      allMap  = allMap  && t is MapType
      allFunc = allFunc && t is FuncType
    }
    if (allList) return commonList(ns, types)
    if (allMap)  return commonExact(ns, types, ns.mapType)
    if (allFunc) return commonExact(ns, types, ns.funcType)
    return ns.objType
  }

  private static CType commonList(CNamespace ns, ListType[] types)
  {
    vTypes := types.map |t->CType| { t.v }
    return common(ns, vTypes).toListOf
  }

  private static CType commonExact(CNamespace ns, CType[] types, CType fallback)
  {
    // we only infer func types based strictly on exact type
    first := types[0]
    exact := types.all |t| { first == t }
    return exact ? first : fallback
  }

//////////////////////////////////////////////////////////////////////////
// Flags
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the flags bitmask.
  **
  abstract Int flags()

  **
  ** Return if this Type is a class (as opposed to enum or mixin)
  **
  Bool isClass() { !isMixin && !isEnum }

  **
  ** Return if this Type is a mixin type and cannot be instantiated.
  **
  Bool isMixin() { flags.and(FConst.Mixin) != 0 }

  **
  ** Return if this Type is an sys::Enum
  **
  Bool isEnum() { flags.and(FConst.Enum) != 0 }

  **
  ** Return if this Type is an sys::Facet
  **
  Bool isFacet() { flags.and(FConst.Facet) != 0 }

  **
  ** Return if this Type is abstract and cannot be instantiated.  This
  ** method will always return true if the type is a mixin.
  **
  Bool isAbstract() { flags.and(FConst.Abstract) != 0 }

  **
  ** Return if this Type is const and immutable.
  **
  Bool isConst() { flags.and(FConst.Const) != 0 }

  **
  ** Return if this Type is final and cannot be subclassed.
  **
  Bool isFinal() { flags.and(FConst.Final) != 0 }

  **
  ** Is this a public scoped class
  **
  Bool isPublic() { flags.and(FConst.Public) != 0 }

  **
  ** Is this an internally scoped class
  **
  Bool isInternal() { flags.and(FConst.Internal) != 0 }

  **
  ** Is this a compiler generated synthetic class
  **
  Bool isSynthetic() { flags.and(FConst.Synthetic) != 0 }

  **
  ** Is the entire class implemented in native code?
  **
  Bool isNative() { flags.and(FConst.Native) != 0 }

//////////////////////////////////////////////////////////////////////////
// Conveniences
//////////////////////////////////////////////////////////////////////////

  Bool isObj()     { qname == "sys::Obj" }
  Bool isBool()    { qname == "sys::Bool" }
  Bool isInt()     { qname == "sys::Int" }
  Bool isFloat()   { qname == "sys::Float" }
  Bool isDecimal() { qname == "sys::Decimal" }
  Bool isRange()   { qname == "sys::Range" }
  Bool isStr()     { qname == "sys::Str" }
  Bool isThis()    { qname == "sys::This" }
  Bool isType()    { qname == "sys::Type" }
  Bool isVoid()    { qname == "sys::Void" }
  Bool isBuf()     { qname == "sys::Buf" }
  Bool isList()    { fits(ns.listType) }
  Bool isMap()     { fits(ns.mapType) }
  Bool isFunc()    { fits(ns.funcType) }
  Bool isNothing() { this === ns.nothingType }

  ** Is this a valid type usable anywhere (such as local var)
  virtual Bool isValid() { !isVoid && !isThis }

  **
  ** Is this type ok to use as a const field?  Any const
  ** type fine, plus we allow Obj, List, Map, Buf, and Func since
  ** they will implicitly have toImmutable called on them.
  **
  Bool isConstFieldType()
  {
    if (isConst) return true

    // these are checked at runtime
    t := deref.toNonNullable
    //if (t.isObj || t.isList || t.isMap|| t.isBuf || t.isFunc)
    //  return true
    if (t.flags.and(FConst.RuntimeConst) != 0) return true

    // definitely no way it can be immutable
    return false
  }

//////////////////////////////////////////////////////////////////////////
// Slots
//////////////////////////////////////////////////////////////////////////

  **
  ** Map of the all defined slots, both fields and
  ** methods (including inherited slots).
  **
  abstract Str:CSlot slots()

  **
  ** Return if this type contains a slot by the specified name.
  **
  Bool hasSlot(Str name) { slots.containsKey(name) }

  **
  ** Lookup a slot by name.  If the slot doesn't exist then return null.
  **
  virtual CSlot? slot(Str name) { slots[name] }

  **
  ** Lookup a field by name (null if method).
  **
  virtual CField? field(Str name) { slot(name) as CField }

  **
  ** Lookup a method by name (null if field).
  **
  virtual CMethod? method(Str name) { slot(name) as CMethod }

  **
  ** List of the all defined fields (including inherited fields).
  **
  CField[] fields() { slots.vals.findType(CField#) }

  **
  ** List of the all defined methods (including inherited methods).
  **
  CMethod[] methods() { slots.vals.findType(CMethod#) }

  **
  ** List of the all constructors.
  **
  CMethod[] ctors() { slots.vals.findAll |s| { s.isCtor } }

  ** List of the all instance constructors.
  **
  CMethod[] instanceCtors() { slots.vals.findAll |s| { s.isInstanceCtor } }

  **
  ** Get operators lookup structure
  **
  abstract COperators operators()

//////////////////////////////////////////////////////////////////////////
// Facets
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the facet keyed by given type, or null if not defined.
  **
  abstract CFacet? facet(Str qname)

  **
  ** Return if the given facet is defined.
  **
  Bool hasFacet(Str qname) { facet(qname) != null }

  **
  ** Return if type has NoDoc facet
  **
  Bool isNoDoc() { hasFacet("sys::NoDoc") }
}

abstract class ProxyType : CType
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  new make(CType root)
  {
    this.root = root
  }

//////////////////////////////////////////////////////////////////////////
// CType
//////////////////////////////////////////////////////////////////////////

  override CNamespace ns() { root.ns }
  override CPod pod()      { root.pod }
  override Str name()      { root.name }
  override Str qname()     { root.qname }
  override Int flags()     { root.flags }
  override Str extName()   { root.extName }
  //override Str signature() { root.signature }

  override Bool isVal() { root.isVal }

  override CFacet? facet(Str qname) { root.facet(qname) }

  override Bool isNullable() { false }
  override CType toNullable() { NullableType(this) }
  override CType toNonNullable() { this }

  override Bool isGeneric() { root.isGeneric }
  override Bool isParameterized() { root.isParameterized }
  override Bool hasGenericParameter() { root.hasGenericParameter }
  //override CType parameterizeThis(CType thisType) { root.parameterizeThis(thisType) }

  override Bool isForeign()   { root.isForeign }
  override Bool isSupported() { root.isSupported }

  //override CType raw() { root.raw }
  //override CType inferredAs() { root.inferredAs }
  //override CType deref() { root.deref }

  override CType toListOf() { ListType(this) }

  override CType? base() { root.base }
  override CType[] mixins() { root.mixins }
  override Bool fits(CType t) { root.fits(t) }

  override Str:CSlot slots() { root.slots }
  override COperators operators() { root.operators }

  override Bool isValid() { root.isValid }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  CType root { private set }
}

class PlaceHolderType : CType {
  new make(CNamespace ns, Str name)
  {
    this.ns = ns
    this.name = name
  }

  override CNamespace ns
  override CPod pod() { ns.sysPod }
  override Str name
  override Str qname() { "sys::$name" }
  override Str extName() { "" }
  //override Str signature() { qname }
  override Int flags() { FConst.Public }
  override Bool isVal() { false }
  override Bool isNullable() { false }
  override once CType toNullable() { NullableType(this) }
  override Bool isGeneric() { false }
  override Bool isParameterized() { false }
  override Bool hasGenericParameter() { false }
  override once CType toListOf() { ListType(this) }
  override CType? base() { null }
  override CType[] mixins() { CType[,] }
  override CFacet? facet(Str qname) { null }
  override Str:CSlot slots() { throw UnsupportedErr() }
  override COperators operators() { ns.objType.operators }
}