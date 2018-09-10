//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   24 Mar 06  Brian Frank  Creation
//

**
** TypeTest
**
class TypeTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Find
//////////////////////////////////////////////////////////////////////////

  Void testIdentity()
  {
    t := Type.of(this)
    verifyEq(t.isImmutable, true)
    verifyEq(t.toStr, "testSys::TypeTest")
    //verifyEq(t.toLocale, "testSys::TypeTest")
  }

//////////////////////////////////////////////////////////////////////////
// Find
//////////////////////////////////////////////////////////////////////////

  Void testFind()
  {
    verifySame(Type.find("sys::Int"), Int#)
    //verifySame(Type.find("sys::Str[]"), Str[]#)
    verifySame(Type.find("sys::notHereFoo", false), null)
    verifyErr(UnknownTypeErr#) { Type.find("sys::notHereFoo") }
    verifyErr(UnknownPodErr#) { Type.find("notHereFoo::Duh") }
    verifyErr(ArgErr#) { Type.find("sys") }
    verifyErr(ArgErr#) { Type.find("sys::") }
    verifyErr(ArgErr#) { Type.find("::sys") }
    verifyErr(ArgErr#) { Type.find("[]") }
  }

//////////////////////////////////////////////////////////////////////////
// Value Types
//////////////////////////////////////////////////////////////////////////

  Void testValueTypes()
  {
    verifyEq(Bool#.isVal,     true)
    verifyEq(Bool?#.isVal,    true)
    verifyEq(Int#.isVal,      true)
    verifyEq(Int?#.isVal,     true)
    verifyEq(Float#.isVal,    true)
    verifyEq(Float?#.isVal,   true)

    verifyEq(Obj#.isVal,      false)
    verifyEq(Obj?#.isVal,     false)
    verifyEq(Num#.isVal,      false)
    verifyEq(Num?#.isVal,     false)
    //verifyEq(Decimal#.isVal,  false)
    //verifyEq(Decimal?#.isVal, false)
    verifyEq(Str#.isVal,      false)
    verifyEq(Str?#.isVal,     false)

    Obj? x := true
    verifyEq(x is Obj,  true);  verifyEq(x isnot Obj,  false); verifyEq(x as Obj,  true)
    verifyEq(x is Bool, true);  verifyEq(x isnot Bool, false); verifyEq(x as Bool, true)
    verifyEq(x is Num,  false); verifyEq(x isnot Num,  true);  verifyEq(x as Num,  null)
    verifyEq(x is Int,  false); verifyEq(x isnot Int,  true);  verifyEq(x as Int,  null)

    x = 123
    verifyEq(x is Obj,  true);  verifyEq(x isnot Obj,  false); verifyEq(x as Obj,  123)
    verifyEq(x is Bool, false); verifyEq(x isnot Bool, true);  verifyEq(x as Bool, null)
    verifyEq(x is Num,  true);  verifyEq(x isnot Num,  false); verifyEq(x as Num,  123)
    verifyEq(x is Int,  true);  verifyEq(x isnot Int,  false); verifyEq(x as Int,  123)

    x = 123f
    verifyEq(x is Obj,  true);  verifyEq(x isnot Obj,  false); verifyEq(x as Obj,  123f)
    verifyEq(x is Bool, false); verifyEq(x isnot Bool, true);  verifyEq(x as Bool, null)
    verifyEq(x is Num,  true);  verifyEq(x isnot Num,  false); verifyEq(x as Num,  123f)
    verifyEq(x is Int,  false); verifyEq(x isnot Int,  true);  verifyEq(x as Int,  null)
    verifyEq(x is Float, true); verifyEq(x isnot Float,false); verifyEq(x as Float,123f)
  }

//////////////////////////////////////////////////////////////////////////
// Flags
//////////////////////////////////////////////////////////////////////////

  Void testFlags()
  {
    // isAbstract]
    t := Type.of(this)
    verifyEq(Test#.isAbstract, true)
    verifyEq(t.isAbstract, false)

    // isClass
    verifyEq(t.isClass, true)
    verifyEq(EnumAbc#.isClass, false)
    verifyEq(MxA#.isClass, false)

    // isEnum
    verifyEq(t.isEnum, false)
    verifyEq(EnumAbc#.isEnum, true)
    verifyEq(MxA#.isEnum, false)

    // isFacet
    verifyEq(TypeFacetM1#.isFacet, true)
    verifyEq(MxA#.isFacet, false)

    // isFinal
    verifyEq(Bool#.isFinal, true)
    verifyEq(Test#.isFinal, false)

    // isInternal
    verifyEq(t.isInternal, false)
    verifyEq(EnumAbc#.isInternal, true)

    // isMixin
    verifyEq(t.isMixin, false)
    verifyEq(EnumAbc#.isMixin, false)
    verifyEq(MxA#.isMixin, true)

    // isPublic
    verifyEq(t.isPublic, true)
    verifyEq(EnumAbc#.isPublic, false)

    // isSynthetic
    // test below in testSynthetic()
  }

//////////////////////////////////////////////////////////////////////////
// Mixins
//////////////////////////////////////////////////////////////////////////

  Void testMixins()
  {
    verifyEq(Obj#.mixins, Type[,])
    verifyEq(Obj#.mixins.isRO, true)

    verifyEq(MxClsAB#.mixins, [MxA#, MxB#])
    verifyEq(MxClsAB#.mixins.isRO, true)
  }

//////////////////////////////////////////////////////////////////////////
// Inheritance
//////////////////////////////////////////////////////////////////////////

  Void testInheritance()
  {
    verifyEq(Obj#.inheritance, [Obj#])
    verifyEq(Num#.inheritance, [Num#, Obj#])
    verifyEq(Int#.inheritance, [Int#, Num#, Obj#])

    // test Void which is a special case
    //verifyEq(Void#.inheritance, [Void#])

    // mixin types tested in MixinTest.testType

    // test slot inheritance
    t := TypeInheritTestC#

    verifyNotNull(t.slot("c"))
    verifyNotNull(t.slot("b"))
    verifyNotNull(t.slot("a"))
    verifyNotNull(t.slot("m"))

    verifyNotNull(t.slots.find |s| { s.name == "c" })
    verifyNotNull(t.slots.find |s| { s.name == "b" })
    verifyNotNull(t.slots.find |s| { s.name == "a" })
    verifyNotNull(t.slots.find |s| { s.name == "m" })
    verifyNotNull(t.fields.find |f| { f.name == "b" })
    verifyNotNull(t.fields.find |f| { f.name == "a" })
    verifyNotNull(t.methods.find |m| { m.name == "m" })
  }

//////////////////////////////////////////////////////////////////////////
// Fits
//////////////////////////////////////////////////////////////////////////

  Void testFits()
  {
    verifyFits(Float#, Float#, true)
    verifyFits(Float#, Num#,   true)
    verifyFits(Float#, Obj#,   true)
    verifyFits(Float#, Str#,   false)
    verifyFits(Obj#,   Float#, false)

    // list
    verifyFits(Int[]#, Obj#,     true)
    verifyFits(Int[]#, Int[]#,   true)
    verifyFits(Int[]#, Num[]#,   true)
    verifyFits(Int[]#, Obj[]#,   true)
    //verifyFits(Int[]#, Float[]#, false)

    // maps
    verifyFits(Str:Int#, Obj#, true)
    verifyFits(Str:Int#, Str:Int#, true)
    verifyFits(Str:Int#, Str:Num#, true)
    verifyFits(Str:Int#, Str:Obj#, true)
    verifyFits(Str:Int#, Obj:Obj#, true)
    //verifyFits(Str:Int#, Obj:Float#, false)
    //verifyFits(Str:Int#, Str#, false)

    // funcs
    verifyFits(|Int|#, Obj#,   true)
    verifyFits(|Int|#, |Int|#, true)
    verifyFits(|Num|#, |Int|#, true)
    verifyFits(|Obj|#, |Int|#, true)
    //verifyFits(|Float|#, |Int|#, false)

    // void doesn't fit anything
    //verifyFits(Void#, Obj#,  false)
    //verifyFits(Obj#,  Void#, false)

    // casting (in JS it uses fits reflection)
    list1 := (Int[]?) Obj[,]
    list2 := (Int[]?) Obj?[,]
    list3 := (Int?[]?) Obj[,]
    list4 := (Int?[]?) Obj?[,]
    map1 := (Int:Int[]?) Obj:Obj[:]
    map2 := (Int:Int[]?) Obj:Obj?[:]
    map3 := (Int:Int?[]?) Obj:Obj[:]
    map4 := (Int:Int?[]?) Obj:Obj?[:]

    // JS casting bug - see #2453
    // sys::CastErr: [sys::Int:sys::Obj?] cannot be cast to [sys::Int:sys::Str]
    map5 := (Int:Str) Int:Int[1:1].map { it.toStr }

    // always worked okay
    list5 := (Str[]) Int[1].map { it.toStr }
  }

  Void verifyFits(Type a, Type b, Bool expected)
  {
    an := a.toNullable
    bn := b.toNullable
    verifyEq(a.fits(b), expected)
    verifyEq(an.fits(b), expected)
    verifyEq(a.fits(bn), expected)
    verifyEq(an.fits(bn), expected)
  }

//////////////////////////////////////////////////////////////////////////
// Generics
//////////////////////////////////////////////////////////////////////////
/*
  Void testIsGeneric()
  {
    verifyEq(Obj#.isGeneric,    false)
    verifyEq(Str#.isGeneric,    false)
    verifyEq(Str[]#.isGeneric,  false)
    verifyEq(Method#.isGeneric, false)
    verifyEq(List#.isGeneric,   true)
    verifyEq(Map#.isGeneric,    true)
    verifyEq(Func#.isGeneric,   true)
  }
*/
/*
  Void testParams()
  {
    verifyEq(Str#.params, Str:Type[:])
    verifyEq(Str#.params.isRO, true)

    verifyEq(Str[]#.params, ["V":Str#, "L":Str[]#])
    verifyEq(Str[]#.params.isRO, true)

    verifyEq(Int:Slot[]#.params, ["K":Int#, "V":Slot[]#, "M":Int:Slot[]#])
    verifyEq(Int:Slot[]#.params.isRO, true)

    verifyEq(|Int a, Float b->Bool|#.params, ["A":Int#, "B":Float#, "R":Bool#])
    verifyEq(|Int a, Float b->Bool|#.params.isRO, true)
  }
  */
/*
  Void testParameterization()
  {
    verifyEq(List#.parameterize(["V":Bool#]), Bool[]#)
    verifyEq(List#.parameterize(["V":Bool[]#]), Bool[][]#)
    verifyErr(ArgErr#) { List#.parameterize(["X":Bool[]#]) }

    verifyEq(Map#.parameterize(["K":Str#, "V":Slot#]), Str:Slot#)
    verifyEq(Map#.parameterize(["K":Str#, "V":Int[]#]), Str:Int[]#)
    verifyErr(ArgErr#) { Map#.parameterize(["V":Bool[]#]) }
    verifyErr(ArgErr#) { Map#.parameterize(["K":Bool[]#]) }

    verifyEq(Func#.parameterize(["R":Void#]), |->|#)
    verifyEq(Func#.parameterize(["A":Str#, "R":Int#]), |Str a->Int|#)
    verifyEq(Func#.parameterize(["A":Str#, "B":Bool#, "C":Int#, "R":Float#]),
      |Str a, Bool b, Int c->Float|#)
    verifyErr(ArgErr#) { Func#.parameterize(["A":Bool[]#]) }

    verifyErr(UnsupportedErr#) { Str#.parameterize(["X":Void#]) }
    verifyErr(UnsupportedErr#) { Str[]#.parameterize(["X":Void#]) }
  }
*/
/*
  Void testToListOf()
  {
    verify(Str#.toListOf.fits(Str[]#))
    verify(Str[]#.toListOf.fits(Str[][]#))
    verify(Str[][]#.toListOf.fits(Str[][][]#))
    verify(Str:Buf#.toListOf.fits([Str:Buf][]#))
  }

  Void testEmptyList()
  {
    s :=  Str#.emptyList
    verifyEq(s, Str[,])
    verifyEq(s.isImmutable, true)
    //verifyEq(Type.of(s).signature, "sys::Str[]")
    verifySame(s, Str#.emptyList)
    verifyErr(ReadonlyErr#) { s.add("foo") }

    sl :=  Str[]#.emptyList
    verifyEq(sl, Str[][,])
    verifyEq(sl.isImmutable, true)
    //verifyEq(Type.of(sl).signature, "sys::Str[][]")
    verifySame(sl, Str[]#.emptyList)
    verifyNotSame(sl, s)
    verifyErr(ReadonlyErr#) { sl.add(Str[,]) }
  }
*/
//////////////////////////////////////////////////////////////////////////
// Reflection
//////////////////////////////////////////////////////////////////////////

  Void testMake()
  {
    verify(File#.make([`foo`]) is File)
    verifyEq(File#.make([`foo`])->uri, `foo`)
    //verifyErr(Err#) { Bool.type.make }
    verifyErr(Err#) { TypeInheritTestAbstract#.make }
    verifyErr(Err#) { TypeInheritTestM1#.make }
  }

//////////////////////////////////////////////////////////////////////////
// Synthetic
//////////////////////////////////////////////////////////////////////////

  Void testSynthetic()
  {
    Pod.of(this).types.each |Type t|
    {
      verifyEq(t.isSynthetic, t.name.index("\$") != null, t.toStr)
      verifySlotsSynthetic(t)
    }
  }

  Void verifySlotsSynthetic(Type t)
  {
    t.slots.each |Slot slot|
    {
      if (slot.parent.isSynthetic || slot.name.index("\$") != null)
        verify(slot.isSynthetic, slot.toStr)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Generic Parameters
//////////////////////////////////////////////////////////////////////////
/*
  Void testGenericParameters()
  {
    // TODO - what do we really want for these guys?
    v := List#get.returns
    verifyEq(v.name, "V")
    verifyEq(v.qname, "sys::V")
    verifySame(v.pod, Obj#.pod)
    verifySame(v.base, Obj#)
    verifyEq(v.mixins, Type[,])
    verifyEq(v.mixins.ro, Type[,])
  }
*/
//////////////////////////////////////////////////////////////////////////
// Inference
//////////////////////////////////////////////////////////////////////////
/*
  Void testInference()
  {
    verifyEq([2].typeof,   Int[]#)
    verifyEq([num].typeof, Num[]#)
    verifyEq([a].typeof,   TiA[]#)
    verifyEq([an].typeof,  TiA?[]#)

    verifyEq([2, 3].typeof,   Int[]#)
    verifyEq([2f, 3].typeof,  Num[]#)
    verifyEq([3, 2f].typeof,  Num[]#)
    verifyEq([3, num].typeof, Num[]#)
    verifyEq([num, 3].typeof, Num[]#)

    verifyEq([a, a, a].typeof,  TiA[]#)
    verifyEq([b, bn, b].typeof, TiB?[]#)
    verifyEq([c, c, c].typeof,  TiC[]#)
    verifyEq([a, b, c].typeof,  TiA[]#)
    verifyEq([c, b, a].typeof,  TiA[]#)
    verifyEq([c, b, b].typeof,  TiB[]#)
    verifyEq([cn, b, b].typeof, TiB?[]#)
    verifyEq([b, c, bn].typeof, TiB?[]#)

    verifyEq([b, c, m].typeof,  Obj[]#)
    verifyEq([c, mn, c].typeof, Obj?[]#)
    verifyEq([m, m].typeof,     TiM[]#)
    verifyEq([m, mn].typeof,    TiM?[]#)
    verifyEq([mn, m].typeof,    TiM?[]#)
    verifyEq([m, on].typeof,    Obj?[]#)
    verifyEq([on, m].typeof,    Obj?[]#)
    verifyEq([on, on].typeof,   TiO?[]#)

    verifyEq([[2], [3]].typeof,   Int[][]#)
    verifyEq([[2f], [3]].typeof,  Num[][]#)
    verifyEq([[3], [2f]].typeof,  Num[][]#)
    verifyEq([[3], [num]].typeof, Num[][]#)
    verifyEq([[num], [3]].typeof, Num[][]#)

    verifyEq([[a], [a, b], [a]].typeof,  TiA[][]#)
    verifyEq([[b], [bn, b], [b]].typeof, TiB?[][]#)
    verifyEq([[c], [c], [c]].typeof,  TiC[][]#)
    verifyEq([[a], [b], [c, c]].typeof,  TiA[][]#)
    verifyEq([[c], [b, c], [a]].typeof,  TiA[][]#)
    verifyEq([[c], [b], [b]].typeof,  TiB[][]#)
    verifyEq([[cn], [b], [b]].typeof, TiB?[][]#)
    verifyEq([[b], [c], [bn]].typeof, TiB?[][]#)
    verifyEq([[b], [c], [m]].typeof,  Obj[][]#)
    verifyEq([[c], [mn, m], [c]].typeof, Obj?[][]#)

    verifyEq([ [[b],[c]], [[cn]]  ].typeof, TiB?[][][]#)

    verifyEq([func1, func1].typeof,  |->Int|[]#)
    verifyEq([func1n, func1].typeof, |->Int|?[]#)
    verifyEq([func1, func1n].typeof, |->Int|?[]#)
    verifyEq([func1, func2].typeof,  Func[]#)
    verifyEq([func1n, func2].typeof, Func?[]#)

    verifyEq([1:a, 2:a].typeof,  [Int:TiA]#)
    verifyEq([1:an, 2:a].typeof, [Int:TiA?]#)
    verifyEq([1:a, 2:an].typeof, [Int:TiA?]#)
    verifyEq([1:b, 2:c].typeof,  [Int:TiB]#)
    verifyEq([1:b, 2:cn].typeof,  [Int:TiB?]#)

    verifyEq([[1:b, 2:cn], [1:b, 2:cn]].typeof,  [Int:TiB?][]#)
    verifyEq([[1:b, 2:c], [1:b, 2:cn]].typeof,  Map[]#)
    verifyEq([[1:b, 2:a], [1:b, 2:c]].typeof,  Map[]#)
    verifyEq([[1:b, 2:a], [1:b, 2:cn]].typeof,  Map[]#)
    verifyEq([[1:b, 2:a], [1:b, 2:cn], null].typeof,  Map?[]#)
  }
*/
  private Num  num() { 4 }
  private TiA  a()   { TiA() }
  private TiA? an()  { TiA() }
  private TiB  b()   { TiB() }
  private TiB? bn()  { TiB() }
  private TiC  c()   { TiC() }
  private TiC? cn()  { TiC() }
  private TiM  m()   { TiC() }
  private TiM? mn()  { TiC() }
  private TiO? on()  { null }
  private |->Int| func1()   { |->Int| {3} }
  private |->Int|? func1n() { |->Int| {3} }
  private |->Num| func2()   { |->Num| {3} }
}

facet class TypeFacetM1 { const Str? n }

**************************************************************************
** Inference Types
**************************************************************************

  internal class TiA {}
  internal class TiB : TiA, TiM {}
  internal class TiC : TiB {}
  internal mixin TiM {}
  internal mixin TiO : TiM {}

**************************************************************************
** Inherticance Types
**************************************************************************

  abstract class TypeInheritTestAbstract {}
  internal class TypeInheritTestA { Int a := 5  }
  internal mixin TypeInheritTestM1 { Int m() { 10 } }
  internal class TypeInheritTestB : TypeInheritTestA { Str b := "foo" }
  internal class TypeInheritTestC : TypeInheritTestB, TypeInheritTestM1
{
  Float c := 7.5f
}