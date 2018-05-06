//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Oct 06  Brian Frank  Creation
//

**
** ConstantFolder is used to implement constant folding optimizations
** where known literals and operations can be performed ahead of time
** by the compiler.
**
class ConstantFolder : CompilerSupport
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Constructor
  **
  new make(Compiler compiler)
    : super(compiler)
  {
  }

//////////////////////////////////////////////////////////////////////////
// Resolve
//////////////////////////////////////////////////////////////////////////

  **
  ** Check shortcut expression for constant folding
  **
  Expr fold(CallExpr call)
  {
    // there are certain methods we never optimize
    name := call.name
    if (never.containsKey(name)) return call

    // check if target is constant
    target := exprToConst(call.target)
    if (target == null) return call

    // check if all the parameters are constant
    Obj[]? args := null
    for (i:=0; i<call.args.size; ++i)
    {
      arg := exprToConst(call.args[i])
      if (arg == null) return call
      if (i == 0) args = [,]
      args.add(arg)
    }

    // everything is constant, so try to find an instance method
    method := target.typeof.method(name, false)
    if (method == null || method.isStatic) return call
    if (call.args.size != method.params.size)
    {
      if (call.args.size >= method.params.size ||
          !method.params[call.args.size].hasDefault)
        return call
    }

    // try to invoke the method to get the result
    Obj? result := null
    try
    {
      result = method.callOn(target, args)
    }
    catch
    {
      return call
    }

    // try to map result to literal
    return constToExpr(call, result)
  }

  private Obj? exprToConst(Expr? expr)
  {
    if (expr == null) return null
    switch (expr.id)
    {
      case ExprId.intLiteral:      return ((LiteralExpr)expr).val
      case ExprId.floatLiteral:    return ((LiteralExpr)expr).val
      case ExprId.decimalLiteral:  return ((LiteralExpr)expr).val
      case ExprId.strLiteral:      return ((LiteralExpr)expr).val
      case ExprId.durationLiteral: return ((LiteralExpr)expr).val
      default:                     return null
    }
  }

  private Expr constToExpr(Expr orig, Obj? val)
  {
    if (val == null)     return LiteralExpr(orig.loc, ExprId.nullLiteral, ns.objType.toNullable, null)
    if (val is Int)      return LiteralExpr(orig.loc, ExprId.intLiteral, ns.intType, val)
    if (val is Float)    return LiteralExpr(orig.loc, ExprId.floatLiteral, ns.floatType, val)
    if (val is Decimal)  return LiteralExpr(orig.loc, ExprId.decimalLiteral, ns.decimalType, val)
    if (val is Str)      return LiteralExpr(orig.loc, ExprId.strLiteral, ns.strType, val)
    if (val is Duration) return LiteralExpr(orig.loc, ExprId.durationLiteral, ns.durationType, val)
    return orig
  }

  private const static Str:Int never := ["compare":1, "equal":1, "hash":1, "intern":1, "toLocale":1, "fromLocale": 1]

}