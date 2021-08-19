
class CommonType {
  
  **
  ** Map the list of expressions into their list of types
  **
  static CType[] ctypes(Expr[] exprs)
  {
    return exprs.map |Expr e->CType| { e.ctype }
  }
  
  **
  ** Given a list of Expr instances, find the common base type
  ** they all share.  This method does not take into account
  ** the null literal.  It is used for type inference for lists
  ** and maps.
  **
  static CType commonType(CNamespace ns, Expr[] exprs)
  {
    hasNull := false
    exprs = exprs.exclude |Expr e->Bool|
    {
      if (e.id !== ExprId.nullLiteral) return false
      hasNull = true
      return true
    }
    t := common(ns, ctypes(exprs))
    if (hasNull) t = t.toNullable
    return t
  }
  
  **
  ** Given a list of types, compute the most specific type which they
  ** all share, or at worst return sys::Obj.  This method does not take
  ** into account mixins, only extends class inheritance.
  **
  public static CType common(CNamespace ns, CType[] types)
  {
    // special handling for nothing
    if (types.size == 2)
    {
      if (types[0].isNothing) return types[1]
      if (types[1].isNothing) return types[0]
    }

    // special handling for zero or one types
    if (types.size == 0) return ns.objType.toNullable
    if (types.size == 1) return types.first

    // first-pass iteration is used to:
    //   - check if any one of the types is nullable
    //   - check if any of the types is a parameterized generic
    //   - normalize our types to non-nullable
    mixins := false
    nullable := false
    parameterized := false
    types = types.dup
    types.each |t, i|
    {
      if (t.isParameterized) parameterized = true
      if (t.isNullable) nullable = true
      if (t.isMixin) mixins = true
      types[i] = t.toNonNullable
    }

    // if any one of the items is parameterized then we handle it
    // specially, otherwise we find the most common class
    CType? best
//    if (parameterized)
//      best = commonParameterized(ns, types)
//    else 
    if (mixins)
      best = commonMixin(ns, types)
    else
      best = commonClass(ns, types)

    // if any one of the items was nullable, then whole result is nullable
    return nullable ? best.toNullable : best
  }

  private static CType commonClass(CNamespace ns, CType[] types)
  {
    best := types[0]
    for (Int i:=1; i<types.size; ++i)
    {
      t := types[i]
      while (!t.fits(best))
      {
        bestBase := best.base
        if (bestBase == null) return ns.objType
        best = bestBase
      }
    }
    return best
  }

  private static CType commonMixin(CNamespace ns, CType[] types)
  {
    // mixins must all be same type or else we fallback to Obj
    first := types[0]
    allSame := types.all |t| { t == first }
    return allSame ? first : ns.objType
  }

//  private static CType commonParameterized(CNamespace ns, CType[] types)
//  {
//    // we only support common inference on parameterized lists
//    // since they are one dimensional in their parameterization,
//    // all other inference is based strictly on exact type
//    allList := true
//    allMap  := true
//    allFunc := true
//    types.each |t|
//    {
//      allList = allList && t is ListType
//      allMap  = allMap  && t is MapType
//      allFunc = allFunc && t is FuncType
//    }
//    if (allList) return commonList(ns, types)
//    if (allMap)  return commonExact(ns, types, ns.mapType)
//    if (allFunc) return commonExact(ns, types, ns.funcType)
//    return ns.objType
//  }
//
//  private static CType commonList(CNamespace ns, ListType[] types)
//  {
//    vTypes := types.map |t->CType| { t.v }
//    return common(ns, vTypes).toListOf
//  }
//
//  private static CType commonExact(CNamespace ns, CType[] types, CType fallback)
//  {
//    // we only infer func types based strictly on exact type
//    first := types[0]
//    exact := types.all |t| { first == t }
//    return exact ? first : fallback
//  }
}
