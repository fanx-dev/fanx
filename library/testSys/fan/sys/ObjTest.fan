//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   17 Jun 06  Brian Frank  Creation
//

**
** ObjTest
**
class ObjTest : Test
{

//////////////////////////////////////////////////////////////////////////
// IsImmutable
//////////////////////////////////////////////////////////////////////////

  Void testIsImmutable()
  {
    verifyEq(true.isImmutable,  true)
    verifyEq("foo".isImmutable, true)
    verifyEq(88.isImmutable,    true)
    verifyEq(88f.isImmutable,   true)
    verifyEq(88sec.isImmutable, true)
    verifyEq(IOErr.make.isImmutable, true)

    verifyEq(this.isImmutable, false)
    //verifyEq(Buf.make.isImmutable, false)

    verifyEq([0, 1, 2].isImmutable, false)
    verifyEq([0, 1, 2].toImmutable.isImmutable, true)

    verifyEq([0:"0"].isImmutable, false)
    verifyEq([0:"0"].toImmutable.isImmutable, true)
  }

//////////////////////////////////////////////////////////////////////////
// ToImmutable
//////////////////////////////////////////////////////////////////////////

  Void testToImmutable()
  {
    s := "hello"
    verifySame(s.toImmutable, s)
    verifySame(Str#.toImmutable, Str#)
    verifyEq([0, 1, 2].toImmutable, [0, 1, 2])
    //TODO
    //verifyEq([0:"zero"].toImmutable, [0:"zero"])
    verifyErr(NotImmutableErr#) { this.toImmutable }
  }

//////////////////////////////////////////////////////////////////////////
// Virtual Calls
//////////////////////////////////////////////////////////////////////////

  **
  ** Virtual calls on Obj require special testing, because they
  ** need to be handled on both classes and mixins.
  **
  Void testVirtualCalls()
  {
    // use class type
    ObjMixinImpl a := ObjMixinImpl.make()
    ObjMixinImpl b := ObjMixinImpl.make()

    verifyType(a, ObjMixinImpl#)
    verifyEq(a == a, true)
    verifyEq(a == b, false)
    verifyEq(a.equals(a), true)
    verifyEq(a.equals(b), false)
    verifyEq(a.hash, 99)
    verifyEq(a.toStr, "x")

    // repeat using mixin type
    ObjMixin ma := ObjMixinImpl.make()
    ObjMixin mb := ObjMixinImpl.make()

    verifyType(ma, ObjMixinImpl#)
    verifyEq(ma == ma, true)
    verifyEq(ma == mb, false)
    verifyEq(ma.equals(ma), true)
    verifyEq(ma.equals(mb), false)
    verifyEq(ma.hash, 99)
    verifyEq(ma.toStr, "x")
  }

//////////////////////////////////////////////////////////////////////////
// Obj Field
//////////////////////////////////////////////////////////////////////////

  **
  ** Virtual calls on Obj require special testing, because they
  ** need to be handled on both classes and mixins.
  **
  Void testObjField()
  {
    verifyEq(ObjWrapper.make("s").obj, "s")
    verifyEq(ObjWrapper.make("s"), ObjWrapper.make("s"))
    verifyNotEq(ObjWrapper.make("s"), ObjWrapper.make(7))
  }

//////////////////////////////////////////////////////////////////////////
// Unsafe
//////////////////////////////////////////////////////////////////////////

  Void testUnsafe()
  {
    verifyEq(this.isImmutable, false)
    verifyEq(Unsafe(this).isImmutable, true)
    verifyType(Unsafe(this), Unsafe#)
    verifyEq(Type.of(Unsafe(this)).qname, "std::Unsafe")
    verifySame(Unsafe(this).val, this)
  }

}

//////////////////////////////////////////////////////////////////////////
// ObjMixin
//////////////////////////////////////////////////////////////////////////

mixin ObjMixin
{
}

class ObjMixinImpl : ObjMixin
{
  override Int hash() { return 99 }
  override Str toStr() { return "x" }
}

//////////////////////////////////////////////////////////////////////////
// ObjWrapper
//////////////////////////////////////////////////////////////////////////

class ObjWrapper
{
  new make(Obj obj) { this.obj = obj }
  override Int hash() { return obj.hash(); }
  override Bool equals(Obj? that) { return ((ObjWrapper)that).obj == obj }
  Obj obj
}