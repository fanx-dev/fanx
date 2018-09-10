//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Mar 06  Brian Frank  Creation
//

**
** NativeTest
**
class NativeTest : Test
{

  Void testNativeClass()
  {
    x := NativeClass()
    verifyEq(x.typeof, NativeClass#)
    verifyEq(x.typeof.method("add").returns, Int#)
    verifyEq(x.add(2, 3), 5)
  }

  Void testFields()
  {
    verifyFields(Native())
    verifyFields(NativeSub())
  }

  Void verifyFields(Native n)
  {
    verifyEq(n.fX, 6);     n.fX = 99;  verifyEq(n.fX, 99)
    verifyEq(n.fA, 444);   n.fA = 33;  verifyEq(n.fA, 33)
    verifyEq(n.fV, "fV");  n.fV = "?"; verifyEq(n.fV, "?")
    verifyEq(n.fA2, 0xab); n.fA2 = 12; verifyEq(n.fA2, 12)
  }

  Void testMethods()
  {
    // static methods
    verifyEq(Native.doStaticA(), 2006)
    verifyEq(Native.doStaticB(4, 3), 7)

    // verify native make happens before field init (1234)
    // and before constructor (11) code
    n := Native.makeY(5, 6)
    verifyEq(n.getCtorY(), 0)

    // set field in the peer
    n.setPeerZ(55)
    verifyEq(n.getPeerZ, 55)
  }

  Void testParamDefaults()
  {
    verifyParamDefaults(Native())
    verifyParamDefaults(NativeSub())
  }

  Void verifyParamDefaults(Native n)
  {
    // instance
    verifyEq(n.defs1, "a")
    verifyEq(n.defs1("A"), "A")

    verifyEq(n.defs2, "ab")
    verifyEq(n.defs2("A"), "Ab")
    verifyEq(n.defs2("A", "B"), "AB")

    verifyEq(n.defs3("A"), "Abc")
    verifyEq(n.defs3("A", "B"), "ABc")
    verifyEq(n.defs3("A", "B", "C"), "ABC")

    // static
    verifyEq(Native.sdefs1, "x")
    verifyEq(Native.sdefs1("A"), "A")

    verifyEq(Native.sdefs2, "xy")
    verifyEq(Native.sdefs2("A"), "Ay")
    verifyEq(Native.sdefs2("A", "B"), "AB")

    verifyEq(Native.sdefs3("A"), "Ayz")
    verifyEq(Native.sdefs3("A", "B"), "ABz")
    verifyEq(Native.sdefs3("A", "B", "C"), "ABC")
  }

  Void testSubclasses()
  {
    n := NativeSub()
    n.x = 777
    n.setPeerZ(888)
    n.subCheckPeers
    verifyEq(n.subNative, "subNative working")
    verifyEq(n.fX, 777)
    verifyEq(n.subfX, 777)
    verifyEq(n.subGetPeerZ, 888)
  }

  Void testPlatform()
  {
    Native.runPlatformTests(this)
  }

//////////////////////////////////////////////////////////////////////////
// Resources
//////////////////////////////////////////////////////////////////////////

  Void testResources()
  {
    verifyEq(typeof.pod.file(`/res/foo.txt`).readAllStr, "wombat")
    verifyEq(NativeClass.make.readResource("/res/foo.txt"), "wombat")
  }
}

//////////////////////////////////////////////////////////////////////////
// NativeBase
//////////////////////////////////////////////////////////////////////////

abstract class NativeBase : Test
{
  abstract Int? fA
  virtual Str? fV
  abstract Int fA2
}

//////////////////////////////////////////////////////////////////////////
// Native
//////////////////////////////////////////////////////////////////////////

class Native : NativeBase
{
  new make()
  {
  }

  new makeY(Int a, Int b)
  {
    y = a + b
  }

  native static Int doStaticA()
  native static Int doStaticB(Int x, Int y)

  native Int fX
  native override Int? fA
  native override Str? fV
  override Int fA2 := 0xab

  native Int getCtorY()

  native Int getPeerZ()
  native Void setPeerZ(Int z)

  native Str defs1(Str a := "a")
  native Str defs2(Str a := "a", Str b := "b")
  native Str defs3(Str a, Str b := "b", Str c := "c")

  native static Str sdefs1(Str a := "x")
  native static Str sdefs2(Str a := "x", Str b := "y")
  native static Str sdefs3(Str a, Str b := "y", Str c := "z")

  native static Void runPlatformTests(Test test)

  Int x := 6
  Int y := 1234
}

//////////////////////////////////////////////////////////////////////////
// NativeSub
//////////////////////////////////////////////////////////////////////////

class NativeSub : Native
{
  new make() : super() {}

  native Void subCheckPeers()
  native Str subNative()
  native Int subfX()
  native Int subGetPeerZ()
}