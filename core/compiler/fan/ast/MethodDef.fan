//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//   19 Jul 06  Brian Frank  Ported from Java to Fan
//

**
** MethodDef models a method definition - it's signature and body.
**
class MethodDef : SlotDef, CMethod
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  public static MethodDef makeStaticInit(Loc loc, TypeDef parent, Block? block)
  {
    def := make(loc, parent)
    def.name   = "static\$init"
    def.flags  = FConst.Private + FConst.Static + FConst.Synthetic
    def.ret    = parent.ns.voidType
    def.code   = block
    return def;
  }

  public static MethodDef makeInstanceInit(Loc loc, TypeDef parent, Block? block)
  {
    def := make(loc, parent)
    def.name   = "instance\$init\$$parent.pod.name\$$parent.name";
    def.flags  = FConst.Private + FConst.Synthetic
    def.ret    = parent.ns.voidType
    def.code   = block
    return def;
  }

  new make(Loc loc, TypeDef parent, Str name := "?", Int flags := 0)
     : super(loc, parent)
  {
    this.name = name
    this.flags = flags
    this.ret = parent.ns.error
    paramDefs = ParamDef[,]
    vars = MethodVar[,]
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Return if this a static initializer block.
  **
  Bool isStaticInit() { name == "static\$init" }
  static Bool isNameStaticInit(Str name) { name == "static\$init" }

  **
  ** Return if this a instance initializer block.
  **
  Bool isInstanceInit() { name.startsWith("instance\$init\$") }
  static Bool isNameInstanceInit(Str name) { name.startsWith("instance\$init\$") }

  **
  ** Return if getter/setter for FieldDef
  **
  Bool isFieldAccessor() { accessorFor != null }

  **
  ** Return if setter for FieldDef
  **
  Bool isFieldSetter() { accessorFor != null && paramDefs.size == 1  }

  **
  ** Return if this is a once method
  **
  Bool isOnce() { flags.and(Parser.Once) != 0 }

  **
  ** Return if this is a constructor with an it-block as last parameter
  **
  Bool isItBlockCtor()
  {
    if (!isCtor || params.isEmpty) return false
    lastArg := params.last.paramType.deref.toNonNullable as FuncType
    if (lastArg == null || lastArg.params.size != 1) return false
    return true
  }

  **
  ** Make and add a MethodVar for a local variable.
  **
  MethodVar addLocalVarForDef(LocalDefStmt def, Block? scope)
  {
    var := addLocalVar(def.ctype, def.name, scope)
    var.isCatchVar = def.isCatchVar
    return var
  }

  **
  ** Make and add a MethodVar for a local variable.  If name is
  ** null then we auto-generate a temporary variable name
  **
  MethodVar addLocalVar(CType ctype, Str? name, Block? scope)
  {
    // allocate next register index, implicit this always register 0
    reg := vars.size
    if (!isStatic) reg++

    // auto-generate name
    if (name == null) name = "\$temp" + reg

    // create variable and add it variable list
    var := MethodVar(this, reg, ctype, name, 0, scope)
    vars.add(var)
    return var
  }

  **
  ** Add a parameter to the end of the method signature and
  ** initialize the param MethodVar.
  ** Note: currently this only works if no locals are defined.
  **
  MethodVar addParamVar(CType ctype, Str name)
  {
    if (vars.size > 0 && !vars[-1].isParam) throw Err("Add param with locals $qname")
    param := ParamDef(loc, ctype, name)
    params.add(param)
    var := MethodVar.makeForParam(this, params.size, param, ctype)
    vars.add(var)
    return var
  }

//////////////////////////////////////////////////////////////////////////
// CMethod
//////////////////////////////////////////////////////////////////////////

  override Str signature() { qname + "(" + params.join(",") + ")" }

  override CType returnType() { ret }

  override CType inheritedReturnType()
  {
    if (inheritedRet != null)
      return inheritedRet
    else
      return ret
  }

  override CParam[] params() { paramDefs }

//////////////////////////////////////////////////////////////////////////
// Tree
//////////////////////////////////////////////////////////////////////////

  override Void walk(Visitor v, VisitDepth depth)
  {
    v.enterMethodDef(this)
    walkFacets(v, depth)
    if (depth >= VisitDepth.stmt)
    {
      if (depth >= VisitDepth.expr)
      {
        if (ctorChain != null) ctorChain = (CallExpr)ctorChain.walk(v)
        paramDefs.each |ParamDef p| { if (p.def != null) p.def = p.def.walk(v) }
      }
      if (code != null) code.walk(v, depth)
    }
    v.visitMethodDef(this)
    v.exitMethodDef(this)
  }

//////////////////////////////////////////////////////////////////////////
// Debug
//////////////////////////////////////////////////////////////////////////

  override Void print(AstWriter out)
  {
    printFacets(out)
    out.flags(flags).w(ret).w(" ").w(name).w("(")
    paramDefs.each |ParamDef p, Int i|
    {
      if (i > 0) out.w(", ")
      p.print(out)
    }
    out.w(")").nl

    if (ctorChain != null) { out.w(" : "); ctorChain.print(out); out.nl }

    if (code != null) code.print(out)
    out.nl
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  CType ret              // return type
  CType? inheritedRet    // used for original return if covariant
  ParamDef[] paramDefs   // parameter definitions
  Block? code            // code block
  CallExpr? ctorChain    // constructor chain for this/super ctor
  MethodVar[] vars       // all param/local variables in method
  FieldDef? accessorFor  // if accessor method for field
  Bool usesCvars         // does this method have locals enclosed by closure
}