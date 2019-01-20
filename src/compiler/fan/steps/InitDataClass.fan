//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-08-12  Jed Young Creation
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
    loc := curType.loc

    if (!curType.base.isObj) {
      m.ctorChain = CallExpr(curType.loc, SuperExpr(curType.loc), "make")
      m.ctorChain.isCtorChain = true
    }

    //make(|This|? func)
    funcType := ParameterizedType.create(ns.funcType, [ns.voidType, ns.thisType])
    param := ParamDef(loc, funcType.toNullable, "func\$")
    m.params.add(param)
    pvar := UnknownVarExpr(loc, null, "func\$")

    m.code = Block(curType.loc)
    /*
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
    */
    //func.call(this)
    callExpr := CallExpr.makeWithMethod(loc, pvar, ns.funcCall, [ThisExpr(loc, curType)])
    callExpr.isSafe = true
    m.code.stmts.add(callExpr.toStmt)
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

    // buf$ := Buf()
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

      // buf$.add("a:").add(this.a).add(",")
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
    //return buf$.toStr()
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

    //h$ := 1
    locStmt := LocalDefStmt(loc, ns.intType, "h\$")
    lvar := UnknownVarExpr(loc, null, "h\$")
    locStmt.init = LiteralExpr(loc, ExprId.intLiteral, ns.intType, 1)
    m.code.stmts.add(locStmt)

    curType.fieldDefs.each |field| {
      if (field.isStatic || field.hasFacet("sys::Transient")) return

      //h$ = h$ * 31 + this.a.hash
      //h$ = h$ * 31 + this.b.hash
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

    //param := m.addParamVar(ns.objType.toNullable, "obj\$")
    //pvar := LocalVarExpr(loc, param)
    param := ParamDef(loc, ns.objType.toNullable, "obj\$")
    m.params.add(param)
    pvar := UnknownVarExpr(loc, null, "obj\$")

    //if (this === obj$) return true
    ifSame := IfStmt(
       loc, BinaryExpr(ThisExpr(loc, curType), Token.same, pvar),
       Block(loc) { it.stmts.add(ReturnStmt(loc, LiteralExpr.makeTrue(loc, ns))) }
    )
    m.code.stmts.add(ifSame)

    //that$ := obj$ as Type
    locStmt := LocalDefStmt(loc, curType.toNullable, "that\$")
    lvar := UnknownVarExpr(loc, null, "that\$")
    locStmt.init = TypeCheckExpr(loc, ExprId.asExpr, pvar, curType)
    m.code.stmts.add(locStmt)

    //if (that$ == null) return false
    ifStmt := IfStmt(
       loc, UnaryExpr(loc, ExprId.cmpNull, Token.eq, lvar),
       Block(loc) { it.stmts.add(ReturnStmt(loc, LiteralExpr.makeFalse(loc, ns))) }
    )
    m.code.stmts.add(ifStmt)

    //return this.a == that$.a && this.b == that$.b
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

    // param := m.addParamVar(ns.objType, "obj\$")
    // pvar := UnknownVarExpr(loc, null, "obj\$")
    param := ParamDef(loc, ns.objType, "obj\$")
    m.params.add(param)
    pvar := UnknownVarExpr(loc, null, "obj\$")

    //if (this === obj$) return 0
    ifSame := IfStmt(
       loc, BinaryExpr(ThisExpr(loc, curType), Token.same, pvar),
       Block(loc) { it.stmts.add(ReturnStmt(loc, LiteralExpr(loc, ExprId.intLiteral, ns.intType, 0))) }
    )
    m.code.stmts.add(ifSame)

    // that$ := obj$ as Type
    locStmt := LocalDefStmt(loc, curType, "that\$")
    lvar := UnknownVarExpr(loc, null, "that\$")
    locStmt.init = TypeCheckExpr.coerce(pvar, curType)
    m.code.stmts.add(locStmt)

    CondExpr? condExpr
    curType.fieldDefs.each |field| {
      if (field.isStatic || field.hasFacet("sys::Transient")) return
      // if (this.a != that$.a) {
      //   return this.a <=> that$.a 
      // }
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
                   Token.cmp,
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