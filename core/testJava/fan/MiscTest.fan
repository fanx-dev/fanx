//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   10 Dec 08  Brian Frank  Creation
//

**
** MiscTest
**
class MiscTest : JavaTest
{

//////////////////////////////////////////////////////////////////////////
// Ctor Wrapper
//////////////////////////////////////////////////////////////////////////

  Void testCtorWrapper()
  {
    // test for bug report 423 31-Dec-08
    compile(
     "using [java] fanx.interop::DoubleArray as FloatArray
      class Matrix
      {
        new make(Num[][] rows := Float[][,]) { this.size = rows.size }
        Int size
      }")

    obj := pod.types.first.make
    verifyEq(obj->size, 0)
  }

//////////////////////////////////////////////////////////////////////////
// Ctor With Java Arg
//////////////////////////////////////////////////////////////////////////

  Void testCtorWithJavaArg()
  {
    // test for bug report on IRC 13-May-09
    compile(
     "using [java] java.util
      class Foo
      {
        new make(ArrayList? x) { }
        static Foo foo() { make(null) }
        static Foo bar() { Foo(null) }
      }")

    obj := pod.types.first.make([null])
    verifyEq(Type.of(obj->foo).name, "Foo")
    verifyEq(Type.of(obj->bar).name, "Foo")
  }

//////////////////////////////////////////////////////////////////////////
// #629 NoClassDefFoundError when accessing public static final field with JavaFFI
//////////////////////////////////////////////////////////////////////////

  Void test629()
  {
    // test for bug report 423 31-Dec-08
    compile(
     "using [java] java.io
      class Foo
      {
        static Int foo() { ObjectStreamConstants.PROTOCOL_VERSION_1 }
      }")

    obj := pod.types.first.make
    verifyEq(obj->foo, 1)
  }

//////////////////////////////////////////////////////////////////////////
// #965 Compiler TypeParser doesn't handle Java FFI
//////////////////////////////////////////////////////////////////////////

  Void test965()
  {
    aPod := podName
    compile(
     "using [java] java.util::Date as JDate
      class Foo
      {
        static JDate[] a() { [JDate(123456789)] }
        static Void b(|JDate?|? f) { f(JDate(987654321)) }
      }")

    depends = [Depend("sys 1.0"), Depend("$aPod 0+")]
    compile(
     "using $aPod
      using [java] java.util::Date as JavaDate
      class Bar
      {
        JavaDate a() { Foo.a.first }
        JavaDate b() { x := null; Foo.b |y| { x = y }; return x }
      }")

    obj := pod.types.first.make
    verifyEq(obj->a->getTime, 123456789)
    verifyEq(obj->b->getTime, 987654321)
  }

//////////////////////////////////////////////////////////////////////////
// #1067 compilerJava - findMethods() patch
//////////////////////////////////////////////////////////////////////////

  Void test1067()
  {
    compile(
     """using [java] fanx.test::InteropTest\$ComboA as ComboA
        using [java] fanx.test::InteropTest\$ComboB as ComboB
        using [java] fanx.test::InteropTest\$ComboC as ComboC
        using [java] fanx.test::InteropTest\$ComboD as ComboD
        class Foo : ComboD
        {
          override Str? foo(Str? x) { x }
          Str? test1(ComboA a) { a.foo("1") }
          Str? test2(ComboB b) { b.foo("2") }
          Str? test3(ComboC c) { c.foo("3") }
          Str? test4(ComboD d) { d.foo("4") }
        }""")

    obj := pod.types.first.make
    verifyEq(obj->foo("0"), "0")
    verifyEq(obj->test1(obj), "1")
    verifyEq(obj->test2(obj), "2")
    verifyEq(obj->test3(obj), "3")
    verifyEq(obj->test4(obj), "4")
  }

//////////////////////////////////////////////////////////////////////////
// #1077 Safe invoke with int
//////////////////////////////////////////////////////////////////////////

  Void test1077()
  {
    compile(
     """using [java] java.util::List
        using [java] java.util::ArrayList
        class Foo
        {
          Obj? foo(List? list) { list?.size }
          Obj? test1() { foo(ArrayList()) }
          Obj? test2() { foo(null) }
        }""")

    obj := pod.types.first.make
    verifyEq(obj->test1, 0)
    verifyEq(obj->test2, null)
  }

//////////////////////////////////////////////////////////////////////////
// #1096 Expose java.lang.Class access on Type
//////////////////////////////////////////////////////////////////////////

  Void test1096()
  {
    compile(
     """using [java] java.lang
        using [java] java.util::ArrayList
        class Foo
        {
          Class a() { ArrayList#->toClass }
          Class b() { Class.forName("java.util.ArrayList") }
        }""")

    obj := pod.types.first.make
    verifyEq(obj->a, obj->b)
  }

//////////////////////////////////////////////////////////////////////////
// #1190 compile error on list of java arrays
//////////////////////////////////////////////////////////////////////////

  Void test1190()
  {
    compile(
     """using [java] fanx.interop
        class Foo
        {
          Obj[] x() { [ByteArray(0)] }
        }""")

    obj := pod.types.first.make
    verifyEq(obj->x.typeof.toStr, "[java]fanx.interop::ByteArray?[]")
    verifyEq(obj->x->first.typeof.toStr, "[java]fanx.interop::ByteArray")
  }

//////////////////////////////////////////////////////////////////////////
// #1213 Java FFI coercion to handle null literal
//////////////////////////////////////////////////////////////////////////

  Void test1213()
  {
    compile(
     """using [java] fanx.test::InteropTest\$FuncC as FuncC
        class Foo : FuncC
        {
          override Str?[]? swap(Str?[]? x) { return null }
        }""")

    obj := pod.types.first.make
    verifyEq(obj->swap(null),  null)
  }

//////////////////////////////////////////////////////////////////////////
// #1396 Java subclass visibility disallows overriding
//////////////////////////////////////////////////////////////////////////

  Void test1396()
  {
    compile(
     """using [java] fanx.test::InteropTest\$PublicOverride as PubOverride
        class Bar : PubOverride {}
        class Foo : PubOverride { override Str? foo() { "override" } }
        """)

    verifyEq(pod.types[0].make->foo, "public")
    verifyEq(pod.types[1].make->foo, "override")
  }

//////////////////////////////////////////////////////////////////////////
// #1496 Expose java.lang.Class access on Type
//////////////////////////////////////////////////////////////////////////

  Void test1496()
  {
    compile(
     """using [java] java.lang
        using [java] java.util
        using [java] fanx.interop
        class Foo
        {
          Class a1() { ArrayList#->toClass }
          Class a2() { Interop.toJava(ArrayList#) }
          Type b1() { Interop.toFan(a1) }
          Type b2() { ArrayList# }
        }""")

    obj := pod.types.first.make
    verifySame(obj->a1, obj->a1)
    verifySame(obj->b2, obj->b2)
  }

//////////////////////////////////////////////////////////////////////////
// #1512 FFI 'override once' with array
//////////////////////////////////////////////////////////////////////////

  Void test1512()
  {
    verifyErrors(
     """using [java] fanx.test::InteropTest\$Once as Once
        class Foo : Once
        {
          override once Int i() { (Int)123 }
          override once Str?[]? array() { ["f", "f", "i"] }
        }""",
        [4, 3, "Once method cannot be used with FFI type '[java]::int'",
         5, 3, "Once method cannot be used with FFI type '[java]java.lang::[String?'"])
  }

//////////////////////////////////////////////////////////////////////////
// Object
//////////////////////////////////////////////////////////////////////////

  Void testObjectMethods()
  {
    compile(
     """using [java] java.lang
        class Foo
        {
          Str a(Object x) { x.toString }
          Str b(Object x) { x.getClass.getName }
          Int c(Object x) { x.hashCode }
          Str d(Object x) { r := ""; try x.notify; catch(Err e) r = e.msg; return r }
          Str e(Object x) { r := ""; try x.notifyAll; catch(Err e) r = e.msg; return r }
          Str f(Object x) { r := ""; try x.wait; catch(Err e) r = e.msg; return r }
          Str g(Object x) { r := ""; try x.wait(10); catch(Err e) r = e.msg; return r }
          Str h(Object x) { r := ""; try x.wait(0, 10); catch(Err e) r = e.msg; return r }
        }""")

    obj := pod.types.first.make
    verifySame(obj->a("foo"), "foo")
    verifySame(obj->b("foo"), "java.lang.String")
    verifyEq(obj->c(obj), obj.hash)
    verifySame(obj->d(obj).toStr, "java.lang.IllegalMonitorStateException")
    verifySame(obj->e(obj).toStr, "java.lang.IllegalMonitorStateException")
    verifySame(obj->f(obj).toStr, "java.lang.IllegalMonitorStateException")
    verifySame(obj->g(obj).toStr, "java.lang.IllegalMonitorStateException")
    verifySame(obj->h(obj).toStr, "java.lang.IllegalMonitorStateException")
  }

//////////////////////////////////////////////////////////////////////////
// #2246 Closure wrapper
//////////////////////////////////////////////////////////////////////////

  Void test2246()
  {
    compile(
     """using [java] java.util
        class Foo
        {
          Obj? foo()
          {
            list := ArrayList()
            list = ArrayList()
            3.times |x|
            {
              list.add(x.toStr)
            }
            return list.size
          }
        }""")

    obj := pod.types.first.make
    verifyEq(obj->foo, 3)
  }

}