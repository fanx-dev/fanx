
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

    if (target.ctype == firstArg.ctype && !target.ctype.isNullable && target.ctype.isVal) {
      return call
    }

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
    expr := nullableCompare(loc, l, opToken, r)
    //echo("debug:"+expr)
    return expr
  }

  private Expr nullableCompare(Loc loc, Expr l, Token opToken, Expr r) {
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

    real := realCompare(loc, l, opToken, r)
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

  private Expr realCompare(Loc loc, Expr l, Token opToken, Expr r) {
    //for struct type
    if (l.ctype.toNonNullable.isVal || r.ctype.toNonNullable.isVal) {
      if (l.ctype.isNullable) {
        l = TypeCheckExpr.coerce(l, l.ctype.toNonNullable)
      }
      if (r.ctype.isNullable) {
        r = TypeCheckExpr.coerce(r, r.ctype.toNonNullable)
      }

      if (l.ctype.toNonNullable.isJavaVal || r.ctype.toNonNullable.isJavaVal) {
        return ShortcutExpr.makeBinary(l, opToken, r)
      }
      else {
        base := toMethodForVal(loc, l, Token.cmp, r)
        if (base == null) {
          //TODO auto gen for struct type
          base = ShortcutExpr.makeBinary(l, opToken, r)
        }
        return makeFromBaseCompare(loc, base, opToken)
      }
    }

    //for class type
    switch (opToken) {
      case Token.eq:
        return toMethod(loc, l, Token.eq, r)
      case Token.notEq:
        expr := toMethod(loc, l, Token.eq, r)
        return UnaryExpr(loc, ExprId.boolNot, opToken, expr)
      case Token.cmp:
        return toMethod(loc, l, Token.cmp, r)
      default:
        base := toMethod(loc, l, Token.cmp, r)
        return makeFromBaseCompare(loc, base, opToken)
    }
  }

  private Expr makeFromBaseCompare(Loc loc, Expr expr, Token opToken) {
    switch (opToken) {
      case Token.eq:
        return TernaryExpr(
          ShortcutExpr.makeBinary(expr, Token.eq, Expr.makeForLiteral(loc, ns, 0)),
          LiteralExpr.makeTrue(loc, ns),
          LiteralExpr.makeFalse(loc, ns)
        )
      case Token.notEq:
        return TernaryExpr(
          ShortcutExpr.makeBinary(expr, Token.notEq, Expr.makeForLiteral(loc, ns, 0)),
          LiteralExpr.makeTrue(loc, ns),
          LiteralExpr.makeFalse(loc, ns)
        )
      case Token.cmp:
        return expr
      case Token.lt:
        return TernaryExpr(
          ShortcutExpr.makeBinary(expr, Token.lt, Expr.makeForLiteral(loc, ns, 0)),
          LiteralExpr.makeTrue(loc, ns),
          LiteralExpr.makeFalse(loc, ns)
        )
      case Token.ltEq:
        return TernaryExpr(
          ShortcutExpr.makeBinary(expr, Token.ltEq, Expr.makeForLiteral(loc, ns, 0)),
          LiteralExpr.makeTrue(loc, ns),
          LiteralExpr.makeFalse(loc, ns)
        )
      case Token.gt:
        return TernaryExpr(
          ShortcutExpr.makeBinary(expr, Token.gt, Expr.makeForLiteral(loc, ns, 0)),
          LiteralExpr.makeTrue(loc, ns),
          LiteralExpr.makeFalse(loc, ns)
        )
      case Token.gtEq:
        return TernaryExpr(
          ShortcutExpr.makeBinary(expr, Token.gtEq, Expr.makeForLiteral(loc, ns, 0)),
          LiteralExpr.makeTrue(loc, ns),
          LiteralExpr.makeFalse(loc, ns)
        )
    }
    throw Err("unreachable")
  }

  private Expr toMethod(Loc loc, Expr l, Token opToken, Expr r) {
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

  private Expr? toMethodForVal(Loc loc, Expr l, Token opToken, Expr r) {
    if (opToken == Token.eq) {
      method := l.ctype.method("equalsVal")
      if (method == null) return null
      return CallExpr.makeWithMethod(loc, l, method, [r])
    }
    else if (opToken == Token.cmp) {
      method := l.ctype.method("compareVal")
      if (method == null) return null
      return CallExpr.makeWithMethod(loc, l, method, [r])
    }
    else {
      throw Err("unreachable")
    }
  }

}