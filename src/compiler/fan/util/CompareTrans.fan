
**
** convert compare op to method call
**
class CompareTrans : CompilerSupport
{
  new make(Compiler compiler)
    : super(compiler)
  {
  }

  Expr trans(ShortcutExpr call) {
    target := call.target
    firstArg := call.args.first
    switch (call.opToken)
    {
      case Token.eq:     return transCompareExpr(call.loc, target, call.opToken, firstArg)
      case Token.notEq:  return transCompareExpr(call.loc, target, call.opToken, firstArg)
      case Token.cmp:    return transCompareExpr(call.loc, target, call.opToken, firstArg)
      case Token.lt:     return transCompareExpr(call.loc, target, call.opToken, firstArg)
      case Token.ltEq:   return transCompareExpr(call.loc, target, call.opToken, firstArg)
      case Token.gt:     return transCompareExpr(call.loc, target, call.opToken, firstArg)
      case Token.gtEq:   return transCompareExpr(call.loc, target, call.opToken, firstArg)
    }
    return call
  }

  private Expr transCompareExpr(Loc loc, Expr l, Token opToken, Expr r) {
    //type cast
    if (l.ctype.toNonNullable != r.ctype.toNonNullable) {
      if (l.ctype.fits(r.ctype)) {
        r = TypeCheckExpr.coerce(r, l.ctype)
      }
      else {
        l = TypeCheckExpr.coerce(l, r.ctype)
      }
    }

    //compare with null
    expr := transRealCompareNullableExpr(loc, l, opToken, r)
    return expr
  }

  private Expr transRealCompareNullableExpr(Loc loc, Expr l, Token opToken, Expr r) {
    Obj lt := -1 // <
    Obj eq := 0  // ==
    Obj gt := 1  // >
    switch (opToken) {
      case Token.eq:
        lt = false
        eq = true
        gt = false
      case Token.notEq:
        lt = true
        eq = false
        gt = true
      case Token.cmp:
        lt = -1
      case Token.lt:
        lt = true
        eq = false
        gt = false
      case Token.ltEq:
        lt = true
        eq = true
        gt = false
      case Token.gt:
        lt = false
        eq = false
        gt = true
      case Token.gtEq:
        lt = false
        eq = true
        gt = true
    }

    real := transRealCompareExpr(loc, l, opToken, r)
    expr := real
    if (l.ctype.isNullable && !r.ctype.isNullable) {
      expr = TernaryExpr(
        UnaryExpr(loc, ExprId.cmpNull, Token.eq, l),
        Expr.makeForLiteral(loc, ns, lt),
        real
      )
    }
    else if (!l.ctype.isNullable && r.ctype.isNullable) {
      expr = TernaryExpr(
        UnaryExpr(loc, ExprId.cmpNull, Token.eq, r),
        Expr.makeForLiteral(loc, ns, gt),
        real
      )
    }
    else if (l.ctype.isNullable && r.ctype.isNullable) {
      t := TernaryExpr(
        UnaryExpr(loc, ExprId.cmpNull, Token.eq, r),
        Expr.makeForLiteral(loc, ns, eq),
        Expr.makeForLiteral(loc, ns, lt)
      )

      t2 := TernaryExpr(
        UnaryExpr(loc, ExprId.cmpNull, Token.eq, r),
        Expr.makeForLiteral(loc, ns, gt),
        real
      )

      expr = TernaryExpr(
        UnaryExpr(loc, ExprId.cmpNull, Token.eq, l),
        t,
        t2
      )
    }

    return expr
  }

  private Expr transRealCompareExpr(Loc loc, Expr l, Token opToken, Expr r) {
    if (l.ctype.toNonNullable.isJavaVal || r.ctype.toNonNullable.isJavaVal) {
      return ShortcutExpr.makeBinary(l, opToken, r)
    }

    switch (opToken) {
      case Token.eq:
        return transCompareMethodExpr(loc, l, opToken, r)
      case Token.notEq:
        expr := transCompareMethodExpr(loc, l, opToken, r)
        return UnaryExpr(loc, ExprId.boolNot, opToken, expr)
      case Token.cmp:
        return transCompareMethodExpr(loc, l, opToken, r)
      case Token.lt:
        expr := transCompareMethodExpr(loc, l, opToken, r)
        return TernaryExpr(
          ShortcutExpr.makeBinary(expr, Token.eq, Expr.makeForLiteral(loc, ns, -1)),
          LiteralExpr.makeTrue(loc, ns),
          LiteralExpr.makeFalse(loc, ns)
        )
      case Token.ltEq:
        expr := transCompareMethodExpr(loc, l, opToken, r)
        return TernaryExpr(
          ShortcutExpr.makeBinary(expr, Token.notEq, Expr.makeForLiteral(loc, ns, 1)),
          LiteralExpr.makeTrue(loc, ns),
          LiteralExpr.makeFalse(loc, ns)
        )
      case Token.gt:
        expr := transCompareMethodExpr(loc, l, opToken, r)
        return TernaryExpr(
          ShortcutExpr.makeBinary(expr, Token.eq, Expr.makeForLiteral(loc, ns, 1)),
          LiteralExpr.makeTrue(loc, ns),
          LiteralExpr.makeFalse(loc, ns)
        )
      case Token.gtEq:
        expr := transCompareMethodExpr(loc, l, opToken, r)
        return TernaryExpr(
          ShortcutExpr.makeBinary(expr, Token.notEq, Expr.makeForLiteral(loc, ns, -1)),
          LiteralExpr.makeTrue(loc, ns),
          LiteralExpr.makeFalse(loc, ns)
        )
    }
    throw Err("unreachable")
  }

  private Expr transCompareMethodExpr(Loc loc, Expr l, Token opToken, Expr r) {
    if (opToken == Token.eq) {
      method := l.ctype.method("equals")
      return CallExpr.makeWithMethod(loc, l, method, [r])
    }
    else if (opToken == Token.cmp) {
      method := l.ctype.method("compare")
      return CallExpr.makeWithMethod(loc, l, method, [r])
    }
    else {
      throw Err("unreachable")
    }
  }

}