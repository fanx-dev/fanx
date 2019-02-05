//
// Copyright (c) 2019, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2019-02-04  Jed Young Creation
//

class GenDefaultParam : CompilerStep
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
    log.debug("GenDefaultParam")
    walk(compiler, VisitDepth.slotDef)
    bombIfErr

    //types.each |TypeDef t| { t.dump }
  }

  override Void visitMethodDef(MethodDef def)
  {
    if (!def.params.any { it.hasDefault }) return

    for (i:=0; i<def.params.size; ++i) {
      param := def.params[i]
      if (!param.hasDefault) continue
      genOverloading(i)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Synthetic
//////////////////////////////////////////////////////////////////////////

  Void genOverloading(Int paramCount) {

    // our constructor definition
    m := MethodDef(curMethod.loc, curType)
    m.name = curMethod.name
    m.flags = curMethod.flags.or(FConst.Synthetic).or(FConst.Overloading)
              .and(FConst.Async.not).and(FConst.Native.not).and(FConst.Abstract.not)
    m.ret = curMethod.ret
    m.inheritedRet = curMethod.inheritedRet
    m.code = Block(curMethod.loc)
    loc := curMethod.loc

    args := Expr[,]
    for (i:=0; i<paramCount; ++i) {
      param := curMethod.params[i]
      nparam := m.addParamVar(param.paramType, param.name)
      pvar := LocalVarExpr(loc, nparam)
      args.add(pvar)
    }

    defExpr := curMethod.paramDefs[paramCount].def
    args.add(defExpr)

    callExpr := CallExpr(loc, curMethod.isStatic ? StaticTargetExpr(loc, curMethod.parent) : ThisExpr(loc)
        , curMethod, args)

    if (curMethod.returnType.isVoid) {
      m.code.add(callExpr.toStmt)
      m.code.add(ReturnStmt(loc))
    }
    else {
      m.code.add(ReturnStmt(loc, callExpr))
    }

    curType.addSlot(m)
  }
}