//
// Copyright (c) 2021, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2021-08-01  Jed Young Creation
//

class StructMethod : CompilerStep
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
    log.debug("StructMethod")
    walk(compiler, VisitDepth.typeDef)
    bombIfErr
  }

  override Void visitTypeDef(TypeDef t)
  {
    if (!t.isVal) return

    t.methodDefs.each |def| {
      if (def.isStatic) return
      impl := genValMethod(def)
      genWrap(def, impl)
    }
    //t.dump
  }

//////////////////////////////////////////////////////////////////////////
// Synthetic
//////////////////////////////////////////////////////////////////////////

  private MethodDef genValMethod(MethodDef curMethod) {
    m := MethodDef(curMethod.loc, curType)
    m.name = curMethod.name+"_val"
    m.flags = curMethod.flags.or(FConst.Synthetic).or(FConst.Static)
              .and(FConst.Override.not)
              .and(FConst.Async.not)
              .and(FConst.Abstract.not)
              .and(FConst.Virtual.not)
              
    m.ret = curMethod.ret
    m.inheritedRet = curMethod.inheritedRet
    m.code = curMethod.code
    curMethod.code = Block(curMethod.loc)
    m.paramDefs = curMethod.params.dup
    m.vars = curMethod.vars
    curMethod.vars = [,]

    //add this param
    param := ParamDef(curMethod.loc, curMethod.parent, "__this")
    m.params.insert(0, param)
    reg := 0
    var_v := MethodVar.makeForParam(m, reg, param, curMethod.parent)
    m.vars.insert(0, var_v)

    m.code.walkExpr |expr|
    {
      if (expr.id === ExprId.thisExpr) {
        return LocalVarExpr(expr.loc, var_v)
      }
      return expr
    }

    curType.addSlot(m)
    return m
  }

  private Void genWrap(MethodDef curMethod, MethodDef internalMethod) {
    loc := curMethod.loc
    curMethod.flags = curMethod.flags.and(FConst.Native.not)
    
    self := TypeCheckExpr.coerce(ThisExpr(loc, curMethod.parent.toNullable), curMethod.parent)
    Expr[] args := [self]
    curMethod.params.each |param| {
      var_v := MethodVar.makeForParam(curMethod, curMethod.vars.size+1, param, param.paramType)
      curMethod.vars.add(var_v)
      lvar := LocalVarExpr(loc, var_v)
      args.add(lvar)
    }
    
    callExpr := CallExpr(loc, StaticTargetExpr(loc, curMethod.parent), internalMethod, args)

    if (curMethod.returnType.isVoid) {
      curMethod.code.add(callExpr.toStmt)
      curMethod.code.add(ReturnStmt(loc))
    }
    else {
      curMethod.code.add(ReturnStmt(loc, callExpr))
    }
  }
}