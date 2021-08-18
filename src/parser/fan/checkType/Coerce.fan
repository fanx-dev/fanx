
mixin Coerce {
  **
  ** Return if `coerce` would not report a compiler error.
  **
  static Bool canCoerce(Expr expr, CType expected)
  {
    ok := true
    coerce(expr, expected) |->| {
      ok = false
    }
    return ok
  }
  
  **
  ** Coerce the target expression to the specified type.  If
  ** the expression is not type compatible run the onErr function.
  **
  static Expr coerce(Expr expr, CType expected, |->| onErr)
  {
    // route to bridge for FFI coercion if either side if foreign
    if (expected.typeDef.isForeign) return expected.typeDef.bridge.coerce(expr, expected, onErr)
    if (expr.ctype.typeDef.isForeign) return expr.ctype.typeDef.bridge.coerce(expr, expected, onErr)

    // normal Fantom coercion behavior
    return doCoerce(expr, expected, onErr)
  }

  **
  ** Coerce the target expression to the specified type.  If
  ** the expression is not type compatible run the onErr function.
  ** Default Fantom behavior.
  **
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
//      if (isFuncAutoCoerce(actual, expected))
//         return TypeCheckExpr.coerce(expr, expected)
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
  
  static Bool isFuncAutoCoerce(CType actual, CType expected)
  {
    // check if both are function types
    if (!actual.isFunc || !expected.isFunc) return false

    // auto-cast to or from unparameterized 'sys::Func'
    if (actual.genericArgs == null || expected.genericArgs == null) return true

    // if actual function requires more parameters than
    // we are expecting, then this cannot be a match
    if (actual.genericArgs.size > expected.genericArgs.size) return false

    // match return type (if void is needed, anything matches)
    if (!expected.funcRet.isVoid) {
        // check return type
        if (!isFuncAutoCoerceMatch(actual.funcRet, expected.funcRet))
            return false
    }

    // check that each parameter is auto-castable
    return actual.funcParams.all |CType actualParam, Int i->Bool|
    {
      expectedParam := expected.genericArgs[i+1]
      return isFuncAutoCoerceMatch(actualParam, expectedParam)
    }

    return true
  }

  private static Bool isFuncAutoCoerceMatch(CType actual, CType expected)
  {
    if (actual.fits(expected)) return true
    if (expected.fits(actual)) return true
    if (isFuncAutoCoerce(actual, expected)) return true
    return false
  }
  
  static Bool needCoerce(CType from, CType to)
  {
    //always cast for generic
    if (from.isParameterized || to.isParameterized) return true

    // if either side is a value type and we got past
    // the equals check then we definitely need a coercion
    if (from.isVal || to.isVal) return true

    // if going from Obj? -> Obj we need a nullable coercion
    if (!to.isNullable) return from.isNullable

    return false
  }
}
