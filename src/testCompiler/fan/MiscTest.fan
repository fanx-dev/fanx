//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Sep 06  Brian Frank  Creation
//

using compiler

**
** MiscTest for various steps: DefaultCtor, Normalize, CheckParamDefs
**
class MiscTest : CompilerTest
{

//////////////////////////////////////////////////////////////////////////
// DefaultCtor
//////////////////////////////////////////////////////////////////////////

  Void testDefaultCtor()
  {
    compile(
     "class Foo
      {
        Int x() { return 7 }
      }")
     t := pod.types.first
     mk := t.method("make")
     verifyEq(mk.isCtor, true)
     verifyEq(mk.isPublic, true)
     verifyEq(mk.params.isEmpty, true)
     verifyEq(mk.call->x, 7)

    verifyErrors(
      "class A { Void make() {} }
       class B { Int make }
       class C : Foo { } // ok
       class D { static D make() { return null } private new privateMake() { return } }
       class E : D {}
       class Foo { new make(Int x := 0) {} }
       ",
       [1, 1, "Default constructor 'make' conflicts with slot at Script(1,11)",
        2, 1, "Default constructor 'make' conflicts with slot at Script(2,11)",
        //5, 1, "Default constructor 'make' conflicts with inherited slot '$podName::D.make'",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Normalize
//////////////////////////////////////////////////////////////////////////
  /*
  Void testNormalize()
  {
    compile(
     "class Foo
      {
        new makeItBaby() {}
        Void x() {}
        static Void y(Int v) {}

        Int i := 6
        Int j := 7

        static { y(33) }
        const static Int k := 8
        static { y(44) }
      }

      class Bar : Foo
      {
        new make() {}

        Int g
      }")
     t := compiler.types.first

     // implicit return
     x := t.slotDef("x")->code as Block
     verifyEq(x.size, 1)
     verifyEq(x.stmts[0].id, StmtId.returnStmt)

     // instance$init
     iInit := t.slotDef("instance\$init\$$t.pod.name\$$t.name")->code as Block
     verifyEq(iInit.size, 3)
     verifyEq(iInit.stmts[0]->expr->id, ExprId.assign)
     verifyEq(iInit.stmts[0]->expr->lhs->name, "i")
     verifyEq(iInit.stmts[0]->expr->rhs->val, 6)
     verifyEq(iInit.stmts[1]->expr->id, ExprId.assign)
     verifyEq(iInit.stmts[1]->expr->lhs->name, "j")
     verifyEq(iInit.stmts[1]->expr->rhs->val, 7)
     verifyEq(iInit.stmts[2].id, StmtId.returnStmt)

     // static$init (each one broken up into if (true) stmt)
     sInit := t.slotDef("static\$init")->code as Block
     verifyEq(sInit.size, 4)
     verifyEq(sInit.stmts[0]->trueBlock->stmts->first->expr->id, ExprId.call)
     verifyEq(sInit.stmts[0]->trueBlock->stmts->first->expr->args->get(0)->val, 33)
     verifyEq(sInit.stmts[1]->expr->id, ExprId.assign)
     verifyEq(sInit.stmts[1]->expr->lhs->name, "k")
     verifyEq(sInit.stmts[1]->expr->rhs->val, 8)
     verifyEq(sInit.stmts[2]->trueBlock->stmts->first->expr->id, ExprId.call)
     verifyEq(sInit.stmts[2]->trueBlock->stmts->first->expr->args->get(0)->val, 44)
     verifyEq(sInit.stmts[3].id, StmtId.returnStmt)

     // super ctor
     bar := compiler.types[1]
     ctor := bar.slotDef("make") as MethodDef
     verifyEq(ctor.ctorChain.target.id, ExprId.superExpr)
     verifyEq(ctor.ctorChain.method.parent.name, "Foo")
     verifyEq(ctor.ctorChain.method.name, "makeItBaby")

     // g field getter
     g := bar.slot("g") as FieldDef
     verify(bar.slotDefs.find |SlotDef s->Bool| { return s === g.get } != null)
     verifyEq(g.get.name, "g")
     verifyEq(g.get.returnType.qname, "sys::Int")
     verifyEq(g.get.params.size, 0)
     verifyEq(g.get.code.stmts.size, 1)
     verifyEq(g.get.code.stmts[0].id, StmtId.returnStmt)
     verifyEq(g.get.code.stmts[0]->expr->id, ExprId.field)
     verifyEq(g.get.code.stmts[0]->expr->name, "g")

     // g field setter
     verify(bar.slotDefs.find |SlotDef s->Bool| { return s === g.set } != null)
     verifyEq(g.set.name, "g")
     verifyEq(g.set.returnType.qname, "sys::Void")
     verifyEq(g.set.params.size, 1)
     verifyEq(g.set.params[0].paramType.qname, "sys::Int")
     verifyEq(g.set.params[0].name, "it")
     verifyEq(g.set.code.stmts.size, 2)
     verifyEq(g.set.code.stmts[0].id, StmtId.expr)
     verifyEq(g.set.code.stmts[0]->expr->id, ExprId.assign)
     verifyEq(g.set.code.stmts[0]->expr->lhs->id, ExprId.field)
     verifyEq(g.set.code.stmts[0]->expr->lhs->name, "g")
     verifyEq(g.set.code.stmts[1].id, StmtId.returnStmt)
  }
  */
//////////////////////////////////////////////////////////////////////////
// Static Init Scoping
//////////////////////////////////////////////////////////////////////////

  Void testStaticInitScoping()
  {
    // verify two static init blocks with same local
    // are given different scopes
    compile(
       "class Foo
        {
          const static Int i
          static
          {
            x := 3
            i = x
          }

          const static Str s
          static
          {
            x := \"hello\"
            s = x
          }
        }")

    t := pod.types[0]
    verifyEq(t.field("i").get, 3)
    verifyEq(t.field("s").get, "hello")
  }

//////////////////////////////////////////////////////////////////////////
// Field Type Inference
//////////////////////////////////////////////////////////////////////////

  Void testFieldTypeInference()
  {
   verifyErrors(
     "class Foo
      {
        Void something() { a.ouch() }
        a := false
        b := 0
        c := \"hello\"
        d := d+1
        e := d { get { return d } }
      }",
      [
        4, 3, "Type inference not supported for fields",
        5, 3, "Type inference not supported for fields",
        6, 3, "Type inference not supported for fields",
        7, 3, "Type inference not supported for fields",
        8, 3, "Type inference not supported for fields",
      ])
  }

//////////////////////////////////////////////////////////////////////////
// CheckParamDefs
//////////////////////////////////////////////////////////////////////////

  Void testCheckParamDefs()
  {
    compile(
     "class Foo
      {
        Void f(Int a := 0, Int b := a+1, Int c := a+2, Int d := -c) {}
      }")
     t := compiler.types.first
     f := t.slot("f") as MethodDef
     verifyEq(f.paramDefs[0].def.id, ExprId.assign)    // save to local, used by b, c
     verifyEq(f.paramDefs[1].def.id, ExprId.shortcut)  // not saved to local
     verifyEq(f.paramDefs[2].def.id, ExprId.assign)    // save to local, used by d
     verifyEq(f.paramDefs[3].def.id, ExprId.shortcut)  // not saved to local

   verifyErrors(
     "class Foo
      {
        Void a(Str a := 6)    {}
        Void b(Int a := 6f, Num b := \"f\") {}
        Void c(Str? a := null) {}  // ok
        Void d(Num a := 7)    {}  // ok
      }",
      [
        3, 19, "'sys::Int' is not assignable to 'sys::Str'",
        4, 19, "'sys::Float' is not assignable to 'sys::Int'",
        4, 32, "'sys::Str' is not assignable to 'sys::Num'",
      ])
  }

//////////////////////////////////////////////////////////////////////////
// Generic with Generic Params
//////////////////////////////////////////////////////////////////////////

  Void testGenericWithGenericParams()
  {
    compile(
     "class Foo : Test
      {
        static Str x(Int[] a, Int:Str b, |Int x| c) { return a.toStr }
        Obj testIt() { Type.of(this).method(\"x\").call([1, 2, 3], [4:4.toStr], |Int x| {}) }
      }")

     t := pod.types.first
     verifyEq(t.method("testIt").callOn(t.make, [,]), "[1, 2, 3]")
  }

//////////////////////////////////////////////////////////////////////////
// IsConst
//////////////////////////////////////////////////////////////////////////

  Void testIsConst()
  {
    compile(
     "class Foo
      {
        // fields
        Int f00
        const Int f01 := 1
        const static Int f02 := 2

        // methods
        Void m00() {}
        Int? m01(List? list) { return null }
        static Void m02(Obj x) {}
        static Str[]? m03(Int a, Int b) { return null }

        // closures
        static Func c00() { return |->| {} }
        Func c01() { return |->Int| { a := 3; return a; } }
        Func c02() { return |->Obj| { return m01(null) } }
        static Func c03() { a := 3; return |->Obj| { return a } }
        static Func c04() { a := 3; m := |->Func| { return |->Obj| { return ++a } }; return m() }
        Func c05() { a := 3; m := |->Func| { return |->Obj| { return this } }; return m() }
        Func c06() { list := [0,1]; return |->Obj| { return m01(list) } }
      }")

     // compiler.fpod.dump
     t := pod.types.first
     obj := t.make

     // defined fields
     verify(!t.field("f00").isConst)
     verify(t.field("f01").isConst)
     verify(t.field("f02").isConst)

     // defined methods
     verify(!t.method("m00").isConst)
     verify(!t.method("m01").isConst)
     verify(t.method("m02").isConst)
     verify(t.method("m03").isConst)

     // closures
     verifyEq(obj->c00()->isImmutable, true)
     verifyEq(obj->c01()->isImmutable, true)
     verifyEq(obj->c02()->isImmutable, false)
     verifyEq(obj->c03()->isImmutable, true)
     verifyEq(obj->c04()->isImmutable, false)
     verifyEq(obj->c05()->isImmutable, false)
     verifyEq(obj->c06()->isImmutable, false)
  }

//////////////////////////////////////////////////////////////////////////
// Indexed Assign
//////////////////////////////////////////////////////////////////////////

  Void testIndexedAssign()
  {
    compile(
     "class Foo
      {
        static Void baz(Int[] x) { x[0] += 3 }
        static Int wow(Int[] x) { return ++x[0] }
        static Int wee(Int[] x) { return x[0]++ }

        Int[] f := [99, 2]
        Void fbaz() { f[1] += 3 }
        Int fwow() { return ++f[1] }
        Int fwee() { return f[1]++ }
      }")

    // compiler.fpod.dump
    t := pod.types.first

    x := [2]
    verifyEq(x[0], 2)
    t.method("baz").call(x)
    verifyEq(x[0], 5)
    verifyEq(t.method("wow").call(x), 6)
    verifyEq(x[0], 6)
    verifyEq(t.method("wee").call(x), 6)
    verifyEq(x[0], 7)

    o := t.make
    verifyEq(o->f, [99, 2])
    o->fbaz()
    verifyEq(o->f, [99, 5])
    verifyEq(o->fwow, 6)
    verifyEq(o->f, [99, 6])
    verifyEq(o->fwee, 6)
    verifyEq(o->f, [99, 7])

    verifyErrors(
      "class Foo
       {
         @Operator Str get(Str s) { return s}
         Void bar(Str s) { this[s] += s }
       }
       ",
       [4, 25, "No matching 'set' method for '$podName::Foo.get'",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Auto-Cast
//////////////////////////////////////////////////////////////////////////

  Void testAutoCast()
  {
    compile(
     "class Foo
      {
        Str a() { Str x := this->toStr; return x }
        Str b() { return thru(x(\"B\")) }
        Int c() { return x(7) }
        Int d() { f := |Int x->Int| { return x }; return f(x(9)) }
        Int e() { return x(true) ? 2 : 3 }
        Int f() { if (x(false)) return 2; else return 3 }
        Int g() { throw x(ArgErr.make) }
        Int[] h() { acc := Int [,]; for (i:=0; x(i<3); ++i) acc.add(i); return acc }
        Int[] i() { acc := Int [,]; while (x(acc.size < 4)) acc.add(acc.size); return acc }
        Bool j(Bool a) { return !x(a) }
        Bool k(Bool a, Bool b) { return x(a) && x(b) }
        Int l(Num a) { return a }
        Int m(Num a) { Int i := a; return i }
        Int n(Num a) { return thrui(a) }
        Int[] o(Obj[] a) { return a }

        Str thru(Str x) { return x }
        Int thrui(Int x) { return x }
        Obj x(Obj x) { return x }
        override Str toStr() { return \"Foo!\" }
      }")

    // compiler.fpod.dump
    t := pod.types.first
    o := t.make
    verifyEq(o->a, "Foo!")
    verifyEq(o->b, "B")
    verifyEq(o->c, 7)
    verifyEq(o->d, 9)
    verifyEq(o->e, 2)
    verifyEq(o->f, 3)
    verifyErr(ArgErr#) { o->g }
    verifyEq(o->h, [0, 1, 2])
    verifyEq(o->i, [0, 1, 2, 3])
    verifyEq(o->j(true), false)
    verifyEq(o->j(false), true)
    verifyEq(o->k(false, false), false)
    verifyEq(o->k(false, true), false)
    verifyEq(o->k(true, true), true)
    verifyEq(o->l(6), 6)
    verifyEq(o->m(7), 7)
    verifyEq(o->n(8), 8)
    verifyEq(o->o([1,2,3]), [1,2,3])
  }

//////////////////////////////////////////////////////////////////////////
// Special Errors
//////////////////////////////////////////////////////////////////////////

  Void testSpecialErrors()
  {
    verifyErrors("class Foo { Void x() { Bar b := Bar.make } }",
       [ 1, 24, "Unknown type 'Bar' for local declaration"])

    verifyErrors("class Foo { Void x() { Bar b = dkdkdkd } }",
       [ 1, 24, "Unknown type 'Bar' for local declaration"])

    verifyErrors("class Foo { Void x() { Bar b } }",
       [ 1, 24, "Expected expression statement"])
  }

//////////////////////////////////////////////////////////////////////////
// ParamDefReflect
//////////////////////////////////////////////////////////////////////////

  Void testParamDef()
  {
    compile(
     """class Foo
        {
          static Bool someB() { true }
          static Int someI() { 7 }
          static Float someF() { 3f }

          Str iS() { "!" }
          Bool iB() { false }
          Int iI() { 17 }
          Float iF() { 13f }

          static Void s1(Str a := "def-a") {}
          static Void s2(Str a := "def-a", Str b := "def-b") {}
          static Void s3(Str[] list := ["1", "2", "3"]) {}
          static Void s4(Int[] list := [1, 2, 3]) {}
          static Void s5(Date x := Date.today) {}
          static Void s6(Int x := Date.today.year) {}

          static Void sb1(Bool  a := !someB) {}
          static Void sb2(Bool? a := someB) {}
          static Void sb3(Obj   a := !someB) {}
          static Void sb4(Obj?  a := someB) {}

          static Void si1(Int  a := 3 + someI) {}
          static Void si2(Int? a := 4 + someI) {}
          static Void si3(Obj  a := 5 + someI) {}
          static Void si4(Obj? a := 6 + someI) {}

          static Void sf1(Float  a := 3f + someF) {}
          static Void sf2(Float? a := 4f + someF) {}
          static Void sf3(Obj    a := 5f + someF) {}
          static Void sf4(Obj?   a := 6f + someF) {}

          Void i1(Str a := "def-a") {}
          Void i2(Str a := "def-a", Str b := "def-b") {}
          Void i3(Str a := iS) {}
          Void i4(Bool a := !iB) {}
          Void i5(Int a := iI + 3) {}
          Void i6(Float a := iF + 3f) {}

          new make() {}
          new m1(Str a := "hi!") {}

          Void b1(Int a := 99, Int b := a+1, Int c := b+2) {}
          new b2(Str x := this.toStr) {}
        }"""
    )

    t := pod.types.first
    instance := t.make
    verifyParamDef(instance, "s1", "a", "def-a")
    verifyParamDef(instance, "s2", "a", "def-a"); verifyParamDef(instance, "s2", "b", "def-b")
    verifyParamDef(instance, "s3", "list", ["1", "2", "3"])
    verifyParamDef(instance, "s4", "list", [1, 2, 3])
    verifyParamDef(instance, "s5", "x", Date.today)
    verifyParamDef(instance, "s6", "x", Date.today.year)

    verifyParamDef(instance, "sb1", "a", false)
    verifyParamDef(instance, "sb2", "a", true)
    verifyParamDef(instance, "sb3", "a", false)
    verifyParamDef(instance, "sb4", "a", true)

    verifyParamDef(instance, "si1", "a", 10)
    verifyParamDef(instance, "si2", "a", 11)
    verifyParamDef(instance, "si3", "a", 12)
    verifyParamDef(instance, "si4", "a", 13)

    verifyParamDef(instance, "sf1", "a", 6f)
    verifyParamDef(instance, "sf2", "a", 7f)
    verifyParamDef(instance, "sf3", "a", 8f)
    verifyParamDef(instance, "sf4", "a", 9f)

    verifyParamDef(instance, "i1", "a", "def-a")
    verifyParamDef(instance, "i2", "a", "def-a"); verifyParamDef(instance, "i2", "b", "def-b")
    verifyParamDef(instance, "i3", "a", "!")
    verifyParamDef(instance, "i4", "a", true)
    verifyParamDef(instance, "i5", "a", 20)
    verifyParamDef(instance, "i6", "a", 16f)

    verifyParamDef(instance, "m1", "a", "hi!")

    verifyParamDefErr(instance, "b1", "a")
    verifyParamDefErr(instance, "b1", "b")
    verifyParamDefErr(instance, "b1", "c")

    verifyParamDefErr(instance, "b2", "x")
  }

  Void verifyParamDef(Obj instance, Str methodName, Str paramName, Obj? expected)
  {
    m := instance.typeof.method(methodName)
    p := m.params.find { it.name == paramName }
    v := m.paramDef(p, instance)
    verifyEq(v, expected)
    if (m.isStatic || m.isCtor) verifyEq(m.paramDef(p), expected)
  }

  Void verifyParamDefErr(Obj instance, Str methodName, Str paramName)
  {
    Err? err
    try
      verifyParamDef(instance, methodName, paramName, null)
    catch (Err e)
      err = e
    verifyNotNull(err)
    verifyEq(err.msg, "Method param may not be reflected")
  }

//////////////////////////////////////////////////////////////////////////
// DefDoc
//////////////////////////////////////////////////////////////////////////

  Void testDefDoc()
  {
    pn := podName

    compile(
     "class Foo
      {
        Void a(Str? x := null) { }
        Void b(Int[] y := Int[,] , Str z := \"hi\\n\") {}
        Void c(Int x := 7, Int y := x-x , Int z := - y) {}
        Void d(Str? x := mi(), Str? y := ms(5)) {}

        Str? mi() { return null }
        static Str? ms(Int i) { return null }
      }"
    )

    t := compiler.pod.types.first
    verifyEq(t.method("a").params[0]->def->toDocStr, "null")
    verifyEq(t.method("b").params[0]->def->toDocStr, "Int[,]")
    verifyEq(t.method("b").params[1]->def->toDocStr, "\"hi\\n\"")
    verifyEq(t.method("c").params[0]->def->toDocStr, "7")
    verifyEq(t.method("c").params[1]->def->toDocStr, "x - x")
    verifyEq(t.method("c").params[2]->def->toDocStr, "-y")
    verifyEq(t.method("d").params[0]->def->toDocStr, "this.mi()")
    verifyEq(t.method("d").params[1]->def->toDocStr, "Foo.ms(5)")
  }

//////////////////////////////////////////////////////////////////////////
// Once
//////////////////////////////////////////////////////////////////////////

  Void testOnce()
  {
    compile(
     "class A
      {
        virtual once DateTime x() { return DateTime.now(null) }
        once DateTime bad() { throw Err.make }
      }

      class B : A
      {
        override DateTime x() { return DateTime.now(null) }
      }
      ")

     a := pod.type("A").make
     b := pod.type("B").make
     verifySame(a->x, a->x)
     verifyNotSame(b->x, b->x)
     verifyErr(Err#) { a->bad }
     verifyErr(Err#) { a->bad }
     verifyErr(Err#) { a->bad }

    verifyErrors(
      "class Foo
       {
         once Void x() {}
         once Str y(Str p) { return p }
       }
       ",
       [3, 3, "Once method 'x' cannot return Void",
        4, 3, "Once method 'y' cannot have parameters",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Func Types
//////////////////////////////////////////////////////////////////////////

  Void testFuncTypes()
  {
    compile(
     "class Foo
      {
        Void a(|Int a, Str b| f) {}
        Void b(|Int a, Str| f) {}
        Void c(|Int, Str a| f) {}
        Void d(|Int, Str| f) {}
        Void e(|Duration| f) {}
        Void f(|Duration->Int| f) {}
        Void x() { a |Int x, Str y| { } }
      }")

    t := pod.types.first
    verifyEq(t.method("a").params[0].type, |Int a, Str b|#)
    verifyEq(t.method("b").params[0].type, |Int a, Str b|#)
    verifyEq(t.method("c").params[0].type, |Int a, Str b|#)
    verifyEq(t.method("d").params[0].type, |Int a, Str b|#)
    verifyEq(t.method("e").params[0].type, |Duration|#)
    verifyEq(t.method("f").params[0].type, |Duration->Int|#)
  }

//////////////////////////////////////////////////////////////////////////
// Call Parens
//////////////////////////////////////////////////////////////////////////

  Void testCallParens()
  {
    // we require that calls paren be on the same
    // line to prevent ambiguity
    x := "foo"
    (0..2).each |Int i| { x += "," + i }
    verifyEq(x, "foo,0,1,2")

    x = "foo".size.toStr
    (0..2).each |Int i| { x += "," + i }
    verifyEq(x, "3,0,1,2")
  }

//////////////////////////////////////////////////////////////////////////
// Index Brackets
//////////////////////////////////////////////////////////////////////////

  Void testIndexBrackets()
  {
    // we require that index brackets be on the same
    // line to prevent ambiguity
    x := "foo"
    [0, 1, 2].each |Int i| { x += "," + i }
    verifyEq(x, "foo,0,1,2")

    x = "foo".size.toStr
    [0, 1, 2].each |Int i| { x += "," + i }
    verifyEq(x, "3,0,1,2")
  }

//////////////////////////////////////////////////////////////////////////
// No Leave Pops
//////////////////////////////////////////////////////////////////////////

  Void testNoLeavePops()
  {
    // this is kind of a random regression test
    // for a problem I stubmled across
    compile(
     "class Foo
      {
        Void a(Bool b) { if (b) factory { it.x = 7 } }
        Void b(Bool b, Obj x) { if (b) (Str)x->toHex }
        Int x
        static Foo factory() { return make }
      }")
    //compiler.fpod.dump

    obj := pod.types.first.make
    obj->a(true)     // JVM will throw VerifyError if problem exists
    obj->b(true, 3)  // JVM will throw VerifyError if problem exists
  }

//////////////////////////////////////////////////////////////////////////
// Implicit ToImmutable
//////////////////////////////////////////////////////////////////////////

  Void testImplicitToImmutable()
  {
    compile(
     "class Foo
      {
        const Int[]? a
        const Int[]? b := null
        const Int[] c := [2,3]
        const Int[]? d := wrap(null)
        const Int[] e := wrap([4])
        const Int[]? f
        const Int[] g

        const [Int:Str]? h := null
        const [Int:Str]? i := map(null)
        const Int:Str j := map(c)
        const Int:Str k := map(c)

        const Type? l := null
        const Type m := Str#
        const Type? n
        const Type o

        const Buf p := \"abc\".toBuf
        const Buf q := Buf()

        new make(|Foo|? x := null)
        {
          f = wrap(null)
          g = wrap([5,6])
          k = map(g)
          n = thru(null)
          o = thru(Bool#)
          if (x != null) x(this)
        }

        Foo withIt()
        {
          return make
          {
            it.f = Foo.wrap(null)
            it.g = Foo.wrap([5,6])
            it.k = Foo.map(this.g)
            it.n = Foo.thru(null)
            it.o = Foo.thru(Bool#)
          }
        }

        static Int[]? wrap(Int[]? x) { return x }
        static Type? thru(Type? t) { return t }

        static [Int:Str]? map(Int[]? x)
        {
          if (x == null) return null
          m := Int:Str[:]
          x.each |Int i| { m[i] = i.toStr }
          return m
        }

      }")
    // compiler.fpod.dump

    obj := pod.types.first.make
    verifyImplicitToImmutable(obj)
    verifyImplicitToImmutable(obj->withIt)
 }

 Void verifyImplicitToImmutable(Obj obj)
 {
    verifyEq(obj->a, null)
    verifyEq(obj->b, null)
    verifyEq(obj->c, [2,3])
    verifyEq(obj->c->isImmutable, true)
    verifyEq(obj->d, null)
    verifyEq(obj->e, [4])
    verifyEq(obj->e->isImmutable, true)
    verifyEq(obj->f, null)
    verifyEq(obj->g, [5,6])
    verifyEq(obj->g->isImmutable, true)

    verifyEq(obj->h, null)
    verifyEq(obj->i, null)
    verifyEq(obj->j, [2:"2", 3:"3"])
    verifyEq(obj->j->isImmutable, true)
    verifyEq(obj->k, [5:"5", 6:"6"])
    verifyEq(obj->k->isImmutable, true)

    verifyEq(obj->l, null)
    verifyEq(obj->m, Str#)
    verifyEq(obj->n, null)
    verifyEq(obj->o, Bool#)

    verifyEq(obj->p->isImmutable, true)
    verifyEq(obj->q->isImmutable, true)
    verifyEq(obj->p->in->readAllStr, "abc")
    verifyEq(obj->q->size, 0)
  }

//////////////////////////////////////////////////////////////////////////
// Generics
//////////////////////////////////////////////////////////////////////////

  Void testGenericList()
  {
    // problem reported on forum
    compile("class Foo { Bool foo(List x) { return x[0] == 7 } }")
    //compiler.fpod.dump

    obj := pod.types.first.make
    verifyEq(obj->foo(["x"]), false)
    verifyEq(obj->foo([7]), true)
  }
/*
  Void testGenericFields()
  {
    // verify parameterized casts
    compile(
      "class Foo
       {
         Str foo() { x := Int:Str[:]; x.def = \"hi\"; return x.def }
         Int bar() { x := Int:Int[:]; x.def = 5; return x.def.max(3) }
       }")
    obj := pod.types.first.make
    verifyEq(obj->foo, "hi")
    verifyEq(obj->bar, 5)

    // verify type check errors
    verifyErrors(
      "class Foo
       {
         Void foo()
         {
           x := Int:Str[:]
           x.def = 5ms
         }
       }",
       [6, 13, "'std::Duration' is not assignable to 'sys::Str?'",
       ])
  }
*/
//////////////////////////////////////////////////////////////////////////
// NullSafe
//////////////////////////////////////////////////////////////////////////

  Void testSafe()
  {
    compile(
       "class Foo
        {
          Obj? test1() { return f(this)?.i(1) }
          Obj? test2() { return f(this)?.i(null) }
          Obj? test3() { return f(null)?.i(3) }
          Obj? test4() { return f(null)?.i(null) }

          Obj? test5() { return f(this)?.j(5) }
          Obj? test6() { return f(null)?.j(6) }
          Obj? test7() { last = null; f(this)?.j(7); return last }
          Obj? test8() { last = null; f(null)?.j(8); return last }

          Obj? test9()  { q = 9; return f(this)?.q }
          Obj? test10() { q = 10; return f(null)?.q }

          Foo? f(Foo? x) { return x }
          Int? i(Int? x) { return last = x }
          Int j(Int x) { return last = x }
          Int? last
          Int q
        }")

    t := pod.types[0]
    obj := t.make
    verifyEq(obj->test1, 1)
    verifyEq(obj->test2, null)
    verifyEq(obj->test3, null)
    verifyEq(obj->test4, null)
    verifyEq(obj->test5, 5)
    verifyEq(obj->test6, null)
    verifyEq(obj->test7, 7)
    verifyEq(obj->test8, null)
    verifyEq(obj->test9, 9)
    verifyEq(obj->test10, null)
  }

//////////////////////////////////////////////////////////////////////////
// FromStrSubs
//////////////////////////////////////////////////////////////////////////

  Void testFromStrSubs()
  {
    compile(
       "class Foo
        {
          Foo b(Str s) { return Bar(s) }
          Foo? fromStr(Str s) { return null }
        }

        class Bar : Foo
        {
          new make(Str s) { this.s = s}
          Str s
        }
        ")

    t := pod.types[0]
    obj := t.make
    verifyEq(obj->b("boo")->s, "boo")
  }

//////////////////////////////////////////////////////////////////////////
// Inherit Bug Mar 2009
//////////////////////////////////////////////////////////////////////////

  Void testBug0903()
  {
    recPod := podName
    compile(
       "class RecImpl : Rec
        {
          override Str foo() { return \"foo\" }
          override Str baz() { return \"baz 2\" }
        }

        class SubRecImpl : RecImpl, SubRec
        {
          override Str bar() { return \"bar\" }
          override Str baz() { return \"baz 3\" }
        }

        mixin Rec
        {
          abstract Str foo()
          abstract Str baz()
        }

        mixin SubRec : Rec
        {
          abstract Str bar()
          override Str baz() { return \"baz 1\" }
          Str goo() { return \"goo\" }
        }")

    compile("class Derived : $recPod::SubRecImpl {}")

    t := pod.types[0]
    obj := t.make
    verifyEq(obj->foo, "foo")
    verifyEq(obj->bar, "bar")
    verifyEq(obj->baz, "baz 3")
    verifyEq(obj->goo, "goo")
    verifyEq(t.method("foo").parent.name, "RecImpl")
    verifyEq(t.method("bar").parent.name, "SubRecImpl")
    verifyEq(t.method("baz").parent.name, "SubRecImpl")
    verifyEq(t.method("goo").parent.name, "SubRec")
  }

//////////////////////////////////////////////////////////////////////////
// Local Defaults
//////////////////////////////////////////////////////////////////////////

  Void testLocalDefaults()
  {
    compile(
       "class Foo
        {
          Bool   m01() { Bool x; return x }
          Bool?  m02() { Bool? x; return x }
          Int    m03() { Int x; return x }
          Int?   m04() { Int? x; return x }
          Float  m05() { Float x; return x }
          Float? m06() { Float? x; return x }
          Str?   m07() { Str? x; return x }
        }")

    obj := pod.types[0].make
    verifyEq(obj->m01, false)
    verifyEq(obj->m02, null)
    verifyEq(obj->m03, 0)
    verifyEq(obj->m04, null)
    verifyEq(obj->m05, 0f)
    verifyEq(obj->m06, null)
    verifyEq(obj->m07, null)
  }

//////////////////////////////////////////////////////////////////////////
// Str DSL
//////////////////////////////////////////////////////////////////////////

  Void testStrDslErrors()
  {
    // NOTE: matching checks for " and """ literals in ParserTest.testMultiLineStrs
    verifyErrors(
     //123456
      "class Foo
       {
         Str m01() { return Str
           <|
            x
           |>}

         Str m02() { return
       \t\t Str<|
       \t         x|>}

         Str m03() { return
       \t\t Str<|
       \t\t     x|>}

         Str m04() { return  // ok
       \t\t Str<|
       \t\t      x|>}
       }",
       [
          5, 6,  "Leading space in Str DSL must be 6 spaces",
         10, 11, "Leading space in Str DSL must be 2 tabs and 6 spaces",
         14, 8, "Leading space in Str DSL must be 2 tabs and 6 spaces",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Deprecated
//////////////////////////////////////////////////////////////////////////

  Void testDeprecated()
  {
    podName := this.podName
    compile(
     """class Foo
        {
          Obj? m01() { oldf }
          Obj? m02() { oldm }
          Obj? m03() { Old.m }
          Obj? m04() { Old() }

          @Deprecated Obj? oldf
          @Deprecated { msg = "dont use!" } Obj? oldm() { null }
        }

        @Deprecated { msg = "hum bug" }
        class Old
        {
          static Obj? m() { null }
        }
        """)

       doVerifyErrors(
       [
          3, 16,  "Deprecated slot '$podName::Foo.oldf'",
          4, 16,  "Deprecated slot '$podName::Foo.oldm' - dont use!",
          5, 20,  "Deprecated type '$podName::Old' - hum bug",
          6, 16,  "Deprecated type '$podName::Old' - hum bug",
       ], compiler.warns)
  }

}