//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Jan 06  Brian Frank  Creation
//    2 Oct 06  Brian Frank  Ported from Java to Fan
//

**
** During the Parse step we created a list of all the closures.
** In InitClosures we map each ClosureExpr into a TypeDef as
** an anonymous class, then we map ClosureExpr.substitute to
** call the constructor anonymous class.
**
class InitClosures : CompilerStep
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
    //compiler.log.debug("Closures")
    compiler.pod.closures.each |ClosureExpr c| { process(c) }
  }

//////////////////////////////////////////////////////////////////////////
// Process
//////////////////////////////////////////////////////////////////////////

  private Void process(ClosureExpr c)
  {
    // class Class$Method$Num : |A,B..->R|
    // {
    //    new $make() {}
    //    Bool isImmutable() { return true }
    //    Obj? call(Obj? a, Obj? b, ...) { doCall((A)a, ...) }
    //    R doCall(A a, B b, ...) { closure.code }
    // }

    setup(c)      // setup our fields to process this closure
    genClass      // generate anonymous implementation class
    genCtor       // generate make()
    genDoCall     // generate doCall(...)
    genCall       // generate call(...) { doCall(...) }
    //genReturns
    //genArity
    substitute    // substitute closure code with anonymous class ctor
  }

//////////////////////////////////////////////////////////////////////////
// Setup
//////////////////////////////////////////////////////////////////////////

  private Void setup(ClosureExpr c)
  {
    this.closure         = c
    this.loc             = c.loc
    this.signature       = c.signature
    this.enclosingType   = c.enclosingType
  }

//////////////////////////////////////////////////////////////////////////
// Generate Class
//////////////////////////////////////////////////////////////////////////

  private Void genClass()
  {
    cls = TypeDef(loc, closure.enclosingType.unit, closure.name)
    cls.flags   = FConst.Internal + FConst.Final + FConst.Synthetic + FConst.Closure
    cls.setBase(closure.signature.typeRef)
    cls.closure = closure
    closure.cls = cls
    compiler.pod.addTypeDef(cls)
  }

//////////////////////////////////////////////////////////////////////////
// Generate Constructor
//////////////////////////////////////////////////////////////////////////

  private Void genCtor()
  {
    code := Block(loc)
    code.stmts.add(ReturnStmt.makeSynthetic(loc))

    ctor = MethodDef(loc, cls)
    ctor.flags = FConst.Internal + FConst.Ctor + FConst.Synthetic
    ctor.name = "make"
    ctor.ret  = ns.voidType
    ctor.code = code
    cls.addSlot(ctor)
  }

//////////////////////////////////////////////////////////////////////////
// Generate doCall()
//////////////////////////////////////////////////////////////////////////

  private Void genDoCall()
  {
    doCall = MethodDef(loc, cls)
    doCall.name  = "doCall"
    doCall.flags = FConst.Internal + FConst.Synthetic
    doCall.code  = closure.code
    doCall.ret = signature.ret
    doCall.paramDefs = signature.toParamDefs()
    closure.doCall = doCall
    cls.addSlot(doCall)
  }

//////////////////////////////////////////////////////////////////////////
// Generate call()
//////////////////////////////////////////////////////////////////////////

  private Void genCall()
  {
    c := CallExpr.makeWithMethod(loc, ThisExpr.makeType(loc, cls.asRef), doCall)
    c.ctype = signature.ret
    genMethodCall(compiler, loc, cls, signature, c, false)
  }

  **
  ** This method overrides either call(List) or callx(A...) to push the
  ** args onto the stack, then redirect to the specified CallExpr c.
  ** We share this code for both closures and curries.
  **
  MethodDef genMethodCall(CompilerContext compiler, Loc loc, TypeDef parent,
                                 FuncTypeDef signature, CallExpr c, Bool firstAsTarget)
  {
    ns := compiler.ns

    // method def
    m := MethodDef(loc, parent)
    m.flags = FConst.Override + FConst.Synthetic + FConst.Public
    m.ret   = ns.objType.toNullable
    m.code  = Block(loc)

    // signature:
    //   callList(List)             // if > MaxIndirectParams
    //   call(Obj p0, Obj p1, ...)  // if <= MaxIndirectParams
    paramCount := signature.params.size
    MaxIndirectParams := 8
    useListArgs := paramCount > MaxIndirectParams
    if (useListArgs)
    {
      // m.name  = "callList"
      // p := ParamDef(loc, ns.objType.toListOf, "list")
      // m.params.add(p)
      err("tow many params", loc)
    }
    // else
    // {
      m.name = "call"
      paramCount.times |Int i|
      {
        p := ParamDef(loc, ns.objType.toNullable, "p$i")
        m.paramDefs.add(p)
      }
    // }

    // init the doCall() expr with arguments
    paramCount.times |Int i|
    {
      Expr? arg

      // list.get(<i>)
      // if (useListArgs)
      // {
      //   listGet := CallExpr.makeWithMethod(loc, UnknownVarExpr(loc, null, "list"), ns.objType.toListOf.method("get"))
      //   listGet.args.add(LiteralExpr(loc, ExprId.intLiteral, ns.intType, i))
      //   arg = listGet
      // }

      // p<i>
      // else
      // {
        arg = LocalVarExpr(loc, m.paramDefs[i])
      // }

      // cast to closure param type
      arg = TypeCheckExpr.coerce(arg, signature.params[i])

      // add to doCall() argument list
      if (firstAsTarget && i == 0)
        c.target = arg
      else
        c.args.add(arg)
    }

    // return:
    //   doCall; return null;  // if doCall() is void
    //   return doCall         // if doCall() non-void
    if (signature.ret.isVoid)
    {
      m.code.add(c.toStmt)
      nullExpr := LiteralExpr.makeNull(loc)
      nullExpr.ctype = ns.objType.toNullable
      m.code.add(ReturnStmt.makeSynthetic(loc, nullExpr))
    }
    else
    {
      //res := TypeCheckExpr.coerce(c, ns.objType.toNullable)
      m.code.add(ReturnStmt.makeSynthetic(loc, c))
    }

    // add to our synthetic parent class
    parent.addSlot(m)
    if (parent.isClosure) parent.closure.call = m
    return m
  }
  /*
  private Void genReturns()
  {
    loc := cls.loc
    m := MethodDef(loc, cls)
    m.flags = FConst.Public + FConst.Synthetic + FConst.Override
    m.name = "returns"
    m.ret  = ns.typeType
    m.code = Block(loc)
    t := LiteralExpr(loc, ExprId.typeLiteral, ns.typeType, signature.ret)
    m.code.stmts.add(ReturnStmt.makeSynthetic(loc, t))
    cls.addSlot(m)
  }
  */

  private Void genArity()
  {
    loc := cls.loc
    m := MethodDef(loc, cls)
    m.flags = FConst.Public + FConst.Synthetic + FConst.Override
    m.name = "arity"
    m.ret  = ns.intType
    m.code = Block(loc)
    t := Expr.makeForLiteral(loc, signature.arity)
    m.code.stmts.add(ReturnStmt.makeSynthetic(loc, t))
    cls.addSlot(m)
  }

//////////////////////////////////////////////////////////////////////////
// Substitute
//////////////////////////////////////////////////////////////////////////

  **
  ** Generate in-place subtitution of closure:
  **   |->| { ... }  =>  Closure$Cls.make()
  **
  private Void substitute()
  {
    closure.code = null
    closure.substitute = CallExpr.makeWithMethod(loc, null, ctor)
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  ClosureExpr? closure        // current closure
  Loc? loc                    // closure.loc
  FuncTypeDef? signature         // closure.sig
  TypeDef? enclosingType      // closure.enclosingType
  TypeDef? cls                // current anonymous class implementing closure
  MethodDef? ctor             // anonymous class make ctor
  MethodDef? doCall           // R doCall(A a, ...) { closure.code }

}