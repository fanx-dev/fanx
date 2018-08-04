//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Nov 08  Brian Frank  Creation
//

using compiler

**
** ReflectTest
**
class ReflectTest : JavaTest
{

//////////////////////////////////////////////////////////////////////////
// Reflection
//////////////////////////////////////////////////////////////////////////

  Void testLiterals()
  {
    compile(
     "using [java] java.util::Date as JDate

      class Foo
      {
        Type date()  { return JDate# }
        Type jint()  { return Type.find(\"[java]::int\") }
        Type array() { return Type.find(\"[java]java.util::[Date\") }
        Type list()  { return Type.find(\"[java]java.util::Date[]\") }
        Type map()   { return Type.find(\"[[java]java.util::Date:[java]java.util::ArrayList]\") }
      }")

    obj := pod.types.first.make

    Type date := obj->date
    verifyEq(date.pod,   null)
    verifyEq(date.name,  "Date")
    verifyEq(date.qname, "[java]java.util::Date")
    verifyEq(date.signature, "[java]java.util::Date")

    Type jint := obj->jint
    verifyEq(jint.pod,   null)
    verifyEq(jint.name,  "int")
    verifyEq(jint.qname, "[java]::int")
    verifyEq(jint.signature, "[java]::int")

    Type array := obj->array
    verifyEq(array.pod,   null)
    verifyEq(array.name,  "[Date")
    verifyEq(array.qname, "[java]java.util::[Date")
    verifyEq(array.signature, "[java]java.util::[Date")

    Type list := obj->list
    verifyEq(list.pod,   Pod.find("sys"))
    verifyEq(list.name,  "List")
    verifyEq(list.qname, "sys::List")
    verifyEq(list.signature, "[java]java.util::Date[]")
    verifyEq(list.params["V"].qname, "[java]java.util::Date")

    Type map := obj->map
    verifyEq(map.pod,   Pod.find("sys"))
    verifyEq(map.name,  "Map")
    verifyEq(map.qname, "sys::Map")
    verifyEq(map.signature, "[[java]java.util::Date:[java]java.util::ArrayList]")
    verifyEq(map.params["K"].qname, "[java]java.util::Date")
    verifyEq(map.params["V"].qname, "[java]java.util::ArrayList")
  }

//////////////////////////////////////////////////////////////////////////
// JavaType: java.util.Date
//////////////////////////////////////////////////////////////////////////

  Void testDate()
  {
    t := Type.find("[java]java.util::Date")
    verifySame(Type.find("[java]java.util::Date"), t)

    // naming
    verifyEq(t.name, "Date")
    verifyEq(t.qname, "[java]java.util::Date")
    verifyEq(t.signature, "[java]java.util::Date")
    verifyEq(t.toStr, t.signature)

    // flags
    verifyEq(t.isPublic, true)
    verifyEq(t.isInternal, false)
    verifyEq(t.isAbstract, false)
    verifyEq(t.isFinal, false)
    verifyEq(t.isMixin, false)
    verifyEq(t.isEnum, false)
    verifyEq(t.isConst, false)

    // inheritance
    verifyEq(t.base, Obj#)
    verifyEq(t.mixins.isRO, true)
    verifyEq(t.inheritance.isRO, true)
    verifyEq(t.mixins.rw.sort,
      Type[Type.find("[java]java.io::Serializable"),
       Type.find("[java]java.lang::Cloneable"),
       Type.find("[java]java.lang::Comparable"),
      ].sort)
    verifyEq(t.inheritance.rw.sort, Type[t, Obj#].addAll(t.mixins).sort)
    verifyEq(t.fits(Obj#), true)
    verifyEq(t.fits(t), true)
    verifyEq(t.fits(Type.find("[java]java.lang::Cloneable")), true)
    verifyEq(t.fits(Str#), false)

    // nullable
    verifyEq(t.toNullable.signature, "[java]java.util::Date?")
    verifyEq(t.toNullable.isNullable, true)
    verifySame(t.toNullable, t.toNullable)
    verifySame(t.toNullable.toNonNullable, t)

    verifyErr(ArgErr#) { Type.find("[Java]java.util::Date") }
    verifyErr(ArgErr#) { Type.find("[java] java.util::Date") }
  }

//////////////////////////////////////////////////////////////////////////
// JavaType: java.lang.Runnable
//////////////////////////////////////////////////////////////////////////

  Void testRunnable()
  {
    t := Type.find("[java]java.lang::Runnable")
    verifySame(Type.find("[java]java.lang::Runnable"), t)

    // naming
    verifyEq(t.name, "Runnable")
    verifyEq(t.toStr, "[java]java.lang::Runnable")

    // flags
    verifyEq(t.isPublic, true)
    verifyEq(t.isInternal, false)
    verifyEq(t.isAbstract, true)
    verifyEq(t.isFinal, false)
    verifyEq(t.isMixin, true)
    verifyEq(t.isEnum, false)
    verifyEq(t.isConst, false)

    // inheritance
    verifyEq(t.base, Obj#)
    verifyEq(t.mixins.isRO, true)
    verifyEq(t.inheritance.isRO, true)
    verifyEq(t.mixins, Type[,])
    verifyEq(t.inheritance, Type[t, Obj#])
  }

//////////////////////////////////////////////////////////////////////////
// Field Reflection
//////////////////////////////////////////////////////////////////////////

  Void testFields()
  {
    t := Type.find("[java]java.lang::System")
    verifyField(t.field("out"), t, Type.find("[java]java.io::PrintStream"))

    t = Type.find("[java]java.io::File")
    verifyField(t.field("separator"), t, Str#)
    verifyField(t.field("separatorChar"), t, Type.find("[java]::char"))
  }

  Void verifyField(Field f, Type parent, Type type)
  {
    verifySame(f.parent, parent)
    verifySame(f.type, type)
    verify(f.type == type)
  }

//////////////////////////////////////////////////////////////////////////
// Method Reflection
//////////////////////////////////////////////////////////////////////////

  Void testMethods()
  {
    t := Type.find("[java]java.io::DataInput")

    // primitives with direct Fantom mappings
    verifyMethod(t.method("readBoolean"), t, Bool#)
    verifyMethod(t.method("readLong"),    t, Int#)
    verifyMethod(t.method("readDouble"),  t, Float#)
    verifyMethod(t.method("readUTF"),     t, Str#)

    // FFI primitives
    verifyMethod(t.slot("readByte"),    t, Type.find("[java]::byte"))
    verifyMethod(t.method("readShort"), t, Type.find("[java]::short"))
    verifyMethod(t.method("readChar"),  t, Type.find("[java]::char"))
    verifyMethod(t.method("readInt"),   t, Type.find("[java]::int"))
    verifyMethod(t.method("readFloat"), t, Type.find("[java]::float"))
  }

  Void verifyMethod(Method m, Type parent, Type ret, Type[] params := Type[,])
  {
    verifySame(m.parent, parent)
    verifySame(m.returns, ret)
    verify(m.returns == ret)
    verifyEq(m.params.isRO, true)
    verifyEq(m.params.size, params.size)
    params.each |Type p, Int i| { verifySame(p, m.params[i].type) }
  }

//////////////////////////////////////////////////////////////////////////
// Dynamic Invoke
//////////////////////////////////////////////////////////////////////////

  Void testDynamicInvoke()
  {
    // basics
    now := DateTime.now
    t := Type.find("[java]java.util::Date")
    date := t.make
    verifyEq(t.method("getYear").callOn(date, [,]), now.year-1900)
    verifyEq(t.method("getYear").call(date), now.year-1900)
    verifyEq(t.method("getYear").callList([date]), now.year-1900)
    verifyEq(date->getYear, now.year-1900)
    verifyEq(date->toString, date.toStr)

    // static field primitive coercion
    x := Type.find("[java]fanx.test::InteropTest").make
    x->snumb = 'a'; verifyEq(x->snumb, 'a')
    x->snums = 'b'; verifyEq(x->snums, 'b')
    x->snumc = 'c'; verifyEq(x->snumc, 'c')
    x->snumi = 'd'; verifyEq(x->snumi, 'd')
    x->snuml = 'e'; verifyEq(x->snuml, 'e')
    x->snumf = 'f'.toFloat; verifyEq(x->snumf, 'f'.toFloat)
    x->snumd = 'g'.toFloat; verifyEq(x->snumd, 'g'.toFloat)

    // methods override fields
    verifyEq(x->numi, 1000)
    x->numi(-1234)
    verifyEq(x->numf, -1234f)
    verifyEq(x->num, -1234)

    // methods
    x->num = 100
    x->xnumb(100); verifyEq(x->xnumb(), 100)
    verifyEq(x->xnums(), 100)
    verifyEq(x->xnumc(), 100)
    verifyEq(x->xnumi(), 100)
    verifyEq(x->xnuml(), 100)
    verifyEq(x->xnumf(), 100.toFloat)
    verifyEq(x->xnumd(), 100.toFloat)

    // verify numi can be looked up as both field and method
    numiField := Type.of(x).field("numi")
    numi := Type.of(x).method("numi")
    verifySame(Type.of(x).slot("numi"), numiField)
    si := Type.of(x).method("si") // static test

    // numi as field
    verifyEq(numiField.get(x), 'i')
    numiField.set(x, 2008)
    verifyEq(numiField.get(x), 2008)

    // numi 4x overloaded - call
    verifyEq(numi.callList([x, 8877]), null)
    verifyEq(numi.callList([x]), 8877)
    verifyEq(numi.callList([x, 6, 4]), 10)
    verifyEq(numi.callList([x, "55"]), 55)
    verifyEq(si.callList(["55", 6]), 61) // static

    // numi 4x overloaded - callX
    verifyEq(numi.call(x, 8877), null)
    verifyEq(numi.call(x), 8877)
    verifyEq(numi.call(x, 6, 4), 10)
    verifyEq(numi.call(x, "55"), 55)
    verifyEq(si.call("55", 6), 61) // static

    // numi 4x overloaded - callOn
    verifyEq(numi.callOn(x, [8877]), null)
    verifyEq(numi.callOn(x, [,]), 8877)
    verifyEq(numi.callOn(x, [6, 4]), 10)
    verifyEq(numi.callOn(x, ["55"]), 55)
    verifyEq(si.callOn(null, ["55", 6]), 61) // static

    // numi 4x overloaded - trap
    x->num = -99
    verifyEq(x->numi, -99)
    verifyEq(x->numi(3, 4), 7)
    verifyEq(x->numi("999"), 999)
    verifyEq(x->si("2", 9), 11) // static

    // Obj[] arrays
    x->initArray
    Obj[] array := x->array1
    verifySame(array[0], x->a)
    verifySame(array[1], x->b)
    verifySame(array[2], x->c)
    array[2] = x->a
    x->array1(array)
    verifySame(array[2], x->a)

    // overloaded by parameter
    verifyEq(x->overload1(this), "(Object)")
    verifyEq(x->overload1("foo"), "(String)")
  }

//////////////////////////////////////////////////////////////////////////
// Mix
//////////////////////////////////////////////////////////////////////////

  Void testMix()
  {
    compile(
     "using [java] java.util

      class Foo
      {
        Random x := Random()
        Random? y
        Random a() { a }
        Random? b() { null }
        Void c(Random x) {}
        Void d(Random? x) {}
      }")

    t := pod.types.first
    verifyMixRandom(t.field("x").type, false)
    verifyMixRandom(t.field("y").type, true)
    verifyMixRandom(t.method("a").returns, false)
    verifyMixRandom(t.method("b").returns, true)
    verifyMixRandom(t.method("c").params[0].type, false)
    verifyMixRandom(t.method("d").params[0].type, true)
  }

  Void verifyMixRandom(Type t, Bool nullable)
  {
    verifyEq(t.isNullable, nullable)
    if (nullable)
      verifyEq(t.signature, "[java]java.util::Random?")
    else
      verifyEq(t.signature, "[java]java.util::Random")
  }
}