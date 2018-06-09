//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Mar 06  Brian Frank  Creation
//

**
** MixinTest
**
@Js class MixinTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  Void testMethods()
  {
    // static on mixin
    verifyEq(MxA.sa,     "sa")
    verifyEq(MxB.sb,     "sb")

    // static on class
    verifyEq(MxClsAB.sa, "sa")
    verifyEq(MxClsAB.sb, "sb")

    // static on class instance
/* TODO - need to pop make off stack?
    verifyEq(MxClsAB.make.sa, "sa")
    verifyEq(MxClsAB.make.sb, "sb")
*/

    // instance on mixin
    verifyEq(MxClsA.make.ia,  "ia")
    verifyEq(MxClsAB.make.ia, "ia")
    verifyEq(MxClsAB.make.ib, "ib")

    // abstract overrides
    verifyEq(MxClsA.make.aa,  "aa")
    verifyEq(MxClsAB.make.aa, "aa")
    verifyEq(MxClsAB.make.ab, "ab")

    // virtual overrides
    verifyEq(MxClsA.make.va,  "override-va")
    verifyEq(MxClsAB.make.va, "va")
    verifyEq(MxClsAB.make.vb, "override-vb")

    // covariant
    a   := MxClsA.make
    ab  := MxClsAB.make
    abi := MxClsABIndirect.make
    verifyEq(ab.coa,  "1")
    verifyEq(ab.cob,  "22")
    verifyEq(ab.coc,  "3")
    verifyEq(abi.coa, "11")
    verifyEq(abi.cob, "12")
    verifyEq(abi.coc, "23")

    // this return
    verifyErr(UnsupportedErr#) { a.thisa }
    verify(a.thisb   ===  a)
    verify(a.thisb.mxClsA == "MxClsA")
    verify(ab.thisa  ===  ab)
    verify(ab.thisb  ===  ab)
    verify(ab.thisa.mxClsAB == "MxClsAB")
    verifyErr(UnresolvedErr#) { abi.thisa }
    verifyErr(IndexErr#) { abi.thisb }
  }

//////////////////////////////////////////////////////////////////////////
// Type
//////////////////////////////////////////////////////////////////////////

  Void testType()
  {
    // sys::Type
    verifyEq(MxA#.pod.name, "testSys")
    verifyEq(MxA#.name,     "MxA")
    verifyEq(MxA#.qname,    "testSys::MxA")
    verify(MxA#.base === Obj#)
    verifyEq(MxA#.mixins, Type[,])
    verify(MxA#.isMixin)
    verifyFalse(MxA#.isClass)
    verifyFalse(MxA#.isEnum)

    verify(MxA#.inheritance.isRO)
    verifyEq(MxA#.inheritance, [MxA#, Obj#])
    verifyEq(MxAB#.inheritance, [MxAB#, Obj#, MxA#, MxB#])
    verifyEq(MxClsA#.inheritance, [MxClsA#, Obj#, MxA#])
    verifyEq(MxClsAB#.inheritance, [MxClsAB#, Obj#, MxA#, MxB#])

    // sys::Type.fits
    verify(MxClsA#.fits(Obj#))
    verify(MxClsA#.fits(MxClsA#))
    verify(MxClsA#.fits(MxA#))
    verifyFalse(MxClsA#.fits(MxB#))
    verifyFalse(MxClsA#.fits(MxClsAB#))
    verify(MxA#.fits(MxA#))
    verify(MxA#.fits(Obj#))
    verify(MxAB#.fits(MxAB#))
    verify(MxAB#.fits(MxA#))
    verify(MxAB#.fits(Obj#))
  }

//////////////////////////////////////////////////////////////////////////
// Is
//////////////////////////////////////////////////////////////////////////

  Void testIs()
  {
    Obj a := MxClsA.make
    verify(a is MxClsA)
    verify(a is MxA)
    verifyFalse(a is MxB)
    verifyFalse(a is MxClsAB)

    Obj ab := MxClsAB.make
    verify(ab is MxA)
    verify(ab is MxB)
    verify(ab is MxClsAB)

    // verify compiler allows assignment
    MxA x := MxClsA.make;
    x = MxClsAB.make;
  }

//////////////////////////////////////////////////////////////////////////
// As
//////////////////////////////////////////////////////////////////////////

  Void testAs()
  {
    Obj x := MxClsAB.make
    verify(Type.of(x) === MxClsAB#)

    MxClsAB? cls := x as MxClsAB;  verify(cls === x)
    MxA?     a   := x as MxA;      verify(a   === x)
    MxB?     b   := x as MxB;      verify(b   === x)
    MxAB?    ab  := x as MxAB;     verify(ab  === null)
    Str?     s   := x as Str;      verify(s   === null)
  }

//////////////////////////////////////////////////////////////////////////
// Obj
//////////////////////////////////////////////////////////////////////////

  Void testObj()
  {
    // because Obj is actually a class in Java/C# and mixins are
    // implemented as interfaces - a mixin doesn't actually implement
    // the sys::Obj type in the VM; the compiler works around this
    // by inserting an Obj in the appropiate places

    MxA? a := MxClsAB.make as MxA;

    // call Obj instance methods on mixin
    verifyEq(a.toStr, "MxClsAB!")
    verify(Type.of(a) === MxClsAB#)

    // call Obj instance operators on mixin
    verifyEq(a > a,  false)
    verifyEq(a >= a, true)
    verifyEq(a <= a, true)
    verifyEq(a < a,  false)
    verifyEq(a == a, true)
    verifyEq(a != a, false)
    verifyEq(a == null, false)
    verifyEq(a != null, true)
    verifyEq(null != a, true)
    verifyEq(null == a, false)
    verifyEq(a <=> a, 0)
    verifyFalse(null === a)
    verifyFalse(a === null)

    // call Obj instance methods inside mixin
    verifyEq(a.wrapToStr1, "MxClsAB!")
    verifyEq(a.wrapToStr2, "MxClsAB!")
    verify(MxA.staticWrapType(a) === MxClsAB#)
  }

//////////////////////////////////////////////////////////////////////////
// Reflection
//////////////////////////////////////////////////////////////////////////

  Void testReflection()
  {
    Slot[] obj := Obj#.slots
    Slot[] a   := MxA#.slots

    // we inherit all of Objs slots except make
    fromObj := a[0..<obj.size-1]
    obj = obj.dup
    obj.remove(Obj#make)
    verifyEq(fromObj, obj)

    // verify the rest of MxA's slots (by name)
    Str[] fromMxA := a[obj.size..-1].map |Slot m->Str| { m.name }
    verifyEq(fromMxA, ["sa", "ia", "wrapToStr1", "wrapToStr2",
      "staticWrapType", "va", "aa", "coa", "cob", "coc", "thisa", "thisb"])
  }

//////////////////////////////////////////////////////////////////////////
// Param Default
//////////////////////////////////////////////////////////////////////////

  Void testParamDefaults()
  {
    x := MxClsDefs.make
    y := MxClsDefs.make as MxDefs
    Str? s := null

    // void - zero args
    x.v0(); verifyEq(x.r(), "v0")
    y.v0(); verifyEq(y.r(), "v0")

    // void - one arg
    x.v1(); verifyEq(x.r(), "a")
    y.v1(); verifyEq(y.r(), "a")
    x.v1("A"); verifyEq(x.r(), "A")
    y.v1("A"); verifyEq(y.r(), "A")

    // void - two args
    x.v2(); verifyEq(x.r(), "ab")
    y.v2(); verifyEq(y.r(), "ab")
    x.v2("A"); verifyEq(x.r(), "Ab")
    y.v2("A"); verifyEq(y.r(), "Ab")
    x.v2("A", "B"); verifyEq(x.r(), "AB")
    y.v2("A", "B"); verifyEq(y.r(), "AB")

    // void - three args
    x.v3(); verifyEq(x.r(), "abc")
    y.v3(); verifyEq(y.r(), "abc")
    x.v3("A"); verifyEq(x.r(), "Abc")
    y.v3("A"); verifyEq(y.r(), "Abc")
    x.v3("A", "B"); verifyEq(x.r(), "ABc")
    y.v3("A", "B"); verifyEq(y.r(), "ABc")
    x.v3("A", "B", "C"); verifyEq(x.r(), "ABC")
    y.v3("A", "B", "C"); verifyEq(y.r(), "ABC")

    // instance - zero args
    s = x.i0(); verifyEq(s, "i0")
    s = y.i0(); verifyEq(s, "i0")

    // instance - one arg
    s = x.i1(); verifyEq(s, "a")
    s = y.i1(); verifyEq(s, "a")
    s = x.i1("x"); verifyEq(s, "x")
    s = y.i1("x"); verifyEq(s, "x")

    // instance - two arg
    s = x.i2(); verifyEq(s, "ab")
    s = y.i2(); verifyEq(s, "ab")
    s = x.i2("x"); verifyEq(s, "xb")
    s = y.i2("x"); verifyEq(s, "xb")
    s = x.i2("x", "y"); verifyEq(s, "xy")
    s = y.i2("x", "y"); verifyEq(s, "xy")

    // instance - three arg
    s = x.i3(); verifyEq(s, "abc")
    s = y.i3(); verifyEq(s, "abc")
    s = x.i3("x"); verifyEq(s, "xbc")
    s = y.i3("x"); verifyEq(s, "xbc")
    s = x.i3("x", "y"); verifyEq(s, "xyc")
    s = y.i3("x", "y"); verifyEq(s, "xyc")
    s = x.i3("x", "y", "z"); verifyEq(s, "xyz")
    s = y.i3("x", "y", "z"); verifyEq(s, "xyz")

    // static - zero args
    s = MxDefs.s0(); verifyEq(s, "s0")

    // static - one arg
    s = MxDefs.s1(); verifyEq(s, "s")
    s = MxDefs.s1("a"); verifyEq(s, "a")

    // static - two arg
    s = MxDefs.s2(); verifyEq(s, "st")
    s = MxDefs.s2("a"); verifyEq(s, "at")
    s = MxDefs.s2("a", "b"); verifyEq(s, "ab")

    // static - three arg
    s = MxDefs.s3(); verifyEq(s, "stu")
    s = MxDefs.s3("a"); verifyEq(s, "atu")
    s = MxDefs.s3("a", "b"); verifyEq(s, "abu")
    s = MxDefs.s3("a", "b", "c"); verifyEq(s, "abc")
  }

//////////////////////////////////////////////////////////////////////////
// Helper Types
//////////////////////////////////////////////////////////////////////////

  Void testMisc()
  {
    // check that mixins generate type constants correctly
    verify(MxClsMisc.make.typeConst == MixinTest#)
  }

//////////////////////////////////////////////////////////////////////////
// Getters
//////////////////////////////////////////////////////////////////////////

  Void testGetterOverride()
  {
    // verify that fields can be used to override getter methods
    x := MxClsGetters.make
    verifyEq(x.a, "a")
    verifyEq(x.b, 'b')
    verifyEq(x.c, 3f)

    // access getters thru mixin/interface
    MxGetters m := (MxGetters)x
    verifyEq(m.a, "a")
    verifyEq(m.b, 'b')
    verifyEq(m.c, 3f)
  }

//////////////////////////////////////////////////////////////////////////
// Indirect
//////////////////////////////////////////////////////////////////////////

  Void testIndirect()
  {
    obj := MxClsABIndirect.make
    verifyEq(obj->ia, "ia")
    verifyEq(obj.va,  "va")
    verifyEq(obj.ib,  "ib")
    verifyEq(obj->vb, "vb")
  }

//////////////////////////////////////////////////////////////////////////
// Inheritance
//////////////////////////////////////////////////////////////////////////

  Void testInheritance()
  {
    verifyInheritance(MxRooGoo#)
    verifyInheritance(MxGooRoo#)
  }

  Void verifyInheritance(Type t)
  {
    a1 := t.make(["a"])
    a2 := t.make(["a"])
    b  := t.make(["b"])

    verify(a1 == a2)
    verify(a1 != b)
    verify(t.method("equals").parent == MxGoo#)
  }

//////////////////////////////////////////////////////////////////////////
// Test special .NET handling
//////////////////////////////////////////////////////////////////////////

  Void testNet()
  {
    verifyNetMixin(NetNormal.make, 22, 23)
    verifyNetMixin(NetChild.make,  5,  7)
    verifyNetMixin(NetChild2.make, 5,  33)
    verifyNetMixin(NetChild3.make, 17, 19)
    verifyNetMixin(NetChild4.make, 17, 99)

    NetDefMixin m := NetDefChild.make
    verifyEq(m.foo(), 8)
    verifyEq(m.foo(5), 10)
    verifyEq(m.foo(1, 3), 4)
  }

  Void verifyNetMixin(NetMixin m, Int a, Int b)
  {
    verifyEq(m.foo(), a)
    verifyEq(m.bar(), b)
  }
}


//////////////////////////////////////////////////////////////////////////
// Helper Types
//////////////////////////////////////////////////////////////////////////

@Js
mixin MxA
{
  static Str sa() { "sa" }
  Str ia() { "ia" }
  Str wrapToStr1() { this.toStr }  // explicit this
  Str wrapToStr2() { toStr }       // implicit this
  static Type staticWrapType(MxA a) { Type.of(a) }
  virtual Str va() { "va" }
  abstract Str aa()
  virtual Obj coa() { "1" }
  virtual Obj cob() { "2" }
  virtual Obj coc() { "3" }
  virtual This thisa() { this }
  virtual This thisb() { this }
}

@Js
mixin MxB
{
  static Str sb() { "sb" }
  Str ib() { "ib" }
  virtual Str vb() { "vb" }
  abstract Str ab()
}

@Js
mixin MxAB : MxA, MxB
{
  override Str coa() { "11" }
  override Str cob() { "12" }
  override This thisa() { throw UnresolvedErr() }
}

@Js
class MxClsA : MxA
{
  override Str aa() { return "aa" }
  override Str va() { return "override-va" }
  override This thisa() { throw UnsupportedErr() }
  Str mxClsA() { return "MxClsA" }
}

@Js
class MxClsAB : MxA, MxB
{
  override Str aa() { return "aa" }
  override Str ab() { return "ab" }
  override Str vb() { return "override-vb" }
  override Str toStr() { return "MxClsAB!" }
  override Str cob() { return "22" }
  Str mxClsAB() { return "MxClsAB" }
}

@Js
class MxClsABIndirect  : MxAB
{
  override Str aa() { return "iaa" }
  override Str ab() { return "iab" }
  override Str coc() { return "23" }
  override This thisb() { throw IndexErr() }
}

@Js
mixin MxDefs
{
  Void v0() { result("v0") }
  Void v1(Str a := "a") { result(a) }
  Void v2(Str a := "a", Str b := "b") { result(a+b) }
  Void v3(Str a := "a", Str b := "b", Str c := "c") { result(a+b+c) }

  Str i0() { return "i0" }
  Str i1(Str a := "a") { return a }
  Str i2(Str a := "a", Str b := "b") { return a+b }
  Str i3(Str a := "a", Str b := "b", Str c := "c") { return a+b+c }

  static Str s0() { return "s0" }
  static Str s1(Str a := "s") { return a }
  static Str s2(Str a := "s", Str b := "t") { return a+b }
  static Str s3(Str a := "s", Str b := "t", Str c := "u") { return a+b+c }

  abstract Str r()
  abstract Void result(Str r)
}

@Js
class MxClsDefs : MxDefs
{
  override Str r() { return _r }
  override Void result(Str r) { _r = r; }
  Str _r := "";
}

@Js mixin MxMisc
{
  Type typeConst() { return MixinTest# }
}

@Js class MxClsMisc : MxMisc
{
}

@Js mixin MxGetters
{
  abstract Str a()
  virtual Int  b() { return 4 }
  virtual Float c() { return 3f }
}

@Js class MxClsGetters : MxGetters
{
  override Str a := "a"
  override Int b := 'b'
}

@Js mixin MxGoo
{
  abstract Str name
  override Bool equals(Obj? that) { return name == ((MxGoo)that).name }
}

@Js mixin MxRoo {}

@Js class MxGooRoo: MxGoo, MxRoo
{
  new make(Str n) { this.name = n }
  override Str name
}

@Js class MxRooGoo: MxRoo, MxGoo
{
  new make(Str n) { this.name = n }
  override Str name
}

//////////////////////////////////////////////////////////////////////////
// Helper Types for .NET tests
//////////////////////////////////////////////////////////////////////////

@Js mixin NetMixin
{
  abstract Int foo()
  abstract Int bar()

  Int nope() { return 9 }
  static Int nope2() { return 11 }
}

@Js class NetNormal : NetMixin
{
  override Int foo() { return 22 }
  override Int bar() { return 23 }
}

@Js class NetBase { Int foo() { return 5 } }
@Js class NetChild : NetBase, NetMixin { override Int bar() { return 7 } }

@Js class NetBase2 : NetBase { Int bar() { return 33 } }
@Js class NetChild2 : NetBase2, NetMixin {}

@Js mixin NetMixin2 : NetMixin  { override Int foo() { return 17 } }
@Js class NetChild3 : NetMixin2 { override Int bar() { return 19 } }

@Js class NetBase3 { Int bar() { return 99 } }
@Js class NetChild4 : NetBase3, NetMixin2 {}

@Js mixin NetDefMixin { abstract Int foo(Int a := 3, Int b := 5) }
@Js class NetDefBase  { Int foo(Int a := 3, Int b := 5) { return a + b } }
@Js class NetDefChild : NetDefBase, NetDefMixin {}