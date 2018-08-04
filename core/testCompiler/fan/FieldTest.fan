//
// Copyright (c) 2007, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   7 Jan 07  Brian Frank  Creation
//

using compiler

**
** FieldTest tests
**
class FieldTest : CompilerTest
{

//////////////////////////////////////////////////////////////////////////
// Basics
//////////////////////////////////////////////////////////////////////////

  Void testBasics()
  {
    compile(
       "class Foo
        {
          Int geta() { return x }
          Int gets() { return &x }

          Void seta(Int v) { x = v }
          Void sets(Int v) { &x = v }

          Int x := 3
          {
            get { xGets++; return &x }
            set { xSets++; this.&x = it }
          }

          Int xGets := 0
          Int xSets := 0
        }")

    t := pod.types[0]
    obj := t.make
    verifyEq(obj->gets,  3)
    verifyEq(obj->xGets, 0)
    verifyEq(obj->xSets, 0)

    verifyEq(obj->geta,  3)
    verifyEq(obj->xGets, 1)
    verifyEq(obj->xSets, 0)

    obj->sets(55)
    verifyEq(obj->gets,  55)
    verifyEq(obj->xGets, 1)
    verifyEq(obj->xSets, 0)

    obj->seta(66)
    verifyEq(obj->gets,  66)
    verifyEq(obj->xGets, 1)
    verifyEq(obj->xSets, 1)

    obj->x = 77
    verifyEq(obj->gets,  77)
    verifyEq(obj->xGets, 1)
    verifyEq(obj->xSets, 2)
  }

//////////////////////////////////////////////////////////////////////////
// Field Accessor
//////////////////////////////////////////////////////////////////////////

  Void testFieldAccessors()
  {
    compile(
     "class Foo
      {
        Int a := 2
        {
          get { return &a != 2 ? &a : -1 }
          set { aset = it; &a = it }
        }
        Int aset := 0

        Int b := 6
      }

      class Bar
      {
        static Int geta() { return Foo.make.a }
        static Foo seta() { foo := Foo.make; foo.a = 8; return foo }

        static Int getb() { return Foo.make.b }
        static Foo setb() { foo := Foo.make; foo.b = 99; return foo }

        static Int getc()  { return make.&c }
        static Int getca() { return make.c }
        static Bar setc()  { bar := make; bar.&c = 123; return bar }
        static Bar setca() { bar := make; bar.c = 321; return bar }

        Int c := 3
        {
          get { return &c != 3 ? &c : 5 }
          set { &c = it; ctrap = it }
        }
        Int ctrap := 0
      }")

     // verify useAccessor - Foo a
     geta := compiler.types[1].methodDef("geta").code.stmts[0]->expr as FieldExpr
     verifyEq(geta.useAccessor, true)
     seta := compiler.types[1].methodDef("seta").code.stmts[1]->expr->lhs as FieldExpr
     verifyEq(seta.useAccessor, true)

     // verify not useAccessor - Foo a
     getb := compiler.types[1].methodDef("getb").code.stmts[0]->expr as FieldExpr
     verifyEq(getb.useAccessor, false)
     setb := compiler.types[1].methodDef("setb").code.stmts[1]->expr->lhs as FieldExpr
     verifyEq(setb.useAccessor, false)

     // verify working code - Foo.a
     foo := pod.types[0]
     bar := pod.types[1]
     verifyEq(bar.method("geta").call, -1)
     verifyEq(bar.method("seta").call->a, 8)
     verifyEq(bar.method("seta").call->aset, 8)

     // verify working code - Foo.b
     verifyEq(bar.method("getb").call, 6)
     verifyEq(bar.method("setb").call->b, 99)

     // verify working code - Bar.c
     verifyEq(bar.method("getc").call, 3)
     verifyEq(bar.method("getca").call, 5)
     verifyEq(bar.method("setc").call->c, 123)
     verifyEq(bar.method("setc").call->ctrap, 0)
     verifyEq(bar.method("setca").call->c, 321)
     verifyEq(bar.method("setca").call->ctrap, 321)
   }

//////////////////////////////////////////////////////////////////////////
// Mixins
//////////////////////////////////////////////////////////////////////////

  Void testMixin()
  {
    compile(
       "mixin Mixin
        {
          static Int mgeta() { return s }
          //static Int mgets() { return &s } not allowed

          static const Int s := 5
          static const Int? x
          abstract Int a
        }

        class Foo : Mixin
        {
          Int geta() { return a }
          Int gets() { return &a }

          override Int a { get { return s } }
        }")

    m := pod.types[0]
    f := pod.types[1]

    verifyEq(m.name, "Mixin")
    verifyEq(f.name, "Foo")

    verify(m.field("s").isConst)
    verify(m.field("s").isStatic)
    verifyEq(m.field("s").get, 5)
    verifyEq(m.method("mgeta").call, 5)
    //verifyEq(m.method("mgets").call, 5)

    obj := f.make
    verifyEq(f.field("s").get, 5)
    verifyEq(f.field("s").parent, m)
    verifyEq(obj->geta, 5)
    verifyEq(obj->gets, 0)
    verifyEq(f.field("x").get, null)
  }

//////////////////////////////////////////////////////////////////////////
// Storage
//////////////////////////////////////////////////////////////////////////

  Void testStorage()
  {
    compile(
     "class Foo
      {
        // storage
        Int a
        Int b := 99
        Int c { get { return &c } }
        Int d { set { &d = it } }
        Int e { get { return &e } set { &e = it } }
        Int f { get { return 2 } }
        Int g { set { } }
        Int h { get { return 777 } set {} }
        Void hs() { &h = 2 }

        // no storage
        Int o { get { return 2 } set {} }
        Int p { get { return a } set { a = it } }
        Int q { get { return x } set { x = it } }

        Bar bar := Bar.make
        Int x { get { return bar.x } set { bar.x = it } }
      }

      class Bar
      {
        Int x := 77
      }

      abstract class Goo
      {
        virtual Int abc
        abstract Int xyz
      }")

      foo := pod.types[0]
      goo := pod.types[2]

      // verify set storage flags
      Str["a", "b", "c", "d", "e", "f", "g", "h"]
        .each |Str name| { verifyStorage(foo.field(name), true) }
      verifyStorage(goo.field("abc"), true)

      // verify clear storage flags
      Str["o", "p", "q", "x"]
        .each |Str name| { verifyStorage(foo.field(name), false) }
      verifyStorage(goo.field("xyz"), false)

      // verify "wrapper" fields
      obj := foo.make
      verifyEq(obj->bar->x, 77); verifyEq(obj->x, 77); verifyEq(obj->q, 77)
      obj->bar->x = 99
      verifyEq(obj->bar->x, 99); verifyEq(obj->x, 99); verifyEq(obj->q, 99)
      obj->x = 44
      verifyEq(obj->bar->x, 44); verifyEq(obj->x, 44); verifyEq(obj->q, 44)
      obj->q = 33
      verifyEq(obj->bar->x, 33); verifyEq(obj->x, 33); verifyEq(obj->q, 33)
  }

  Void verifyStorage(Field f, Bool expected)
  {
    verifySame(((Int)f->flags).and(FConst.Storage) != 0, expected)
  }

//////////////////////////////////////////////////////////////////////////
// Virtuals
//////////////////////////////////////////////////////////////////////////

  Void testVirtuals1()
  {
    compile(
     "class Foo
      {
        Int geta() { return x }
        Int gets() { return &x }

        virtual Int x := 3
      }

      class Bar : Foo, Mix
      {
        override Int x := 4
      }

      mixin Mix
      {
        abstract Int x
      }
      ")

     // compiler.fpod.dump

     fooType := pod.types[0]
     mixType := pod.types[1]
     barType := pod.types[2]

     verifyEq(fooType.name, "Foo")
     verifyEq(barType.name, "Bar")
     verifyEq(mixType.name, "Mix")

     verifySame(fooType.field("x").parent, fooType)
     verifySame(barType.field("x").parent, barType)
     verifySame(mixType.field("x").parent, mixType)

     verifyStorage(fooType.field("x"), true)
     verifyStorage(barType.field("x"), false)
     verifyStorage(mixType.field("x"), false)

     verifyEq(fooType.make->x, 3)
     verifyEq(barType.make->x, 4)

     bar := barType.make
     verifyEq(bar->x, 4)
     verifyEq(bar->geta, 4)
     verifyEq(bar->gets, 4)

     bar->x = 7
     verifyEq(bar->x, 7)
     verifyEq(bar->geta, 7)
     verifyEq(bar->gets, 7)
  }

  Void testVirtuals2()
  {
    compile(
     "class A
      {
        Int get() { return x }
        Void set(Int v) { x = v }

        virtual Int x
        {
          get { aGets++; return &x }
          set { aSets++; &x = it }
        }
        Int aGets := 0
        Int aSets := 0
      }

      class B : A
      {
        override Int x
        {
          get { bGets++; return super.x }
          set { bSets++; super.x = it }
        }
        Int bGets := 0
        Int bSets := 0
      }

      class C : B
      {
        override Int x
        {
          get { cGets++; return super.x }
          set { cSets++; super.x = it }
        }
        Int cGets := 0
        Int cSets := 0
      }
      ")

     // compiler.fpod.dump

     aType := pod.types[0]
     bType := pod.types[1]
     cType := pod.types[2]

     verifyEq(aType.name, "A")
     verifyEq(bType.name, "B")
     verifyEq(cType.name, "C")

     verifyStorage(aType.field("x"), true)
     verifyStorage(bType.field("x"), false)
     verifyStorage(cType.field("x"), false)

     verifySame(aType.field("x").parent, aType)
     verifySame(bType.field("x").parent, bType)
     verifySame(cType.field("x").parent, cType)

     verifySame(aType.field("x")->getter->parent, aType)
     verifySame(bType.field("x")->getter->parent, bType)
     verifySame(cType.field("x")->getter->parent, cType)

     obj := cType.make
     verifyEq(obj->aGets, 0); verifyEq(obj->bGets, 0); verifyEq(obj->cGets, 0)
     verifyEq(obj->aSets, 0); verifyEq(obj->bSets, 0); verifyEq(obj->cSets, 0)

     verifyEq(obj->x, 0)
     verifyEq(obj->aGets, 1); verifyEq(obj->bGets, 1); verifyEq(obj->cGets, 1)
     verifyEq(obj->aSets, 0); verifyEq(obj->bSets, 0); verifyEq(obj->cSets, 0)

     obj->x = 7
     verifyEq(obj->aGets, 1); verifyEq(obj->bGets, 1); verifyEq(obj->cGets, 1)
     verifyEq(obj->aGets, 1); verifyEq(obj->bGets, 1); verifyEq(obj->cSets, 1)

     verifyEq(obj->x, 7)
     verifyEq(obj->aGets, 2); verifyEq(obj->bGets, 2); verifyEq(obj->cGets, 2)
     verifyEq(obj->aSets, 1); verifyEq(obj->bSets, 1); verifyEq(obj->cSets, 1)

     obj->set(99)
     verifyEq(obj->aGets, 2); verifyEq(obj->bGets, 2); verifyEq(obj->cGets, 2)
     verifyEq(obj->aSets, 2); verifyEq(obj->bSets, 2); verifyEq(obj->cSets, 2)

     verifyEq(obj->get, 99)
     verifyEq(obj->aGets, 3); verifyEq(obj->bGets, 3); verifyEq(obj->cGets, 3)
     verifyEq(obj->aSets, 2); verifyEq(obj->bSets, 2); verifyEq(obj->cSets, 2)
  }

  Void testVirtuals3()
  {
    compile(
     "class A
      {
        virtual Int x := 3 { set { xTrap = it } }
        Int xTrap
      }

      class B : A
      {
        override Int x := 7
      }
      ")

     aType := pod.types[0]
     bType := pod.types[1]

     obj := bType.make

     verifyEq(obj->x, 3)
     verifyEq(obj->xTrap, 7)
   }

  Void testVirtuals4()
  {
    compile(
     "class A
      {
        virtual Int x { get { return y } set { y = it } }
        Int y
      }

      class B : A
      {
        override Int x
      }
      ")

     aType := pod.types[0]
     bType := pod.types[1]

     verifyStorage(aType.field("x"), false)
     verifyStorage(bType.field("x"), false)
  }

  Void testVirtuals5()
  {
    compile(
     "class B : A
      {
        override Int x := 3
      }

      abstract class A
      {
        abstract Int x
      }
      ")

     aType := pod.types[0]
     bType := pod.types[1]

     verifyStorage(aType.field("x"), false)
     verifyStorage(bType.field("x"), true)
     verifyEq(bType.make->x, 3)
  }

  Void testVirtuals6()
  {
    compile(
     "class A
      {
        virtual Int x { get { return &y } set { &y = it } }
        Int y
      }

      class B : A
      {
        Int get() { return x }
        Void set(Int v) { x = v }

        override Int x
        {
          get { bGets++; return super.x }
          set { bSets++; super.x = it }
        }

        private Int bGets := 0
        private Int bSets := 0
      }
      ")

     aType := pod.types[0]
     bType := pod.types[1]

     verifyStorage(aType.field("x"), false)
     verifyStorage(bType.field("x"), false)

     obj := bType.make
     verifyEq(obj->bGets, 0); verifyEq(obj->bSets, 0)

     verifyEq(obj->x, 0)
     verifyEq(obj->bGets, 1); verifyEq(obj->bSets, 0)

     obj->set(9)
     verifyEq(obj->bGets, 1); verifyEq(obj->bSets, 1)

     verifyEq(obj->get, 9)
     verifyEq(obj->bGets, 2); verifyEq(obj->bSets, 1)
   }

//////////////////////////////////////////////////////////////////////////
// Errors
//////////////////////////////////////////////////////////////////////////

  Void testErrors()
  {
    verifyErrors(
     "class Foo
      {
        Void m00(Int x) { &x = 3 }
        Int m01(Str x) { return x.&size  }
        Int m02(Str x) { return &whereAreYou  }
        Int m03() { return f() }
        Int m04() { return this.f() }
        Void m05() { f(3) }
        Void m06(Foo foo) { foo.f(3) }
        Void m07() { f(3, 2, 1) }

        Int f
      }
      ",
       [
         3, 21, "Invalid use of field storage operator '&'",
         4, 29, "Invalid use of field storage operator '&'",
         5, 27, "Unknown variable 'whereAreYou'",
         6, 22, "Expected method, not field '$podName::Foo.f'",
         7, 27, "Expected method, not field '$podName::Foo.f'",
         8, 16, "Expected method, not field '$podName::Foo.f'",
         9, 27, "Expected method, not field '$podName::Foo.f'",
        10, 16, "Expected method, not field '$podName::Foo.f'",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Func Fields
//////////////////////////////////////////////////////////////////////////

  Void testFuncFields()
  {
    compile(
     "class A
      {
        |->Int| f0 := |->Int| { 99 }
        |Int a->Int| f1 := |Int a->Int| { a }
        |Int a, Int b->Int| f2 := |Int a, Int b->Int| { a + b }
        A ref := this

        Int m00() { f0() }
        Int m01() { this.f0() }
        Int m02() { f1(2) }
        Int m03() { this.f1(3) }
        Int m04() { x := this; return x.f1(4) }
        Int m05() { ref.f2(2, 3) }
        Int m06() { this.ref.f2(2, 4) }
        Int m07() { x := this; return x.ref.f2(3, 4) }
      }")

     a := pod.types.first.make
     verifyEq(a->m00, 99)
     verifyEq(a->m01, 99)
     verifyEq(a->m02, 2)
     verifyEq(a->m03, 3)
     verifyEq(a->m04, 4)
     verifyEq(a->m05, 5)
     verifyEq(a->m06, 6)
     verifyEq(a->m07, 7)
  }

}