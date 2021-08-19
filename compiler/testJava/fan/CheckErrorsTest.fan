//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Nov 08  Brian Frank  Creation
//

**
** CheckErrorsTest
**
class CheckErrorsTest : JavaTest
{

//////////////////////////////////////////////////////////////////////////
// Calls
//////////////////////////////////////////////////////////////////////////

  Void testCalls()
  {
    // ResolveExpr step
    verifyErrors(
     "using [java] java.lang
      using [java] fanx.test
      class Foo
      {
        // invalid arguments
        static Void m00() { System.getProperty() }
        static Void m01() { System.getProperty(\"foo\", \"bar\", 4) }
        static Void m02() { System.getProperty(\"foo\", 4) }
        static System? m03() { m03.getProperty(\"foo\"); return null }

        // ambiguous calls
        static Void m04() { InteropTest().ambiguous1(3, 4) }
        static Void m05() { InteropTest().ambiguous2(null) }
      }
      ",
       [
          6, 30, "Invalid args getProperty()",
          7, 30, "Invalid args getProperty(sys::Str, sys::Str, sys::Int)",
          8, 30, "Invalid args getProperty(sys::Str, sys::Int)",
         12, 37, "Ambiguous call ambiguous1(sys::Int, sys::Int)",
         13, 37, "Ambiguous call ambiguous2(null)",
       ])

    // CheckErrors step
    verifyErrors(
     "using [java] java.lang
      using [java] java.util
      class Foo
      {
        static System? m00() { m00.getProperty(\"foo\"); return null }
        static Void m01() { Observable().setChanged }
      }
      ",
       [
          5, 30, "Cannot call static method 'getProperty' on instance",
          6, 36, "Protected method '[java]java.util::Observable.setChanged' not accessible",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Multi-dimensional Arrays
//////////////////////////////////////////////////////////////////////////

  Void testMultiDimArrays()
  {
    verifyErrors(
     "using [java] fanx.test
      class Foo
      {
        static Void m00() { v := InteropTest().dateMulti2() }
        static Void m01() { v := InteropTest().dateMulti3 }
        static Void m02() { v := InteropTest().strMulti2() }
        static Void m03() { v := InteropTest().strMulti3 }
        static Void m04() { v := InteropTest().intMulti2() }
        static Void m05() { v := InteropTest().intMulti3 }
        static Void m06() { v := InteropTest().doubleMulti2() }
        static Void m07() { v := InteropTest().doubleMulti3 }
      }
      ",
       [
          4, 42, "Method 'dateMulti2' uses unsupported type '[java]java.util::[[Date?'",
          5, 42, "Field 'dateMulti3' has unsupported type '[java]java.util::[[[Date?'",
          6, 42, "Method 'strMulti2' uses unsupported type '[java]java.lang::[[String?'",
          7, 42, "Field 'strMulti3' has unsupported type '[java]java.lang::[[[String?'",
          8, 42, "Method 'intMulti2' uses unsupported type '[java]::[[int?'",
          9, 42, "Field 'intMulti3' has unsupported type '[java]::[[[int?'",
         10, 42, "Method 'doubleMulti2' uses unsupported type '[java]::[[double?'",
         11, 42, "Field 'doubleMulti3' has unsupported type '[java]::[[[double?'",
       ])
   }

//////////////////////////////////////////////////////////////////////////
// ClassDef
//////////////////////////////////////////////////////////////////////////

  Void testClassDef()
  {
    verifyErrors(
     "using [java] java.util
      class Foo : Observer, Observable {}
      ",
       [
          2, 1, "Invalid inheritance order, ensure class '[java]java.util::Observable' comes first before mixins",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Abstract ClassDef
//////////////////////////////////////////////////////////////////////////

  Void testAbstractClassDef()
  {
    verifyErrors(
     "using [java] java.util
      class Foo : Observer {}
      abstract class Bar: Observer {} // ok
      ",
       [
          2, 1, "Class 'Foo' must be abstract since it inherits but doesn't override '[java]java.util::Observer.update'",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Constructors
//////////////////////////////////////////////////////////////////////////

  Void testCtors()
  {
    verifyErrors(
     "using [java] java.util::Date as JDate
      class Foo : JDate
      {
        new make() : super() {}
        new makeFoo() : this.make() {}
      }
      ",
       [
          5, 19, "Must use super constructor call in Java FFI",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Subclass
//////////////////////////////////////////////////////////////////////////

  Void testSubclass()
  {
    verifyErrors(
     "using [java] java.util::Date as JDate
      using [java] fanx.interop::IntArray as JIntArray
      virtual class Foo : JDate
      {
        new makeA() : super() {}
        new makeB() : super() {}
        new makeC(Int a) : super() {}
        new makeD(Int a) : super() {}
        new makeE(Int a) : super() {}
      }

      virtual class Foo1 : Foo
      {
        new make() : super.makeA() {}
      }

      class Foo2 : Foo1
      {
        new make() : super.make() {}
      }

      class Foo3 : JIntArray
      {
        new ctor() {}
      }
      ",
       [
          6, 3, "Duplicate Java FFI constructor signatures: 'makeA' and 'makeB'",
          8, 3, "Duplicate Java FFI constructor signatures: 'makeC' and 'makeD'",
          9, 3, "Duplicate Java FFI constructor signatures: 'makeC' and 'makeE'",
          9, 3, "Duplicate Java FFI constructor signatures: 'makeD' and 'makeE'",
         12, 9, "Cannot subclass Java class more than one level: [java]java.util::Date",
         17, 1, "Cannot subclass Java class more than one level: [java]java.util::Date",
         22, 1, "Cannot subclass from Java interop array: [java]fanx.interop::IntArray",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Abstract Overloads
//////////////////////////////////////////////////////////////////////////

  Void testAbstractOverloads()
  {
    // Inherit
    verifyErrors(
     "using [java] fanx.test::InteropTest\$AbstractOverloadsClass as OverloadsClass
      using [java] fanx.test::InteropTest\$AbstractOverloadsInterface as OverloadsInterface
      using [java] fanx.test::InteropTest\$AbstractOverloadsA as OverloadsA
      using [java] fanx.test::InteropTest\$AbstractOverloadsB as OverloadsB

      class A : OverloadsA, OverloadsB {}
      class B : OverloadsClass { override Void foo() {} }
      class C : OverloadsInterface { override Void foo(Str? x) {} }
      ",
       [
          6,  1, "Inherited slots have conflicting signatures '[java]fanx.test::InteropTest\$AbstractOverloadsA.foo' and '[java]fanx.test::InteropTest\$AbstractOverloadsB.foo'",
          7, 28, "Cannot override Java overloaded method: 'foo'",
          8, 32, "Cannot override Java overloaded method: 'foo'",
       ])

    // CheckErrors
    verifyErrors(
     "using [java] fanx.test::InteropTest\$AbstractOverloadsClass as OverloadsClass
      using [java] fanx.test::InteropTest\$AbstractOverloadsInterface as OverloadsInterface
      using [java] fanx.test::InteropTest\$AbstractOverloadsA as OverloadsA
      using [java] fanx.test::InteropTest\$AbstractOverloadsB as OverloadsB

      class A : OverloadsClass {}
      class B : OverloadsInterface {}
      ",
       [
          6, 1, "Class 'A' must be abstract since it inherits but doesn't override '[java]fanx.test::InteropTest\$AbstractOverloadsClass.foo'",
          7, 1, "Class 'B' must be abstract since it inherits but doesn't override '[java]fanx.test::InteropTest\$AbstractOverloadsInterface.foo'",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Java Overloads
//////////////////////////////////////////////////////////////////////////

  Void testJavaOverrides()
  {
    verifyErrors(
     "using [java] fanx.test::InteropTest\$JavaOverrides as JavaOverrides
      class Foo : JavaOverrides
      {
        override Num add(Int a, Int b) { return a + b }
        override Decimal?[]? addDecimal(Decimal?[]? a, Decimal d) { return a.add(d) }
        override Int addfs(Float? a, Str? b) { return a.toInt + b.toInt }
        override Obj? arrayGet(Obj?[] a, Int i) { return a[i] }
        override JavaOverrides[]? arraySelf() { return JavaOverrides[this] }
        override Str?[]? swap(Str?[]? a) { a.swap(0, 1); return a }
      }
      ",
       [
          4, 3, "Return type mismatch in override of '[java]fanx.test::InteropTest\$JavaOverrides.add' - 'sys::Int' != 'sys::Num'",
          5, 3, "Parameter mismatch in override of '[java]fanx.test::InteropTest\$JavaOverrides.addDecimal' - '",
          6, 3, "Parameter mismatch in override of '[java]fanx.test::InteropTest\$JavaOverrides.addfs' - 'addfs(sys::Float, sys::Str?)' != 'addfs(sys::Float?, sys::Str?)'",
          7, 3, "Parameter mismatch in override of '[java]fanx.test::InteropTest\$JavaOverrides.arrayGet' - '",
          8, 3, "Return type mismatch in override of '[java]fanx.test::InteropTest\$JavaOverrides.arraySelf' - '",
       ])
  }

//////////////////////////////////////////////////////////////////////////
// Func to Interface
//////////////////////////////////////////////////////////////////////////

  Void testFuncToInterface()
  {
    verifyErrors(
     "using [java] fanx.test::InteropTest\$FuncA as FuncA
      class Foo
      {
        Void funcA(FuncA x) {}

        Void test00() { funcA |Str? s->Str?| { return null } } // ok
        Void test01() { funcA |->| {} }  // bad return
        Void test02() { funcA |Str? s->Int| { return 3} } // bad return
        Void test03() { funcA |Str? s, Int x->Str?| { return 3} } // not enough params
        Void test04() { funcA |Int x->Str?| { return 3} } // bad params
      }
      ",
       [
          7, 19, "Invalid args funcA",
          8, 19, "Invalid args funcA",
          9, 19, "Invalid args funcA",
         10, 19, "Invalid args funcA",
       ])
  }



}