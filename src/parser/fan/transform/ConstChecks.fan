//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//    9 Apr 09  Brian Frank  Creation
//   23 Mar 10  Brian Frank  FieldNotSetErr checks
//

**
** ConstChecks adds hooks into constructors and it-blocks
** to ensure that an attempt to set a const field will throw
** ConstErr if not in the objects constructor.  We also use
** this step to insert the runtime checks for non-nullable fields.
**
** For each it-block which sets const fields:
**
**   doCall(Foo it)
**   {
**     this.checkInCtor(it)
**     ...
**   }
**
** For each constructor which takes an it-block:
**
**   new make(..., |This| f)
**   {
**     f?.enterCtor(this)
**     ...
**     checksField$Foo()  // if non-nullable fields need runtime checks
**     f?.exitCtor()      // for every return
**     return
**   }
**
**
class ConstChecks : CompilerStep
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
    //log.debug("ConstChecks")

    // walk all the closures
    //compiler.closures.each |ClosureExpr c| { processClosure(c) }

    // walk all the types
    compiler.pod.types.each |TypeDef t|
    {
      if (t.isNative) return
      this.curType = t

      // get all the fields which require runtime checks, and if there
      // are any, then generate a fieldCheck method to call on ctor exit
      this.fieldCheck = genFieldCheck(t)

      // walk all the constructors
      t.ctorDefs.each |MethodDef ctor| { processCtor(ctor) }
    }
  }

//////////////////////////////////////////////////////////////////////////
// Process Closure
//////////////////////////////////////////////////////////////////////////
/*
  private Void processClosure(ClosureExpr c)
  {
    // don't process anything but it-blocks which use const fields
    if (!c.isItBlock || !c.setsConst) return

    // add inCtor check
    loc := c.loc
    check := CallExpr.makeWithMethod(loc, ThisExpr(loc), ns.funcCheckInCtor, [ItExpr(loc)])
    check.noLeave
    c.doCall.code.stmts.insert(0, check.toStmt)
  }
*/
//////////////////////////////////////////////////////////////////////////
// Process Constructor
//////////////////////////////////////////////////////////////////////////

  private Void processCtor(MethodDef ctor)
  {
    // don't process static constructors
    if (ctor.isStatic) return

    // set current state
    this.curCtor = ctor

    // add func?.enterCtor(this)
    // if (ctor.isItBlockCtor)
    // {
    //   loc := ctor.loc
    //   enter := CallExpr.makeWithMethod(loc, LocalVarExpr(loc, itBlockVar), ns.funcEnterCtor, [ThisExpr(loc)])
    //   enter.isSafe = true
    //   enter.noLeave
    //   ctor.code.stmts.insert(0, enter.toStmt)
    // }

    // walk all the statements and insert exitCtor before each return
    if (ctor.isItBlockCtor || fieldCheck != null)
      ctor.code.walk(this, VisitDepth.stmt)
  }

  override Stmt[]? visitStmt(Stmt stmt)
  {
    if (stmt.id !== StmtId.returnStmt) return null
    loc := stmt.loc
    result := Stmt[,]

    // insert call to func?.exitCtor()
    // if (curCtor.isItBlockCtor)
    // {
    //   exit1 := CallExpr.makeWithMethod(loc, LocalVarExpr(loc, itBlockVar), ns.funcExitCtor)
    //   exit1.isSafe = true
    //   exit1.noLeave
    //   result.add(exit1.toStmt)
    // }

    // if needed insert call to this.fieldCheck()
    if (fieldCheck != null)
    {
      exit2 := CallExpr.makeWithMethod(loc, ThisExpr(loc), fieldCheck)
      exit2.noLeave
      result.add(exit2.toStmt)
    }

    return result.add(stmt)
  }

  //private MethodVar itBlockVar() { curCtor.vars[curCtor.params.size-1] }

  private MethodDef? genFieldCheck(TypeDef t)
  {
    // find any fields which were marked as requiring a
    // runtime check during the CheckErrors step
    checkedFields := t.fieldDefs.findAll |f| { f.requiresNullCheck  }
    if (checkedFields.isEmpty) return null

    // add check for each field which requires runtime null check
    loc := t.loc
    block := Block(loc)
    checkedFields.each |FieldDef f|
    {
      // field == null
      condExpr := UnaryExpr(loc, ExprId.cmpNull, Token.same,
                            FieldExpr(loc, ThisExpr(loc), f, false))

      // throw FieldNotSet(f.qname)
      throwExpr := ThrowStmt(loc, CallExpr.makeWithMethod(loc, null, ns.fieldNotSetErrMake,
                             [LiteralExpr.makeStr(loc, f.qname)]))

      // if (condExpr) throwExpr
      trueBlock := Block(loc)
      trueBlock.stmts.add(throwExpr)
      block.stmts.add(IfStmt(loc, condExpr, trueBlock))
    }
    block.stmts.add(ReturnStmt.makeSynthetic(loc))

    // create checkFields method
    m := MethodDef(loc, t)
    m.flags = FConst.Private.or(FConst.Synthetic)
    m.name  = "checkFields\$" + t.name
    m.ret   = ns.voidType
    m.code  = block
    t.addSlot(m)
    return m
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  MethodDef? curCtor
  MethodDef? fieldCheck
}