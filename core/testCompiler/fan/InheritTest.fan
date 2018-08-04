//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Sept 06  Brian Frank  Creation
//

using compiler

**
** InheritTest
**
class InheritTest : CompilerTest
{

//////////////////////////////////////////////////////////////////////////
// OrderByInheritance
//////////////////////////////////////////////////////////////////////////

  Void testOrderByInheritance()
  {
    compile(
     "class B : A {}
      class D : C {}
      class A {}
      class C : B {}")
     verifyEq(compiler.types[0].name, "A")
     verifyEq(compiler.types[1].name, "B")
     verifyEq(compiler.types[2].name, "C")
     verifyEq(compiler.types[3].name, "D")

    compile(
     "mixin MABC : MAB, MC {}
      mixin MAB : MA, MB {}
      mixin MB {}
      mixin MBD : MD, MB {}
      mixin MC {}
      mixin MBC : MB, MC {}
      mixin MA {}
      mixin MD {}
      ")
     //echo(compiler.types.join("\n"))
     verifyEq(compiler.types[0].name, "MA")
     verifyEq(compiler.types[1].name, "MB")
     verifyEq(compiler.types[2].name, "MAB")
     verifyEq(compiler.types[3].name, "MC")
     verifyEq(compiler.types[4].name, "MABC")
     verifyEq(compiler.types[5].name, "MD")
     verifyEq(compiler.types[6].name, "MBD")
     verifyEq(compiler.types[7].name, "MBC")

    // cyclic inheritance errors
    verifyErrors(
     "class A : A {}
      class B : C {}
      class C : D {}
      class D : B {}
      mixin X : Z {}
      mixin Y : X {}
      mixin Z : X {}
      ",
       [1, 1, "Cyclic inheritance for 'A'",
        2, 1, "Cyclic inheritance for 'B'",
        5, 1, "Cyclic inheritance for 'X'",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// CheckInheritance
//////////////////////////////////////////////////////////////////////////

  Void testCheckInheritance()
  {
    verifyErrors(
     "class C {}
      mixin M {}

      mixin C1 : C {}
      mixin C2 : Buf {}

      class D1 : C[] {}
      class D2 : M:C {}
      class D3 : Str[] {}

      class E : |Int x->M| {}
      mixin F : Int:C {}

      class G : Str {}
      class H : ZipEntryFile {}
      class I : M {} // OK!

      enum class J : G { a }

      class K : C1, G {}
      class L : C1, Test, C2 {}
      class N : G, C1, K {}
      ",
       [
        4, 1, "Mixin 'C1' cannot extend class '$podName::C'",
        5, 1, "Mixin 'C2' cannot extend class 'sys::Buf'",
        7, 1, "Class 'D1' cannot extend parameterized type '$podName::C[]'",
        8, 1, "Class 'D2' cannot extend parameterized type '[$podName::M:$podName::C]'",
        9, 1, "Class 'D3' cannot extend parameterized type 'sys::Str[]'",
       11, 1, "Class 'E' cannot extend parameterized type '|sys::Int->$podName::M|'",
       12, 1, "Mixin 'F' cannot extend class '[sys::Int:$podName::C]'",
       12, 1, "Class 'F' cannot extend parameterized type '[sys::Int:$podName::C]'",
       14, 1, "Class 'G' cannot extend final class 'sys::Str'",
       15, 1, "Class 'H' cannot access internal scoped class 'sys::ZipEntryFile'",
       18, 6, "Enum 'J' cannot extend class '$podName::G'",
       20, 1, "Invalid inheritance order, ensure class '$podName::G' comes first before mixins",
       21, 1, "Invalid inheritance order, ensure class 'sys::Test' comes first before mixins",
       22, 1, "Class 'N' cannot mixin class '$podName::K'",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// InheritErrors
//////////////////////////////////////////////////////////////////////////

  Void testInheritErrors()
  {
    verifyErrors(
      "class A
       {
         new ctor() { return }
         Bool a() { return false }
         virtual Bool b() { return false }
         virtual Bool c() { return false }
         virtual Void d(Bool b) { }
         private Void e() {}
         virtual Int f () { return 9 }
         Bool g
         virtual Int h
         abstract Bool i
         virtual Int j
         virtual Void k() {}
       }

       class B : A
       {
         static B ctor() { return null } // ok
         Bool a() { return true }
         Bool b() { return true }
         override Int c() { return 0 }
         override Void d(Bool b, Int x) { }
         private Void e(Int x, Int y) {} // ok
         override Str f
         override Str g
         Int h
         override Str i
         override final Int j
         override final Void k() {}
       }

       class C : B
       {
         override Int j
         override Void k() {}
       }

       class SubOut : OutStream
       {
         override Void close() { }
         This flush() { this }
         override This write() { return this }
         override This writeBool(Bool x) { return this }
       }

       mixin ConflictX
       {
         static Void a() {}
         virtual Int b() { return 3 }
         virtual Void c(Str q) { }
         virtual Void d(Str q) { }
       }
       mixin ConflictY
       {
         static Void a() {}
         virtual Bool b() { return true }
         virtual Void c(Str q, Int p) { }
         virtual Void d(Int q) { }
       }
       class Conflict : ConflictX, ConflictY {}

       mixin WhichX { virtual Str name() { return null } }
       mixin WhichY { virtual Str name() { return null } }
       class Which : WhichX, WhichY {}

       class Ouch
       {
         override Bool isImmutable() { return true }
         override Void figgle() {}
         override Str foogle
         virtual Obj returnObj() { return null }
         virtual Void returnVoid() {}
       }

       class SubOuch : Ouch
       {
         override Void returnObj() {}
         override Obj returnVoid() { return null }
       }",
       [// internal to compilation unit
        20, 3, "Cannot override non-virtual slot '$podName::A.a'",
        21, 3, "Must specify override keyword to override '$podName::A.b'",
        22, 3, "Return type mismatch in override of '$podName::A.c' - 'sys::Bool' != 'sys::Int'",
        23, 3, "Parameter mismatch in override of '$podName::A.d' - 'd(sys::Bool)' != 'd(sys::Bool, sys::Int)'",
        25, 3, "Type mismatch in override of '$podName::A.f' - 'sys::Int' != 'sys::Str'",
        26, 3, "Cannot override non-virtual slot '$podName::A.g'",
        27, 3, "Must specify override keyword to override '$podName::A.h'",
        28, 3, "Type mismatch in override of '$podName::A.i' - 'sys::Bool' != 'sys::Str'",

        // override finals
        35, 3, "Cannot override non-virtual slot '$podName::B.j'",
        36, 3, "Cannot override non-virtual slot '$podName::B.k'",

        // imported inherits
        41, 3, "Return type mismatch in override of 'sys::OutStream.close' - 'sys::Bool' != 'sys::Void'",
        42, 3, "Must specify override keyword to override 'sys::OutStream.flush'",
        43, 3, "Parameter mismatch in override of 'sys::OutStream.write' - 'write(sys::Int)' != 'write()'",
        44, 3, "Cannot override non-virtual slot 'sys::OutStream.writeBool'",

        // conflicts
        61, 1, "Inheritance conflict '$podName::ConflictX.a' and '$podName::ConflictY.a'",
        61, 1, "Inherited slots have conflicting signatures '$podName::ConflictX.b' and '$podName::ConflictY.b'",
        61, 1, "Inherited slots have conflicting signatures '$podName::ConflictX.c' and '$podName::ConflictY.c'",
        61, 1, "Inherited slots have conflicting signatures '$podName::ConflictX.d' and '$podName::ConflictY.d'",
        65, 1, "Must override ambiguous inheritance '$podName::WhichX.name' and '$podName::WhichY.name'",

        // overrides of unknown virtuals
        69, 3, "Cannot override non-virtual slot 'sys::Obj.isImmutable'",
        70, 3, "Override of unknown virtual slot 'figgle'",
        71, 3, "Override of unknown virtual slot 'foogle'",

        // Obj -> Void covariance - no no!
        78, 3, "Return type mismatch in override of '$podName::Ouch.returnObj' - 'sys::Obj' != 'sys::Void'",
        79, 3, "Return type mismatch in override of '$podName::Ouch.returnVoid' - 'sys::Void' != 'sys::Obj'",
       ])
  }

  Void testCovariantNullable()
  {
    verifyErrors(
     "class Foo : Base
      {
        override Obj  a() { return this }
        override Obj? b() { return this }
        override Str[]? c
        override Str:Int d
        override Int e
        override Int? f
      }

      class Base
      {
        virtual Obj? a() { return this }
        virtual Obj  b() { return this }
        virtual Str[] c
        virtual [Str:Int]? d
        virtual Int? e() { return 4 }
        virtual Int f() { return 4 }
      }

      ",
       [
        3, 3, "Return type mismatch in override of '$podName::Base.a' - 'sys::Obj?' != 'sys::Obj'",
        4, 3, "Return type mismatch in override of '$podName::Base.b' - 'sys::Obj' != 'sys::Obj?'",
        5, 3, "Type mismatch in override of '$podName::Base.c' - 'sys::Str[]' != 'sys::Str[]?'",
        6, 3, "Type mismatch in override of '$podName::Base.d' - '[sys::Str:sys::Int]?' != '[sys::Str:sys::Int]'",
        7, 3, "Type mismatch in override of '$podName::Base.e' - 'sys::Int?' != 'sys::Int'",
        8, 3, "Type mismatch in override of '$podName::Base.f' - 'sys::Int' != 'sys::Int?'",
       ])
  }

  Void testCovariantValueTypes()
  {
    verifyErrors(
     "class Foo : Base
      {
        override Float? a() { return null}
        override Int    b() { return 0 }
        override Int    c() { return 0 }
        override Int d
      }

      class Base
      {
        virtual Obj? a() { return this }
        virtual Obj  b() { return this }
        virtual Num  c() { return 0 }
        virtual Num  d() { return 0 }
      }

      ",
       [
        3, 3, "Cannot use covariance with value types '$podName::Base.a' - 'sys::Obj?' != 'sys::Float?'",
        4, 3, "Cannot use covariance with value types '$podName::Base.b' - 'sys::Obj' != 'sys::Int'",
        5, 3, "Cannot use covariance with value types '$podName::Base.c' - 'sys::Num' != 'sys::Int'",
        6, 3, "Cannot use covariance with value types '$podName::Base.d' - 'sys::Num' != 'sys::Int'",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// InheritProtection
//////////////////////////////////////////////////////////////////////////

  Void testInheritProtection()
  {
    verifyErrors(
     "class B : A
      {
        override public    Void a1() {} // ok
        override protected Void a2() {}
        override internal  Void a3() {}
        override private   Void a4() {}

        override public    Void b1() {} // ok
        override protected Void b2() {} // ok
        override internal  Void b3() {}
        override private   Void b4() {}

        override public    Void c1() {} // ok
        override protected Void c2() {}
        override internal  Void c3() {} // ok
        override private   Void c4() {}

        override public Void d() {}  // unknown
      }

      class A
      {
        virtual public Void a1() {}
        virtual public Void a2() {}
        virtual public Void a3() {}
        virtual public Void a4() {}

        virtual protected Void b1() {}
        virtual protected Void b2() {}
        virtual protected Void b3() {}
        virtual protected Void b4() {}

        virtual internal Void c1() {}
        virtual internal Void c2() {}
        virtual internal Void c3() {}
        virtual internal Void c4() {}

        private Void d() {}
      }",
     [
       4, 3, "Override narrows protection scope of '$podName::A.a2'",
       5, 3, "Override narrows protection scope of '$podName::A.a3'",
       6, 3, "Override narrows protection scope of '$podName::A.a4'",

      10, 3, "Override narrows protection scope of '$podName::A.b3'",
      11, 3, "Override narrows protection scope of '$podName::A.b4'",

      14, 3, "Override narrows protection scope of '$podName::A.c2'",
      16, 3, "Override narrows protection scope of '$podName::A.c4'",

      18, 3, "Override of unknown virtual slot 'd'",
     ])
  }

//////////////////////////////////////////////////////////////////////////
// IntraUnitInherit
//////////////////////////////////////////////////////////////////////////

  Void testIntraUnitInherit()
  {
    compile(
     "class A
      {
        static Str sa() { return \"sa\" }
        Str ia() { return \"ia\" }
        virtual Str vx() { return \"A.vx\" }
      }

      class B : A
      {
        static Str sb() { return sa }
        Str ib() { return ia }
        override Str vx() { return \"B.vx\" }
      }")
     a := compiler.types[0]
     b := compiler.types[1]
     verifyEq(a.name, "A")
     verifyEq(b.name, "B")
     verifyEq(b.base, a)
     verifyEq(b.slot("ib").parent, b)
     verifyEq(b.slot("ia").parent, a)
     verifyEq(b.slot("vx").parent, b)

     typeB := pod.types[1]
     objB := typeB.make
     verifyEq(typeB.method("sb").callList([,]), "sa")
     verifyEq(typeB.method("ib").callList([objB]), "ia")
     verifyEq(typeB.method("vx").callList([objB]), "B.vx")
  }

//////////////////////////////////////////////////////////////////////////
// MultipleInherit
//////////////////////////////////////////////////////////////////////////

  Void testMultipleInherit()
  {
    compile(
     "mixin A
      {
        abstract Str a()
        abstract Str b()
        override Int hash() { return 77 }
      }

      class B : A
      {
        override Str a() { return \"B.a\" }
        override Str b := \"B.b\"
      }

      mixin C : A      {
        override Str toStr() { return \"C.toStr\" }
      }

      class D : B, C
      {
      }
      ")

     // verify D's slot map
     astD := compiler.types[3]
     verifyEq(astD.name, "D")
     verifyEq(astD.slot("a").parent.name, "B")      // inherit concrete one
     verifyEq(astD.slot("b").parent.name, "B")      // inherit concrete one
     verifyEq(astD.slot("hash").parent.name, "A")   // inherit most specific one
     verifyEq(astD.slot("toStr").parent.name, "C")  // inherit most specific one

     // verify code works
     typeD := pod.types[3]
     objD := typeD.make
     verifyEq(typeD.name, "D")
     verifyEq(typeD.method("a").callList([objD]), "B.a")
     verifyEq(typeD.field("b").get(objD), "B.b")
     verifyEq(typeD.method("hash").callList([objD]), 77)
     verifyEq(typeD.method("toStr").callList([objD]), "C.toStr")
  }

//////////////////////////////////////////////////////////////////////////
// Covariance
//////////////////////////////////////////////////////////////////////////

  Void testCovariance()
  {
    compile(
     "mixin Q
      {
        virtual Q? m() { return null }
        virtual Q? n() { return null }

        virtual Obj[] e() { return [2ns, 3] }
        virtual Num[] f() { return [2, 3f] }
      }

      mixin P : Q
      {
        override P? n() { return this }
        override Int[] f() { return [2, 3] }
      }"
    )
    TypeDef q := compiler.types[0]
    TypeDef p := compiler.types[1]

    Type qt := pod.types[0]
    Type pt := pod.types[1]

    compile(
     "using $q.pod.name

      class A
      {
        virtual A? x() { return null }
      }

      mixin M
      {
        virtual M? y() { return null }
      }

      class B : A, M, P
      {
        override B? x() { return this }
        static A? xA(A a) { return a.x }
        static B xB(B b) { return b.x }

        override B? y() { return this }
        static M? yM(M a) { return a.y }
        static B yB(B b) { return b.y }

        override B? m() { return this }
        static Q? mQ(Q q) { return q.m }
        static B mB(B b) { return b.m }

        override B? n() { return this }
        static Q? nQ(Q q) { return q.n }
        static P nP(P p) { return p.n }
        static B nB(B b) { return b.n }

        override Str[] e() { return [\"hello\"] }
        static Obj[] eQ(Q q) { return q.e }
        static Str[] eB(B b) { return b.e }

        static Num[] fQ(Q q) { return q.f }
        static Int[] fP(P p) { return p.f }
        static Int[] fB(B b) { return b.f }
      }
      ")

     // compiler.fpod.dump

     //
     // verify CMethod.inheritedType works correctly
     //

     TypeDef a := compiler.types[0]
     TypeDef m := compiler.types[1]
     TypeDef b := compiler.types[2]

     verifyEq(q.name, "Q")
     verifyEq(q.method("m").returnType.name, "Q")
     verifyEq(q.method("m").inheritedReturnType.name, "Q")

     verifyEq(p.name, "P")
     verifyEq(p.method("n").returnType.name, "P")
     verifyEq(p.method("n").inheritedReturnType.name, "Q")
     verifyEq(p.method("f").returnType.signature, "sys::Int[]")
     verifyEq(p.method("f").inheritedReturnType.signature, "sys::Num[]")

     verifyEq(a.name, "A")
     verifyEq(a.method("x").returnType.name, "A")
     verifyEq(a.method("x").inheritedReturnType.name, "A")

     verifyEq(m.name, "M")
     verifyEq(m.method("y").returnType.name, "M")
     verifyEq(m.method("y").inheritedReturnType.name, "M")

     verifyEq(b.name, "B")
     verifyEq(b.method("x").returnType.name, "B")
     verifyEq(b.method("x").inheritedReturnType.name, "A")
     verifyEq(b.method("y").returnType.name, "B")
     verifyEq(b.method("y").inheritedReturnType.name, "M")
     verifyEq(b.method("m").returnType.name, "B")
     verifyEq(b.method("m").inheritedReturnType.name, "Q")
     verifyEq(b.method("n").returnType.name, "B")
     verifyEq(b.method("n").inheritedReturnType.name, "Q")
     verifyEq(b.method("e").returnType.signature, "sys::Str[]")
     verifyEq(b.method("e").inheritedReturnType.signature, "sys::Obj[]")
     verifyEq(b.method("f").returnType.signature, "sys::Int[]")
     verifyEq(b.method("f").inheritedReturnType.signature, "sys::Num[]")

     //
     // verify reflection
     //
     Type at := pod.types[0]
     Type mt := pod.types[1]
     Type bt := pod.types[2]

     verifySame(at.method("x").returns, at.toNullable)
     verifySame(mt.method("y").returns, mt.toNullable)
     verifySame(qt.method("m").returns, qt.toNullable)
     verifySame(qt.method("n").returns, qt.toNullable)
     verifySame(qt.method("e").returns, Obj[]#)
     verifySame(qt.method("f").returns, Num[]#)
     verifySame(pt.method("m").returns, qt.toNullable)
     verifySame(pt.method("n").returns, pt.toNullable)
     verifySame(pt.method("e").returns, Obj[]#)
     verifySame(pt.method("f").returns, Int[]#)
     verifySame(bt.method("x").returns, bt.toNullable)
     verifySame(bt.method("y").returns, bt.toNullable)
     verifySame(bt.method("n").returns, bt.toNullable)
     verifySame(bt.method("m").returns, bt.toNullable)
     verifySame(bt.method("e").returns, Str[]#)
     verifySame(bt.method("f").returns, Int[]#)

     //
     // verify methods work
     //
     obj := bt.make
     verifySame(bt.method("xA").call(obj), obj)
     verifySame(bt.method("xB").call(obj), obj)
     verifySame(bt.method("yM").call(obj), obj)
     verifySame(bt.method("yB").call(obj), obj)
     verifySame(bt.method("mQ").call(obj), obj)
     verifySame(bt.method("mB").call(obj), obj)
     verifySame(bt.method("nQ").call(obj), obj)
     verifySame(bt.method("nP").call(obj), obj)
     verifySame(bt.method("nB").call(obj), obj)
     verifyEq(bt.method("eQ").call(obj), ["hello"])
     verifyEq(bt.method("eB").call(obj), ["hello"])
     verifyEq(bt.method("fQ").call(obj), [2, 3])
     verifyEq(bt.method("fP").call(obj), [2, 3])
     verifyEq(bt.method("fB").call(obj), [2, 3])
  }

  Void testCovarianceMore()
  {
    compile(
     "abstract class AA
      {
        abstract Obj y()
      }

      abstract class A : AA
      {
        abstract Obj x()
        override abstract Num y()
      }

      mixin M
      {
        abstract Obj x()
        virtual Obj y() { return 4 }
      }

      class B : A, M
      {
        override B x() { return this }
        static Obj xA(A a) { return a.x }
        static Obj xM(M m) { return m.x }
        static B xB(B b) { return b.x }

        override Num y() { return 8 }
        static Obj yAA(AA a) { return a.y }
        static Num yA(A a) { return a.y }
        static Obj yM(M m) { return m.y }
        static Num yB(B b) { return b.y }
      }
      ")

     // compiler.fpod.dump

     Type bt := pod.types[3]

     obj := bt.make
     verifySame(bt.method("xA").call(obj), obj)
     verifySame(bt.method("xM").call(obj), obj)
     verifySame(bt.method("xB").call(obj), obj)

     verifySame(bt.method("yAA").call(obj), 8)
     verifySame(bt.method("yA").call(obj), 8)
     verifySame(bt.method("yM").call(obj), 8)
     verifySame(bt.method("yB").call(obj), 8)
  }

  Void testCovarianceFields()
  {
   compile(
     "mixin Q
      {
        virtual Num q() { return 'q' }
      }"
    )

    Type q := pod.type("Q")

    compile(
     "using $q.pod.name

      abstract class A
      {
        abstract Num x()
      }

      class B : A, Q
      {
        override Decimal x := 3d
        override Decimal q := 7d

        static Decimal v1(B o) { return o.x }
        static Num v2(A o) { return o.x }
        static Decimal v3(B o) { return o.q++ }
        static Num v4(Q o) { return o.q }
      }

      ")

    // compiler.fpod.dump

    a := pod.type("A")
    b := pod.type("B")
    o := b.make

    verifySame(b.base, a)
    verifySame(b.mixins.first, q)

    verifyEq(a.method("x").callOn(o, [,]), 3d)
    verifyEq(b.field("x").get(o), 3d)
    b.field("x").set(o, 6d)
    verifyEq(a.method("x").callOn(o, [,]), 6d)
    verifyEq(b.field("x").get(o), 6d)

    verifyEq(b.method("v1").call(o), 6d)
    verifyEq(b.method("v2").call(o), 6d)
    verifyEq(b.method("v3").call(o), 7d)
    verifyEq(b.method("v4").call(o), 8d)
  }

  Void testCovarianceConflict()
  {
    verifyErrors(
     "abstract class AA
      {
        abstract Obj f()
      }

      abstract class A : AA
      {
        abstract A x()
        abstract Obj y()
        abstract A z()
        override Num f() { return 3 }
      }

      mixin M
      {
        abstract M x()
        abstract A y()
        abstract Obj z()
        abstract Num f()
      }

      class B : A, M
      {
        override B x() { return this }
        override A y() { return this }
        override B z() { return this }
      }",
      [
       22, 1, "Inherited slots have conflicting signatures '$podName::A.f' and '$podName::M.f'",
       24, 3, "Conflicting covariant returns: '$podName::A' and '$podName::M'",
       25, 3, "Conflicting covariant returns: 'sys::Obj' and '$podName::A'",
       26, 3, "Conflicting covariant returns: '$podName::A' and 'sys::Obj'",
     ])
  }

//////////////////////////////////////////////////////////////////////////
// This Return
//////////////////////////////////////////////////////////////////////////

  Void testThisReturn()
  {
    compile(
     "class A
      {
        Int testA() { return x.a }
        This x() { return this }
        Int a() { return 'A' }
        virtual This o() { return this }
        This n() { return this }
      }

      class B : A
      {
        Int testB1() { return x.b }
        Int testB2() { return x.y.b }
        Int testB3() { return o.b }
        This y() { return this }
        Int b() { return 'B' }
        override This o() { return this }
      }

      class C : B
      {
        Int testC1() { return x.y.z.c }
        Int testC2() { return this.o.c }
        Int testC3(C p) { return p.y.x.o.c }
        C testC4(C p) { return p.x }
        Int testC5() { x.y; return 'X' }
        This z() { return this }
        Int c() { return 'C' }
      }")
    // compiler.fpod.dump

    a := pod.type("A").make
    b := pod.type("B").make
    c := pod.type("C").make

    verifyEq(a->testA, 'A')
    verifySame(a->x, a)
    verifySame(a->o, a)

    verifyEq(b->testB1, 'B')
    verifyEq(b->testB2, 'B')
    verifyEq(b->testB3, 'B')
    verifySame(b->y, b)

    verifyEq(c->testC1, 'C')
    verifyEq(c->testC2, 'C')
    verifyEq(c->testC3(c), 'C')
    verifySame(c->testC4(c), c)
    verifyEq(c->testC5, 'X')
  }

  Void testThisReturnErrors()
  {
    // normalize
    verifyErrors(
     "class Foo
      {
        This field
      }",
      [
        3, 3,  "Cannot use This as field type",
      ])

    // inherit step
    verifyErrors(
     "class A
      {
        virtual This x() { return this }
      }

      class B : A
      {
        override B x() { return this }
      }",
      [
        8, 3, "Return in override of '$podName::A.x' must be This",
      ])

    // check errors
    verifyErrors(
     "class Foo
      {
        Void m00(This x) {}
        Void m01(Void x) {}
        Void m02() { This? x := null }
        Void m03() { Void? x := null }
        static This m04() { return Foo.make }
        This m05() { return 3 }
        This? m06() { return this }
        This m07() { return null }
      }",
      [
        3, 12, "Cannot use This as parameter type",
        4, 12, "Cannot use Void as parameter type",
        5, 16, "Cannot use This as local variable type",
        6, 27, "'null' is not assignable to 'sys::Void?'",
        6, 16, "Cannot use Void as local variable type",
        7, 3,  "Cannot return This from static method",
        8, 23, "Cannot return 'sys::Int' as $podName::Foo This",
        9, 3, "This type cannot be nullable",
        10, 23, "Cannot return 'null' as $podName::Foo This",
      ])
  }

//////////////////////////////////////////////////////////////////////////
// FieldInherit
//////////////////////////////////////////////////////////////////////////

  ** abstract method -> field
  Void testFieldInherit1()
  {
    verifyFieldInherit(
     "abstract Int p0()
      abstract Int p1()
      abstract Int p2()
      abstract Int p3()", false)
   }

  ** virtual method -> field
  Void testFieldInherit2()
  {
    verifyFieldInherit(
     "virtual Int p0() { return 99 }
      virtual Int p1() { return 99 }
      virtual Int p2() { return 99 }
      virtual Int p3() { return 99 }", false)
   }

  ** abstract field -> field
  Void testFieldInherit3()
  {
    verifyFieldInherit(
     "abstract Int p0
      abstract Int p1
      abstract Int p2
      abstract Int p3", true)
   }

  ** field -> field (tested in FieldTest - we can't really
  ** use this test approach because the subclass doesn't get
  ** direct accesss to parent class storage

   private Void verifyFieldInherit(Str aFields, Bool doSeta)
   {
     doVerifyFieldInherit(true, aFields, doSeta)
     doVerifyFieldInherit(false, aFields, doSeta)
   }

   private Void doVerifyFieldInherit(Bool aIsClass, Str aFields, Bool doSeta)
   {
     aHeader  := aIsClass ? "abstract class" : "mixin"

     setaCode := !doSeta ? "" :
     "
        static Void seta(A a, Str:Int m)
        {
          a.p0 = m[\"p0\"]
          a.p1 = m[\"p1\"]
          a.p2 = m[\"p2\"]
          a.p3 = m[\"p3\"]
        }
      "

     compile(
     "$aHeader A
      {
        $aFields
      }

      class B : A
      {
        static Str:Int geta(A a)
        {
          return [\"p0\":a.p0, \"p1\":a.p1, \"p2\":a.p2, \"p3\":a.p3]
        }

        static Str:Int getb(B b)
        {
          return [\"p0\":b.&p0, \"p1\":b.&p1, \"p2\":b.&p2, \"p3\":b.&p3]
        }

        $setaCode

        static Void setb(B b, Str:Int m)
        {
          b.&p0 = m[\"p0\"]
          b.&p1 = m[\"p1\"]
          b.&p2 = m[\"p2\"]
          b.&p3 = m[\"p3\"]
        }

        static Bool getCounts(B b, Int expected)
        {
          // echo(\"getCounts \$b.p1_get \$b.p2_get\")
          return b.p1_get == expected && b.p2_get == expected
        }

        static Bool setCounts(B b, Int expected)
        {
          // echo(\"setCounts \$b.p2_set \$b.p3_set\")
          return b.p2_set == expected && b.p3_set == expected
        }

        // abstract method -> field
        override Int p0 := 101
        override Int p1 := 102 { get { p1_get++; return &p1 } }
        override Int p2 := 103 { get { p2_get++; return &p2 } set { p2_set++; &p2 = it } }
        override Int p3 := 104 { set { p3_set++; &p3 = it } }
        Int p1_get := 0
        Int p2_get := 0
        Int p2_set := 0
        Int p3_set := 0
      }
      ")

     a := pod.types[0]
     b := pod.types[1]
     geta := b.method("geta")
     getb := b.method("getb")
     seta := b.method("seta", false)
     setb := b.method("setb")
     getCounts := b.method("getCounts")
     setCounts := b.method("setCounts")

     orig := ["p0":101, "p1":102, "p2":103, "p3":104]
     Str:Int change1 := orig.map |Int v->Int| { 1000+v }
     Str:Int change2 := orig.map |Int v->Int| { 2000+v }

     obj := b.make
     verifyEq(getCounts.call(obj, 0), true)
     verifyEq(getCounts.call(obj, 0), true)

     verifyEq(geta.call(obj), orig)
     verifyEq(getCounts.call(obj, 1), true)

     verifyEq(getb.call(obj), orig)
     verifyEq(getCounts.call(obj, 1), true)

     setb.call(obj, change1)
     verifyEq(setCounts.call(obj, 0), true)

     verifyEq(geta.call(obj), change1)
     verifyEq(getCounts.call(obj, 2), true)

     verifyEq(getb.call(obj), change1)
     verifyEq(getCounts.call(obj, 2), true)

     if (doSeta)
     {
       seta.call(obj, change2)
       verifyEq(setCounts.call(obj, 1), true)

       verifyEq(geta.call(obj), change2)
       verifyEq(getCounts.call(obj, 3), true)

       verifyEq(getb.call(obj), change2)
       verifyEq(getCounts.call(obj, 3), true)
     }
  }

//////////////////////////////////////////////////////////////////////////
// NamedSuper
//////////////////////////////////////////////////////////////////////////

  Void testNamedSuper()
  {
    compile(
     "mixin X
      {
        virtual Str f(Int a) { return \"X.f\" }
        virtual Str s(Int a) { return \"X.s\" }
      }

      mixin Y
      {
        virtual Str f(Int a) { return \"Y.f\" }
      }

      mixin Z : X
      {
        override Str toStr() { return \"Z.toStr\" }
        override Str s(Int a)
        {
          switch (a)
          {
            case 'Z': return \"Z.s\"
            case 'X': return X.super.s(a)
          }
          throw Err.make
        }
      }

      class A
      {
        virtual Str f(Int a) { return \"A.f\" }
      }

      class B : A
      {
        override Str f(Int a) { return \"B.f\" }
      }

      class C : B, Z, Y
      {
        override Str f(Int a)
        {
          switch (a)
          {
            case 'C': return \"C.f\"
            case 'S': return super.f(a)
            // removed named super on classes #1670
            // case 'B': return B.super.f(a)
            // case 'A': return A.super.f(a)
            case 'X': return X.super.f(a)
            case 'Y': return Y.super.f(a)
          }
          throw Err.make
        }

        Str g(Int a)
        {
          switch (a)
          {
            case 'C': return \"C.f\"
            case 'S': return super.f(a)
            // removed named super on classes #1670
            // case 'B': return B.super.f(a)
            // case 'A': return A.super.f(a)
            case 'X': return X.super.f(a)
            case 'Y': return Y.super.f(a)
          }
          throw Err.make
        }

        Str h(Int a)
        {
          switch (a)
          {
            case 'C': return ((C)this).f(a)
            case 'S': return ((B)this).f(a)
            case 'B': return ((B)this).f(a)
            case 'A': return ((A)this).f(a)
            case 'X': return ((X)this).f(a)
            case 'Y': return ((Y)this).f(a)
          }
          throw Err.make
        }
      }
      ")

     // compiler.fpod.dump

     Type t := pod.types[5]
     verifyEq(t.name, "C")
     obj := t.make;

     ["f", "g", "h"].each |Str mn|
     {
       m := t.method(mn)
       verifyEq(m.callOn(obj, ['C']), "C.f")
       verifyEq(m.callOn(obj, ['S']), "B.f")
       verifyEq(m.callOn(obj, ['X']), "X.f")
       verifyEq(m.callOn(obj, ['Y']), "Y.f")
     }

     verifyEq(t.method("s").callOn(obj, ['Z']), "Z.s")
     verifyEq(t.method("s").callOn(obj, ['X']), "X.s")
  }

  Void testNamedSuperErrors()
  {
    verifyErrors(
     "mixin X
      {
        virtual Str f() { return \"X.f\" }
      }

      mixin Y : X
      {
        //Str m00() { return super.f }  Unknown slot before CheckErrors
        Str m01() { return super.toStr }
        Str m02() { return Obj.super.toStr }
      }

      class A
      {
        virtual Str a() { return \"A.f\" }
      }

      class Foo
      {
        virtual Str f() { return \"Foo.f\" }
      }

      class B : A, Y
      {
        Str m00() { return Foo.super.f }
        Str m03() { return A.super.a }
      }",
      [
        9, 22, "Must use named 'super' inside mixin",
       10, 22, "Cannot use 'Obj.super' inside mixin (yeah I know - take it up with Sun)",
       10, 22, "Cannot use named super on class type 'sys::Obj'",
       25, 22, "Cannot use named super on class type '$podName::Foo'",
       25, 22, "Named super '$podName::Foo' not a super class of 'B'",
       26, 22, "Cannot use named super on class type '$podName::A'",
     ])
  }

//////////////////////////////////////////////////////////////////////////
// Const Overrides
//////////////////////////////////////////////////////////////////////////

  Void testConstOverrides()
  {
    compile(
     "mixin X
      {
        virtual Str x() { return \"X.a\" }
        Str xToStr() { return x.toStr }
      }

      mixin Y
      {
        abstract Str y()
        Str yToStr() { return y.toStr }
      }

      abstract class A
      {
        virtual Str a1() { return \"A.a1\" }
        abstract Str a2()

        Str aToStr() { return \"\$a1,\$a2\" }
      }

      class Foo : A, X, Y
      {
        new make(Str? x := null, Str? y := null)
        {
          if (x != null) this.x = x
          if (y != null) this.y = y
        }
        override const Str x := \"Foo.x\"
        override const Str y := \"Foo.y\"
        override const Str a1 := \"Foo.a1\"
        override const Str a2 := \"Foo.a2\"

        override Str toStr() { return \"\$x,\$y,\$a1,\$a2\" }
      }
      ")

     t := pod.type("Foo")
     obj := t.make
     verifyEq(obj.toStr, "Foo.x,Foo.y,Foo.a1,Foo.a2")
     verifyEq(obj->aToStr, "Foo.a1,Foo.a2")
     verifyEq(obj->xToStr, "Foo.x")
     verifyEq(obj->yToStr, "Foo.y")

     obj = t.make(["q", "r"])
     verifyEq(obj.toStr, "q,r,Foo.a1,Foo.a2")
     verifyEq(obj->aToStr, "Foo.a1,Foo.a2")
     verifyEq(obj->xToStr, "q")
     verifyEq(obj->yToStr, "r")
  }

  Void testConstOverridesErrors()
  {
    // Parser step
    verifyErrors(
     "class Foo : A
      {
        override const Str a { get { return 5 } }
        override const Str b { set {} }
        override const Str c { get { return 5 } set { &c = 6 } }
      }

      class A
      {
        virtual Int a
        virtual Int b
        virtual Int c
      }
      ",
      [
        3, 26, "Const field 'a' cannot have getter",
        4, 26, "Const field 'b' cannot have setter",
        5, 26, "Const field 'c' cannot have getter",
        5, 43, "Const field 'c' cannot have setter",
     ])

    // Inherit step
    verifyErrors(
     "class Foo : A, X
      {
        override const Float a
        override Int b // shouldn't work with non-const either
        override const Int c
        override const Int d
      }

      class A
      {
        virtual Float a
      }

      mixin X
      {
        virtual Int b(Int x) { return x}
        virtual Int c(Int x) { return x}
        abstract Int d
      }

      ",
      [
        3, 3, "Const field 'a' cannot override field '$podName::A.a'",
        4, 3, "Field 'b' cannot override method with params '$podName::X.b'",
        5, 3, "Field 'c' cannot override method with params '$podName::X.c'",
        6, 3, "Const field 'd' cannot override field '$podName::X.d'",
     ])

    // CheckErrors step
    verifyErrors(
     "abstract class Foo
      {
        abstract const Str? a
        virtual const Str? b
      }
      ",
      [
        3, 3, "Invalid combination of 'const' and 'abstract' modifiers",
        4, 3, "Invalid combination of 'const' and 'virtual' modifiers",
     ])

  }

//////////////////////////////////////////////////////////////////////////
// Const Subclass
//////////////////////////////////////////////////////////////////////////

  Void testConstSubclass()
  {
    compile(
     "class X
      {
        const Int x := 1
      }

      class Y : X
      {
        const Int y := 2
        new make() { x += 10 }
      }")

    x := pod.type("X").make
    y := pod.type("Y").make
    verifyEq(x->x, 1)
    verifyEq(y->x, 11)
    verifyEq(y->y, 2)
  }


}