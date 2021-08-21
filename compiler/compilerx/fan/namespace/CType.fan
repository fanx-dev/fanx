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
class CType : CNode, TypeMixin
{
  Str name
  Str podName
  
  CType[]? genericArgs {
    set { &genericArgs = it; if (it != null && it.any|a|{ a ===  this}) throw Err("self ref") }
  }
  
  ** for sized primitive type. the Int32's extName is 32
  Str? sized
  
  **
  ** Is this is a nullable type (marked with trailing ?)
  **
  private const Bool _isNullable := false
  private CType? nullabelePeer = null
  
  private CTypeDef? resolvedType
  
  ** location in source file
  override Loc loc
  
  ** end loc is loc.offset + len
  override Int len := 0
  
//////////////////////////////////////////////////////////////////////////
// Ctors
//////////////////////////////////////////////////////////////////////////
  
  static CType makeRef(Loc loc, Str? pod, Str name) {
    t := CType(pod ?: "", name, loc)
    return t
  }
  
  new make(Str pod, Str name, Loc loc := Loc.makeUnknow) {
    this.podName = pod
    this.loc = loc
    
    if (pod == "sys" || pod.isEmpty) {
      if (name.size > 3 && 
        (name == "Int8" || name == "Int16" || name == "Int32" || name == "Int64") ) {
        sized = name[3..-1]
        this.name = name[0..<3]
      }
      else if (name.size > 5 &&
        (name == "Float32" || name == "Float64") ) {
        sized = name[5..-1]
        this.name = name[0..<5]
      }
      else {
        this.name = name
      }
    }
    else {
      this.name = name
    }
  }
  
  static CType makeQname(Str sig) {
    colon    := sig.index("::")
    podName := sig[0..<colon]
    name := sig[colon+2..-1]
    
    return CType(podName, name)
  }
  
  new makeResolvedType(CTypeDef resolvedType, Loc? loc := null) {
    this.resolvedType = resolvedType
    this.name = resolvedType.name
    this.podName = resolvedType.podName
    this.loc = loc ?: this.resolvedType.loc
  }
  
//////////////////////////////////////////////////////////////////////////
// Builder
//////////////////////////////////////////////////////////////////////////
  
  static CType? objType(Loc loc) { makeRef(loc, "sys", "Obj") }
  static CType? voidType(Loc loc) { makeRef(loc, "sys", "Void") }
  static CType? errType(Loc loc) { makeRef(loc, "sys", "Err") }
  static CType? error(Loc loc) { makeRef(loc, "sys", "Error") }
  static CType? nothingType(Loc loc) { makeRef(loc, "sys", "Nothing") }
  static CType? boolType(Loc loc) { makeRef(loc, "sys", "Bool") }
  static CType? enumType(Loc loc) { makeRef(loc, "sys", "Enum") }
  static CType? facetType(Loc loc) { makeRef(loc, "sys", "Facet") }
  static CType? intType(Loc loc) { makeRef(loc, "sys", "Int") }
  static CType? strType(Loc loc) { makeRef(loc, "sys", "Str") }
  static CType? thisType(Loc loc) { makeRef(loc, "sys", "This") }
  static CType? listType(Loc loc, CType elemType) {
    t := makeRef(loc, "sys", "List")
    t.genericArgs = [elemType]
    return t
  }
  static CType? funcType(Loc loc, CType[] params, CType ret) {
    t := makeRef(loc, "sys", "Func")
    t.genericArgs = [ret].addAll(params)
    return t
  }
  static CType? asyncType(Loc loc) { makeRef(loc, "concurrent", "Async") }
//  static TypeRef? promiseType(Loc loc) { TypeRef(loc, "concurrent", "Promise") }
  static CType? mapType(Loc loc, CType k, CType v) {
    t := makeRef(loc, "std", "Map")
    t.genericArgs = [k, v]
    return t
  }
  
//////////////////////////////////////////////////////////////////////////
// methods
//////////////////////////////////////////////////////////////////////////
  
  override Void print(AstWriter out)
  {
    out.w(toStr)
  }
  

  CTypeDef typeDef() {
    if (resolvedType == null) {
      throw Err("try access unresolved type: $this")
      //resolvedType = PlaceHolderTypeDef("Error")
    }
    return resolvedType
  }
  
  
  virtual Bool isResolved() {
    if (resolvedType == null) return false
//    if (typeDef.isError()) return false
    return true
  }
  
    
  ** generic genericArgs is absent
  Bool defaultParameterized() {
    if (resolvedType is ParameterizedType) {
       return ((ParameterizedType)resolvedType).defaultParameterized
    }
    return false
  }
  
  Void resolveTo(CTypeDef typeDef, Bool defaultParameterized := true) {
    if (typeDef.isGeneric) {
      if (genericArgs == null && !defaultParameterized) {
        resolvedType = typeDef
      }
      else {
        c := typeDef.parameterizedTypeCache[extName]
        if (c == null) {
          c = ParameterizedType.create(typeDef, genericArgs)
          typeDef.parameterizedTypeCache[extName] = c
        }
        resolvedType = c

        if ((resolvedType as ParameterizedType).defaultParameterized) {
          genericArgs = (resolvedType as ParameterizedType).genericArgs
        }
      }
    }
    else {
      resolvedType = typeDef
    }
    
    if (podName.isEmpty) podName = this.resolvedType.podName
    if (nullabelePeer != null) {
        nullabelePeer.resolvedType = this.resolvedType
        if (nullabelePeer.podName.isEmpty) nullabelePeer.podName = this.resolvedType.podName
    }
  }

  **
  ** Qualified name such as "sys:Str".
  **
  override Str qname() { "${podName}::$name" }

  **
  ** This is the full signature of the type.
  **
  Str signature() {
    s := StrBuf()
    if (!podName.isEmpty) {
      s.add(podName).add("::")
    }
    s.add(name)
    s.add(extName)
    return s.toStr
  }
  
  Str extName() {
    s := StrBuf()
    if (sized != null) s.add(sized)
    if (genericArgs != null) {
      s.add("<").add(genericArgs.join(",")).add(">")
    }
    if (_isNullable) {
      s.add("?")
    }
    return s.toStr
  }

  **
  ** Return signature
  **
  override Str toStr() { signature }
  
  
  override Int flags() { typeDef.flags }
  
  
  virtual Bool isFunc() { qname == "sys::Func" || (base != null && base.qname == "sys::Func") }
  
//  private CType dup() {
//    d := CType(qname, name)
//    d.resolvedType = typeDef
//    return d
//  }

   override Void getChildren(CNode[] list, [Str:Obj]? options) {
     if (genericArgs != null) {
        genericArgs.each { list.add(it) }
     }
   }

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
  
  private new makeNullable(CType type) {
    this.name = type.name
    this.podName = type.podName
    this.resolvedType = type.resolvedType
    this._isNullable = true
    this.genericArgs = type.genericArgs
    this.loc = type.loc
    this.len = type.len
    //d.attachedGenericParam = attachedGenericParam
    this.sized = type.sized
  }

  **
  ** Get this type as a nullable type (marked with trailing ?)
  **
  virtual CType toNullable() {
    if (_isNullable) return this
    if (nullabelePeer != null) return nullabelePeer
    nullabelePeer := makeNullable(this)
    nullabelePeer.nullabelePeer = this
    return nullabelePeer
  }

  **
  ** Get this type as a non-nullable (if nullable)
  **
  virtual CType toNonNullable() {
    if (!_isNullable) return this
    return nullabelePeer
  }
  
  **
  ** Is this is a nullable type (marked with trailing ?)
  **
  Bool isNullable() { _isNullable || (resolvedType != null && resolvedType is GenericParamDef) }
  
  Bool isExplicitNullable() { _isNullable }
  

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
  Bool isParameterized() {
    if (this.typeDef is ParameterizedType) return true
    return false
  }
  
  ** after generic type erasure
  virtual CType raw() {
    if (typeDef is GenericParamDef) {
        t := ((GenericParamDef)typeDef).bound
        if (this.isNullable && !t.isNullable) t = t.toNullable
        return t
    }
    return this
  }
  
  private CType realType() {
    CType t := this
    if (t.isThis || t.podName.isEmpty)
      t = typeDef.asRef
    return t
  }
  
  Bool isGenericParameter() {
    return typeDef is GenericParamDef
  }
  
  CTypeDef? generic() {
    if (typeDef.isGeneric) return typeDef
    if (typeDef is ParameterizedType) return ((ParameterizedType)typeDef).root
    return null
  }

  **
  ** Return if this type is a generic parameter (such as V or K) in a
  ** generic type (List, Map, or Method).  Generic parameters serve
  ** as place holders for the parameterization of the generic type.
  ** Fantom has a predefined set of generic parameters which are always
  ** defined in the sys pod with a one character name.
  **
  Bool hasGenericParameter() {
    if (this.typeDef.isGeneric) return true
    if (this.typeDef is GenericParamDef) return true
    if (this.genericArgs != null) {
      if (this.genericArgs.any { it.hasGenericParameter }) return true
    }
    
    return false
  }

  **
  ** If this is a parameterized type which uses 'This',
  ** then replace 'This' with the specified type.
  **
  virtual CType parameterizeThis(CType thisType) {
    //if (!usesThis) return this
    //f := |CType t->CType| { t.isThis ? thisType : t }
    //return FuncType(params.map(f), names, f(ret), defaultParameterized)
    
    if (this.isThis) return thisType
    
    if (this.genericArgs != null) {
      hasThis := this.genericArgs.any { it.isThis }
      if (!hasThis) return this
      
      nt := CType.makeResolvedType(this.resolvedType)
      if (this.isNullable)
        nt = nt.toNullable
      nt.genericArgs = this.genericArgs.map |a|{ a.parameterizeThis(thisType) }
      return nt
    }
    return this
  }
  
  CType funcRet() {
    if (genericArgs == null || genericArgs.size == 0) return CType.make("sys", "Obj").toNullable
    return this.genericArgs.first
  }
  
  CType[] funcParams() {
    if (genericArgs == null || genericArgs.size == 0) {
      t := CType.make("sys", "Obj").toNullable
      return [t, t, t, t, t, t, t, t]
    }
    return this.genericArgs[1..-1]
  }
  
  Int funcArity() {
    if (genericArgs == null || genericArgs.size == 0) return 8
    return this.genericArgs.size - 1
  }
  
  CType arrayOf() {
    if (genericArgs == null|| genericArgs.size == 0) return CType.make("sys", "Obj").toNullable
    return this.genericArgs[0]
  }
  
  
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
    if (this.isFunc && ty.isFunc) {
        return Coerce.isFuncAutoCoerce(this, ty)
    }
    //unparameterized generic parameters
    // don't take nullable in consideration
    t := ty.realType
    m := this.realType

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

}


