//
// Copyright (c) 2011, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2 Jan 11  Andy Frank  Creation
//

**
** CompilerJsTest
**
@Js
class CompilerJsTest : Test
{

//////////////////////////////////////////////////////////////////////////
// testMethodHiding
//////////////////////////////////////////////////////////////////////////

  Void testMethodHiding()
  {
    a := CompilerJsA()
    b := CompilerJsB()

    verifyEq(a.foo, "a")
    verifyEq(b.foo, "a")
    verifyEq(b.bar, "b")

    verifyEq(a.f1, "fa")
    verifyEq(b.f1, "fa")
    verifyEq(b.f2, "fb")
  }

//////////////////////////////////////////////////////////////////////////
// testShortcutFieldSet
//////////////////////////////////////////////////////////////////////////

  Void testShortcutFieldSet()
  {
    c := CompilerJsC()
    verifyEq(c.x, 0)
    c.foo; verifyEq(c.x, 4)
    c.foo; verifyEq(c.x, 8)
  }
}

@Js class CompilerJsA
{
  Str foo() { getFoo }
  private Str getFoo() { "a" }

  Str f1() { _f1 }
  private Str _f1 := "fa"
}

@Js class CompilerJsB : CompilerJsA
{
  Str bar() { getFoo2 }
  private Str getFoo2() { "b" }

  Str f2() { _f2 }
  private Str _f2 := "fb"
}

@Js class CompilerJsC
{
  virtual Int x := 0
  Void foo() { x += 4 }
}