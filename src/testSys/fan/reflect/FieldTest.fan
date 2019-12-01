//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   17 Apr 06  Brian Frank  Creation
//

**
** FieldTest
**
class FieldTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Inside Instance Accessors
//////////////////////////////////////////////////////////////////////////

  Void testInsideInstanceAccessors()
  {
    // inside class - raw field get
    verifyEq(&count, 0); verifyEq(getCounter, 0); verifyEq(setCounter, 0);

    // inside class - raw field set
    &count = 3
    verifyEq(&count, 3); verifyEq(getCounter, 0); verifyEq(setCounter, 0);

    // inside class - getter
    verifyEq(count, 3); verifyEq(getCounter, 1); verifyEq(setCounter, 0);
    verifyEq(count, 3); verifyEq(getCounter, 2); verifyEq(setCounter, 0);

    // inside class - setter
    count = 5
    verifyEq(&count, 5); verifyEq(getCounter, 2); verifyEq(setCounter, 1);
    count = 7
    verifyEq(&count, 7); verifyEq(getCounter, 2); verifyEq(setCounter, 2);
  }

  Int count := 0
  {
    get { getCounter++; return &count }
    set { setCounter++; &count = it }
  }
  Int getCounter := 0
  Int setCounter := 0

//////////////////////////////////////////////////////////////////////////
// Outside Instance Accessors
//////////////////////////////////////////////////////////////////////////

  Void testOutsideInstanceAccessors()
  {
    // outside class - getter
    verifyEq(OutsideAccessor.getCount(this), 0);
      verifyEq(getCounter, 1); verifyEq(setCounter, 0);
    verifyEq(OutsideAccessor.getCount(this), 0);
      verifyEq(getCounter, 2); verifyEq(setCounter, 0);

    // outside class - setter
    OutsideAccessor.setCount(this, 5)
      verifyEq(&count, 5); verifyEq(getCounter, 2); verifyEq(setCounter, 1);
    OutsideAccessor.setCount(this, 7)
      verifyEq(&count, 7); verifyEq(getCounter, 2); verifyEq(setCounter, 2);

    // outside class - setter with leave for return
    verifyEq(OutsideAccessor.setCountLeave(this, 9), 9)
      verifyEq(&count, 9); verifyEq(getCounter, 2); verifyEq(setCounter, 3);
  }

//////////////////////////////////////////////////////////////////////////
// Val Field
//////////////////////////////////////////////////////////////////////////

  Void testValField()
  {
    // verify auto-generated val setter works correctly
    verifyEq(&val, "val")
    verifyEq(val, "val");

    &val = "changed"
    verifyEq(&val, "changed")
    verifyEq(val, "changed")

    val = "again"
    verifyEq(&val, "again")
    verifyEq(val, "again")
  }

  Str val := "val"

//////////////////////////////////////////////////////////////////////////
// Closures Inside Accessor
//////////////////////////////////////////////////////////////////////////

  Void testClosureInsideAccessor()
  {
    verifyEq(closureInsideAccessorCount, 0)
    verifyEq(closureInsideAccessor, "abc")
    verifyEq(closureInsideAccessorCount, 3)
  }

  Str closureInsideAccessor := "abc"
  {
    get
    {
      closureInsideAccessorCount = 0;
      &closureInsideAccessor.each |Int ch| { closureInsideAccessorCount++ }
      return &closureInsideAccessor
    }
  }
  Int closureInsideAccessorCount

//////////////////////////////////////////////////////////////////////////
// Field Defaults
//////////////////////////////////////////////////////////////////////////

  Void testDefaults()
  {
    verifyEq(b1, false)
    verifyEq(b2, null)
    verifyEq(i1, 0)
    verifyEq(i2, null)
    verifyEq(f1, 0f)
    verifyEq(f2, null)
    verifyEq(s1InCtor, null)
    verifyEq(s2, null)
  }

  Bool b1;  Bool? b2
  Int i1;   Int? i2
  Float f1; Float? f2
  Str s1;   Str? s2
  Str? s1InCtor;

  new make() { s1InCtor = s1; s1 = "" }

//////////////////////////////////////////////////////////////////////////
// Reflect Signatures
//////////////////////////////////////////////////////////////////////////

  Void testReflectSignatures()
  {
    // instance field
    t := Type.of(this)
    verify(t.slot("count").isField)
    verifyEq(t.field("count").name, "count")
    verifyEq(t.field("count").type, Int#)

    // instance getter
    verify(t.field("count")->getter != null)
    verifyEq(t.field("count")->getter->name, "count")
    verifyEq(t.field("count")->getter->returns, Int#)
    verifyEq(t.field("count")->getter->params->size, 0)

    // instance setter
    verify(t.field("count")->setter != null)
    verifyEq(t.field("count")->setter->name, "count")
    verifyEq(t.field("count")->setter->returns, Void#)
    verifyEq(t.field("count")->setter->params->size, 1)
    verifyEq(t.field("count")->setter->params->get(0)->type, Int#)
  }

//////////////////////////////////////////////////////////////////////////
// ReflectionInstance
//////////////////////////////////////////////////////////////////////////

  Void testReflectionInstance()
  {
    Field f := Type.of(this).field("count");

    // reflect - getter
    verifyEq(f.get(this), 0);
      verifyEq(getCounter, 1); verifyEq(setCounter, 0);
    verifyEq(f.get(this), 0);
      verifyEq(getCounter, 2); verifyEq(setCounter, 0);
    verifyEq(f->getter->call(this), 0);
      verifyEq(getCounter, 3); verifyEq(setCounter, 0);
    verifyEq(f->getter->callList([this]), 0);
      verifyEq(getCounter, 4); verifyEq(setCounter, 0);

    // reflect - setter
    f.set(this, 5)
      verifyEq(&count, 5); verifyEq(getCounter, 4); verifyEq(setCounter, 1);
    f.set(this, 7)
      verifyEq(&count, 7); verifyEq(getCounter, 4); verifyEq(setCounter, 2);
    f->setter->call(this, 9)
      verifyEq(&count, 9); verifyEq(getCounter, 4); verifyEq(setCounter, 3);
    f->setter->callList([this, -1])
      verifyEq(&count, -1); verifyEq(getCounter, 4); verifyEq(setCounter, 4);
  }

//////////////////////////////////////////////////////////////////////////
// Reflection Const
//////////////////////////////////////////////////////////////////////////

  Void testReflectionConst()
  {
    t := Type.of(this)
    verifyEq(this->constX, 4)
    verifyEq(this->constY, [0,1,2])
    verifyEq(this->constY->isImmutable, true)
    verifyEq(t.field("constX").get(this), 4)
    verifyEq(t.field("constY").get, [0,1,2])

    verifyErr(ReadonlyErr#) { t.field("constX").set(this, 5) }
    verifyErr(ReadonlyErr#) { t.field("constY").set(null, [9, 8, 7]) }

    verifyErr(ReadonlyErr#) { this->constX = 5 }
    verifyErr(ReadonlyErr#) { this->constY = [9, 8, 7] }
  }

  const Int constX := 4
  const static Int[] constY := [0, 1, 2]

//////////////////////////////////////////////////////////////////////////
// Flags
//////////////////////////////////////////////////////////////////////////

  Void testFlags()
  {
    // all public
    t := Type.of(this)
    verifyEq(t.field("flagsAllPublic").isPublic, true)
    verifyEq(t.field("flagsAllPublic")->getter->isPublic, true)
    verifyEq(t.field("flagsAllPublic")->setter->isPublic, true)

    // all internal
    verifyEq(t.field("flagsAllInternal").isInternal, true)
    verifyEq(t.field("flagsAllInternal")->getter->isInternal, true)
    verifyEq(t.field("flagsAllInternal")->setter->isInternal, true)

    // all protected
    verifyEq(t.field("flagsAllProtected").isProtected, true)
    verifyEq(t.field("flagsAllProtected")->getter->isProtected, true)
    verifyEq(t.field("flagsAllProtected")->setter->isProtected, true)

    // all private
    verifyEq(t.field("flagsAllPrivate").isPrivate, true)
    verifyEq(t.field("flagsAllPrivate")->getter->isPrivate, true)
    verifyEq(t.field("flagsAllPrivate")->setter->isPrivate, true)

    // public w/ private set
    verifyEq(t.field("flagsPublicPrivateSet").isPublic, true)
    verifyEq(t.field("flagsPublicPrivateSet")->getter->isPublic, true)
    verifyEq(t.field("flagsPublicPrivateSet")->setter->isPrivate, true)

    // protected w/ private set
    verifyEq(t.field("flagsProtectedInternalSet").isProtected, true)
    verifyEq(t.field("flagsProtectedInternalSet")->getter->isProtected, true)
    verifyEq(t.field("flagsProtectedInternalSet")->setter->isInternal, true)

    // readonly public
    verifyEq(t.field("flagsReadonlyPublic").isPublic, true)
    verifyEq(t.field("flagsReadonlyPublic")->getter->isPublic, true)
    verifyEq(t.field("flagsReadonlyPublic")->setter->isPrivate, true)

    // readonly protected
    verifyEq(t.field("flagsReadonlyProtected").isProtected, true)
    verifyEq(t.field("flagsReadonlyProtected")->getter->isProtected, true)
    verifyEq(t.field("flagsReadonlyProtected")->setter->isPrivate, true)

    // readonly internal
    verifyEq(t.field("flagsReadonlyInternal").isInternal, true)
    verifyEq(t.field("flagsReadonlyInternal")->getter->isInternal, true)
    verifyEq(t.field("flagsReadonlyInternal")->setter->isPrivate, true)
  }

  Int flagsAllPublic
  internal Int flagsAllInternal
  protected Int flagsAllProtected
  private Int flagsAllPrivate

  Int flagsPublicPrivateSet { private set }
  protected Int flagsProtectedInternalSet { get; internal set; }

  public Int flagsReadonlyPublic { private set }
  protected Int flagsReadonlyProtected { private set }
  internal Int flagsReadonlyInternal { private set }

//////////////////////////////////////////////////////////////////////////
// makeSetFunc
//////////////////////////////////////////////////////////////////////////

  Void testMakeSetFunc()
  {
    // simple
    s := FieldTestSerSimple(0, 0)
    f := Field.makeSetFunc([FieldTestSerSimple#a: 6, FieldTestSerSimple#b: 7])
    f(s)
    verifyEq(s.a, 6)
    verifyEq(s.b, 7)

    // const
    f = Field.makeSetFunc([ConstMakeSetTest#x: 9, ConstMakeSetTest#y: null, ConstMakeSetTest#z: [0, 1, 2].toImmutable])
    ConstMakeSetTest c := ConstMakeSetTest#.make([f])
    verifyEq(c.x, 9)
    verifyEq(c.y, null)
    verifyEq(c.z, [0, 1, 2])

    //verifyErr(ReadonlyErr#) { f(c) }
    verifyErr(ReadonlyErr#) { ConstMakeSetTest#.make([Field.makeSetFunc([ConstMakeSetTest#z: this])]) }
  }

//////////////////////////////////////////////////////////////////////////
// Field Inference
//////////////////////////////////////////////////////////////////////////

  Void testFieldInference()
  {
    x := FieldInferTest()
    verifyIsType(x.a, Str[]#)
    verifyIsType(x.b, Str?[]#)
    verifyIsType(x.c, Str[]#)
    verifyIsType(x.d, Int?[]#)
    verifyIsType(x.e, Str:Int#)
    verifyIsType(x.f, Str:Num?#)
    verifyIsType(x.g, Str:Duration#)
  }

//////////////////////////////////////////////////////////////////////////
// FieldNotSet
//////////////////////////////////////////////////////////////////////////

  Void testFieldNotSet()
  {
    // make1
    ok := FieldNotSetTest.make1 { a = "a"; b = "b"; c = "c" }
    verifyErr(FieldNotSetErr#) { x := FieldNotSetTest.make1() }
    verifyErr(FieldNotSetErr#) { x := FieldNotSetTest.make1 {} }
    verifyErr(FieldNotSetErr#) { x := FieldNotSetTest.make1 { b = "b"; c = "c" } }
    verifyErr(FieldNotSetErr#) { x := FieldNotSetTest.make1 { a = "a"; c = "c" } }
    verifyErr(FieldNotSetErr#) { x := FieldNotSetTest.make1 { a = "a"; b = "b"; } }
    verifyErr(FieldNotSetErr#) { x := FieldNotSetTest.make1 { a = "a" } }

    // make2
    ok = FieldNotSetTest.make2(true) {}
    ok = FieldNotSetTest.make2(false) { a = "a"; b = "b"; c = "c" }
    verifyErr(FieldNotSetErr#) { x := FieldNotSetTest.make2(false) { a = "a" } }
    verifyErr(FieldNotSetErr#) { x := FieldNotSetTest.make2(false) { a = "a"; b = "b" } }
  }

}

//////////////////////////////////////////////////////////////////////////
// OutsideAccessor
//////////////////////////////////////////////////////////////////////////

  class OutsideAccessor
{
  static Int getCount(FieldTest test) { return test.count }
  static Void setCount(FieldTest test, Int c) { test.count = c }
  static Int setCountLeave(FieldTest test, Int c) { return test.count = c }
}

//////////////////////////////////////////////////////////////////////////
// OutsideAccessor
//////////////////////////////////////////////////////////////////////////

  const class ConstMakeSetTest
{
  new make(|This|? f) { f?.call(this) }
  const Int x
  const Str? y := "foo"
  const Obj? z
}

//////////////////////////////////////////////////////////////////////////
// FieldInferTest
//////////////////////////////////////////////////////////////////////////

  class FieldInferTest
{
  Str[]  a  := [,]
  Str?[]? b := [null, "x"]
  Obj[]  c  := Str[,]
  Num[]? d  := Int?[,]

  Str:Int e := [:]
  Str:Num? f := [:]
  Str:Obj? g := Str:Duration[:]
}

//////////////////////////////////////////////////////////////////////////
// FieldNotSetTest
//////////////////////////////////////////////////////////////////////////

  class FieldNotSetTest
{
  new make1(|This|? f := null) { f?.call(this) }

  new make2(Bool flag, |This| f)
  {
    if (flag)
    {
      a = b = c = "set"
    }
    else
    {
      f(this)
    }
  }

  const Str a
  Str b
  Str c
  Str? x
}

class FieldTestSerSimple
{
  static FieldTestSerSimple fromStr(Str s)
  {
    return make(s[0..<s.index(",")].toInt, s[s.index(",")+1..-1].toInt)
  }
  new make(Int a, Int b) { this.a = a; this.b = b }
  override Str toStr() { return "$a,$b" }
  override Int hash() { return a.xor(b) }
  override Bool equals(Obj? obj)
  {
    if (obj isnot FieldTestSerSimple) return false
    return a == obj->a && b == obj->b
  }
  Int a
  Int b
}

