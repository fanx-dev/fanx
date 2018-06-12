//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Jun 06  Brian Frank  Creation
//

**
** ExprTest
**
class ExprTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Is
//////////////////////////////////////////////////////////////////////////

  Void testIs()
  {
    Obj x := 4

    verifyEq(x is Int, true)
    verifyEq(x is Num, true)
    verifyEq(x is Obj, true)
    verifyEq(x is Str, false)
    verifyEq(null is Str, false)

    verifyEq(x isnot Int, false)
    verifyEq(x isnot Num, false)
    verifyEq(x isnot Obj, false)
    verifyEq(x isnot Str, true)
    verifyEq(null isnot Str, true)

    verifySame(x as Int, x)
    verifySame(x as Num, x)
    verifySame(x as Obj, x)
    verifySame(x as Str, null)
  }

//////////////////////////////////////////////////////////////////////////
// Ternary
//////////////////////////////////////////////////////////////////////////

  Void testTernary()
  {
    x := 3
    y := 2

    verifyEq(x == y ? 't' : 'f', 'f')
    verifyEq(x != y ? 't' : 'f', 't')
    verifyEq(true  ? (x = 0) : (y = 1), 0); verifyEq(x, 0); verifyEq(y, 2);
    verifyEq(false ? (x = 9) : (y = 8), 8); verifyEq(x, 0); verifyEq(y, 8);

    a := 4ns; b := 3ns;
    Str? s := a == b ? "a=$a" : "b=$b"
    verifyEq(s, "b=3ns")
    verifyEq(s = a != b ? null : "b=$b", null)
    verifyEq(s = a != b ? "a=$a" : null,  "a=4ns")
  }

//////////////////////////////////////////////////////////////////////////
// Coercion
//////////////////////////////////////////////////////////////////////////

  Void testCoercion()
  {
    Str? x := null
    verifyErr(NullErr#) |->Str| { return x }
    verifyErr(NullErr#) { Obj? a := null; verifyCoercion(a, "hi") }
    verifyErr(NullErr#) { Str? a := null; verifyCoercion(this, a) }
  }

  Void verifyCoercion(Obj x, Str y) {}

//////////////////////////////////////////////////////////////////////////
// With
//////////////////////////////////////////////////////////////////////////

  Void testWithThisTypes()
  {
    // regression test for bug where This return cast
    // wasn't getting popped off on a with block sub
    y := ExprY { a = ExprZ { add(ExprZ.make) } }
    verifyEq(y.a.kids.size, 1)

    // This return cast popped off on for loop update
    i := 0
    x := ExprZ.make
    for (i=0; i<100; x.add(null)) { i++ }
    verifyEq(i, 100)
  }

//////////////////////////////////////////////////////////////////////////
// Safe Call
//////////////////////////////////////////////////////////////////////////

  Void testSafeCall()
  {
    // various combinations of Str, Int, and Int?
    Int? a := 0xabcd
    verifyEq(a?.toHex, "abcd")
    verifyEq(a?.toHex?.toInt(16), 0xabcd)
    verifyEq(a?.toHex?.toInt(16)?.toDigit, null)
    verifyEq(a?.toHex?.index("b"), 1)
    i := (Int)a?.toHex?.index("c"); verifyEq(i, 2)
    verifyEq(a?.toHex?.index("d")?.toStr, "3")
    verifyEq(a?.toHex?.index("x")?.toStr, null)
    verifyEq(a?.toHex?.get(-1)?.toChar, "d")

    // same combinations against null
    a = null
    verifyEq(a?.toHex, null)
    verifyEq(a?.toHex?.toInt(16), null)
    verifyEq(a?.toHex?.toInt(16)?.toDigit, null)
    verifyEq(a?.toHex?.index("b"), null)
    verifyErr(NullErr#) { j := (Int)a?.toHex?.index("c") }
    verifyEq(a?.toHex?.index("d")?.toStr, null)
    verifyEq(a?.toHex?.index("x")?.toStr, null)
    verifyEq(a?.toHex?.get(-1)?.toChar, null)

    // against myself
    ExprTest? b := this
    verifyEq(b?.mInt(4), 4)
    verifyEq(b?.mInt(4)?.toHex(2), "04")
    i = (Int)b?.mInt(7); verifyEq(i, 7)
    verifyEq(b?.mIntQ(4), 4)
    verifyEq(b?.mIntQ('0')?.fromDigit, 0)
    verifyEq(b?.mIntQ(null)?.max(3), null)

    // against myself null
    b = null
    verifyEq(b?.mInt(4), null)
    verifyEq(b?.mInt(4)?.toHex(2), null)
    verifyErr(NullErr#) { j := (Int)b?.mInt(7) }
    verifyEq(b?.mIntQ(4), null)
    verifyEq(b?.mIntQ('0')?.fromDigit, null)
    verifyEq(b?.mIntQ(null)?.max(3), null)
  }

  Int mInt(Int x) { return x }
  Int? mIntQ(Int? x) { return x }

//////////////////////////////////////////////////////////////////////////
// Safe Dynamic Call
//////////////////////////////////////////////////////////////////////////

  Void testSafeDynamicCall()
  {
    Int? i := 0xab
    verifyEq(i?->toHex, "ab")
    verifyEq(i?->toHex?->size, 2)

    i = null
    verifyEq(i?->toHex, null)
    verifyEq(i?->toHex?->size, null)

    ExprTest? x := this
    verifyEq(x?->mInt(77), 77)
    verifyEq(x?->mInt(77)?->toStr, "77")
    verifyEq(x?->mIntQ(77), 77)
    verifyEq(x?->mIntQ(77)?.toStr, "77")
    verifyEq(x?->mIntQ(null), null)

    x = null
    verifyEq(x?->mInt(77), null)
    verifyEq(x?->mInt(77)?->toStr, null)
    verifyEq(x?->mIntQ(77)?.toStr, null)
    verifyEq(x?->mIntQ(null), null)
  }

//////////////////////////////////////////////////////////////////////////
// Safe Field
//////////////////////////////////////////////////////////////////////////

  Void testSafeField()
  {
    // try with field default values
    ExprTest? x := this
    verifyEq(x?.fInt, 0)
    verifyEq(x?.fIntQ, null)
    verifyEq(x?.fInt?.toHex, "0")
    verifyEq(x?.fIntQ?.toHex, null)
    verifyEq(x?.fStr?.size, null)
    verifyEq(x?.chain?.fInt, null)
    verifyEq(x?.chain?.fIntQ, null)

    // set fields and chain and try
    chain = ExprTest()
    fInt = 0xabcd
    fIntQ = 123
    fStr = "hello"
    verifyEq(x?.fInt, 0xabcd)
    verifyEq(x?.fIntQ, 123)
    verifyEq(x?.fInt?.toHex, "abcd")
    verifyEq(x?.fInt?.toHex?.toInt(16), 0xabcd)
    verifyEq(x?.fIntQ?.toHex, "7b")
    verifyEq(x?.fStr?.size, 5)
    verifyEq(x?.chain?.fInt, 0)
    verifyEq(x?.chain?.fInt?.toHex, "0")
    verifyEq(x?.chain?.fIntQ, null)
    verifyEq(x?.chain?.fIntQ?.toHex, null)

    // try with x as null
    x = null
    verifyEq(x?.fInt, null)
    verifyEq(x?.fIntQ, null)
    verifyEq(x?.fInt?.toHex, null)
    verifyEq(x?.fInt?.toHex?.toInt(16), null)
    verifyEq(x?.fIntQ?.toHex, null)
    verifyEq(x?.fStr?.size, null)
    verifyEq(x?.chain?.fInt, null)
    verifyEq(x?.chain?.fInt?.toHex, null)
    verifyEq(x?.chain?.fIntQ, null)
    verifyEq(x?.chain?.fIntQ?.toHex, null)
  }

  Int fInt
  Int? fIntQ
  Str? fStr
  ExprTest? chain
}

class ExprX { This add(ExprX? k) { kids.add(k); return this } ExprX?[] kids := ExprX?[,]  }
class ExprY : ExprX { ExprX? a }
class ExprZ : ExprX  {}