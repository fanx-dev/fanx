
class FuncType : TypeRef {
  
  new make(Loc loc, TypeRef[] params, Str[] names, TypeRef ret, Bool defaultParameterized := false)
   : super(loc, "sys", "Func")
  {
    this.params = params
    this.names  = names
    this.ret    = ret
    
    super.genericArgs = params
  }
  
  
  TypeRef[] params { private set } // a, b, c ...
  Str[] names    { private set } // parameter names
  TypeRef ret      { private set } // return type
  Bool unnamed                   // were any names auto-generated
  Bool inferredSignature   // were one or more parameters inferred
}
