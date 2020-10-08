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
    s4 := await expr
    s5
    s6
    return x
  }

trans to =>

  class Async$foo : concurrent::Async<T> {
    Type self

    Type param1
    Type var1
    Type var2
    
    new make(Type param1) { this.param1 = param1 }

    protected Bool nextStep() {
      self.foo$async(this)
      return this.state != -1
    }
  }

  Asyc<Type> foo(p1) {
    return foo_(p1).start
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
         v := expr
         ctx.sate = 1
         if (ctx.waitFor(v)) break
      case 1:
         s4 := ctx.awaitRes
         if (ctx.err != null) { tmpErr = ctx.err; ctx.err = null; throw tmpErr; }
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
class GenAsync : CompilerStep {
  
  private TypeDef? ctxCls //context class
  private CType? asyncCls
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
    log.debug("GenAsync")
    walk(compiler, VisitDepth.slotDef)
    bombIfErr
  }
  
  override Void visitMethodDef(MethodDef def) {
    if ((curMethod.flags.and(FConst.Async)) == 0) return

    loc = def.loc
    name = def.name
    isStatic = def.isStatic

    if (isStatic) throw err("Unsupport static async")
    
    process
    //curType.dump
  }

//////////////////////////////////////////////////////////////////////////
// Process
//////////////////////////////////////////////////////////////////////////

  private Void process()
  {
    if (curMethod.code == null) {
      genAbstractMethod
      return
    }
    
    genCtx
    genAsyncMethod
    
    genCtor
    genInternalMethod
    
    genNext
    //genGet

    genExportMethod

    removeLocalVar
    genSwitch
  }


  private Void genCtx()
  {
    asyncCls = ParameterizedType.create(ns.asyncType, [curMethod.returnType])
    ctxCls = TypeDef(ns, loc, curUnit, "Async\$"+curType.name+"\$"+name)
    ctxCls.flags   = FConst.Internal + FConst.Final + FConst.Synthetic
    ctxCls.base    = asyncCls
    addTypeDef(ctxCls)

    addField(curType, "self")

    curMethod.vars.each |v| {
      addField(v.ctype, "var_" + v.name)
    }
  }

  private Void addField(CType ctype, Str name) {
    // define storage field on closure class
    if (ctype.isVoid) ctype = ns.objType.toNullable
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

    ctor.ctorChain = CallExpr(curType.loc, SuperExpr(curType.loc), asyncCls.method("make"))
    ctor.ctorChain.isCtorChain = true

    //self param
    if (!isStatic) {
      field := ctxCls.fieldDef("self")
      s := ExprStmt(
         BinaryExpr.makeAssign(
           FieldExpr(loc, ThisExpr(loc, curType), field, false),
           LocalVarExpr(loc, ctor.addParamVar(field.fieldType, field.name))
         )
      )
      ctor.code.stmts.add(s)
    }

    curMethod.paramDefs.each |param| {
      field := ctxCls.fieldDef("var_"+param.name)
      s := ExprStmt(
         BinaryExpr.makeAssign(
           FieldExpr(loc, ThisExpr(loc, curType), field, false),
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
    m.name  = "nextStep"
    m.flags = FConst.Protected + FConst.Synthetic + FConst.Override
    m.ret = ns.boolType
    m.code = Block(loc)
    ctxCls.addSlot(m)

    //self.foo$async(this)
    field := ctxCls.field("self")
    fieldE := FieldExpr(loc, ThisExpr(loc, curType), field, false)
    cs := CallExpr.makeWithMethod(loc, fieldE, implMethod, [ThisExpr(loc, ctxCls)])
    m.code.add(cs.toStmt)
    
    //return this.state != -1
    field2 := asyncCls.field("state")
    field2E := FieldExpr(loc, ThisExpr(loc, curType), field2, false)
    cmp := ShortcutExpr.makeBinary(
            field2E,
            Token.notEq,
            LiteralExpr(loc, ExprId.intLiteral, ns.intType, -1)
          )
    cmp.ctype = ns.boolType
    s := ReturnStmt.make(loc, cmp)
    m.code.add(s)
  }
  
  private Void genAsyncMethod()
  {
    doCall := MethodDef(loc, curType)
    doCall.name  = name+"\$async"
    doCall.flags = FConst.Internal + FConst.Synthetic
    if (isStatic) doCall.flags += FConst.Static
    doCall.ret = ns.voidType
    //doCall.paramDefs = [ParamDef(loc, ctxCls, "async\$ctx")]
    doCall.addParamVar(ctxCls, "\$ctx")
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
    doCall.ret = asyncCls
    doCall.paramDefs = curMethod.paramDefs.dup
    doCall.code = Block(loc)
    curType.addSlot(doCall)
    
    Expr[]? args := Expr[,]
    if (!isStatic) {
      args.add(ThisExpr(loc, curType))
    }

    if (doCall.paramDefs.size > 0) {
      doCall.paramDefs.each |param| {
        var_v := MethodVar.makeForParam(doCall, doCall.vars.size+1, param, param.paramType)
        doCall.vars.add(var_v)
        lvar := LocalVarExpr(loc, var_v)
        args.add(lvar)
      }
    }
    cs := CallExpr.makeWithMethod(loc, null, ctxCls.method("make"), args)
    doCall.code.add(ReturnStmt.make(loc, cs))
  }

  private Void genAbstractMethod() {
    asyncCls = ParameterizedType.create(ns.asyncType, [curMethod.returnType])
    curMethod.ret = asyncCls
    curMethod.inheritedRet = null
  }
  
  private Void genExportMethod() {
    implMethod.code = curMethod.code
    curMethod.ret = asyncCls
    curMethod.inheritedRet = null
    curMethod.code = Block(loc)
    curMethod.vars.clear
    
    Expr[]? args
    if (curMethod.paramDefs.size > 0) {
      args = Expr[,]
      curMethod.paramDefs.each |param| {
        var_v := MethodVar.makeForParam(curMethod, curMethod.vars.size+1, param, param.paramType)
        curMethod.vars.add(var_v)
        lvar := LocalVarExpr(loc, var_v)
        args.add(lvar)
      }
    }
    
    //return foo_(p1).start
    internalMethod := curType.methodDef(name+"_")
    ctx := CallExpr.makeWithMethod(loc, ThisExpr(loc, curType), internalMethod, args)
    ctx = CallExpr.makeWithMethod(loc, ctx, asyncCls.method("start"))
    curMethod.code.add(ReturnStmt(loc, ctx))
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
      if (expr.id === ExprId.localVar) return replaceLocalVar(expr)
      else if (expr.id === ExprId.closure) {
        ClosureExpr closure := expr

        closure.substitute = Expr.walkExpr(ExprVisitor(|Expr e->Expr| {
            e.id === ExprId.localVar ? replaceLocalVar(e) : e
          }),
          closure.substitute)
      }
      return expr
    }
  }

  private Stmt replaceLocalDef(LocalDefStmt stmt)
  {
    if (stmt.init == null) {
      if (stmt.isCatchVar) {
        stmt.var_v = implMethod.addLocalVar(stmt.ctype, stmt.name, null)
        return stmt
      }
      return NopStmt(stmt.loc)
    }

    return stmt.init.toStmt
  }
  
  private Expr fieldExpr(Loc loc, Str name) {
    field := ctxCls.field(name)
    if (field == null) field = asyncCls.field(name)
    return FieldExpr(loc, LocalVarExpr(loc, implMethod.vars.first), field, false)
  }

  private Expr replaceLocalVar(LocalVarExpr local)
  {
    var_v := local.var_v
    return fieldExpr(local.loc, "var_"+var_v.name)
  }


//////////////////////////////////////////////////////////////////////////
// Gen Switch
//////////////////////////////////////////////////////////////////////////

  private Void genSwitch() {
    Stmt[] stmts := [,]
    //count := 0
    breakLabel := TargetLabel(loc)

    table := SwitchTable(loc, fieldExpr(loc, "state"))
    stmts.add(table)

    //default goto end
    defJump := JumpStmt.makeGoto(loc)
    defJump.target = breakLabel
    stmts.add(defJump)

    //jump 0
    label := TargetLabel(loc)
    stmts.add(label)
    table.jumps.add(label)

    implMethod.code.stmts.each |stmt| {
      if (stmt.id === StmtId.expr) {
        ExprStmt exprStmt := stmt
        if (exprStmt.expr.id === ExprId.assign) {
          BinaryExpr assignExpr := exprStmt.expr
          if (assignExpr.rhs.id === ExprId.awaitExpr) {
              AwaitExpr c := assignExpr.rhs
              genYield(c.expr, breakLabel, table, stmts)

              //if (ctx.err != null) throw Err()
              genCheckErr(stmts, stmt.loc)

              //ctx.var1 = ctx.awaitRes
              resField := fieldExpr(stmt.loc, "awaitRes")
              assignExpr.rhs = TypeCheckExpr.coerce(resField, assignExpr.lhs.ctype)
              stmts.add(assignExpr.toStmt)

              return
          }
        }
        else if (exprStmt.expr.id == ExprId.awaitExpr) {
          AwaitExpr c := exprStmt.expr
          genYield(c.expr, breakLabel, table, stmts)

          //if (ctx.err != null) throw Err()
          genCheckErr(stmts, stmt.loc)
          return
        }
      }
      else if (stmt.id === StmtId.returnStmt) {
        ReturnStmt retStmt := stmt

        //ctx.state = -1
        setState := BinaryExpr.makeAssign(fieldExpr(stmt.loc, "state")
            , Expr.makeForLiteral(stmt.loc, ns, -1))
        stmts.add(setState.toStmt)

        if (retStmt.expr != null) {
          //ctx.result = expr
          setRes := BinaryExpr.makeAssign(fieldExpr(stmt.loc, "result"), 
              TypeCheckExpr.coerce(retStmt.expr, ns.objType.toNullable))
          stmts.add(setRes.toStmt)
        }

        //break;
        jump := JumpStmt.makeGoto(stmt.loc)
        jump.target = breakLabel
        stmts.add(jump)
        return
      }
      else if (stmt.id === StmtId.localDef) {
        //catch var
        LocalDefStmt defStmt := stmt
        if (!defStmt.isCatchVar) throw Err("Must catch var")
        stmts.add(stmt)
        lvar := LocalVarExpr(stmt.loc, defStmt.var_v)
        store := BinaryExpr.makeAssign(fieldExpr(stmt.loc, "var_"+defStmt.name), lvar)
        stmts.add(store.toStmt)
        return
      }
      stmts.add(stmt)
    }
    stmts.add(breakLabel)
    implMethod.code.stmts = stmts
  }

  private Void genCheckErr(Stmt[] stmts, Loc loc) {
    //if (ctx.err != null) { tmpErr = ctx.err; ctx.err = null; throw tmpErr; }
    err := fieldExpr(loc, "err")
    cmp := ShortcutExpr.makeBinary(
            err,
            Token.notEq,
            LiteralExpr.makeNull(loc, ns)
          )
    cmp.ctype = ns.boolType
    jump := JumpStmt(loc, cmp)
    jump.target = TargetLabel(loc)
    stmts.add(jump)

    //tmpErr = ctx.err
    var_v := implMethod.addLocalVar(ns.errType, "tmpErr", null)
    lvar := LocalVarExpr(loc, var_v)
    storeTmp := BinaryExpr.makeAssign(lvar, err)
    stmts.add(storeTmp.toStmt)

    ///ctx.err = null
    store := BinaryExpr.makeAssign(err, LiteralExpr.makeNull(loc, ns))
    stmts.add(store.toStmt)

    //throw tmpErr
    stmts.add(ThrowStmt(loc, lvar))
    stmts.add(jump.target)
  }

  private Void genYield(Expr c, TargetLabel breakLabel, SwitchTable table, Stmt[] stmts) {
    //ctx.state = 3
    setState := BinaryExpr.makeAssign(fieldExpr(c.loc, "state")
        , Expr.makeForLiteral(c.loc, ns, table.jumps.size))
    stmts.add(setState.toStmt)

    //ctx.waitFor(foo_())
    arg := TypeCheckExpr.coerce(c, ns.objType.toNullable)
    ctx := LocalVarExpr(loc, implMethod.vars.first)
    awaitForExpr := CallExpr.makeWithMethod(loc, ctx, asyncCls.method("waitFor"), [arg])

    //if (ctx.waitFor(v) break
    jump0 := JumpStmt(loc, awaitForExpr)
    jump0.ifFalse = false
    jump0.target = breakLabel
    stmts.add(jump0)

    //next block
    nextBlockLabel := TargetLabel(c.loc)
    stmts.add(nextBlockLabel)
    table.jumps.add(nextBlockLabel)
  }
}
