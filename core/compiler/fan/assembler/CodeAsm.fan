//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//

**
** CodeAsm is used to assemble the fcode instructions of an Expr or Block.
**
class CodeAsm : CompilerSupport
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  new make(Compiler compiler, Loc loc, FPod fpod, MethodDef? curMethod)
    : super(compiler)
  {
    this.loc       = loc
    this.fpod      = fpod
    this.curMethod = curMethod
    this.code      = Buf.make
    this.errTable  = Buf.make; errTable.writeI2(-1)
    this.errCount  = 0
    this.lines     = Buf.make; lines.writeI2(-1)
    this.lineCount = 0
    this.loopStack = Loop[,]
  }

//////////////////////////////////////////////////////////////////////////
// Statements
//////////////////////////////////////////////////////////////////////////

  Void block(Block block)
  {
    block.stmts.each |Stmt s| { stmt(s) }
  }

  Void stmt(Stmt stmt)
  {
    switch (stmt.id)
    {
      case StmtId.nop:           return
      case StmtId.expr:          expr(((ExprStmt)stmt).expr)
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

  private Void ifStmt(IfStmt stmt)
  {
    endLabel := -1
    c := Cond.make

    // optimize: if (true)
    if (stmt.condition.id == ExprId.trueLiteral)
    {
      block(stmt.trueBlock)
      return
    }

    // optimize: if (false)
    if (stmt.condition.id == ExprId.falseLiteral)
    {
      if (stmt.falseBlock != null)
        block(stmt.falseBlock)
      return
    }

    // check condition - if the condition is itself a CondExpr
    // then we just have it branch directly to the true/false
    // block rather than wasting instructions to push true/false
    // onto the stack
    if (stmt.condition is CondExpr)
    {
      cond((CondExpr)stmt.condition, c)
    }
    else
    {
      expr(stmt.condition)
      c.jumpFalses.add(jump(FOp.JumpFalse))
    }

    // true block
    c.jumpTrues.each |Int pos| { backpatch(pos) }
    block(stmt.trueBlock)
    if (!stmt.trueBlock.isExit && stmt.falseBlock != null)
      endLabel = jump(FOp.Jump)

    // false block
    c.jumpFalses.each |Int pos| { backpatch(pos) }
    if (stmt.falseBlock != null)
      block(stmt.falseBlock)

    // end
    if (endLabel != -1) backpatch(endLabel)
  }

  private Void returnStmt(ReturnStmt stmt)
  {
    // if we have a expression
    exprOnStack := false
    if (stmt.expr != null)
    {
      // evaluate expr
      expr(stmt.expr)

      // unless expr was void, we have it on the stack now
      exprOnStack = !stmt.expr.ctype.isVoid

      // if we have expr on stack inside a void method, need to pop it
      inVoidMethod := curMethod != null && curMethod.ret.isVoid
      if (inVoidMethod && exprOnStack)
      {
        opType(FOp.Pop, stmt.expr.ctype)
        exprOnStack = false
      }
    }

    // if we are in a protected region, then we can't return immediately,
    // rather we need to save the result into a temporary local; and use
    // a "leave" instruction which we will backpatch in finishCode() with
    // the actual return sequence;
    if (inProtectedRegion)
    {
      // if returning a result then stash in temp local
      if (exprOnStack)
      {
        returnLocal = stmt.leaveVar
        op(FOp.StoreVar, returnLocal.register)
      }

      // jump to any finally blocks we are inside
      protectedRegions.eachr |ProtectedRegion region|
      {
        if (region.hasFinally)
          region.jumpFinallys.add(jump(FOp.JumpFinally))
      }

      // generate leave instruction and register for backpatch
      if (leavesToReturn == null) leavesToReturn = Int[,]
      leavesToReturn.add(jump(FOp.Leave))
      return
    }

    // process as normal return
    op(FOp.Return)
  }

  private Void throwStmt(ThrowStmt stmt) { throwOp(stmt.exception) }

  private Void throwOp(Expr exception)
  {
    expr(exception)
    op(FOp.Throw)
  }

  private Void localVarDefStmt(LocalDefStmt stmt)
  {
    if (stmt.isCatchVar)
    {
      // "declaration" of a catch variable is used store the
      // variable back to its local register
      var := stmt.var
      op(FOp.CatchErrStart, fpod.addTypeRef(stmt.ctype))

      // if the catch variable has been hoisted onto the heap
      // with a wrapper, call the wrapper constructor
      if (var.isWrapped)
      {
        wrapCtor := fpod.addMethodRef(var.wrapField.parent.method("make"), 1)
        op(FOp.CallNew, wrapCtor)
      }

      // store back to local register
      op(FOp.StoreVar, var.register)
    }
    else if (stmt.init != null)
    {
      expr(stmt.init)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Loops
//////////////////////////////////////////////////////////////////////////

  private Void whileStmt(WhileStmt stmt)
  {
    // push myself onto the loop stack so that breaks
    // and continues can register for backpatching
    loop := Loop(stmt)
    loopStack.push(loop)

    // assemble the while loop code
    continueLabel := mark
    expr(stmt.condition)
    breakJump := jump(FOp.JumpFalse)
    block(stmt.block)
    jump(FOp.Jump, continueLabel)
    breakLabel := mark
    backpatch(breakJump)

    // backpatch continues/breaks
    loop.continues.each |Int pos| { backpatch(pos, continueLabel) }
    loop.breaks.each |Int pos| { backpatch(pos, breakLabel) }

    // pop loop from stack
    loopStack.pop

    // TODO - the fcode will often contain Jumps to Jumps which can be optimized
  }

  private Void forStmt(ForStmt stmt)
  {
    breakJump := -1

    // push myself onto the loop stack so that breaks
    // and continues can register for backpatching
    loop := Loop(stmt)
    loopStack.push(loop)

    // assemble init if available
    if (stmt.init != null) this.stmt(stmt.init)

    // assemble the for loop code
    condLabel := mark
    if (stmt.condition != null)
    {
      expr(stmt.condition)
      breakJump = jump(FOp.JumpFalse)
    }
    block(stmt.block)
    updateLabel := mark
    if (stmt.update != null) expr(stmt.update)
    jump(FOp.Jump, condLabel)
    endLabel := mark
    if (breakJump != -1) backpatch(breakJump, endLabel)

    // backpatch continues/breaks
    loop.continues.each |Int pos| { backpatch(pos, updateLabel) }
    loop.breaks.each |Int pos| { backpatch(pos, endLabel) }

    // pop loop from stack
    loopStack.pop

    // TODO - the fcode will often contain Jumps to Jumps which can be optimized
  }

  private Void breakOrContinueStmt(Stmt stmt)
  {
    // associated loop should be top of stack
    loop := loopStack.peek
    if (loop.stmt !== stmt->loop)
      throw err("Internal compiler error", stmt.loc)

    // if we are inside a protection region which was pushed onto
    // my loop's own stack that means this break or continue
    // needs to jump out of the protected region - that requires
    // calling each region's finally block and using a "leave"
    // instruction rather than a standard "jump"
    Int? toBackpatch := null
    if (!loop.protectedRegions.isEmpty)
    {
      // jump to any finally blocks we are inside
      loop.protectedRegions.eachr |ProtectedRegion region|
      {
        if (region.hasFinally)
          region.jumpFinallys.add(jump(FOp.JumpFinally))
      }

      // generate leave instruction
      toBackpatch = jump(FOp.Leave)
    }
    else
    {
      // generate standard jump instruction
      toBackpatch = jump(FOp.Jump)
    }

    // register for backpatch
    if (stmt.id === StmtId.breakStmt)
      loop.breaks.add(toBackpatch)
    else
      loop.continues.add(toBackpatch)
  }

//////////////////////////////////////////////////////////////////////////
// Switch
//////////////////////////////////////////////////////////////////////////

  private Void switchStmt(SwitchStmt stmt)
  {
    // A table switch is a series of contiguous (or near contiguous)
    // cases which can be represented an offset into a jump table.
    minMax := computeTableRange(stmt)
    if (minMax != null)
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

    // push condition onto the stack
    expr(stmt.condition)

    // get a real int onto the stack
    if (conditionType.isInt && conditionType.isNullable)
      coerceOp(conditionType, ns.intType)
    else if (isEnum)
      op(FOp.CallVirtual, fpod.addMethodRef(ns.enumOrdinal))

    // if min is not zero, then do a subtraction so that
    // our condition is a zero based index into the jump table
    if (min != 0)
    {
      op(FOp.LoadInt, fpod.ints.add(-min))
      op(FOp.CallVirtual, fpod.addMethodRef(ns.intPlus))
    }

    // now allocate our jump table
    count := max - min + 1
    jumps := Case?[,]
    jumps.size = count

    // walk thru each case, and map the jump offset to a block
    stmt.cases.each |Case c|
    {
      for (i:=0; i<c.cases.size; ++i)
      {
        expr    := c.cases[i]
        literal := expr.asTableSwitchCase
        offset  := literal - min
        jumps[offset] = c
      }
    }

    // now write the switch bytecodes
    op(FOp.Switch)
    code.writeI2(count)
    jumpStart := code.size
    fill := count*2
    fill.times |->| { code.write(0xff) }  // we'll backpatch the jump offsets last

    // default block goes first - it's the switch fall
    // thru, save offset to back patch jump
    defaultStart := mark
    defaultEnd := switchBlock(stmt.defaultBlock)

    // now write each case block
    caseEnds := Int?[,]
    caseEnds.size = stmt.cases.size
    stmt.cases.each |Case c, Int i|
    {
      c.startOffset = code.size
      caseEnds[i] = switchBlock(c.block)
    }

    // backpatch the jump table
    end := code.size
    code.seek(jumpStart)
    jumps.each |Case? c, Int i|
    {
      if (c == null)
        code.writeI2(defaultStart)
      else
        code.writeI2(c.startOffset)
    }
    code.seek(end)

    // backpatch all the case blocks to jump here when done
    if (defaultEnd != -1) backpatch(defaultEnd)
    caseEnds.each |Int pos|
    {
      if (pos != -1) backpatch(pos)
    }
  }

  private Void equalsSwitchStmt(SwitchStmt stmt)
  {
    stmt.isTableswitch = false

    // push condition onto the stack
    condition := stmt.condition
    expr(condition)

    // walk thru each case, keeping track of all the
    // places we need to backpatch when cases match
    jumpPositions := Int[,]
    jumpCases := Case[,]
    stmt.cases.each |Case c|
    {
      for (i:=0; i<c.cases.size; ++i)
      {
        opType(FOp.Dup, condition.ctype)
        compareOp(stmt.condition.ctype, FOp.CmpEQ, c.cases[i])
        jumpPositions.add(jump(FOp.JumpTrue))
        jumpCases.add(c)
      }
    }

    // default block goes first - it's the switch fall
    // thru, save offset to back patch jump
    defaultStart := mark
    defaultEnd := switchBlock(stmt.defaultBlock, condition.ctype)

    // now write each case block
    caseEnds := Int?[,]
    caseEnds.size = stmt.cases.size
    stmt.cases.each |Case c, Int i|
    {
      c.startOffset = code.size
      caseEnds[i] = switchBlock(c.block, condition.ctype)
    }

    // backpatch the jump table
    end := code.size
    jumpPositions.each |Int pos, Int i|
    {
      backpatch(pos, jumpCases[i].startOffset)
    }
    code.seek(end)

    // backpatch all the case blocks to jump here when done
    if (defaultEnd != -1) backpatch(defaultEnd)
    caseEnds.each |Int pos|
    {
      if (pos != -1) backpatch(pos)
    }
  }

  private Int switchBlock(Block? block, CType? popType := null)
  {
    if (popType != null) opType(FOp.Pop, popType)
    if (block != null)
    {
      this.block(block)
      if (block.isExit) return -1
    }
    return jump(FOp.Jump)
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
    // enter a "protected region" which means that we can't
    // jump or return out of this region directly - we have to
    // use a special "leave" jump of the protected region
    if (protectedRegions == null) protectedRegions = ProtectedRegion[,]
    region := ProtectedRegion(stmt)
    protectedRegions.push(region)
    if (!loopStack.isEmpty) loopStack.peek.protectedRegions.push(region)

    // assemble body of try block
    start := mark
    block(stmt.block)
    end := mark

    // if the block isn't guaranteed to exit:
    //  1) if we have a finally, then jump to finally
    //  2) jump over catch blocks
    tryDone := -1
    finallyStart := -1
    if (!stmt.block.isExit)
    {
      if (region.hasFinally)
      {
        region.jumpFinallys.add(jump(FOp.JumpFinally))
        end = mark
      }
      tryDone = jump(FOp.Leave)
    }

    // assemble catch blocks
    catchDones := Int?[,]
    catchDones.size = stmt.catches.size
    stmt.catches.each |Catch c, Int i|
    {
      catchDones[i] = tryCatch(c, start, end, region)
    }

    // assemble finally block
    if (region.hasFinally)
    {
      // wrap try block and each catch block with catch all to finally
      addToErrTable(start, end, mark, null)
      stmt.catches.each |Catch c|
      {
        addToErrTable(c.start, c.end, mark, null)
      }

      // handler code
      region.jumpFinallys.each |Int pos| { backpatch(pos) }
      op(FOp.FinallyStart)
      block(stmt.finallyBlock)
      op(FOp.FinallyEnd)
    }

    // mark next statement as jump destination for try block
    if (tryDone != -1) backpatch(tryDone)
    catchDones.each |Int pos| { if (pos != -1) backpatch(pos) }

    // leave protected region
    if (!loopStack.isEmpty) loopStack.peek.protectedRegions.pop
    protectedRegions.pop
  }

  private Int tryCatch(Catch c, Int start, Int end, ProtectedRegion region)
  {
    // assemble catch block - if there isn't a local variable
    // we emit the CatchAllStart, otherwise the block will
    // start off with a LocalVarDef which will write out the
    // CatchErrStart opcode
    handler := mark
    c.start = mark
    if (c.errVariable == null) op(FOp.CatchAllStart)
    block(c.block)
    done := -1
    if (!c.block.isExit)
    {
      if (region.hasFinally)
        region.jumpFinallys.add(jump(FOp.JumpFinally))

      done = jump(FOp.Leave)
    }
    c.end = mark
    op(FOp.CatchEnd)

    // fill in err table
    addToErrTable(start, end, handler, c.errType)

    // return position to backpatch
    return done
  }

  private Void addToErrTable(Int start, Int end, Int handler, CType? errType)
  {
    // catch all is implicitly a catch for sys::Err
    if (errType == null) errType = ns.errType

    // add to err table buffer
    errCount++
    errTable.writeI2(start)
    errTable.writeI2(end)
    errTable.writeI2(handler)
    errTable.writeI2(fpod.addTypeRef(errType))
  }

//////////////////////////////////////////////////////////////////////////
// Expressions
//////////////////////////////////////////////////////////////////////////

  Void expr(Expr expr)
  {
    line(expr.loc)
    switch (expr.id)
    {
      case ExprId.nullLiteral:     nullLiteral
      case ExprId.trueLiteral:
      case ExprId.falseLiteral:    boolLiteral(expr)
      case ExprId.intLiteral:      intLiteral(expr)
      case ExprId.floatLiteral:    floatLiteral(expr)
      case ExprId.decimalLiteral:  decimalLiteral(expr)
      case ExprId.strLiteral:      strLiteral(expr)
      case ExprId.durationLiteral: durationLiteral(expr)
      case ExprId.uriLiteral:      uriLiteral(expr)
      case ExprId.typeLiteral:     typeLiteral(expr)
      case ExprId.slotLiteral:     slotLiteral(expr)
      case ExprId.rangeLiteral:    rangeLiteral(expr)
      case ExprId.listLiteral:     listLiteral(expr)
      case ExprId.mapLiteral:      mapLiteral(expr)
      case ExprId.boolNot:         not(expr)
      case ExprId.cmpNull:         cmpNull(expr)
      case ExprId.cmpNotNull:      cmpNotNull(expr)
      case ExprId.elvis:           elvis(expr)
      case ExprId.assign:          assign(expr)
      case ExprId.same:            same(expr)
      case ExprId.notSame:         notSame(expr)
      case ExprId.boolOr:          or(expr, null)
      case ExprId.boolAnd:         and(expr, null)
      case ExprId.isExpr:          isExpr(expr)
      case ExprId.isnotExpr:       isnotExpr(expr)
      case ExprId.asExpr:          asExpr(expr)
      case ExprId.localVar:
      case ExprId.thisExpr:
      case ExprId.superExpr:
      case ExprId.itExpr:          loadLocalVar(expr)
      case ExprId.call:
      case ExprId.construction:    call(expr)
      case ExprId.shortcut:        shortcut(expr)
      case ExprId.field:           loadField(expr)
      case ExprId.coerce:          coerce(expr)
      case ExprId.closure:         closure(expr)
      case ExprId.ternary:         ternary(expr)
      case ExprId.staticTarget:    return
      case ExprId.throwExpr:       throwOp(((ThrowExpr)expr).exception)
      default:                     throw Err(expr.id.toStr)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Literals
//////////////////////////////////////////////////////////////////////////

  private Void nullLiteral()
  {
    op(FOp.LoadNull)
  }

  private Void boolLiteral(LiteralExpr expr)
  {
    if (expr.val == true)
      op(FOp.LoadTrue)
    else
      op(FOp.LoadFalse)
  }

  private Void intLiteral(LiteralExpr expr)
  {
    op(FOp.LoadInt, fpod.ints.add(expr.val))
  }

  private Void floatLiteral(LiteralExpr expr)
  {
    op(FOp.LoadFloat, fpod.floats.add(expr.val))
  }

  private Void decimalLiteral(LiteralExpr expr)
  {
    op(FOp.LoadDecimal, fpod.decimals.add(expr.val))
  }

  private Void strLiteral(LiteralExpr expr)
  {
    op(FOp.LoadStr, fpod.strs.add(expr.val))
  }

  private Void durationLiteral(LiteralExpr expr)
  {
    op(FOp.LoadDuration, fpod.durations.add(expr.val))
  }

  private Void uriLiteral(LiteralExpr expr)
  {
    op(FOp.LoadUri, fpod.uris.add(expr.val))
  }

  private Void typeLiteral(LiteralExpr expr)
  {
    val := (CType)expr.val
    op(FOp.LoadType, fpod.addTypeRef(val))
  }

  private Void slotLiteral(SlotLiteralExpr expr)
  {
    op(FOp.LoadType, fpod.addTypeRef(expr.parent))
    op(FOp.LoadStr, fpod.strs.add(expr.name))
    if (expr.slot is CField)
      op(FOp.CallStatic, fpod.addMethodRef(ns.typeField, 2))
    else
      op(FOp.CallStatic, fpod.addMethodRef(ns.typeMethod, 2))
  }

  private Void rangeLiteral(RangeLiteralExpr r)
  {
    expr(r.start);
    expr(r.end);
    if (r.exclusive)
      op(FOp.CallNew, fpod.addMethodRef(ns.rangeMakeExclusive))
    else
      op(FOp.CallNew, fpod.addMethodRef(ns.rangeMakeInclusive))
  }

  private Void listLiteral(ListLiteralExpr list)
  {
    t := list.ctype
    if (t is NullableType) t = t->root
    v := ((ListType)t).v

    op(FOp.LoadInt,  fpod.ints.add(list.vals.size))
    op(FOp.LoadType, fpod.addTypeRef(v))
    op(FOp.CallNew,  fpod.addMethodRef(ns.listMake))

    add := fpod.addMethodRef(ns.listAdd)
    for (i:=0; i<list.vals.size; ++i)
    {
      expr(list.vals[i])
      op(FOp.CallVirtual, add)
    }
  }

  private Void mapLiteral(MapLiteralExpr map)
  {
    //op(FOp.LoadType, fpod.addTypeRef(map.ctype))
    op(FOp.LoadInt,  fpod.ints.add(map.keys.size))
    op(FOp.CallNew,  fpod.addMethodRef(ns.mapMake, 1))

    set := fpod.addMethodRef(ns.mapSet)
    for (i:=0; i<map.keys.size; ++i)
    {
      expr(map.keys[i])
      expr(map.vals[i])
      op(FOp.CallVirtual, set)
    }
  }

//////////////////////////////////////////////////////////////////////////
// UnaryExpr
//////////////////////////////////////////////////////////////////////////

  private Void not(UnaryExpr unary)
  {
    expr(unary.operand)
    op(FOp.CallVirtual, fpod.addMethodRef(ns.boolNot))
  }

  private Void cmpNull(UnaryExpr unary)
  {
    expr(unary.operand)
    opType(FOp.CmpNull, unary.operand.ctype)
  }

  private Void cmpNotNull(UnaryExpr unary)
  {
    expr(unary.operand)
    opType(FOp.CmpNotNull, unary.operand.ctype)
  }

//////////////////////////////////////////////////////////////////////////
// BinaryExpr
//////////////////////////////////////////////////////////////////////////

  private Void same(BinaryExpr binary)
  {
    if (binary.lhs.id === ExprId.nullLiteral ||
        binary.rhs.id === ExprId.nullLiteral)
      err("Unexpected use of same with null literals", binary.loc)
    expr(binary.lhs)
    expr(binary.rhs)
    op(FOp.CmpSame)
  }

  private Void notSame(BinaryExpr binary)
  {
    if (binary.lhs.id === ExprId.nullLiteral ||
        binary.rhs.id === ExprId.nullLiteral)
      err("Unexpected use of same with null literals", binary.loc)
    expr(binary.lhs)
    expr(binary.rhs)
    op(FOp.CmpNotSame)
  }

//////////////////////////////////////////////////////////////////////////
// CondExpr
//////////////////////////////////////////////////////////////////////////

  private Void cond(CondExpr expr, Cond cond)
  {
    switch (expr.id)
    {
      case ExprId.boolOr:  or(expr, cond)
      case ExprId.boolAnd: and(expr, cond)
      default:             throw Err(expr.id.toStr)
    }
  }

  private Void or(CondExpr expr, Cond? cond)
  {
    // if cond is null this is a top level expr which means
    // the result is to push true or false onto the stack;
    // otherwise our only job is to do the various jumps if
    // true or fall-thru if true (used with if statement)
    // NOTE: this code could be further optimized because
    //   it doesn't optimize "a && b || c && c"
    topLevel := cond == null
    if (topLevel) cond = Cond.make

    // perform short circuit logical-or
    expr.operands.each |Expr operand, Int i|
    {
      this.expr(operand)
      if (i < expr.operands.size-1)
        cond.jumpTrues.add(jump(FOp.JumpTrue))
      else
        cond.jumpFalses.add(jump(FOp.JumpFalse))
    }

    // if top level push true/false onto stack
    if (topLevel) condEnd(cond)
  }

  private Void and(CondExpr expr, Cond? cond)
  {
    // if cond is null this is a top level expr which means
    // the result is to push true or false onto the stack;
    // otherwise our only job is to do the various jumps if
    // true or fall-thru if true (used with if statement)
    // NOTE: this code could be further optimized because
    //   it doesn't optimize "a && b || c && c"
    topLevel := cond == null
    if (topLevel) cond = Cond.make

    // perform short circuit logical-and
    expr.operands.each |Expr operand|
    {
      this.expr(operand)
      cond.jumpFalses.add(jump(FOp.JumpFalse))
    }

    // if top level push true/false onto stack
    if (topLevel) condEnd(cond)
  }

  private Void condEnd(Cond cond)
  {
    // true if always fall-thru
    cond.jumpTrues.each |Int pos| { backpatch(pos) }
    op(FOp.LoadTrue)
    end := jump(FOp.Jump)

    // false
    cond.jumpFalses.each |Int pos| { backpatch(pos) }
    op(FOp.LoadFalse)

    backpatch(end)
  }

//////////////////////////////////////////////////////////////////////////
// Type Checks
//////////////////////////////////////////////////////////////////////////

  private Void isExpr(TypeCheckExpr tc)
  {
    expr(tc.target)
    op(FOp.Is, fpod.addTypeRef(tc.check))
  }

  private Void isnotExpr(TypeCheckExpr tc)
  {
    isExpr(tc)
    op(FOp.CallVirtual, fpod.addMethodRef(ns.boolNot))
  }

  private Void asExpr(TypeCheckExpr tc)
  {
    expr(tc.target)
    op(FOp.As, fpod.addTypeRef(tc.check))
  }

  private Void coerce(TypeCheckExpr tc)
  {
    expr(tc.target)
    coerceOp(tc.from, tc.ctype)
    if (!tc.leave) opType(FOp.Pop, tc.ctype)
  }

  private Void coerceOp(CType from, CType to)
  {
    // map from/to to typeRefs
    fromRef := fpod.addTypeRef(from)
    toRef   := fpod.addTypeRef(to)

    // short circuit if coercing same types
    if (fromRef == toRef) return

    // write opcode with its from/to arguments
    op(FOp.Coerce)
    code.writeI2(fromRef)
    code.writeI2(toRef)
  }

//////////////////////////////////////////////////////////////////////////
// Elvis
//////////////////////////////////////////////////////////////////////////

  private Void elvis(BinaryExpr binary)
  {
    expr(binary.lhs)
    opType(FOp.Dup, binary.lhs.ctype)
    opType(FOp.CmpNull, binary.lhs.ctype)
    isNullLabel := jump(FOp.JumpTrue)
    endLabel := jump(FOp.Jump)
    backpatch(isNullLabel)
    opType(FOp.Pop, binary.lhs.ctype)
    expr(binary.rhs)
    backpatch(endLabel)
  }

//////////////////////////////////////////////////////////////////////////
// Ternary
//////////////////////////////////////////////////////////////////////////

  private Void ternary(TernaryExpr ternary)
  {
    expr(ternary.condition)
    falseLabel := jump(FOp.JumpFalse)
    expr(ternary.trueExpr)
    endLabel := jump(FOp.Jump)
    backpatch(falseLabel)
    expr(ternary.falseExpr)
    backpatch(endLabel)
  }

//////////////////////////////////////////////////////////////////////////
// Closure
//////////////////////////////////////////////////////////////////////////

  private Void closure(ClosureExpr c)
  {
    // we replace the closure with its substitute
    // expression - call to closure constructor
    expr(c.substitute)
  }

//////////////////////////////////////////////////////////////////////////
// Assign
//////////////////////////////////////////////////////////////////////////

  **
  ** Simple assignment using =
  **
  private Void assign(BinaryExpr expr)
  {
    switch (expr.lhs.id)
    {
      case ExprId.localVar: assignLocalVar(expr)
      case ExprId.field:    assignField(expr)
      default: throw err("Internal compiler error", expr.loc)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Local Var
//////////////////////////////////////////////////////////////////////////

  private Void loadLocalVar(LocalVarExpr var)
  {
    op(FOp.LoadVar, var.register)
  }

  private Void storeLocalVar(LocalVarExpr var)
  {
    op(FOp.StoreVar, var.register);
  }

  private Void assignLocalVar(BinaryExpr assign)
  {
    expr(assign.rhs)
    if (assign.leave) opType(FOp.Dup, assign.ctype)
    storeLocalVar((LocalVarExpr)assign.lhs)
  }

//////////////////////////////////////////////////////////////////////////
// Field
//////////////////////////////////////////////////////////////////////////

  private Void loadField(FieldExpr fexpr, Bool dupTarget := false)
  {
    field := fexpr.field

    // evaluate target expression
    if (fexpr.target != null)
    {
      expr(fexpr.target);
      if (dupTarget) opType(FOp.Dup, fexpr.target.ctype)
    }

    // if safe, check for null condition
    Int? isNullLabel := null
    if (fexpr.isSafe)
    {
      if (fexpr.target == null) throw err("Compiler error field isSafe", fexpr.loc)
      opType(FOp.Dup, fexpr.ctype)
      opType(FOp.CmpNull, fexpr.ctype)
      isNullLabel = jump(FOp.JumpTrue)
    }

    // load field via accessor method
    if (fexpr.useAccessor)
    {
      getter := field.getter // if null then bug in useAccessor
      index := fpod.addMethodRef(getter)
      if (field.parent.isMixin)
      {
        if (getter.isStatic)
          op(FOp.CallMixinStatic, index)
        else
          op(FOp.CallMixinVirtual, index)
      }
      else
      {
        if (getter.isStatic)
          op(FOp.CallStatic, index)
        else if (fexpr.target.id == ExprId.superExpr)
          op(FOp.CallSuper, index)
        else if (field.isVirtual || field.isAbstract)
          op(FOp.CallVirtual, index)
        else
          op(FOp.CallNonVirtual, index)
      }

      // if parameterized or covariant, then coerce
      if (field.isParameterized)
        coerceOp(ns.objType.toNullable, field.fieldType)
      else if (field.isCovariant)
        coerceOp(field.inheritedReturnType, field.fieldType)
    }
    // load field directly from storage
    else
    {
      index := fpod.addFieldRef(field)
      if (field.parent.isMixin)
      {
        if (field.isStatic)
          op(FOp.LoadMixinStatic, index)
        else
          throw err("LoadMixinInstance", fexpr.loc)
      }
      else
      {
        if (field.isStatic)
          op(FOp.LoadStatic, index)
        else
          op(FOp.LoadInstance, index)
      }

      if (field.isParameterized)
        coerceOp(ns.objType.toNullable, field.fieldType)
    }

    // if safe, handle null case
    if (fexpr.isSafe)
    {
      if (field.fieldType.isVal) coerceOp(field.fieldType, field.fieldType.toNullable)
      endLabel := jump(FOp.Jump)
      backpatch(isNullLabel)
      opType(FOp.Pop, fexpr.ctype)
      op(FOp.LoadNull)
      backpatch(endLabel)
    }
  }

  private Void assignField(BinaryExpr assign)
  {
    lhs := (FieldExpr)assign.lhs
    isInstanceField := !lhs.field.isStatic;  // used to determine how to duplicate

    if (lhs .target != null) expr(lhs.target)
    expr(assign.rhs);
    if (assign.leave)
    {
      opType(FOp.Dup, assign.ctype)
      if (isInstanceField)
        op(FOp.StoreVar, assign.tempVar.register)
    }
    storeField(lhs)
    if (assign.leave && isInstanceField)
    {
      op(FOp.LoadVar, assign.tempVar.register)
    }
  }

  private Void storeField(FieldExpr fexpr)
  {
    field := fexpr.field

    if (field.isParameterized)
        coerceOp(field.fieldType, ns.objType.toNullable)

    if (fexpr.useAccessor)
    {
      setter := field.setter  // if null then bug in useAccessor
      index := fpod.addMethodRef(setter)

      if (field.parent.isMixin) // TODO
      {
        if (setter.isStatic)
          op(FOp.CallMixinStatic, index)
        else
          op(FOp.CallMixinVirtual, index)
      }
      else
      {
        if (setter.isStatic)
          op(FOp.CallStatic, index)
        else if (fexpr.target.id == ExprId.superExpr)
          op(FOp.CallSuper, index)
        else if (field.isVirtual || field.isAbstract)
          op(FOp.CallVirtual, index)
        else
          op(FOp.CallNonVirtual, index)
      }
    }
    else
    {
      index := fpod.addFieldRef(field)

      if (field.parent.isMixin)
      {
        if (field.isStatic)
          op(FOp.StoreMixinStatic, index)
        else
          throw err("StoreMixinInstance", fexpr.loc)
      }
      else
      {
        if (field.isStatic)
          op(FOp.StoreStatic, index)
        else
          op(FOp.StoreInstance, index)
      }
    }
  }

//////////////////////////////////////////////////////////////////////////
// Call
//////////////////////////////////////////////////////////////////////////

  private Void call(CallExpr call, Bool leave := call.leave)
  {
    // evaluate target
    method := call.method

    // push call target onto the stack
    target := call.target
    if (target != null) expr(target)

    // if safe, check for null
    Int? isNullLabel := null
    if (call.isSafe)
    {
      // sanity check
      if (target == null || (target.ctype.isVal && !target.ctype.isNullable))
        throw err("Compiler error call isSafe: $call", call.loc)

      // check if null and if so then jump over call
      opType(FOp.Dup, target.ctype)
      opType(FOp.CmpNull, target.ctype)
      isNullLabel = jump(FOp.JumpTrue)

      // now if we are calling a value-type method we might need to coerce
      if (target.ctype.isVal || method.parent.isVal)
        coerceOp(target.ctype, call.method.parent)
    }

    // invoke call
    if (call.isDynamic)
    {
      dynamicCall(call)
    }
    else
    {
      call.args.each |Expr arg| { expr(arg) }
      invokeCall(call, leave)
    }

    // if safe, handle null case
    if (call.isSafe)
    {
      // if the method return a value type, ensure it is coerced to nullable
      if (method.returnType.isVal && call.leave)
        coerceOp(method.returnType, call.ctype.toNullable)

      // jump to end after successful call and push null onto
      // stack for null check from above (if a leave)
      endLabel := jump(FOp.Jump)
      backpatch(isNullLabel)
      opType(FOp.Pop, target.ctype)
      if (call.leave) op(FOp.LoadNull)
      backpatch(endLabel)
    }
  }

  private Void dynamicCall(CallExpr call)
  {
    // name str literal
    op(FOp.LoadStr, fpod.strs.add(call.name))

    // args Obj[]
    if (call.args.isEmpty)
    {
      op(FOp.LoadNull)
    }
    else
    {
      op(FOp.LoadInt,  fpod.ints.add(call.args.size))
      op(FOp.CallNew,  fpod.addMethodRef(ns.listMakeObj))
      add := fpod.addMethodRef(ns.listAdd)
      call.args.each |Expr arg|
      {
        expr(arg)
        op(FOp.CallVirtual, add)
      }
    }

    // Obj.trap
    op(FOp.CallVirtual, fpod.addMethodRef(ns.objTrap))

    // pop return if no leave
    if (!call.leave) opType(FOp.Pop, call.ctype)
  }

  private Void invokeCall(CallExpr call, Bool leave := call.leave)
  {
    m := call.method
    index := fpod.addMethodRef(m, call.args.size)

    // write CallVirtual, CallNonVirtual, CallStatic, CallNew, or CallCtor;
    // note that if a constructor call has a target (this or super), then it
    // is a CallCtor instance call because we don't want to allocate
    // a new instance
    if (m.parent.isMixin)
    {
      if (m.isStatic)
        op(FOp.CallMixinStatic, index)
      else if (call.target.id == ExprId.superExpr)
        op(FOp.CallMixinNonVirtual, index)
      else
        op(FOp.CallMixinVirtual, index)
    }
    else if (m.isStatic)
    {
      op(FOp.CallStatic, index)
    }
    else if (m.isCtor)
    {
      if (call.target == null || call.target.id == ExprId.staticTarget)
        op(FOp.CallNew, index)
      else
        op(FOp.CallCtor, index)
    }
    else
    {
      // because CallNonVirtual maps to Java's invokespecial, we can't
      // use it for calls outside of the class (consider it like calling
      // protected method); we also don't want to use non-virtual for
      // any Obj methods since those are implemented as static wrappers
      // in the Java/.NET runtime
      targetId := call.target.id
      if (targetId == ExprId.superExpr) {
        op(FOp.CallSuper, index)
      }
      else if (m.isVirtual || m.isAbstract) {
        op(FOp.CallVirtual, index)
      }
      else {
        op(FOp.CallNonVirtual, index)
      }

      /*Why this?
      if (targetId == ExprId.thisExpr && !m.isVirtual && !m.parent.isObj))
        op(FOp.CallNonVirtual, index)
      else
        op(FOp.CallVirtual, index)
      */
    }

    // if we are leaving a value on the stack of a method which
    // has a parameterized return value or is covariant, then we
    // need to insert a cast operation
    //   Int.toStr    => non-generic - no cast
    //   Str[].toStr  => return isn't parameterized - no cast
    //   Str[].get()  => actual return is Obj, but we want Str - cast
    //   covariant    => actual call is against inheritedReturnType
    if (leave)
    {
      if (m.isParameterized)
      {
        ret := m.generic.returnType
        if (ret.hasGenericParameter)
          coerceOp(ret.raw, m.returnType)
      }
      else if (m.isCovariant)
      {
        //Fix: sys::List^V => sys::ArrayList^V
        coerceOp(m.inheritedReturnType.raw, m.returnType.raw)
      }
    }

    // if the method left a value on the stack, and we
    // aren't going to use it, then pop it off
    if (!leave)
    {
      // note we need to use the actual method signature (not parameterized)
      x := m.isParameterized ? m.generic : m
      if (!x.returnType.isVoid || x.isInstanceCtor)
        opType(FOp.Pop, x.returnType.raw)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Shortcut
//////////////////////////////////////////////////////////////////////////

  private Void shortcut(ShortcutExpr call)
  {
    // handle comparisions as special opcodes
    target := call.target
    firstArg := call.args.first
    switch (call.opToken)
    {
      case Token.eq:     compareOp(target, FOp.CmpEQ, firstArg); return
      case Token.notEq:  compareOp(target, FOp.CmpNE, firstArg); return
      case Token.cmp:    compareOp(target, FOp.Cmp,   firstArg); return
      case Token.lt:     compareOp(target, FOp.CmpLT, firstArg); return
      case Token.ltEq:   compareOp(target, FOp.CmpLE, firstArg); return
      case Token.gt:     compareOp(target, FOp.CmpGT, firstArg); return
      case Token.gtEq:   compareOp(target, FOp.CmpGE, firstArg); return
    }

    // always check string concat first since it can
    // have string on either left or right hand side
    if (call.isStrConcat)
    {
      addStr(call, true)
      return
    }

    // if assignment we need to do a bunch of special processing
    if (call.isAssign)
    {
      shortcutAssign(call)
      return
    }

    // just process as normal call
    this.call(call)
  }

  **
  ** Generate a comparison.  The lhs can be either a ctype or an expr.
  **
  private Void compareOp(Obj lhs, FOp opCode, Expr rhs)
  {
    lhsExpr := lhs as Expr
    lhsType := lhsExpr != null ? lhsExpr.ctype : (CType)lhs

    if (lhsExpr != null) expr(lhsExpr)
    expr(rhs)

    fromRef := fpod.addTypeRef(lhsType)
    toRef   := fpod.addTypeRef(rhs.ctype)

    op(opCode)
    code.writeI2(fromRef)
    code.writeI2(toRef)
  }

  **
  ** This method is used for complex assignments: prefix/postfix
  ** increment and special dual assignment operators like "+=".
  **
  private Void shortcutAssign(ShortcutExpr c)
  {
    var := c.target
    leaveUsingTemp := false

    // if var is a coercion set that aside and get real variable
    TypeCheckExpr? coerce := null
    if (var.id == ExprId.coerce)
    {
      coerce = (TypeCheckExpr)var
      var = coerce.target
    }

    // load the variable
    switch (var.id)
    {
      case ExprId.localVar:
        loadLocalVar((LocalVarExpr)var)
      case ExprId.field:
        fexpr := (FieldExpr)var
        loadField(fexpr, true) // dup target on stack for upcoming set
        leaveUsingTemp = !fexpr.field.isStatic  // used to determine how to duplicate
      case ExprId.shortcut:
        // since .NET sucks when it comes to stack manipulation,
        // we use two scratch locals to get the stack into the
        // following format:
        //   index  \  used for get
        //   target /
        //   index  \  used for set
        //   target /
        index := (IndexedAssignExpr)c
        get := (ShortcutExpr)var
        expr(get.target)  // target
        opType(FOp.Dup, get.target.ctype)
        op(FOp.StoreVar, index.scratchA.register)
        expr(get.args[0]) // index expr
        opType(FOp.Dup, get.args[0].ctype)
        op(FOp.StoreVar, index.scratchB.register)
        op(FOp.LoadVar, index.scratchA.register)
        op(FOp.LoadVar, index.scratchB.register)
        invokeCall(get, true)
        leaveUsingTemp = true
      default:
        throw err("Internal error", var.loc)
    }

    // if we have a coercion do it
    if (coerce != null) coerceOp(var.ctype, coerce.check)

    // if postfix leave, duplicate value before we preform computation
    if (c.leave && c.isPostfixLeave)
    {
      opType(FOp.Dup, c.ctype)
      if (leaveUsingTemp)
        op(FOp.StoreVar, c.tempVar.register)
    }

    // load args and invoke call
    c.args.each |Expr arg| { expr(arg) }
    invokeCall(c, true)

    // if prefix, duplicate after we've done computation
    if (c.leave && !c.isPostfixLeave)
    {
      opType(FOp.Dup, c.ctype)
      if (leaveUsingTemp)
        op(FOp.StoreVar, c.tempVar.register)
    }

    // if we have a coercion then uncoerce,
    // otherwise perform coerce to ensure we
    // have right type to store back to variable
    if (coerce != null) coerceOp(coerce.check, var.ctype)
    else coerceOp(c.ctype, var.ctype)

    // save the variable back
    switch (var.id)
    {
      case ExprId.localVar:
        storeLocalVar((LocalVarExpr)var)
      case ExprId.field:
        storeField((FieldExpr)var)
      case ExprId.shortcut:
        set := (CMethod)c->setMethod
        setParam := (set.isParameterized ? set.generic : set).params[1].paramType.raw
        //setParam := (set).params[1].paramType
        // if calling setter check if we need to boxed
        if (c.ctype.isVal && !setParam.isVal && coerce == null) coerceOp(c.ctype, setParam)
        op(FOp.CallVirtual, fpod.addMethodRef(set, 2))
        if (!set.returnType.isVoid) opType(FOp.Pop, set.returnType)
      default:
        throw err("Internal error", var.loc)
    }

    // if field leave, then load back from temp local
    if (c.leave && leaveUsingTemp)
      op(FOp.LoadVar, c.tempVar.register)
  }

//////////////////////////////////////////////////////////////////////////
// Strings
//////////////////////////////////////////////////////////////////////////

  **
  ** Assemble code to build a string using sys::StrBuf.
  **
  private Void addStr(ShortcutExpr expr, Bool topLevel)
  {
    if (topLevel)
      op(FOp.CallNew, fpod.addMethodRef(ns.strBufMake, 0))

    lhs := expr.target
    rhs := expr.args.first

    lhsShortcut := lhs as ShortcutExpr
    if (lhsShortcut != null && lhsShortcut.isStrConcat)
    {
      addStr(lhsShortcut, false)
    }
    else
    {
      if (!isEmptyStrLiteral(lhs))
      {
        this.expr(lhs)
        if (lhs.ctype.isVal) coerceOp(lhs.ctype, ns.objType)
        op(FOp.CallVirtual, fpod.addMethodRef(ns.strBufAdd))
      }
    }

    if (!isEmptyStrLiteral(rhs))
    {
      this.expr(rhs)
      op(FOp.CallVirtual, fpod.addMethodRef(ns.strBufAdd))
    }

    if (topLevel) op(FOp.CallVirtual, fpod.addMethodRef(ns.strBufToStr))
  }

  private Bool isEmptyStrLiteral(Expr expr)
  {
    return expr.id === ExprId.strLiteral && expr->val == ""
  }

//////////////////////////////////////////////////////////////////////////
// Code Buffer
//////////////////////////////////////////////////////////////////////////

  **
  ** Append a opcode with a type argument.
  **
  Void opType(FOp opcode, CType arg)
  {
    op(opcode, fpod.addTypeRef(arg))
  }

  **
  ** Append a opcode with option two byte argument.
  **
  Void op(FOp op, Int? arg := null)
  {
    code.write(op.ordinal)
    if (arg != null) code.writeI2(arg)
  }

//////////////////////////////////////////////////////////////////////////
// Jumps
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the current location as a mark to use for backwards jump.
  **
  private Int mark()
  {
    return code.size
  }

  **
  ** Add the specified jump opcode and two bytes for the jump
  ** location.  If a backward jump then pass the mark; if a
  ** a forward jump we return the code pos to backpatch the
  ** mark later.
  **
  private Int jump(FOp op, Int mark := 0xffff)
  {
    this.op(op, mark)
    return code.size-2
  }

  **
  ** Backpacth the mark of forward jump using the given
  ** pos which was returned by jump().  If mark is defaulted,
  ** then we use the current instruction as the mark.
  **
  private Void backpatch(Int pos, Int mark := code.size)
  {
    orig := code.pos
    code.seek(pos).writeI2(mark)
    code.seek(orig)
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  **
  ** Finish writing out the exception handling table
  **
  Buf finishCode()
  {
    // if we had to return from a protected region, then now we
    // need to generate the actual return instructions and backpatch
    // all the leaves
    if (leavesToReturn != null)
    {
      leavesToReturn.each |Int pos| { backpatch(pos) }
      if (returnLocal != null) op(FOp.LoadVar, returnLocal.register)
      op(FOp.Return)
    }

    // check final size
    if (code.size >= 0x7fff) throw err("Method too big", loc)
    return code
  }

  **
  ** Finish writing out the exception handling table
  **
  Buf finishErrTable()
  {
    errTable.seek(0).writeI2(errCount)
    return errTable
  }

  **
  ** Finish writing out the line number table
  **
  Buf finishLines()
  {
    lines.seek(0).writeI2(lineCount)
    return lines
  }

  **
  ** Map the opcode we are getting ready to add to the specified line number
  **
  private Void line(Loc loc)
  {
    line   := loc.line
    offset := code.size
    if (line == null || lastLine == line || lastOffset == offset) return
    lineCount++
    lines.writeI2(offset)
    lines.writeI2(line)
    lastLine = line
    lastOffset = offset
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  Loc loc
  FPod fpod
  MethodDef? curMethod
  Buf code
  Buf errTable
  Int errCount
  Buf lines
  Int lineCount
  Int lastLine := -1
  Int lastOffset := -1
  Loop[] loopStack

  // protected region fields
  ProtectedRegion[]? protectedRegions // stack of protection regions
  Int[]? leavesToReturn    // list of Leave positions to backpatch
  MethodVar? returnLocal    // where we stash return value
}

**************************************************************************
** Loop
**************************************************************************

class Loop
{
  new make(Stmt stmt) { this.stmt = stmt }

  Stmt stmt                  // WhileStmt or ForStmt
  Int[] breaks := Int[,]     // backpatch positions
  Int[] continues := Int[,]  // backpatch positions
  ProtectedRegion[] protectedRegions := ProtectedRegion[,] // stack
}

**************************************************************************
** ProtectedRegion
**************************************************************************

class ProtectedRegion
{
  new make(TryStmt stmt)
  {
    hasFinally = stmt.finallyBlock != null
    if (hasFinally) jumpFinallys = Int[,]
  }

  Bool hasFinally      // does this region have a finally
  Int[]? jumpFinallys  // list of JumpFinally positions to backpatch
}

**************************************************************************
** Cond
**************************************************************************

class Cond
{
  Int[] jumpTrues  := Int[,]   // backpatch positions
  Int[] jumpFalses := Int[,]   // backpatch positions
}