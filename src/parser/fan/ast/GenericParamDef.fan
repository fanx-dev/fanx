
**************************************************************************
** GenericParameterType
**************************************************************************

**
** GenericParameterType models the generic parameter types
** sys::V, sys::K, etc.
**

class GenericParamDef : Node, CTypeDef {
  CType? bound
  CTypeDef parent
  Str paramName
  Int index

  new make(Loc loc, Str name, CTypeDef parent, Int index, CType? bound := null)
    : super(loc)
  {
    this.parent = parent
    this.paramName = name
    this.index = index
    this.name = parent.name+"^"+name
    if (bound == null) this.bound = TypeRef.objType(loc)
    else this.bound = bound
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
  override Str podName() { "sys" }
  override Str extName() { "" }

  override CType[] inheritances() { bound.inheritances }
  override CFacet[]? facets() { bound.typeDef.facets }
  override Int flags() { FConst.Public }
  override CSlot[] slotDefs() { bound.typeDef.slotDefs }
  protected override once [Str:CSlot] slotsCache() { [:] }
  
  protected override GenericParamDef[]? genericParameters() { bound.typeDef.genericParameters }
  override once Str:TypeDef parameterizedTypeCache() { [:] }
}