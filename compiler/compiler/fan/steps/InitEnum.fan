//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Apr 06  Brian Frank  Creation
//   22 Sep 06  Brian Frank  Ported from Java to Fan
//

**
** InitEnum is used to auto-generate EnumDefs into abstract
** syntax tree representation of the fields and method.
**
**
class InitEnum : CompilerStep
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(Compiler compiler)
    : super(compiler)
  {
  }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  override Void run()
  {
    log.debug("InitEnum")
    walk(compiler, VisitDepth.typeDef)
    bombIfErr
  }

  override Void visitTypeDef(TypeDef t)
  {
    if (!t.isEnum) return

    try
    {
      addCtor
      addFromStr
      t.addFacet(this, ns.sysPod.resolveType("Serializable", true), ["simple":true])

      fields := FieldDef[,]
      t.enumDefs.each |EnumDef e| { fields.add(makeField(e)) }
      fields.add(makeValsField)

      // add enum fields to beginning of type
      fields.each |FieldDef f, Int i| { t.addSlot(f, i) }
    }
    catch (CompilerErr e)
    {
    }
  }

//////////////////////////////////////////////////////////////////////////
// Make Ctor
//////////////////////////////////////////////////////////////////////////

  **
  ** Add constructor or enhance existing constructor.
  **
  Void addCtor()
  {
    // our constructor definition
    MethodDef? m :=  null

    // check if there are any existing constructors - there
    // can only be zero or one called make
    ctors := curType.methodDefs.findAll |MethodDef x->Bool| { x.isInstanceCtor }
    ctors.each |MethodDef ctor|
    {
      if (ctor.name == "make")
        m = ctor
      else
        throw err("Enum constructor must be named 'make'", ctor.loc)
    }

    // if we found an existing constructor, then error check it
    if (m != null)
    {
      if (!m.isPrivate)
        err("Enum constructor must be private", m.loc)

      if (m.ctorChain != null)
        err("Enum constructor cannot call super constructor", m.loc)
    }

    // if we didn't find an existing constructor, then
    // add a synthetic one
    if (m == null)
    {
      m = MethodDef(curType.loc, curType)
      m.name = "make"
      m.flags = FConst.Ctor + FConst.Private + FConst.Synthetic
      m.ret = TypeRef(curType.loc, ns.voidType)
      m.code = Block(curType.loc)
      m.code.stmts.add(ReturnStmt.makeSynthetic(curType.loc))
      curType.addSlot(m)
    }

    // Enum.make call
    loc := m.loc
    m.ctorChain = CallExpr(loc, SuperExpr(loc), "make")
    m.ctorChain.isCtorChain = true
    m.ctorChain.args.add(UnknownVarExpr(loc, null, "\$ordinal"))
    m.ctorChain.args.add(UnknownVarExpr(loc, null, "\$name"))

    // insert ordinal, name params
    m.params.insert(0, ParamDef(loc, ns.intType, "\$ordinal"))
    m.params.insert(1, ParamDef(loc, ns.strType, "\$name"))
  }

//////////////////////////////////////////////////////////////////////////
// Make FromStr
//////////////////////////////////////////////////////////////////////////

  **
  ** Add fromStr method.
  **
  Void addFromStr()
  {
    // static CurType fromStr(Str name, Bool checked := true)
    loc := curType.loc
    m := MethodDef(loc, curType)
    m.name = "fromStr"
    m.flags = FConst.Public + FConst.Static + FConst.Ctor
    m.params.add(ParamDef(loc, ns.strType, "name"))
    m.params.add(ParamDef(loc, ns.boolType, "checked", LiteralExpr(loc, ExprId.trueLiteral, ns.boolType, true)))
    m.ret = TypeRef(loc, curType.toNullable)
    m.code = Block(loc)
    m.doc  = DocDef(loc,
              ["Return the $curType.name instance for the specified name.  If not a",
               "valid name and checked is false return null, otherwise throw ParseErr."])
    curType.addSlot(m)

    // return (CurType)doParse(name, checked)
    doFromStr := CallExpr(loc, null, "doFromStr")
    doFromStr.args.add(LiteralExpr(loc, ExprId.strLiteral, ns.strType, curType.qname))
    doFromStr.args.add(UnknownVarExpr(loc, null, "name"))
    doFromStr.args.add(UnknownVarExpr(loc, null, "checked"))
    cast := TypeCheckExpr(loc, ExprId.coerce, doFromStr, curType.toNullable)
    m.code.stmts.add(ReturnStmt.makeSynthetic(loc, cast))
  }

//////////////////////////////////////////////////////////////////////////
// Make Field
//////////////////////////////////////////////////////////////////////////

  **
  ** Make enum value field:  public static final Foo name = make(ord, name)
  **
  FieldDef makeField(EnumDef def)
  {
    // ensure there isn't already a slot with same name
    dup := curType.slot(def.name)
    if (dup != null)
    {
      if (dup.parent === curType)
        throw err("Enum '$def.name' conflicts with slot", (Loc)dup->loc)
      else
        throw err("Enum '$def.name' conflicts with inherited slot '$dup.qname'", def.loc)
    }

    loc := def.loc

    // initializer
    init := CallExpr(loc, null, "make")
    init.args.add(LiteralExpr(loc, ExprId.intLiteral, ns.intType, def.ordinal))
    init.args.add(LiteralExpr(loc, ExprId.strLiteral, ns.strType, def.name))
    init.args.addAll(def.ctorArgs)

    // static field
    f := FieldDef(loc, curType)
    f.doc       = def.doc
    f.facets    = def.facets
    f.flags     = FConst.Public + FConst.Static + FConst.Const + FConst.Storage + FConst.Enum
    f.name      = def.name
    f.fieldType = curType
    f.init      = init
    f.enumDef   = def
    return f
  }

  **
  ** Make vals field: List of Enum values
  **
  FieldDef makeValsField()
  {
    // ensure there isn't already a slot with same name
    dup := curType.slot("vals")
    if (dup != null)
    {
      if (dup.parent == curType)
        throw err("Enum 'vals' conflicts with slot", (Loc)dup->loc)
      else
        throw err("Enum 'vals' conflicts with inherited slot '$dup.qname'", curType.loc)
    }

    loc := curType.loc

    // initializer
    listType := curType.toListOf
    init := ListLiteralExpr(loc, listType)
    curType.enumDefs.each |EnumDef e|
    {
      target := StaticTargetExpr(loc, curType)
      init.vals.add(UnknownVarExpr(loc, target, e.name))
    }

    // static field
    f := FieldDef(loc, curType)
    f.flags     = FConst.Public + FConst.Static + FConst.Const + FConst.Storage
    f.name      = "vals"
    f.fieldType = listType
    f.init      = init
    f.doc       = DocDef(loc, ["List of $curType.name values indexed by ordinal"])
    return f
  }

}