//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Nov 08  Brian Frank  Creation
//

**
** InteropTest
**
class InteropTest : JavaTest
{

//////////////////////////////////////////////////////////////////////////
// Basics
//////////////////////////////////////////////////////////////////////////

  Void testBasics()
  {
    compile(
     "using [java] java.lang
      class Foo
      {
        Str? a(Str key) { return System.getProperty(key) }
        Str? b(Str key, Str def) { return System.getProperty(key, def) }
      }")

    obj := pod.types.first.make
    verifyEq(obj->a("java.home"), Env.cur.vars["java.home"])
    verifyEq(obj->a("bad one"), null)
    verifyEq(obj->b("bad one", "default"), "default")
  }

//////////////////////////////////////////////////////////////////////////
// Constructors
//////////////////////////////////////////////////////////////////////////

  Void testCtors()
  {
    compile(
     "using [java] java.util::Date as JDate
      class Foo
      {
        Int a() { return JDate().getTime }
        Int b() { return JDate(1_000_000).getTime }
      }")

    obj := pod.types.first.make
    verify(DateTime.fromJava(obj->a) - DateTime.now(null) <= 50ms)
    verifyEq(obj->b, 1_000_000)
  }

//////////////////////////////////////////////////////////////////////////
// Primitive Instance Fields
//////////////////////////////////////////////////////////////////////////

  Void testPrimitiveInstanceFields()
  {
    compile(
     "using \"[java]fanx.test\"
      class Foo
      {
        Obj init() { return InteropTest() { numl(9999) } }

        Int num(Obj o) { return ((InteropTest)o).numl() }

        Int getb(Obj o) { return ((InteropTest)o).numb }
        Int gets(Obj o) { return ((InteropTest)o).nums }
        Int getc(Obj o) { return ((InteropTest)o).numc }
        Int geti(Obj o) { return ((InteropTest)o).numi }
        Int getl(Obj o) { return ((InteropTest)o).numl }
        Float getf(Obj o) { return ((InteropTest)o).numf }
        Float getd(Obj o) { return ((InteropTest)o).numd }

        Int? getbx(Obj o) { return ((InteropTest)o).numb }
        Int? getsx(Obj o) { return ((InteropTest)o).nums }
        Int? getcx(Obj o) { return ((InteropTest)o).numc }
        Int? getix(Obj o) { return ((InteropTest)o).numi }
        Int? getlx(Obj o) { return ((InteropTest)o).numl }
        Float? getfx(Obj o) { return ((InteropTest)o).numf }
        Float? getdx(Obj o) { return ((InteropTest)o).numd }

        Int setb(Obj o, Int v) { x := (InteropTest)o; return x.numb = v }
        Int sets(Obj o, Int v) { x := (InteropTest)o; return x.nums = v }
        Int? setc(Obj o, Int v) { x := (InteropTest)o; return x.numc = v }
        Int? seti(Obj o, Int v) { x := (InteropTest)o; return x.numi = v }
        Float setf(Obj o, Float v) { x := (InteropTest)o; return x.numf = v }

        Int? setbx(Obj o, Int? v) { x := (InteropTest)o; return x.numb = v }
        Int? setsx(Obj o, Int? v) { x := (InteropTest)o; return x.nums = v }
        Int setcx(Obj o, Int? v) { x := (InteropTest)o; return x.numc = v }
        Int setix(Obj o, Int? v) { x := (InteropTest)o; return x.numi = v }
        Float setfx(Obj o, Float? v) { x := (InteropTest)o; return x.numf = v }
      }")

    obj := pod.types.first.make
    x := obj->init

    // non-nullable gets
    verifyEq(obj->num(x), 9999)
    verifyEq(obj->getb(x), 'b')
    verifyEq(obj->gets(x), 's')
    verifyEq(obj->getc(x), 'c')
    verifyEq(obj->geti(x), 'i')
    verifyEq(obj->getl(x), 'l')
    verifyEq(obj->getf(x), 'f'.toFloat)
    verifyEq(obj->getd(x), 'd'.toFloat)

    // nullable
    verifyEq(obj->getbx(x), 'b')
    verifyEq(obj->getsx(x), 's')
    verifyEq(obj->getcx(x), 'c')
    verifyEq(obj->getix(x), 'i')
    verifyEq(obj->getlx(x), 'l')
    verifyEq(obj->getfx(x), 'f'.toFloat)
    verifyEq(obj->getdx(x), 'd'.toFloat)

    // non-nullable sets
    verifyEq(obj->setb(x, -99), -99)
    verifyEq(obj->sets(x, 1997), 1997)
    verifyEq(obj->setc(x, '\u8abc'), '\u8abc')
    verifyEq(obj->seti(x, 0xbabe), 0xbabe)
    verify(obj->setf(x, 34e13f)->approx(34e13f))

    // nullable sets
    verifyEq(obj->setbx(x, -99), -99)
    verifyEq(obj->setsx(x, 1997), 1997)
    verifyEq(obj->setcx(x, '\u8abc'), '\u8abc')
    verifyEq(obj->setix(x, 0xbabe), 0xbabe)
    verify(obj->setfx(x, 34e13f)->approx(34e13f))
  }

//////////////////////////////////////////////////////////////////////////
// Primitive Static Fields
//////////////////////////////////////////////////////////////////////////

  Void testPrimitiveStaticFields()
  {
    compile(
     "using [java] fanx.test
      class Foo
      {
        new make()
        {
          InteropTest.snumb = 'B'
          InteropTest.snums = 'S'
          InteropTest.snumc = 'C'
          InteropTest.snumi = 'I'
          InteropTest.snuml = 'L'
          InteropTest.snumf = 'F'.toFloat
          InteropTest.snumd = 'D'.toFloat
        }

        Int b() { return InteropTest.snumb }
        Int s() { return InteropTest.snums }
        Int c() { return InteropTest.snumc }
        Int i() { return InteropTest.snumi }
        Int l() { return InteropTest.snuml }
        Float f() { return InteropTest.snumf }
        Float d() { return InteropTest.snumd }

        Int? bx() { return InteropTest.snumb }
        Int? sx() { return InteropTest.snums }
        Int? cx() { return InteropTest.snumc }
        Int? ix() { return InteropTest.snumi }
        Int? lx() { return InteropTest.snuml }
        Float? fx() { return InteropTest.snumf }
        Float? dx() { return InteropTest.snumd }
      }")

    obj := pod.types.first.make

    // non-nullable
    verifyEq(obj->b, 'B')
    verifyEq(obj->s, 'S')
    verifyEq(obj->c, 'C')
    verifyEq(obj->i, 'I')
    verifyEq(obj->l, 'L')
    verifyEq(obj->f, 'F'.toFloat)
    verifyEq(obj->d, 'D'.toFloat)

    // nullable
    verifyEq(obj->bx, 'B')
    verifyEq(obj->sx, 'S')
    verifyEq(obj->cx, 'C')
    verifyEq(obj->ix, 'I')
    verifyEq(obj->lx, 'L')
    verifyEq(obj->fx, 'F'.toFloat)
    verifyEq(obj->dx, 'D'.toFloat)
  }

//////////////////////////////////////////////////////////////////////////
// Primitive Methods
//////////////////////////////////////////////////////////////////////////

  Void testPrimitiveMethods()
  {
    compile(
     "using [java] fanx.test
      class Foo
      {
        Obj init() { return InteropTest() }

        Int getb(Obj o) { return ((InteropTest)o).numb() }
        Int gets(Obj o) { return ((InteropTest)o).nums() }
        Int getc(Obj o) { return ((InteropTest)o).numc() }
        Int geti(Obj o) { return ((InteropTest)o).numi() }
        Float getf(Obj o) { return ((InteropTest)o).numf() }

        Int? getbx(Obj o) { return ((InteropTest)o).numb() }
        Int? getsx(Obj o) { return ((InteropTest)o).nums() }
        Int? getcx(Obj o) { return ((InteropTest)o).numc() }
        Int? getix(Obj o) { return ((InteropTest)o).numi() }
        Float? getfx(Obj o) { return ((InteropTest)o).numf() }

        Obj getbo(Obj o) { return ((InteropTest)o).numb() }
        Obj getso(Obj o) { return ((InteropTest)o).nums() }
        Obj getco(Obj o) { return ((InteropTest)o).numc() }
        Obj getio(Obj o) { return ((InteropTest)o).numi() }
        Obj getfo(Obj o) { return ((InteropTest)o).numf() }

        Obj? getbox(Obj o) { return ((InteropTest)o).numb() }
        Obj? getsox(Obj o) { return ((InteropTest)o).nums() }
        Obj? getcox(Obj o) { return ((InteropTest)o).numc() }
        Obj? getiox(Obj o) { return ((InteropTest)o).numi() }
        Obj? getfox(Obj o) { return ((InteropTest)o).numf() }

        Int setb(Obj o, Int v) { x := (InteropTest)o; x.numb(v); return x.numl() }
        Int sets(Obj o, Int v) { x := (InteropTest)o; x.nums(v); return x.numl() }
        Int setc(Obj o, Int v) { x := (InteropTest)o; x.numc(v); return x.numl() }
        Int seti(Obj o, Int v) { x := (InteropTest)o; x.numi(v); return x.numl() }
        Int setl(Obj o, Int v) { x := (InteropTest)o; x.numl(v); return x.numl() }
        Int setf(Obj o, Float v) { x := (InteropTest)o; x.numf(v); return x.numl() }

        Int setbx(Obj o, Int? v) { x := (InteropTest)o; x.numb(v); return x.numl() }
        Int setsx(Obj o, Int? v) { x := (InteropTest)o; x.nums(v); return x.numl() }
        Int setcx(Obj o, Int? v) { x := (InteropTest)o; x.numc(v); return x.numl() }
        Int setix(Obj o, Int? v) { x := (InteropTest)o; x.numi(v); return x.numl() }
        Int setlx(Obj o, Int? v) { x := (InteropTest)o; x.numl(v); return x.numl() }
        Int setfx(Obj o, Float? v) { x := (InteropTest)o; x.numf(v); return x.numl() }

        Int add(Obj o, Int b, Int s, Int i, Float f) { x := (InteropTest)o; x.numadd(b, s, i, f); return x.numl() }
      }")

    obj := pod.types.first.make
    x := obj->init

    // long -> byte -> long
    verifyEq(obj->setb(x, 127), 127)
    verifyEq(obj->setb(x, -127), -127)
    verifyEq(obj->setbx(x, 0xff7a), 0x7a)
    verifyEq(obj->getb(x), 0x7a)
    verifyEq(obj->getbx(x), 0x7a)
    verifyEq(obj->setl(x, -1), -1)
    verifyEq(obj->getb(x), -1)
    verifyEq(obj->getbx(x), -1)
    verifyEq(obj->setb(x, 345), 89)
    verifyEq(obj->getb(x), 89)
    verifyEq(obj->getbo(x), 89)
    verifyEq(obj->getbox(x), 89)

    // long -> short -> long
    verifyEq(obj->sets(x, 32_000), 32_000)
    verifyEq(obj->sets(x, -32_000), -32_000)
    verifyEq(obj->setsx(x, 0x1234_7abc), 0x7abc)
    verifyEq(obj->gets(x), 0x7abc)
    verifyEq(obj->getsx(x), 0x7abc)
    verifyEq(obj->setl(x, 0xffff_0123), 0xffff_0123)
    verifyEq(obj->gets(x), 0x123)
    verifyEq(obj->getsx(x), 0x123)
    verifyEq(obj->sets(x, -70982), -5446)
    verifyEq(obj->gets(x), -5446)
    verifyEq(obj->getso(x), -5446)
    verifyEq(obj->getsox(x), -5446)

    // long -> char -> long
    verifyEq(obj->setc(x, 'A'), 'A')
    verifyEq(obj->getc(x), 'A')
    verifyEq(obj->setcx(x, 60_000), 60_000)
    verifyEq(obj->getcx(x), 60_000)
    verifyEq(obj->setc(x, 71234), 5698)
    verifyEq(obj->getcx(x), 5698)
    verifyEq(obj->getco(x), 5698)
    verifyEq(obj->getcox(x), 5698)

    // long -> int -> long
    verifyEq(obj->seti(x, -44), -44)
    verifyEq(obj->geti(x), -44)
    verifyEq(obj->setix(x, 0xff_1234_abcd), 0x1234_abcd)
    verifyEq(obj->geti(x), 0x1234_abcd)
    verifyEq(obj->getix(x), 0x1234_abcd)
    verifyEq(obj->setl(x, 0xff_1234_abcd), 0xff_1234_abcd)
    verifyEq(obj->geti(x), 0x1234_abcd)
    verifyEq(obj->getix(x), 0x1234_abcd)
    verifyEq(obj->getio(x), 0x1234_abcd)
    verifyEq(obj->getiox(x), 0x1234_abcd)

    // double -> float -> long
    verifyEq(obj->setf(x, 88f), 88)
    verifyEq(obj->getf(x), 88f)
    verifyEq(obj->getfx(x), 88f)
    verifyEq(obj->setfx(x, -1234f), -1234)
    verifyEq(obj->getf(x), -1234f)
    verifyEq(obj->getfo(x), -1234f)
    verifyEq(obj->getfox(x), -1234f)

    // multiple primitives on stack
    verifyEq(obj->add(x, 3, 550, -50, -50f), 453)
  }

//////////////////////////////////////////////////////////////////////////
// Arrays
//////////////////////////////////////////////////////////////////////////

  Void testArrays()
  {
    compile(
     """using [java] fanx.interop
        using [java] fanx.test
        using [java] java.text
        class Foo
        {
          InteropTest x := InteropTest().initArray
          InteropTest a() { return x.a }
          InteropTest b() { return x.b }
          InteropTest c() { return x.c }

          InteropTest[] get1a() { return x.array1 }
          Obj get1b() { return x.array1 }
          Obj[] get1c() { return x.array1 }

          Void set1(InteropTest[] a) { x.array1(a) }

          SimpleDateFormat?[]? getFormats() { x.formats }
          Void setFormats() { x.formats = [SimpleDateFormat("yyyy")] }
          SimpleDateFormat? firstFormat() { x.formats?.first }

          Str?[]? getStrs() { x.strings }
          Void setStrs() { x.strings = ["a", "b"] }

          Obj? getInts() { x.ints }
          Int getIntsAt(Int i) { x.ints[i] }
          Void setInts() { x.ints = IntArray(2); x.ints.set(0, 10); x.ints.set(1, 20) }
        }""")

    obj := pod.types.first.make

    // get one dimension array
    Obj[] a := obj->get1a
    verifyEq(a.size, 3)
    verifyEq(a.of.qname, "[java]fanx.test::InteropTest")
    verifySame(a[0], obj->a)
    verifySame(a[1], obj->b)
    verifySame(a[2], obj->c)

    // get as coerced to Obj
    a = obj->get1b
    verifyEq(a.size, 3)
    verifyEq(a.of.qname, "[java]fanx.test::InteropTest")
    verifySame(a[2], obj->c)

    // get as coerced to InteropTest[]
    a = obj->get1c
    verifyEq(a.size, 3)
    verifyEq(a.of.qname, "[java]fanx.test::InteropTest")
    verifySame(a[0], obj->a)

    // set one dimension array items
    origa := obj->a
    origb := obj->b
    origc := obj->c
    a.reverse
    verifySame(obj->a, origa)
    verifySame(obj->b, origb)
    verifySame(obj->c, origc)
    obj->set1(a)
    verifySame(obj->a, origc)
    verifySame(obj->b, origb)
    verifySame(obj->c, origa)

    // set entire SimpleDateFormat array
    verifyEq(obj->getFormats, null)
    verifyEq(obj->firstFormat, null)
    obj->setFormats
    verifyEq(obj->getFormats->size, 1)
    verifyEq(obj->getFormats->first.typeof.signature, "[java]java.text::SimpleDateFormat")
    verifyEq(obj->getFormats->first->toPattern, "yyyy")
    verifyEq(obj->firstFormat.typeof.signature, "[java]java.text::SimpleDateFormat")
    verifyEq(obj->firstFormat->toPattern, "yyyy")

    // set entire Strings array
    verifyEq(obj->getStrs, null)
    obj->setStrs
    verifyEq(obj->getStrs, Str?["a", "b"])

    // set entire ints array
    verifyEq(obj->getInts, null)
    obj->setInts
    verifyEq(obj->getInts.typeof.signature, "[java]fanx.interop::IntArray")
    verifyEq(obj->getIntsAt(0), 10)
    verifyEq(obj->getIntsAt(1), 20)
  }

//////////////////////////////////////////////////////////////////////////
// Primitive Arrays
//////////////////////////////////////////////////////////////////////////

  Void testPrimitiveArrays()
  {
    verifyPrimitiveArrays("boolean", "Bool", "true", "false")
    verifyPrimitiveArrays("byte", "Int", "-88", "126")
    verifyPrimitiveArrays("short", "Int", "9", "-32004")
    verifyPrimitiveArrays("char", "Int", "'X'", "'Y'")
    verifyPrimitiveArrays("int", "Int", "1234", "-99")
    verifyPrimitiveArrays("long", "Int", "0x1234_abcd_00ef", "-123")
    verifyPrimitiveArrays("float", "Float", "12f", "4f")
    verifyPrimitiveArrays("double", "Float", "12f", "4f")
  }

  Void verifyPrimitiveArrays(Str kind, Str fanOf, Str a, Str b)
  {
    fanArray := "${kind.capitalize}Array"
    compile(
     "using [java] fanx.test
      using [java] fanx.interop
      class Foo
      {
        InteropTest x := InteropTest().initArray
        // size
        Bool test0() { Int v := x.${kind}Array($a, $b).size; return v == 2 }
        // gets
        Bool test1() { $fanOf v := x.${kind}Array($a, $b)[0]; return v == $a }
        Bool test2() { $fanOf v := x.${kind}Array($a, $b)[1]; return v == $b }
        // sets
        Bool test3() { array := x.${kind}Array($a, $b); array[1] = $a; $fanOf v := array[1]; return v == $a }
        // new
        Bool test4() { array := ${fanArray}(8); return (Int)array.size == 8 }
      }")

    obj := pod.types.first.make
    verify(obj->test0)
    verify(obj->test1)
    verify(obj->test2)
    verify(obj->test3)
    verify(obj->test4)
  }

//////////////////////////////////////////////////////////////////////////
// Inference
//////////////////////////////////////////////////////////////////////////

  Void testInference()
  {
    compile(
     "using [java] fanx.test
      class Foo
      {
        InteropTest x := InteropTest()
        Obj[] b() { v := x.numb;   return [Type.of(v), v] }
        Obj[] s() { v := x.nums(); return [Type.of(v), v] }
        Obj[] c() { v := x.numc;   return [Type.of(v), v] }
        Obj[] i() { v := x.numi(); return [Type.of(v), v] }
        Obj[] f() { v := x.numf;   return [Type.of(v), v] }

        Obj   m00() { return x.numi.toHex }
        Obj   m01() { return x.numi().toHex }
        Obj   m02() { return x.numi == x.numi() }
        Bool  m03() { return x.numi() < x.numi }
        Void  m04() { x.numi() } // verify pop
      }")

    obj := pod.types.first.make
    verifyEq(obj->b, [Int#, 'b'])
    verifyEq(obj->s, [Int#, 1000])
    verifyEq(obj->c, [Int#, 'c'])
    verifyEq(obj->i, [Int#, 1000])
    verifyEq(obj->f, [Float#, 'f'.toFloat])

    verifyEq(obj->m00, 'i'.toHex)
    verifyEq(obj->m01, 1000.toHex)
    verifyEq(obj->m02, false)
    verifyEq(obj->m03, false)
    obj->m04
  }

//////////////////////////////////////////////////////////////////////////
// Overload Resolution
//////////////////////////////////////////////////////////////////////////

  Void testOverloadResolution()
  {
    compile(
     "using [java] java.lang
      using [java] fanx.test
      class Foo
      {
        InteropTest x := InteropTest()
        Bool a() { return x.overload1(this) == \"(Object)\" }
        Bool b() { return x.overload1(\"foo\") == \"(String)\" }
        Bool c() { return x.overload1(5) == \"(long)\" }

        Bool d() { return x.overload2(3, this) == \"(int, Object)\" }
        Bool e() { return x.overload2(3, (Number?)null) == \"(int, Number)\" }
        Bool f() { return x.overload2(3, (Double?)null) == \"(int, Double)\" }
      }")

    obj := pod.types.first.make
    verify(obj->a)
    verify(obj->b)
    verify(obj->c)
    verify(obj->d)
    // TODO: need to fix JLS resolution rules
    // verify(obj->e)
    verify(obj->f)
  }

//////////////////////////////////////////////////////////////////////////
// Inner Classes
//////////////////////////////////////////////////////////////////////////

  Void testInnerClasses()
  {
    compile(
     "using [java] fanx.test::InteropTest\$InnerClass as Inner
      class Foo
      {
        Str name() { return Inner().name }
      }")

    obj := pod.types.first.make
    verifyEq(obj->name, "InnerClass")
  }

//////////////////////////////////////////////////////////////////////////
// ObjMethods
//////////////////////////////////////////////////////////////////////////

  Void testObjMethods()
  {
    compile(
     "using [java] fanx.test
      class Foo : InteropTest
      {
        Void foo() { echo(this) }
        Bool test1() { return this < this }
        Bool test2() { return this <= this }
        Bool test3() { return this == this }
        Str  test4() { return Type.of(this).name }
        Bool test5() { return toStr == toString }
        Bool test6() { return this.isImmutable }
        Bool test7() { return hash == hashCode }
      }")

    obj := pod.types.first.make
    verifyEq(obj->test1, false)
    verifyEq(obj->test2, true)
    verifyEq(obj->test3, true)
    verifyEq(obj->test4, "Foo")
    verifyEq(obj->test5, true)
    verifyEq(obj->test6, false)
    verifyEq(obj->test7, true)
  }

//////////////////////////////////////////////////////////////////////////
// DefaultParams
//////////////////////////////////////////////////////////////////////////

  Void testDefaultParams()
  {
    compile(
     "using [java] java.util::Date as JDate
      class Foo
      {
        Str foo(JDate? a := null, JDate? b := null, Str? end := null)
        {
          s :=  \"\"
          if (a != null) s += \"a\"
          if (b != null) s += \"b\"
          if (end != null) s += end
          return s
        }

        Str test1() { return foo }
        Str test2() { return foo(JDate()) }
        Str test3() { return foo(JDate(), JDate()) }
        Str test4() { return foo(JDate(), null, \"|\") }
      }")

    obj := pod.types.first.make
    verifyEq(obj->test1, "")
    verifyEq(obj->test2, "a")
    verifyEq(obj->test3, "ab")
    verifyEq(obj->test4, "a|")
  }

//////////////////////////////////////////////////////////////////////////
// Func To Interface
//////////////////////////////////////////////////////////////////////////

  Void testFuncToInterface()
  {
    compile(
     "using [java] java.lang
      using [java] fanx.test::InteropTest\$FuncA as FuncA
      using [java] fanx.test::InteropTest\$FuncB as FuncB
      using [java] fanx.test::InteropTest\$FuncC as FuncC
      class Foo
      {
        Void run(Runnable r) { r.run }
        Str? funcA(Str? s, FuncA f) { return f.thru(s) }
        Int funcB(Int a, Int b, Int c, FuncB f) { return f.add(a, b, c) }
        Str[] funcC(Str[] a, FuncC f) { return f.swap(a) }

        Int test1() { n := 0; run |->| { n++ }; return n }
        Str? test2(Str? x) { return funcA(x) |Str? s->Str?| { return s } }
        Int test3(Int x, Int y, Int z) { return funcB(x, y, z) |Int a, Int b, Int c->Int| { return a+b+c } }
        Str[] test4(Str[] a) { return funcC(a) |Str[] x->Str[]| { return x.swap(0, 1) } }
        Str test5() { return funcA(\"foo\") |->Str| { return \"fixed\" } }
        Int test6() { n := 3; run |->Int| { return n++ }; return n }
        Str? test7() { return funcA(\"seven\", |Str s->Str| { wrap(s) }) }
        Str? test8() { f := |->Str| { return 8.toStr }; return funcA(\"bad\", f) }

        static Str wrap(Str s) { return \"[\$s]\" }
      }")

    obj := pod.types.first.make
    verifyEq(obj->test1, 1)
    verifyEq(obj->test2("fan"), "fan")
    verifyEq(obj->test2(null), null)
    verifyEq(obj->test3(2, 3, 7), 12)
    verifyEq(obj->test4(["hi", "hola"]), Str?["hola", "hi"])
    verifyEq(obj->test5, "fixed")
    verifyEq(obj->test6, 4)
    verifyEq(obj->test7, "[seven]")
    verifyEq(obj->test8, "8")
  }

//////////////////////////////////////////////////////////////////////////
// It-Blocks
//////////////////////////////////////////////////////////////////////////

  Void testItBlocks()
  {
    compile(
     "using [java] fanx.test
      class Foo
      {
        Obj a() { x := InteropTest() { num = 'a' }; return x.num }
        Obj b() { x := InteropTest(); x { num = 'b' }; return x.num }
        Obj c() { x := makeOne { num = 'c' }; return x.num }
        Obj d() { x := InteropTest.makeOne { num = 'd' }; return x.num }
        Obj e() { x := InteropTest().initArray { num = 'e' }; return x.num }
        InteropTest makeOne() { InteropTest() }
      }
      ")

    obj := pod.types.first.make
    verifyEq(obj->a, 'a')
    verifyEq(obj->b, 'b')
    verifyEq(obj->c, 'c')
    verifyEq(obj->d, 'd')
    verifyEq(obj->e, 'e')
  }

//////////////////////////////////////////////////////////////////////////
// Exceptions
//////////////////////////////////////////////////////////////////////////

  Void testErrs()
  {
    compile(
     "using [java] java.lang
      using [java] fanx.interop
      class Foo
      {
        Obj m00()
        {
          try
            return Class.forName(\"badname\")
          catch (Err e)
            return Interop.toJava(e)
        }

        Obj m01()
        {
          throw Interop.toFan(NullPointerException())
        }
      }
      ")

    obj := pod.types.first.make
    verifyEq(Type.of(obj->m00).toStr, "[java]java.lang::ClassNotFoundException")
    verifyErr(NullErr#) { obj->m01 }
  }

//////////////////////////////////////////////////////////////////////////
// IO
//////////////////////////////////////////////////////////////////////////

  Void testIO()
  {
    compile(
     "using [java] java.io
      using [java] fanx.interop
      class Foo
      {
        Obj m00()
        {
          buf := Buf().print(\"abcd\")
          InputStream in := Interop.toJava(buf.flip.in)
          return BufferedReader(InputStreamReader(in)).readLine
        }

        Obj m01()
        {
          buf := Buf()
          OutputStream out := Interop.toJava(buf.out)
          out.write('x'); out.write('y')
          return buf.seek(0).readAllStr
        }

        Obj m02()
        {
          bout := ByteArrayOutputStream()
          fout := Interop.toFan(bout)
          fout.write('b').write('s').write('f').flush
          bin := ByteArrayInputStream(bout.toByteArray)
          fin := Interop.toFan(bin)
          return fin.readAllStr
        }
      }
      ")

    obj := pod.types.first.make
    verifyEq(obj->m00, "abcd")
    verifyEq(obj->m01, "xy")
    verifyEq(obj->m02, "bsf")
  }

//////////////////////////////////////////////////////////////////////////
// Collections
//////////////////////////////////////////////////////////////////////////

  Void testCollections()
  {
    compile(
     "using [java] java.util
      using [java] fanx.interop
      class Foo
      {
        // java.util.List => List
        Obj m00() { a := ArrayList(); a.add(1); a.add(2); return Interop.toFan(a) }
        Obj m01() { a := ArrayList(); a.add(1); a.add(2); return Interop.toFan(a, Int#) }

        // Iterator => List
        Obj m02() { a := ArrayList(); a.add(3); a.add(4); return Interop.toFan(a.iterator()) }
        Obj m03() { a := ArrayList(); a.add(3); a.add(4); return Interop.toFan(a.iterator(), Int#) }

        // Enumeration => List
        Obj m04() { a := Vector(); a.add(3); a.add(4); return Interop.toFan(a.elements()) }
        Obj m05() { a := Vector(); a.add(3); a.add(4); return Interop.toFan(a.elements(), Int#) }

        // HashMap => Map
        Obj m06() { a := HashMap(); a.put(3, \"x\"); return Interop.toFan(a) }
        Obj m07() { a := HashMap(); a.put(3, \"x\"); return Interop.toFan(a, Int:Str#) }
      }
      ")

    obj := pod.types.first.make
    verifyEq(obj->m00, Obj?[1, 2])
    verifyEq(obj->m01, Int[1, 2])
    verifyEq(obj->m02, Obj?[3, 4])
    verifyEq(obj->m03, Int[3, 4])
    verifyEq(obj->m04, Obj?[3, 4])
    verifyEq(obj->m05, Int[3, 4])
    verifyEq(obj->m06, Obj:Obj?[3:"x"])
    verifyEq(obj->m07, Int:Str[3:"x"])
  }

//////////////////////////////////////////////////////////////////////////
// Built-ins
//////////////////////////////////////////////////////////////////////////

  Void testBuiltins()
  {
    compile(
     """using [java] fanx.test
        class Foo
        {
          // Str <=> java.lang.String
          Obj s00() { InteropTest.charSequence("hello") }
          Obj s01() { InteropTest.serializable("x") === (Obj?)"x" }
          Obj s02() { InteropTest.comparable("a", "b") }

          // Bool <=> java.lang.Bool
          Obj b00() { InteropTest.serializable(true) }
          Obj b01() { InteropTest.comparable(false, false) }

          // Int <=> java.lang.Long
          Obj i00() { InteropTest.serializable(5) == (Obj?)5 }
          Obj i01() { InteropTest.number(5) == (Obj?)5 }
          Obj i02() { InteropTest.comparable(6, 3) }

          // Float <=> java.lang.Double
          Obj f00() { InteropTest.serializable(5f) == (Obj?)5f }
          Obj f01() { InteropTest.number(5f) == (Obj?)5f }
          Obj f02() { InteropTest.comparable(6f, 6f) }

          // Decimal <=> java.math.BigDecimal
          Obj d00() { InteropTest.serializable(5d) == (Obj?)5d }
          Obj d01() { InteropTest.number(5d) == (Obj?)5d }
          Obj d02() { InteropTest.comparable(2d, 3d) }
        }""")

    obj := pod.types.first.make
    verifyEq(obj->s00, 5)
    verifyEq(obj->s01, true)
    verifyEq(obj->s02, -1)

    verifyEq(obj->b00, true)
    verifyEq(obj->b01, 0)

    verifyEq(obj->i00, true)
    verifyEq(obj->i01, true)
    verifyEq(obj->i02, 1)

    verifyEq(obj->f00, true)
    verifyEq(obj->f01, true)
    verifyEq(obj->f02, 0)

    verifyEq(obj->d00, true)
    verifyEq(obj->d01, true)
    verifyEq(obj->d02, -1)
  }

//////////////////////////////////////////////////////////////////////////
// Primitive Routers
//////////////////////////////////////////////////////////////////////////

  Void testPrimitiveRouters()
  {
    compile(
     """using [java] fanx.test::InteropTest\$PrimitiveRouters as PrimitiveRouters
        mixin Router : PrimitiveRouters
        {
          override Bool z(Bool x) { return x }
          override Int b(Int x) { return x }
          override Int c(Int x) { return x }
          override Int s(Int x) { return x }
          override Int i(Int x) { return x }
          override Int j(Int x) { return x }
          override Float f(Float x) { return x }
          override Float d(Float x) { return x }
        }

        class Foo : Router
        {
          Bool testz() { z(true) == true }
          Bool testb() { b(3) == 3 }
          Bool tests() { s(333) == 333 }
          Bool testi() { i(1234567) == 1234567 }
          Bool testj() { j(1234567) == 1234567 }
          Bool testf() { f(4f) == 4f }
          Bool testd() { d(11f) == 11f }
        }""")

    obj := pod.types.last.make
    verify(obj->testz)
    verify(obj->testb)
    verify(obj->tests)
    verify(obj->testi)
    verify(obj->testj)
    verify(obj->testf)
    verify(obj->testd)
  }

}

