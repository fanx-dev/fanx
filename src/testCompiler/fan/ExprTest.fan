//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   25 Aug 06  Brian Frank  Creation
//

**
** ExprTest
**
class ExprTest : CompilerTest
{

//////////////////////////////// //////////////////////////////////////////
// Literals
//////////////////////////////////////////////////////////////////////////

  Void testLiterals()
  {
    // null
    verifyExpr("null", null)

    // bool
    verifyExpr("false", false)
    verifyExpr("true", true)

    // int
    verifyExpr("0", 0)
    verifyExpr("1", 1)
    verifyExpr("0xabcd_1234_fedc_9876", 0xabcd_1234_fedc_9876)
    verifyExpr("493859850", 493859850)
    verifyExpr("-1", -1)
    verifyExpr("-123_456", -123_456)

    // float
    verifyExpr("0f",    0.0f)
    verifyExpr("0.0f",  0.0f)
    verifyExpr("1f",    1.0f)
    verifyExpr("1.2f",  1.2f)
    verifyExpr("-1.2F", -1.2f)

    // decimal
    verifyExpr("0.00d", 0.00d)
    verifyExpr("3d",    3d)
    verifyExpr("4e14d", 4e14d)
    verifyExpr("-5.2d", -5.2d)

    // str
    verifyExpr("\"\"",  "")
    verifyExpr("\"x\"", "x")
    verifyExpr("\"x\\ny\"", "x\ny")

    // duration
    //verifyExpr("0ns",     0ns)
    verifyExpr("1ms",     1ms)
    verifyExpr("1.2sec",  1200ms)
    verifyExpr("1.5min",  90_000ms)
    verifyExpr("1hr",     3_600_000ms)
    verifyExpr("0.5day",  43_200_000ms)

    // uri
    verifyExpr("`x`",  `x`)
    verifyExpr("`http://fantom/path/file?query#frag`", `http://fantom/path/file?query#frag`)

    // type
    verifyExpr("Str#", Str#)
    verifyExpr("sys::Str#", Str#)
    verifyExpr("Str[]#", Str[]#)
    verifyExpr("Str:Int#", Str:Int#)
    verifyExpr("|Str a->Bool|#", |Str a->Bool|#)

    // type
    verifyExpr("Str#getRange", Str#.method("getRange"))
    verifyExpr("sys::Str#getRange", Str#.method("getRange"))
    verifyExpr("Str[]#add", Str[]#.method("add"))
    //verifyExpr("Str:Int#caseInsensitive", Str:Int#.field("caseInsensitive"))
    //verifyExpr("|Str a->Bool|#call.returns", Bool#)
    verifyExpr("Obj#echo", Obj#.method("echo"))
    verifyExpr("Obj#echo.returns", Void#)

    // range
    verifyExpr("2..3",  2..3)
    verifyExpr("2..<3", 2..<3)

    // list
    verifyExpr("[,]", [,])
    verifyExpr("Str[,]", Str[,])
    verifyExpr("Int[3]", Int[3])
    verifyExpr("[0]",  [0])
    verifyExpr("[0,1]", [0,1])
    verifyExpr("Obj[0,1]", Obj[0,1])
    verifyExpr("[2,2f]", Num[2,2f])

    // map
    verifyExpr("[:]", [:])
    verifyExpr("Int:Str[:]", Int:Str[:])
    verifyExpr("[2:2f]", [2:2f])
    verifyExpr("[2:2f, 3:3]", Int:Num[2:2f, 3:3])
    verifyExpr("[2:2f, 3f:3f]", Num:Float[2:2f, 3f:3f])
  }

//////////////////////////////////////////////////////////////////////////
// Locals
//////////////////////////////////////////////////////////////////////////

  Void testLocals()
  {
    verifyExpr("a", 3, 3)
    verifyExpr("b", 2, 1, 2)
    verifyExpr("c", 3, 1, 2, "c := 3;")
    verifyExpr("c", 3, 1, 2, "Int c := 3;")
    verifyExpr("c", 7, 1, 2, "Int? c; c = 7;")
    verifyExpr("c", null, 1, 2, "Int? c;")
  }

//////////////////////////////////////////////////////////////////////////
// Operators
//////////////////////////////////////////////////////////////////////////

  Void testOperators()
  {
    verifyExpr("!a", true, false)
    verifyExpr("!a", false, true)

    verifyExpr("+a", 2, 2)
    verifyExpr("+a", -2f, -2f)

    verifyExpr("a == b", true, 3ms, 3ms)
    verifyExpr("a != b", false, 3ms, 3ms)

    verifyExpr("a == null",  false, 3ms, null, "", true)
    verifyExpr("a === null", false, 3ms, null, "", true)
    verifyExpr("a != null",  true,  3ms, null, "", true)
    verifyExpr("a !== null", true,  3ms, null, "", true)
    verifyExpr("null == a",  true,  null, null, "Str? a := null;")
    verifyExpr("null === a", true,  null, null, "Str? a := null;")
    verifyExpr("null != a",  false, null, null, "Str? a := null;")
    verifyExpr("null !== a", false, null, null, "Str? a := null;")

    verifyExpr("a || b", true, true, true)
    verifyExpr("a || b", true, false, true)
    verifyExpr("a || b", true, true, false)
    verifyExpr("a || b", false, false, false)

    verifyExpr("a && b", true, true, true)
    verifyExpr("a && b", false, false, true)
    verifyExpr("a && b", false, true, false)
    verifyExpr("a && b", false, false, false)

    verifyExpr("(Obj)a is Str", false, 4)
    verifyExpr("(Obj)a is Str", true, "x")

    verifyExpr("(Obj)a isnot Str", true, 4)
    verifyExpr("(Obj)a isnot Str", false, "x")

    verifyExpr("(Obj)a as Str", null, 4)
    verifyExpr("(Obj)a as Str", "x", "x")

    verifyExpr("(Str)a", "x", "x")
    verifyErr(CastErr#) { verifyExpr("(Str)((Obj)a)", null, 3) }

    verifyExpr("true ? a : b", 1, 1, 2)
    verifyExpr("false ? a : b", 2, 1, 2)
  }

//////////////////////////////////////////////////////////////////////////
// Call
//////////////////////////////////////////////////////////////////////////

  Void testCall()
  {
    // import static with arg
    verifyExpr("Str.spaces(1)", " ")
    verifyExpr("sys::Str.spaces(2)", "  ")

    // import static no args
    verifyExpr("Env.cur.args()", Env.cur.args)
    verifyExpr("std::Env.cur.args()", Env.cur.args)
    verifyExpr("Env.cur.args", Env.cur.args)
    verifyExpr("std::Env.cur.args", Env.cur.args)

    // import instance target
    verifyExpr("3.increment()", 4)
    verifyExpr("5.increment", 6)
    verifyExpr("2.increment().increment.isEven", true)

    // default args
    verifyExpr("\"abcb\".index(\"b\")", 1)
    verifyExpr("\"abcb\".index(\"b\", 2)", 3)

    // instance myself
    verifyExpr("ifoo", "ifoo")
    verifyExpr("ifoo()", "ifoo")
    verifyExpr("this.ifoo", "ifoo")
    verifyExpr("this.ifoo()", "ifoo")

    // static myself
    verifyExpr("sfoo", "sfoo")
    verifyExpr("sfoo()", "sfoo")
    verifyExpr("Foo.sfoo", "sfoo")
    verifyExpr("Foo.sfoo()", "sfoo")
    verifyExpr("${podName}::Foo.sfoo", "sfoo")
    verifyExpr("${podName}::Foo.sfoo()", "sfoo")

    // generics
    verifyExpr("x.negate", -20, [0, 10, 20, 30], null, "Int x := -1; x = a[2];")
  }

//////////////////////////////////////////////////////////////////////////
// Dynamic Call
//////////////////////////////////////////////////////////////////////////

  Void testDynamicCall()
  {
    // dynamic calls
    verifyExpr("((Obj)3)->negate", -3)
    verifyExpr("((Obj)3)->plus(2)", 5)
    verifyExpr("((Obj)3)->plus = 6", 9)
  }

//////////////////////////////////////////////////////////////////////////
// Safe Calls
//////////////////////////////////////////////////////////////////////////

  Void testSafe()
  {
    verifyExpr("a?.size()", 3, "abc", null, "", true)
    verifyExpr("a?.size()", null, xNull, null, "", true)
    verifyExpr("a?->size()", 6, "foobar", null, "", true)
    verifyExpr("a?->size()", null, xNull, null, "", true)

    verifyExpr("a?.size", 3, "abc", null, "", true)
    verifyExpr("a?.size", null, xNull, null, "", true)
    verifyExpr("a?->size", 6, "foobar", null, "", true)
    verifyExpr("a?->size", null, xNull, null, "", true)

    verifyExpr("a?.size()?.plus(6)", 9, "abc", null, "", true)
    verifyExpr("a?.size()?.plus(6)", null, xNull, null, "", true)
    verifyExpr("a?->size()?->plus(6)", 12, "foobar", null, "", true)
    verifyExpr("a?->size()?->plus(6)", null, xNull, null, "", true)

    verifyExpr("a?.size?.plus(6)", 9, "abc", null, "", true)
    verifyExpr("a?.size?.plus(6)", null, xNull, null, "", true)
    verifyExpr("a?->size?->plus(6)", 12, "foobar", null, "", true)
    verifyExpr("a?->size?->plus(6)", null, xNull, null, "", true)
  }

  // also see MiscTest.testSafe for more complicated test

//////////////////////////////////////////////////////////////////////////
// Elvis
//////////////////////////////////////////////////////////////////////////

  Void testElvis()
  {
    verifyExpr("a?:\"x\"", "abc", "abc", null, "", true)
    verifyExpr("a?:\"x\"", "x", xNull, null, "", true)
    verifyExpr("a.index(\"b\")?:-1", 1, "abc", null, "", true)
    verifyExpr("a.index(\"b\")?:-1", -1, "xyz", null, "", true)

    verifyExpr("(a ?: b) ?: \"x\"", "foo", "foo", "bar", "", true)
    verifyExpr("(a ?: b) ?: \"x\"", "foo", "foo", xNull, "", true)
    verifyExpr("(a ?: b) ?: \"x\"", "bar", xNull, "bar", "", true)
    verifyExpr("(a ?: b) ?: \"x\"", "x",   xNull, xNull, "", true)

    verifyExpr("(a ?: b) < \"m\"", true, "a", "z", "", true)
    verifyExpr("(a ?: b) < \"m\"", false, xNull, "z", "", true)
  }

//////////////////////////////////////////////////////////////////////////
// Throw Expr
//////////////////////////////////////////////////////////////////////////

  Void testThrowExpr()
  {
    compile(
     "class Foo
      {
        Str a(Int x) { v := x.isOdd ? x + 100 : throw ArgErr(); return v.toHex }
        Str b(Int x) { v := x.isOdd ? throw ArgErr() : x + 100; return v.toHex }
        Str c(Int x) { x.isOdd ? throw ReadonlyErr() : throw IOErr() }
        //Str d(Str x) { v := Int.fromStr(x, 10, false) ?: throw IOErr(); return v.toHex }
      }
      ")

     o := pod.types.first.make
     verifyEq(o->a(5), 105.toHex)
     verifyErr(ArgErr#) { o->a(4) }
     verifyEq(o->b(4), 104.toHex)
     verifyErr(ArgErr#) { o->b(5) }
     verifyErr(ReadonlyErr#) { o->c(3) }
     verifyErr(IOErr#) { o->c(4) }
     //verifyEq(o->d("45"), 45.toHex)
     //verifyErr(IOErr#) { o->d("xyz") }
  }

//////////////////////////////////////////////////////////////////////////
// Shortcuts
//////////////////////////////////////////////////////////////////////////

  Void testShortcuts()
  {
    // math operators
    verifyExpr("-a", -7, 7)
    verifyExpr("a + b", 3, 1, 2)
    verifyExpr("a - b", 2, 5, 3)
    verifyExpr("a * b", 12, 4, 3)
    verifyExpr("a / b", 3, 12, 4)
    verifyExpr("a % b", 1, 5, 2)

    // equality
    verifyExpr("a == b", true, "x", "x", "", true)
    verifyExpr("a == null", false, "x", "x", "", true)
    verifyExpr("null == a", false, "x", "x", "", true)
    verifyExpr("a != b", false, "x", "x", "", true)
    verifyExpr("a != null", true, "x", "x", "", true)
    verifyExpr("null != a", true, "x", "x", "", true)

    // comparisons
    verifyExpr("a < b", true, 2, 3)
    verifyExpr("a < b", false, 2, 2)
    verifyExpr("a <= b", true, 2, 3)
    verifyExpr("a <= b", true, 2, 2)
    verifyExpr("a <= b", false, 2, 1)
    verifyExpr("a > b", true, 4, 3)
    verifyExpr("a > b", false, 4, 9)
    verifyExpr("a >= b", true, 4, 3)
    verifyExpr("a >= b", true, 2, 2)
    verifyExpr("a >= b", false, 2, 4)
    verifyExpr("a <=> b", 0, 3, 3)
    verifyExpr("a <=> b", -1, 3, 7)
    verifyExpr("a <=> b", +1, -1, -2)

    // get
    verifyExpr("a[b]", 'b', "abc", 1)
    verifyExpr("a[b]", 'c', "abc", 2)

    // set
    verifyExpr("a[b] = 99", [0, 99, 2], [0, 1, 2], 1)
    verifyExpr("a[b] = 99", [99, 1, 2], [0, 1, 2], -3)

    // slice
    verifyExpr("a[b]", [1,2], [0, 1, 2, 3], 1..2)
    verifyExpr("a[b]", [1], [0, 1, 2, 3], 1..<2)
    verifyExpr("a[b]", [2, 3], [0, 1, 2, 3], -2..-1)
    verifyExpr("a[b]", [2], [0, 1, 2, 3], -2..<-1)
  }

//////////////////////////////////////////////////////////////////////////
// Assignments
//////////////////////////////////////////////////////////////////////////

  Void testAssignments()
  {
    verifyAssignments("a")
  }

  Void verifyAssignments(Str v)
  {
    verifyExpr("$v", 2, 1, 2, "$v = b;")

    verifyExpr("$v", 5, 2, 3,  "x := a; $v = x; $v += b;")
    verifyExpr("$v", -1, 2, 3, "x := a; $v = x; $v-= b;")
    verifyExpr("$v", 6, 2, 3,  "x := a; $v = x; $v*= b;")
    verifyExpr("$v", 3, 6, 2,  "x := a; $v = x; $v/= b;")
    verifyExpr("$v", 2, 8, 3,  "x := a; $v = x; $v%= b;")
  }

//////////////////////////////////////////////////////////////////////////
// Increment Operators
//////////////////////////////////////////////////////////////////////////

  Void testIncrementOps()
  {
    verifyIncrementOps("a", true)
  }

  Void verifyIncrementOps(Str v, Bool testFloat)
  {
    verifyExpr("++$v", 3, 2, 0, "x := a; $v = x;")
    verifyExpr("$v++", 2, 2, 0, "x := a; $v = x;")
    verifyExpr("[$v,b]", [2,3], 0, 2, "$v = b++;")
    verifyExpr("[$v,b]", [3,3], 0, 2, "$v = ++b;")

    verifyExpr("--$v", 1, 2, 0, "x := a; $v = x;")
    verifyExpr("$v--", 2, 2, 0, "x := a; $v = x;")
    verifyExpr("[$v,b]", [2,1], 0, 2, "$v = b--;")
    verifyExpr("[$v,b]", [1,1], 0, 2, "$v = --b;")

    verifyExpr("--a == b", true, 3, 2)

    if (testFloat)
    {
      verifyExpr("++a", 3f, 2f)
      verifyExpr("a++", 2f, 2f)
      verifyExpr("[a,b]", [2f,3f], 0f, 2f, "a = b++;")
      verifyExpr("[a,b]", [3f,3f], 0f, 2f, "a = ++b;")

      verifyExpr("--a", 1f, 2f)
      verifyExpr("a--", 2f, 2f)
      verifyExpr("[a,b]", [2f,1f], 0f, 2f, "a = b--;")
      verifyExpr("[a,b]", [1f,1f], 0f, 2f, "a = --b;")
    }
  }

  Void testIncrementMore()
  {
    src :=
     "class Foo
      {
        Int f() { return a += b++ }
        Int g() { return a += ++b }
        Void h() { 3.times |->| { a = (b++) } }
        Int i() { return a += b++ + (c++).toInt }
        Void j() { x := 2; a = |->Int| { return x++ }.call; b = x } // cvar field

        Int a := 2
        Int b := 3
        Float c := 4f
      }"
     compile(src)

     t := pod.types.first

     o := t.make
     verifyEq(t.method("f").callOn(o, null), 5)
     verifyEq(o->a, 5)
     verifyEq(o->b, 4)

     o = t.make
     verifyEq(t.method("g").callOn(o, null), 6)
     verifyEq(o->a, 6)
     verifyEq(o->b, 4)

     o = t.make
     verifyEq(t.method("h").callOn(o, null), null)
     verifyEq(o->a, 5)
     verifyEq(o->b, 6)

     o = t.make
     verifyEq(t.method("i").callOn(o, null), 9)
     verifyEq(o->a, 9)
     verifyEq(o->b, 4)
     verifyEq(o->c, 5.0f)

     o = t.make
     verifyEq(t.method("j").callOn(o, null), null)
     verifyEq(o->a, 2)
     verifyEq(o->b, 3)
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  Void testFields()
  {
    // don't rely on field initializers in this test
    verifyExpr("f", 7, 0, 0, "f = 7;")
    verifyAssignments("f")
    verifyIncrementOps("f", false)

    // const static
    verifyExpr("sf", 1972)

    // generics
    verifyExpr("tue", Weekday.tue, null, null, "Weekday tue := Weekday.vals[2];")
  }

//////////////////////////////////////////////////////////////////////////
// Safe Fields
//////////////////////////////////////////////////////////////////////////

  Void testSafeFields()
  {
    verifyExpr("x?.f", 7, 0, 0, "f = 7; Foo? x := this;", true)
    verifyExpr("x?.f", null, 0, 0, "f = 7; Foo? x := null;", true)
  }

  // also see MiscTest.testSafe for more complicated test

//////////////////////////////////////////////////////////////////////////
// Str Concat
//////////////////////////////////////////////////////////////////////////

  Void testStrConcat()
  {
    verifyExpr("\"\$a \$b\"", "4 5", 4, 5)
    verifyExpr("\"x\" + a", "x7", 7)
    verifyExpr("a + \"x\"", "7x", "7")

    verifyExpr("a += \"y\"", "xy", "x")
  }

//////////////////////////////////////////////////////////////////////////
// Test Construction Calls
//////////////////////////////////////////////////////////////////////////

  Void testConstruction()
  {
    verifyExpr("Version(\"3.4.9\")", Version.make([3,4,9]))
    verifyExpr("std::Version(\"\${a}.99\")", Version.make([3,6,99]), "3.6")
    verifyExpr("Range(3,7,true)", Range.make(3, 7,true))
    verifyExpr("sys::Range(3,7,false)", Range.make(3, 7,false))

    compile(
     """class Tester
        {
          Str t00() { Foo("a").toStr }
          Str t01() { Foo("a", "b").toStr }
          Str t02() { Foo(9).toStr }
          Str t03() { M("x").toStr }
          Str t04() { M("x", "y").toStr }
        }
        class Foo : M
        {
          new make1(Str x) { toStr = x }
          new make2(Str x, Str y) { toStr = x + "," + y }
          static new make3(Int x)  { make1("Int " + x) }
          const override Str toStr
        }
        mixin M
        {
          static new make1(Str x) { Foo(x) }
          static new make2(Str x, Str y) { Foo(x, y) }
        }
        """)

    obj := pod.types.first.make
    verifyEq(obj->t00, "a")
    verifyEq(obj->t01, "a,b")
    verifyEq(obj->t02, "Int 9")
    verifyEq(obj->t03, "x")
    verifyEq(obj->t04, "x,y")


    // ResolveExpr errors
    verifyErrors(
     """class Tester
        {
          Obj t00() { Foo("a") }
          Obj t01() { Foo("a", true) }
          Obj t02() { Foo("a", 3) }
          Obj t03() { Foo("a", true, 3) } // ok
          Obj t04() { Foo() }
          Obj t05() { Foo(4f) }
        }
        class Foo
        {
          new make1(Str x) {}
          new make2(Str x, Bool y := true) {}
          static new make3(Str x, Bool y, Int z := 3) {}
          private new make4(Str x) {}
        }
        """,
      [ 3, 15, "Ambiguous constructor: Foo(sys::Str) [make1, make2]",
        4, 15, "Ambiguous constructor: Foo(sys::Str, sys::Bool) [make2, make3]",
        5, 15, "No constructor found: Foo(sys::Str, sys::Int)",
        7, 15, "No constructor found: Foo()",
        8, 15, "No constructor found: Foo(sys::Float)",
      ])
  }

//////////////////////////////////////////////////////////////////////////
// Call Operator
//////////////////////////////////////////////////////////////////////////

  Void testCallOperator()
  {
    compile(
       "class Foo
        {
          Func funcField := Foo#.method(\"m4\").func

          static Int nine() { return 9 }
          static Func nineFunc() {  return Foo#.method(\"nine\").func }

          static Int m1(Int a) { return a }
          static Int m4(Int a, Int b, Int c, Int d) { return d }
          static Int m8(Int a, Int b, Int c, Int d, Int e, Int f, Int g, Int h) { return h }

          Int i1(Int a) { return a }
          Int i4(Int a, Int b, Int c, Int d) { return d }
          Int i7(Int a, Int b, Int c, Int d, Int e, Int f, Int g) { return g }

          static Int callClosure(|->Int| c) { return c() }

          static Obj a()
          {
            m := Foo#.method(\"nine\").func
            return m()
          }

          static Obj b()
          {
            m := |->Int| { return 69 }
            return m()
          }

          static Obj c(Int a, Int b)
          {
            m := |Int x, Int y->Int| { return x + y }
            return m(a, b)
          }

          static Obj d() { return Foo#.method(\"nine\").func()() }

          static Obj e() { return ((Func)Foo#.method(\"nineFunc\").func()())() }

          static Int f()
          {
            m := (|-> |->Int| |)Foo#.method(\"nineFunc\").func
            return m()()
          }

          static Obj g() { return Foo#.method(\"m1\").func()(7) }
          static Obj h() { return Foo#.method(\"m4\").func()(10, 11, 12, 13) }
          static Obj i() { return Foo#.method(\"m8\").func()(1, 2, 3, 4, 5, 6, 7, 8) }

          Obj j() { return Foo#.method(\"i1\").func()(this, 6) }
          Obj k() { return Foo#.method(\"i4\").func()(this, 101, 111, 121, 131) }
          Obj l() { return Foo#.method(\"i7\").func()(this, -1, -2, -3, -4, -5, -6, -7) }

          Int m(Int p)
          {
            list := [ (|Int a->Int|) Type.of(this).method(\"m1\").func() ]
            return list[0](p)
          }

          Obj o(Int p)
          {
            return (funcField)(0, 1, 2, p)
          }

          Obj q(Int p)
          {
            return Foo#.method(\"callClosure\").func()() |->Int| { return p }
          }
        }")

    // compiler.fpod.dump
    t := pod.types[0]
    obj := t.make
    verifyEq(obj->a, 9)
    verifyEq(obj->b, 69)
    verifyEq(obj->c(10, 3), 13)
    verifyEq(obj->d, 9)
    verifyEq(obj->e, 9)
    verifyEq(obj->f, 9)
    verifyEq(obj->g, 7)
    verifyEq(obj->h, 13)
    verifyEq(obj->i, 8)
    verifyEq(obj->j, 6)
    verifyEq(obj->k, 131)
    verifyEq(obj->l, -7)
    verifyEq(obj->m(54), 54)
    verifyEq(obj->o(33), 33)
    verifyEq(obj->q('x'), 'x')
  }

  Void testCallOperatorErrors()
  {
    // ResolveExpr step
    verifyErrors(
     "class Foo
      {
        static Void a(Str x) { x() }
        static Void b() { Str x; x() }
        static Void c() { x := 44; x() }
        static Void d()
        {
          //m := |Int a, Int b, Int c, Int d, Int e, Int f, Int g, Int h, Int j| {}
          //m(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
        }

        static Void m9(Int a, Int b, Int c, Int d, Int e, Int f, Int g, Int h, Int j) {}
      }",
      [
        3, 26, "Cannot use () call operator on non-func type 'sys::Str'",
        4, 28, "Cannot use () call operator on non-func type 'sys::Str'",
        5, 30, "Cannot use () call operator on non-func type 'sys::Int'",
        //9,  5, "Tough luck - cannot use () operator with more than 8 arguments, use call(List)",
      ])

    // CheckErrors step
    verifyErrors(
      "class Foo
       {
         Int call(Int a, Int b) { a + b }
         Void test1(Foo f) { f(2, 3) }
         Void test2(Foo f) { this(2, 3) }
         Void test3()      { Foo()(2, 3) }
       }
       ",
       [ 4, 23, "Cannot use () call operator on non-func type '$podName::Foo'",
         5, 23, "Cannot use () call operator on non-func type '$podName::Foo'",
         6, 23, "Cannot use () call operator on non-func type '$podName::Foo'"])
  }

//////////////////////////////////////////////////////////////////////////
// Errors
//////////////////////////////////////////////////////////////////////////

  Void testErrors()
  {
    // errors
    verifyErrors(
     "class Foo
      {
        static Obj a() { return foobar }
        static Obj b() { return 3.foobar }
        static Obj c() { return 3.noway() }
        static Obj d() { return 3.nope(3) }
        static Obj e() { return sys::Str.foo }
        static Obj f() { return sys::Str.foo() }
        static Obj g(Int x) { x := 3 }
        static Obj h(Int y) { Int y; }
        static Obj i() { z := 3; z := 5 }
        static Obj j() { return foobar.x }
        static Obj k() { return 8f.foobar().x.y }
        static Obj l() { return foo + bar }
        static Obj m() { return (4.foo.ouch + bar().boo).rightOn }
        static Obj n(Str x) { return x++ }
        static Obj o(Str x) { return --x }
        static Obj q(Str x) { return x / 3 }
        static Obj r(Str x) { return x -= 3 }
        static Obj s(Str x) { return x?.foo }
        static Obj t(Str x) { return x?.foo() }
        static Obj u() { return Str#bad }
        static Obj v() { return #bad }
      }",
      [ 3, 27, "Unknown variable 'foobar'",
        4, 29, "Unknown slot 'sys::Int.foobar'",
        5, 29, "Unknown method 'sys::Int.noway'",
        6, 29, "Unknown method 'sys::Int.nope'",
        7, 36, "Unknown slot 'sys::Str.foo'",
        8, 36, "Unknown method 'sys::Str.foo'",
        9, 25, "Variable 'x' is already defined in current block",
       10, 25, "Variable 'y' is already defined in current block",
       11, 28, "Variable 'z' is already defined in current block",
       12, 27, "Unknown variable 'foobar'",
       13, 30, "Unknown method 'sys::Float.foobar'",
       14, 27, "Unknown variable 'foo'",
       14, 33, "Unknown variable 'bar'",
       15, 30, "Unknown slot 'sys::Int.foo'",
       15, 41, "Unknown method '$podName::Foo.bar'",
       16, 32, "Unknown method 'sys::Str.increment'",
       17, 32, "Unknown method 'sys::Str.decrement'",
       18, 32, "No operator method found: sys::Str / sys::Int",
       19, 32, "No operator method found: sys::Str - sys::Int",
       20, 35, "Unknown slot 'sys::Str.foo'",
       21, 35, "Unknown method 'sys::Str.foo'",
       22, 27, "Unknown slot literal 'sys::Str.bad'",
       23, 27, "Unknown slot literal '$podName::Foo.bad'",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  const static Str xNull := "_null_"

  Void verifyExpr(Str code, Obj? result, Obj? a := null, Obj? b := null, Str more := "", Bool nullable := false)
  {
    params := ""
    if (a != null) params = Type.of(a).signature + (nullable ? "?" :"") + " a"
    if (b != null) params += ", " + Type.of(b).signature + (nullable ? "?" :"") + " b"

    src :=
     "class Foo
      {
        new make() { return }

        Str ifoo() { return \"ifoo\" }
        static Str sfoo() { return \"sfoo\" }

        Obj? func($params) { $more return $code }

        Int f
        const static Int sf := 1972
      }"
     //echo(src)
     compile(src)
     // compiler.fpod.dump

     aarg := a == xNull ? null : a
     barg := b == xNull ? null : b

     t := pod.types.first
     instance := t.method("make").call
     actual := t.method("func").callList([instance, aarg, barg])
     verifyEq(actual, result)
   }

}