//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//    5 Sep 06  Brian Frank  Ported from Java to Fan
//

**
** CallResolver handles the process of resolving a CallExpr or
** UnknownVarExpr to a method call or a field access.
**
class CallResolver
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Construct with NameExpr (base class of CallExpr and UnknownVarExpr)
  **
  new make(CompilerContext compiler, TypeDef? curType, MethodDef? curMethod, NameExpr expr, ClosureExpr? curClosure)
  {
    this.compiler = compiler
    this.curType   = curType
    this.curMethod = curMethod
    this.curClosure = curClosure
    this.expr      = expr
    this.loc       = expr.loc
    this.target    = expr.target
    this.name      = expr.name

    call := expr as CallExpr
    if (call != null)
    {
      this.isVar   = false
      this.isItAdd = call.isItAdd
      this.args    = call.args
      this.found   = call.method
    }
    else
    {
      this.isVar = true
      this.args  = Expr[,]
    }
  }

//////////////////////////////////////////////////////////////////////////
// Resolve
//////////////////////////////////////////////////////////////////////////

  **
  ** Resolve into a method call or field access
  **
  Expr resolve()
  {
    try
    {
//      if (isStaticLiteral) return result
      resolveBase
      find
      if (result != null) return result
      insertImplicitThisOrIt
      resolveToExpr
      inferClosureType
      resolveForeign
      //TODO ConstantFolder
//      constantFolding
      castForThisType
      safeToNullable
      ffiCoercion
      return result
    }
    catch (CompilerErr err)
    {
      expr.ctype = compiler.ns.error
      return expr
    }
  }

//////////////////////////////////////////////////////////////////////////
// Static Literal
//////////////////////////////////////////////////////////////////////////

  **
  ** If this is a standalone name without a base target
  ** such as "Foo" and the name maps to a type name, then
  ** this is a type literal.
  **
//  Bool isStaticLiteral()
//  {
//    if (target == null)
//    {
//      stypes := curType.unit.importedTypes[name]
//
//      // if more then, one first try to exclude those internal to other pods
//      if (stypes != null && stypes.size > 1)
//        stypes.exclude |t| { t.isInternal && t.podName != compiler.pod.name }
//
//      if (stypes != null && !stypes.isEmpty)
//      {
//        if (stypes.size > 1)
//          compiler.log.err("Ambiguous type: " + stypes.join(", "), loc)
//        
//        staticTargetExpr := StaticTargetExpr(loc, stypes.first)
//        staticTargetExpr.ctype = stypes.first
//        call := expr as CallExpr
//        if (call != null) {
//          expr = CallExpr(loc, staticTargetExpr, "<ctor>", ExprId.construction)
//          name = "<ctor>"
//          target = staticTargetExpr
//          ((CallExpr)expr).args = call.args
//        }
//        else {
//          result = staticTargetExpr
//        }
//        
//        return true
//      }
//    }
//    return false
//  }

//////////////////////////////////////////////////////////////////////////
// Resolve Base
//////////////////////////////////////////////////////////////////////////

  **
  ** Resolve the base type which defines the slot we are calling.
  **
  Void resolveBase()
  {
    // if target unspecified, then assume a slot on the current
    // class otherwise the slot must be on the target type
    if (target == null)
    {
      // if we are in a closure - then base is the enclosing class;
      // if closure is it-block when we need to keep track of it too
      if (curClosure != null)
      {
        base = curType.asRef
        if (curClosure.isItBlock) baseIt = curClosure.signature.params[0]
      }
      else
      {
        base = curType.asRef
      }
    }
    else
    {
      base = target.ctype
    }

    // if base is the error type, then we already logged an error
    // trying to resolve the target and it's pointless to continue
    if (base.isError) throw CompilerErr("ignore", loc, null)

    // sanity check
    if (base == null) compiler.log.err("Internal error", loc)
  }

//////////////////////////////////////////////////////////////////////////
// Find
//////////////////////////////////////////////////////////////////////////

  **
  ** Find the method or field with the specified name.
  **
  Void find()
  {
    // if already "found", then skip this step
    if (found != null) return

    // look it up in base type
    found = findOn(base)

    // if we have an it in scope, then also attempt to resolve against it
    if (baseIt != null)
    {
      foundIt := findOn(baseIt)

      // if we found a match on both base and it, that is an error
      if (isAmbiguous(found, foundIt))
      {
        // if we detected ambiguity, but the current type doesn't have
        // visibility to access the baseIt slot, then ignore it
        if (!CheckErrors.isSlotVisible(curType, foundIt))
          { foundIt = null }
        else
          compiler.log.err("Ambiguous slot '$name' on both 'this' ($base) and 'it' ($baseIt)", loc)
      }

      // resolved against implicit it
      if (foundIt != null)
      {
        found = foundIt
        foundOnIt = true
      }
    }

    if (found == null && target == null) {
      founds := CSlot[,]
      findInheritedStatic(base, founds)
      if (founds.size > 1) {
        compiler.log.err("Ambiguous static methods: $founds", loc)
      }
      else if (founds.size == 1) {
        found = founds.first
      }
    }

    //try find extension methods
    //the extension method is not support safe call, e.g. obj?.foo
    if (found == null && target != null && target.id !== ExprId.staticTarget
      && !expr.isSafe) {
      try findExtesion(base)
      catch (Err e) e.trace
    }

    // if still not found, then error
    if (found == null)
    {
      if (isVar)
      {
        if (target == null)
          throw compiler.log.err("Unknown variable '$name'", loc)
        else
          throw compiler.log.err("Unknown slot '$errSig'", loc)
      }
      else
      {
        ct := target as CallExpr
        if (ct != null && ct.isItAdd)
          throw compiler.log.err("'$ct.method.qname' must return This", loc)
        else if (this.isItAdd)
          throw compiler.log.err("No comma operator method found: '$errSig'", loc)
        else
          throw compiler.log.err("Unknown method '$errSig'", loc)
      }
    }
  }

  private CSlot? findOn(CType base)
  {
    // if base is the error type, short circuit
    if (base.isError) return null

    // attempt to resolve the slot by name
    found := base.slot(name)
    if (found == null) return null

    // if the resolved slot is on a FFI type then we have to
    // delegate back to bridge because we might support both methods
    // and fields overloaded by the same name
    if (found.isForeign)
      found = found.parent.bridge.resolveSlotAccess(base, name, isVar)

    // if we resolve a method call against a field that is an error,
    // unless the field is a function in which case this is sugar
    // for field.call(...)
    if (found is CField && !isVar)
    {
      field := (CField)found
      if (field.fieldType.isFunc)
        isFuncFieldCall = true
      else
        compiler.log.err("Expected method, not field '$errSig'", loc)
    }

    return found
  }

  private Void findInheritedStatic(CType type, CSlot[] founds) {
    found := type.slot(name)
    if (found != null && found.isStatic && !founds.contains(found)) {
      founds.add(found)
    }

    if (type.isObj) return
    if (type.base != null) {
      findInheritedStatic(type.base, founds)
    }

    type.mixins.each {
      findInheritedStatic(it, founds)
    }
  }

  private Bool findExtesion(CType base) {
    meths := curType.unit.extensionMethods[name]
    if (meths == null) return false

    founds := CMethod[,]
    meths.each |m| {
      param := m.params.first
      if (param == null) return
      CType paramType := param.paramType
      while (true) {
        if (base.fits(paramType)) {
          founds.add(m)
          break
        }
        if (paramType.isObj) break
        paramType = paramType.base
      }
    }

    if (founds.size == 0) return false
    else if (founds.size > 1) {
      compiler.log.err("Ambiguous extension methods: $founds", loc)
    }

    found = founds.first
    args.insert(0, target)
    target = StaticTargetExpr(loc, found.parent.asRef)

    return true
  }

  private Bool isAmbiguous(CSlot? onBase, CSlot? onIt)
  {
    // unless we found on both base and baseIt, it is not ambiguous
    if (onBase == null || onIt == null) return false

    // if they are both the same static method, it doesn't matter
    if (onBase.qname == onIt.qname && onBase.isStatic) return false

    // if we are calling an instance slot in a static context,
    // then we can assume that we are binding to it
    if (!onBase.isStatic && !onIt.isStatic && curClosure.enclosingSlot.isStatic)
      return false

    return true
  }

  private Str errSig() { "${base.qname}.${name}" }

//////////////////////////////////////////////////////////////////////////
// Implicit This
//////////////////////////////////////////////////////////////////////////

  **
  ** If the call has no explicit target, and is a instance field
  ** or method, then we need to insert an implicit this or it.
  **
  private Void insertImplicitThisOrIt()
  {
    if (target != null) return
    if (found.isStatic || found.isCtor) return
    if (curMethod.isStatic) return

    if (foundOnIt)
    {
      target = ItExpr(loc) { enclosingClosure = curClosure }
      target.ctype = baseIt
    }
//    else if (curClosure != null)
//    {
//      closure := curClosure
//      if (!closure.enclosingSlot.isStatic)
//        target = FieldExpr(loc, ThisExpr(loc), "\$this")
//    }
    else
    {
      target = ThisExpr(loc)
      target.ctype = curType.asRef
    }
  }

//////////////////////////////////////////////////////////////////////////
// Resolve Expr Type
//////////////////////////////////////////////////////////////////////////

  **
  ** Compute the expression type the call itself (what gets left on the stack).
  **
  private Void resolveToExpr()
  {
    if (found is CField)
    {
      result = resolveToFieldExpr
      if (isFuncFieldCall)
      {
        callMethod := ((CField)found).fieldType.method("call")
        result = CallExpr.makeWithMethod(loc, result, callMethod, args)
      }
    }
    else
    {
      result = resolveToCallExpr
    }
  }

  private CallExpr resolveToCallExpr()
  {
    method := (CMethod)found

    call := expr as CallExpr
    if (call == null)
    {
      call = CallExpr(loc)
      call.name   = name
      call.args   = args
    }
    call.target   = target
    call.isSafe   = expr.isSafe
    call.noParens = isVar

    call.method = method
    if (method.isInstanceCtor) {
      if (expr.target != null) {
        //echo("$expr.typeof $expr $expr.target")
        //echo("$expr.loc.file $expr.loc.line")
        call.ctype = expr.target.ctype
      }
      else {
       call.ctype = method.parent.asRef
      }
    }
    else
      call.ctype = method.returnType

    //rewrite for async method
    if (method.flags.and(FConst.Async) != 0 && method.parent.podName == compiler.pod.name) {
      call.ctype = CType.asyncType(loc) { genericArgs = [call.ctype] }
    }

    return call
  }

  private FieldExpr resolveToFieldExpr()
  {
    f := (CField)found

    field := FieldExpr(loc, target, name)
    field.len = expr.len
//    field.target = target
//    field.name   = name
    field.field  = f
    field.ctype  = f.fieldType
    field.isSafe = expr.isSafe

    return field
  }

//////////////////////////////////////////////////////////////////////////
// Infer Closure Type
//////////////////////////////////////////////////////////////////////////

  **
  ** If the last argument to the resolved call is a closure,
  ** then use the method to infer the function type
  **
  private Void inferClosureType()
  {
    if (result is CallExpr)
    {
      base := foundOnIt ? this.baseIt : this.base
      result = inferClosureTypeFromCall(compiler, result, base)
    }
  }

  **
  ** If the last argument to the resolved call is a closure,
  ** then use the method to infer the function type.  If the
  ** last arg is a closure, but the call doesn't take a closure,
  ** then translate into an implicit call to Obj.with
  **
  static Expr inferClosureTypeFromCall(CompilerContext support, CallExpr call, CType base)
  {
    ClosureExpr? lastC := null
    lastOk := false
    call.args.each |arg, i| {
      // check if last argument is closure
      c := arg as ClosureExpr
      if (i == call.args.size - 1) lastC = c
      if (c == null) return

      // if the resolved slot is a method where the last param
      // is expected to be a function type, then use that to
      // infer the type signature of the closure
      m := call.method
      paramType := m.params.getSafe(i)?.paramType
      if (paramType != null && paramType.isFunc)
      {
        if (call.method.name == "with")
          paramType = FuncTypeDef.makeItBlock(call.loc, base).typeRef
        else
          paramType = paramType.parameterizeThis(base)
        c.setInferredSignature(paramType)
        
        //re resolve after modify
        support.ns.resolveTypeRef(c.ctype, c.loc)
        if (lastC != null) lastOk = true
      }
    }

    if (lastC != null && lastC.isItBlock && call.method.isInstanceCtor) lastC.followCtorType = base

    // otherwise if the closure is an it-block, we infer
    // its type to be the result of the target expression
    if (!lastOk && lastC != null && lastC.isItBlock)
    {
      // if call is This, switch it to base (passes thru to toWith)
      if (call.ctype.isThis) call.ctype = base

      // can't chain it-block if call returns Void
      if (call.ctype.isVoid)
      {
        support.log.err("Cannot apply it-block to Void expr", call.loc)
        return call
      }

      // remove the function parameter and turn this into:
      //  call(args).toWith(c)
      call.args.removeAt(-1)
      expr := lastC.toWith(call, support.ns.objWith)
      
      //re resolve after modify
      support.ns.resolveTypeRef(lastC.ctype, lastC.loc)
      
      return expr
    }
    return call
  }

//////////////////////////////////////////////////////////////////////////
// FFI
//////////////////////////////////////////////////////////////////////////

  **
  ** If we have a FFI call, then give the foreign bridge a chance
  ** to resolve the method and deal with method overloading.  Note
  ** at this point we've already resolved the call by name to *some*
  ** method (in the find step).  But this callback gives the bridge
  ** a chance to resolve to the *correct* overloaded method.  We need
  ** to this during ResolveExpr in order to infer local variables
  ** correctly.
  **
  private Void resolveForeign()
  {
    bridge := found.isForeign
    if (bridge && result is CallExpr)
      result = found.bridge.resolveCall(result)
  }

//////////////////////////////////////////////////////////////////////////
// Constant Folding
//////////////////////////////////////////////////////////////////////////

  **
  ** If the epxression is a call, check for constant folding.
  **
//  private Void constantFolding()
//  {
//    // only do const folding on method calls (which inculdes shortcut ops)
//    call := result as CallExpr
//    if (call == null) return
//
//    // skip constant folding for testSys
//    if (curType != null && compiler.pod.name == "testSys") return
//
//    result = ConstantFolder(compiler).fold(call)
//  }

//////////////////////////////////////////////////////////////////////////
// Cast for This Type
//////////////////////////////////////////////////////////////////////////

  **
  ** If the epxression is a call which returns sys::This,
  ** then we need to insert an implicit cast.
  **
  private Void castForThisType()
  {
    // only care about calls that return This
    if (!result.ctype.isThis) return

    // check that we are calling a method
    method := found as CMethod
    if (method == null) return

    // the result of a method which returns This
    // is always the base target type - if we aren't
    // calling against the original declaring type
    // then we also need an implicit cast operation
    base := foundOnIt ? this.baseIt : this.base
    result.ctype = base
    if (method.inheritedReturnType != base)
      result = TypeCheckExpr.coerce(result, base) { from = method.inheritedReturnType }
  }

//////////////////////////////////////////////////////////////////////////
// Safe to Nullable
//////////////////////////////////////////////////////////////////////////

  **
  ** If the epxression is a safe call using "?.", then
  ** the resulting expression type is nullable.
  **
  private Void safeToNullable()
  {
    if (expr.isSafe)
    {
      result.ctype = result.ctype.toNullable
    }
  }

//////////////////////////////////////////////////////////////////////////
// FFI Coercion
//////////////////////////////////////////////////////////////////////////

  **
  ** If this field access or method call returns a type which
  ** isn't directly represented in the Fantom type system, then
  ** implicitly coerce it
  **
  private Void ffiCoercion()
  {
//    if (result.ctype.typeDef.isForeign)
//    {
//      foreign := result.ctype
//      inferred := foreign.inferredAs
//      if (foreign !== inferred)
//      {
//        result = foreign.bridge.coerce(result, inferred) |->|
//        {
//          throw err("Cannot coerce call return to Fantom type", loc)
//        }
//      }
//    }
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  TypeDef? curType     // current type of scope
  MethodDef? curMethod // current method of scope
  ClosureExpr? curClosure // current closure of scope. for resolve 'it'
  NameExpr expr        // original expression being resolved
  Loc loc              // location of original expression
  Expr? target         // target base or null
  Str name             // slot name to resolve
  Bool isItAdd         // are we resolving "," it-block add
  Bool isVar           // are we resolving simple variable
  Bool isFuncFieldCall // is this a field.call(...) on func field
  Expr[] args          // arguments or null if simple variable
  CType? base          // resolveBase()
  CType? baseIt        // resolveBase()
  CSlot? found         // find()
  Bool foundOnIt       // was find() resolved against it
  Expr? result         // resolveToExpr()

  CompilerContext compiler
}