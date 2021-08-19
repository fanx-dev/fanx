//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   21 Oct 06  Brian Frank  Creation
//

**
** ReflectionTest
**
class ReflectionTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Basics
//////////////////////////////////////////////////////////////////////////

  Void testBasics()
  {
    t := Str#
    verify(t.slots.isRO)
    verify(t.fields.isRO)
    verify(t.methods.isRO)

    m := t.method("toInt")
    verifyEq(m.name, "toInt")
    verifyEq(m.qname, "sys::Str.toInt")
    //verifyEq(m.returns, Int?#)

    verifyIsType(m.params, Param[]#)
    verifyEq(m.params.size, 2)
    verifyEq(m.params.isRO, true)
    verifyEq(m.params[0].type, Int#)
    verifyEq(m.params[0].name, "radix")
    verifyEq(m.params[0].hasDefault, true)
    verifyEq(m.params[1].type, Bool#)
    verifyEq(m.params[1].name, "checked")
    verifyEq(m.params[1].hasDefault, true)
/*
    verifyType(m.func.params, Param[]#)
    verifyEq(m.func.params.size, 3)
    verifyEq(m.func.params.isRO, true)
    verifyEq(m.func.params[0].type, Str#)
    verifyEq(m.func.params[0].name, "this")
    verifyEq(m.func.params[0].hasDefault, false)
    verifyEq(m.func.params[1].type, Int#)
    verifyEq(m.func.params[1].name, "radix")
    verifyEq(m.func.params[1].hasDefault, true)
    verifyEq(m.func.params[2].type, Bool#)
    verifyEq(m.func.params[2].name, "checked")
    verifyEq(m.func.params[2].hasDefault, true)
*/
    m = t.method("spaces")
    verifyEq(m.params.isRO, true)
    verifyEq(m.params.size, 1)
    verifyEq(m.params[0].name, "n")
    //verifySame(m.params, m.func.params)
  }

//////////////////////////////////////////////////////////////////////////
// Generics
//////////////////////////////////////////////////////////////////////////

  Void testGenerics()
  {
    x := ReflectMixinCls()
    verifyEq(ReflectMixinCls#ints.get(x), null)
    ReflectMixinCls#ints.set(x, Int[3,4])
    verifyEq(ReflectMixinCls#ints.get(x), Int[3,4])
    //verifyErr(ArgErr#) { ReflectMixinCls#ints.set(x, Num[6, 7f]) }

    verifyEq(ReflectMixinCls#map.get(x), Str:Num[:])
    ReflectMixinCls#map.set(x, Str:Num["i":8, "f":9f])
    verifyEq(ReflectMixinCls#map.get(x), Str:Num["i":8, "f":9f])
    ReflectMixinCls#map.set(x, Str:Int["i":6])
    verifyEq(ReflectMixinCls#map.get(x), Str:Int["i":6])
    //verifyErr(ArgErr#) { ReflectMixinCls#map.set(x, Str:Obj["5":4]) }
  }

//////////////////////////////////////////////////////////////////////////
// Invokes
//////////////////////////////////////////////////////////////////////////

  Void testInvoke()
  {
    statics :=
    [
      |Method m->Obj| { return m.call() },
      |Method m->Obj| { return m.call('a') },
      |Method m->Obj| { return m.call('a', 'b') },
      |Method m->Obj| { return m.call('a', 'b', 'c') },
      |Method m->Obj| { return m.call('a', 'b', 'c', 'd') },
      |Method m->Obj| { return m.call('a', 'b', 'c', 'd', 'e') },
      |Method m->Obj| { return m.call('a', 'b', 'c', 'd', 'e', 'f') },
      |Method m->Obj| { return m.call('a', 'b', 'c', 'd', 'e', 'f', 'g') },
      |Method m->Obj| { return m.call('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h') }
    ]

    instances :=
    [
      |Method m->Obj| { return m.call(this) },
      |Method m->Obj| { return m.call(this, 'a') },
      |Method m->Obj| { return m.call(this, 'a', 'b') },
      |Method m->Obj| { return m.call(this, 'a', 'b', 'c') },
      |Method m->Obj| { return m.call(this, 'a', 'b', 'c', 'd') },
      |Method m->Obj| { return m.call(this, 'a', 'b', 'c', 'd', 'e') },
      |Method m->Obj| { return m.call(this, 'a', 'b', 'c', 'd', 'e', 'f') },
      |Method m->Obj| { return m.call(this, 'a', 'b', 'c', 'd', 'e', 'f', 'g') },
      |Method m->Obj| { return m.callOn(this, ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']) },
    ]

    funcs :=
    [
      |Method m->Obj| { return m.func.call(this) },
      |Method m->Obj| { return m.func.call(this, 'a') },
      |Method m->Obj| { return m.func.call(this, 'a', 'b') },
      |Method m->Obj| { return m.func.call(this, 'a', 'b', 'c') },
      |Method m->Obj| { return m.func.call(this, 'a', 'b', 'c', 'd') },
      |Method m->Obj| { return m.func.call(this, 'a', 'b', 'c', 'd', 'e') },
      |Method m->Obj| { return m.func.call(this, 'a', 'b', 'c', 'd', 'e', 'f') },
      |Method m->Obj| { return m.func.call(this, 'a', 'b', 'c', 'd', 'e', 'f', 'g') },
      |Method m->Obj| { return m.func.callOn(this, ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']) },
    ]

    for (i:=0; i<10; ++i)
    {
      // get static sX method and instance iX method
      ms := Type.of(this).method("s$i")
      mi := Type.of(this).method("i$i")
      verifyEq(ms.params.size, i)
      verifyEq(mi.params.size, i)

      // build arguments and expected string result
      args := [,]
      expected := ""
      for (j:=0; j<i; ++j)
      {
        args.add('a'+j)
        expected += ('a'+j).toChar
      }

      // verify explicits less than i fail
      for (j:=0; j<i; ++j)
      {
        verifyErr(ArgErr#) { statics[j]->call(ms) }
        verifyErr(ArgErr#) { instances[j]->call(mi) }
        verifyErr(ArgErr#) { funcs[j]->call(mi) }
      }

      // verify explicits i and greater work (we
      // can always pass more arguments)
      for (j:=i; j<statics.size; ++j)
      {
        verifyEq(statics[j]->call(ms), expected)
        verifyEq(instances[j]->call(mi), expected)
        verifyEq(funcs[j]->call(mi), expected)
      }

      // call() static method
      verifyEq(ms.callList(args), expected)

      // callOn()
      verifyEq(ms.callOn(null, args), expected)
      verifyEq(mi.callOn(this, args), expected)

      // insert this, then call() instance
      args.insert(0, this)
      verifyEq(mi.callList(args), expected)

      // add some extra args to the end, and verify
      // things still work
      args.add('x')
      verifyEq(mi.callList(args), expected)
      args.add('y')
      verifyEq(mi.callList(args), expected)
      args.removeAt(0)
      verifyEq(ms.callList(args), expected)

      // callOn() with extra arguments
      verifyEq(ms.callOn(null, args), expected)
      verifyEq(mi.callOn(this, args), expected)
      verifyEq(ms.func.callOn(null, args), expected)
      verifyEq(mi.func.callOn(this, args), expected)
    }
  }

  static Str s0() { return "" }
  static Str s1(Int a) { return a.toChar }
  static Str s2(Int a, Int b) { return a.toChar+b.toChar }
  static Str s3(Int a, Int b, Int c) { return a.toChar+b.toChar+c.toChar }
  static Str s4(Int a, Int b, Int c, Int d) { return a.toChar+b.toChar+c.toChar+d.toChar }
  static Str s5(Int a, Int b, Int c, Int d, Int e) { return a.toChar+b.toChar+c.toChar+d.toChar+e.toChar }
  static Str s6(Int a, Int b, Int c, Int d, Int e, Int f) { return a.toChar+b.toChar+c.toChar+d.toChar+e.toChar+f.toChar }
  static Str s7(Int a, Int b, Int c, Int d, Int e, Int f, Int g) { return a.toChar+b.toChar+c.toChar+d.toChar+e.toChar+f.toChar+g.toChar }
  static Str s8(Int a, Int b, Int c, Int d, Int e, Int f, Int g, Int h) { return a.toChar+b.toChar+c.toChar+d.toChar+e.toChar+f.toChar+g.toChar+h.toChar }
  static Str s9(Int a, Int b, Int c, Int d, Int e, Int f, Int g, Int h, Int i) { return a.toChar+b.toChar+c.toChar+d.toChar+e.toChar+f.toChar+g.toChar+h.toChar+i.toChar }

  Str i0() { return "" }
  Str i1(Int a) { return a.toChar }
  Str i2(Int a, Int b) { return a.toChar+b.toChar }
  Str i3(Int a, Int b, Int c) { return a.toChar+b.toChar+c.toChar }
  Str i4(Int a, Int b, Int c, Int d) { return a.toChar+b.toChar+c.toChar+d.toChar }
  Str i5(Int a, Int b, Int c, Int d, Int e) { return a.toChar+b.toChar+c.toChar+d.toChar+e.toChar }
  Str i6(Int a, Int b, Int c, Int d, Int e, Int f) { return a.toChar+b.toChar+c.toChar+d.toChar+e.toChar+f.toChar }
  Str i7(Int a, Int b, Int c, Int d, Int e, Int f, Int g) { return a.toChar+b.toChar+c.toChar+d.toChar+e.toChar+f.toChar+g.toChar }
  Str i8(Int a, Int b, Int c, Int d, Int e, Int f, Int g, Int h) { return a.toChar+b.toChar+c.toChar+d.toChar+e.toChar+f.toChar+g.toChar+h.toChar }
  Str i9(Int a, Int b, Int c, Int d, Int e, Int f, Int g, Int h, Int i) { return a.toChar+b.toChar+c.toChar+d.toChar+e.toChar+f.toChar+g.toChar+h.toChar+i.toChar }

//////////////////////////////////////////////////////////////////////////
// Default Params - Static
//////////////////////////////////////////////////////////////////////////

  Void testDefaultParamStatic()
  {
    m := Type.of(this).method("defaultsStatic")

    verifyEq(m.call(), "abc")
    verifyEq(m.call('x'), "xbc")
    verifyEq(m.call('x', 'y'), "xyc")
    verifyEq(m.call('x', 'y', 'z'), "xyz")
    verifyEq(m.call('x', 'y', 'z', '?'), "xyz")
    verifyEq(m.call('x', 'y', 'z', '?', '?'), "xyz")
    verifyEq(m.call('x', 'y', 'z', '?', '?', '?'), "xyz")
    verifyEq(m.call('x', 'y', 'z', '?', '?', '?', '?'), "xyz")
    verifyEq(m.call('x', 'y', 'z', '?', '?', '?', '?', '?'), "xyz")

    verifyEq(m.callList(null), "abc")
    verifyEq(m.callList([,]), "abc")
    verifyEq(m.callList(['x']), "xbc")
    verifyEq(m.callList(['x', 'y']), "xyc")
    verifyEq(m.callList(['x', 'y', 'z']), "xyz")
    verifyEq(m.callList(['x', 'y', 'z', '?']), "xyz")
    verifyEq(m.callList(['x', 'y', 'z', '?', '?']), "xyz")

    verifyEq(m.callOn(null, null), "abc")
    verifyEq(m.callOn(null, [,]), "abc")
    verifyEq(m.callOn(null, ['x']), "xbc")
    verifyEq(m.callOn(null, ['x', 'y']), "xyc")
    verifyEq(m.callOn(null, ['x', 'y', 'z']), "xyz")
    verifyEq(m.callOn(null, ['x', 'y', 'z', '?']), "xyz")
    verifyEq(m.callOn(null, ['x', 'y', 'z', '?', '?']), "xyz")
  }

  static Str defaultsStatic(Int a := 'a', Int b := 'b', Int c := 'c')
  {
    return a.toChar + b.toChar + c.toChar
  }

//////////////////////////////////////////////////////////////////////////
// Default Params - Instance 0
//////////////////////////////////////////////////////////////////////////

  Void testDefaultParamInstance0()
  {
    m := Type.of(this).method("defaultsInstance0")

    verifyErr(ArgErr#) { m.call() }
    verifyEq(m.call(this), "abc")
    verifyEq(m.call(this, 'x'), "xbc")
    verifyEq(m.call(this, 'x', 'y'), "xyc")
    verifyEq(m.call(this, 'x', 'y', 'z'), "xyz")
    verifyEq(m.call(this, 'x', 'y', 'z', '?'), "xyz")
    verifyEq(m.call(this, 'x', 'y', 'z', '?', '?'), "xyz")
    verifyEq(m.call(this, 'x', 'y', 'z', '?', '?', '?'), "xyz")
    verifyEq(m.call(this, 'x', 'y', 'z', '?', '?', '?', '?'), "xyz")

    verifyErr(ArgErr#) { m.callList(null) }
    verifyErr(ArgErr#) { m.callList([,]) }
    verifyEq(m.callList([this]), "abc")
    verifyEq(m.callList([this, 'x']), "xbc")
    verifyEq(m.callList([this, 'x', 'y']), "xyc")
    verifyEq(m.callList([this, 'x', 'y', 'z']), "xyz")
    verifyEq(m.callList([this, 'x', 'y', 'z', '?']), "xyz")
    verifyEq(m.callList([this, 'x', 'y', 'z', '?', '?']), "xyz")

    verifyEq(m.callOn(this, null), "abc")
    verifyEq(m.callOn(this, [,]), "abc")
    verifyEq(m.callOn(this, ['x']), "xbc")
    verifyEq(m.callOn(this, ['x', 'y']), "xyc")
    verifyEq(m.callOn(this, ['x', 'y', 'z']), "xyz")
    verifyEq(m.callOn(this, ['x', 'y', 'z', '?']), "xyz")
    verifyEq(m.callOn(this, ['x', 'y', 'z', '?', '?']), "xyz")
  }

  Str defaultsInstance0(Int a := 'a', Int b := 'b', Int c := 'c')
  {
    return a.toChar + b.toChar + c.toChar
  }

//////////////////////////////////////////////////////////////////////////
// Default Params - Instance 1
//////////////////////////////////////////////////////////////////////////

  Void testDefaultParamInstance1()
  {
    m := Type.of(this).method("defaultsInstance1")

    verifyErr(ArgErr#) { m.call() }
    verifyErr(ArgErr#) { m.call(this) }
    verifyEq(m.call(this, 'x'), "xbc")
    verifyEq(m.call(this, 'x', 'y'), "xyc")
    verifyEq(m.call(this, 'x', 'y', 'z'), "xyz")
    verifyEq(m.call(this, 'x', 'y', 'z', '?'), "xyz")
    verifyEq(m.call(this, 'x', 'y', 'z', '?', '?'), "xyz")
    verifyEq(m.call(this, 'x', 'y', 'z', '?', '?', '?'), "xyz")
    verifyEq(m.call(this, 'x', 'y', 'z', '?', '?', '?', '?'), "xyz")

    verifyErr(ArgErr#) { m.callList(null) }
    verifyErr(ArgErr#) { m.callList([,]) }
    verifyErr(ArgErr#) { m.callList([this]) }
    verifyEq(m.callList([this, 'x']), "xbc")
    verifyEq(m.callList([this, 'x', 'y']), "xyc")
    verifyEq(m.callList([this, 'x', 'y', 'z']), "xyz")
    verifyEq(m.callList([this, 'x', 'y', 'z', '?']), "xyz")
    verifyEq(m.callList([this, 'x', 'y', 'z', '?', '?']), "xyz")

    verifyErr(ArgErr#) { m.callOn(this, null) }
    verifyErr(ArgErr#) { m.callOn(this, [,]) }
    verifyEq(m.callOn(this, ['x']), "xbc")
    verifyEq(m.callOn(this, ['x', 'y']), "xyc")
    verifyEq(m.callOn(this, ['x', 'y', 'z']), "xyz")
    verifyEq(m.callOn(this, ['x', 'y', 'z', '?']), "xyz")
    verifyEq(m.callOn(this, ['x', 'y', 'z', '?', '?']), "xyz")
  }

  Str defaultsInstance1(Int a, Int b := 'b', Int c := 'c')
  {
    return a.toChar + b.toChar + c.toChar
  }

//////////////////////////////////////////////////////////////////////////
// Mixins
//////////////////////////////////////////////////////////////////////////

  Void testMixin()
  {
    // reflect static method
    t := ReflectMixin#
    verifyEq(t.method("add").call(3, 4), 7)
    verifyEq(t.method("mult").call(3, 4), 12)
    verifyEq(t.method("mult").call(3), 30)
    verifyEq(t.method("mult").callList([3]), 30)

    // reflect static field
    verifyEq(t.field("sx").get, 99)
    verifyErr(ReadonlyErr#) { t.field("sx").set(null, 77) }

    // reflect instance method
    obj := ReflectMixinCls.make
    verifyEq(t.method("a").callOn(obj, [,]), 'a')
    verifyEq(t.method("b").callOn(obj, [,]), 'b')
    verifyEq(t.method("c").callOn(obj, [,]), 'C')
    verifyEq(t.method("concat").callOn(obj, [,]), "7;")
    verifyEq(t.method("concat").callOn(obj, [2]), "2;")
    verifyEq(t.method("concat").callOn(obj, [3, "."]), "3.")
    verifyEq(t.method("concat").callList([obj, 3, "."]), "3.")
    verifyEq(t.method("concat").callList([obj, 3]), "3;")
    verifyEq(t.method("concat").callList([obj]), "7;")
    verifyEq(t.method("concat").call(obj, 3, "."), "3.")
    verifyEq(t.method("concat").call(obj, 3), "3;")
    verifyEq(t.method("concat").call(obj), "7;")

    // instance methods with field override
    verifyEq(t.method("ix").callOn(obj, [,]), 'X')
    verifyEq(t.method("iy").callOn(obj, [,]), 'Y')

    // reflect instance fields
    verifyEq(t.field("iz").get(obj), 'Z')
    t.field("iz").set(obj, 1972)
    verifyEq(t.field("iz").get(obj), 1972)

    // invalid sets
    verifyErr(ArgErr#) { Type.of(obj).field("ints").set(obj, "x") }
    //verifyErr(ArgErr#) { Type.of(obj).field("ints").set(obj, ["x"]) }
    verifyErr(ArgErr#) { Type.of(obj).field("iz").set(obj, "x") }

    // trap
    //add is static
    //verifyEq(t->add(4, 6), 10)
    //verifyErr(ReadonlyErr#) { t->sx = 101 }

    verifyEq(obj->a, 'a')
    verifyEq(obj->b, 'b')
    verifyEq(obj->c, 'C')
    verifyEq(obj->concat, "7;")
    verifyEq(obj->concat(-9), "-9;")
    verifyEq(obj->concat(-9, "abc"), "-9abc")
    obj->ix = 321; verifyEq(obj->ix, 321)
    obj->iy = 432; verifyEq(obj->iy, 432)
    obj->iz = 543; verifyEq(obj->iz, 543)
  }

//////////////////////////////////////////////////////////////////////////
// Nullable
//////////////////////////////////////////////////////////////////////////

  Void testNullable()
  {
    t := Int#
    verifyEq(t.pod, Obj#.pod)
    verifyEq(t.name, "Int")
    verifyEq(t.qname, "sys::Int")
    verifyEq(t.signature, "sys::Int")
    verifyEq(t.isNullable, false)
    verifyEq(t.toNullable.signature, "sys::Int?")
    //verifyEq(t.toListOf.signature, "sys::Int[]")
    verifyEq(t.fits(Obj#), true)
    verifyEq(t.fits(Obj?#), true)
    verifyEq(t.fits(Num#), true)
    verifyEq(t.fits(Int#), true)
    verifyEq(t.fits(Int?#), true)
    verifyEq(t.fits(Float#), false)

    t = Int?#
    verifyEq(t.pod, Obj#.pod)
    verifyEq(t.name, "Int")
    verifyEq(t.qname, "sys::Int")
    verifyEq(t.signature, "sys::Int?")
    verifyEq(t.isNullable, true)
    verifyEq(t.toNullable.signature, "sys::Int?")
    //verifyEq(t.toListOf.signature, "sys::Int?[]")
    verifyEq(t.fits(Obj#), true)
    verifyEq(t.fits(Obj?#), true)
    verifyEq(t.fits(Num#), true)
    verifyEq(t.fits(Int#), true)
    verifyEq(t.fits(Int?#), true)
    verifyEq(t.fits(Float#), false)

    m := #nullableMethod
    verifyEq(m.returns.signature, "sys::Int?")
    verifyEq(m.returns.isNullable, true)
    verifyEq(m.params[0].type.signature, "sys::Bool?")
    verifyEq(m.params[0].type.isNullable, true)

    f := #nullableField
    //verifyEq(f.type.signature, "sys::List<Str>?")
    verifyEq(f.type.isNullable, true)
  }

  Int? nullableMethod(Bool? a) { return null }
  Str[]? nullableField

}

**************************************************************************
** ReflectMixin
**************************************************************************

mixin ReflectMixin
{
  static Int add(Int a, Int b) { return a + b }
  static Int mult(Int a, Int b := 10) { return a * b }
  const static Int sx := 99

  Int a() { return 'a' }
  virtual Int b() { return 'b' }
  virtual Int c() { return 'c' }
  Str concat(Int x := 7, Str s := ";") { return x.toStr + s }

  virtual Int ix() { return 'y' }
  abstract Int iy()
  abstract Int iz
}

class ReflectMixinCls : ReflectMixin
{
  override Int c()  { return 'C' }

  override Int ix := 'X'
  override Int iy := 'Y'
  override Int iz := 'Z'

  Int[]? ints
  Str:Num map := Str:Num[:]
}