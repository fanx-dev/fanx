
abstract class CTypeDef : CDefNode, TypeMixin {
  
  override Int len := 0

  **
  ** Get the flags bitmask.
  **
  override abstract Int flags()
  
  **
  ** Parent pod which defines this type.
  **
  abstract CPod pod()

  **
  ** name of parent pod
  ** 
  Str podName() { pod.name }

  **
  ** Simple name of the type such as "Str".
  **
  abstract Str name()

  **
  ** Qualified name such as "sys:Str".
  **
  override Str qname() { "${podName}::${name}" }


  virtual Str extName() { "" }

  **
  ** This is the full signature of the type.
  **
  Str signature() { "$qname$extName" }

  **
  ** Return signature
  **
  override Str toStr() { signature }
  
  once CType asRef() {
    tr := CType.makeRef(loc, pod.name, name)
//    if (this.isGeneric) {
//      if (this.qname != "sys::Func") {
//        tr.genericArgs = [,]
//        this.genericParameters.each |p| {
//          tr.genericArgs.add(p.bound)
//        }
//      }
//    }
    if (this is ParameterizedType) {
        tr.genericArgs = ((ParameterizedType)this).genericArgs.dup
    }
    tr.resolveTo(this, false)
    return tr
  }
  
  virtual Bool isVal() {
    return flags.and(FConst.Struct) != 0
  }
  
//////////////////////////////////////////////////////////////////////////
// FFI
//////////////////////////////////////////////////////////////////////////

  **
  ** If this a foreign function interface type.
  **
  virtual Bool isForeign() { false }
  
  **
  ** If this is a foreign function return the bridge.
  **
  CBridge? bridge() { pod.bridge }
  
  
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
  virtual Bool isGeneric() { genericParameters.size > 0 }
  
  **
  ** find GenericParameter by name
  **
  virtual GenericParamDef? getGenericParameter(Str name) {
    ps := genericParameters
    return ps.find { it.paramName == name }
  }
  
  protected virtual GenericParamDef[] genericParameters() { List.defVal }
  
  internal once Str:CTypeDef parameterizedTypeCache() { [Str:CTypeDef][:] }
  
//////////////////////////////////////////////////////////////////////////
// Data
//////////////////////////////////////////////////////////////////////////
  
  abstract CType[] inheritances()
  
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
  
  override abstract CFacet[]? facets()
  
  
  **
  ** Get the facet keyed by given type, or null if not defined.
  **
  CFacet? facetAnno(Str qname) {
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
  
  **
  ** Get operators lookup structure
  **
  once COperators operators() { COperators(this) }
  
//////////////////////////////////////////////////////////////////////////
// Slots
//////////////////////////////////////////////////////////////////////////
  **
  ** Get the CSlots declared within this CTypeDef.
  **
  abstract CSlot[] slotDefs()
  
  protected [Str:CSlot]? slotDefMapCache
  protected [Str:CSlot] slotDefMap() {
    if (slotDefMapCache != null) return slotDefMapCache
    map := [Str:CSlot][:]
    slotDefs.each |s|{
      if (s.isGetter || s.isSetter || s.isOverload) return
      map[s.name] = s
    }
    slotDefMapCache = map
    return slotDefMapCache
  }
  
  **
  ** Return if this class has a slot definition for specified name.
  **
  Bool hasSlotDef(Str name)
  {
    return slotDefMap.containsKey(name)
  }

  **
  ** Return SlotDef for specified name or null.
  **
  SlotDef? slotDef(Str name)
  {
    return slotDefMap[name]
  }

  **
  ** Return FieldDef for specified name or null.
  **
  CField? fieldDef (Str name)
  {
    return slotDefMap[name] as FieldDef
  }

  **
  ** Return MethodDef for specified name or null.
  **
  CMethod? methodDef(Str name)
  {
    return slotDefMap[name] as MethodDef
  }

  **
  ** Get the FieldDefs declared within this TypeDef.
  **
  CField[] fieldDefs()
  {
    return (CField[])slotDefs.findType(CField#)
  }

  **
  ** Get the static FieldDefs declared within this TypeDef.
  **
  CField[] staticFieldDefs()
  {
    return fieldDefs.findAll |CField f->Bool| { f.isStatic }
  }

  **
  ** Get the instance FieldDefs declared within this TypeDef.
  **
  CField[] instanceFieldDefs()
  {
    return fieldDefs.findAll |CField f->Bool| { !f.isStatic }
  }

  **
  ** Get the MethodDefs declared within this TypeDef.
  **
  CMethod[] methodDefs()
  {
    return (MethodDef[])slotDefs.findType(CMethod#)
  }

  **
  ** Get the constructor MethodDefs declared within this TypeDef.
  **
  CMethod[] ctorDefs()
  {
    return methodDefs.findAll |CMethod m->Bool| { m.isCtor }
  }
  
  **
  ** Map of the all defined slots, both fields and
  ** methods (including inherited slots).
  **
  private [Str:CSlot]? slotsMapCache
  
  virtual Str:CSlot slots() {
    if (slotsMapCache != null) return slotsMapCache
    
    [Str:CSlot] slotsMap := OrderedMap(64)
    slotsMapCache = slotsMap
    
    slotDefs.each |s| {
      if (s.isGetter || s.isSetter || s.isOverload) return
      slotsMap[s.name] = s
    }
    
    this.inheritances.each |t| {
      inherit(slotsMap, this, t)
    }
    
    return slotsMapCache
  }
  
  **
  ** Lookup a slot by name.  If the slot doesn't exist then return null.
  **
  virtual CSlot? slot(Str name) { slots[name] }
  
  private static Void inherit([Str:CSlot] slotsCached, CTypeDef def, CType inheritance)
  {
    closure := |CSlot newSlot|
    {
      //already inherit by base
      if (inheritance.isMixin && newSlot.parent.isObj) return
      
      // we never inherit constructors, private slots,
      // or internal slots outside of the pod
      if (newSlot.isCtor || newSlot.isPrivate || newSlot.isStatic ||
          (newSlot.isInternal && newSlot.parent.podName != inheritance.typeDef.podName))
        return
      
      oldSlot := slotsCached[newSlot.name]
      if (oldSlot != null) {
        // if we've inherited the exact same slot from two different
        // class hiearchies, then no need to continue
        if (newSlot === oldSlot) return
        
        // if this is one of the type's slot definitions
        if (oldSlot.parent === def) return
        
        kp := keep(oldSlot, newSlot)
        if (kp != newSlot) return
      }

      // inherit it
      slotsCached[newSlot.name] = newSlot
    }
    //inheritance.slots.vals.sort(|CSlot a, CSlot b->Int| {return a.name <=> b.name}).each(closure)
    inheritance.slots.each(closure)
  }
  
  **
  ** Return if there is a clear keeper between a and b - if so
  ** return the one to keep otherwise return null.
  **
  static CSlot? keep(CSlot a, CSlot b)
  {
    // if one is abstract and one concrete we keep the concrete one
    if (a.isAbstract && !b.isAbstract) return b
    if (!a.isAbstract && b.isAbstract) return a

    // keep one if it is a clear override from the other
    if (a.parent.asRef.fits(b.parent.asRef)) return a
    if (b.parent.asRef.fits(a.parent.asRef)) return b

    return null
  }

}

class PlaceHolderTypeDef : CTypeDef {
  override Str name
  override Loc loc
  override DocDef? doc() { null }
  
  new make(Str name)
  {
    this.name = name
    this.loc = Loc.makeUnknow
  }
  
  override once CPod pod() { PodDef(Loc.makeUnknow, "sys") }

  override Int flags() { FConst.Public }
  override CType[] inheritances() { CType#.emptyList }
  override CFacet[]? facets() { null }
  override CSlot[] slotDefs() { CType#.emptyList }
}
