//
// Copyright (c) 2019, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2019-11-15  Jed Young  Creation
//

class TypeErasure : CompilerStep
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(Compiler compiler)
    : super(compiler)
  {
  }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  override Void run()
  {
    log.debug("TypeErasure")
    walk(compiler, VisitDepth.expr)
    bombIfErr
  }


//////////////////////////////////////////////////////////////////////////
// Expr
//////////////////////////////////////////////////////////////////////////

  override Expr visitExpr(Expr expr)
  {
    switch (expr.id)
    { 
      case ExprId.call:
      case ExprId.construction:    return doCall(expr)
      case ExprId.shortcut:        return doShortcut(expr)
      case ExprId.field:           return loadField(expr)
      case ExprId.assign:          return doAssign(expr)
    }
    return expr
  }

  private Expr doCall(CallExpr call) {
    if (call.isDynamic) return call
    if (!call.method.isParameterized) return call

    method := call.method
    newArgs := call.args.dup
    params := method.params
    genericParams := method.generic.params

    type := method.parent
    if (type.qname == "sys::Array" || 
        type.qname == "sys::Func" ||
        type.qname == "sys::Ptr") {
      return call
    }

    // check each arg against each parameter
    params.each |CParam p, Int i|
    {
      if (genericParams[i].paramType.hasGenericParameter)
          newArgs[i] = box(newArgs[i])
    }
  
    call.args = newArgs


    if (call.leave) {
      if (method.isParameterized)
      {
        ret := method.generic.returnType
        if (ret.hasGenericParameter)
          return TypeCheckExpr.coerce(call, method.returnType) { from = ret.raw }
      }
    }
    return call
  }

  private Expr box(Expr expr)
  {
    if (expr.ctype.isVal)
      return TypeCheckExpr.coerce(expr, ns.objType.toNullable)
    else
      return expr
  }

  private Expr doShortcut(ShortcutExpr call) {
    switch (call.opToken)
    {
      case Token.eq:     return call
      case Token.notEq:  return call
      case Token.cmp:    return call
      case Token.lt:     return call
      case Token.ltEq:   return call
      case Token.gt:     return call
      case Token.gtEq:   return call
    }
    if (call.isStrConcat)
    {
      return call
    }

    if (call.isAssign)
    {
      return shortcutAssign(call)
    }

    // just process as normal call
    return this.doCall(call)
  }

  private Expr shortcutAssign(ShortcutExpr c) {
    //TODO
    return c
  }

  private Expr loadField(FieldExpr fexpr) {
    // if parameterized or covariant, then coerce
    field := fexpr.field
    if (field.isParameterized)
      return TypeCheckExpr.coerce(fexpr, field.fieldType) { from = ns.objType.toNullable }
    return fexpr
  }

  private Expr doAssign(BinaryExpr assign)
  {
    if (assign.lhs.id == ExprId.field)
    {
      field := (FieldExpr)assign.lhs
      if (field.field.isParameterized) {
        return box(assign.rhs)
      }
    }
    return assign
  }

}