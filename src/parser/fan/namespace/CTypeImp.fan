

class CTypeImp : CType {
  
  override Str name
  override Str podName
  
  override TypeRef[]? genericArgs
  
  //TODO check
  ** for sized primitive type. the Int32's extName is 32
  Str? sized
  
  override Bool isNullable := false
  
  CTypeDef? resolvedType
  
  new make(Str pod, Str name) {
    this.podName = pod
    
    if (pod == "sys") {
      if (name.size > 3 && name.startsWith("Int")) {
        sized = name[3..-1]
        this.name = name[0..<3]
      }
      else if (name.size > 5 && name.startsWith("Float")) {
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
  
  static CTypeImp makeQname(Str sig) {
    colon    := sig.index("::")
    podName := sig[0..<colon]
    name := sig[colon+2..-1]
    
    return CTypeImp(podName, name)
  }
  
  new makeResolvedType(CTypeDef resolvedType) {
    this.resolvedType = resolvedType
    this.name = resolvedType.name
    podName = resolvedType.podName
  }
  
  override Bool isResolved() {
    if (resolvedType == null) return false
    return CType.super.isResolved
  }
  
  override Void resolveTo(CTypeDef typeDef) {
    if (typeDef.isGeneric) {
      resolvedType = ParameterizedType.create(typeDef, genericArgs)
    }
    else {
      resolvedType = typeDef
    }
  }
  
  override Str extName() {
    s := StrBuf()
    if (sized != null) s.add(sized)
    if (genericArgs != null) {
      s.add("<").add(genericArgs.join(",")).add(">")
    }
    if (isNullable) {
      s.add("?")
    }
    return s.toStr
  }
  
  override Str signature() {
    s := StrBuf()
    if (!podName.isEmpty) {
      s.add(podName).add("::")
    }
    s.add(name)
    s.add(extName)
    return s.toStr
  }
  
  override CType toNullable() {
    isNullable = true
    return this
  }
  
  override CTypeDef typeDef() {
    if (resolvedType == null) {
      throw Err("try access unresolved type: $this")
      //resolvedType = PlaceHolderTypeDef("Error")
    }
    return resolvedType
  }
  
  override GenericParamDef? attachedGenericParam
}