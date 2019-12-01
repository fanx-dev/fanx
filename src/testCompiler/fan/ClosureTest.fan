//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2 Oct 06  Brian Frank  Creation
//

using compiler
using concurrent

**
** ClosureTest
**
class ClosureTest : CompilerTest
{

//////////////////////////////////////////////////////////////////////////
// InitClosures
//////////////////////////////////////////////////////////////////////////

  Void testInitClosures()
  {
    compile(
     "class Foo
      {
        static Void x()
        {
          at := |->| {}
          bt := |Int x, Str y->Str| { return \"x\" }
          //ct := |Int a, Int b, Int c, Int d, Int e, Int f, Int g, Int h, Int j| {}
        }
      }")

     a := compiler.types[1]
     b := compiler.types[2]
     //c := compiler.types[3]

     // compiler.pod.dump

     verifyEq(a.name, "Foo\$x\$0")
     verifyEq(a.slotDef("make")->isCtor, true)
     verifyEq(a.slotDef("call")->code->size, 2)
     verifyEq(a.slotDef("call")->code->stmts->get(0)->expr->method->name, "doCall")
     verifyEq(a.slotDef("call")->code->stmts->get(1)->expr->id, ExprId.nullLiteral)

     verifyEq(b.name, "Foo\$x\$1")
     verifyEq(b.slotDef("call")->code->size, 1)
     call := b.slotDef("call")->code->stmts->get(0)->expr as CallExpr
     verifyEq(call.method.name, "doCall")
     verifyEq(call.args[0].id, ExprId.coerce)
     verifyEq(call.args[0]->check->qname, "sys::Int")
     verifyEq(call.args[1].id, ExprId.coerce)
     verifyEq(call.args[1]->check->qname, "sys::Str")

    /*
     verifyEq(c.name, "Foo\$x\$2")
     verifyEq(c.slotDef("callList")->params->get(0)->paramType->qname, "sys::List")
     call = c.slotDef("callList")->code->stmts->get(0)->expr as CallExpr
     verifyEq(call.args[0].id, ExprId.coerce)
     verifyEq(call.args[0]->check->qname, "sys::Int")
     verifyEq(call.args[0]->target->method->qname, "sys::List.get")
     verifyEq(call.args[8].id, ExprId.coerce)
     verifyEq(call.args[8]->check->qname, "sys::Int")
     verifyEq(call.args[8]->target->method->qname, "sys::List.get")
     */
  }

//////////////////////////////////////////////////////////////////////////
// Outer This
//////////////////////////////////////////////////////////////////////////

  Void testOuterThis()
  {
    compile(
     "class Foo
      {
        Int x() { return 1972 }
        Int xc1() { return |->Int| { return x }.call }
        Int xc2() { return |->Int| { return this.x }.call }

        static Int y() { return 72 }
        Int yc1() { return |->Int| { return y }.call }
        Int yc2() { return |->Int| { return Foo.y }.call }

        Int f := 66
        Int fc1() { return |->Int| { return f }.call }
        Int fc2() { return |->Int| { return this.f }.call }
      }")

     t := pod.types[0]
     obj := t.make
     verifyEq(t.method("xc1").callList([obj]), 1972)
     verifyEq(t.method("xc2").callList([obj]), 1972)
     verifyEq(t.method("yc1").callList([obj]), 72)
     verifyEq(t.method("yc2").callList([obj]), 72)
     verifyEq(t.method("fc1").callList([obj]), 66)
     verifyEq(t.method("fc2").callList([obj]), 66)
  }

  Void testOuterThisErrors()
  {
    verifyErrors(
     "class Base
      {
        virtual Int x() { return 3 }
      }

      class Foo : Base
      {
        override Int x() { return 4 }
        static Int  a() { return |->Int| { return this.x }.call }
        static Void b() { |->| { |->| { this.x } }.call }
        Int  c() { return |->Int| { return super.x }.call }
        Void d() { |->| { |->| { super.x } }.call }
      }
      ",
       [
          9, 45, "Cannot access 'this' within closure of static context",
         10, 35, "Cannot access 'this' within closure of static context",
         11, 38, "Invalid use of 'super' within closure",
         12, 28, "Invalid use of 'super' within closure",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Cvars
//////////////////////////////////////////////////////////////////////////

  Void testCvars()
  {
    compile(
     "class Foo
      {
        static Int f()
        {
          Int x := 7
          Int echo := 10
          3.times |Int i| {}
          return |->Int| { return x+echo }.call
        }
      }")

     // verify code works correctly
     t  := pod.types[0]
     obj := t.make
     verifyEq(t.method("f").callList([obj]), 17)

     // verify first closure doesn't have cvars overhead
     c0 := compiler.types[1]
     verifyEq(c0.name, "Foo\$f\$0")
     verifyEq(c0.method("make").params.size, 0)
     verifyNull(c0.field("x\$0"))

     // verify second closure has cvars overhead
     c1 := compiler.types[2]
     verifyEq(c1.name, "Foo\$f\$1")
     verifyEq(c1.method("make").params.size, 2)
     verifyNotNull(c1.field("x\$0"))
   }

  Void testCvarsStaticInit()
  {
    // 1) test the multiple static initializers work ok
    // 2) test cvars with two different scopes for 'x'
    compile(
     "class Foo
      {
        const static Int f
        static
        {
          Int x := 0
          3.times
          {
            2.times { x++ }
          }
          f = |->Int| { return x }.call
        }

        const static Str g
        static
        {
          Str x := \"\";
          [0ms, 1ms, 2ms].each|Duration d|
          {
            x += d.toStr
          }
          g = x
        }
      }")

     t  := pod.types[0]
     verifyEq(t.field("f").get, 6)
     verifyEq(t.field("g").get, "0ms1ms2ms")
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  Void testField1()
  {
    compile(
     "using concurrent
      class Foo
      {
        |->| c1 := |->| { s=\"c1\" };
        |Str x| c2 := |Str x| { s=x };
        |Str x| c3 := |Str x| { sets(x) };
        |Str x| c4 := |Str x| { this.sets(x) };
        static const |->| sc1 := |->| { Actor.locals[\"testCompiler.closure\"] = \"sc1\" }
        static const |Str x| sc2 := |Str x| { Actor.locals[\"testCompiler.closure\"] = x }
        Void sets(Str x) { s = x }
        Str? s
      }")

    // compiler.fpod.dump
    t  := pod.types[0]
    obj := t.make
    obj->c1->call()
    verifyEq(obj->s, "c1")
    obj->c2->call("c2")
    verifyEq(obj->s, "c2")
    obj->c3->call("c3")
    verifyEq(obj->s, "c3")
    obj->c4->call("c4")
    verifyEq(obj->s, "c4")

    verifyEq(Actor.locals["testCompiler.closure"], null)
    ((Func)t.field("sc1").get).call
    verifyEq(Actor.locals["testCompiler.closure"], "sc1")
    ((Func)t.field("sc2").get).call("xxx")
    verifyEq(Actor.locals["testCompiler.closure"], "xxx")
  }

  Void testField2()
  {
    compile(
     "class Foo
      {
        Int f
        {
          get
          {
            x := 2
            return [0,1,2,3].find |Int v->Bool| { return v == x }
          }
          set
          {
            s = \"\"
            it.times |Int i|
            {
              2.times |Int j| { s += \"(\$i,\$j)\" }
            }
          }
        }

        Str? s
      }")

     // compiler.fpod.dump
     t  := pod.types[0]
     obj := t.make
     verifyEq(obj->f, 2)
     verifyEq(obj->s, null)
     obj->f = 0
     verifyEq(obj->s, "")
     obj->f = 1
     verifyEq(obj->s, "(0,0)(0,1)")
     obj->f = 2
     verifyEq(obj->s, "(0,0)(0,1)(1,0)(1,1)")
     obj->f = 3
     verifyEq(obj->s, "(0,0)(0,1)(1,0)(1,1)(2,0)(2,1)")
  }

//////////////////////////////////////////////////////////////////////////
// Combo
//////////////////////////////////////////////////////////////////////////

  Void testCombo()
  {
    compile(
     "class Foo
      {
        Str f(Int a, Int b)
        {
          c := 2
          d := 6; d = 3
          s := \"\"
          3.times |Int i|
          {
            n := next
            s += \"(\$n: \$a \$b \$c \$d)\"
            a++
            d++
          }
          return s
        }

        Int next() { return counter++ }
        Int counter := 0
      }")

     // verify code works correctly
     t  := pod.types[0]
     obj := t.make
     verifyEq(t.method("f").callList([obj, 0, 1]), "(0: 0 1 2 3)(1: 1 1 2 4)(2: 2 1 2 5)")
   }

//////////////////////////////////////////////////////////////////////////
// Nested 1
//////////////////////////////////////////////////////////////////////////

  Void testNested1()
  {
    compile(
     "class Foo
      {
        static Str f(Int a)
        {
          b := 2
          s := \"\"
          2.times |Int c|
          {
            d := c+10
            2.times |Int e|
            {
              s += \"[\$a \$b \$c \$d \$e]\"
              a++
              b*=2
            }
          }
          return s
        }
      }")

     // verify code works correctly
     t  := pod.types[0]
     obj := t.make
     verifyEq(t.method("f").callList([1]),
       "[1 2 0 10 0][2 4 0 10 1][3 8 1 11 0][4 16 1 11 1]")
   }

//////////////////////////////////////////////////////////////////////////
// Nested 2
//////////////////////////////////////////////////////////////////////////

  Void testNested2()
  {
    compile(
     "class Foo
      {
        static Str f(Int a)
        {
          s := \"\"
          b := 2
          c := 3
          2.times |Int i|
          {
            a++
            s += \"i=\$i \"
            2.times |Int j|
            {
              2.times |Int k|
              {
                s += \"[\$a \$b \$i \$j \$k]\"
              }
              b *= 2
            }
            s += \"\\n\"
          }
          d := 4
          return s + \" | \$a \$b \$c \$d\"
        }
      }")

     // verify code works correctly
     t  := pod.types[0]
     obj := t.make
     verifyEq(t.method("f").callList([1]),
       "i=0 [2 2 0 0 0][2 2 0 0 1][2 4 0 1 0][2 4 0 1 1]\n" +
       "i=1 [3 8 1 0 0][3 8 1 0 1][3 16 1 1 0][3 16 1 1 1]\n | 3 32 3 4")
   }

//////////////////////////////////////////////////////////////////////////
// Nested 3
//////////////////////////////////////////////////////////////////////////

  Void testNested3()
  {
    compile(
     "class Foo
      {
        Str? f()
        {
          2.times |Int i|
          {
            2.times |Int j|
            {
              counter++
            }
          }
          return null
        }

        Int counter := 0
      }")

     // verify code works correctly
     t  := pod.types[0]
     obj := t.make
     verifyEq(t.method("f").callList([obj]), null)
     verifyEq(obj->counter, 4)
   }

//////////////////////////////////////////////////////////////////////////
// Special
//////////////////////////////////////////////////////////////////////////

  /* TODO
     // this problem looks to be related to shared cvars, where as currently
     // designed all the Target closures will return "gamma" since that was
     // the last value of $cvars.$name - is this a bug or just poor design?
  Void testFoo()
  {
    compile("
      class Foo
      {
        Target[] list()
        {
          names := [\"alpha\", \"beta\", \"gamma\"]
          return (Target[])names.map(Target[,]) |Str name->Target|
          {
            return Target.make |->Str| { return name }
          }
        }
      }

      class Target
      {
        new make(Method m) { this.m = m }
        Str run() { return (Str)m.call }
        Method m
      }
      ")

     // verify code works correctly
     // compiler.fpod.dump
     t  := pod.types[0]
     list := (List)t.method("list").callOn(t.make, [,])
     verifyEq(list.size, 3)
     verifyEq(list[0]->run, "alpha")
     verifyEq(list[1]->run, "beta")
     verifyEq(list[2]->run, "gamma")
  }
  */

//////////////////////////////////////////////////////////////////////////
// Default Params
//////////////////////////////////////////////////////////////////////////

  Void testDefaultParams()
  {
    compile(
     "class Foo
      {
        Void m0() { s = \"m0\" }
        Void m1(|->| f := |->| { s=\"m1\" }) { f() }
        Void m2(Str x, |Str y| f := |Str y| { s=y }) { f(x) }
        Str? s
      }")

    // compiler.fpod.dump
    t  := pod.types[0]
    obj := t.make
    obj->m0(); verifyEq(obj->s, "m0")
    obj->m1(); verifyEq(obj->s, "m1")
    obj->m2("m2"); verifyEq(obj->s, "m2")
  }

//////////////////////////////////////////////////////////////////////////
// Errors
//////////////////////////////////////////////////////////////////////////

  Void testAlreadyDefined()
  {
    // NOTE: we don't keep location of individual closure parameters
    verifyErrors(
     "class Foo
      {
        Void f(Int a)
        {
          b := 2
          a := true
          b := true;

          3.times |Int a| { return };
          2.times |->| { |Int x, Int b| {} };

          |->| { a := true }.callList;
          |->| { |->| { b := 4 } }.callList;
        }
      }
      ",
       [
         6,  5, "Variable 'a' is already defined in current block",
         7,  5, "Variable 'b' is already defined in current block",
         9, 13, "Closure parameter 'a' is already defined in current block",
        10, 20, "Closure parameter 'b' is already defined in current block",
        12, 12, "Variable 'a' is already defined in current block",
        13, 19, "Variable 'b' is already defined in current block",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Closure in Ctor
//////////////////////////////////////////////////////////////////////////

  Void testInCtor()
  {
    compile(
     "class Foo
      {
        new make() { f := |->| { i = 4 }; f()  }
        const Int i

        static const Int j
        static  { f := |->| { j = 7 }; f()  }
      }")

    // compiler.fpod.dump
    t  := pod.types[0]
    obj := t.make
    verifyEq(obj->i, 4)
    verifyEq(obj->j, 7)
  }

//////////////////////////////////////////////////////////////////////////
// Closure Inference
//////////////////////////////////////////////////////////////////////////

  Void testInference()
  {
    compile(
     "class Foo
      {
        Obj m03(Obj x, Obj y) { s := \"\"; f := |a, b| { s = \"\$a \$b.toStr.size\" }; f(x,y); return s }
        Obj m04(Obj x, Obj y) { f := |a, b->Str| { \"\$a \$b.hash\" }; return f(x, y) }
        Obj m05(Str[] x) { x.sort |a, b->Int| { a.size <=> b.size } }
        Obj m06(Str[] x) { x.sortr |a, b| { a.size <=> b.size } }
        Obj m07(Str[] x) { r := Obj[,]; x.each |s,i| { r.add(s).add(i) }; return r }
        Obj m08(Str[] x) { return x.map |s,i| { i.toStr + s  } }
        Obj m09(Str[] x) { return x.map |s,i->Str| { q := i.toStr; return q + s  } }
        Obj m10(Str[] x)
        {
          return x.sort |a,b|
          {
            if (a == \"first\") return -1
            if (b == \"first\") return +1
            return a <=> b
          }
        }

        Type m11() { foo { 4 } }
        Type m12() { foo |a| { 4 } }
        Type m13() { foo |a,b| { 4 } }
        Type m14() { foo |Int a,b| { 4 } }
        Type m15() { foo |a,Int b| { 4 } }
        Type m16() { foo |a,b->Int| { 4 } }
        Type m17() { foo |Int a,b->Int| { 4 } }
        Type m18() { foo |Int a, Float b->Int| { 4 } }

        Type foo(|Num,Num->Num| f) { Type.of(f) }
       }")

    // compiler.fpod.dump
    t  := pod.types[0]
    obj := t.make
    verifyEq(obj->m03("x", "boo"), "x 3")
    verifyEq(obj->m04("a", "b"), "a " + "b".hash)
    verifyEq(obj->m05(["hello", "x", "foo"]), ["x", "foo", "hello"])
    verifyEq(obj->m06(["hello", "x", "foo"]), ["hello", "foo", "x"])
    verifyEq(obj->m07(["a", "b"]), ["a", 0, "b", 1])
    verifyEq(obj->m08(["a", "b"]), Obj?["0a", "1b"])
    verifyEq(obj->m09(["foo", "bar"]), Str["0foo", "1bar"])
    verifyEq(obj->m10(["bar", "c", "first", "alpha"]), ["first", "alpha", "bar", "c"])
    /*TODO
    verifyEq(obj->m11, |Num->Num|#)
    verifyEq(obj->m12, |Num->Num|#)
    verifyEq(obj->m13, |Num,Num->Num|#)
    verifyEq(obj->m14, |Int,Num->Num|#)
    verifyEq(obj->m15, |Num,Int->Num|#)
    verifyEq(obj->m16, |Num,Num->Int|#)
    verifyEq(obj->m17, |Int,Num->Int|#)
    verifyEq(obj->m18, |Int,Float->Int|#)
    */
  }

  Void testInferenceErrors()
  {
    // check that we don't infer if expected params < inferred params,
    // the errors will indicate uninferred default Obj? params
    verifyErrors(
     "class Foo
      {
        Void m03() { f0 |->| {} }   // ok
        Void m04() { f0 |a| {} }
        Void m05() { f1 |a| {} }   // ok
        Void m06() { f1 |a,b| {} }
        Void m07() { f2 |a,b| {} } // ok
        Void m08() { f2 |a,b,c| {} }
        Void m09() { f2 |a,b,c,d| {} }

        Void f0(|->| f) {}
        Void f1(|Str| f) {}
        Void f2(|Str,Str| f) {}
      }
      ",
      [
        4, 16, "Invalid args f0",
        6, 16, "Invalid args f1",
        8, 16, "Invalid args f2",
        9, 16, "Invalid args f2",
      ])
  }

  Void testMutableClosure()
  {
    compile(
     """class Foo {
        static Str[] list() { ["a", "b"] }
        static Obj test() {
          acc := Str[,]
          list.each |i|
          {
            list.each |j|
            {
              list.each |k|
              {
                i = "(\$i)"
                acc.add("\$i \$j \$k")
              }
              j = "(\$j)"
            }
          }
          return acc
        } }""")

    //compiler.fpod.dump
    o := pod.types.first.make
    r := o->test as List
    verifyEq(r.join(",\n"),
      "(a) a a,
       ((a)) a b,
       (((a))) b a,
       ((((a)))) b b,
       (b) a a,
       ((b)) a b,
       (((b))) b a,
       ((((b)))) b b")
  }
}