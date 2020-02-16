
**************************************************************************
** GenericParameterType
**************************************************************************

**
** GenericParameterType models the generic parameter types
** sys::V, sys::K, etc.
**

class GenericParamDef : CTypeDef {
  CType? bound
  CTypeDef parent
  Str paramName
  Int index
  
  override Loc loc
  override DocDef? doc() { null }

  new make(Loc loc, Str name, CTypeDef parent, Int index, CType? bound := null)
  {
    this.loc = loc
    this.parent = parent
    this.paramName = name
    this.index = index
    this.name = parent.name+"^"+name
    if (bound == null) bound = TypeRef.objType(loc).toNullable
    this.bound = bound
  }
  
  override Str toStr() {
    s := paramName
    if (bound != null) s += " : " + bound
    return s
  }
  
  override Void print(AstWriter out)
  {
    out.w(paramName)
    if (bound != null) out.w(" : ").w(bound)
  }
  
  override Str name
  override CPod pod() { parent.pod }

  override CType[] inheritances() { bound.inheritances }
  override CFacet[]? facets() { bound.typeDef.facets }
  override Int flags() { FConst.Public }
  override CSlot[] slotDefs() { bound.typeDef.slotDefs }
}