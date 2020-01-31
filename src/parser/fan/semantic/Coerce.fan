
class Coerce {
  
  static Expr doCoerce(Expr expr, CType expected, |->| onErr)
  {
    // sanity check that expression has been typed
    CType actual := expr.ctype
    if ((Obj?)actual == null) throw NullErr("null ctype: ${expr}")

    // if the same type this is easy
    if (actual == expected) return expr

    // if actual type is nothing, then its of no matter
    if (actual.isNothing) return expr

    // we can never use a void expression
    if (actual.isVoid || expected.isVoid)
    {
      onErr()
      return expr
    }

    // if expr is always nullable (null literal, safe invoke, as),
    // then verify expected type is nullable
    if (expr.isAlwaysNullable)
    {
      if (!expected.isNullable) { onErr(); return expr }

      // null literals don't need cast to nullable types,
      // otherwise // fall-thru to apply coercion
      if (expr.id === ExprId.nullLiteral) return expr
    }

    // if the expression fits to type, that is ok
    if (actual.fits(expected))
    {
      // if we have any nullable/value difference we need a coercion
      if (needCoerce(actual, expected))
        return TypeCheckExpr.coerce(expr, expected)
      else
        return expr
    }

    // if we can auto-cast to make the expr fit then do it - we
    // have to treat function auto-casting a little specially here
    if (actual.isFunc && expected.isFunc)
    {
      // if (isFuncAutoCoerce(actual, expected))
      //   return TypeCheckExpr.coerce(expr, expected)
    }
    else
    {
      if (expected.fits(actual))
        return TypeCheckExpr.coerce(expr, expected)
    }

    // we have an error condition
    onErr()
    return expr
  }
  
  static Bool needCoerce(CType from, CType to)
  {
    //TODO fix
    //always cast for generic
//    if (from.isParameterized || to.isParameterized) return true

    // if either side is a value type and we got past
    // the equals check then we definitely need a coercion
    if (from.isVal || to.isVal) return true

    // if going from Obj? -> Obj we need a nullable coercion
    if (!to.isNullable) return from.isNullable

    return false
  }
}
