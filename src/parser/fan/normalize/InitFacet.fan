//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   03 Feb 10  Brian Frank  Creation
//

**
** InitFacet is used to auto-generate AST modifications to facet classes.
**
**
class InitFacet : CompilerStep
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(CompilerContext compiler)
    : super(compiler)
  {
  }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  override Void run()
  {
    debug("InitFacet")
    walk(pod, VisitDepth.typeDef)
  }

  override Void visitTypeDef(TypeDef t)
  {
    if (!t.isFacet) return
    try
    {
      initCurType
      errorChecks
      if (fields.isEmpty)
        initSingleton
      else
        initStruct
    }
    catch (CompilerErr e)
    {
    }
  }

  private Void initCurType()
  {
    this.ctors  = curType.ctorDefs
    this.fields = curType.instanceFieldDefs
  }

  private Void errorChecks()
  {
    // there cannot be any user defined constructors
    if (!ctors.isEmpty)
      throw err("Facet cannot declare constructors", ctors.first.loc)
  }

  private Void initSingleton()
  {
    loc := curType.loc

    // private new make() {}
    m := MethodDef(loc, curType)
    m.name = "make"
    m.flags = FConst.Ctor + FConst.Private + FConst.Synthetic
    m.ret = TypeRef.voidType(loc)
    m.code = Block(loc)
    m.code.stmts.add(ReturnStmt.makeSynthetic(loc))
    curType.addSlot(m)

    // const static CurType defVal := make()
    f := FieldDef(loc, curType)
    f.doc       = DocDef(loc, ["Singleton for $curType.name facet."])
    f.flags     = FConst.Public + FConst.Static + FConst.Const + FConst.Storage
    f.name      = "defVal"
    f.fieldType = curType.asRef()
    f.init      = CallExpr(loc, null, "make")
    curType.addSlot(f)
  }

  private Void initStruct()
  {
    loc := curType.loc

    // f?.call(this)
    call := CallExpr(loc, UnknownVarExpr(loc, null, "f"), "call")
    call.args = [ThisExpr(loc)]
    call.isSafe = true

    // new make(|This|? f := null) { f?.call(this) }
    m := MethodDef(loc, curType)
    m.name = "make"
    m.flags = FConst.Ctor + FConst.Public + FConst.Synthetic
    m.ret = TypeRef.voidType(loc)
    itType := TypeRef.funcType(loc, [curType.asRef()], TypeRef.voidType(loc))
    m.params.add(ParamDef(loc, itType.toNullable, "f", LiteralExpr.makeNull(loc)))
    m.code = Block(loc)
    m.code.stmts.add(call.toStmt)
    m.code.stmts.add(ReturnStmt.makeSynthetic(loc))
    curType.addSlot(m)

    // make Serializable
    curType.addFacet(TypeRef(loc, "sys", "Serializable"))
  }

//////////////////////////////////////////////////////////////////////////
// Make Ctor
//////////////////////////////////////////////////////////////////////////

  MethodDef[]? ctors    // constructors
  FieldDef[]? fields    // instance fields
}


