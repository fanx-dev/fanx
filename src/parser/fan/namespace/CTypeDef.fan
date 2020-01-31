
mixin CTypeDef : TypeMixin{
  **
  ** Parent pod which defines this type.
  **
//  abstract CPod pod()

  abstract Str podName()

  **
  ** Simple name of the type such as "Str".
  **
  abstract Str name()

  **
  ** Qualified name such as "sys:Str".
  **
  override Str qname() { "${podName}::${name}" }


  abstract Str extName()

  **
  ** This is the full signature of the type.
  **
  Str signature() { "$qname$extName" }

  **
  ** Return signature
  **
  override Str toStr() { signature }
  
  virtual CType asRef(Loc? loc := null) {
    tr := CTypeImp(podName, name)
    tr.resolveTo(this)
    return tr
  }
  
//////////////////////////////////////////////////////////////////////////
// FFI
//////////////////////////////////////////////////////////////////////////

  **
  ** If this a foreign function interface type.
  **
  virtual Bool isForeign() { false }

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
  virtual Bool isGeneric() { genericParameters != null }
  
  **
  ** find GenericParameter by name
  **
  virtual GenericParamDef? getGenericParameter(Str name) {
    ps := genericParameters
    return ps.find { it.paramName == name }
  }
  
  protected abstract GenericParamDef[]? genericParameters()
  
  
//////////////////////////////////////////////////////////////////////////
// Data
//////////////////////////////////////////////////////////////////////////
  
  abstract CType[] inheritances()
  
  
  abstract CFacet[]? facets()

  **
  ** Get the flags bitmask.
  **
//  abstract Int flags()
  
  **
  ** decleard slots
  ** 
  abstract CSlot[] slotDefs()
  
  **
  ** Map of the all defined slots, both fields and
  ** methods (including inherited slots).
  **
  protected abstract Str:CSlot slotsCache()
  
  virtual Str:CSlot slots() {
    if (slotsCache.size > 0) return slotsCache
    
    slotDefs.each {
      slotsCache[it.name] = it
    }
    
    this.inheritances.each |t| {
      inherit(slotsCache, t)
    }
    return slotsCache
  }
  
  **
  ** Lookup a slot by name.  If the slot doesn't exist then return null.
  **
  virtual CSlot? slot(Str name) { slots[name] }
  
  static Void inherit([Str:CSlot] slotsCached, CType t)
  {
    t.slots.each |CSlot newSlot|
    {
      // if slot already mapped, skip it
      if (slotsCached[newSlot.name] != null) {
        if (slotsCached[newSlot.name].parent.qname != "sys::Obj") {
          return
        }
      }

      // we never inherit constructors, private slots,
      // or internal slots outside of the pod
      if (newSlot.isCtor || newSlot.isPrivate || newSlot.isStatic ||
          (newSlot.isInternal && newSlot.parent.podName != t.typeDef.podName))
        return

      // inherit it
      slotsCached[newSlot.name] = newSlot
    }
  }
  
  abstract Str:TypeDef parameterizedTypeCache()
}

class PlaceHolderTypeDef : CTypeDef {
  override Str name
  
  new make(Str name)
  {
    this.name = name
  }

  override Str podName() { "sys" }
  override Str extName() { "" }
  
  override CType[] inheritances() { CType#.emptyList }
  override CFacet[]? facets() { null }
  override Int flags() { FConst.Public }
  
  override CSlot[] slotDefs() { CType#.emptyList }
  protected override once Str:CSlot slotsCache() { [:] }
  
  override once Str:TypeDef parameterizedTypeCache() { [:] }
  protected override GenericParamDef[]? genericParameters() { null }
}
