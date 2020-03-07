//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//    9 Mar 06  Brian Frank  Creation
//   19 Sep 06  Brian Frank  Ported from Java to Fan
//

**
** DefaultCtor adds a default public constructor called make()
** if no constructor was explicitly specified.
**
class DefaultCtor : CompilerStep
{

  new make(CompilerContext compiler)
    : super(compiler)
  {
  }

  override Void run()
  {
    //debug("DefaultCtor")
    walkUnits(VisitDepth.typeDef)
  }

  override Void visitTypeDef(TypeDef t)
  {
    if (t.isMixin || t.isEnum || t.isFacet) return

    hasCtor := t.methodDefs.any |MethodDef m->Bool| { m.isInstanceCtor }
    if (hasCtor) return

    // ensure there isn't already a slot called make
    dup := t.slotDef("make")
    if (dup != null)
    {
      if (dup.parent === t)
        err("Default constructor 'make' conflicts with slot at " + dup->loc->toLocStr, t.loc)
      else
        err("Default constructor 'make' conflicts with inherited slot '$dup.qname'", t.loc)
      return
    }

    addDefaultCtor(t, FConst.Public)
  }

  static MethodDef addDefaultCtor(TypeDef parent, Int flags)
  {
    loc := parent.loc.toPointLoc

    block := Block(loc)
    block.stmts.add(ReturnStmt.makeSynthetic(loc))

    m := MethodDef(loc, parent)
    m.flags = flags.or(FConst.Ctor + FConst.Synthetic)
    m.name  = "make"
    m.ret   = CType.voidType(loc)
    m.code  = block

    parent.addSlot(m)
    return m
  }

}