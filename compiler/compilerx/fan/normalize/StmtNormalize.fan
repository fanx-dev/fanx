
//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//    2 Dec 05  Brian Frank  Creation
//   30 Sep 06  Brian Frank  Ported from Java to Fan
//

**
** Normalize the abstract syntax tree:
**   - Add implicit return in methods
**   - Add implicit super constructor call
**
class StmtNormalize : CompilerStep
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
    //debug("Normalize Stmt")
    walkUnits(VisitDepth.slotDef)
  }

//////////////////////////////////////////////////////////////////////////
// Type Normalization
//////////////////////////////////////////////////////////////////////////

  override Void visitTypeDef(TypeDef t)
  {
    if (t.instanceInit != null)
      callInstanceInit(t, t.instanceInit)
  }

  override Void visitMethodDef(MethodDef m)
  {
    normalizeMethod(m)
  }
  
  override Void visitFieldDef(FieldDef f) {
    // if this field overrides a concrete field, that means we already have
    // a concrete getter/setter for this field - if either of this field's
    // accessors is synthetic, then rewrite the one generated by Parser with
    // one that calls the "super" version of the accessor
    if (f.concreteBase != null && !f.isAbstract && !f.isNative)
    {
      if (!f.hasGet) genSyntheticOverrideGet(f)
      if (!f.hasSet) genSyntheticOverrideSet(f)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Method Normalization
//////////////////////////////////////////////////////////////////////////

  private Void normalizeMethod(MethodDef m)
  {
    code := m.code
    if (code == null) return

    // add implicit return
    if (!code.isExit) addImplicitReturn(m)

    if (curUnit.isFanx && m.isInstanceCtor) setCtorChain(m)

    // insert super constructor call
    if (m.isInstanceCtor) insertSuperCtor(m)
  }

  private Void addImplicitReturn(MethodDef m)
  {
    code := m.code
    loc := code.loc

    // we allow return keyword to be omitted if there is exactly one statement
    if (code.size == 1 && !m.returnType.isVoid && code.stmts[0].id == StmtId.expr)
    {
      code.stmts[0] = ReturnStmt.makeSynthetic(code.stmts[0].loc, code.stmts[0]->expr)
      return
    }

    // return is implied as simple method exit
    code.add(ReturnStmt.makeSynthetic(loc))
  }

  private Void insertSuperCtor(MethodDef m)
  {
    // don't need to insert if one already is defined
    if (m.ctorChain != null) return

    // never insert super call for synthetic types, mixins, or Obj.make
    parent := m.parent
    base := parent.base
    if (parent.isSynthetic) return
    if (parent.isMixin) return
    if (base == null || base.isObj) return

    // check if the base class has exactly one available
    // constructor with no parameters
    superCtors := base.instanceCtors
    if (superCtors.size != 1) return
    superCtor := superCtors.first
    if (superCtor.isPrivate) return
    if (superCtor.isInternal && base.podName != parent.podName) return
    if (!superCtor.params.isEmpty) return

    // if we find a ctor to use, then create an implicit super call
    m.ctorChain = CallExpr(m.loc, SuperExpr(m.loc), superCtor.name)
    m.ctorChain.isCtorChain = true
  }

  private Void callInstanceInit(TypeDef t, MethodDef ii)
  {
    // we call instance$init in every constructor
    // unless the constructor chains to "this"
    t.methodDefs.each |MethodDef m|
    {
      if (!m.isInstanceCtor) return
      if (t.isNative) return
      if (m.code == null) return
      if (m.ctorChain != null && m.ctorChain.target.id === ExprId.thisExpr) return
      call := CallExpr(m.loc, ThisExpr(m.loc), ii.name)
      call.synthetic = true
      m.code.stmts.insert(0, call.toStmt)
    }
  }

  private Void setCtorChain(MethodDef method)
  {
    if (method.parent.isEnum) return
    if (method.code == null || method.code.stmts.size == 0) return
    pos := 0
    stmt := method.code.stmts[pos] as ExprStmt
    if (stmt == null) return
    // if (stmt.expr.synthetic) ++pos;//instance$init
    // stmt = method.code.stmts[pos] as ExprStmt
    // if (stmt == null) return
    
    if (stmt.expr.id != ExprId.call) return

    CallExpr call := stmt.expr
    if (call.target == null) return
    CMethod? found
    if (call.target.id === ExprId.superExpr) {
      found = method.parent.base.method(call.name)
    }
    else if (call.target.id === ExprId.thisExpr) {
      found = method.parent.methodDef(call.name)
    }
    if (found == null) return

    if (found.isInstanceCtor) {
      call.isCtorChain = true
      method.ctorChain = call
      method.code.stmts.removeAt(pos)
    }
  }
  
//////////////////////////////////////////////////////////////////////////
// Field override
//////////////////////////////////////////////////////////////////////////
  
  private Void genSyntheticOverrideGet(FieldDef f)
  {
    loc := f.loc
    if (f.get == null) return
    f.get.code.stmts.clear
    f.get.code.add(ReturnStmt.makeSynthetic(loc, FieldExpr(loc, SuperExpr(loc), f.name) { it.field = f.concreteBase } ))
  }

  private Void genSyntheticOverrideSet(FieldDef f)
  {
    loc := f.loc
    lhs := FieldExpr(loc, SuperExpr(loc), f.name) { it.field = f.concreteBase }
    rhs := UnknownVarExpr(loc, null, "it")
    if (f.set == null) return
    f.set.code.stmts.clear
    f.set.code.add(BinaryExpr.makeAssign(lhs, rhs).toStmt)
    f.set.code.add(ReturnStmt.makeSynthetic(loc))
  }
}