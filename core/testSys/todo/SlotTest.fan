//
// Copyright (c) 2007, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Jan 07  Brian Frank  Creation
//

**
** SlotTest
**
@Js
class SlotTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Find
//////////////////////////////////////////////////////////////////////////

  Void testFind()
  {
    verifySame(Slot.find("sys::Int.plus"), Int#plus)
    verifySame(Slot.findMethod("sys::Int.plus"), Int#plus)
    verifySame(Slot.findFunc("sys::Int.minus"), Int#minus.func)
    verifySame(Pod.find("sys::Int.foo", false), null)
    verifyEq(Slot.findField("sys::Int.isSpace", false), null)
    verifyEq(Slot.findMethod("sys::Float.pi", false), null)
    verifyErr(UnknownPodErr#) { Slot.find("badPodName::Foo.bar") }
    verifyErr(UnknownTypeErr#) { Slot.find("sys::Foo.bar") }
    verifyErr(UnknownSlotErr#) { Slot.find("sys::Int.foo") }
    verifyErr(CastErr#) { Slot.findField("sys::Int.isSpace") }
    verifyErr(CastErr#) { Slot.findMethod("sys::Float.pi") }
  }

//////////////////////////////////////////////////////////////////////////
// Find
//////////////////////////////////////////////////////////////////////////

  Void testFlags()
  {
    a := SlotsA.make
    b := SlotsB.make

    s := Type.of(a).slot("a")
    verifyEq(s.qname,      "testSys::SlotsA.a")
    verifyEq(s.isField,     true);    verifyEq(s.isMethod,    false)
    verifyEq(s.isConst,     false);   verifyEq(s.isCtor,      false)
    verifyEq(s.isPublic,    true);    verifyEq(s.isProtected, false)
    verifyEq(s.isPrivate,   false);   verifyEq(s.isInternal,  false)
    verifyEq(s.isNative,    false);   verifyEq(s.isOverride,  false)
    verifyEq(s.isStatic,    false);   verifyEq(s.isSynthetic, false)
    verifyEq(s.isVirtual,   true)

    s = Type.of(b).slot("a")
    verifyEq(s.qname,      "testSys::SlotsB.a")
    verifyEq(s.isField,     true);    verifyEq(s.isMethod,    false)
    verifyEq(s.isConst,     false);   verifyEq(s.isCtor,      false)
    verifyEq(s.isPublic,    true);    verifyEq(s.isProtected, false)
    verifyEq(s.isPrivate,   false);   verifyEq(s.isInternal,  false)
    verifyEq(s.isNative,    false);   verifyEq(s.isOverride,  true)
    verifyEq(s.isStatic,    false);   verifyEq(s.isSynthetic, false)
    verifyEq(s.isVirtual,   false)

    s = Type.of(a).slot("b")
    verifyEq(s.qname,      "testSys::SlotsA.b")
    verifyEq(s.isField,     false);   verifyEq(s.isMethod,   true)
    verifyEq(s.isConst,     false);   verifyEq(s.isCtor,      false)
    verifyEq(s.isPublic,    false);   verifyEq(s.isProtected, true)
    verifyEq(s.isPrivate,   false);   verifyEq(s.isInternal,  false)
    verifyEq(s.isNative,    false);   verifyEq(s.isOverride,  false)
    verifyEq(s.isStatic,    false);   verifyEq(s.isSynthetic, false)
    verifyEq(s.isVirtual,   true)

    s = Type.of(b).slot("b")
    verifyEq(s.qname,      "testSys::SlotsB.b")
    verifyEq(s.isField,     false);   verifyEq(s.isMethod,    true)
    verifyEq(s.isConst,     false);   verifyEq(s.isCtor,      false)
    verifyEq(s.isPublic,    false);   verifyEq(s.isProtected, true)
    verifyEq(s.isPrivate,   false);   verifyEq(s.isInternal,  false)
    verifyEq(s.isNative,    false);   verifyEq(s.isOverride,  true)
    verifyEq(s.isStatic,    false);   verifyEq(s.isSynthetic, false)
    verifyEq(s.isVirtual,   false)

    s = Type.of(a).slot("c")
    verifyEq(s.qname,      "testSys::SlotsA.c")
    verifyEq(s.isField,     true);    verifyEq(s.isMethod,    false)
    verifyEq(s.isConst,     true);    verifyEq(s.isCtor,      false)
    verifyEq(s.isPublic,    false);   verifyEq(s.isProtected, false)
    verifyEq(s.isPrivate,   false);   verifyEq(s.isInternal,  true)
    verifyEq(s.isNative,    false);   verifyEq(s.isOverride,  false)
    verifyEq(s.isStatic,    true);    verifyEq(s.isSynthetic, false)
    verifyEq(s.isVirtual,   false)
  }

}

**************************************************************************
** SlotsA
**************************************************************************

@Js class SlotsA
{
  virtual Str a := "SlotsA"
  protected virtual Str b() { return "SlotsA" }
  internal static const Int c := 77
}

@Js class SlotsB : SlotsA
{
  override final Str a := "SlotsB"
  protected override final Str b() { return "SlotsB" }
}

