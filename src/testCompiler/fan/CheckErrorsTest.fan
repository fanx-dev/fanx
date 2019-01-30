//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   17 Sep 06  Brian Frank  Creation
//

**
** CheckErrorsTest
**
class CheckErrorsTest : CompilerTest
{

//////////////////////////////////////////////////////////////////////////
// Types
//////////////////////////////////////////////////////////////////////////

  Void testTypeFlags()
  {
    // parser stage
    verifyErrors(
     "abstract mixin A {}
      final mixin B {}
      abstract enum class C { none }
      const final enum class D { none }
      abstract facet class E {}
      const final facet class F {}
      public public class G {}
      abstract internal abstract class H {}
      ",
       [
         1,  10, "The 'abstract' modifier is implied on mixin",
         2,   7, "Cannot use 'final' modifier on mixin",
         3,  10, "Cannot use 'abstract' modifier on enum",
         4,  13, "The 'const' modifier is implied on enum",
         4,  13, "The 'final' modifier is implied on enum",
         5,  10, "Cannot use 'abstract' modifier on facet",
         6,  13, "The 'const' modifier is implied on facet",
         6,  13, "The 'final' modifier is implied on facet",
         7,   8, "Repeated modifier",
         8,  19, "Repeated modifier",
       ])

    // check errors stage
    verifyErrors(
     "new class A {}
      private class B {}
      protected class C {}
      virtual static class D {}
      once class G {}
      public internal class H {}
      abstract final class I {}
      ",
       [
         1,  5, "Cannot use 'new' modifier on type",
         2,  9, "Cannot use 'private' modifier on type",
         3, 11, "Cannot use 'protected' modifier on type",
         4, 16, "Cannot use 'static' modifier on type",
         //4, 16, "Cannot use 'virtual' modifier on type",
         5,  6, "Cannot use 'once' modifier on type",
         6, 17, "Invalid combination of 'public' and 'internal' modifiers",
         7, 16, "Invalid combination of 'abstract' and 'final' modifiers",
       ])
  }

  Void testTypeAbstractSlots()
  {
    // errors
    verifyErrors(
     "virtual class A { abstract Void x()  }
      virtual class B { abstract Void x(); abstract Void y(); }
      class C : B {}
      class D : A { abstract Void y(); }
      class E : B, X { override Void a() {} override Void x() {} }
      mixin X { abstract Void a(); abstract Void b(); }
      ",
       [
         1,  9, "Class 'A' must be abstract since it contains abstract slots",
         2,  9, "Class 'B' must be abstract since it contains abstract slots",
         3,  1, "Class 'C' must be abstract since it inherits but doesn't override '$podName::B.x'",
         3,  1, "Class 'C' must be abstract since it inherits but doesn't override '$podName::B.y'",
         4,  1, "Class 'D' must be abstract since it inherits but doesn't override '$podName::A.x'",
         4,  1, "Class 'D' must be abstract since it contains abstract slots",
         5,  1, "Class 'E' must be abstract since it inherits but doesn't override '$podName::B.y'",
         5,  1, "Class 'E' must be abstract since it inherits but doesn't override '$podName::X.b'",
       ])
  }

  Void testTypeMisc()
  {
    // check inherit stage
    verifyErrors(
     "class A { Type typeof }
      class B { Type typeof() { return Str# } }
      class C { override Type typeof() { return Str# } }
      ",
       [
         1, 11, "Cannot override non-virtual slot 'sys::Obj.typeof'",
         2, 11, "Cannot override non-virtual slot 'sys::Obj.typeof'",
         3, 11, "Cannot override non-virtual slot 'sys::Obj.typeof'",
       ])
  }

  Void testConstInheritance()
  {
    // check errors stage
    verifyErrors(
     "virtual const class Q {}
      const mixin X {}
      const mixin Y {}
      mixin Z {}

      class A : Q {}
      class B : X {}
      class C : Q, X, Y {}
      class D : Z, X {}
      mixin E : X {}
      mixin F : Z, Y {}
      ",
       [
         6, 1, "Non-const type 'A' cannot subclass const class 'Q'",
         7, 1, "Non-const type 'B' cannot implement const mixin 'X'",
         8, 1, "Non-const type 'C' cannot subclass const class 'Q'",
         8, 1, "Non-const type 'C' cannot implement const mixin 'X'",
         8, 1, "Non-const type 'C' cannot implement const mixin 'Y'",
         9, 1, "Non-const type 'D' cannot implement const mixin 'X'",
        10, 1, "Non-const type 'E' cannot implement const mixin 'X'",
        11, 1, "Non-const type 'F' cannot implement const mixin 'Y'",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Test protection scopes
//////////////////////////////////////////////////////////////////////////

  Void testProtectionScopes()
  {
    // first create a pod with internal types/slots
    compile(
     "class Public
      {
        virtual public    Void mPublic()    {}
        virtual protected Void mProtected() {}
        virtual internal  Void mInternal()  {}
                private   Void mPrivate()   {} // can't mix virtual+private

        static public    Void msPublic()    {}
        static protected Void msProtected() {}
        static internal  Void msInternal()  {}
        static private   Void msPrivate()   {}

        virtual public    Int fPublic
        virtual protected Int fProtected
        virtual internal  Int fInternal
                private   Int fPrivate   // can't mix virtual+private

        public            Int fPublicProtected { protected set }
        public            Int fPublicReadonly { private set }
        protected         Int fProtectedInternal { internal set }
      }

      virtual internal class InternalClass
      {
        Void m() {}
      }

      internal mixin InternalMixin
      {
        static Void x() { Public.msPublic; Public.msProtected; Public.msInternal }
      }
      ")

    p := pod.types[0]
    ic := pod.types[1]
    im := pod.types[2]

    // CheckInherit step
    verifyErrors(
     "using $p.pod.name

      class C00 : Public {}
      class C01 : InternalClass {}
      class C02 : InternalMixin {}
      mixin C03 : InternalMixin {}
      ",
    [
      4, 1, "Class 'C01' cannot access internal scoped class '$ic'",
      5, 1, "Type 'C02' cannot access internal scoped mixin '$im'",
      6, 1, "Type 'C03' cannot access internal scoped mixin '$im'",
    ])

    // Inherit step
    verifyErrors(
     "using $p.pod.name

      class C01 : Public { override Void figgle() {} }
      class C02 : Public { Str toStr() { return null } }
      class C03 : Public { override Void mPublic() {} }    // ok
      class C04 : Public { override Void mProtected() {} } // ok

      //class C05 : Public { override Void mInternal() {} }
      class C06 : Public { override Void mPrivate() {} }
      ",
    [
      3, 22, "Override of unknown virtual slot 'figgle'",
      4, 22, "Must specify override keyword to override 'sys::Obj.toStr'",

      // TODO: internal/privates never make it this far to tell you its a scope problem...
      //8, 22, "Override of unknown virtual slot 'mInternal'",
      9, 22, "Override of unknown virtual slot 'mPrivate'",
    ])

    // CheckErrors step
    verifyErrors(
     "using $p.pod.name

      class C04 : Public { Void f() { mPublic; x := fPublic } } // ok
      class C05 : Public { Void f() { mProtected; x := fProtected } } // ok
      class C06 { Void f(Public p) { p.mProtected  } }
      class C07 { Void f(Public p) { p.mInternal  } }
      class C08 { Void f(Public p) { p.mPrivate  } }
      class C09 { Void f() { Public.msProtected  } }
      class C10 { Void f() { Public.msInternal  } }
      class C11 { Void f() { Public.msPrivate  } }

      class C13 { Obj f(Public p) { return p.fPublic } } // ok
      class C14 : Public { Obj f(Public p) { return p.fProtected} } // ok
      class C15 { Obj f(Public p) { return p.fPublicProtected } } // ok
      class C16 { Obj f(Public p) { return p.fPublicReadonly } } // ok
      class C17 : Public { Obj f(Public p) { return p.fProtectedInternal } } // ok

      class C19 { Obj f(Public p) { return p.fProtected } }
      class C20 { Obj f(Public p) { return p.fProtectedInternal } }
      class C21 { Obj f(Public p) { return p.fInternal } }
      class C22 { Obj f(Public p) { return p.fPrivate } }

      class C24 { Void f(Public p) { p.fPublic = 7 } }  // ok
      class C25 : Public { Void f(Public p) { p.fProtected = 7 } } // ok
      class C26 : Public { Void f(Public p) { p.fPublicProtected = 7 } } // ok
      class C27 { Void f(Public p) { p.fProtected = 7 } }
      class C28 { Void f(Public p) { p.fInternal = 7 } }
      class C29 { Void f(Public p) { p.fPrivate = 7 } }
      class C30 { Void f(Public p) { p.fPublicProtected = 7; p.fPublicProtected++ } }
      class C31 { Void f(Public p) { p.fPublicReadonly = 7; p.fPublicReadonly++ } }
      class C32 : Public { Void f(Public p) { p.fProtectedInternal = 7; p.fProtectedInternal++ } }
      class C33 { Bool f(Obj o) { o is MemBuf } }
      class C34 { Bool f(Obj o) { o isnot MemBuf } }
      class C35 { Obj? f(Obj o) { o as MemBuf } }
      class C36 { Obj? f(Obj o) { return (MemBuf)o } }
      ",
    [
      5, 34, "Protected method '${p}.mProtected' not accessible",
      6, 34, "Internal method '${p}.mInternal' not accessible",
      7, 34, "Private method '${p}.mPrivate' not accessible",
      8, 31, "Protected method '${p}.msProtected' not accessible",
      9, 31, "Internal method '${p}.msInternal' not accessible",
     10, 31, "Private method '${p}.msPrivate' not accessible",

     18, 40, "Protected field '${p}.fProtected' not accessible",
     19, 40, "Protected field '${p}.fProtectedInternal' not accessible",
     20, 40, "Internal field '${p}.fInternal' not accessible",
     21, 40, "Private field '${p}.fPrivate' not accessible",

     26, 34, "Protected field '${p}.fProtected' not accessible",
     27, 34, "Internal field '${p}.fInternal' not accessible",
     28, 34, "Private field '${p}.fPrivate' not accessible",
     29, 34, "Protected setter of field '${p}.fPublicProtected' not accessible",
     29, 58, "Protected setter of field '${p}.fPublicProtected' not accessible",
     30, 34, "Private setter of field '${p}.fPublicReadonly' not accessible",
     30, 57, "Private setter of field '${p}.fPublicReadonly' not accessible",
     31, 43, "Internal setter of field '${p}.fProtectedInternal' not accessible",
     31, 69, "Internal setter of field '${p}.fProtectedInternal' not accessible",
     //32, 29, "Internal type 'sys::MemBuf' not accessible",
     //33, 29, "Internal type 'sys::MemBuf' not accessible",
     //34, 29, "Internal type 'sys::MemBuf' not accessible",
     //35, 36, "Internal type 'sys::MemBuf' not accessible",
    ]
    )
  }

  Void testClosureProtectionScopes()
  {
    // verify closure get access to external class privates
    compile(
     "class Foo : Goo
      {
        private static Int x() { return 'x' }
        static Int testX()
        {
          f := |->Int| { return x }
          return f.call
        }

        protected static Int y() { return 'y' }
        static Int testY()
        {
          f := |->Int|
          {
            g := |->Int| { return y  }
            return g.call
          }
          return f.call
        }

        static Int testZ()
        {
          f := |->Int| { return z }
          return f.call
        }
      }

      virtual class Goo
      {
        protected static Int z() { return 'z' }
      }")

     t := pod.types[1]
     verifyEq(t.name, "Foo")
     verifyEq(t.method("testX").call, 'x')
     verifyEq(t.method("testY").call, 'y')
     verifyEq(t.method("testZ").call, 'z')
  }

//////////////////////////////////////////////////////////////////////////
// Test Type Scopes
//////////////////////////////////////////////////////////////////////////

  Void testTypeProtectionScopes()
  {
    // first create a pod with internal types/slots
    compile(
     "internal class Foo
      {
        static const Int f
        static Void m() {}
      }
      ")
    p := pod

    verifyErrors(
     "using $p.name

      internal class Bar
      {
        Void m00() { echo(Foo.f) }
        Void m01() { Foo.m() }
        Void m02() { echo(Foo#) }
        Void m03() { echo(Foo#f) }
        Void m04() { echo(Foo#m) }

        Foo  m05() { throw Err() }
        Foo? m06() { throw Err() }
        |Foo x| m07() { throw Err() }
        |->Foo| m08() { throw Err() }

        Void m09(Foo p) {}
        Void m10(Foo? p) {}
        Void m11(Foo?[] p) {}
        Void m12(Str:Foo? p) {}
        Void m13(Foo:Str p) {}
        Void m14(|->Foo[]| p) {}

        Foo? f00
        Foo?[]? f01
      }
      ",
    [
       5, 25, "Internal field '$p::Foo.f' not accessible",
       6, 20, "Internal method '$p::Foo.m' not accessible",
       7, 21, "Internal type '$p::Foo' not accessible",
       8, 21, "Internal field '$p::Foo.f' not accessible",
       9, 21, "Internal method '$p::Foo.m' not accessible",

      11,  3, "Internal type '$p::Foo' not accessible",
      12,  3, "Internal type '$p::Foo' not accessible",
      13,  3, "Internal type '$p::Foo' not accessible",
      14,  3, "Internal type '$p::Foo' not accessible",

      16, 12, "Internal type '$p::Foo' not accessible",
      17, 12, "Internal type '$p::Foo' not accessible",
      18, 12, "Internal type '$p::Foo' not accessible",
      19, 12, "Internal type '$p::Foo' not accessible",
      20, 12, "Internal type '$p::Foo' not accessible",
      21, 12, "Internal type '$p::Foo' not accessible",

      23,  3, "Internal type '$p::Foo' not accessible",
      24,  3, "Internal type '$p::Foo' not accessible",
    ])
  }

//////////////////////////////////////////////////////////////////////////
// API Protection Scopes
//////////////////////////////////////////////////////////////////////////

  Void testApiProtectionScopes()
  {
    // errors
    verifyErrors(
     "class Bar : Foo, Goo
      {
        Foo? a() { return null }
        protected Void b(Str:Foo x) {}
        Foo? f
        protected Foo[]? g
        |Foo|? h
        |Str->Foo|? i
        internal Foo? ai(Foo x) { return null } // ok
        internal Foo? fi // ok
      }

      virtual internal class Foo {}
      internal mixin Goo {}",
       [
         3, 3, "Public method 'Bar.a' cannot use internal type '$podName::Foo?'",
         4, 3, "Public method 'Bar.b' cannot use internal type '",
         5, 3, "Public field 'Bar.f' cannot use internal type '$podName::Foo?'",
         6, 3, "Public field 'Bar.g' cannot use internal type '",
         7, 3, "Public field 'Bar.h' cannot use internal type '",
         8, 3, "Public field 'Bar.i' cannot use internal type '",
         1, 1, "Public type 'Bar' cannot extend from internal class 'Foo'",
         1, 1, "Public type 'Bar' cannot implement internal mixin 'Goo'",
       ])
  }


//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  Void testFieldFlags()
  {
    // parser stage
    verifyErrors(
     "abstract class Foo
      {
        private private Int f01
        Int f02 { override get { return f02 } }
        Int f03 { internal override get { return f03 } }
        Int f04 { override set {} }
      }
      ",
       [
         3,  11, "Repeated modifier",
         4,  13, "Cannot use modifiers on field getter",
         5,  13, "Cannot use modifiers on field getter",
         6,  13, "Cannot use modifiers on field setter except to narrow protection",
       ])

    // check errors stage
    verifyErrors(
     "abstract class Foo : Bar
      {
        // new Str f00 - parser actually catches this
        final Int f01
        native Int f02 // ok
        once Int f03

        public protected Int f04
        public private Int f05
        public internal Int f06
        protected private Int f07
        protected internal Int f08
        internal private Int f09

        Int f10 { public protected set {} }
        Int f11 { public private  set {} }
        Int f12 { public internal  set {} }
        Int f13 { protected private  set {} }
        Int f14 { protected internal  set {} }
        Int f15 { internal private  set {} }

        private Int f20 { public set {} }
        private Int f21 { protected set {} }
        private Int f22 { internal set {} }
        internal Int f23 { public set {} }
        internal Int f24 { protected set {} }
        protected Int f25 { public set {} }
        protected Int f26 { internal set {} } // ok

        const abstract Int f30
        //
        const virtual  Int f32

        virtual private Int f33

        native abstract Int f35
        const native Int f36
        native static Int f37
      }

      virtual class Bar
      {
        virtual Int f31
      }
      ",
       [
         4,  3, "Cannot use 'final' modifier on field",
         6,  3, "Cannot use 'once' modifier on field",

         8,  3, "Invalid combination of 'public' and 'protected' modifiers",
         9,  3, "Invalid combination of 'public' and 'private' modifiers",
        10,  3, "Invalid combination of 'public' and 'internal' modifiers",
        11,  3, "Invalid combination of 'protected' and 'private' modifiers",
        12,  3, "Invalid combination of 'protected' and 'internal' modifiers",
        13,  3, "Invalid combination of 'private' and 'internal' modifiers",

        15,  3, "Invalid combination of 'public' and 'protected' modifiers",
        16,  3, "Invalid combination of 'public' and 'private' modifiers",
        17,  3, "Invalid combination of 'public' and 'internal' modifiers",
        18,  3, "Invalid combination of 'protected' and 'private' modifiers",
        19,  3, "Invalid combination of 'protected' and 'internal' modifiers",
        20,  3, "Invalid combination of 'private' and 'internal' modifiers",

        22,  3, "Setter cannot have wider visibility than the field",
        23,  3, "Setter cannot have wider visibility than the field",
        24,  3, "Setter cannot have wider visibility than the field",
        25,  3, "Setter cannot have wider visibility than the field",
        26,  3, "Setter cannot have wider visibility than the field",
        27,  3, "Setter cannot have wider visibility than the field",

        30,  3, "Invalid combination of 'const' and 'abstract' modifiers",
        //30,  3, "Invalid combination of 'const' and 'override' modifiers", TODO
        32,  3, "Invalid combination of 'const' and 'virtual' modifiers",

        34,  3, "Invalid combination of 'private' and 'virtual' modifiers",

        36,  3, "Invalid combination of 'native' and 'abstract' modifiers",
        37,  3, "Invalid combination of 'native' and 'const' modifiers",
        38,  3, "Invalid combination of 'native' and 'static' modifiers",
        38,  3, "Static field 'f37' must be const",
       ])
  }

  Void testFields()
  {
    verifyErrors(
     "mixin MixIt
      {
        Str a
        virtual Int b
        abstract Int c { get { return &c } }
        abstract Int d { set { &d = it } }
        abstract Int e { get { return &e } set { &e = it } }
        const Int f := 3
        abstract Int g := 5
      }

      abstract class Foo
      {
        abstract Int c { get { return &c } }
        abstract Int d { set { &d = it } }
        abstract Int e { get { return &e } set { &e = it } }
        abstract Int f := 3
      }
      ",
       [
         3,  3, "Mixin field 'a' must be abstract",
         4,  3, "Mixin field 'b' must be abstract",
         5,  3, "Abstract field 'c' cannot have getter or setter",
         5, 33, "Field storage not accessible in mixin '$podName::MixIt.c'",
         6,  3, "Abstract field 'd' cannot have getter or setter",
         6, 26, "Field storage not accessible in mixin '$podName::MixIt.d'",
         7,  3, "Abstract field 'e' cannot have getter or setter",
         7, 33, "Field storage not accessible in mixin '$podName::MixIt.e'",
         7, 44, "Field storage not accessible in mixin '$podName::MixIt.e'",
         8,  3, "Mixin field 'f' must be abstract",
         9, 21, "Abstract field 'g' cannot have initializer",

        14,  3, "Abstract field 'c' cannot have getter or setter",
        15,  3, "Abstract field 'd' cannot have getter or setter",
        16,  3, "Abstract field 'e' cannot have getter or setter",
        17, 21, "Abstract field 'f' cannot have initializer",
       ])
  }

  Void testConst()
  {
    // Parser step
    verifyErrors(
     "const class Foo
      {
        const static Int a { get { return 3 } }
        const static Int b { set {  } }
        const static Int c { get { return 3 } set { } }

        const Int d { get { return 3 } }
        const Int e { set {  } }
        const Int f { get { return 3 } set { } }
      }
      ",
       [
         3, 24, "Const field 'a' cannot have getter",
         4, 24, "Const field 'b' cannot have setter",
         5, 24, "Const field 'c' cannot have getter",
         5, 41, "Const field 'c' cannot have setter",

         7, 17, "Const field 'd' cannot have getter",
         8, 17, "Const field 'e' cannot have setter",
         9, 17, "Const field 'f' cannot have getter",
         9, 34, "Const field 'f' cannot have setter",
       ])

    // CheckErrors step
    verifyErrors(
     "virtual const class Foo : Bar
      {
        static Int a := 3

        const static Int b := 3
        static { b = 5 }
        static Void goop() { b = 7; b += 3; b++ }

        //const static Int c { get { return 3 } }
        //const static Int d { set {  } }  // 10
        //const static Int e { get { return 3 } set { } }

        const Int f := 3
        new make() { f = 5 }
        Void wow() { f = 7; f++; }
        static Void bow(Foo o) { o.f = 9; o.f += 2 }

        //const Int g { get { return 3 } }
        //const Int h { set {  } }
        //const Int i { get { return 3 } set { } } // 20

        private Str? j
        private const StrBuf? k
        const Buf[]? l              // ok
        const [Str:Buf]? m          // ok
        const [Buf:Int]? n          // ok
        const [Num:Duration]? ok1   // ok
        const [Num:Str[][]]? ok2    // ok

        once Int p() { return 3 }  // 30
      }

      virtual class Bar {}
      class Roo : Foo {}
      enum class Boo { none;  private Int x }

      const class Outside : Foo
      {
        Void something() { f = 99 }
        static { b++ }  // 40
      }

      class With
      {
        static Foo fooFactory() { return Foo.make }
        static With withFactory() { return make }
        Obj a() { return Foo { it.f = 99 } }              // ok
        Obj b() { return Foo.make { it.f = 99 } }         // ok
        Obj c() { return With { it.xxx = [1,2] } }        // ok
        Obj d() { return make { it.xxx = [1,2] } }        // ok  line 50
        Obj e() { return fooFactory { it.f = 99 } }       // ok it-block
        Obj f() { return withFactory { it.xxx = [1,2] } } // ok it-block
        Obj g() { return make { it.xxx = [1,2] } }        // ok it-block
        Obj h(With s) { return s { it.xxx = [1,2] } }     // ok it-block
        Obj i() { return this { it.xxx = [1,2] } }        // ok it-block
        Obj j() { return make { it.goop = 99 } }
        static { Foo.b = 999 }

        const Int[] xxx := Int[,]
        static const Int goop := 9
      }

      const abstract class Ok
      {
        abstract Int a
        native Str b
        Int c { get { return 3 } set {} }
        static const Obj? d
        static const Obj[]? e
        static const [Obj:Obj]? f
      }
      ",
       [
         3,  3, "Static field 'a' must be const",

         7, 24, "Cannot set const static field 'b' outside of static initializer",
         7, 31, "Cannot set const static field 'b' outside of static initializer",
         7, 39, "Cannot set const static field 'b' outside of static initializer",

        15, 16, "Cannot set const field 'f' outside of constructor",
        15, 23, "Cannot set const field 'f' outside of constructor",
        16, 30, "Cannot set const field 'f' outside of constructor",
        16, 39, "Cannot set const field 'f' outside of constructor",

        23,  3, "Const field 'k' has non-const type 'sys::StrBuf?'",
        /*
        24,  3, "Const field 'l' has non-const type 'sys::Buf[]'",
        25,  3, "Const field 'm' has non-const type '[sys::Str:sys::Buf]'",
        26,  3, "Const field 'n' has non-const type '[sys::Buf:sys::Int]'",
        */

         1,  15, "Const type 'Foo' cannot subclass non-const class 'Bar'", // further tests in testConstInheritance
        22,  3, "Const type 'Foo' cannot contain non-const field 'j'",
        30,  3, "Const type 'Foo' cannot contain once method 'p'",

        34,  1, "Non-const type 'Roo' cannot subclass const class 'Foo'",
        35, 25, "Const type 'Boo' cannot contain non-const field 'x'",

        39, 22, "Cannot set const field '$podName::Foo.f'",
        40, 12, "Cannot set const field '$podName::Foo.b'",

        /* used to be prevented for with-block, before it-blocks
        51, 33, "Cannot set const field '$podName::Foo.f'",
        52, 34, "Cannot set const field 'xxx' outside of constructor",
        54, 30, "Cannot set const field 'xxx' outside of constructor",
        55, 27, "Cannot set const field 'xxx' outside of constructor",
        */
        57, 16, "Cannot set const field '$podName::Foo.b'",
        56, 30, "Cannot access static field 'goop' on instance",
        56, 30, "Cannot set const static field 'goop' outside of static initializer",
       ])
  }

  Void testFieldStorage()
  {
    verifyErrors(
     "class Foo : Root
      {
        Int m00() { return &r00 }
        Int m01() { return this.&r00 }

        Int f00 { get { return f00 } }
        Int f01 { set { f01 = it } }
        Int f02 { get { return f02 } set { f02 = it } }
        Int f03 { get { return f02 } set { this.f02 = it } }
        Int f04 { set { child.f04 = it } } // ok

        override Int r01 { set { &r01 = it } }
        Foo? child
      }

      mixin M
      {
        abstract Int x
        Void foo() { &x = 2 }
        Int bar() { &x }
      }

      class Root
      {
        Int r00
        virtual Int r01
      }

      ",
       [
         3, 22, "Field storage for '$podName::Root.r00' not accessible",
         4, 27, "Field storage for '$podName::Root.r00' not accessible",

         6, 26, "Cannot use field accessor inside accessor itself - use '&' operator",
         7, 19, "Cannot use field accessor inside accessor itself - use '&' operator",
         8, 26, "Cannot use field accessor inside accessor itself - use '&' operator",
         8, 38, "Cannot use field accessor inside accessor itself - use '&' operator",

        12, 28, "Field storage of inherited field '$podName::Root.r01' not accessible (might try super)",

        19, 16, "Field storage not accessible in mixin '$podName::M.x'",
        20, 15, "Field storage not accessible in mixin '$podName::M.x'",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  Void testMethodFlags()
  {
    // parser stage
    verifyErrors(
     "abstract class Foo
      {
        abstract internal abstract Void m01()
        abstract virtual Void m02()
        override virtual Void m03() {}
      }
      ",
       [
         3, 21, "Repeated modifier",
         4,  3, "Abstract implies virtual",
         5,  3, "Override implies virtual",
       ])

    // check errors stage
    verifyErrors(
     "abstract class Foo : Whatever
      {
        final Void m00() {}
        const Void m01() {}
        // readonly Void unused() {}

        public protected Void m10() {}
        public private Void m11() {}
        public internal Void m12() {}
        protected private Void m13() {}
        protected internal Void m14() {}
        internal private Void m15() {}

        new override m22() {}
        new virtual m23() {}
        abstract native Void m24()
        static abstract Void m25()
        static override Void m26() {}
        static virtual Void m27() {}

        private virtual Void m28() {}
      }

      abstract class Bar
      {
        new abstract m20 ()
        new native m21()

        new once m30() {}
        once static Int m31() { return 3 }
        abstract once Int m32()
      }

      abstract class Whatever
      {
        virtual Void m22() {}
        virtual Void m26() {}
      }

      mixin MixIt
      {
        once Int a() { return 3 }
      }

      ",
       [
         3,  3, "Cannot use 'final' modifier on method",
         4,  3, "Cannot use 'const' modifier on method",

         7,  3, "Invalid combination of 'public' and 'protected' modifiers",
         8,  3, "Invalid combination of 'public' and 'private' modifiers",
         9,  3, "Invalid combination of 'public' and 'internal' modifiers",
        10,  3, "Invalid combination of 'protected' and 'private' modifiers",
        11,  3, "Invalid combination of 'protected' and 'internal' modifiers",
        12,  3, "Invalid combination of 'private' and 'internal' modifiers",

        14,  3, "Invalid combination of 'new' and 'override' modifiers",
        15,  3, "Invalid combination of 'new' and 'virtual' modifiers",
        16,  3, "Invalid combination of 'abstract' and 'native' modifiers",
        17,  3, "Invalid combination of 'static' and 'abstract' modifiers",
        18,  3, "Invalid combination of 'static' and 'override' modifiers",
        19,  3, "Invalid combination of 'static' and 'virtual' modifiers",

        21,  3, "Invalid combination of 'private' and 'virtual' modifiers",

        26,  3, "Invalid combination of 'new' and 'abstract' modifiers",
        27,  3, "Invalid combination of 'new' and 'native' modifiers",

        29,  3, "Invalid combination of 'new' and 'once' modifiers",
        30,  3, "Invalid combination of 'static' and 'once' modifiers",
        31,  3, "Invalid combination of 'abstract' and 'once' modifiers",

        42,  3, "Mixins cannot have once methods",
       ])
  }

  Void testMethods()
  {
    // errors
    verifyErrors(
     "virtual class A { new make(Str n) {}  }
      virtual class B { private new make() {} }
      class C : A { }
      class D : B { }
      class E : A { new makeIt() {} }
      class F : B { new makeIt() {} }
      mixin G { new make() {} }
      class H { Void f(Int a := 3, Int b) {} }
      ",
       [
         3,  1, "Must call super class constructor in 'make'",
         4,  1, "Must call super class constructor in 'make'",
         5, 15, "Must call super class constructor in 'makeIt'",
         6, 15, "Must call super class constructor in 'makeIt'",
         7, 11, "Mixins cannot have instance constructors",
         8, 30, "Parameter 'b' must have default",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Mixin Natives
//////////////////////////////////////////////////////////////////////////

  Void testMixinNatives()
  {
    verifyErrors(
     "mixin Foo {
        native Int x()
        static native Int y()
      }",
       [
         2,  3, "Mixins cannot have native methods",
         3,  3, "Mixins cannot have native methods",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Statements
//////////////////////////////////////////////////////////////////////////

  Void testStmt()
  {
    // errors
    verifyErrors(
     "class Foo
      {
        static Obj m03() { if (0) return 1; return 2; }
        static Obj m04() { throw 3 }
        static Str m05() { return 6 }
        static Obj m06() { for (;\"x\";) m03(); return 2 }
        static Obj m07() { while (\"x\") m03(); return 2 }
        static Void m08() { break; continue }
        static Void m09() { Str x := 4.0f }
        static Void m10() { try { m03 } catch (Str x) {} }
        static Void m11() { try { m03 } catch (IOErr x) {} catch (IOErr x) {} }
        static Void m12() { try { m03 } catch (Err x) {} catch (IOErr x) {} }
        static Void m13() { try { m03 } catch (Err x) {} catch {} }
        static Void m14() { try { m03 } catch {} catch {} }
        static Void m15() { switch (Weekday.sun) { case 4: return } }
        static Void m16() { switch (2) { case 0: case 0: return } }
        static Void m17() { switch (Weekday.sun) { case Weekday.sun: return; case Weekday.sun: return } }

        static Void m19() { try { return } finally { return } }
        static Int m20() { try { return 1 } finally { return 2 } }
        static Obj m21() { try { try { return m03 } finally { return 8 } } finally { return 9 } }
        static Obj m22() { try { try { return m03 } finally { return 8 } } finally {} }
        static Obj m23() { try { try { return m03 } finally { } } finally { return 9 } }
        static Void m24() { while (true) { try { echo(3) } finally { break } } }
        static Void m25() { while (true) { try { echo(3) } finally { continue } } }
        static Void m26() { for (;;) { try { try { m03 } finally { break } } finally { continue } } }

        static Void m28() { try { } catch {} }

        Void m30() { return 6 }
        Obj m31() { return }
        Obj m32(Bool b) { if (b) return; else return }

        Obj m34(Obj? x) { x ?: throw \"x\" }
      }",
       [3, 26, "If condition must be Bool, not 'sys::Int'",
        4, 28, "Must throw Err, not 'sys::Int'",
        5, 29, "Cannot return 'sys::Int' as 'sys::Str'",
        6, 28, "For condition must be Bool, not 'sys::Str'",
        7, 29, "While condition must be Bool, not 'sys::Str'",
        8, 23, "Break outside of loop (break is implicit in switch)",
        8, 30, "Continue outside of loop",
        9, 32, "'sys::Float' is not assignable to 'sys::Str'",
        10, 42, "Must catch Err, not 'sys::Str'",
        11, 54, "Already caught 'sys::IOErr'",
        12, 52, "Already caught 'sys::IOErr'",
        13, 52, "Already caught 'sys::Err'",
        14, 44, "Already caught 'sys::Err'",
        15, 51, "Incomparable types 'sys::Int' and '",
        16, 49, "Duplicate case label",
        17, 85, "Duplicate case label",

        19, 48, "Cannot leave finally block",
        20, 49, "Cannot leave finally block",
        21, 57, "Cannot leave finally block",
        21, 80, "Cannot leave finally block",
        22, 57, "Cannot leave finally block",
        23, 71, "Cannot leave finally block",
        24, 64, "Cannot leave finally block",
        25, 64, "Cannot leave finally block",
        26, 62, "Cannot leave finally block",
        26, 82, "Cannot leave finally block",

        28, 23, "Try block cannot be empty",

        30, 16, "Cannot return a value from Void method",
        31, 15, "Must return a value from non-Void method",
        32, 28, "Must return a value from non-Void method",
        32, 41, "Must return a value from non-Void method",

        34, 32, "Must throw Err, not 'sys::Str'",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Expressions
//////////////////////////////////////////////////////////////////////////

  Void testExpr()
  {
    // errors
    verifyErrors(
     "class Foo
      {
        new make() { return }
        static Obj m00() { return 1f..2 }
        static Obj m01() { return 2..[,] }
        static Obj m02() { return !4 }
        static Obj m03() { return 4 && true }
        static Obj m04() { return 0ms || [,] }
        static Void m05(Str x) { x = true }
        Obj m06() { this.make }
        Obj m07() { this.m00 }
        static Void m08(Str x) { m07; Foo.m07() }
        Void m09(Str x) { this.sf.size }
        static Void m10(Str x) { f.size; Foo.f.size }
        static Void m11(Str x) { this.m06; super.hash() }
        static Obj m12(Str x) { return 1 ? 2 : 3 }
        static Bool m14(Str x, Duration y) { return x === y }
        static Bool m15(Str x, Duration y) { return x !== y }
        static Bool m16(Str x) { return x == m10(\"\") }
        static Bool m17(Str x) { return x != x.size }
        static Bool m18(Int x) { return x < 2f }
        static Bool m19(Int x) { return x <= Weekday.sun }
        static Bool m20(Int x) { return x > \"\" }
        static Bool m21(Int x) { return x >= m10(\"\") }
        static Int m22(Int x) { return x <=> 2f }
        static Obj m23(Str x) { return (Num)x }
        static Obj m24(Str x) { return x is Num}
        static Obj m25(Str x) { return x isnot Type }
        static Obj? m26(Str x) { return x as Num }
        static Obj m27() { return Bar.make }
        static Obj m28() { return \"x=\$v\" }
        static Obj? m29(Obj x) { return x as Foo? }
        static Obj? m30(Obj x) { return x as Str[]? }

        static Void v() {}

        Str? f
        const static Str? sf
      }

      abstract class Bar
      {
      }",
       [4, 29, "Range must be Int..Int, not 'sys::Float..sys::Int'",
        5, 29, "Range must be Int..Int, not '",
        6, 29, "Cannot apply '!' operator to 'sys::Int'",
        7, 29, "Cannot apply '&&' operator to 'sys::Int'",
        8, 29, "Cannot apply '||' operator to 'std::Duration'",
        8, 36, "Cannot apply '||' operator to '",
        9, 32, "'sys::Bool' is not assignable to 'sys::Str'",
       10, 20, "Cannot call constructor 'make' on instance",
       11, 20, "Cannot call static method 'm00' on instance",
       12, 28, "Cannot call instance method 'm07' in static context",
       12, 37, "Cannot call instance method 'm07' in static context",
       13, 26, "Cannot access static field 'sf' on instance",
       14, 28, "Cannot access instance field 'f' in static context",
       14, 40, "Cannot access instance field 'f' in static context",
       15, 28, "Cannot access 'this' in static context",
       15, 38, "Cannot access 'super' in static context",
       16, 34, "Ternary condition must be Bool, not 'sys::Int'",
       17, 47, "Incomparable types 'sys::Str' and 'std::Duration'",
       17, 47, "Cannot use '===' operator with value types",
       18, 47, "Incomparable types 'sys::Str' and 'std::Duration'",
       18, 47, "Cannot use '!==' operator with value types",
       19, 35, "Incomparable types 'sys::Str' and 'sys::Void'",
       20, 35, "Incomparable types 'sys::Str' and 'sys::Int'",
       21, 35, "Incomparable types 'sys::Int' and 'sys::Float'",
       22, 35, "Incomparable types 'sys::Int' and '",
       23, 35, "Incomparable types 'sys::Int' and 'sys::Str'",
       24, 35, "Incomparable types 'sys::Int' and 'sys::Void'",
       25, 34, "Incomparable types 'sys::Int' and 'sys::Float'",
       26, 34, "Inconvertible types 'sys::Str' and 'sys::Num'",
       27, 34, "Inconvertible types 'sys::Str' and 'sys::Num'",
       28, 34, "Inconvertible types 'sys::Str' and 'sys::Type'",
       29, 35, "Inconvertible types 'sys::Str' and 'sys::Num'",
       30, 33, "Calling constructor on abstract class",
       31, 29, "Invalid args plus(sys::Obj?), not (sys::Void)",
       32, 35, "Cannot use 'as' operator with nullable type '$podName::Foo?'",
       33, 35, "Cannot use 'as' operator with nullable type '",
    ])
  }

  Void testNotAssignable()
  {
    // errors
    verifyErrors(
     "class Foo
      {

        Void m00(Int a) { 3 = a }
        Void m01(Int a) { 3 += a }
        Void m02(Int a) { i = a }
        Void m03(Int a) { i += a }
        Void m04(Int a) { i++ }
        Void m05(Foo a) { this = a }
        //Void m06(Foo a) { super = a }
        Void m07(Foo a) { this += a }
        Void m08(Foo a) { this++ }

        Int i() { return 3 }
        @Operator Foo plus(Foo a) { return this }
        @Operator Int plusInt(Int x) { x }
        @Operator Int increment() { 3 }
      }",
       [
         4, 21, "Left hand side is not assignable",
         5, 21, "Target is not assignable",
         6, 21, "Left hand side is not assignable",
         7, 21, "Target is not assignable",
         8, 21, "Target is not assignable",
         9, 21, "Left hand side is not assignable",
        //10, 21, "Left hand side is not assignable",
        11, 21, "Target is not assignable",
        12, 21, "Target is not assignable",
        12, 21, "'sys::Int' is not assignable to '$podName::Foo'",
       ])
  }

  Void testInvalidArgs()
  {
    // errors
    verifyErrors(
     "class Foo
      {
        static Obj m00() { return 3.increment(true) }
        static Obj m01() { return 3.plus }
        static Obj m02() { return 3.plus(3ms) }
        static Obj m03() { return 3.plus(4, 5) }
        static Obj m04() { return sys::Str.spaces }
        static Obj m05() { return sys::Str.spaces(true) }
        static Obj m06() { return sys::Str.spaces(1, 2) }
        static Obj m07() { return \"abcb\".index(\"b\", true) }
        static Void m08() { m := |Int a| {}; m(3ms) }
        static Void m09() { m := |Str a| {}; m() }
      }",
       [3, 31, "Invalid args increment(), not (sys::Bool)",
        4, 31, "Invalid args plus(sys::Int), not ()",
        5, 31, "Invalid args plus(sys::Int), not (std::Duration)",
        6, 31, "Invalid args plus(sys::Int), not (sys::Int, sys::Int)",
        7, 38, "Invalid args spaces(sys::Int), not ()",
        8, 38, "Invalid args spaces(sys::Int), not (sys::Bool)",
        9, 38, "Invalid args spaces(sys::Int), not (sys::Int, sys::Int)",
       10, 36, "Invalid args index(sys::Str, sys::Int), not (sys::Str, sys::Bool)",
       11, 40, "Invalid args ",
       12, 40, "Invalid args ",
       ])
  }

  Void testExprInClosure()
  {
    // errors
    verifyErrors(
     "class Foo                                                // 1
      {                                                        // 2
        Void m00a() { |->| { x := this.make }.call }           // 3
        Void m00b() { |->| { |->| { x := this.make }.call }.call } // 4
        Void m01a() { |->| { this.m02a }.call }                // 5
        Void m01b() { |->| { |->| { this.m02a }.call }.call }  // 6
        static Void m02a() { |->| { m00a; Foo.m00a() }.call }  // 7
        static Void m02b() { |->| { |->| { m00a; Foo.m00a() }.call }.call } // 8
        Void m03a(Str x) { |->| { this.sf.size }.call }        // 9
        Void m03b(Str x) { |->| { |->| { this.sf.size }.call }.call } // 10
        static Void m04a(Str x) { |->| { f.size; Foo.f.size }.call }
        static Void m04b(Str x) { |->| { |->| { f.size; Foo.f.size }.call }.call }

        Str? f
        const static Str? sf
      }",

       [3, 34, "Cannot call constructor 'make' on instance",
        4, 41, "Cannot call constructor 'make' on instance",
        5, 29, "Cannot call static method 'm02a' on instance",
        6, 36, "Cannot call static method 'm02a' on instance",
        7, 31, "Cannot call instance method 'm00a' in static context",
        7, 41, "Cannot call instance method 'm00a' in static context",
        8, 38, "Cannot call instance method 'm00a' in static context",
        8, 48, "Cannot call instance method 'm00a' in static context",
        9, 34, "Cannot access static field 'sf' on instance",
       10, 41, "Cannot access static field 'sf' on instance",
       11, 36, "Cannot access instance field 'f' in static context",
       11, 48, "Cannot access instance field 'f' in static context",
       12, 43, "Cannot access instance field 'f' in static context",
       12, 55, "Cannot access instance field 'f' in static context",
       ])
  }

  Void testAbstractSupers()
  {
    verifyErrors(
     "class Foo : Base, A
      {
        override Int x { get { return super.x } set { A.super.x = it } }
        override Void n() { super.n }
        override Void m() { A.super.m() }
      }

      abstract class Base
      {
        abstract Int x
        abstract Void n()
      }

      mixin A
      {
        abstract Int x
        abstract Void m()
      }
      ",
       [
         3, 33, "Cannot use super to access abstract field '$podName::Base.x'",
         3, 49, "Cannot use super to access abstract field '$podName::A.x'",
         4, 23, "Cannot use super to call abstract method '$podName::Base.n'",
         5, 23, "Cannot use super to call abstract method '$podName::A.m'",
       ])
  }

  Void testSupersWithDef()
  {
    // verify don't call super with default parameters
    // otherwise you get stack overflow
    verifyErrors(
     "class Foo : Base, A
      {
        override Void b(Int a := 0, Int b:= 1) { super.b }
        override Void a(Str a, Str? b := null) { A.super.a(a) }
        Void c() { super.b(3) } // ok
        Void d() { A.super.a(\"x\") } // ok
      }

      abstract class Base
      {
        virtual Void b(Int a := 0, Int b := 1) {}
      }

      mixin A
      {
        virtual Void a(Str a, Str? b := null) {}
      }
      ",
       [
         3, 44, "Must call super method '$podName::Base.b' with exactly 2 arguments",
         4, 44, "Must call super method '$podName::A.a' with exactly 2 arguments",
       ])
  }

  Void testNotStmt()
  {
    // Parser level errors
    verifyErrors(
     "class Foo
      {
        Void x(Int i, Str s, Obj o)
        {
          i + Int;
        }
      }",
       [5, 9, "Unexpected type literal",])

    // CheckErrors level errors
    verifyErrors(
     "class Foo
      {
        Void x(Int i, Str s, Obj o)
        {
          true;               // 5
          3;                  // 6
          i + 2;              // 7
          f;                  // 8
          this.f;             // 9
          (Int)o;             // 10
          o is Int;           // 11
          o as Int;           // 12
          i == 4 ? 0ms : 1ms; // 13
          |->| {}             // 14
          i == 2;             // 15
          s === o;            // 16
          Foo()               // 17
          Foo() {}            // 18
          Foo {}              // 19
        }

        Int f
      }",

       [
         5,  5, "Not a statement",
         6,  5, "Not a statement",
         7,  5, "Not a statement",
         8,  5, "Not a statement",
         9, 10, "Not a statement",
        10,  5, "Not a statement",
        11,  5, "Not a statement",
        12,  5, "Not a statement",
        13,  5, "Not a statement",
        14,  5, "Not a statement",
        15,  5, "Not a statement",
        16,  5, "Not a statement",
        17,  5, "Not a statement",
        18, 11, "Not a statement",
        19,  9, "Not a statement",
       ])
  }

  Void testSafeNav()
  {
    verifyErrors(
     "class Foo
      {
        Void func()
        {
          x?.i = 5
          x?.x.i = 5
          x?.x?.i = 5
          y()?.i = 5
          x?.i += 5
          nn?.y
          temp := nn?.i
          foo1 := x ?: 5 // ok
          foo2 := nn ?: 5 // not-ok
          int1 := 5; int2 := int1 ?: 7
        }

        static Foo someFoo() { throw Err() }

        Foo? y() { return this }
        Foo? get(Int x) { return null }
        Void set(Int x, Int y) {}
        Foo? x
        Foo nn := someFoo()
        Int i
      }",

       [
         5,  8, "Null-safe operator on left hand side of assignment",
         6, 10, "Non-null safe field access chained after null safe call",
         6,  8, "Null-safe operator on left hand side of assignment",
         7, 11, "Null-safe operator on left hand side of assignment",
         7,  8, "Null-safe operator on left hand side of assignment",
         8, 10, "Null-safe operator on left hand side of assignment",
         9,  8, "Null-safe operator on left hand side of assignment",
         9,  8, "Non-null safe call chained after null safe call",
        10,  5, "Cannot use null-safe call on non-nullable type '$podName::Foo'",
        11, 13, "Cannot use null-safe access on non-nullable type '$podName::Foo'",
        13, 13, "Cannot use '?:' operator on non-nullable type '$podName::Foo'",
        14, 24, "Cannot use '?:' operator on non-nullable type 'sys::Int'",
       ])
  }

  Void testSafeNavChaining()
  {
    verifyErrors(
     """class Foo
        {
          Void func(Str? x)
          {
            x?.size.toHex
            x?.size->toHex
            x?->size.toStr
            x?->size->toStr
            x?.size?.toHex   // ok
            x?.size?.toHex.hash
            x?.size?.toHex?.hash.toStr.size
            y := foo?.foo.foo
            foo?.foo.toStr

            Uri? uri := null
            echo(uri?.query["x"])
          }
          Foo? foo
          Uri? list
        }""",

       [
          5, 13, "Non-null safe call chained after null safe call",
          6, 14, "Non-null safe call chained after null safe call",
          7, 14, "Non-null safe call chained after null safe call",
          8, 15, "Non-null safe call chained after null safe call",
         10, 20, "Non-null safe call chained after null safe call",
         11, 26, "Non-null safe call chained after null safe call",
         12, 19, "Non-null safe field access chained after null safe call",
         13, 14, "Non-null safe call chained after null safe call",
         16, 20, "Non-null safe call chained after null safe call",
       ])
  }

  Void testAlwaysNullable()
  {
    // errors
    verifyErrors(
     "class Foo
      {
        Int m00() { return null }
        Void m01(Obj x) { x = null }
        Void m02() { Int x := null }
        Void m03() { m01(null) }
        Str m04(Obj? x) { x?.toStr }
        Str m05(Obj? x) { x?->toStr }
        Str m06(Obj? x) { x as Str }
        Int m07(Foo? x) { x?.f }

        Int f
      }",
       [
         3, 22, "Cannot return 'null' as 'sys::Int'",
         4, 25, "'null' is not assignable to 'sys::Obj'",
         5, 25, "'null' is not assignable to 'sys::Int'",
         6, 16, "Invalid args m01(sys::Obj), not (null)",
         7, 24, "Cannot return 'sys::Str?' as 'sys::Str'",
         8, 25, "Cannot return 'sys::Obj?' as 'sys::Str'",
         9, 21, "Cannot return 'sys::Str?' as 'sys::Str'",
        10, 24, "Cannot return 'sys::Int?' as 'sys::Int'",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Collection Literals
//////////////////////////////////////////////////////////////////////////

  Void testListLiterals()
  {
    // errors
    verifyErrors(
     "class Foo
      {
        Obj m00() { return [3] }    // ok
        Obj m01() { return [null] } // ok
        Obj m02() { return Num[\"x\", 4ms, 6] }
        Obj m03() { return Num[null] }
        Obj m04() { return Int[][ [3], [3d] ] }
      }",
       [
         5, 26, "Invalid value type 'sys::Str' for list of 'sys::Num'",
         5, 31, "Invalid value type 'std::Duration' for list of 'sys::Num'",
         6, 26, "Invalid value type 'null' for list of 'sys::Num'",
         7, 34, "Invalid value type '",
       ])
  }

  Void testMapLiterals()
  {
    // errors
    verifyErrors(
     "class Foo
      {
        Obj m00() { return Int:Num[3:2ms, 2ms:5, 2ms:2ms] }
        Obj m01() { return Int:Int[null:2, 3:null] }
      }",
       [
         3, 32, "Invalid value type 'std::Duration' for map type '",
         3, 37, "Invalid key type 'std::Duration' for map type '",
         3, 44, "Invalid key type 'std::Duration' for map type '",
         3, 48, "Invalid value type 'std::Duration' for map type '",
         4, 30, "Invalid key type 'null' for map type '",
         4, 40, "Invalid value type 'null' for map type '",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Value Types
//////////////////////////////////////////////////////////////////////////

  Void testValueTypes()
  {
    // errors
    verifyErrors(
     "class Foo
      {
        Int m00() { return (Int)(Obj)5ms } // ok - runtime failure
        Float? m01() { return (Float?)(Obj)5ms } // ok - runtime failure
        Bool m02() { return m00 === 0  }
        Bool m03() { return 2f !== m01  }
      }",
       [
         5, 23, "Cannot use '===' operator with value types",
         6, 23, "Cannot use '!==' operator with value types",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Func Auto Casting
//////////////////////////////////////////////////////////////////////////

  Void testFuncAutoCasting()
  {
    // test functions which should work
    compile(
      "class Foo
       {
         static Num a(Num a, Num b, |Num a, Num b->Num| f) { return f(a, b) }
         // diff return types
         static Int a01() { return a(1,5) |Num a, Num b->Num?| { return a.toInt+b.toInt } }
         static Int a02() { return a(1,6) |Num a, Num b->Int|  { return a.toInt+b.toInt } }
         static Int a03() { return a(1,7) |Num a, Num b->Obj?| { return a.toInt+b.toInt } }
         // diff parameter types
         static Int a04() { return a(1,9)  |Int a, Num b->Int|  { return a+b.toInt } }
         static Int a05() { return a(1,10) |Num a, Int b->Obj|  { return a.toInt+b } }
         static Int a06() { return a(1,11) |Int? a, Int b->Num| { return a+b } }
         static Int a07() { return a(1,12) |Obj a, Obj? b->Obj| { return (Int)a + (Int)b } }
         // diff arity
         static Int a08() { return a(14,1) |Num? a->Int| { return a.toInt*2 } }
         static Int a09() { return a(15,1) |Int a->Int| { return a*2 } }
         static Int a10() { return a(16,1) |Obj a->Int| { return (Int)a*2 } }
       }")
    obj := pod.types.first.make
    verifyEq(obj->a01, 6)
    verifyEq(obj->a02, 7)
    verifyEq(obj->a03, 8)
    verifyEq(obj->a04, 10)
    verifyEq(obj->a05, 11)
    verifyEq(obj->a06, 12)
    verifyEq(obj->a07, 13)
    verifyEq(obj->a08, 28)
    verifyEq(obj->a09, 30)
    verifyEq(obj->a10, 32)

    // errors
    verifyErrors(
     "class Foo
      {
         static Num a(|Num a, Num b->Num| f) { return f(3, 4) }
         // diff return types
         static Int a05() { return a |Num a, Num b->Str| { return a.toStr  } }
         // wrong arity
         static Int a07() { return a |Num a, Num b, Num c->Num| { return a.toInt  } }
         // wrong params
         static Int a09() { return a |Str a, Num b, Num c->Num| { return a.toInt  } }
         static Int a10() { return a |Num a, Str? b, Num c->Num| { return a.toInt  } }
         static Int a11() { return a |Str a, Str b, Str c->Num| { return a.toInt  } }

         static Void b(| |Num[] x| y |? f) {}
         // diff return types
         static Void b15() { b | |Num[] x| y | {}  }        // ok
         static Void b16() { b | |Int[] x| y | {}  }        // ok
         static Void b17() { b | |Obj[] x| y | {}  }        // ok
         static Void b18() { b | |Num[] x->Str| y | {}  }   // ok
         static Void b19() { b | |Str[] x| y | {}  }        // wrong params
         static Void b20() { b | |Num[] x| y, Obj o| {}  } // wrong arity
      }",
       [
         5, 30, "Invalid args a(sys::Func<sys::Num,sys::Num,sys::Num>), not (sys::Func<sys::Str,sys::Num,sys::Num>)",
         7, 30, "Invalid args a(sys::Func<sys::Num,sys::Num,sys::Num>), not (sys::Func<sys::Num,sys::Num,sys::Num,sys::Num>)",
         9, 30, "Invalid args a(sys::Func<sys::Num,sys::Num,sys::Num>), not (sys::Func<sys::Num,sys::Str,sys::Num,sys::Num>)",
        10, 30, "Invalid args a(sys::Func<sys::Num,sys::Num,sys::Num>), not (sys::Func<sys::Num,sys::Num,sys::Str?,sys::Num>)",
        11, 30, "Invalid args a(sys::Func<sys::Num,sys::Num,sys::Num>), not (sys::Func<sys::Num,sys::Str,sys::Str,sys::Str>)",
        19, 24, "Invalid args b(sys::Func<sys::Void,sys::Func<sys::Void,sys::List<sys::Num>>>?), not (sys::Func<sys::Void,sys::Func<sys::Void,sys::List<sys::Str>>>)",
        20, 24, "Invalid args b(sys::Func<sys::Void,sys::Func<sys::Void,sys::List<sys::Num>>>?), not (sys::Func<sys::Void,sys::Func<sys::Void,sys::List<sys::Num>>,sys::Obj>)",
       ])

  }

//////////////////////////////////////////////////////////////////////////
// Self Assignment
//////////////////////////////////////////////////////////////////////////

  Void testSelfAssignment()
  {
    verifyErrors(
      "class Foo
       {
         Void m03() { x := 7; x = x }
         Void m04() { f = f }
         Void m05() { f = this.f }
         Void m06() { this.f = f }
         Void m07() { this.f = this.f }
         Void m08() { foo.f = foo.f }
         Void m09() { foo.f = this.foo.f }
         Obj m10(Int f) { Foo { f = f } }
         Obj m11(Int f) { Foo { it.f = it.f } }
         Obj m12(Int f) { Foo { this.f = this.f } }

         const static Str bar := Foo.bar

         Void ok01(Foo foo) { this.foo = foo }
         Void ok03(Foo x) { f = x.f }
         Void ok04(Foo x) { foo.f = x.foo.f }
         Void ok05() { Obj a := 1; [2].each |Obj b| { a = b } } // ok
         Obj ok06(Int f) { Foo { it.f = f } }
         Obj ok07(Int f) { Foo { it.f = this.f } }
         Obj ok08(Int f) { Foo { this.f = it.f } }
         Obj ok09(Int f) { Foo { this.f = f } }
         Obj ok10(Int f) { Foo { f = it.f } }
         Obj ok11(Int f) { Foo { f = this.f } }


         Int f
         Foo? foo
       }",
       [
         3, 24, "Self assignment",
         4, 16, "Self assignment",
         5, 16, "Self assignment",
         6, 21, "Self assignment",
         7, 21, "Self assignment",
         8, 20, "Self assignment",
         9, 20, "Self assignment",
        14, 3,  "Self assignment",
        10, 26, "Self assignment",
        11, 29, "Self assignment",
        12, 31, "Self assignment",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Valid Types
//////////////////////////////////////////////////////////////////////////

  Void testValidTypes()
  {
    // Normalize (fields check before getter/setter generated)
    verifyErrors(
      "class Foo
       {
         Void f03
         This f04
         Void[] f05
         This[]? f06
         Void:Obj f07
         [Obj:This]? f08
         |This|? f09
         |->This| f10
         |Void| f11
         |Obj,Void| f12
         |->This[]?| f13
       }",
       [
         3, 3, "Cannot use Void as field type",
         4, 3, "Cannot use This as field type",
         5, 3, "Invalid type 'sys::List<sys::Void>'",
         6, 3, "Invalid type 'sys::List<sys::This>?'",
         7, 3, "Invalid type 'std::Map<sys::Void,sys::Obj>'",
         8, 3, "Invalid type 'std::Map<sys::Obj,sys::This>?'",
         9, 3, "Invalid type 'sys::Func<sys::Void,sys::This>?'",
         10, 3, "Invalid type 'sys::Func<sys::This>'",
         11, 3, "Invalid type 'sys::Func<sys::Void,sys::Void>'",
         12, 3, "Invalid type 'sys::Func<sys::Void,sys::Obj,sys::Void>'",
         13, 3, "Invalid type 'sys::Func<sys::List<sys::This>?>'",
       ])

    // CheckErrors
    verifyErrors(
      "class Foo
       {
         Void[]? m03() { throw Err() }
         |This| m04() { throw Err() }
         Void m05(Void a) { }
         Void m06(This a) { }
         Void m07(Void? a) { }
         Void m08(This? a) { }
         Void m09(|->This|? a) {}
         Str m10() { Void? x; return x.toStr }
         Str m11() { This? x; return x.toStr }
         Str m12() { Void[]? x; return x.toStr }
         Str m13() { |This|? x; return x.toStr }
       }",
       [
         3, 3,  "Invalid type",
         4, 3,  "Invalid type",
         5, 12, "Cannot use Void as parameter type",
         6, 12, "Cannot use This as parameter type",
         7, 12, "Cannot use Void as parameter type",
         8, 12, "Cannot use This as parameter type",
         9, 12, "Invalid type",
        10, 15, "'null' is not assignable to 'sys::Void?'",
        10, 15, "Cannot use Void as local variable type",
        10, 33, "Cannot call method on Void",
        11, 15, "Cannot use This as local variable type",
        12, 15, "Invalid type",
        13, 15, "Invalid type",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Non-Null Definite Assignment
//////////////////////////////////////////////////////////////////////////

  Void testDefiniteAssign()
  {
    verifyErrors(
      "abstract class Foo : Bar
       {
         new make()
         {
           ok02 = s
         }

         new make2()
         {
           ok02 = bad01 = s
         }

         new make3() : this.make() {}

         Str bad01
         virtual Str bad02

         Str ok00 := s        // init
         Int ok01             // value type
         Str ok02             // in ctor
         abstract Str ok03    // abstract
         override Str ok04    // override
         Str ok05 { get { s } set { } } // calculated
         Str? ok06            // nullable

         const static Str s := \"x\"
         const static Bool b
         const static Str sBad01
         const static Str sBad02; static { if (b) sBad02 = s }
         const static Str sOk00 := s
         const static Str sOk01; static { if (b) sOk01 = s; else sOk01 = s }
       }

       class Bar
       {
         virtual Str ok04 := \"ok\"
       }",
       [
         3, 3, "Non-nullable field 'bad01' must be assigned in constructor 'make'",
         3, 3, "Non-nullable field 'bad02' must be assigned in constructor 'make'",
         8, 3, "Non-nullable field 'bad02' must be assigned in constructor 'make2'",
        28, 3, "Non-nullable field 'sBad01' must be assigned in static initializer",
        29, 3, "Non-nullable field 'sBad02' must be assigned in static initializer",
       ])
  }

  Void testDefiniteAssignStmts()
  {
    verifyErrors(
    """abstract class Foo
       {
         new m01() // ok
         {
           try { x = s } catch (IOErr e) { x = s } catch (CastErr e) { x = s }
         }

         new m02() // not ok
         {
           try { x = s } catch (IOErr e) { foo } catch (CastErr e) { x = s }
         }

         new m03() // not ok
         {
           try { foo }  catch (IOErr e) { foo }
         }

         new m04() { if (foo) x = s; else x = s } // ok

         new m05() { if (foo) x = s; else foo } // not ok

         new m06() { foo(x = s) } // ok

         new m07() { while (foo) x = s } // not-ok

         new m08() { while ((x = s).isEmpty) foo } // ok

         new m09(Int i)  // ok
         {
           switch(i) { case 0: x = s; default: x = s; }
         }

         new m10(Int i)  // not-ok
         {
           switch(i) { case 0: x = s; case 1: x = s; }
         }

         new m11(Int i)  // not-ok
         {
           switch(i) { case 0: x = s; default: foo; }
         }

         new m12(Int i)  // not-ok
         {
           switch(i) { case 0: x = s; case 1: foo; default: x = s; }
         }

         new m13() // ok
         {
           try { x = s } catch (IOErr e) { throw e }
         }

         new m14(Int v) // ok
         {
           if (v == 0) x = ""
           else throw Err()
         }

         static Bool foo(Str y := s) { false }
         const static Str s := \"x\"
         Str x
       }

       class Bar
       {
         virtual Str ok04 := \"ok\"
       }""",
       [
         8, 3, "Non-nullable field 'x' must be assigned in constructor 'm02'",
         13, 3, "Non-nullable field 'x' must be assigned in constructor 'm03'",
         20, 3, "Non-nullable field 'x' must be assigned in constructor 'm05'",
         24, 3, "Non-nullable field 'x' must be assigned in constructor 'm07'",
         33, 3, "Non-nullable field 'x' must be assigned in constructor 'm10'",
         38, 3, "Non-nullable field 'x' must be assigned in constructor 'm11'",
         43, 3, "Non-nullable field 'x' must be assigned in constructor 'm12'",
       ])
  }

  Void testDefiniteAssignInClosures()
  {
    compile(
     """class Foo
        {
          new make(Bool c) { f := |->| { x = "ok" }; if (c) f(); }
          Str x
        }""")

     t := pod.types.first
     verifyEq(t.make([true])->x, "ok")
     verifyErr(FieldNotSetErr#) { t.make([false]) }
  }

//////////////////////////////////////////////////////////////////////////
// Operators
//////////////////////////////////////////////////////////////////////////

  Void testOperators()
  {
    verifyErrors(
      "class Foo
       {
         @Operator Int plu03() { 5 }
         @Operator Void plusFoo(Int x) { }
         @Operator Foo negate(Int x) { this }
         @Operator Int plus06() { 5 }
         @Operator Int minus07(Int x, Int y) { 5 }
         @Operator Foo get08() { this }
         @Operator Void set(Int x) { }
         @Operator Void setFoo(Int x, Int y) { }
         @Operator Int get11(Int x, Int y := 0) { y } // ok
         @Operator Foo add(Obj x) { this }
       }",
       [
         3, 3,  "Operator method 'plu03' has invalid name",
         4, 3,  "Operator method 'plusFoo' cannot return Void",
         5, 3,  "Operator method 'negate' has wrong number of parameters",
         6, 3,  "Operator method 'plus06' has wrong number of parameters",
         7, 3,  "Operator method 'minus07' has wrong number of parameters",
         8, 3,  "Operator method 'get08' has wrong number of parameters",
         9, 3,  "Operator method 'set' has wrong number of parameters",
        10, 3,  "Operator method 'setFoo' has invalid name",
        12, 3,  "Operator method 'add' must return This",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Null Compares
//////////////////////////////////////////////////////////////////////////

  Void testNullCompares()
  {
    verifyErrors(
      "class Foo
       {
         new make(Foo foo, |This| f)
         {
           if (s != null) return  // line 5 ok
           if (ni != null) return // line 6 ok
           if (j != null) return  // line 7 not ok
           if (this.f != null) return  // line 8 not ok
           if (foo.s != null) return  // line 9 not okay
           if (Env.cur.homeDir == null) return // 10 not okay
           x := s
           if (x != null) return // not okay
         }

         Void foo()
         {
           if (s != null) return // not okay
         }

         const Str s
         const Int? ni
         const Int j
         const Float f
       }",
       [
         7,  9, "Comparison of non-nullable type 'sys::Int' to null",
         8, 14, "Comparison of non-nullable type 'sys::Float' to null",
         9, 13, "Comparison of non-nullable type 'sys::Str' to null",
        10, 17, "Comparison of non-nullable type 'std::File' to null",
        12,  9, "Comparison of non-nullable type 'sys::Str' to null",
        17,  9, "Comparison of non-nullable type 'sys::Str' to null",
       ])
  }

  Void testStruct()
  {
    verifyErrors(
       """struct class Bar {
            Str x := "hi"
          }

          struct class Bar2 {
            readonly Str x := "hi"
            new make(|This|? f := null) { f?.call(this) }
          }

          class Main {
            Void main() {
              b2 := Bar2 { x = "" }
              echo(b2)
            }
          }
          """,
       [
         2,  3, "Struct type 'Bar' cannot contain non-readonly field 'x'",
         12, 18, "Cannot set struct field '",
       ])
  }

}

