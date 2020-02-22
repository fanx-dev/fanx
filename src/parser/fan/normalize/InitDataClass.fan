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

  new make(CompilerContext compiler)
    : super(compiler)
  {
  }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  override Void run()
  {
    debug("InitData")
    walk(pod, VisitDepth.typeDef)
  }

  override Void visitTypeDef(TypeDef t)
  {
    if (t.flags.and(FConst.Data) == 0) return

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
    m.ret = CType.voidType(curType.loc)
    loc := curType.loc

    if (!curType.inheritances.first.isObj) {
      m.ctorChain = CallExpr(curType.loc, SuperExpr(curType.loc), "make")
      m.ctorChain.isCtorChain = true
    }

    //make(|This|? func)
    funcType := CType.funcType(loc, [curType.asRef()], CType.voidType(loc))
    param := ParamDef(loc, funcType.toNullable, "func\$")
    m.params.add(param)
    pvar := UnknownVarExpr(loc, null, "func\$")

    m.code = Block(curType.loc)

    //func.call(this)
    callExpr := CallExpr(loc, pvar, "call")
    callExpr.args = [ThisExpr(loc)]
    
    callExpr.isSafe = true
    m.code.stmts.add(callExpr.toStmt)
    m.code.stmts.add(ReturnStmt.makeSynthetic(curType.loc))
    curType.addSlot(m)

    addCtorFromArgs
  }

  private Void addCtorFromArgs() {
    // our constructor definition
    m := MethodDef(curType.loc, curType)
    m.name = "makeFrom"
    m.flags = FConst.Ctor + FConst.Public + FConst.Synthetic
    m.ret = CType.voidType(curType.loc)
    loc := curType.loc

    if (!curType.inheritances.first.isObj) {
      m.ctorChain = CallExpr(curType.loc, SuperExpr(curType.loc), "make")
      m.ctorChain.isCtorChain = true
    }

    m.code = Block(curType.loc)
    
    curType.fieldDefs.each |field| {
      if (field.isStatic || field.hasFacet("sys::Transient")) return

      param := ParamDef(loc, field.fieldType, field.name)
      m.params.add(param)
      pvar := UnknownVarExpr(loc, null, field.name)

      s := ExprStmt(
         BinaryExpr.makeAssign(
           FieldExpr(loc, ThisExpr(loc), "name"),
           pvar
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
    m.ret = CType.strType(curType.loc)
    m.code = Block(curType.loc)
    loc := curType.loc

    // buf$ := Buf()
    locStmt := LocalDefStmt(loc, CType.makeRef(loc, "sys", "StrBuf"), "buf\$")
    lvar := UnknownVarExpr(loc, null, "buf\$")
    locStmt.init = CallExpr(loc, StaticTargetExpr(loc, CType.makeRef(loc, "sys", "StrBuf")), "make", ExprId.construction)
    m.code.stmts.add(locStmt)

    fields := curType.fieldDefs.exclude |field| {
      return (field.isStatic || field.hasFacet("sys::Transient"))
    }
    fields.each |field, i| {
      addName := CallExpr(loc, lvar, "add") { args = [LiteralExpr.makeStr(loc, field.name+":")] }
      addField := CallExpr(
          loc, addName, "add") { args = [TypeCheckExpr.coerce(
                 FieldExpr(loc, ThisExpr(loc), field.name), CType.objType(loc)
             )]
          }

      // buf$.add("a:").add(this.a).add(",")
      Stmt? addStmt
      if (i == fields.size-1) {
        addStmt = ExprStmt(addField)
      }
      else {
        addStmt = ExprStmt(
          CallExpr(
            loc, addField, "add") { args = [LiteralExpr.makeStr(loc, ",")]
          }
        )
      }
      m.code.stmts.add(addStmt)
    }
    //return buf$.toStr()
    retStmt := ReturnStmt(loc, CallExpr(loc, lvar, "toStr"))
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
    m.ret = CType.intType(curType.loc)
    m.code = Block(curType.loc)
    loc := curType.loc

    //h$ := 1
    locStmt := LocalDefStmt(loc, CType.intType(curType.loc), "h\$")
    lvar := UnknownVarExpr(loc, null, "h\$")
    locStmt.init = LiteralExpr(loc, ExprId.intLiteral, 1)
    m.code.stmts.add(locStmt)

    curType.fieldDefs.each |field| {
      if (field.isStatic || field.hasFacet("sys::Transient")) return

      //h$ = h$ * 31 + this.a.hash
      //h$ = h$ * 31 + this.b.hash
      s := ExprStmt(
         BinaryExpr(lvar, Token.assign,
           ShortcutExpr.makeBinary(
             ShortcutExpr.makeBinary(lvar, Token.star, LiteralExpr(loc, ExprId.intLiteral, 31)),
             Token.plus,
             CallExpr(loc, FieldExpr(loc, ThisExpr(loc), field.name), "hash")
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
    m.ret = CType.boolType(curType.loc)
    m.code = Block(curType.loc)
    loc := curType.loc

    //param := m.addParamVar(ns.objType.toNullable, "obj\$")
    //pvar := LocalVarExpr(loc, param)
    param := ParamDef(loc, CType.objType(loc).toNullable, "obj\$")
    m.params.add(param)
    pvar := UnknownVarExpr(loc, null, "obj\$")

    //if (this === obj$) return true
    ifSame := IfStmt(
       loc, BinaryExpr(ThisExpr(loc), Token.same, pvar),
       Block(loc) { it.stmts.add(ReturnStmt(loc, LiteralExpr.makeTrue(loc))) }
    )
    m.code.stmts.add(ifSame)

    //that$ := obj$ as Type
    locStmt := LocalDefStmt(loc, curType.asRef().toNullable, "that\$")
    lvar := UnknownVarExpr(loc, null, "that\$")
    locStmt.init = TypeCheckExpr(loc, ExprId.asExpr, pvar, curType.asRef())
    m.code.stmts.add(locStmt)

    //if (that$ == null) return false
    ifStmt := IfStmt(
       loc, UnaryExpr(loc, ExprId.cmpNull, Token.eq, lvar),
       Block(loc) { it.stmts.add(ReturnStmt(loc, LiteralExpr.makeFalse(loc))) }
    )
    m.code.stmts.add(ifStmt)

    //return this.a == that$.a && this.b == that$.b
    CondExpr? condExpr
    curType.fieldDefs.each |field| {
      if (field.isStatic || field.hasFacet("sys::Transient")) return

      s := ShortcutExpr.makeBinary(
        FieldExpr(loc, ThisExpr(loc), field.name),
        Token.eq,
        FieldExpr(loc, lvar, field.name)
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
    m.ret = CType.intType(curType.loc)
    m.code = Block(curType.loc)
    loc := curType.loc

    // param := m.addParamVar(ns.objType, "obj\$")
    // pvar := UnknownVarExpr(loc, null, "obj\$")
    param := ParamDef(loc, CType.objType(loc), "obj\$")
    m.params.add(param)
    pvar := UnknownVarExpr(loc, null, "obj\$")

    //if (this === obj$) return 0
    ifSame := IfStmt(
       loc, BinaryExpr(ThisExpr(loc), Token.same, pvar),
       Block(loc) { it.stmts.add(ReturnStmt(loc, LiteralExpr(loc, ExprId.intLiteral, 0))) }
    )
    m.code.stmts.add(ifSame)

    // that$ := obj$ as Type
    locStmt := LocalDefStmt(loc, curType.asRef(), "that\$")
    lvar := UnknownVarExpr(loc, null, "that\$")
    locStmt.init = TypeCheckExpr.coerce(pvar, curType.asRef())
    m.code.stmts.add(locStmt)

    CondExpr? condExpr
    curType.fieldDefs.each |field| {
      if (field.isStatic || field.hasFacet("sys::Transient")) return
      // if (this.a != that$.a) {
      //   return this.a <=> that$.a 
      // }
      ifStmt := IfStmt(
          loc, ShortcutExpr.makeBinary(
             FieldExpr(loc, ThisExpr(loc), field.name),
             Token.notEq,
             FieldExpr(loc, lvar, field.name)
          ),
          Block(loc)
      )
      ifStmt.trueBlock.stmts.add(
          ReturnStmt(
             loc, ShortcutExpr.makeBinary(
                   FieldExpr(loc, ThisExpr(loc), field.name),
                   Token.cmp,
                   FieldExpr(loc, lvar, field.name)
             )
          )
      )
      m.code.stmts.add(ifStmt)
    }
    retStmt := ReturnStmt(loc, LiteralExpr(loc, ExprId.intLiteral, 0))
    m.code.stmts.add(retStmt)
    curType.addSlot(m)
  }
}