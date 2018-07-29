//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Apr 08  Brian Frank  Creation
//

**
** DecimalTest
**
class DecimalTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Is
//////////////////////////////////////////////////////////////////////////

  Void testIs()
  {
    Obj x := 3.0d
    verify(Type.of(x) === Decimal#)

    verify(x is Obj)
    verify(x is Num)
    verify(x is Decimal)
    verifyFalse(x is Int)
  }

//////////////////////////////////////////////////////////////////////////
// Equals
//////////////////////////////////////////////////////////////////////////

  Void testEquals()
  {
    Obj? x := 3.0d

    verify(-2.0d == -2.0d)
    verify(0.0d == 0.0d)
    verify(15d == 0xf.toDecimal)
    verify(1_000.4d == 1000.4d)
    verify(2.0d != 2.001d)
    verify(-2.0d != 0.0d)
    verify(-2.0d != 2.0d)
    verify(x != 3.0f)
    verify(x != true)
    verify(x != null)
    verify(null != x)
    verify(77d.hash == 77d.hash)
  }

//////////////////////////////////////////////////////////////////////////
// Def Val
//////////////////////////////////////////////////////////////////////////

  Void testDefVal()
  {
    verifyEq(Decimal.defVal, 0d)
    verifyEq(Decimal#.make, 0d)
  }

//////////////////////////////////////////////////////////////////////////
// Compare
//////////////////////////////////////////////////////////////////////////

  Void testCompare()
  {
    verify(2.0d < 3.0d)
    verify(null < 3.0d)
    verifyFalse(3.0d < 3.0d)
    verifyFalse(6.0d < 4.0d)
    verifyFalse(3.0d < null)

    verify(3.0d <= 3.0d)
    verify(3.0d <= 3.0d)
    verify(null <= 3d)
    verifyFalse(6d <= 5d)
    verifyFalse(5d <= null)

    verify(-2d > -3d)
    verify(0d > -2d)
    verify(-2d > null)
    verifyFalse(null > 77d)
    verifyFalse(3d > 4d)

    verify(-3d >= -4d)
    verify(-3d >= -3d)
    verify(-3d >= null)
    verifyFalse(null >= 4d)
    verifyFalse(-3d >= -2d)

    verifyEq(3d <=> 4d, -1)
    verifyEq(3d <=> 3d, 0)
    verifyEq(4d <=> 3d, 1)
  }

//////////////////////////////////////////////////////////////////////////
// Operators
//////////////////////////////////////////////////////////////////////////

  Void testOperators()
  {
    x := 5d;   verifyEq(-x, -5d)
    x = -44d; verifyEq(-x, 44d)

    verifyEq(3d*2d,   6d)
    verifyEq(3d*-2d, -6d)
    verifyEq(-2d*3d, -6d)
    verifyEq(-3d*-2d, 6d)
    verifyEq(6.0d * 2, 12.0d)
    verifyEq(6.0d * 0.5f, 3.00d)
    x=2d*2d; x*=3d; verifyEq(x, 12d)

    verifyEq(-16d/4d, -4d)
    verifyEq(16d / 5d, 3.2d)
    verifyEq(15d / 5,  3d)
    verifyEq(15d / 5f, 3d)
    verifyEq(1d / 3d, 0.3333333333d)
    verifyEq(1d / 3,  0.3333333333d)
    verifyEq(1d / 3f, 0.3333333333d)
    x = 20d / 2d; x /= -5d; verifyEq(x, -2d)

    verifyEq(21d%-6d, 3d)
    verifyEq(16d%5d, 1d)
    verifyEq(12d%5d, 2d)
    x = 19d % 10d; x %= 5d; verifyEq(x, 4d)

    verifyEq(2d + 3d,  5d)
    verifyEq(2d + -1d, 1d)
    verifyEq(2d + 44,  46d)
    verifyEq(2.0d + 44f, 46.0d)
    x= 4d + 3d; x+=5d; verifyEq(x, 12d)

    verifyEq(0.7d - 0.3d,  0.4d)
    verifyEq(2.0d - 3.0d, -1.0d)
    verifyEq(7d - 3d,  4d)
    verifyEq(7.0d - 2f,  5.0d)
    x=5d - 2d; x-=-3d; verifyEq(x, 6d)
  }

//////////////////////////////////////////////////////////////////////////
// Increment
//////////////////////////////////////////////////////////////////////////

  Void testIncrement()
  {
    x:=4.0d
    verifyEq(++x, 5.0d); verifyEq(x, 5.0d)
    verifyEq(x++, 5.0d); verifyEq(x, 6.0d)
    verifyEq(--x, 5.0d); verifyEq(x, 5.0d)
    verifyEq(x--, 5.0d); verifyEq(x, 4.0d)
  }

//////////////////////////////////////////////////////////////////////////
// Num
//////////////////////////////////////////////////////////////////////////

  Void testNum()
  {
    verifyEq(3.0d.toInt, 3)
    verifyEq(3.1d.toInt, 3)
    verifyEq(3.9d.toInt, 3)
    verifyEq(4.0d.toInt, 4)
    verifyEq(73939.9555d.toFloat, 73939.9555f)
    //verify(73939.9555d.toDecimal === 73939.9555d)
  }

//////////////////////////////////////////////////////////////////////////
// Math
//////////////////////////////////////////////////////////////////////////

  Void testMath()
  {
    // abs
    verifySame(3d.abs, 3d)
    verifySame(0d.abs, 0d)
    verifyEq((-5.2d).abs, 5.2d)

    // min
    verifyEq(3d.min(2d), 2d)
    verifyEq((-7d).min(-7d), -7d)
    verifyEq(3d.min(5d), 3d)
    verifyEq(8d.min(-5d), -5d)

    // max
    verifyEq(0d.max(1d), 1d)
    verifyEq((-99.0d).max(-6666.0d), -99.0d)
  }

//////////////////////////////////////////////////////////////////////////
// Str
//////////////////////////////////////////////////////////////////////////

  Void testToStr()
  {
    verifyEq(2.00D.toStr, "2.00")
    verifyEq(0.040d.toStr, "0.040")
  }

//////////////////////////////////////////////////////////////////////////
// Parse
//////////////////////////////////////////////////////////////////////////

  Void testParse()
  {
    verifyEq(Decimal.fromStr("0"), 0d)
    verifyEq(Decimal.fromStr("0.8"), 0.8d)
    verifyEq(Decimal.fromStr("99.00"), 99.00d)
    verifyEq(Decimal.fromStr("bad", false),  null)
    verifyErr(ParseErr#) { x := Decimal.fromStr("x.x") }
    verifyErr(ParseErr#) { x := Decimal.fromStr("%\$##", true) }
  }

//////////////////////////////////////////////////////////////////////////
// To Code
//////////////////////////////////////////////////////////////////////////

  Void testToCode()
  {
    verifyEq(0d.toCode, "0d")
    verifyEq((-88.45d).toCode, "-88.45d")
  }

//////////////////////////////////////////////////////////////////////////
// Locale
//////////////////////////////////////////////////////////////////////////

  Void testToLocale()
  {
    // NOTE: most testing is done in FloatTest.testLocale, we just
    //  test decimals which exceed 64-bit int/float range

    verifyToLocale(123_456_789.123_456_789d, "#,####.###", "1,2345,6789.123")
    verifyToLocale(123_456_789_123_456_789_123_456_789d, "#,###.0#",  "123,456,789,123,456,789,123,456,789.0")
    verifyToLocale(-123_456_789_123_456_789_123_456_789.55d, "#,###.0",  "-123,456,789,123,456,789,123,456,789.6")

    // default, alternate locale
    verifyToLocale(12345.68d, null, "12,345.68")
    /*
    Locale("fr-FR").use
    {
      verifyEq(1345.6d.toLocale("#,###.00"), "1\u00a0345,60")
      verifyEq(1345.6d.toLocale("#,###.00"), "1,345.60")
    }
    */
  }

  Void verifyToLocale(Decimal d, Str? pattern, Str expected)
  {
    Locale("en-US").use
    {
      // echo("====> $d $pattern ?= $expected")
      actual := d.toLocale(pattern)
      // echo("   ==> $actual ?= $expected")
      verifyEq(actual, expected)
    }
  }

}