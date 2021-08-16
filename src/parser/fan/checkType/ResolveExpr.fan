//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2 Dec 05  Brian Frank  Creation
//

**
** Walk the AST to resolve:
**   - Manage local variable scope
**   - Resolve loop for breaks and continues
**   - Resolve LocalDefStmt.init into full assignment expression
**   - Resolve Expr.ctype
**   - Resolve UknownVarExpr -> LocalVarExpr, FieldExpr, or CallExpr
**   - Resolve CallExpr to their CMethod
**
class ResolveExpr : CompilerStep
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(CompilerContext compiler)
    : super(compiler)
  {
  }

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  override Void run()
  {
    //log.debug("ResolveExpr")
    walk(compiler.cunits, VisitDepth.expr)
    //bombIfErr
  }

//////////////////////////////////////////////////////////////////////////
// Method
//////////////////////////////////////////////////////////////////////////

  override Void enterMethodDef(MethodDef m)
  {
    super.enterMethodDef(m)
    this.inClosure = (curType.isClosure && curType.closure.doCall === m)
    initMethodVars
  }

//////////////////////////////////////////////////////////////////////////
// Stmt
//////////////////////////////////////////////////////////////////////////

  override Void enterStmt(Stmt stmt) { stmtStack.push(stmt) }

  override Stmt[]? visitStmt(Stmt stmt)
  {
    stmtStack.pop
    switch (stmt.id)
    {
      case StmtId.expr:         resolveExprStmt((ExprStmt)stmt)
      case StmtId.forStmt:      resolveFor((ForStmt)stmt)
      case StmtId.breakStmt:    resolveBreak((BreakStmt)stmt)
      case StmtId.continueStmt: resolveContinue((ContinueStmt)stmt)
      case StmtId.localDef:     resolveLocalVarDef((LocalDefStmt)stmt)
    }
    return null
  }

  private Void resolveExprStmt(ExprStmt stmt)
  {
    // stand alone expr statements, shouldn't be left on the stack
    stmt.expr = stmt.expr.noLeave
  }

  private Void resolveLocalVarDef(LocalDefStmt def)
  {
    // check for type inference
    if (def.ctype == null)
      def.var_v.ctype = def.init.ctype//.inferredAs

    // bind to scope as a method variable
    bindToMethodVar(def)

    // if init is null, then we default the variable to null (Fan
    // doesn't do true definite assignment checking since most local
    // variables use type inference anyhow)
    if (def.init == null && !def.isCatchVar)
      def.init = LiteralExpr.makeDefaultLiteral(def.loc, def.ctype)

    // turn init into full assignment
    if (def.init != null)
      def.init = BinaryExpr.makeAssign(LocalVarExpr(def.loc, def.var_v), def.init)
  }

  private Void resolveFor(ForStmt stmt)
  {
    // don't leave update expression on the stack
    if (stmt.update != null) stmt.update = stmt.update.noLeave
  }

  private Void resolveBreak(BreakStmt stmt)
  {
    // find which loop we're inside of (checked in CheckErrors)
    stmt.loop = findLoop
  }

  private Void resolveContinue(ContinueStmt stmt)
  {
    // find which loop we're inside of (checked in CheckErrors)
    stmt.loop = findLoop
  }

//////////////////////////////////////////////////////////////////////////
// Expr
//////////////////////////////////////////////////////////////////////////

  override Expr visitExpr(Expr expr)
  {
    // resolve the expression
    expr = resolveExpr(expr)

    // expr type must be resolved at this point
    if ((Obj?)expr.ctype == null)
      throw err("Expr type not resolved: ${expr.id}: ${expr}", expr.loc)
      
    if (!expr.ctype.isResolved)
      ResolveType.doResolveType(this, expr.ctype)

    // if we resolved to a generic parameter like V or K,
    // then use its real underlying type
    if (expr.ctype.hasGenericParameter)
      expr.ctype = expr.ctype.physicalType

    // if this expression performs assignment against a local
    // variable, then note the reassignment so that we know it
    // is not a final variable (final being like Java semanatics)
    assignTarget := expr.assignTarget as LocalVarExpr
    if (assignTarget != null && assignTarget.var_v != null)
      assignTarget.var_v.reassigned

    return expr
  }

  private Expr resolveExpr(Expr expr)
  {
    switch (expr.id)
    {
      case ExprId.nullLiteral:      // LiteralExpr
        expr.ctype = ns.objType.toNullable
      case ExprId.trueLiteral:
        expr.ctype = ns.boolType
      case ExprId.falseLiteral:
        expr.ctype = ns.boolType
      case ExprId.intLiteral:
        expr.ctype = ns.intType
      case ExprId.floatLiteral:
        expr.ctype = ns.floatType
      case ExprId.decimalLiteral:
        expr.ctype = ns.decimalType
      case ExprId.strLiteral:
        expr.ctype = ns.strType
      case ExprId.durationLiteral:
        expr.ctype = ns.durationType
      case ExprId.uriLiteral:
        expr.ctype = ns.uriType
      case ExprId.typeLiteral:
        expr.ctype = ns.typeType
        LiteralExpr e := expr
        CType t := e.val
        ResolveType.doResolveType(this, t)
      case ExprId.localeLiteral:    // LocaleLiteralExpr
        expr = resolveLocaleLiteral(expr)
      case ExprId.slotLiteral:      // SlotLiteralExpr
        expr = resolveSlotLiteral(expr)
      case ExprId.rangeLiteral:     // RangeLiteralExpr
        expr.ctype = ns.rangeType
      case ExprId.listLiteral:      // ListLiteralExpr
        expr = resolveList(expr)
      case ExprId.mapLiteral:       // MapLiteralExpr
        expr = resolveMap(expr)

      case ExprId.boolNot:          // UnaryExpr
      case ExprId.cmpNull:
      case ExprId.cmpNotNull:
        expr.ctype = ns.boolType

      case ExprId.elvis:
        expr = resolveElvis(expr)
      case ExprId.assign:           // BinaryExpr
        expr = resolveAssign(expr)

      case ExprId.same:
      case ExprId.notSame:
      case ExprId.boolOr:           // CondExpr
      case ExprId.boolAnd:
        expr.ctype = ns.boolType
      
      case ExprId.isExpr:           // TypeCheckExpr
      case ExprId.isnotExpr:
      case ExprId.asExpr:
      case ExprId.coerce:
        expr = resolveTypeCheck(expr)

      case ExprId.call:             // CallExpr
        expr = resolveCall(expr)

      case ExprId.construction:
        expr = resolveConstruction(expr)
      case ExprId.shortcut:         // ShortcutExpr (has ShortcutOp)
        expr = resolveShortcut(expr)

      case ExprId.field:            // FieldExpr
        expr = resolveField(expr)
      case ExprId.localVar:         // LocalVarExpr
        expr.ctype = ((LocalVarExpr)expr).var_v.ctype

      case ExprId.thisExpr:         // ThisExpr
        expr = resolveThis(expr)
      case ExprId.superExpr:        // SuperExpr
        expr = resolveSuper(expr)
      case ExprId.itExpr:           // ItExpr
        expr = resolveIt(expr)
      case ExprId.staticTarget:     // StaticTargetExpr
        expr.ctype = ((StaticTargetExpr)expr).target
      case ExprId.unknownVar:       // UnknownVarExpr
        expr = resolveVar(expr)
      case ExprId.storage:
        expr = resolveStorage(expr)
      case ExprId.ternary:          // TernaryExpr
        expr = resolveTernary(expr)
      case ExprId.complexLiteral:   // ComplexLiteral
        expr.ctype = ((ComplexLiteral)expr).target
      case ExprId.closure:          // ClosureExpr
        expr = resolveClosure(expr)
      case ExprId.dsl:              // DslExpr
        expr = resolveDsl(expr)
      case ExprId.throwExpr:        // ThrowExpr
        expr.ctype = ns.nothingType
      case ExprId.awaitExpr:
        expr = resolveAwait(expr)
      case ExprId.sizeOfExpr:
        expr.ctype = ns.intType
      case ExprId.addressOfExpr:
        expr = resolveAddressOf(expr)
    }

    return expr
  }
  
  
  private Expr resolveTypeCheck(TypeCheckExpr expr) {
    ResolveType.doResolveType(this, expr.check)
    switch (expr.id) {
      case ExprId.isExpr:           // TypeCheckExpr
      case ExprId.isnotExpr:
        expr.ctype = ns.boolType

      case ExprId.asExpr:
        expr.ctype = ((TypeCheckExpr)expr).check.toNullable
      case ExprId.coerce:
        expr.ctype = ((TypeCheckExpr)expr).check
    }
    return expr
  }
  
  private Expr resolveField(FieldExpr expr) {
    expr.field = expr.target.ctype.field(expr.name)
    if (expr.field == null) {
      expr.ctype = ns.error
    }
    else {
      expr.ctype = expr.field.fieldType
    }
    return expr
  }
  
  **
  ** If this is a standalone name without a base target
  ** such as "Foo" and the name maps to a type name, then
  ** this is a type literal.
  **
  private Expr? resolveStaticTypeTarget(NameExpr expr)
  {
    if (expr.target == null)
    {
      stypes := curType.unit.importedTypes[expr.name]

      // if more then, one first try to exclude those internal to other pods
      if (stypes != null && stypes.size > 1)
        stypes = stypes.exclude |t| { t.isInternal && t.podName != compiler.pod.name }

      if (stypes != null && !stypes.isEmpty)
      {
        if (stypes.size > 1)
          compiler.log.err("Ambiguous type: " + stypes.join(", "), expr.loc)
        
        type := CType.makeResolvedType(stypes.first.typeDef, expr.loc)
        type.len = expr.name.size
        staticTargetExpr := StaticTargetExpr(expr.loc, type)
        staticTargetExpr.ctype = stypes.first
        staticTargetExpr.len = expr.len
        call := expr as CallExpr
        if (call != null) {
          nexpr := CallExpr(expr.loc, staticTargetExpr, "<ctor>", ExprId.construction)
          ((CallExpr)nexpr).args = call.args
          nexpr.len = expr.len
          return nexpr
        }
        else {
          return staticTargetExpr
        }
      }
    }
    return null
  }

  private Expr resolveAwait(AwaitExpr yexpr) {
    //yexpr.expr = resolveExpr(yexpr.expr)
    if (yexpr.expr.ctype.fits(ns.promiseType)) {
      awaitType := (yexpr.expr.ctype).genericArgs.first
      if (awaitType != null) {
        yexpr.ctype = awaitType.toNullable
      } else {
        yexpr.ctype = ns.objType.toNullable
      }
    }
    else {
      yexpr.ctype = yexpr.expr.ctype
    }
    return yexpr
  }

  private Expr resolveAddressOf(AddressOfExpr expr) {
    //expr.var_v = resolveExpr(expr.var_v)
    expr.ctype = ns.ptrType
    return expr
  }

  **
  ** Resolve locale literal '$<pod::key=def>'
  **
  private Expr resolveLocaleLiteral(LocaleLiteralExpr expr)
  {
    loc := expr.loc

    // cannot define def with explicit podName
    if (expr.podName != null && expr.def != null)
      err("Locale literal cannot specify both qualified pod and default value", loc)

    // cannot specify using current pod if output is not pod
    if (expr.podName == null && compiler.input.isScript)
      err("Scripts cannot define non-qualified locale literals", loc)

    // if we have a def, then add to compiler to merge into locale/en.props
    if (expr.def != null) compiler.localeDefs.add(expr)

    // Pod.find(podName) or inType#.pod
    inType := this.curType
    if (inType.isClosure) inType = inType.closure.enclosingType
    podTarget := expr.podName != null ?
      CallExpr.makeWithMethod(loc, null, ns.podFind, [LiteralExpr.makeStr(loc, expr.podName)]) :
      CallExpr.makeWithMethod(loc, LiteralExpr(loc, ExprId.typeLiteral, ns.typeType, inType), ns.typePod)

    // podTarget.locale(key [, def])
    args := [LiteralExpr.makeStr(loc, expr.key)]
    if (expr.def != null) args.add(LiteralExpr.makeStr(loc, expr.def))
    return CallExpr.makeWithMethod(loc, podTarget, ns.podLocale, args)
  }

  **
  ** Resolve slot literal
  **
  private Expr resolveSlotLiteral(SlotLiteralExpr expr)
  {
    ResolveType.doResolveType(this, expr.parent)
    slot := expr.parent.slot(expr.name)
    if (slot == null)
    {
      err("Unknown slot literal '${expr.parent.signature}.${expr.name}'", expr.loc)
      expr.ctype = ns.error
      return expr
    }
    expr.ctype = slot is CField ? ns.fieldType : ns.methodType
    expr.slot = slot
    return expr
  }

  **
  ** Resolve list literal
  **
  private Expr resolveList(ListLiteralExpr expr)
  {
    if (expr.explicitType != null)
    {
      expr.ctype = expr.explicitType
    }
    else
    {
      // infer from list item expressions
      v := CommonType.commonType(ns, expr.vals)
      expr.ctype = CType.listType(expr.loc, v)
    }
    return expr
  }

  **
  ** Resolve map literal
  **
  private Expr resolveMap(MapLiteralExpr expr)
  {
    if (expr.explicitType != null)
    {
      expr.ctype = expr.explicitType
    }
    else
    {
      // infer from key/val expressions
      k := CommonType.commonType(ns, expr.keys).toNonNullable
      v := CommonType.commonType(ns, expr.vals)
      expr.ctype = CType.mapType(expr.loc, k, v)
    }
    return expr
  }

  **
  ** Resolve this keyword expression
  **
  private Expr resolveThis(ThisExpr expr)
  {
    if (inClosure)
    {
      loc := expr.loc
      closure := curType.closure

      // if the closure is in a static slot, report an error
      if (closure.enclosingSlot.isStatic)
      {
        expr.ctype = ns.error
        err("Cannot access 'this' within closure of static context", loc)
        return expr
      }

      // otherwise replace this with $this field access
      return FieldExpr(loc, ThisExpr(loc), closure.outerThisField)
    }

    expr.ctype = curType.asRef
    return expr
  }

  **
  ** Resolve super keyword expression
  **
  private Expr resolveSuper(SuperExpr expr)
  {
    if (inClosure)
    {
      // it would be nice to support super from within a closure,
      // but the Java VM has the stupid restriction that invokespecial
      // cannot be used outside of the class - we could potentially
      // work around this using a wrapper method - but for now we will
      // just disallow it
      err("Invalid use of 'super' within closure", expr.loc)
      expr.ctype = ns.error
      return expr
    }

    if (expr.explicitType != null)
      expr.ctype = expr.explicitType
    else
      expr.ctype = curType.base

    return expr
  }

  **
  ** Resolve it keyword expression
  **
  private Expr resolveIt(ItExpr expr)
  {
    // if inside of field setter it is our implicit val parameter
    if (curMethod != null && curMethod.isFieldSetter)
      return LocalVarExpr(expr.loc, curMethod.paramDefs.first)

    // can't use it keyword outside of an it-block
    if (!inClosure || !curType.closure.isItBlock)
    {
      err("Invalid use of 'it' outside of it-block", expr.loc)
      expr.ctype = ns.error
      return expr
    }

    // closure's itType should be defined at this point
    expr.ctype = curType.closure.itType
    return expr
  }

  **
  ** Resolve an assignment operation
  **
  private Expr resolveAssign(BinaryExpr expr)
  {
    // if lhs has synthetic coercion we need to remove it;
    // this can occur when resolving a FFI field - in order
    // for this to work there are only two possible allowed
    // coercions: 1) a TypeCheckExpr or 2) a CallExpr where
    // the non-coerced expression is the last argument
    if (expr.lhs.synthetic)
    {
      if (expr.lhs.id === ExprId.coerce)
        expr.lhs = ((TypeCheckExpr)expr.lhs).target
      else if (expr.lhs.id === ExprId.call)
        expr.lhs = ((CallExpr)expr.lhs).args.last
      else
        throw Err("Unexpected LHS synthetic expr: $expr [$expr.loc.toLocStr]")
    }

    // check for left hand side the [] shortcut, because []= is set
    shortcut := expr.lhs as ShortcutExpr
    if (shortcut != null && shortcut.op == ShortcutOp.get)
    {
      shortcut.op = ShortcutOp.set
      shortcut.name = "set"
      shortcut.args.add(expr.rhs)
      shortcut.method = null
      return resolveCall(shortcut)
    }

    // check for left hand side the -> shortcut, because a->x=b is trap.a("x", [b])
    call := expr.lhs as CallExpr
    if (call != null && call.isDynamic)
    {
      call.args.add(expr.rhs)
      return resolveCall(call)
    }

    // assignment is typed by lhs
    expr.ctype = expr.lhs.ctype

    return expr
  }

  **
  ** Resolve an UnknownVar to its replacement node.
  **
  private Expr resolveVar(UnknownVarExpr var_v)
  {
    // if there is no target, attempt to bind to local variable
    if (var_v.target == null)
    {
      // attempt to a name in the current scope
      binding := resolveLocal(var_v.name, var_v.loc)
      if (binding != null) {
        res := LocalVarExpr(var_v.loc, binding)
        res.len = var_v.len
        return res
      }
    }
    
    //static slot: Int.max
    res := resolveStaticTypeTarget(var_v)
    if (res != null) {
      return res
    }

    // at this point it can't be a local variable, so it must be
    // a slot on either myself or the variable's target
    return CallResolver(compiler, curType, curMethod, var_v, curType.closure).resolve
  }

  **
  ** Resolve storage operator
  **
  private Expr resolveStorage(UnknownVarExpr var_v)
  {
    // resolve as normal unknown variable
    resolved := resolveVar(var_v)

    // handle case where we have a local variable hiding a
    // field since the *x is assumed to be this.*x
    if (resolved.id === ExprId.localVar)
    {
      field := curType.fieldDef(var_v.name)
      if (field != null) {
        fieldExpr := FieldExpr(var_v.loc, ThisExpr(var_v.loc), field.name)
        fieldExpr.len = var_v.len
        fieldExpr.field = field
        fieldExpr.ctype = field.fieldType
        resolved = fieldExpr
      }
    }

    // is we can't resolve as field, then this is an error
    if (resolved.id !== ExprId.field)
    {
      if (resolved.ctype !== ns.error)
        err("Invalid use of field storage operator '&'", var_v.loc)
      return resolved
    }

    f := resolved as FieldExpr
    f.useAccessor = false
    if (f.field is FieldDef)
    {
      fd := (FieldDef)f.field
      fd.flags = fd.flags.or(FConst.Storage)
    }
    return f
  }

  **
  ** Resolve "x ?: y" expression
  **
  private Expr resolveElvis(BinaryExpr expr)
  {
    expr.ctype = CommonType.common(ns, [expr.lhs.ctype, expr.rhs.ctype]).toNullable
    return expr
  }

  **
  ** Resolve "x ? y : z" ternary expression
  **
  private Expr resolveTernary(TernaryExpr expr)
  {
    if (expr.trueExpr.id === ExprId.nullLiteral)
      expr.ctype = expr.falseExpr.ctype.toNullable
    else if (expr.falseExpr.id === ExprId.nullLiteral)
      expr.ctype = expr.trueExpr.ctype.toNullable
    else
      expr.ctype = CommonType.common(ns, [expr.trueExpr.ctype, expr.falseExpr.ctype])
    return expr
  }

  **
  ** Resolve a call to it's Method and return type.
  **
  private Expr resolveCall(CallExpr call)
  {
    // dynamic calls are just syntactic sugar for Obj.trap
    if (call.isDynamic && !call.isCheckedCall)
    {
      call.method = ns.objTrap
      call.ctype = ns.objType.toNullable
      return call
    }

    // if this is a constructor chained call to a FFI
    // super-class then route to the FFI bridge to let it handle
    if (call.isCtorChain && curType.base.typeDef.isForeign)
      return curType.base.typeDef.bridge.resolveConstructorChain(call)

    // if there is no target, attempt to bind to local variable
    if (call.target == null)
    {
      // attempt to a name in the current scope
      binding := resolveLocal(call.name, call.loc)
      if (binding != null)
        return resolveCallOnLocalVar(call, LocalVarExpr(call.loc, binding))
    }
    
    //maybe ctor
    ctor := resolveStaticTypeTarget(call)
    if (ctor != null) {
      return this.resolveConstruction(ctor)
    }

    res := CallResolver(compiler, curType, curMethod, call, curType.closure).resolve
    if (call.isDynamic) {
      res.ctype = ns.objType.toNullable
    }
    return res
  }

  **
  ** Resolve the () operator on a local variable - if the local
  ** is a Method, then () is syntactic sugar for Method.callx()
  **
  private Expr resolveCallOnLocalVar(CallExpr call, LocalVarExpr binding)
  {
    // if the call was generated as an it-block on local
    if (call.noParens && call.args.size == 1)
    {
      closure:= call.args.last as ClosureExpr
      if (closure != null && closure.isItBlock) {
        expr := closure.toWith(binding, ns.objWith)
        ns.resolveTypeRef(closure.ctype, closure.loc)
        return expr
      }
    }

    // can only handle zero to eight arguments; I could wrap up the
    // arguments into a List and use call(List) - but methods with
    // that many arguments are just inane so tough luck
    if (call.args.size > 8)
    {
      err("Tough luck - cannot use () operator with more than 8 arguments, use call(List)", call.loc)
      call.ctype = ns.error
      return call
    }

    // invoking the () operator on a sys::Func is syntactic
    // sugar for invoking one of the Func.call methods
    callMethod := binding.ctype.method("call")
    if (callMethod == null)
    {
      if (binding.ctype != ns.error)
        err("Cannot use () call operator on non-func type '$binding.ctype'", call.loc)
      call.ctype = ns.error
      return call
    }
    ncall := CallExpr.makeWithMethod(call.loc, binding, callMethod, call.args)
    ncall.len = call.len
    ncall.isCallOp = true
    return ncall
  }

  **
  ** Resolve a construction call Type(args)
  **
  private Expr resolveConstruction(CallExpr call)
  {
    base := call.target.ctype
    call.ctype = base  // fallback in case of errors

    // route FFI constructors to bridge
    if (base.typeDef.isForeign) return base.typeDef.bridge.resolveConstruction(call)

    // get all constructors that might match this call
    matches := Str:CMethod[:]
    findCtorMatches(matches, base, call.args)

    // check if our last argument is an it-block, then check
    // for constructors without that arg:
    //    make(...).with(lastArg)
    itBlock := (call.args.last as ClosureExpr)?.isItBlock ?: false
    if (itBlock) findCtorMatches(matches, base, call.args[0..-2])

    // if no matches bail
    if (matches.isEmpty)
    {
      args := call.args.join(", ") |arg| { arg.ctype.toStr }
      err("No constructor found: ${base.name}($args)", call.loc)
      return call
    }

    // if we have multiple matches, we have ambiguous constructor
    if (matches.size > 1)
    {
      args := call.args.join(", ") |arg| { arg.ctype.toStr }
      names := matches.map |m| { m.name }.vals.sort.join(", ")
      err("Ambiguous constructor: ${base.name}($args) [$names]", call.loc)
      return call
    }

    // we have our resolved match
    match := matches.vals.first
    call.method = match
    call.ctype = match.isStatic ? match.returnType : base

    // hook to infer closure type from call or to
    // translateinto an implicit call to Obj.with
    return CallResolver.inferClosureTypeFromCall(this.compiler, call, base)
  }

  **
  ** Walk all the slots in 'base' and match any constructor
  ** that could be called using the given arguments.
  **
  private Void findCtorMatches([Str:CMethod] matches, CType base, Expr[] args)
  {
    base.slots.each |slot|
    {
      // if not a visibile constructor, then not a match
      if (!isCtorMethod(slot)) return
      if (!CheckErrors.isSlotVisible(curType, slot)) return

      // don't match any inherited methods
      if (slot.parent != base.typeDef) {
        if (base.typeDef is ParameterizedType) {
          if (slot.parent != (base.typeDef as ParameterizedType).root) {
            return
          }
        }
        else {
          return
        }
      }

      // check argument/parameter counts to see if we can disqualify it
      ctor := (CMethod)slot
      params := ctor.params
      if (params.size < args.size) return
      if (params.size > args.size && !params[args.size].hasDefault) return

      // check that each parameter fits
      for (i:=0; i<args.size; ++i)
        if (!Coerce.canCoerce(args[i], params[i].paramType))
          return

      // its a match!
      matches[ctor.name] = ctor
    }
  }

  private Bool isCtorMethod(CSlot slot)
  {
    if (slot.isCtor) return true
    if (slot isnot CMethod) return false
    // TODO let static "make" or "fromStr" pass
    if (slot.isStatic && (slot.name == "make" || slot.name == "fromStr")) return true
    return false
  }

  **
  ** Resolve ShortcutExpr.
  **
  private Expr resolveShortcut(ShortcutExpr expr)
  {
    // if this is an indexed assigment such as x[y] += z
    if (expr.isAssign && expr.target.id === ExprId.shortcut)
      return resolveIndexedAssign(expr)

    // string concat is always optimized, and performs a bit
    // different since a non-string can be used as the lhs
    if (expr.isStrConcat)
    {
      expr.ctype  = ns.strType
      expr.method = ns.strPlus
      return ConstantFolder(compiler).fold(expr)
    }

    // if a binary operation
    if (expr.args.size == 1 && expr.op.isOperator)
    {
      method := resolveBinaryOperator(expr)
      if (method == null) { expr.ctype = ns.error; return expr }
      expr.method = method
      expr.name   = method.name
    }

    // resolve the call, if optimized, then return it immediately
    result := resolveCall(expr)
    if (result !== expr) return result

    // check that method has Operator facet
    if (expr.method != null && expr.op.isOperator && !expr.method.hasFacet("sys::Operator"))
      err("Missing Operator facet: $expr.method.qname", expr.loc)

    // the comparision operations are special case that call a method
    // that return an Int, but leave a Bool on the stack (we also handle
    // specially in assembler)
    switch (expr.opToken)
    {
      case Token.lt:
      case Token.ltEq:
      case Token.gt:
      case Token.gtEq:
        expr.ctype = ns.boolType
    }

    return expr
  }

  **
  ** Given a shortcut method such as 'lhs op rhs' figure
  ** out which method to use for the operator symbol.
  **
  private CMethod? resolveBinaryOperator(ShortcutExpr expr)
  {
    op := expr.op
    lhs := expr.target.ctype
    rhs := expr.args.first

    if (lhs === ns.error || rhs.ctype === ns.error) return null

    // get matching operators for the method name
    matches := lhs.typeDef.operators.find(op.methodName)

    // if multiple matches, attempt to narrow by argument type
    if (matches.size > 1)
    {
      matches = matches.findAll |m|
      {
        if (m.params.size != 1) return false
        paramType := m.params.first.paramType
        return Coerce.canCoerce(rhs, paramType)
      }
    }

    // if no matches bail
    if (matches.isEmpty)
    {
      err("No operator method found: ${op.formatErr(lhs, rhs.ctype)}", expr.loc)
      return null
    }

    // if we have one match, we are golden
    if (matches.size == 1) return matches.first

    // still have an ambiguous operator method call
    names := (matches.map |CMethod m->Str| { m.name }).join(", ")
    err("Ambiguous operator method: ${op.formatErr(lhs, rhs.ctype)} [$names]", expr.loc)
    return null
  }

  **
  ** If we have an assignment against an indexed shortcut
  ** such as x[y] += z, then process specially to return
  ** a IndexedAssignExpr subclass of ShortcutExpr.
  **
  private Expr resolveIndexedAssign(ShortcutExpr orig)
  {
    // if target is in error, don't bother
    if (orig.target.ctype === ns.error)
    {
      orig.ctype = ns.error
      return orig
    }

    // we better have a x[y] indexed get expression
    if (orig.target.id != ExprId.shortcut && orig.target->op === ShortcutOp.get)
    {
      err("Expected indexed expression", orig.loc)
      return orig
    }

    // wrap the shorcut as an IndexedAssignExpr
    expr := IndexedAssignExpr.makeFrom(orig)

    // resolve it normally - if the orig is "x[y] += z" then we
    // are resolving Int.plus here - the target is "x[y]" and should
    // already be resolved
    resolveCall(expr)

    // resolve the set method which matches
    // the get method on the target
    get := ((ShortcutExpr)expr.target).method
    set := get.parent.slots.get("set") as CMethod
    if (set == null || set.params.size != 2 || set.isStatic ||
        set.params[0].paramType.toNonNullable != get.params[0].paramType.toNonNullable ||
        set.params[1].paramType.toNonNullable != get.returnType.toNonNullable)
      err("No matching 'set' method for '$get.qname'", orig.loc)
    else
      expr.setMethod = set

    // return the new IndexedAssignExpr
    return expr
  }

  **
  ** ClosureExpr will just output its substitute expression.  But we take
  ** this opportunity to capture the local variables in the closure's scope
  ** and cache them on the ClosureExpr.  We also do variable name checking.
  **
  private Expr resolveClosure(ClosureExpr expr)
  {
    // save away current locals in scope
    expr.enclosingVars = localsInScope

    // make sure none of the closure's parameters
    // conflict with the locals in scope
    expr.doCall.paramDefs.each |ParamDef p|
    {
      if (expr.enclosingVars.containsKey(p.name) && p.name != "it")
        err("Closure parameter '$p.name' is already defined in current block", p.loc)
    }
    
    expr.ctype = expr.signature.typeRef
    return expr
  }

  **
  ** Resolve a DSL
  **
  private Expr resolveDsl(DslExpr expr)
  {
    ResolveType.doResolveType(this, expr.anchorType)
    plugin := DslPlugin.find(this, expr.loc, expr.anchorType)
    if (plugin == null)
    {
      expr.ctype = ns.error
      return expr
    }

    origNumErrs := compiler.log.errs.size
    expr.ctype = ns.error
    try
    {
      result := plugin.compile(expr)
      if (result === expr) return result
      return result.walk(this)
    }
    catch (CompilerErr e)
    {
      if (compiler.log.errs.size == origNumErrs) errReport(e)
      return expr
    }
    catch (Err e)
    {
      errReport(CompilerErr("Internal error in DslPlugin '$plugin.typeof': $e", expr.loc, e))
      e.trace
      return expr
    }
  }

//////////////////////////////////////////////////////////////////////////
// Scope
//////////////////////////////////////////////////////////////////////////

  **
  ** Setup the MethodVars for the parameters.
  **
  private Void initMethodVars()
  {
    m := curMethod
    //reg := m.isStatic ?  0 : 1

    m.paramDefs.each |ParamDef p|
    {
      //var_v := MethodVar.makeForParam(m, reg++, p, p.paramType.parameterizeThis(curType))
      //m.vars.add(var_v)
      p.method = m
    }
  }

  **
  ** Bind the specified local variable definition to a
  ** MethodVar (and register number).
  **
  private Void bindToMethodVar(LocalDefStmt def)
  {
    // make sure it doesn't exist in the current scope
    if (resolveLocal(def.name, def.loc) != null)
      err("Variable '$def.name' is already defined in current block", def.loc)

    // create and add it
    def.var_v = curMethod.addLocalVarForDef(def, currentBlock)
    
    if (def.var_v.ctype != null) {
      ResolveType.doResolveType(this, def.var_v.ctype)
    }
  }

  **
  ** Resolve a local variable using current scope based on
  ** the block stack and possibly the scope of a closure.
  **
  private MethodVar? resolveLocal(Str name, Loc loc)
  {
    // if not in method, then we can't have a local
    if (curMethod == null) return null

    MethodVar? binding
    
    if (stmtStack.peek is ForStmt) {
      block := ((ForStmt)stmtStack.peek).block
      binding = block.vars.find |MethodVar var_v->Bool| {
        return var_v.name == name
      }
    }
    
    if (binding == null) {
        for (i:=this.blockStack.size -1; i >=0 ; --i) {
          b := blockStack[i]
          binding = b.vars.find |MethodVar var_v->Bool| {
            return var_v.name == name
          }
          if (binding != null) break
        }
    }
    
    if (binding == null) {
        binding = curMethod.paramDefs.find |MethodVar var_v->Bool| {
            return var_v.name == name
        }
    }
    
    if (binding != null) return binding

    // if a closure, check parent scope
    if (inClosure)
    {
      closure := curType.closure
      binding = closure.enclosingVars[name]
      if (binding != null)
      {
        // mark the enclosing method and var as being used in a closure
        binding.method.usesCvars = true
        binding.usedInClosure = true

        // create new "shadow" local var in closure body which
        // shadows the enclosed variable from parent scope,
        // we'll do further processing in ClosureVars
        shadow := curMethod.addLocalVar(binding.loc, binding.ctype, binding.name, currentBlock)
        shadow.usedInClosure = true
        shadow.shadows = binding

        // if there are intervening closure scopes between
        // the original scope and current scope, then we need to
        // add a pass-thru variable in each scope
        last := shadow
        for (p := closure.enclosingClosure; p != null; p = p.enclosingClosure)
        {
          if (binding.method === p.doCall) break
          passThru := p.doCall.addLocalVar(binding.loc, binding.ctype, binding.name, p.doCall.code)
          passThru.usedInClosure = true
          passThru.shadows = binding
          passThru.usedInClosure = true
          last.shadows = passThru
          last = passThru
        }

        return shadow
      }
    }

    // not found
    return null
  }

  **
  ** Get a list of all the local method variables that
  ** are currently in scope.
  **
  private Str:MethodVar localsInScope()
  {
    Str:MethodVar acc := inClosure ?
      curType.closure.enclosingVars.dup :
      Str:MethodVar[:]

    if (curMethod == null) return acc

    if (stmtStack.peek is ForStmt) {
      block := ((ForStmt)stmtStack.peek).block
      block.vars.each |MethodVar var_v| {
        acc[var_v.name] = var_v
      }
    }
    
    for (i:=this.blockStack.size -1; i >=0 ; --i) {
      b := blockStack[i]
      b.vars.each |MethodVar var_v| {
        acc[var_v.name] = var_v
      }
    }
    
    curMethod.paramDefs.each |MethodVar var_v| {
        acc[var_v.name] = var_v
    }

    return acc
  }

  **
  ** Get the current block which defines our scope.  We make
  ** a special case for "for" loops which can declare variables.
  **
  private Block currentBlock()
  {
    if (stmtStack.peek is ForStmt)
      return ((ForStmt)stmtStack.peek).block
    else
      return blockStack.peek
  }

//  **
//  ** Check if the specified block is currently in scope.  We make
//  ** a specialcase for "for" loops which can declare variables.
//  **
//  private Bool isBlockInScope(Block? block)
//  {
//    // the null block within the whole method (ctorChains or defaultParams)
//    if (block == null) return true
//
//    // special case for "for" loops
//    if (stmtStack.peek is ForStmt)
//    {
//      if (((ForStmt)stmtStack.peek).block === block)
//        return true
//    }
//
//    // look in block stack which models scope chain
//    return blockStack.any |Block b->Bool| { b === block }
//  }

//////////////////////////////////////////////////////////////////////////
// StmtStack
//////////////////////////////////////////////////////////////////////////

  private Stmt? findLoop()
  {
    for (i:=stmtStack.size-1; i>=0; --i)
    {
      stmt := stmtStack[i]
      if (stmt.id === StmtId.whileStmt) return stmt
      if (stmt.id === StmtId.forStmt)   return stmt
    }
    return null
  }

//////////////////////////////////////////////////////////////////////////
// BlockStack
//////////////////////////////////////////////////////////////////////////

  override Void enterBlock(Block block) { blockStack.push(block) }
  override Void exitBlock(Block block)  { blockStack.pop }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  Stmt[] stmtStack  := Stmt[,]    // statement stack
  Block[] blockStack := Block[,]  // block stack used for scoping
  Bool inClosure := false         // are we inside a closure's block
}