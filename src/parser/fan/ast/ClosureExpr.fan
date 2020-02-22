//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Jul 06  Brian Frank  Creation
//


class FuncTypeDef : Node {
  
  CType typeRef
  
  new make(Loc loc, CType[] params, Str[] names, CType ret, Bool defaultParameterized := false)
   : super(loc)
  {
    typeRef = CType.funcType(loc, params, ret)
    this.params = params
    this.names  = names
    this.ret    = ret
  }
  
  new makeItBlock(Loc loc, CType itType)
    : this.make(loc, [itType], ["it"], CType.voidType(loc))
  {
    // sanity check
    if (itType.isThis) throw Err("Invalid it-block func signature: $this")
  }
  
  override Void print(AstWriter out)
  {
    out.w(toStr)
  }
  
  override Str toStr() {
    s := StrBuf()
    s.add("|")
    params.size.times |i| {
      if (i > 0) s.add(", ")
      s.add(names.getSafe(i)).add(" : ").add(params[i])
    }
    s.add(" -> ").add(ret).add("|")
    return s.toStr
  }
  
  ParamDef[] toParamDefs(Loc loc)
  {
    p := ParamDef[,]
    p.capacity = params.size
    for (i:=0; i<params.size; ++i)
    {
      p.add(ParamDef(loc, params[i], names[i]))
    }
    return p
  }
  
  CType[] params // a, b, c ...
  Str[] names    { private set } // parameter names
  CType ret // return type
  Bool unnamed                   // were any names auto-generated
  Bool inferredSignature   // were one or more parameters inferred
}


**************************************************************************
** ClosureExpr
**************************************************************************

**
** ClosureExpr is an "inlined anonymous method" which closes over it's
** lexical scope.  ClosureExpr is placed into the AST by the parser
** with the code field containing the method implementation.  In
** InitClosures we remap a ClosureExpr to an anonymous class TypeDef
** which extends Func.  The function implementation is moved to the
** anonymous class's doCall() method.  However we leave ClosureExpr
** in the AST in it's original location with a substitute expression.
** The substitute expr just creates an instance of the anonymous class.
** But by leaving the ClosureExpr in the tree, we can keep track of
** the original lexical scope of the closure.
**
class ClosureExpr : Expr
{
  new make(Loc loc, TypeDef enclosingType,
           SlotDef enclosingSlot, ClosureExpr? enclosingClosure,
           FuncTypeDef signature, Str name)
    : super(loc, ExprId.closure)
  {
//    this.ctype            = signature
    this.enclosingType    = enclosingType
    this.enclosingSlot    = enclosingSlot
    this.enclosingClosure = enclosingClosure
    this.signature        = signature
    this.name             = name
  }

//  once CField outerThisField()
//  {
//    if (enclosingSlot.isStatic) throw Err("Internal error: $loc.toLocStr")
//    //TODO
//    throw Err("TODO")
//    //return ClosureVars.makeOuterThisField(this)
//  }

  override Str toStr()
  {
    return "$signature { ... }"
  }

  override Void print(AstWriter out)
  {
    out.w(signature.toStr)
//    if (substitute != null)
//    {
//      out.w(" { substitute: ")
//      substitute.print(out)
//      out.w(" }").nl
//    }
//    else
//    {
      out.nl
      code.print(out)
//    }
  }

//  override Bool isDefiniteAssign(|Expr lhs->Bool| f)
//  {
//    // at this point, we have moved code into doCall method
//    if (doCall == null) return false
//    return doCall.code.isDefiniteAssign(f)
//  }

  Expr toWith(Expr target, CMethod with)
  {
    if (target.ctype != null) setInferredSignature(FuncTypeDef.makeItBlock(target.loc, target.ctype).typeRef)
    x := CallExpr(loc, target, "with") { args = Expr[this] }
    x.method = with
    x.ctype = with.returnType
    // TODO: this coercion should be added automatically later in the pipeline
    if (target.ctype == null) return x
    return TypeCheckExpr.coerce(x, target.ctype)
  }

  Void setInferredSignature(CType t)
  {
    // bail if we didn't expect an inferred the signature
    // or haven't gotten to InitClosures yet
//    if (cls == null) return

    delArity := signature.params.size-1
    inferredArity := t.genericArgs.size-1
    if (!signature.inferredSignature && delArity == inferredArity) {
      return
    }
    
    signature.params = t.genericArgs[1..-1]
    ctype = t

    // between the explicit signature and the inferred
    // signature, take the most specific types; this is where
    // we take care of functions with generic parameters like V
//    if (delArity <= inferredArity) {
//      if (delArity < inferredArity) {
//        addParams := CType[,]
//        for (i:=delArity; i<inferredArity; ++i) {
//          ptype := t.params[i]
//          addParams.add(ptype)
//          //echo(doCall.params)
//          doCall.paramDefs.add(ParamDef(loc, ptype, "ignoreparam\$$i"))
//        }
//        collapseExprAndParams(call, addParams)
//      }
//      t = t.toArity(((FuncType)cls.base).arity)
//      t = signature.mostSpecific(t, signature.inferredSignature)
//    }
//    else if (isItBlock && t.arity == 0) {
//      call.paramDefs.clear
//      c := CallExpr.makeWithMethod(loc, ThisExpr(loc), doCall, [LiteralExpr.makeNull(loc)])
//      call.code.stmts.clear
//      if (t.ret.isVoid) {
//         call.code.add(c.toStmt)
//         call.code.add(ReturnStmt.makeSynthetic(loc, LiteralExpr.makeNull(loc)))
//      }
//      else {
//         call.code.add(ReturnStmt.makeSynthetic(loc, c))
//      }
//    }
//    else {
//      return
//    }
//
//    // sanity check
//    if (t.usesThis)
//      throw Err("Inferring signature with un-parameterized this type: $t")
//
//    // update my signature and the doCall signature
//    signature = t
//    ctype = t
//    if (doCall != null)
//    {
//      // update parameter types
//      doCall.paramDefs.each |ParamDef p, Int i|
//      {
//        if (i < signature.params.size)
//          p.paramType = signature.params[i]
//      }
//
//      // update return, we might have to translate an single
//      // expression statement into a return statement
//      if (doCall.ret.isVoid && !t.ret.isVoid)
//      {
//        doCall.ret = t.ret
//        collapseExprAndReturn(doCall)
//        collapseExprAndReturn(call)
//      }
//    }
//
//    // if an itBlock, set type of it
//    if (isItBlock) itType = t.params.first
//
//    // update base type of Func subclass
//    cls.base = t
//    ctype = t
  }

  Void collapseExprAndParams(MethodDef m, CType[] addParams)
  {
    addParams.each |ptype, i| {
      m.paramDefs.add(ParamDef(loc, CType.objType(loc).toNullable, "ignoreparam\$$i"))
    }

    stmt := m.code.stmts.first
    CallExpr? call
    if (stmt is ReturnStmt) {
      call = ((ReturnStmt)stmt).expr
    }
    else {
      call = ((ExprStmt)stmt).expr
    }

    addParams.each |ptype, i| {
      arg := UnknownVarExpr(m.loc, null, "ignoreparam\$$i")
      carg := TypeCheckExpr.coerce(arg, ptype)
      call.args.add(carg)
    }
  }

  Void collapseExprAndReturn(MethodDef m)
  {
    code := m.code.stmts
    if (code.size != 2) return
    if (code[0].id !== StmtId.expr) return
    if (code[1].id !== StmtId.returnStmt) return
    if (!((ReturnStmt)code.last).isSynthetic) return
    expr := ((ExprStmt)code.first).expr
    code.set(0, ReturnStmt.makeSynthetic(expr.loc, expr))
    code.removeAt(1)
  }

  // Parse
  TypeDef enclosingType         // enclosing class
  SlotDef enclosingSlot         // enclosing method or field initializer
  ClosureExpr? enclosingClosure // if nested closure
  FuncTypeDef signature            // function signature
  Block? code                   // moved into a MethodDef in InitClosures
  Str name                      // anonymous class name
  Bool isItBlock                // does closure have implicit it scope

  /*
  // InitClosures
  Expr? substitute          // expression to substitute during assembly
  TypeDef? cls                  // anonymous class which implements the closure
  MethodDef? call               // anonymous class's call() with code
  MethodDef? doCall             // anonymous class's doCall() with code

  // ResolveExpr
  [Str:MethodVar]? enclosingVars // my parent methods vars in scope
  //Bool setsConst                 // sets one or more const fields (CheckErrors)
//  CType? itType                  // type of implicit it
  */
  
  CType? followCtorType          // follow make a new Type
}
