//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   7 Sep 09  Brian Frank  Creation
//

**
** ClosureToImmutable processes each closure to determine
** its immutability.  At this point, all the enclosed variables
** have been mapped to fields by ClosureVars.  So we have
** three cases:
**
**  1. If every field is known const, then the function is
**     always immutable, and we can just override isImmutable
**     to return true.
**
**  2. If any field is known to never be const, then the function
**     can never be immutable, and we just use Func defaults for
**     isImmutable and toImmutable.
**
**  3. In the last case we have fields like Obj or List which require
**     us calling toImmutable.  In this case we generate a toImmutable
**     method which constructs a new closure instance by calling
**     toImmutable on each field.
**
**
class ClosureToImmutable : CompilerStep
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(CompilerContext compiler) : super(compiler) {}

//////////////////////////////////////////////////////////////////////////
// Run
//////////////////////////////////////////////////////////////////////////

  override Void run()
  {
    compiler.pod.closures.each |c| { process(c) }
  }

  private Void process(ClosureExpr closure)
  {
    cls := closure.cls

    // if always immutable, then override isImmutable
    // to be true and set all the fields to be const;
    // Func.toImmutable will do the right thing for us
    if (isAlwaysImmutable(cls))
    {
      genIsImmutable(cls, LiteralExpr.makeTrue(cls.loc))
      setAllFieldsConst(cls)
      return
    }

    // if never immutable then we inherit default toImmutable false
    // and generate a toImmutable which raises NotImmutableErr with
    // a meaningful error message
    never := isNeverImmutable(cls)
    if (never != null)
    {
      genToImmutableErr(cls, never)
      return
    }

    // if we have made it here we are neither always immutable
    // or never immutable - we could be immutable, but we have
    // to call toImmutable on each of our fields
    genToImmutable(cls)
  }

  **
  ** Are all the fields known to be const types?
  **
  Bool isAlwaysImmutable(TypeDef cls)
  {
    cls.instanceFieldDefs.all |f| { f.fieldType.isConst }
  }

  **
  ** Are any of the fields known to never be immutable?
  ** If any field is not immutable, then return meaningful error message.
  **
  Str? isNeverImmutable(TypeDef cls)
  {
    field := cls.instanceFieldDefs.find |f| { !f.fieldType.isConstFieldType } as FieldDef
    if (field == null) return null
    return "Closure field not const: " + (field.closureInfo ?: field.name)
  }

  **
  ** Set const flag on every field def.
  **
  Void setAllFieldsConst(TypeDef cls)
  {
    cls.fieldDefs.each |FieldDef f| { f.flags = f.flags.or(FConst.Const) }
  }

  **
  ** Generate: 'isImmutable() { return result }'
  **
  private Void genIsImmutable(TypeDef cls, Expr result)
  {
    loc := cls.loc
    m := MethodDef(loc, cls)
    m.flags = FConst.Public + FConst.Synthetic + FConst.Override
    m.name = "isImmutable"
    m.ret  = ns.boolType
    m.code = Block(loc)
    result.ctype = ns.boolType
    m.code.stmts.add(ReturnStmt.makeSynthetic(loc, result))
    cls.addSlot(m)
  }

  **
  ** Generate toImmutable which raises an error with a nice error
  ** message as to why the function is not immutable.
  **
  **   Obj toImmutable()
  **   {
  **     throw NotImmutableErr.make(msg);
  **   }
  **
  private Void genToImmutableErr(TypeDef cls, Str msg)
  {
    loc := cls.loc
    m := stubToImmutable(cls)
    ctor := CallExpr.makeWithMethod(loc, null, ns.notImmutableErrMake, [LiteralExpr.makeStr(loc, msg)])
    m.code.add(ThrowStmt(loc, ctor))
  }

  **
  ** Generate toImmutable by attempting to construct a copy
  ** of this closure with toImmutable called on every field
  ** along with a flag to keep track of which state we are in.
  **
  **   Obj toImmutable()
  **   {
  **     r := make( (T1)f1.toImmutable, ... )
  **     r.isImmutable$ = true
  **     return true
  **   }
  **
  **   Bool isImmutable() { immutable }
  **
  **   private Bool immutable
  **
  private Void genToImmutable(TypeDef cls)
  {
    loc := cls.loc

    // Bool immutable
    immutableField := FieldDef(loc, cls)
    immutableField.name = "immutable"
    immutableField.fieldType = ns.boolType
    immutableField.flags = FConst.Private + FConst.Storage + FConst.Synthetic
    cls.addSlot(immutableField)

    // Bool isImmutable() { immutable }
    genIsImmutable(cls, FieldExpr.makeField(loc, ThisExpr.makeType(loc, cls.asRef), immutableField, false))

    // Obj toImmutable()
    m := stubToImmutable(cls)

    // make( (T1)f1.toImmutable, ... )
    ctor := cls.methodDef("make")
    args := Expr[,]
    ctor.params.each |param|
    {
      field := cls.fieldDef(param.name)
      if (field == null) throw Err("Closure param missing matched field $param.name")
      fieldGet := FieldExpr.makeField(loc, ThisExpr.makeType(loc, cls.asRef), field, false)
      if (field.fieldType.isConst)
      {
        args.add(fieldGet)
      }
      else
      {
        call := CallExpr.makeWithMethod(loc, fieldGet, ns.objToImmutable)
        args.add(TypeCheckExpr.coerce(call, field.fieldType))
      }
    }
    makeCall := CallExpr.makeWithMethod(loc, null, ctor, args)

    // temp = make
    temp := m.addLocalVar(loc, cls.asRef, "temp", m.code)
    m.code.add(BinaryExpr.makeAssign(
      LocalVarExpr(loc, temp),
      makeCall).toStmt)

    // temp.immutable = true
    m.code.add(BinaryExpr.makeAssign(
        FieldExpr.makeField(loc, LocalVarExpr(loc, temp), immutableField, false),
        LiteralExpr.makeTrue(loc)).toStmt)

    // return temp
    m.code.add(ReturnStmt.makeSynthetic(loc, LocalVarExpr(loc, temp)))
  }

  ** Stub the 'Obj toImmutable()' method
  private MethodDef stubToImmutable(TypeDef cls)
  {
    loc := cls.loc
    m := MethodDef(loc, cls)
    m.flags = FConst.Public + FConst.Synthetic + FConst.Override
    m.name = "toImmutable"
    m.ret  = ns.objType
    m.code = Block(loc)
    cls.addSlot(m)
    return m
  }

}

