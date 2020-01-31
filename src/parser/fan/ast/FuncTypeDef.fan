
class FuncTypeDef : Node {
  
  TypeRef typeRef
  
  new make(Loc loc, TypeRef[] params, Str[] names, TypeRef ret, Bool defaultParameterized := false)
   : super(loc)
  {
    typeRef = TypeRef(loc, "sys", "Func")
    this.params = params
    this.names  = names
    this.ret    = ret
    
    typeRef.genericArgs = [ret].addAll(params)
  }
  
  new makeItBlock(Loc loc, CType itType)
    : this.make(loc, [itType], ["it"], TypeRef.voidType(loc))
  {
    //TODO check
    // sanity check
    //if (itType.isThis) throw Err("Invalid it-block func signature: $this")
  }
  
  override Void print(AstWriter out)
  {
    out.w(toStr)
  }
  
  override Str toStr() {
    s := StrBuf()
    s.add("|")
    params.size.times |i| {
      s.add(names[i]).add(" : ").add(params[i])
    }
    s.add(" -> ").add(ret)
    return s.toStr
  }
  
  TypeRef[] params { private set } // a, b, c ...
  Str[] names    { private set } // parameter names
  TypeRef ret      { private set } // return type
  Bool unnamed                   // were any names auto-generated
  Bool inferredSignature   // were one or more parameters inferred
}
