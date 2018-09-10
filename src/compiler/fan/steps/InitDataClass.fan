//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-08-12  Brian Frank  Creation
//

class InitDataClass : CompilerStep
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
    log.debug("InitData")
    walk(compiler, VisitDepth.typeDef)
    bombIfErr
  }

  override Void visitTypeDef(TypeDef t)
  {
    if (t.flags.and(Parser.Data) == 0) return

    addCtor
    addHash
    addToStr
    addEquals
    addCompare
    //t.dump
  }

//////////////////////////////////////////////////////////////////////////
// Synthetic
//////////////////////////////////////////////////////////////////////////

  **
  ** Add constructor
  **
  Void addCtor()
  {
    // if we found an existing constructor
    if ( curType.methodDefs.any |MethodDef x->Bool| { x.isInstanceCtor } ) {
      return
    }

    // our constructor definition
    m := MethodDef(curType.loc, curType)
    m.name = "make"
    m.flags = FConst.Ctor + FConst.Public + FConst.Synthetic
    m.ret = TypeRef(curType.loc, ns.voidType)

    if (!curType.base.isObj) {
      m.ctorChain = CallExpr(curType.loc, SuperExpr(curType.loc), "make")
      m.ctorChain.isCtorChain = true
    }

    m.code = Block(curType.loc)
    loc := curType.loc
    curType.fieldDefs.each |field| {
      if (field.isStatic || field.hasFacet("sys::Transient")) return
      s := ExprStmt(
         BinaryExpr.makeAssign(
           FieldExpr(loc, ThisExpr(loc, curType), field),
           LocalVarExpr(loc, m.addParamVar(field.fieldType, field.name))
         )
      )
      m.code.stmts.add(s)
    }
    m.code.stmts.add(ReturnStmt.makeSynthetic(curType.loc))

    curType.addSlot(m)
  }

  Void addToStr() {
    if ( curType.hasSlotDef("toStr") ) {
      return
    }

    // our constructor definition
    m := MethodDef(curType.loc, curType)
    m.name = "toStr"
    m.flags = FConst.Virtual + FConst.Override + FConst.Public + FConst.Synthetic
    m.ret = TypeRef(curType.loc, ns.strType)
    m.code = Block(curType.loc)
    loc := curType.loc

    locStmt := LocalDefStmt(loc, ns.strBufType, "buf\$")
    lvar := UnknownVarExpr(loc, null, "buf\$")
    locStmt.init = CallExpr(loc, StaticTargetExpr(loc, ns.strBufType), "<ctor>", ExprId.construction)
    m.code.stmts.add(locStmt)

    fields := curType.fieldDefs.exclude |field| {
      return (field.isStatic || field.hasFacet("sys::Transient"))
    }
    fields.each |field, i| {
      addName := CallExpr.makeWithMethod(loc, lvar, ns.strBufAdd, [LiteralExpr.makeStr(loc, ns, field.name+":")])
      addField := CallExpr.makeWithMethod(
          loc, addName, ns.strBufAdd, [TypeCheckExpr.coerce(
                 FieldExpr(loc, ThisExpr(loc, curType), field), ns.objType
          )]
        )

      Stmt? addStmt
      if (i == fields.size-1) {
        addStmt = ExprStmt(addField)
      }
      else {
        addStmt = ExprStmt(
          CallExpr.makeWithMethod(
            loc, addField, ns.strBufAdd, [LiteralExpr.makeStr(loc, ns, ",")]
          )
        )
      }
      m.code.stmts.add(addStmt)
    }
    retStmt := ReturnStmt(loc, CallExpr.makeWithMethod(loc, lvar, ns.strBufToStr))
    m.code.stmts.add(retStmt)
    curType.addSlot(m)
  }

  Void addHash() {
    if ( curType.hasSlotDef("hash") ) {
      return
    }

    // our constructor definition
    m := MethodDef(curType.loc, curType)
    m.name = "hash"
    m.flags = FConst.Virtual + FConst.Override + FConst.Public + FConst.Synthetic
    m.ret = TypeRef(curType.loc, ns.intType)
    m.code = Block(curType.loc)
    loc := curType.loc

    locStmt := LocalDefStmt(loc, ns.intType, "h\$")
    lvar := UnknownVarExpr(loc, null, "h\$")
    locStmt.init = LiteralExpr(loc, ExprId.intLiteral, ns.intType, 1)
    m.code.stmts.add(locStmt)

    curType.fieldDefs.each |field| {
      if (field.isStatic || field.hasFacet("sys::Transient")) return

      s := ExprStmt(
         BinaryExpr(lvar, Token.assign,
           ShortcutExpr.makeBinary(
             ShortcutExpr.makeBinary(lvar, Token.star, LiteralExpr(loc, ExprId.intLiteral, ns.intType, 31)),
             Token.plus,
             CallExpr(loc, FieldExpr(loc, ThisExpr(loc, curType), field), "hash")
           )
         )
      )

      m.code.stmts.add(s)
    }
    retStmt := ReturnStmt(loc, lvar)
    m.code.stmts.add(retStmt)
    curType.addSlot(m)
  }

  Void addEquals() {
    if ( curType.hasSlotDef("equals") ) {
      return
    }

    // our constructor definition
    m := MethodDef(curType.loc, curType)
    m.name = "equals"
    m.flags = FConst.Virtual + FConst.Override + FConst.Public + FConst.Synthetic
    m.ret = TypeRef(curType.loc, ns.boolType)
    m.code = Block(curType.loc)
    loc := curType.loc

    param := m.addParamVar(ns.objType.toNullable, "obj\$")

    locStmt := LocalDefStmt(loc, curType.toNullable, "that\$")
    lvar := UnknownVarExpr(loc, null, "that\$")
    pvar := LocalVarExpr(loc, param)
    locStmt.init = TypeCheckExpr(loc, ExprId.asExpr, pvar, curType)
    m.code.stmts.add(locStmt)

    ifStmt := IfStmt(
       loc, UnaryExpr(loc, ExprId.cmpNull, Token.eq, lvar),
       Block(loc) { it.stmts.add(ReturnStmt(loc, LiteralExpr.makeFalse(loc, ns))) }
    )
    m.code.stmts.add(ifStmt)

    CondExpr? condExpr
    curType.fieldDefs.each |field| {
      if (field.isStatic || field.hasFacet("sys::Transient")) return

      s := ShortcutExpr.makeBinary(
        FieldExpr(loc, ThisExpr(loc, curType), field),
        Token.eq,
        FieldExpr(loc, lvar, field)
      )
      if (condExpr == null) {
        condExpr = CondExpr(s, Token.doubleAmp)
      }
      else {
        condExpr.operands.add(s)
      }
    }
    retStmt := ReturnStmt(loc, condExpr)
    m.code.stmts.add(retStmt)
    curType.addSlot(m)
  }

  Void addCompare() {
    if ( curType.hasSlotDef("compare")) {
      return
    }

    // our constructor definition
    m := MethodDef(curType.loc, curType)
    m.name = "compare"
    m.flags = FConst.Virtual + FConst.Override + FConst.Public + FConst.Synthetic
    m.ret = TypeRef(curType.loc, ns.intType)
    m.code = Block(curType.loc)
    loc := curType.loc

    param := m.addParamVar(ns.objType, "obj\$")

    locStmt := LocalDefStmt(loc, curType, "that\$")
    lvar := UnknownVarExpr(loc, null, "that\$")
    pvar := UnknownVarExpr(loc, null, "obj\$")
    locStmt.init = TypeCheckExpr.coerce(pvar, curType)
    m.code.stmts.add(locStmt)

    CondExpr? condExpr
    curType.fieldDefs.each |field| {
      if (field.isStatic || field.hasFacet("sys::Transient")) return

      ifStmt := IfStmt(
          loc, ShortcutExpr.makeBinary(
             FieldExpr(loc, ThisExpr(loc, curType), field),
             Token.notEq,
             FieldExpr(loc, lvar, field)
          ),
          Block(loc)
      )
      ifStmt.trueBlock.stmts.add(
          ReturnStmt(
             loc, ShortcutExpr.makeBinary(
                   FieldExpr(loc, ThisExpr(loc, curType), field),
                   Token.minus,
                   FieldExpr(loc, lvar, field)
             )
          )
      )
      m.code.stmts.add(ifStmt)
    }
    retStmt := ReturnStmt(loc, LiteralExpr(loc, ExprId.intLiteral, ns.intType, 0))
    m.code.stmts.add(retStmt)
    curType.addSlot(m)
  }
}