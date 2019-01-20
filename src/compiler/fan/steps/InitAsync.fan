//
// Copyright (c) 2019, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2019-01-19  Jed Young Creation
//

/*

  async Type foo() {
    s1
    s2
    goto s6
    s3
    s4 := yield expr
    s5
    s6
    return x
  }

trans to =>

  class Async$foo : Iter {
    Int state
    Type self
    Obj? yieldObj
    Type? result

    Type param1
    Type var1
    Type var2
    
    new make(Type param1) { this.param1 = param1 }

    Bool next() {
      self.foo$async(this)
      return this.state != -1
    }
    Obj? get() { return this.yieldObj }
  }

  Type foo(p1) {
    //ctx := foo_(p1)
    //while (ctx.next) {
    //}
    //return ctx.get
    throw Err("Cant call aysnc")
  }

  Iter foo_(p1, p2) {
    ctx := Async$foo.make(p1)
    return ctx
  }

  Void foo$async(Async$foo ctx) {
    try{
      switch(ctx.state) {
      case 0:
         s1
         s2
         goto s6
         s3
         ctx.yieldObj = expr
         ctx.sate = 2
         break
      case 1:
         s4 := ctx.result
         s5
         s6
         ctx.result = x
         ctx.state = -1
         break
      }
    }
    catch (Err e){
      if (s < ctx.state && ctx.state < end) {
        if (e.ctype fit errType) ctx.err = e; goto Handler
      }
      if (s < ctx.state && ctx.state < end) {
        if (e.ctype fit errType) ctx.err = e; goto Handler
      }
      if (s < ctx.state && ctx.state < end) {
        if (e.ctype fit errType) goto Handler
      }
    }
  }
*/
class InitAsync : CompilerStep {
  
  private TypeDef? ctxCls //context class
  private Loc? loc  //method loc
  private Str? name  //method name
  private MethodDef? implMethod //async method
  private Bool isStatic
  
  new make(Compiler compiler)
    : super(compiler)
  {
  }

  override Void run()
  {
    log.debug("InitAsync")
    walk(compiler, VisitDepth.slotDef)
    bombIfErr
  }
  
  override Void visitMethodDef(MethodDef def) {
    if (def.code == null) return
    if ((curMethod.flags.and(FConst.Async)) == 0) return

    loc = def.loc
    name = def.name
    isStatic = def.isStatic
    
    process
  }

//////////////////////////////////////////////////////////////////////////
// Process
//////////////////////////////////////////////////////////////////////////

  private Void process()
  {
    genCtx
    genAsyncMethod
    
    genCtor
    genInternalMethod
    
    genNext
    genGet

    genSyncMethod

    removeLocalVar
    genSwitch
  }


  private Void genCtx()
  {
    ctxCls = TypeDef(ns, loc, curUnit, "Async\$"+name)
    ctxCls.flags   = FConst.Internal + FConst.Final + FConst.Synthetic
    ctxCls.base    = ns.iterType
    addTypeDef(ctxCls)

    addField(ns.intType, "state")
    addField(curType, "self")
    addField(ns.objType.toNullable, "yieldObj")
    addField(curMethod.ret.toNullable, "result")

    curMethod.vars.each |v| {
      addField(v.ctype, "var_" + v.name)
    }
  }

  private Void addField(CType ctype, Str name) {
    // define storage field on closure class
    field := FieldDef(loc, ctxCls)
    field.name  = name
    field.flags = FConst.Internal + FConst.Storage + FConst.Synthetic
    field.fieldType = ctype
    ctxCls.addSlot(field)
  }
  
  private Void genCtor()
  {
    code := Block(loc)
    code.stmts.add(ReturnStmt.makeSynthetic(loc))

    ctor := MethodDef(loc, ctxCls)
    ctor.flags = FConst.Internal + FConst.Ctor + FConst.Synthetic
    ctor.name = "make"
    ctor.ret  = ns.voidType
    ctor.code = Block(loc)
    ctxCls.addSlot(ctor)

    ctor.ctorChain = CallExpr(curType.loc, SuperExpr(curType.loc), "make")
    ctor.ctorChain.isCtorChain = true

    curMethod.paramDefs.each |param| {
      field := ctxCls.fieldDef("var_"+param.name)
      s := ExprStmt(
         BinaryExpr.makeAssign(
           FieldExpr(loc, ThisExpr(loc, curType), field),
           LocalVarExpr(loc, ctor.addParamVar(field.fieldType, field.name))
         )
      )
      ctor.code.stmts.add(s)
    }
    ctor.code.stmts.add(ReturnStmt.makeSynthetic(curType.loc))
  }
  
  private Void genNext()
  {
    m := MethodDef(loc, ctxCls)
    m.name  = "next"
    m.flags = FConst.Public + FConst.Synthetic + FConst.Override
    m.ret = ns.boolType
    m.code = Block(loc)
    ctxCls.addSlot(m)
    
    //self.foo$async(this)
    field := ctxCls.fieldDef("self")
    cs := CallExpr.makeWithMethod(loc, 
      FieldExpr(loc, ThisExpr(loc, ctxCls), field), implMethod,
      [ThisExpr(loc, ctxCls)])
    m.code.add(cs.toStmt)
    
    //return this.state != -1
    field2 := ctxCls.fieldDef("state")
    cmp := ShortcutExpr.makeBinary(
            FieldExpr(loc, ThisExpr(loc, ctxCls), field2),
            Token.eq,
            LiteralExpr(loc, ExprId.intLiteral, ns.intType, -1)
          )
    s := ReturnStmt.make(loc, cmp)
    m.code.add(s)
  }
  
  private Void genGet()
  {
    m := MethodDef(loc, ctxCls)
    m.name  = "get"
    m.flags = FConst.Public + FConst.Synthetic + FConst.Override
    m.ret = ns.objType.toNullable
    m.code = Block(loc)
    ctxCls.addSlot(m)

    field := ctxCls.fieldDef("yieldObj")
    s := ReturnStmt.make(loc,FieldExpr(loc, ThisExpr(loc, ctxCls), field))
    m.code.add(s)
  }
  
  private Void genAsyncMethod()
  {
    doCall := MethodDef(loc, curType)
    doCall.name  = name+"\$async"
    doCall.flags = FConst.Internal + FConst.Synthetic
    if (isStatic) doCall.flags += FConst.Static
    doCall.ret = ns.voidType
    doCall.paramDefs = [ParamDef(loc, ctxCls, "async\$ctx")]
    //doCall.code = Block(loc)
    curType.addSlot(doCall)
    
    implMethod = doCall
  }
  
  private Void genInternalMethod()
  {
    doCall := MethodDef(loc, curType)
    doCall.name  = name+"_"
    doCall.flags = FConst.Internal + FConst.Synthetic
    if (isStatic) doCall.flags += FConst.Static
    doCall.ret = ns.iterType
    doCall.paramDefs = curMethod.paramDefs.dup
    doCall.code = Block(loc)
    curType.addSlot(doCall)
    
    Expr[]? args
    if (doCall.paramDefs.size > 0) {
      args = Expr[,]
      doCall.paramDefs.each |param| {
        var := MethodVar.makeForParam(doCall, doCall.params.size, param, param.paramType)
        doCall.vars.add(var)
        lvar := LocalVarExpr(loc, var)
        args.add(lvar)
      }
    }
    cs := CallExpr.makeWithMethod(loc, null, ctxCls.methodDef("make"), args)
    doCall.code.add(ReturnStmt.make(loc, cs))
  }
  
  private Void genSyncMethod() {
    implMethod.code = curMethod.code
    curMethod.code = Block(loc)
    curMethod.vars.clear
    /*
    Expr[]? args
    if (curMethod.paramDefs.size > 0) {
      args = Expr[,]
      curMethod.paramDefs.each |param| {
        var := MethodVar.makeForParam(doCall, curMethod.params.size, param, param.paramType)
        curMethod.vars.add(var)
        lvar := LocalVarExpr(loc, var)
        args.add(lvar)
      }
    }
    
    //ctx := foo_(p1)
    internalMethod := curType.methodDef(name+"_")
    ctx := CallExpr.makeWithMethod(loc, internalMethod, ThisExpr(loc, curType), args)
    var := curMethod.addLocalVar(ctx.ctype, null, null)
    lvar := LocalVarExpr(expr.loc, var)
    assign := BinaryExpr.makeAssign(lvar, expr)
    curMethod.code.add(assign.toStmt)
    
    //while (ctx.next) {}
    continueLable := TargetLable(loc)
    curMethod.code.add(continueLable)
    condJump := JumpStmt(loc, CallExpr.makeWithMethod(loc, ctxCls.methodDef("next"), lvar))
    curMethod.code.add(condJump)
    //continue
    jmp := JumpStmt.makeGoto(loc)
    jmp.target = continueLable
    curMethod.code.add(jmp)
    //end
    condJump.target := TargetLable(loc)
    curMethod.code.add(condJump.target)
    
    //  return ctx.get
    retStmt := ReturnStmt.make(loc, CallExpr.makeWithMethod(loc, ctxCls.methodDef("get"), lvar))
    curMethod.code.add(retStmt)
    */
    thr := ThrowStmt(loc,
      CallExpr.makeWithMethod(loc, null, ns.errType.method("make"),
        [Expr.makeForLiteral(loc, ns, "Cant call async method directly")])
      )
    curMethod.code.add(thr)
  }

//////////////////////////////////////////////////////////////////////////
// Remove Local Var
//////////////////////////////////////////////////////////////////////////

  private Void removeLocalVar() {
    implMethod.code.stmts.each |stmt, i| {
      if (stmt.id === StmtId.localDef) {
        implMethod.code.stmts[i] = replaceLocalDef(stmt)
      }
    }

    implMethod.code.walkExpr |expr|
    {
      expr.id === ExprId.localVar ? replaceLocalVar(expr) : expr
    }
  }

  private Stmt replaceLocalDef(LocalDefStmt stmt)
  {
    if (stmt.init == null)
      return NopStmt(stmt.loc)

    Expr? init = ((BinaryExpr)stmt.init).rhs
    // ctx.var1 = initExpr
    s := BinaryExpr.makeAssign(
           LocalVarExpr(loc, implMethod.vars.first),
           init
         )
    return s.toStmt
  }
  
  private Expr fieldExpr(Loc loc, Str name) {
    field := ctxCls.fieldDef(name)
    return FieldExpr(loc, LocalVarExpr(loc, implMethod.vars.first), field, false)
  }

  private Expr replaceLocalVar(LocalVarExpr local)
  {
    var := local.var
    return fieldExpr(local.loc, "var_"+var.name)
  }


//////////////////////////////////////////////////////////////////////////
// Gen Switch
//////////////////////////////////////////////////////////////////////////

  private Void genSwitch() {
    Stmt[] stmts := [,]
    count := 0
    breakLabel := TargetLabel(loc)

    table := SwitchTable(loc, fieldExpr(loc, "state"))
    stmts.add(table)

    label := TargetLabel(loc)
    stmts.add(label)
    table.jumps[count] = label

    implMethod.code.stmts.each |stmt| {
      if (stmt.id === StmtId.expr) {
        ExprStmt exprStmt := stmt
        if (exprStmt.expr.id === ExprId.assign) {
          BinaryExpr assignExpr := exprStmt.expr
          if (assignExpr.rhs.id === ExprId.yieldExpr) {
              YieldExpr c := assignExpr.rhs
              genYield(count, c.expr, breakLabel, table, stmts)

              //ctx.var1 = ctx.result
              resField := fieldExpr(stmt.loc, "result")
              assignExpr.rhs = TypeCheckExpr.coerce(resField, assignExpr.lhs.ctype)
              stmts.add(assignExpr.toStmt)
              return
          }
        }
        else if (exprStmt.expr.id == ExprId.yieldExpr) {
          YieldExpr c := exprStmt.expr
          genYield(count, c.expr, breakLabel, table, stmts)
          return
        }
      }
      stmts.add(stmt)
    }
    stmts.add(breakLabel)
    implMethod.code.stmts = stmts
  }

  private Void genYield(Int count, Expr c, TargetLabel breakLabel, SwitchTable table, Stmt[] stmts) {
    //ctx.yieldObj = foo_()
    if (c.id == ExprId.call) {
      ((CallExpr)c).method = curType.methodDef(name+"_")
    }
    setRes := BinaryExpr.makeAssign(fieldExpr(c.loc, "yieldObj"), c)
    stmts.add(setRes.toStmt)

    //ctx.state = 3
    setState := BinaryExpr.makeAssign(fieldExpr(c.loc, "state")
        , Expr.makeForLiteral(c.loc, ns, count+1))
    stmts.add(setState.toStmt)

    //break
    jump := JumpStmt.makeGoto(c.loc)
    jump.target = breakLabel
    stmts.add(jump)

    //next block
    ++count
    label := TargetLabel(c.loc)
    stmts.add(label)
    table.jumps[count] = label
  }
}
