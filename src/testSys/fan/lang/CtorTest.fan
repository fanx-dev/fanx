//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   9 Mar 06  Brian Frank  Creation
//

//using concurrent

class TestOrder {
  Int order := 0
  static const Unsafe<TestOrder> cur := Unsafe(TestOrder())
}

**
** CtorTest
**
class CtorTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Default
//////////////////////////////////////////////////////////////////////////

  Void testDefault()
  {
    verifyEq(CtorNone.make.x, "none")
    verifyEq(CtorSubNone.make.x, "none")
  }

//////////////////////////////////////////////////////////////////////////
// Autogen
//////////////////////////////////////////////////////////////////////////

  Void testAutoGen()
  {
    verifyEq(CtorAutoGen.foobar.x,   "bsf")
    verifyEq(CtorSubAutoGen1.make.x, "bsf")
    verifyEq(CtorSubAutoGen2.make.x, "bsf")
  }

//////////////////////////////////////////////////////////////////////////
// Base
//////////////////////////////////////////////////////////////////////////

  Void testBase()
  {
    c := CtorBase.make("x")
    verifyEq(c.x, "x")
    verifyEq(c.y, "y")

    c = CtorBase.makeDef()
    verifyEq(c.x, "defx")
    verifyEq(c.y, "defy")

    c = CtorBase.makeThis()
    verifyEq(c.x, "this")
    verifyEq(c.y, "y")

    c = CtorBase.makeInt(57)
    verifyEq(c.x, "[57]")
    verifyEq(c.y, "y")

    s := CtorSubBase.make
    verifyEq(s.x, "foo")
    verifyEq(s.y, "y")
  }

//////////////////////////////////////////////////////////////////////////
// Defs
//////////////////////////////////////////////////////////////////////////

  Void testDefs()
  {
    d := CtorDefs.make(1)
    verifyEq(d.a, 1)
    verifyEq(d.b, 2)
    verifyEq(d.c, 3)

    d = CtorDefs.make(1, 22)
    verifyEq(d.a, 1)
    verifyEq(d.b, 22)
    verifyEq(d.c, 3)

    d = CtorDefs.make(1, 22, 33)
    verifyEq(d.a, 1)
    verifyEq(d.b, 22)
    verifyEq(d.c, 33)

    d = CtorDefs.make3()
    verifyEq(d.a, -1)
    verifyEq(d.b, -2)
    verifyEq(d.c, -3)

    d = CtorDefs.make1()
    verifyEq(d.a, -1)
    verifyEq(d.b, 2)
    verifyEq(d.c, 3)

    d = CtorDefs.makeAdd(10, 20)
    verifyEq(d.a, 10)
    verifyEq(d.b, 20)
    verifyEq(d.c, 30)

    d = CtorSubDefs.make(9, 8, 7)
    verifyEq(d.a, 9)
    verifyEq(d.b, 8)
    verifyEq(d.c, 7)

    d = CtorSubDefs.make(11)
    verifyEq(d.a, 11)
    verifyEq(d.b, 12)
    verifyEq(d.c, 13)

    d = CtorSubDefs.makeThis1()
    verifyEq(d.a, 71)
    verifyEq(d.b, 12)
    verifyEq(d.c, 13)

    d = CtorSubDefs.makeSuper1()
    verifyEq(d.a, 72)
    verifyEq(d.b, 2)
    verifyEq(d.c, 3)
  }

//////////////////////////////////////////////////////////////////////////
// Order
//////////////////////////////////////////////////////////////////////////

  Void testOrder()
  {
    resetOrder
    a := CtorOrderA.make
    verifyEq(a.q, "0,1")

    resetOrder
    b := CtorOrderB.make
    verifyEq(b.q, "0,1")
    verifyEq(b.r, "0,1,2,3")
    verifyEq(b.x, 1)

    resetOrder
    b = CtorOrderB.makeThis
    verifyEq(b.q, "0,1")
    verifyEq(b.r, "0,1,2,3")
    verifyEq(b.x, 1)
  }

  static Void resetOrder() {
    TestOrder.cur.val.order = 0
  }

  static Int orderInit()
  {
    Int i := TestOrder.cur.val.order
    i += 1
    TestOrder.cur.val.order = i
    return i
  }

//////////////////////////////////////////////////////////////////////////
// Const Fields
//////////////////////////////////////////////////////////////////////////

  Void testConstFields()
  {
    x := ConstFieldCtor()
    verifyEq(x.listA.isImmutable, true)
    verifyEq(x.listB.isImmutable, true)
    verifyEq(x.mapA.isImmutable,  true)
    verifyEq(x.mapB.isImmutable,  true)
    verifyEq(x.funcA.isImmutable, true)
    verifyEq(x.funcB.isImmutable, true)
  }

}

//////////////////////////////////////////////////////////////////////////
// CtorNone
//////////////////////////////////////////////////////////////////////////

virtual class CtorNone
{
  Str x := "none"
}

class CtorSubNone : CtorNone
{
}

//////////////////////////////////////////////////////////////////////////
// CtorAutoGen
//////////////////////////////////////////////////////////////////////////

virtual class CtorAutoGen
{
  new foobar() { x = "bsf" }
  Str x
}

class CtorSubAutoGen1 : CtorAutoGen
{
}

class CtorSubAutoGen2 : CtorAutoGen
{
  new make() {}
}

//////////////////////////////////////////////////////////////////////////
// CtorBase
//////////////////////////////////////////////////////////////////////////

virtual class CtorBase
{
  new make(Str x) { this.x = x; this.y = "y"; }
  new makeDef()   { this.x = "defx"; this.y = "defy"; }
  new makeThis() : this.make("this") {}
  new makeInt(Int i) : this.make(i.toStr) { x = "[" + x + "]" }
  Str x
  Str y
}

class CtorSubBase : CtorBase
{
  new make() : super("foo") {}
}

//////////////////////////////////////////////////////////////////////////
// CtorDefs
//////////////////////////////////////////////////////////////////////////

virtual class CtorDefs
{
  new make(Int a, Int b := 2, Int c := 3)
  {
    this.a = a
    this.b = b
    this.c = c
  }

  new make1() : this.make(-1) {}
  new make3() : this.make(-1, -2, -3) {}
  new makeAdd(Int a, Int b) : this.make(a, b, a+b) {}

  Int a;
  Int b;
  Int c;
}

class CtorSubDefs : CtorDefs
{
  new make(Int a, Int b := 12, Int c := 13) : super(a, b, c) {}
  new makeThis1()  : this.make(71) {}
  new makeSuper1() : super.make(72) {}
}

//////////////////////////////////////////////////////////////////////////
// CtorOrdering
//////////////////////////////////////////////////////////////////////////

virtual class CtorOrderA
{
  new make(Str? a := null) { q += ",1" }
  Str q := "0"
}

class CtorOrderB : CtorOrderA
{
  new make() : super.make("foo") { r += ",3" }
  new makeThis() : this.make() {}
  Str r := q + ",2"
  Int x := CtorTest.orderInit
}

//////////////////////////////////////////////////////////////////////////
// ConstFieldCtor
//////////////////////////////////////////////////////////////////////////

class ConstFieldCtor
{
  new make()
  {
    listA = ["a"]
    listB = ["b"]
    mapA = ["a":"a"]
    mapB = ["b":"b"]
    funcA = |->| { echo("a") }
    funcB = |->| { echo("b") }
  }

  const List listA
  const Obj?[] listB
  const Map mapA
  const [Obj:Obj] mapB
  const Func funcA
  const |->| funcB
}

