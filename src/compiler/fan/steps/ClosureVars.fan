//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   5 Mar 06  Brian Frank  Creation
//   4 Oct 06  Brian Frank  Port from Java to Fan
//   4 Sep 09  Brian Frank  Redesign with individual wrappers
//

**
** ClosureVars is used to process closure variables which have
** been enclosed from their parent scope:
**
**  ResolveExpr
**  -----------
**  ResolveExpr we detected variables used from parent scope
**  and created shadow variables in the closure's scope with
**  a reference via 'MethodVar.shadows'.  Also during this step
**  we note any variables which are reassigned making them
**  non-final (according to Java final variable semantics).
**
**  Process Method
**  --------------
**  First we walk all types looking for methods which use
**  closure variables:
**
**   1. For each one walk thru its variables to see if any variables
**      enclosed are non-final (reassigned at some point).  These
**      variables as hoisted onto the heap with wrappers:
**         class Wrapper$T { new make(T v) { val=v }  T val }
**
**   2. If no wrapped variables, then we can leave a cvars method
**      alone - everything stays the same.  If however we do have
**      wrapped variables, then we need to walk the expr tree of
**      the method replacing all access of the variable with its
**      wrapper access:
**         x := 3     =>   x := Wrapper$Int(3)
**         x = x + 1  =>   x.val = x.val + 1
**
**   3. If any params were wrapped, we generated a new local variable
**      in 'wrapNonFinalVars'.  During the expr tree walk we replaced all
**      references to the param to its new wrapped local.   To finish
**      processing the method we insert a bit of code in the beginning
**      of the method to initialize the local.
**
**  Process Closure
**  ---------------
**  After we have walked all methods using closure variables (which
**  might include closure doCall methods themselves), then we walk
**  all the closures.
**
**   1. For each shadowed variables we need:
**        a. Define field on the closure to store variable
**        b. Pass variable to closure constructor at substitution site
**        c. Add variable to as closure constructor param
**        d. Assign param to field in constructor
**      If the variable has been wrapped we are doing this for the
**      wrapped variable (we don't unwrap it).
**
**   2. If any of the closures shadowed variables are wrapped, then
**      we do a expr tree walk of doCall - the exact same thing as
**      step 2 of the processMethod stage.
**
**
class ClosureVars : CompilerStep
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(Compiler compiler) : super(compiler) {}

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  override Void run()
  {
    // process all the methods which use closures
    types.each |TypeDef t| { scanType(t) }

    // process all the closures themselves
    compiler.closures.each |c| { processClosure(c) }
  }

  private Void scanType(TypeDef t)
  {
    // only process methods which use closure variables
    t.methodDefs.each |m| { if (m.usesCvars) processMethod(m) }
  }

//////////////////////////////////////////////////////////////////////////
// Process Method
//////////////////////////////////////////////////////////////////////////

  private Void processMethod(MethodDef method)
  {
    if (!wrapNonFinalVars(method)) return
    walkMethod(method)
    fixWrappedParams(method)
  }

//////////////////////////////////////////////////////////////////////////
// Wrap Non-Final Vars
//////////////////////////////////////////////////////////////////////////

  **
  ** Wrap each non-final variable which is reassigned and used
  ** inside a closure.  By wrapping it we hoist it into the heap
  ** so that it may be shared b/w method and closure(s).  Return
  ** true if we wrapped any vars.
  **
  private Bool wrapNonFinalVars(MethodDef m)
  {
    wrapped := false
    m.vars.each |var_v, i|
    {
      // we only care about variables used in closures
      if (!var_v.usedInClosure) return

      // if the variable is never reassigned, then we
      // can use it directly since it is final
      if (!var_v.isReassigned) return

      // generate or reuse Wrapper class for this type
      wrapField := genWrapper(this, var_v.ctype)

      if (var_v.isParam)
      {
        // we can't change signature of parameters since they
        // are passed in externally, so we have to create a new
        // local to use for the wrapper version of the param
        w := m.addLocalVar(wrapField.parent, var_v.name + "\$Wrapper", m.code)
        w.wrapField = wrapField
        var_v.paramWrapper = w
      }
      else
      {
        // generate wrapper type and update variable type
        if (var_v.wrapField != null) throw Err()
        var_v.wrapField = wrapField
        var_v.ctype = wrapField.parent
      }

      // keep track that we've wrapped something
      wrapped = true
    }
    return wrapped
  }

//////////////////////////////////////////////////////////////////////////
// Walk Method
//////////////////////////////////////////////////////////////////////////

  **
  ** Walk the method body:
  **   1.  Create wrapper for each local var definition which requries it
  **   2.  Add unwrap val access for each use of a wrapped local variable
  **   3.  If using a wrapped param, then replace with wrapped local
  **
  private Void walkMethod(MethodDef method)
  {
    method.code.walk(this, VisitDepth.expr)
  }

  override Stmt[]? visitStmt(Stmt stmt)
  {
    if (stmt.id === StmtId.localDef && ((LocalDefStmt)stmt).var_v.isWrapped)
      return fixLocalDef(stmt)
    return null
  }

  override Expr visitExpr(Expr expr)
  {
    switch (expr.id)
    {
      case ExprId.localVar: return fixWrappedVar(expr)
    }
    return expr
  }

//////////////////////////////////////////////////////////////////////////
// Fix Local Init
//////////////////////////////////////////////////////////////////////////

  **
  ** If a local variable has been hoisted onto the heap with
  ** a wrapper, then generate wrapper initialization:
  **
  **   // original code
  **   local := 3
  **
  **   // becomes
  **   local := Wrap$Int(3)
  **
  private Stmt[]? fixLocalDef(LocalDefStmt stmt)
  {
    // get the initial value to pass to wrapper constructor
    Expr? init
    if (stmt.init == null)
      init = LiteralExpr.makeNull(stmt.loc, ns)
    else
      init = ((BinaryExpr)stmt.init).rhs

    // replace original initialization with wrapper construction
    stmt.init = initWrapper(stmt.loc, stmt.var_v, init)
    return null
  }

  **
  ** Generate the expression: var_v := Wrapper(init)
  **
  private Expr initWrapper(Loc loc, MethodVar var_v, Expr init)
  {
    wrapCtor := var_v.wrapField.parent.method("make")
    lhs := LocalVarExpr.makeNoUnwrap(loc, var_v)
    rhs := CallExpr.makeWithMethod(loc, null, wrapCtor, [init])
    return BinaryExpr.makeAssign(lhs, rhs)
  }

//////////////////////////////////////////////////////////////////////////
// Fix Wrapped Var
//////////////////////////////////////////////////////////////////////////

  **
  ** If we are accessing a wrapped variable, then add
  ** indirection to access it from Wrapper.val field.
  **
  private Expr fixWrappedVar(LocalVarExpr local)
  {
    // if this variable access is a wrapped parameter, then
    // we never use the parameter itself, but rather the wrapper
    // local variable
    var_v := local.var_v
    if (var_v.paramWrapper != null)
    {
      // use param wrapper variable
      var_v = var_v.paramWrapper
    }

    // if not a wrapped variable or we have explictly marked
    // it to stay wrapped, then don't do anything
    if (!var_v.isWrapped || !local.unwrap) return local

    // unwrap from the Wrapper.val field
    loc := local.loc
    return fieldExpr(loc, LocalVarExpr.makeNoUnwrap(loc, var_v), var_v.wrapField)
  }

//////////////////////////////////////////////////////////////////////////
// Fix Wrapped Params
//////////////////////////////////////////////////////////////////////////

  **
  ** After we have walked the expr tree, we go back and initialize
  ** the wrapper for any wrapped params used inside closures:
  **
  **   Void foo(Int x)
  **   {
  **     x$wrapper := Wrap$Int(x)
  **     ...
  **
  private Void fixWrappedParams(MethodDef method)
  {
    method.vars.each |var_v|
    {
      if (var_v.paramWrapper == null) return
      loc := method.loc
      initWrap := initWrapper(loc, var_v.paramWrapper, LocalVarExpr.makeNoUnwrap(loc, var_v))
      method.code.stmts.insert(0, initWrap.toStmt)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Process Closure
//////////////////////////////////////////////////////////////////////////

  **
  ** Walk each closure:
  **   1.  Find all the shadowed variables
  **   2.  Call addVarToClosure for each shadowed variable
  **   3.  If needed do expr tree walk
  **
  private Void processClosure(ClosureExpr closure)
  {
    // get the variables shadowed from enclosing scope
    shadowed := closure.doCall.vars.findAll |var_v| { var_v.shadows != null }

    // process each shadowed variable
    shadowed.each |var_v, i| { addVarToClosure(closure, var_v, var_v.name+"\$"+i) }

    // if any of the shadowed variables are wrapped we need
    // to walk the expression tree
    walkExprTree := shadowed.any |var_v| { var_v.isWrapped }
    if (walkExprTree) closure.doCall.code.walkExpr |expr|
    {
      expr.id === ExprId.localVar ? fixWrappedVar(expr) : expr
    }
  }

  **
  ** For each variable enclosed by the closure:
  **  1. Add field on the closure to store variable
  **  2. Add param to as closure constructor
  **  3. Pass variable to closure constructor at substitution site
  **  4. Assign param to field in constructor
  **  5. Initialize variable in doCall from field
  **
  private Void addVarToClosure(ClosureExpr closure, MethodVar var_v, Str name)
  {
    // check if what we are shadowing is a wrapped param
    if (var_v.shadows.paramWrapper != null)
      var_v.shadows = var_v.shadows.paramWrapper

    // check if shadowed var_v has been wrapped
    if (var_v.shadows.isWrapped)
    {
      var_v.ctype = var_v.shadows.ctype
      var_v.wrapField = var_v.shadows.wrapField
    }

    loc := closure.loc
    field := addToClosure(closure, name, LocalVarExpr.makeNoUnwrap(loc, var_v.shadows), "wrapper for $var_v.name.toCode")

    // load from field to local in beginning of doCall
    loadLocal := BinaryExpr.makeAssign(LocalVarExpr.makeNoUnwrap(loc, var_v), fieldExpr(loc, ThisExpr(loc), field))
    closure.doCall.code.stmts.insert(0, loadLocal.toStmt)
  }

  **
  ** This method is called by ClosureExpr to auto-generate the
  ** implicit outer "this" field in the Closure's implementation
  ** class:
  **   1. Add $this field to closure's anonymous class
  **   2. Add $this param to closure's make constructor
  **   3. Pass this to closure constructor at substitute site
  **   4. Set field from param in constructor
  **
  static CField makeOuterThisField(ClosureExpr closure)
  {
    // pass this to subtitute closure constructor
    loc := closure.loc
    Expr? subArg
    if (closure.enclosingClosure != null)
    {
      // if this is a nested closure, then we have to get $this
      // from it's own $this field
      outerThis := closure.enclosingClosure.outerThisField
      subArg = fieldExpr(loc, ThisExpr(loc), outerThis)
    }
    else
    {
      // outer most closure just uses this
      subArg = ThisExpr(loc, closure.enclosingType)
    }

    return addToClosure(closure, "\$this", subArg, "implicit this")
  }

  **
  ** Common code between addVarToClosure and makeOuterThisField.
  ** Return storage field for closure variable.
  **
  private static FieldDef addToClosure(ClosureExpr closure, Str name, Expr subtituteArg, Str info)
  {
    loc      := closure.loc
    thisType := closure.enclosingType
    implType := closure.cls
    ctype    := subtituteArg.ctype

    // define storage field on closure class
    field := FieldDef(loc, implType)
    field.name  = name
    field.flags = syntheticFieldFlags
    field.fieldType = ctype
    field.closureInfo = info
    implType.addSlot(field)

    // pass variable to subtitute closure constructor in outer scope
    closure.substitute.args.add(subtituteArg)

    // add parameter to constructor
    ctor := implType.methodDef("make")
    pvar := ctor.addParamVar(ctype, name)

    // set field in constructor
    assign := BinaryExpr.makeAssign(fieldExpr(loc, ThisExpr(loc), field), LocalVarExpr.makeNoUnwrap(loc, pvar))
    ctor.code.stmts.insert(0, assign.toStmt)

    return field
  }

//////////////////////////////////////////////////////////////////////////
// Generate Wrapper
//////////////////////////////////////////////////////////////////////////

  **
  ** Given a variable type, generate a wrapper class of the format:
  **
  **   class Wrap$ctype[$n] { CType val }
  **
  ** Wrappers are used to manage variables on the heap so that they
  ** can be shared between methods and closures.  We generate one
  ** wrapper class per variable type per pod with potentially a
  ** non-nullable and nullable variant ($n suffix).
  **
  ** Eventually we'd probably like to share wrappers for common types
  ** like Int, Str, Obj, etc.
  **
  ** Return the val field of the wrapper.
  **
  static CField genWrapper(CompilerSupport cs, CType ctype)
  {
    // build class name key
    suffix := ctype.isNullable ? "\$n" : ""
    podName := ctype.pod.name != "sys" ? "\$" + toSafe(ctype.pod.name) : ""
    name := "Wrap" + podName + "\$" + toSafe(ctype.name) + suffix

    // reuse existing wrapper
    existing := cs.compiler.wrappers[name]
    if (existing != null) return existing

    // define new wrapper
    loc := Loc("synthetic")
    w := TypeDef(cs.ns, loc, cs.syntheticsUnit, name)
    w.flags = FConst.Internal + FConst.Synthetic
    w.base  = cs.ns.objType
    cs.addTypeDef(w)

    // generate val field
    f := FieldDef(loc, w)
    f.name = "val"
    f.fieldType = ctype
    f.flags = syntheticFieldFlags
    w.addSlot(f)

    // generate constructor:  make(T v) { this.val = v }
    ctor := MethodDef(loc, w)
    ctor.flags  = FConst.Ctor + FConst.Internal + FConst.Synthetic
    ctor.name   = "make"
    ctor.ret    = cs.ns.voidType
    param := ParamDef(loc, ctype, "v")
    pvar  := MethodVar.makeForParam(ctor, 1, param, param.paramType)
    ctor.params.add(param)
    ctor.vars.add(pvar)
    ctor.code   = Block(loc)
    lhs := fieldExpr(loc, ThisExpr(loc, w), f)
    rhs := LocalVarExpr(loc, pvar)
    ctor.code.add(BinaryExpr.makeAssign(lhs, rhs).toStmt)
    ctor.code.add(ReturnStmt.makeSynthetic(loc))
    w.addSlot(ctor)

    // cache for reuse
    cs.compiler.wrappers[name] = f
    return f
  }

  private static Str toSafe(Str n)
  {
    if (n.isAlphaNum) return n
    s := StrBuf()
    n.each |ch|
    {
      if (ch.isAlphaNum) s.addChar(ch)
      else s.addChar('_')
    }
    return s.toStr
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  private static FieldExpr fieldExpr(Loc loc, Expr target, CField field)
  {
    // make sure we don't use accessor
    FieldExpr(loc, target, field, false)
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private const static Int syntheticFieldFlags:= FConst.Internal+FConst.Storage+FConst.Synthetic

}

