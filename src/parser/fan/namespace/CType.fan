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
mixin CType : TypeMixin
{

  abstract CTypeDef typeDef()
  
  
  virtual Bool isResolved() {
    if (typeDef is PlaceHolderTypeDef) {
      t := typeDef as PlaceHolderTypeDef
      if (t.name == "Error") return false
    }
    return true
  }
  
  abstract Void resolveTo(CTypeDef typeDef)
  
  virtual Str podName() { typeDef.podName }

  **
  ** Simple name of the type such as "Str".
  **
  virtual Str name() { typeDef.name }

  **
  ** Qualified name such as "sys:Str".
  **
  override Str qname() { "${podName}::$name" }

  **
  ** This is the full signature of the type.
  **
  virtual Str signature() { "${qname}${extName}" }
  
  
  abstract Str extName()

  **
  ** Return signature
  **
  override Str toStr() { signature }
  
  
  override Int flags() { typeDef.flags }
  
  
  virtual Bool isFunc() { base.qname == "sys::Func" }

//////////////////////////////////////////////////////////////////////////
// Nullable
//////////////////////////////////////////////////////////////////////////

  **
  ** Is this is a value type (Bool, Int, or Float and their nullables)
  **
  virtual Bool isVal() {
    if (isNullable) return false
    return flags.and(FConst.Struct) != 0
  }

  Bool isJavaVal() {
    if (isNullable) return false
    n := qname
    return n == "sys::Bool" || n == "sys::Float" || n == "sys::Int"
  }

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
// Generics
//////////////////////////////////////////////////////////////////////////

  **
  ** A parameterized type is a type which has parameterized a generic type
  ** and replaced all the generic parameter types with generic argument
  ** types.  The type Str[] is a parameterized type of the generic type
  ** List (V is replaced with Str).  A parameterized type always has a
  ** signature which is different from the qname.
  **
//  Bool isParameterized() { this.typeDef is ParameterizedType }
  
  **
  ** A single generic parameter replaced by generic argument
  ** 
  abstract GenericParamDef? attachedGenericParam
  
  virtual CType physicalType() {
    if (attachedGenericParam == null) return this
    if (isTypeErasure) return this
    return attachedGenericParam.bound
  }

  **
  ** Return if this type is a generic parameter (such as V or K) in a
  ** generic type (List, Map, or Method).  Generic parameters serve
  ** as place holders for the parameterization of the generic type.
  ** Fantom has a predefined set of generic parameters which are always
  ** defined in the sys pod with a one character name.
  **
  Bool hasGenericParameter() {
    if (this.typeDef is ParameterizedType) return false
    if (this.typeDef.isGeneric) return true
    if (this.typeDef is GenericParamDef) return true
    
    return false
  }

//  **
//  ** If this is a parameterized type which uses 'This',
//  ** then replace 'This' with the specified type.
//  **
//  virtual CType parameterizeThis(CType thisType) {
//    if (!usesThis) return this
//    f := |CType t->CType| { t.isThis ? thisType : t }
//    return FuncType(params.map(f), names, f(ret), defaultParameterized)
//  }
  
  
  abstract TypeRef[]? genericArgs
  
//////////////////////////////////////////////////////////////////////////
// Inheritance
//////////////////////////////////////////////////////////////////////////
  
  virtual CType[] inheritances() { typeDef.inheritances }

  **
  ** The direct super class of this type (null for Obj).
  **
  virtual CType? base() {
    ihs := inheritances
    if (ihs.size > 0 && ihs.first.isClass) return ihs.first
    return null
  }

  **
  ** Return the mixins directly implemented by this type.
  **
  virtual CType[] mixins() {
    ihs := inheritances
    if (ihs.size > 0 && ihs.first.isClass) {
      return ihs[1..-1]
    }
    return ihs
  }

  **
  ** Hash on signature.
  **
  override Int hash()
  {
    return typeDef.signature.hash
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
    t := ty
    m := this

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

    //echo("$this not fits $ty")

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


//////////////////////////////////////////////////////////////////////////
// Slots
//////////////////////////////////////////////////////////////////////////

  **
  ** Map of the all defined slots, both fields and
  ** methods (including inherited slots).
  **
  virtual Str:CSlot slots() { typeDef.slots }

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
//  abstract COperators operators()

//////////////////////////////////////////////////////////////////////////
// Facets
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the facet keyed by given type, or null if not defined.
  **
  CFacet? facetAnno(Str qname) {
    facets := typeDef.facets
    if (facets == null) return null
    return facets.find { it.qname == qname }
  }

  **
  ** Return if the given facet is defined.
  **
  Bool hasFacet(Str qname) { facetAnno(qname) != null }

  **
  ** Return if type has NoDoc facet
  **
  Bool isNoDoc() { hasFacet("sys::NoDoc") }
}


