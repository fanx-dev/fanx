
**
** Parse block and Expr
** 
class DeepParserX : ParserX {
  
  new make(CompilerLog log, Str code, CompilationUnit unit)
    : super(log, code, unit)
  {
  }
  
  private CallExpr? ctorChain(MethodDef method)
  {
    consume(Token.colon)
    loc := cur.loc

    call := CallExpr(loc)
    call.isCtorChain = true
    switch (curt)
    {
      case Token.superKeyword: consume; call.target = SuperExpr(loc)
      case Token.thisKeyword:  consume; call.target = ThisExpr(loc)
      default: throw err("Expecting this or super for constructor chaining", loc);
    }

    // we can omit name if super
    if (call.target.id === ExprId.superExpr && curt != Token.dot)
    {
      call.name = method.name
    }
    else
    {
      consume(Token.dot)
      call.name = consumeId
    }

    // TODO: omit args if pass thru?
    callArgs(call, false)
    endLoc(call)
    return call
  }
  
//////////////////////////////////////////////////////////////////////////
// Block
//////////////////////////////////////////////////////////////////////////

  **
  ** Top level for blocks which must be surrounded by braces
  **
  override Block? block()
  {
    verify(Token.lbrace)
    return stmtOrBlock
  }

  **
  ** <block>  :=  <stmt> | ( "{" <stmts> "}" )
  ** <stmts>  :=  <stmt>*
  **
  private Block stmtOrBlock()
  {
    block := Block(cur.loc)

    if (curt !== Token.lbrace)
    {
      block.stmts.add( stmt )
    }
    else
    {
      consume(Token.lbrace)
      while (curt != Token.rbrace)
        block.stmts.add( stmt )
      consume(Token.rbrace)
    }

    endLoc(block)
    return block
  }

//////////////////////////////////////////////////////////////////////////
// Statements
//////////////////////////////////////////////////////////////////////////

  **
  ** Statement:
  **   <stmt>  :=  <break> | <continue> | <for> | <if> | <return> | <switch> |
  **               <throw> | <while> | <try> | <exprStmt> | <localDef> | <itAdd>
  **
  private Stmt stmt()
  {
    // check for statement keywords
    switch (curt)
    {
      case Token.breakKeyword:    return breakStmt
      case Token.continueKeyword: return continueStmt
      case Token.forKeyword:      return forStmt
      case Token.ifKeyword:       return ifStmt
      case Token.returnKeyword:   return returnStmt
      case Token.lretKeyword:     return returnStmt
      case Token.switchKeyword:   return switchStmt
      case Token.throwKeyword:    return throwStmt
      case Token.tryKeyword:      return tryStmt
      case Token.whileKeyword:    return whileStmt
    }

    // at this point we either have an expr or local var declaration
    return exprOrLocalDefStmt(true)
  }

  **
  ** Expression or local variable declaration:
  **   <exprStmt>  :=  <expr> <eos>
  **   <localDef>  :=  [<type>] <id> [":=" <expr>] <eos>
  **   <itAdd>     :=  <expr> ("," <expr>)*
  **
  private Stmt exprOrLocalDefStmt(Bool isEndOfStmt)
  {
    // see if this statement begins with a type literal
    loc := cur.loc

    //type back local variable declaration
    if (curt === Token.identifier && peekt === Token.colon) {
      return localDefStmt(loc, isEndOfStmt)
    }

    // identifier followed by def assign is inferred typed local var declaration
    if (curt === Token.identifier && peekt === Token.defAssign)
    {
      return localDefStmt(loc, isEndOfStmt)
    }

    // if current is an identifer, save for special error handling
    Str? id := (curt === Token.identifier) ? (Str)cur.val : null

    // otherwise assume it's a stand alone expression statement
    e := expr()

    // if expression statement ends with comma then this
    // is syntax sugar for it.add(expr) ...
    if (curt === Token.comma) e = itAdd(e)

    // return expression as statement
    stmt := ExprStmt(e)
    endLoc(stmt)
    if (!isEndOfStmt) return stmt
    if (endOfStmt(null)) return stmt

    // report error
    if (id != null && curt === Token.identifier && (peekt === Token.defAssign || peekt === Token.assign))
      throw err("Unknown type '$id' for local declaration", loc)
    else if (id == null && curt === Token.defAssign)
      throw err("Left hand side of ':=' must be identifier", loc)
    else
      throw err("Expected expression statement", loc)
  }

  **
  ** Comma operator is sugar for it.add(target):
  **   <itAdd>  :=  <expr> ("," <expr>)* <eos>
  **
  private Expr itAdd(Expr e)
  {
    e = CallExpr(e.loc, ItExpr(cur.loc), "add") { args.add(e); isItAdd = true }
    while (true)
    {
      consume(Token.comma)
      if (curt === Token.rbrace || curt === Token.semicolon) break
      e = CallExpr(cur.loc, e, "add") { args.add(expr()) }
      if (curt === Token.rbrace || curt === Token.semicolon) break
    }
    endLoc(e)
    return e
  }

  **
  ** Parse local variable declaration, the current token must be
  ** the identifier of the local variable.
  **
  private LocalDefStmt localDefStmt(Loc loc, Bool isEndOfStmt)
  {
    // verify name doesn't conflict with an import type
    name := consumeId
    CType? localType

    if (curt === Token.colon) {
      consume
      localType = typeRef
    }

    stmt := LocalDefStmt(loc, localType, name)

    if (curt === Token.defAssign || curt === Token.assign)
    {
      if (localType != null && curt === Token.defAssign) err("Must use = for assignments")
      consume
      stmt.init = expr
    }

    if (isEndOfStmt) endOfStmt
    endLoc(stmt)
    return stmt
  }

  **
  ** If/else statement:
  **   <if>  :=  "if" "(" <expr> ")" <block> [ "else" <block> ]
  **
  private IfStmt ifStmt()
  {
    loc := cur.loc
    consume(Token.ifKeyword)
    consume(Token.lparen)
    cond := expr
    consume(Token.rparen)
    trueBlock := stmtOrBlock
    stmt := IfStmt(loc, cond, trueBlock)
    if (curt === Token.elseKeyword)
    {
      consume(Token.elseKeyword)
      stmt.falseBlock = stmtOrBlock
    }
    return stmt
  }

  **
  ** Return statement:
  **   <return>  :=  "return" [<expr>] <eos>
  **
  private ReturnStmt returnStmt()
  {
    stmt := ReturnStmt(cur.loc)
    if (curt === Token.lretKeyword) {
      if (curClosure == null) {
        throw err("Can't use the 'lret' in non-closure")
      }
      consume(Token.lretKeyword)
      stmt.isLocal = true
    }
    else {
      if (curClosure != null) {
        err("expected 'lret'")
      }
      consume(Token.returnKeyword)
    }

    if (!endOfStmt(null))
    {
      stmt.expr = expr
      endOfStmt
    }
    endLoc(stmt)
    return stmt
  }

  **
  ** Throw statement:
  **   <throw>  :=  "throw" <expr> <eos>
  **
  private ThrowStmt throwStmt()
  {
    loc := cur.loc
    consume(Token.throwKeyword)
    stmt := ThrowStmt(loc, expr)
    endOfStmt
    endLoc(stmt)
    return stmt
  }

  **
  ** While statement:
  **   <while>  :=  "while" "(" <expr> ")" <block>
  **
  private WhileStmt whileStmt()
  {
    loc := cur.loc
    consume(Token.whileKeyword)
    consume(Token.lparen)
    cond := expr
    consume(Token.rparen)
    stmt := WhileStmt(loc, cond, stmtOrBlock)
    endLoc(stmt)
    return stmt
  }

  **
  ** For statement:
  **   <for>      :=  "for" "(" [<forInit>] ";" <expr> ";" <expr> ")" <block>
  **   <forInit>  :=  <expr> | <localDef>
  **
  private ForStmt forStmt()
  {
    stmt := ForStmt(cur.loc)
    consume(Token.forKeyword)
    consume(Token.lparen)

    if (curt !== Token.semicolon) stmt.init = exprOrLocalDefStmt(false)
    consume(Token.semicolon)

    if (curt != Token.semicolon) stmt.condition = expr
    consume(Token.semicolon)

    if (curt != Token.rparen) stmt.update = expr
    consume(Token.rparen)

    stmt.block = stmtOrBlock
    endLoc(stmt)
    return stmt
  }

  **
  ** Break statement:
  **   <break>  :=  "break" <eos>
  **
  private BreakStmt breakStmt()
  {
    stmt := BreakStmt(cur.loc)
    consume(Token.breakKeyword)
    endOfStmt
    endLoc(stmt)
    return stmt
  }

  **
  ** Continue statement:
  **   <continue>  :=  "continue" <eos>
  **
  private ContinueStmt continueStmt()
  {
    stmt := ContinueStmt(cur.loc)
    consume(Token.continueKeyword)
    endOfStmt
    endLoc(stmt)
    return stmt
  }

  **
  ** Try-catch-finally statement:
  **   <try>       :=  "try" "{" <stmt>* "}" <catch>* [<finally>]
  **   <catch>     :=  "catch" [<catchDef>] "{" <stmt>* "}"
  **   <catchDef>  :=  "(" <type> <id> ")"
  **   <finally>   :=  "finally" "{" <stmt>* "}"
  **
  private TryStmt tryStmt()
  {
    stmt := TryStmt(cur.loc)
    consume(Token.tryKeyword)
    stmt.block = stmtOrBlock
    if (curt !== Token.catchKeyword && curt !== Token.finallyKeyword)
      throw err("Expecting catch or finally block")
    while (curt === Token.catchKeyword)
    {
      stmt.catches.add(tryCatch)
    }
    if (curt === Token.finallyKeyword)
    {
      consume
      stmt.finallyBlock = stmtOrBlock
    }
    endLoc(stmt)
    return stmt
  }

  private Catch tryCatch()
  {
    c := Catch(cur.loc)
    consume(Token.catchKeyword)

    if (curt === Token.lparen)
    {
      consume(Token.lparen)
      c.errType = typeRef
      c.errVariable = consumeId
      consume(Token.rparen)
    }

    c.block = stmtOrBlock

    // insert implicit local variable declaration
    if (c.errVariable != null)
      c.block.stmts.insert(0, LocalDefStmt.makeCatchVar(c))

    endLoc(c)
    return c
  }

  **
  ** Switch statement:
  **   <switch>   :=  "switch" "(" <expr> ")" "{" <case>* [<default>] "}"
  **   <case>     :=  "case" <expr> ":" <stmts>
  **   <default>  :=  "default" ":" <stmts>
  **
  private SwitchStmt switchStmt()
  {
    loc := cur.loc
    consume(Token.switchKeyword)
    consume(Token.lparen)
    stmt := SwitchStmt(loc, expr)
    consume(Token.rparen)
    consume(Token.lbrace)
    while (curt != Token.rbrace)
    {
      if (curt === Token.caseKeyword)
      {
        consume
        c := Case(cur.loc)
        c.cases.add(expr)
        while (curt === Token.comma)
        {
          consume
          c.cases.add(expr)
        }
        consume(Token.colon)
        
        c.block = switchBlock
        endLoc(c)
        stmt.cases.add(c)
      }
      else if (curt === Token.defaultKeyword)
      {
        if (stmt.defaultBlock != null) err("Duplicate default blocks")
        consume
        consume(Token.colon)
        stmt.defaultBlock = switchBlock
      }
      else
      {
        throw err("Expected case or default statement")
      }
    }
    consume(Token.rbrace)
    endOfStmt
    endLoc(stmt)
    return stmt
  }

  private Block switchBlock()
  {
    block := Block(cur.loc)
    while (curt !== Token.caseKeyword && curt != Token.defaultKeyword && curt !== Token.rbrace)
      block.stmts.add(stmt)
      
    endLoc(block)
    return block
  }

//////////////////////////////////////////////////////////////////////////
// Expr
//////////////////////////////////////////////////////////////////////////

  **
  ** Expression:
  **   <expr>  :=  <assignExpr>
  **
  override Expr? expr()
  {
    return assignExpr
  }

  **
  ** Assignment expression:
  **   <assignExpr>     :=  <ifExpr> [<assignOp> <assignExpr>]
  **   <assignOp>       :=  "=" | "*=" | "/=" | "%=" | "+=" | "-="
  **
  private Expr assignExpr(Expr? expr := null)
  {
    // this is tree if built to the right (others to the left)
    if (expr == null) expr = ifExpr
    if (curt.isAssign)
    {
      if (curt === Token.assign) {
        e := BinaryExpr(expr, consume.kind, assignExpr)
        endLoc(e)
        return e
      }
      else {
        e := ShortcutExpr.makeBinary(expr, consume.kind, assignExpr)
        endLoc(e)
        return e
      }
    }
    return expr
  }

  **
  ** Ternary/Elvis expressions:
  **   <ifExpr>       :=  <ternaryExpr> | <elvisExpr>
  **   <ternaryExpr>  :=  <condOrExpr> ["?" <ifExprBody> ":" <ifExprBody>]
  **   <elvisExpr>    :=  <condOrExpr> "?:" <ifExprBody>
  **
  private Expr ifExpr()
  {
    expr := condOrExpr
    if (curt === Token.question)
    {
      condition := expr
      consume(Token.question)
      trueExpr := ifExprBody
      // nice error checking for Foo? x :=
      if (curt === Token.defAssign && expr.id === ExprId.unknownVar && trueExpr.id === ExprId.unknownVar)
        throw err("Unknown type '$expr' for local declaration", expr.loc)
      consume(Token.colon)
      falseExpr := ifExprBody
      expr = TernaryExpr(condition, trueExpr, falseExpr)
    }
    else if (curt === Token.elvis)
    {
      lhs := expr
      consume
      rhs := ifExprBody
      expr = BinaryExpr(lhs, Token.elvis, rhs)
    }
    
    endLoc(expr)
    return expr
  }

  **
  ** If expression body (ternary/elvis):
  **   <ifExprBody>   :=  <condOrExpr> | <ifExprThrow>
  **   <ifExprThrow>  :=  "throw" <expr>
  **
  private Expr ifExprBody()
  {
    if (curt === Token.throwKeyword)
    {
      loc := cur.loc
      consume(Token.throwKeyword)
      e := ThrowExpr(loc, expr)
      endLoc(e)
      return e
    }
    else
    {
      return condOrExpr
    }
  }

  **
  ** Conditional or expression:
  **   <condOrExpr>  :=  <condAndExpr>  ("||" <condAndExpr>)*
  **
  private Expr condOrExpr()
  {
    expr := condAndExpr
    if (curt === Token.doublePipe)
    {
      cond := CondExpr(expr, cur.kind)
      while (curt === Token.doublePipe)
      {
        consume
        cond.operands.add(condAndExpr)
      }
      endLoc(cond)
      expr = cond
    }
    return expr
  }

  **
  ** Conditional and expression:
  **   <condAndExpr>  :=  <equalityExpr> ("&&" <equalityExpr>)*
  **
  private Expr condAndExpr()
  {
    expr := equalityExpr
    if (curt === Token.doubleAmp)
    {
      cond := CondExpr(expr, cur.kind)
      while (curt === Token.doubleAmp)
      {
        consume
        cond.operands.add(equalityExpr)
      }
      endLoc(cond)
      expr = cond
    }
    return expr
  }

  **
  ** Equality expression:
  **   <equalityExpr>  :=  <relationalExpr> [("==" | "!=" | "===" | "!==") <relationalExpr>]
  **
  private Expr equalityExpr()
  {
    expr := relationalExpr
    if (curt === Token.eq   || curt === Token.notEq ||
        curt === Token.same || curt === Token.notSame)
    {
      lhs := expr
      tok := consume.kind
      rhs := relationalExpr

      // optimize for null literal
      if (lhs.id === ExprId.nullLiteral || rhs.id === ExprId.nullLiteral)
      {
        id := (tok === Token.eq || tok === Token.same) ? ExprId.cmpNull : ExprId.cmpNotNull
        operand := (lhs.id === ExprId.nullLiteral) ? rhs : lhs
        expr = UnaryExpr(lhs.loc, id, tok, operand)
      }
      else
      {
        if (tok === Token.same || tok === Token.notSame)
          expr = BinaryExpr(lhs, tok, rhs)
        else
          expr = ShortcutExpr.makeBinary(lhs, tok, rhs)
      }
      endLoc(expr)
    }
    return expr
  }

  **
  ** Relational expression:
  **   <relationalExpr> :=  <typeCheckExpr> | <compareExpr>
  **   <typeCheckExpr>  :=  <rangeExpr> [("is" | "as" | "isnot") <type>]
  **   <compareExpr>    :=  <rangeExpr> [("<" | "<=" | ">" | ">=" | "<=>") <rangeExpr>]
  **
  private Expr relationalExpr()
  {
    expr := rangeExpr
    if (curt === Token.isKeyword || curt === Token.isnotKeyword ||
        curt === Token.asKeyword ||
        curt === Token.lt || curt === Token.ltEq ||
        curt === Token.gt || curt === Token.gtEq ||
        curt === Token.cmp)
    {
      switch (curt)
      {
        case Token.isKeyword:
          consume
          expr = TypeCheckExpr(expr.loc, ExprId.isExpr, expr, ctype)
        case Token.isnotKeyword:
          consume
          expr = TypeCheckExpr(expr.loc, ExprId.isnotExpr, expr, ctype)
        case Token.asKeyword:
          consume
          expr = TypeCheckExpr(expr.loc, ExprId.asExpr, expr, ctype)
        default:
          expr = ShortcutExpr.makeBinary(expr, consume.kind, rangeExpr)
      }
      endLoc(expr)
    }
    return expr
  }

  **
  ** Range expression:
  **   <rangeExpr>  :=  <bitOrExpr> ((".." | "...") <bitOrExpr>)*
  **
  private Expr rangeExpr()
  {
    expr := addExpr
    if (curt === Token.dotDot || curt === Token.dotDotLt)
    {
      start := expr
      exclusive := consume.kind === Token.dotDotLt
      end := addExpr
      expr = RangeLiteralExpr(expr.loc, start, end, exclusive)
      endLoc(expr)
    }
    return expr
  }

  **
  ** Additive expression:
  **   <addExpr>  :=  <multExpr> (("+" | "-") <multExpr>)*
  **
  private Expr addExpr()
  {
    expr := multExpr
    while (curt === Token.plus || curt === Token.minus) {
      expr = ShortcutExpr.makeBinary(expr, consume.kind, multExpr)
      endLoc(expr)
    }
    return expr
  }

  **
  ** Multiplicative expression:
  **   <multExpr>  :=  <parenExpr> (("*" | "/" | "%") <parenExpr>)*
  **
  private Expr multExpr()
  {
    expr := parenExpr
    while (curt === Token.star || curt === Token.slash || curt === Token.percent) {
      expr = ShortcutExpr.makeBinary(expr, consume.kind, parenExpr)
      endLoc(expr)
    }
    return expr
  }

  **
  ** Paren grouped expression:
  **   <parenExpr>    :=  <unaryExpr> | <castExpr> | <groupedExpr>
  **   <castExpr>     :=  "(" <type> ")" <parenExpr>
  **   <groupedExpr>  :=  "(" <expr> ")" <termChain>*
  **
  private Expr parenExpr()
  {
    if (curt !== Token.lparen && curt !== Token.lparenSynthetic)
      return unaryExpr

    // consume opening paren (or synthetic paren)
    loc := cur.loc
    consume()

    // this is just a normal parenthesized expression
    expr := expr
    consume(Token.rparen)
    while (true)
    {
      chained := termChainExpr(expr)
      if (chained == null) break
      expr = chained
    }
    return expr
  }

  **
  ** Unary expression:
  **   <unaryExpr>    :=  <prefixExpr> | <termExpr> | <postfixExpr>
  **   <prefixExpr>   :=  ("!" | "+" | "-" | "~" | "++" | "--") <parenExpr>
  **   <postfixExpr>  :=  <termExpr> ("++" | "--")
  **
  private Expr unaryExpr()
  {
    loc := cur.loc
    tok := cur
    tokt := curt

    if (tokt === Token.bang)
    {
      consume
      e := UnaryExpr(loc, Expr.tokenToExprId(tokt), tokt, parenExpr)
      endLoc(e)
      return e
    }

    if (tokt === Token.plus)
    {
      consume
      return parenExpr // optimize +expr to just expr
    }

    if (tokt === Token.minus)
    {
      consume
      e := ShortcutExpr.makeUnary(loc, tokt, parenExpr)
      endLoc(e)
      return e
    }

    // if (tokt.isIncrementOrDecrement)
    // {
    //   consume
    //   e := ShortcutExpr.makeUnary(loc, tokt, parenExpr)
    //   endLoc(e)
    //   return e
    // }

    expr := termExpr

    // postfix ++/-- must be on the same line
    tokt = curt
    tok = cur
    if (tokt.isIncrementOrDecrement && !tok.newline)
    {
      consume
      shortcut := ShortcutExpr.makeUnary(loc, tokt, expr)
      shortcut.isPostfixLeave = true
      endLoc(shortcut)
      return shortcut
    }

    return expr
  }

//////////////////////////////////////////////////////////////////////////
// Term Expr
//////////////////////////////////////////////////////////////////////////

  **
  ** A term is a base terminal such as a variable, call, or literal,
  ** optionally followed by a chain of accessor expressions - such
  ** as "x.y[z](a, b)".
  **
  **   <termExpr>  :=  <termBase> <termChain>*
  **
  private Expr termExpr(Expr? target := null)
  {
    if (target == null) target = termBaseExpr
    while (true)
    {
      chained := termChainExpr(target)
      if (chained == null) break
      target = chained
    }
    return target
  }

  **
  ** If the current stream of tokens can be parsed as a
  ** valid type production return it.  Otherwise leave
  ** the parser positioned on the current token.
  **
  private CType? tryType()
  {
    // types can only begin with identifier, | or [
    if (curt !== Token.identifier && curt !== Token.pipe && curt !== Token.lbracket)
      return null

    oldSuppress := suppressErr
    suppressErr = true
    mark := pos
    CType? type := null
    try
    {
      atype := ctype()
      if (curt === Token.pound) {
        //Int#
        type = atype
      }
      else if (curt === Token.dot && peekt === Token.superKeyword) {
        //Int.super
        type = atype
      }
      else if (curt === Token.dsl) {
        //Int<|..|>
        type = atype
      }
      else if (this.tokens[pos>1?pos-1:0].kind == Token.gt) {
        //Int<X>
        type = atype
      }
      else if (atype.podName != "") {
        //sys::Int
        type = atype
      }
    }
    catch (CompilerErr e)
    {
    }
    suppressErr = oldSuppress
    if (type == null) reset(mark)
    return type
  }
  
  **
  ** Atomic base of a termExpr
  **
  **   <termBase>    :=  <literal> | <idExpr> | <closure> | <dsl>
  **   <literal>     :=  "null" | "this" | "super" | <bool> | <int> |
  **                     <float> | <str> | <duration> | <list> | <map> | <uri> |
  **                     <typeLiteral> | <slotLiteral>
  **   <typeLiteral> :=  <type> "#"
  **   <slotLiteral> :=  [<type>] "#" <id>
  **
  private Expr termBaseExpr()
  {
    loc := cur.loc

    ctype := tryType
    if (ctype != null) return typeBaseExpr(loc, ctype)

    switch (curt)
    {
      case Token.amp:             return idExpr(null, false, false)
      case Token.identifier:      return idExpr(null, false, false)
      case Token.intLiteral:      return LiteralExpr(loc, ExprId.intLiteral, consume.val)
      case Token.floatLiteral:    return LiteralExpr(loc, ExprId.floatLiteral, consume.val)
      case Token.decimalLiteral:  err("Unsupported Decimal literal"); return LiteralExpr(loc, ExprId.decimalLiteral, consume.val)
      case Token.strLiteral:      return LiteralExpr(loc, ExprId.strLiteral, consume.val)
      case Token.durationLiteral: return LiteralExpr(loc, ExprId.durationLiteral, consume.val)
      case Token.uriLiteral:      err("Unsupported Uri literal"); return LiteralExpr(loc, ExprId.uriLiteral, consume.val)
      case Token.localeLiteral:
        expr := LocaleLiteralExpr(loc, consume.val)
        endLoc(expr)
        return expr
      case Token.lbracket:        return collectionLiteralExpr(loc)
      case Token.falseKeyword:    consume; return LiteralExpr.makeFalse(loc)
      case Token.nullKeyword:     consume; return LiteralExpr.makeNull(loc)
      case Token.superKeyword:    consume; if (curt !== Token.dot) err("Expected '.' dot after 'super' keyword"); return SuperExpr(loc)
      case Token.thisKeyword:     consume; return ThisExpr(loc)
      case Token.itKeyword:       consume; return ItExpr(loc)
      case Token.trueKeyword:     consume; return LiteralExpr.makeTrue(loc)
      case Token.pound:           
        consume
        expr := SlotLiteralExpr(loc, curType.asRef(), consumeId)
        endLoc(expr)
        return expr
      case Token.awaitKeyword:
        consume;
        expr := AwaitExpr(loc, this.expr)
        endLoc(expr)
        return expr
      case Token.sizeofKeyword:   
        consume;
        consume(Token.lparen)
        expr := SizeOfExpr(loc, this.ctype)
        consume(Token.rparen)
        endLoc(expr)
        return expr
      case Token.addressofKeyword:
        consume;
        consume(Token.lparen)
        expr := AddressOfExpr(loc, this.expr)
        consume(Token.rparen)
        endLoc(expr)
        return expr
      case Token.pipe:
        c := tryClosure
        if (c != null) return c
    }

    if (curt == Token.pipe)
      throw err("Invalid closure expression (check types)")
    else {
      if (cur.kind.keyword) throw err("Expected expression, not keyword '" + cur + "'")
      else throw err("Expected expression, not '" + cur + "'")
    }
  }

  **
  ** Handle a term expression which begins with a type literal.
  **
  private Expr typeBaseExpr(Loc loc, CType ctype)
  {
    // type or slot literal
    if (curt === Token.pound)
    {
      consume
      if (curt === Token.identifier && !cur.newline) {
        expr := SlotLiteralExpr(loc, ctype, consumeId)
        endLoc(expr)
        return expr
      } else {
        expr := LiteralExpr(loc, ExprId.typeLiteral, ctype)
        endLoc(expr)
        return expr
      }
    }

    // dot is named super or static call chain
    if (curt == Token.dot)
    {
      consume
      if (curt === Token.superKeyword)
      {
        consume
        if (curt !== Token.dot) err("Expected '.' dot after 'super' keyword")
        return SuperExpr(loc, ctype)
      }
      else
      {
        target := StaticTargetExpr(loc, ctype)
        endLoc(target)
        return idExpr(target, false, false)
      }
    }

    // dsl
    if (curt == Token.dsl)
    {
      srcLoc := Loc(cur.loc.file, cur.loc.line, cur.loc.col+2, cur.loc.offset)
      dslVal := cur as TokenValDsl
      expr := DslExpr(loc, ctype, srcLoc, consume.val)
      {
        leadingTabs = dslVal.leadingTabs
        leadingSpaces = dslVal.leadingSpaces
      }
      endLoc(expr)
      return expr
    }

    // list/map literal with explicit type
//    if (curt === Token.lbracket)
//    {
//      return collectionLiteralExpr(loc, ctype)
//    }

    // closure expr never parse as TypeBase
//    if (curt == Token.lbrace && ctype.isFunc)
//    {
//      return closure(loc, ctype)
//    }

    // simple literal type(arg)
    if (curt == Token.lparen)
    {
      construction := CallExpr(loc, StaticTargetExpr(loc, ctype), "<ctor>", ExprId.construction)
      callArgs(construction)
      endLoc(construction)
      return construction
    }

    // constructor it-block {...}
    if (curt == Token.lbrace)
    {
      // if not inside a field/method we have complex literal for facet
      if (curSlot == null) return complexLiteral(loc, ctype)

      // shortcut for make with optional it-block
      ctor := CallExpr(loc, StaticTargetExpr(loc, ctype), "make")
      itBlock := tryItBlock
      if (itBlock != null) ctor.args.add(itBlock)
      endLoc(ctor)
      return ctor
    }

    throw err("Unexpected type literal $ctype", loc)
  }

  **
  ** A chain expression is a piece of a term expression that may
  ** be chained together such as "call.var[x]".  If the specified
  ** target expression contains a chained access, then return the new
  ** expression, otherwise return null.
  **
  **   <termChain>      :=  <compiledCall> | <dynamicCall> | <indexExpr>
  **   <compiledCall>   :=  "." <idExpr>
  **   <dynamicCall>    :=  "->" <idExpr>
  **
  private Expr? termChainExpr(Expr target)
  {
    loc := cur.loc

    // handle various call operators: . -> ?. ?->
    switch (curt)
    {
      // if ".id" field access or ".id" call
      case Token.dot: consume;  return idExpr(target, false, false)

      // if "->id" dynamic call
      case Token.arrow: consume; return idExpr(target, true, false, false)

      // if "~>" checked dynamic call
      case Token.tildeArrow:
        consume; return idExpr(target, true, false, true)

      // if "?.id" safe call
      case Token.safeDot: consume; return idExpr(target, false, true)

      // if "?->id" safe dynamic call
      case Token.safeArrow: consume; return idExpr(target, true, true, false)

      // if "?~>id" safe checked dynamic call
      case Token.safeTildeArrow:
        consume; return idExpr(target, true, true, true)
    }

    // if target[...]
    if (cur.isIndexOpenBracket) return indexExpr(target)

    // if target(...)
    if (cur.isCallOpenParen) return callOp(target)

    // if target {...}
    if (curt === Token.lbrace)
    {
      itBlock := tryItBlock
      if (itBlock != null) {
        x := CallExpr.make(loc, target, "with")
        x.args.add(itBlock)
        endLoc(x)
        return x
      }
    }

    // otherwise the expression should be finished
    return null
  }

//////////////////////////////////////////////////////////////////////////
// Term Expr Utils
//////////////////////////////////////////////////////////////////////////

  **
  ** Identifier expression:
  **   <idExpr>  :=  <local> | <field> | <call>
  **   <local>   :=  <id>
  **   <field>   :=  ["*"] <id>
  **
  private Expr idExpr(Expr? target, Bool dynamicCall, Bool safeCall, Bool checkedCall := true)
  {
    loc := cur.loc

    if (curt == Token.amp)
    {
      consume
      expr := UnknownVarExpr(loc, target, consumeId, ExprId.storage)
      endLoc(expr)
      return expr
    }

    if (peek.isCallOpenParen)
    {
      call := callExpr(target)
      call.isDynamic = dynamicCall
      call.isCheckedCall = checkedCall
      call.isSafe = safeCall
      return call
    }

    name := consumeId

    // if we have a closure then this is a call with one arg of a closure
    closure := tryClosure
    if (closure != null)
    {
      call := CallExpr(loc)
      call.target    = target
      call.name      = name
      call.isDynamic = dynamicCall
      call.isCheckedCall = checkedCall
      call.isSafe    = safeCall
      call.noParens  = true
      call.args.add(closure)
      endLoc(call)
      return call
    }

    // if dynamic call then we know this is a call not a field
    if (dynamicCall)
    {
      call := CallExpr(loc)
      call.target    = target
      call.name      = name
      call.isDynamic = true
      call.isCheckedCall = checkedCall
      call.isSafe    = safeCall
      call.noParens  = true
      endLoc(call)
      return call
    }

    // at this point we are parsing a single identifier, but
    // if it looks like it was expected to be a type we can
    // provide a more meaningful error
    if (curt === Token.pound) throw err("Unknown type '$name' for type literal", loc)

    expr := UnknownVarExpr(loc, target, name) { isSafe = safeCall }
    endLoc(expr)
    return expr
  }

  **
  ** Call expression:
  **   <call>  :=  <id> ["(" <args> ")"] [<closure>]
  **
  private CallExpr callExpr(Expr? target)
  {
    call := CallExpr(cur.loc, target)
    call.name    = consumeId
    callArgs(call)
    endLoc(call)
    return call
  }

  **
  ** Parse args with known parens:
  **   <args>  := [<expr> ("," <expr>)*] [<closure>]
  **
  private Void callArgs(CallExpr call, Bool closureOk := true)
  {
    consume(Token.lparen)
    if (curt != Token.rparen)
    {
      while (true)
      {
        //named param
        if (curt === Token.identifier && peekt === Token.colon) {
          if ((cur.val as Str).getSafe(0, 'x').isUpper) {
            //May be a MapLiteral 'Obj:Obj[:]', just discard parse named param
          }
          else {
            name := consumeId
            consume(Token.colon)
            if (call.paramNames == null) call.paramNames = [Int:Str][:]
            call.paramNames[call.args.size] = name
          }
        }
        call.args.add(expr)
        if (curt === Token.rparen) break
        consume(Token.comma)
      }
    }
    consume(Token.rparen)

    if (closureOk)
    {
      closure := tryClosure
      if (closure != null) call.args.add(closure)
    }
  }

  **
  ** Call operator:
  **   <callOp>  := "(" <args> ")" [<closure>]
  **
  private Expr callOp(Expr target)
  {
    loc := cur.loc
    call := CallExpr(loc)
    call.isCallOp = true
    call.target = target
    callArgs(call)
    call.name = "call"
    endLoc(call)
    return call
  }

  **
  ** Index expression:
  **   <indexExpr>  := "[" <expr> "]"
  **
  private Expr indexExpr(Expr target)
  {
    loc := cur.loc
    consume(Token.lbracket)

    // nice error for BadType[,]
    if (curt === Token.comma && target.id === ExprId.unknownVar)
      throw err("Unknown type '$target' for list literal", target.loc)

    // otherwise this must be a standard single key index
    expr := expr
    consume(Token.rbracket)
    e := ShortcutExpr.makeGet(loc, target, expr)
    endLoc(e)
    return e
  }

//////////////////////////////////////////////////////////////////////////
// Collection "Literals"
//////////////////////////////////////////////////////////////////////////

  **
  ** Collection literal:
  **   <list>       :=  [<type>] "[" <listItems> "]"
  **   <listItems>  :=  "," | (<expr> ("," <expr>)*)
  **   <map>        :=  [<mapType>] "[" <mapItems> "]"
  **   <mapItems>   :=  ":" | (<mapPair> ("," <mapPair>)*)
  **   <mapPair>    :=  <expr> ":" <expr>
  **
  private Expr collectionLiteralExpr(Loc loc)
  {
    CType? explicitType = null
    // empty list [,]
    if (peekt === Token.comma)
      return listLiteralExpr(loc, explicitType, null)

    // empty map [:]
    if (peekt === Token.colon)
      return mapLiteralExpr(loc, explicitType, null)

    // opening bracket
    consume(Token.lbracket)

    // [] is ok
    if (curt === Token.rbracket)
    {
      //err("Invalid list literal; use '[,]' for empty Obj[] list", loc)
      consume
      expr := ListLiteralExpr(loc)
      endLoc(expr)
      return expr
    }

    // read first expression
    first := expr

    // at this point we can determine if it is a list or a map
    if (curt === Token.colon)
      return mapLiteralExpr(loc, explicitType, first)
    else
      return listLiteralExpr(loc, explicitType, first)
  }

  **
  ** Parse List literal; if first is null then
  **   cur must be on lbracket
  ** else
  **   cur must be on comma after first item
  **
  private ListLiteralExpr listLiteralExpr(Loc loc, CType? explicitType, Expr? first)
  {
    // explicitType is type of List:  Str[,]
    if (explicitType != null) {
      elemType := explicitType
      explicitType = CType.listType(loc, elemType)
    }
    list := ListLiteralExpr(loc, explicitType)

    // if first is null, must be on lbracket
    if (first == null)
    {
      consume(Token.lbracket)

      // if [,] empty list
      if (curt === Token.comma)
      {
        consume
        consume(Token.rbracket)
        return list
      }

      first = expr
    }

    list.vals.add(first)
    while (curt === Token.comma)
    {
      consume
      if (curt === Token.rbracket) break // allow extra trailing comma
      list.vals.add(expr)
    }
    consume(Token.rbracket)
    endLoc(list)
    return list
  }

  **
  ** Parse Map literal; if first is null:
  **   cur must be on lbracket
  ** else
  **   cur must be on colon of first key/value pair
  **
  private MapLiteralExpr mapLiteralExpr(Loc loc, CType? explicitType, Expr? first)
  {
    // explicitType is *the* map type: Str:Str[,]
    if (explicitType != null && !explicitType.isMap)
    {
      err("Invalid map type '$explicitType' for map literal", loc)
      explicitType = null
    }

    map := MapLiteralExpr(loc, explicitType)

    // if first is null, must be on lbracket
    if (first == null)
    {
      consume(Token.lbracket)

      // if [,] empty list
      if (curt === Token.colon)
      {
        consume
        consume(Token.rbracket)
        return map
      }

      first = expr
    }

    map.keys.add(first)
    consume(Token.colon)
    map.vals.add(expr)
    while (curt === Token.comma)
    {
      consume
      if (curt === Token.rbracket) break // allow extra trailing comma
      map.keys.add(expr)
      consume(Token.colon)
      map.vals.add(expr)
    }
    consume(Token.rbracket)
    
    endLoc(map)
    return map
  }

//////////////////////////////////////////////////////////////////////////
// Closure
//////////////////////////////////////////////////////////////////////////

  **
  ** Attempt to parse a closure expression or return null if we
  ** aren't positioned at the start of a closure expression.
  **
  private ClosureExpr? tryClosure()
  {
    loc := cur.loc

    // if curly brace, then this is it-block closure
    if (curt === Token.lbrace) return tryItBlock

    // if not pipe then not closure
    if (curt !== Token.pipe) return null

    // otherwise this can only be a FuncType declaration,
    // so give it a whirl, and bail if that fails
    mark := pos
//    funcType := tryType as FuncType
    funcType := this.funcType(false)
//    if (funcType == null) { reset(mark); return null }

    // if we don't see opening brace for body - no go
    if (curt !== Token.lbrace) { reset(mark); return null }

    return closure(loc, funcType)
  }

  **
  ** Parse it-block closure.
  **
  private ClosureExpr? tryItBlock()
  {
    // field initializers look like an it-block, but
    // we can safely peek to see if the next token is "get",
    // "set", or a field getter/setter keyword like "private"
    if (inFieldInit)
    {
      if (peek.kind.isProtectionKeyword) return null
      if (peek.kind === Token.staticKeyword) return null
      if (peek.kind === Token.readonlyKeyword) return null
      if (peekt == Token.identifier)
      {
        if (peek.val == "get" || peek.val == "set") return null
      }
    }

    ib := closure(cur.loc, FuncTypeDef.makeItBlock(cur.loc, CType.objType(cur.loc).toNullable))
    ib.isItBlock = true
    //ib.itType = ns.error
    return ib
  }

  **
  ** Parse body of closure expression and return ClosureExpr.
  **
  private ClosureExpr closure(Loc loc, FuncTypeDef funcType)
  {
    if (curType == null || curSlot == null) throw err("Unexpected closure")

    // closure anonymous class name: class$slot$count
    name := "${curType.name}\$${curSlot.name}\$${curType.closures.size}"

    // verify func types has named parameters
    if (funcType.unnamed) err("Closure parameters must be named", loc)

    // create closure
    closure := ClosureExpr(loc, curType, curSlot, curClosure, funcType, name)

    // save all closures in global list and list per type
//    closures.add(closure)
    curType.closures.add(closure)

    // parse block; temporarily change curClosure
    oldClosure := curClosure
    curClosure = closure
    closure.code = block
    curClosure = oldClosure

    endLoc(closure)
    return closure
  }

  **
  ** This is used to parse an it-block outside of the scope of a
  ** field or method definition.  It is used to parse complex literals
  ** declared in a facet without mucking up the closure code path.
  **
  private Expr complexLiteral(Loc loc, CType ctype)
  {
    complex := ComplexLiteral(loc, ctype)
    consume(Token.lbrace)
    while (curt !== Token.rbrace)
    {
      complex.names.add(consumeId)
      consume(Token.assign)
      complex.vals.add(expr)
      endOfStmt
    }
    consume(Token.rbrace)
    endLoc(complex)
    return complex
  }

}
