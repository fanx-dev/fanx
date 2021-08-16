
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

  override Void visitMethodDef(MethodDef m)
  {
    normalizeMethod(m)
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
}