//
// Copyright (c) 2019, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2019-01-19  Jed Young Creation
//


class StmtFlatLoop {
  TargetLabel continueLabel
  TargetLabel breakLabel
  Stmt stmt
  ExceptionRegion[] protectedRegions := ExceptionRegion[,] // stack
  
  new make(Stmt stmt) {
    this.stmt = stmt
    continueLabel = TargetLabel(stmt.loc)
    breakLabel = TargetLabel(stmt.loc)
  }
}

class StmtFlat : CompilerStep
{
  private Stmt[] stmts := [,]
  private StmtFlatLoop[] loopStack := [,]
  private ExceptionRegion[]? protectedRegions // stack of protection regions
  
  new make(Compiler compiler)
    : super(compiler)
  {
  }

  override Void run()
  {
    log.debug("StmtDecom")
    walk(compiler, VisitDepth.slotDef)
    bombIfErr
  }

  override Void visitMethodDef(MethodDef def) {
    if (def.code == null) return
    stmts.clear
    loopStack.clear
    protectedRegions = null
    block(def.code)
    def.code.stmts = stmts.dup
  }

  private Void block(Block block)
  {
    block.stmts.each |Stmt s| { stmt(s) }
  }

  private Void stmt(Stmt stmt)
  {
    switch (stmt.id)
    {
      case StmtId.nop:           return
      case StmtId.expr:          expr(((ExprStmt)stmt))
      case StmtId.localDef:      localVarDefStmt((LocalDefStmt)stmt)
      case StmtId.ifStmt:        ifStmt((IfStmt)stmt)
      case StmtId.returnStmt:    returnStmt((ReturnStmt)stmt)
      case StmtId.throwStmt:     throwStmt((ThrowStmt)stmt)
      case StmtId.forStmt:       forStmt((ForStmt)stmt)
      case StmtId.whileStmt:     whileStmt((WhileStmt)stmt)
      case StmtId.breakStmt:     breakOrContinueStmt(stmt)
      case StmtId.continueStmt:  breakOrContinueStmt(stmt)
      case StmtId.switchStmt:    switchStmt((SwitchStmt)stmt)
      case StmtId.tryStmt:       tryStmt((TryStmt)stmt)
      default:                   throw Err(stmt.id.toStr)
    }
  }
  
  private Void addStmt(Stmt stmt) {
    stmts.add(stmt)
  }
  
  private Expr toTempVar(Expr expr) {
    var := curMethod.addLocalVar(expr.ctype, null, null)
    lvar := LocalVarExpr(expr.loc, var)
    assign := BinaryExpr.makeAssign(lvar, expr)
    addStmt(assign.toStmt)
    return lvar
  }
  
  private TargetLabel jumpTo(Loc loc, Expr? condition) {
    jump := JumpStmt(loc, condition)
    jump.target = TargetLabel(loc)
    addStmt(jump)
    return jump.target
  }
  
  private Void expr(ExprStmt expr) {
    addStmt(expr)
  }

  private Void ifStmt(IfStmt stmt)
  {
    jmpFalse := jumpTo(stmt.loc, stmt.condition)
    
    block(stmt.trueBlock)
    
    TargetLabel? jmpEnd
    if (stmt.falseBlock != null) {
      jmpEnd = jumpTo(stmt.loc, null)
    }
    
    addStmt(jmpFalse)
        
    if (stmt.falseBlock != null) {

      block(stmt.falseBlock)
      
      addStmt(jmpEnd)
    }
  }

  private Void returnStmt(ReturnStmt stmt) { 
    // if we are in a protected region, then we can't return immediately,
    // rather we need to save the result into a temporary local; and use
    // a "leave" instruction which we will backpatch in finishCode() with
    // the actual return sequence;
    if (inProtectedRegion)
    {
      if (stmt.expr != null) {
        stmt.expr = toTempVar(stmt.expr)
      }

      // jump to any finally blocks we are inside
      protectedRegions.eachr |ExceptionRegion region|
      {
        if (region.hasFinally)
          inlineFinally(region)
      }

      addStmt(stmt)
      return
    }
    addStmt(stmt)
  }

  private Void throwStmt(ThrowStmt stmt) { addStmt(stmt) }

  private Void localVarDefStmt(LocalDefStmt stmt) { addStmt(stmt) }
  
//////////////////////////////////////////////////////////////////////////
// Loops
//////////////////////////////////////////////////////////////////////////

  private Void whileStmt(WhileStmt stmt)
  {
    // push myself onto the loop stack so that breaks
    // and continues can register for backpatching
    loop := StmtFlatLoop(stmt)
    loopStack.push(loop)
    
    addStmt(loop.continueLabel)
    
    jmp := JumpStmt(stmt.loc, stmt.condition)
    jmp.target = loop.breakLabel
    addStmt(jmp)
    
    block(stmt.block)
    
    jmpCont := JumpStmt.makeGoto(stmt.loc)
    jmpCont.target = loop.continueLabel
    addStmt(jmpCont)
    
    
    addStmt(loop.breakLabel)

    // pop loop from stack
    loopStack.pop
  }

  private Void forStmt(ForStmt stmt)
  {
    // push myself onto the loop stack so that breaks
    // and continues can register for backpatching
    loop := StmtFlatLoop(stmt)
    loopStack.push(loop)

    // assemble init if available
    if (stmt.init != null) this.stmt(stmt.init)
    
    condLabel := TargetLabel(stmt.loc)
    addStmt(condLabel)

    // assemble the for loop code
    if (stmt.condition != null)
    {
      jmp := JumpStmt(stmt.loc, stmt.condition)
      jmp.target = loop.breakLabel
      addStmt(jmp)
    }
    
    block(stmt.block)
    
    addStmt(loop.continueLabel)
    if (stmt.update != null) addStmt(stmt.update.toStmt)
    
    jmpCond := JumpStmt.makeGoto(stmt.loc)
    jmpCond.target = condLabel
    addStmt(jmpCond)
    
    addStmt(loop.breakLabel)
    
    // pop loop from stack
    loopStack.pop
  }
  
  private Void inlineFinally(ExceptionRegion region) {
    block(region.stmt.finallyBlock)
  }

  private Void breakOrContinueStmt(Stmt stmt)
  {
    // associated loop should be top of stack
    loop := loopStack.peek
    if (loop.stmt !== stmt->loop)
      throw err("Internal compiler error", stmt.loc)
    
    jmp := JumpStmt.makeGoto(stmt.loc)

    // if we are inside a protection region which was pushed onto
    // my loop's own stack that means this break or continue
    // needs to jump out of the protected region - that requires
    // calling each region's finally block and using a "leave"
    // instruction rather than a standard "jump"
    if (!loop.protectedRegions.isEmpty)
    {
      // jump to any finally blocks we are inside
      loop.protectedRegions.eachr |ExceptionRegion region|
      {
        if (region.hasFinally) inlineFinally(region)
      }
      jmp.isLeave = true;
    }
    
    // register for backpatch
    if (stmt.id === StmtId.breakStmt)
      jmp.target = loop.breakLabel
    else
      jmp.target = loop.continueLabel
    addStmt(jmp)
  }

//////////////////////////////////////////////////////////////////////////
// Switch
//////////////////////////////////////////////////////////////////////////

  private Void switchStmt(SwitchStmt stmt)
  {
    // A table switch is a series of contiguous (or near contiguous)
    // cases which can be represented an offset into a jump table.
    minMax := computeTableRange(stmt)
    if (minMax != null && (curMethod.flags.and(FConst.Async)) == 0)
      tableSwitchStmt(stmt, minMax[0], minMax[1])
    else
      equalsSwitchStmt(stmt)
  }

  **
  ** Compute the range of this switch and return as a list of '[min, max]'
  ** if the switch is a candidate for a table switch as a series of
  ** contiguous (or near contiguous) cases which can be represented an
  ** offset into a jump table.  Return null if the switch is not numeric
  ** or too sparse to use as a table switch.
  **
  private Int[]? computeTableRange(SwitchStmt stmt)
  {
    // we only compute ranges for Ints and Enums
    ctype := stmt.condition.ctype
    if (!ctype.isInt && !ctype.isEnum)
      return null

    // now we need to determine contiguous range
    min := 2147483647
    max := -2147483648
    count := 0
    try
    {
      stmt.cases.each |Case c|
      {
        for (i:=0; i<c.cases.size; ++i)
        {
          count++
          expr := c.cases[i]
          // TODO: need to handle static const Int fields here
          literal := expr.asTableSwitchCase
          if (literal == null) throw CompilerErr("return null", c.loc)
          if (literal < min) min = literal
          if (literal > max) max = literal
        }
      }
    }
    catch (CompilerErr e)
    {
      return null
    }

    // if no cases, then don't use tableswitch
    if (count == 0) return null

    // enums and anything with less than 32 jumps is immediately
    // allowed, otherwise base the table on a percentage of count
    delta := max - min
    if (ctype.isEnum || delta < 32 || count*32 > delta)
      return [min,max]
    else
      return null
  }

  private Void tableSwitchStmt(SwitchStmt stmt, Int min, Int max)
  {
    stmt.isTableswitch = true
    conditionType := stmt.condition.ctype
    isEnum := conditionType.isEnum
    condLoc := stmt.condition.loc

    // push condition onto the stack
    condExpr := stmt.condition

    // get a real int onto the stack
    if (conditionType.isInt && conditionType.isNullable) {
      condExpr = TypeCheckExpr.coerce(condExpr, ns.intType)
    }
    else if (isEnum) {
      condExpr = CallExpr.makeWithMethod(condLoc, stmt.condition, ns.enumOrdinal)
    }
    
    // if min is not zero, then do a subtraction so that
    // our condition is a zero based index into the jump table
    if (min != 0)
    {
      condExpr = CallExpr.makeWithMethod(condLoc, condExpr, ns.intPlus,
          [Expr.makeForLiteral(condLoc, ns, -min)]
        )
    }
    
    // now allocate our jump table
    count := max - min + 1
    condition := toTempVar(condExpr)
    table := SwitchTable(stmt.loc, condition)
    table.jumps.size = count
    addStmt(table)

    // walk thru each case, and map the jump offset to a block
    stmt.cases.each |Case c|
    {
      for (i:=0; i<c.cases.size; ++i)
      {
        expr    := c.cases[i]
        literal := expr.asTableSwitchCase
        offset  := literal - min
        
        label := TargetLabel(c.loc)
        addStmt(label)
        table.jumps[offset] = label
        
        block(c.block)
      }
    }
    
    if (stmt.defaultBlock != null) {
      label := TargetLabel(stmt.defaultBlock.loc)
      addStmt(label)
      table.defJump = label
      
      block(stmt.defaultBlock)
    }
  }

  private Void equalsSwitchStmt(SwitchStmt stmt)
  {
    stmt.isTableswitch = false
    
    condition := toTempVar(stmt.condition)
    endLabel := TargetLabel(stmt.loc)

    // walk thru each case, keeping track of all the
    // places we need to backpatch when cases match
    stmt.cases.each |Case c|
    {
      for (i:=0; i<c.cases.size; ++i)
      {
        expr := ShortcutExpr.makeBinary(condition, Token.eq, c.cases[i])
        falseLable := jumpTo(c.loc, expr)
        block(c.block)
        
        //default break stmt
        jmp := JumpStmt.makeGoto(c.loc)
        jmp.target = endLabel
        addStmt(jmp)
        
        addStmt(falseLable)
      }
    }
    
    if (stmt.defaultBlock != null) {
      block(stmt.defaultBlock)
    }
    
    addStmt(endLabel)
  }

//////////////////////////////////////////////////////////////////////////
// Try
//////////////////////////////////////////////////////////////////////////

  private Bool inProtectedRegion()
  {
    return protectedRegions != null && !protectedRegions.isEmpty
  }

  private Void tryStmt(TryStmt stmt)
  {
    exception := ExceptionRegion(stmt.loc, stmt)
    // enter a "protected region" which means that we can't
    // jump or return out of this region directly - we have to
    // use a special "leave" jump of the protected region
    if (protectedRegions == null) protectedRegions = ExceptionRegion[,]
    protectedRegions.push(exception)
    if (!loopStack.isEmpty) loopStack.peek.protectedRegions.push(exception)

    // assemble body of try block
    addStmt(exception)
    addStmt(exception.tryStart)
    block(stmt.block)
    addStmt(exception.tryEnd)

    // if the block isn't guaranteed to exit:
    //  1) if we have a finally, then jump to finally
    //  2) jump over catch blocks
    if (!stmt.block.isExit)
    {
      if (exception.hasFinally)
      {
        inlineFinally(exception)
      }
      jmp := JumpStmt.makeGoto(stmt.loc)
      jmp.target = exception.exceptionEnd
      jmp.isLeave = true
      addStmt(jmp)
    }

    // assemble catch blocks
    stmt.catches.each |Catch c, Int i|
    {
      handler := ExceptionHandler(c.loc, ExceptionHandler.typeCatch)
      handler.errType = c.errType
      addStmt(handler.pos)
      addStmt(handler)
      block(c.block)
      exception.catchs.add(handler)
      
      if (!c.block.isExit)
      {
        if (exception.hasFinally)
          inlineFinally(exception)
        jmp := JumpStmt.makeGoto(c.loc)
        jmp.target = exception.exceptionEnd
        jmp.isLeave = true
        addStmt(jmp)
      }
    }

    // assemble finally block
    if (exception.hasFinally)
    {
      finallyStart := ExceptionHandler(stmt.finallyBlock.loc, ExceptionHandler.typeFinallyStart)
      addStmt(finallyStart.pos)
      addStmt(finallyStart)
      block(stmt.finallyBlock)
      exception.finallyStart = finallyStart
      
      finallyEnd := ExceptionHandler(stmt.finallyBlock.loc, ExceptionHandler.typeFinallyEnd)
      addStmt(finallyEnd.pos)
      addStmt(finallyEnd)
    }
    
    addStmt(exception.exceptionEnd)

    // leave protected region
    if (!loopStack.isEmpty) loopStack.peek.protectedRegions.pop
    protectedRegions.pop
  }

}