//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Mar 06  Brian Frank  Creation
//

//using concurrent

**
** ClosureTest
**
class ClosureTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Play
//////////////////////////////////////////////////////////////////////////

  /*
  Void testPlay()
  {
    { echo("hello") }.call
  }
  */

//////////////////////////////////////////////////////////////////////////
// Immutable
//////////////////////////////////////////////////////////////////////////

  Void testImmutable()
  {
    x := 2
    y := 3
    in := StrBuf()//"foo".in
    c := ClosureInConst()
    Obj? xObj := x
    Obj? inObj := in
    Obj cObj := c
    Int? m := 3

    verifyAlwaysImmutable |->| { echo("foo") }
    verifyAlwaysImmutable |->|{ echo(x) }
    verifyAlwaysImmutable |->|{ echo("$x, $y") }
    verifyAlwaysImmutable(c.f)

    verifyNeverImmutable |->| { echo(this) }
    verifyNeverImmutable |->| { echo(in) }
    verifyNeverImmutable |->| { echo("$this, $in") }
    verifyNeverImmutable |->| { m += 1 }
    verifyNeverImmutable |->| { echo(m) } // b/c of above

    verifyMaybeImmutable(true)  |->| { echo(xObj) }
    verifyMaybeImmutable(true)  |->| { echo(cObj) }
    verifyMaybeImmutable(false) |->| { echo(inObj) }
  }

  Void testImmutableList()
  {
    list := [0, 1, 2]
    f := |->Obj| { list }
    |->Obj| g := f.toImmutable
    verifyEq(f.isImmutable, false); verifyEq(f(), [0, 1, 2])
    verifyEq(g.isImmutable, true);  verifyEq(g(), [0, 1, 2])
    list.add(3)
    verifyEq(f(), [0, 1, 2, 3])
    verifyEq(g(), [0, 1, 2])
    verifyEq(g()->isImmutable, true)
  }

  Void verifyAlwaysImmutable(Func f)
  {
    verifyEq(f.isImmutable, true)
    verifySame(f.toImmutable, f)
  }

  Void verifyNeverImmutable(Func f)
  {
    verifyEq(f.isImmutable, false)
    verifyErr(NotImmutableErr#) { f.toImmutable }
  }

  Void verifyMaybeImmutable(Bool ok, Func f)
  {
    verifyEq(f.isImmutable, false)
    if (ok)
    {
      g := f.toImmutable
      verifyNotSame(f, g)
      verifyEq(g.isImmutable, true)
    }
    else
    {
      verifyErr(NotImmutableErr#) { f.toImmutable }
    }
  }

//////////////////////////////////////////////////////////////////////////
// Func Fields
//////////////////////////////////////////////////////////////////////////

  Void testFuncFields()
  {
    verifyEq(ClosureFieldA().f.call, 1972)
    verifyErr(NotImmutableErr#) { ClosureFieldB().f.call }
  }

//////////////////////////////////////////////////////////////////////////
// Param Cvars
//////////////////////////////////////////////////////////////////////////

  Void testParamCvars()
  {
    verifyEq(paramCvars1(0), "3")
    verifyEq(paramCvars1(4), "7")
    verifyEq(paramCvars2(0, 0), "3,-3")
    verifyEq(paramCvars2(-3, 3), "0,0")
    verifyEq(paramCvars3("a", "b", "c"), "clear0101,b0101,reset01")
  }

  Str paramCvars1(Int x)
  {
    3.times( |Int i| { x++ } )
    return x.toStr
  }

  Str paramCvars2(Int x, Int y)
  {
    3.times( |Int i| { x++; y--; } )
    return x.toStr + "," + y.toStr
  }

  Str paramCvars3(Str x, Str y, Str z)
  {
    x = "clear"
    2.times( |Int i| { x = x+i.toStr; y = y+i.toStr; z =z+i.toStr } )
    z = "reset"
    2.times( |Int i| { x = x+i.toStr; y = y+i.toStr; z =z+i.toStr } )
    return x + "," + y + "," + z
  }

//////////////////////////////////////////////////////////////////////////
// Local Cvars
//////////////////////////////////////////////////////////////////////////

  Void testLocalCvars()
  {
    x := 2
    y := 1
    3.times( |Int i| { x += y } )
    verifyEq(x, 5)

    Func m := |->| { x += y }
    verifyEq(x, 5)
    m.call
    verifyEq(x, 6)
    y = -6
    m.call
    verifyEq(x, 0)
    x = 0; y = 1
    5.times( |Int i| { m.call } )
    verifyEq(x, 5)

    // this reproduces a bug found by Andy
    if (true)
    {
      first := false
      3.times |Int foobar|
      {
        if (first) first = false
      }
    }
  }

//////////////////////////////////////////////////////////////////////////
// Static Self
//////////////////////////////////////////////////////////////////////////

  Void testStaticSelf()
  {
    loc := "local+"

    // static field, no locals
    verifyEq(|->Str| { return sx }.call, "dora")

    // static method, no locals
    verifyEq(|->Str| { return sm }.call, "wiggles")
    verifyEq(|->Str| { return sm() }.call, "wiggles")
    verifyEq(|->Str| { return sm("!") }.call, "wiggles!")

    // static field, with locals
    verifyEq(|->Str| { return loc+sx }.call, "local+dora")

    // static method, with locals
    verifyEq(|->Str| { return loc+sm }.call, "local+wiggles")

    // change local
    m := |->Str| { return loc+sx }
    verifyEq(m.call, "local+dora")
    loc = "new local+";
    verifyEq(m.call, "new local+dora")
  }

  const static Str sx := "dora";
  static Str sm(Str append := "") { return "wiggles"+append }

//////////////////////////////////////////////////////////////////////////
// Instance Self
//////////////////////////////////////////////////////////////////////////

  Void testInstanceSelf()
  {
    loc := "local+"

    // instance field, no locals
    verifyEq(|->Str| { return ix }.call, "blue")

    // instance method, no locals
    verifyEq(|->Str| { return im }.call, "higgleytown 0")
    verifyEq(|->Str| { return im() }.call, "higgleytown 0")
    verifyEq(|->Str| { return im(7) }.call, "higgleytown 7")

    // instance field, with locals
    verifyEq(|->Str| { return loc+ix }.call, "local+blue")

    // instance method, with locals
    verifyEq(|->Str| { return loc+im }.call, "local+higgleytown 0")
    verifyEq(|->Str| { return loc+im() }.call, "local+higgleytown 0")
    verifyEq(|->Str| { return loc+im(6) }.call, "local+higgleytown 6")

    // change local
    m := |->Str| { return loc+ix }
    verifyEq(m.call, "local+blue")
    loc = "new local+";
    verifyEq(m.call, "new local+blue")
  }

  Str ix := "blue";
  Str im(Int n := 0) { return "higgleytown "+n }

//////////////////////////////////////////////////////////////////////////
// Scope
//////////////////////////////////////////////////////////////////////////

  Str name() { return "foobar" }

  Void testScope()
  {
    verifyEq(|->Obj| { return name }.call, "foobar")
    verifyEq(|->Obj| { return name() }.call, "foobar")
    verifySame(|->Obj| { return this }.call, this)
    verifySame(|->Obj| { return this.name }.call, "foobar")
    verifySame(|->Obj| { return this.name() }.call, "foobar")
    verifySame(|->Obj| { return isImmutable }.call, false)
    verifySame(|->Obj| { return Type.of(this) }.call, Type.of(this))
  }

//////////////////////////////////////////////////////////////////////////
// As Param
//////////////////////////////////////////////////////////////////////////

  Void testAsParam()
  {
    list := [ 10, 20, 30 ]
    n := 0

    // inside
    n = 0; list.each( |Int x| { n += x } ); verifyEq(n, 60);

    // outside with paren
    n = 0; list.each() |Int x| { n += x }; verifyEq(n, 60);

    // outside without paren
    n = 0; list.each |Int x| { n += x }; verifyEq(n, 60);
  }

//////////////////////////////////////////////////////////////////////////
// Calls
//////////////////////////////////////////////////////////////////////////

  Void testCalls()
  {
    f := |Int a, Int b, Int c->Int[]| { return [a, b, c] }
    verifyEq(f.call(1, 2, 3),        [1, 2, 3])
    verifyEq(f.callList([1, 2, 3]),       [1, 2, 3])
    verifyEq(f.callList([1, 2, 3, 4]),    [1, 2, 3])
    verifyEq(f.callOn(1, [2, 3, 4]),  [1, 2, 3])
  }

//////////////////////////////////////////////////////////////////////////
// Closures in Once
//////////////////////////////////////////////////////////////////////////

  Void testOnce()
  {
    s := onceIt
    verify(s.endsWith(" 0 1 2"))
    //Actor.sleep(10ms)
    verifyEq(onceIt, s)

    verifyEq(onceAgain, "(A,B)(a,b)")
  }

  once Str onceIt()
  {
    s := StrBuf.make.add(TimePoint.now)
    3.times |Int i| { s.add(" $i") }
    return s.toStr
  }

  once Str onceAgain()
  {
    Str r := ""
    a := "A"
    b := "B"
    f := |->| { r = r + "(" + a + "," + b + ")" }
    f()
    a = "a"
    b = "b"
    f()
    return r
  }

//////////////////////////////////////////////////////////////////////////
// This In Closure
//////////////////////////////////////////////////////////////////////////

  Void testThis()
  {
    str := this.toStr
    x := ""
    f := |->|
    {
      x = this.toStr
      verifyEq(toStr, str)
      verifyEq(this.toStr, str)
      verifyEq(Type.of(this), ClosureTest#)
    }
    f()
    verifyEq(x, str)
  }

//////////////////////////////////////////////////////////////////////////
// Builder Test
//////////////////////////////////////////////////////////////////////////

  Void testBuilderTest()
  {
    verifyEq(buildTest { x="x"; y="y"}, ["x", "y"])
    verifyEq(buildTest { it.x="x" },    ["x", ""])
  }

  static Str[] buildTest(|TestBuilder| f)
  {
    b := TestBuilder()
    f(b)
    return [b.x, b.y]
  }

//////////////////////////////////////////////////////////////////////////
// Nested Test
//////////////////////////////////////////////////////////////////////////

  Void testNested()
  {
    v := 'v'
    f := |->Int[]|
    {
      Int? w := null
      g := |->Int[]|
      {
        w = 'w'
        x := 'x'
        h := |->Int[]|
        {
          y := 99
          i := |->Int[]|
          {
            j := |->Int[]|
            {
              y = 'y'
              z := 'z'
              return [v, w, x, y, z]
            }
            return j()
          }
          return i()
        }
        return h()
      }
      return g()
    }
    verifyEq(f(), Int?['v', 'w', 'x', 'y', 'z'])
  }

}

**************************************************************************
** Classes
**************************************************************************

class ClosureFieldA
{
  const |->Int| f := |->Int| { return 1972 } // ok
}

class ClosureFieldB
{
  const |->Str| f := |->Str| { return toStr } // uses this
}

const class ClosureInConst
{
  Func f() { |->| { echo(this) } }
}

**************************************************************************
** TestBuilder
**************************************************************************

class TestBuilder
{
  Str x := ""
  Str y := ""
}