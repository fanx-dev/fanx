//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   8 Mar 06  Brian Frank  Creation
//

**
** FloatTest
**
class FloatTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Def Val
//////////////////////////////////////////////////////////////////////////

  Void testDefVal()
  {
    verifyEq(Float.defVal, 0f)
    verifyEq(Float#.make, 0f)
  }

//////////////////////////////////////////////////////////////////////////
// Is
//////////////////////////////////////////////////////////////////////////

  Void testIs()
  {
    Obj x := 3.0f
    verify(Type.of(x) === Float#)
    verify(x.isImmutable)

    verify(x is Obj)
    verify(x is Num)
    verify(x is Float)
    verifyFalse(x is Int)

    y := -4f
    verify(Type.of(y) === Float#)
    verify(y.isImmutable)
  }

//////////////////////////////////////////////////////////////////////////
// Neg Zero
//////////////////////////////////////////////////////////////////////////

  Void testNegZero()
  {
    verifyEq(0f.isNegZero, false)
    verifyEq(0f.negate.toStr, "-0.0")
    verifyEq(0f.negate.isNegZero, true)
    verifyEq(Float.fromStr("0").isNegZero, false)
    verifyEq(Float.fromStr("-0").isNegZero, true)
    verifyEq(Float.fromStr("-0.008").isNegZero, false)
    verifyEq(Float.posInf.isNegZero, false)
    verifyEq(Float.negInf.isNegZero, false)
    verifyEq(Float.nan.isNegZero, false)

    // can't use equality checks safely
    verifyEq(0f.negate.toStr, "-0.0")
    verifyEq(0f.negate.normNegZero.toStr, "0.0")
    verifyEq(Float.fromStr("-0").toStr, "-0.0")
    verifyEq(Float.fromStr("-0").normNegZero.toStr, "0.0")
    verifyEq(Float.fromStr("0").toStr, "0.0")
    verifyEq(Float.fromStr("-0.2").normNegZero.toStr, "-0.2")
    verifyEq(Float.fromStr("1.6").normNegZero.toStr, "1.6")
  }

//////////////////////////////////////////////////////////////////////////
// Equals
//////////////////////////////////////////////////////////////////////////

  Void testEquals()
  {
    Obj? x := 3.0f

    verify(-2.0f == -2.0f)
    verify(0.0f == 0.0f)
    verify(15.0f == 0xf.toFloat)
    verify(1_000.4f == 1000.4f)
    verify(3f == (Float?)3f)
    verify(x == 3f)
    verifyFalse(x == 3.3f)
    verifyFalse(-3f == (Float?)3f)

    verify(2.0f != 2.001f)
    verify(-2.0f != 0.0f)
    verify(-2.0f != 2.0f)
    verify(-2.0f != x)
    verify(x != -2.0f)
    verifyFalse(x != 3.0f)
    verifyFalse((Float?)3.0f != x)
    verify(x != true)
    verify(x != null)
    verify(null != x)

    verify(Float.posInf != 0.0f)
    verify(Float.posInf == Float.posInf)
    verify(Float.negInf != 0.0f)
    verify(Float.posInf != Float.negInf)
    verify(Float.negInf == Float.negInf)
    verifyFalse(Float.nan == Float.nan)
    verifyFalse(Float.nan == 0f)
    verifyFalse(0f == Float.nan)

    verify(Float.nan != 0.0f)
    verify(4f != Float.nan)
    verify(Float.nan != Float.posInf)
    verify(Float.nan != Float.negInf)
    verify(Float.nan != Float.nan)

    verifyFalse(Float.nan.equals(0.0f))
    verifyFalse(4f.equals(Float.nan))
    verifyFalse(Float.nan.equals(Float.posInf))
    verifyFalse(Float.nan.equals(Float.negInf))
    verifyFalse(Float.nan.equals(Float.nan))
    verify(Float.posInf.equals(Float.posInf))
    verify(Float.negInf.equals(Float.negInf))

    verifyEq(Float.nan.isNaN, true)
    verifyEq(55f.isNaN, false)
    verifyEq(Float.negInf.isNaN, false)
  }

//////////////////////////////////////////////////////////////////////////
// Compare
//////////////////////////////////////////////////////////////////////////

  Void testCompare()
  {
    Float? x := 5f

    verify(2.0f < 3.0f)
    verify(2.0f < x)
    verifyFalse(5.0f < x)
    verifyFalse(x < 2f)
    verifyFalse(x < 5f)
    verify(null < 3.0f)
    verifyFalse(0.1f < Float.nan)
    verifyFalse(Float.nan < 0.1f)
    verifyFalse(3.0f < 3.0f)
    verifyFalse(6.0f < 4.0f)
    verifyFalse(3.0f < null)

    verify(3.0f <= 3.0f)
    verify(3.0f <= 3.0f)
    verify(x <= 5f)
    verify(x <= 6f)
    verify(5f <= x)
    verify(3f <= x)
    verify(null <= 3f)
    verifyFalse(0.1f <= Float.nan)
    verifyFalse(Float.nan <= 0.1f)
    verifyFalse(Float.nan <= Float.nan)
    verify(Float.posInf <= Float.posInf)
    verifyFalse(6f <= 5f)
    verifyFalse(5f <= null)

    verify(-2f > -3f)
    verify(0f > -2f)
    verify(6f > x)
    verifyFalse(5f > x)
    verify(x < 77f)
    verifyFalse(x < 5f)
    verify(-2f > null)
    verifyFalse(8f > Float.nan)
    verifyFalse(Float.nan > 8f)
    verify(Float.posInf > 1e17f)
    verify(Float.posInf > Float.negInf)
    verifyFalse(Float.nan > Float.posInf)
    verifyFalse(null > 77f)
    verifyFalse(3f > 4f)

    verify(-3f >= -4f)
    verify(-3f >= -3f)
    verify(x >= -4f)
    verify(x >= 5f)
    verify(5f <= x)
    verifyFalse(6f <= x)
    verify(-3f >= null)
    verifyFalse(8f >= Float.nan)
    verifyFalse(Float.nan >= 8f)
    verifyFalse(null >= 4f)
    verifyFalse(-3f >= -2f)

    verifyEq(3f <=> 4f, -1)
    verifyEq(3f <=> 3f, 0)
    verifyEq(4f <=> 3f, 1)
    verifyEq(5f <=> x, 0)
    verifyEq(6f <=> x, 1)
    verifyEq(x <=> 7f, -1)
    verifyEq(x <=> 5f, 0)

    verifyEq(Float.posInf <=> 99f, 1)
    verifyEq(Float.posInf <=> Float.posInf, 0)
    verifyEq(Float.posInf <=> Float.negInf, 1)
    verifyEq(Float.negInf <=> 99f, -1)
    verifyEq(Float.negInf <=> 0f, -1)

    verifyEq(Float.nan <=> 0f, -1)
    verifyEq(Float.nan.compare(0f), -1)
    verifyEq(Float.nan <=> Float.nan, 0)
    verifyEq(9e10f <=> Float.nan, 1)
    verifyEq(null <=> Float.nan, -1)
    verifyEq(Float.nan <=> null, 1)
    verifyEq(Float.posInf <=> Float.nan, 1)
    verifyEq(Float.posInf.compare(Float.nan), 1)
    verifyEq(Float.negInf <=> Float.nan, 1)
    verifyEq(Float.nan <=> -9999f, -1)
  }

//////////////////////////////////////////////////////////////////////////
// Specials (NaN, Inf)
//////////////////////////////////////////////////////////////////////////

  Void testSpecial()
  {
    verifySpecial(0f, 0f, true, 0)
    verifySpecial(Float.posInf, Float.posInf, true, 0)
    verifySpecial(Float.negInf, Float.negInf, true, 0)
    verifySpecial(Float.nan, Float.nan, false, 0)

    verifySpecial(Float.nan, 0f, false, -1)
    verifySpecial(0f, Float.nan, false, +1)
  }

  Void verifySpecial(Float a, Float b, Bool eq, Int cmp)
  {
    verifyEq(a == b, eq)
    verifyEq(a != b, !eq)
    verifyEq(a.equals(b), eq)
    verifyEq(a <=> b, cmp)
    if (cmp == 0) verify(a.approx(b))
  }

//////////////////////////////////////////////////////////////////////////
// Operators
//////////////////////////////////////////////////////////////////////////

  Void testOperators()
  {
    x := 5f;   verifyEq(-x, -5f)
    x = -44f; verifyEq(-x, 44f)
    Float? y

    verifyEq(3f*2f,   6f)
    verifyEq(3f*-2f, -6f)
    verifyEq(-2f*3f, -6f)
    verifyEq(-3f*-2f, 6f)
    verifyEq(3f * -3, -9f)
    //verifyEq(3.2f * 10d, 32.0d)
    x=2f*2f; x*=3f; verifyEq(x, 12f)

    verifyEq(-16f/4f, -4f)
    verifyEq(16f / 5f, 3.2f)
    verifyEq(16f / 5, 3.2f)
    //verifyEq(16f / 5d, 3.2d)
    x = 20f / 2f; x /= -5f; verifyEq(x, -2f)

    verifyEq(21f%-6f, 3f)
    verifyEq(16f%5f, 1f)
    verifyEq(12f%5f, 2f)
    verifyEq(12f % 5, 2f)
    //verifyEq(12f % 5.0d, 2.0d)
    y = 19f % 10f; y %= 5f; verifyEq(y, 4f)

    verifyEq(2f + 3f,  5f)
    verifyEq(2f + -1f, 1f)
    verifyEq(0.5f + 2, 2.5f)
    //verifyEq(0.5f + 0.5d, 1.0d)
    fx= 4f + 3f; fx+=5f; verifyEq(fx, 12f)

    verifyEq(7f - 3f,  4f)
    verifyEq(2f - 3f, -1f)
    verifyEq(1.5f - 2, -0.5f)
    //verifyEq(1.5f - 2d, -0.5d)
    fy=5f - 2f; fy-=-3.0f; verifyEq(fy, 6f)
  }

//////////////////////////////////////////////////////////////////////////
// Increment
//////////////////////////////////////////////////////////////////////////

  Float fx
  Float? fy

  Void testIncrement()
  {
    x:=4.0f
    verifyEq(++x, 5.0f); verifyEq(x, 5.0f)
    verifyEq(x++, 5.0f); verifyEq(x, 6.0f)
    verifyEq(--x, 5.0f); verifyEq(x, 5.0f)
    verifyEq(x--, 5.0f); verifyEq(x, 4.0f)

    Float? y := 4.0f
    verifyEq(++y, 5.0f); verifyEq(y, 5.0f)
    verifyEq(y++, 5.0f); verifyEq(y, 6.0f)
    verifyEq(--y, 5.0f); verifyEq(y, 5.0f)
    verifyEq(y--, 5.0f); verifyEq(y, 4.0f)

    fx = 4f
    verifyEq(++fx, 5.0f); verifyEq(fx, 5.0f)
    verifyEq(fx++, 5.0f); verifyEq(fx, 6.0f)
    verifyEq(--fx, 5.0f); verifyEq(fx, 5.0f)
    verifyEq(fx--, 5.0f); verifyEq(fx, 4.0f)

    fy = 4.0f
    verifyEq(++fy, 5.0f); verifyEq(fy, 5.0f)
    verifyEq(fy++, 5.0f); verifyEq(fy, 6.0f)
    verifyEq(--fy, 5.0f); verifyEq(fy, 5.0f)
    verifyEq(fy--, 5.0f); verifyEq(fy, 4.0f)
  }

//////////////////////////////////////////////////////////////////////////
// Num
//////////////////////////////////////////////////////////////////////////

  Void testNum()
  {
    verifyEq(3.0f.toInt, 3)
    verifyEq(((Num)3.1f).toInt, 3)
    verifyEq(3.9f.toInt, 3)
    verifyEq(4.0f.toInt, 4)
    verify(73939.9555f.toFloat == 73939.9555f)
    //verifyEq(-5.66e12f.toDecimal <=> -5.66e12d, 0)
    if (isJs)
    {
      verifyEq(Float.posInf.toInt, 9007199254740992)
      verifyEq(Float.negInf.toInt, -9007199254740992)
    }
    else
    {
      verifyEq(Float.posInf.toInt, 0x7fff_ffff_ffff_ffff)
      verifyEq(Float.negInf.toInt, 0x8000_0000_0000_0000)
    }
    verifyEq(Float.nan.toInt, 0)
  }

//////////////////////////////////////////////////////////////////////////
// Math
//////////////////////////////////////////////////////////////////////////

  Void testMath()
  {
    // mathematical constant
    verify(Float.e.approx(2.718281828459045f))
    verify(Float.pi.approx(3.141592653589793f))

    // abs
    verifyEq(3f.abs, 3f)
    verifyEq(0f.abs, 0f)
    verifyEq((-5.0f).abs, 5.0f)

    // min
    verifyEq(3f.min(2f), 2f)
    verifyEq((-7f).min(-7f), -7f)
    verifyEq(3f.min(5f), 3f)
    verifyEq(8f.min(-5f), -5f)

    // max
    verifyEq(0f.max(1f), 1f)
    verifyEq((-99.0f).max(-6666.0f), -99.0f)

    // ceil
    verifyEq(88f.ceil, 88f)
    verifyEq(6.335f.ceil, 7f)
    verifyEq(-3.3f.ceil, -4f)
    verifyEq(0.008f.ceil, 1f)

    // floor
    verifyEq(7f.floor, 7f)
    verifyEq(7.8523f.floor, 7f)
    verifyEq((-3.001f).floor, -4f)

    // round
    verifyEq(3.0f.round, 3.0f)
    verifyEq(3.1f.round, 3.0f)
    verifyEq(3.3f.round, 3.0f)
    verifyEq(3.4f.round, 3.0f)
    verifyEq(3.4999f.round, 3.0f)
    verifyEq(3.5f.round, 4.0f)
    verifyEq(3.6f.round, 4.0f)
    verifyEq(3.9f.round, 4.0f)
    if (isJs)
    {
      verifyEq(4.0456e32f.round, 4.0456e32f)
    }

    // exp
    verify(1f.exp.approx(Float.e))
    verify(2.5f.exp.approx(12.1824939607f))

    // log
    verify(Float.e.log.approx(1.0f))
    verify(1234.5678f.log.approx(7.1184762282977862925087925363871f))

    // log10
    verify(10f.log10.approx(1.0f))
    verify(0.00001f.log10.approx(-5.0f))

    // pow
    verifyEq(2f.pow(8f), 256.0f)
    verify(0.5f.pow(0.75f).approx(0.59460355750136053f))
    verifyEq(10f.pow(3f), 1000.0f)

    // sqrt
    verifyEq(25f.sqrt, 5.0f)
    verify(2.0f.sqrt.approx(1.414213562373f))
  }

//////////////////////////////////////////////////////////////////////////
// Trig
//////////////////////////////////////////////////////////////////////////

  Void testTrig()
  {
    // acos
    verify(0.6f.acos.approx(0.927295218001612f))

    // asin
    verify(0.5f.asin.approx(0.523598775598f))

    // atan
    verify(0.3f.atan.approx(0.29145679447786715f))

    // atan
    verify(Math.atan2(3f, 4f).approx(0.64350110879328f))

    // cos
    verify(Float.pi.cos.approx(-1.0f))
    verify(0.7f.cos.approx(0.7648421872844884262f))

    // cosh
    verify(0.7f.cosh.approx(1.25516900563f))

    // sin
    verify(Float.pi.sin.approx(0.0f, 1e-6f))
    verify(1.2f.sin.approx(0.9320390859672f))

    // sinh
    verify(1.2f.sinh.approx(1.50946135541217f))

    // tan
    verify(Float.pi.tan.approx(0.0f, 1e-6f))
    verify(0.25f.tan.approx(0.2553419212210362f))

    // tanh
    verify(0.3f.tanh.approx(0.29131261245159f))

    // toDegrees
    verify(Float.pi.toDegrees.approx(180.0f))
    verify(1f.toDegrees.approx(57.2957795f))

    // toRadians
    verify(90f.toRadians.approx(Float.pi/2.0f))
    verify(45f.toRadians.approx(0.785398163f))
  }

//////////////////////////////////////////////////////////////////////////
// Bits
//////////////////////////////////////////////////////////////////////////

  Void testBits()
  {

    if (!isJs)
    {
      verifyEq(0f.bits,           0)
      verifyEq(7.0f.bits,         0x401c000000000000)
      verifyEq(0.007f.bits,       0x3f7cac083126e979)
      verifyEq(3000000.0f.bits,   0x4146e36000000000)
      verifyEq((-1.0f).bits,      0xbff0000000000000)
      verifyEq((-7.05E-12f).bits, 0xbd9f019826e0ec8b)
    }

    verifyEq(0f.bits32, 0)
    verifyEq(7.0f.bits32, 0x40e00000)
    verifyEq(0.007f.bits32, 0x3be56042)
    verifyEq(3000000.0f.bits32, 0x4a371b00)
    verifyEq((-1.0f).bits32, 0xbf800000)
    verifyEq((-7.05E-12f).bits32, 0xacf80cc1)

    floats := [0.0f, 88.0f, -7.432f, 123.56e18f, Float.posInf, Float.negInf, Float.nan]
    floats.each |Float r|
    {
      if (!isJs) verifyEq(Float.makeBits(r.bits), r)
      verify(Float.makeBits32(r.bits32).approx(r))
    }
  }

//////////////////////////////////////////////////////////////////////////
// Approx
//////////////////////////////////////////////////////////////////////////

  Void testApprox()
  {
    verify(0f.approx(0f))
    verify(1e-10f.approx(0.0f, 1e-10f))
    verify(10f.approx(11f, 1f))
    verify(1000000f.approx(1000001f))
    verify(!1000000f.approx(1000002f))
    verify(Float.posInf.approx(Float.posInf))
    verify(Float.negInf.approx(Float.negInf))
    verify(Float.nan.approx(Float.nan))
  }

//////////////////////////////////////////////////////////////////////////
// Str
//////////////////////////////////////////////////////////////////////////

  Void testToStr()
  {
    verifyEq(69.69f.toStr, "69.69")
    verifyEq(69f.toStr,    "69.0")

    verifyEq(Float.posInf.toStr, "INF")
    verifyEq(Float.negInf.toStr, "-INF")
    verifyEq(Float.nan.toStr,    "NaN")

    verifyEq(((Obj)Float.posInf).toStr, "INF")
    verifyEq(((Obj)Float.negInf).toStr, "-INF")
    verifyEq(((Obj)Float.nan).toStr,    "NaN")
  }

//////////////////////////////////////////////////////////////////////////
// Parse
//////////////////////////////////////////////////////////////////////////

  Void testParse()
  {
    verifyEq(Float.fromStr("0"), 0.0f)
    verifyEq(Float.fromStr("0.8"), 0.8f)
    verifyEq(Float.fromStr("99.005"), 99.005f)
    verifyEq(Float.fromStr("INF"),  Float.posInf)
    verifyEq(Float.fromStr("-INF"), Float.negInf)
    verifyEq(Float.fromStr("NaN"),  Float.nan)
    //verifyEq(Float.fromStr("foo", false),  null)
    verifyErr(ParseErr#) { x := Float.fromStr("no way!") }
    verifyErr(ParseErr#) { x := Float.fromStr("%\$##", true) }
  }

//////////////////////////////////////////////////////////////////////////
// Random
//////////////////////////////////////////////////////////////////////////

  Void testRandom()
  {
    100.times |->|
    {
      f := Float.random
      verify(0f <= f && f < 1.0f)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Reflect
//////////////////////////////////////////////////////////////////////////

  Void testReflect()
  {
    verifyEq(Float#fromStr.callList(["3.0"]), 3.0f)
    //verifyEq(Float#fromStr.call("3.0"), 3.0f)
    //verifyEq(Float#fromStr.call("xxx", false), null)

    //verifyEq(Float#minus.callList([5f, 3f]), 2f)
    //verifyEq(Float#minus.call(5f, 3f), 2f)
    //verifyEq(Float#minus.callOn(5f, [3f]), 2f)
    //verifyEq(Float#negate.callOn(5f, null), -5f)
  }

//////////////////////////////////////////////////////////////////////////
// To Code
//////////////////////////////////////////////////////////////////////////

  Void testToCode()
  {
    verifyEq(0f.toCode, "0.0f")
    verifyEq((-98f).toCode, "-98.0f")
    verifyEq(Float.nan.toCode, "Float.nan")
    verifyEq(Float.posInf.toCode, "Float.posInf")
    verifyEq(Float.negInf.toCode, "Float.negInf")
  }

//////////////////////////////////////////////////////////////////////////
// Num Locale
//////////////////////////////////////////////////////////////////////////
/*
  Void testNumLocale()
  {
    Locale("en-US").use
    {
      verifyEq(Num.localeDecimal,  ".")
      verifyEq(Num.localeGrouping, ",")
      verifyEq(Num.localeMinus,    "-")
      verifyEq(Num.localePercent,  "%")
      verify(Num.localePosInf == "\u221e"  || Num.localePosInf == "Infinity")
      verify(Num.localeNegInf == "-\u221e" || Num.localeNegInf == "-Infinity")
      verify(Num.localeNaN == "\ufffd" || Num.localeNaN == "NaN") // not sure about replacement char
    }
    Locale("fr-FR").use
    {
      verifyEq(Num.localeDecimal,  ",")
      verifyEq(Num.localeGrouping, "\u00a0")
    }
  }

//////////////////////////////////////////////////////////////////////////
// Locale
//////////////////////////////////////////////////////////////////////////

  Void testLocale()
  {
    // no fractions
    verifyLocale(4.0f, "#", "4")
    verifyLocale(1234.3f, "#", "1234")
    verifyLocale(-123.1234f, "#", "-123")

    // no wholes
    verifyLocale(7.123f, "#.000", "7.123")
    verifyLocale(0.123f, "#.000", ".123")
    verifyLocale(-0.005f, "#.###", "-.005", true)

    // max fractions
    verifyLocale(1234.1234f, "#.#", "1234.1")
    verifyLocale(1234.1f,    "#.#", "1234.1")
    verifyLocale(1234.0f,    "#.#", "1234")
    verifyLocale(1230.0f,    "#.#", "1230")
    verifyLocale(-1230.00f,  "#.#", "-1230")
    verifyLocale(1230.003f,  "#.#", "1230")
    verifyLocale(1234.1234f, "#.#", "1234.1")
    verifyLocale(1234.1234f, "#.##", "1234.12")
    verifyLocale(1234.1234f, "#.###", "1234.123")
    verifyLocale(1234.1234f, "#.####", "1234.1234")
    verifyLocale(1234.1234f, "#.#####", "1234.1234")
    verifyLocale(-1234.1234f, "#.#####", "-1234.1234")

    // min fractions
    verifyLocale(1234.1234f, "#", "1234")
    verifyLocale(1234f,      "#.0", "1234.0")
    verifyLocale(1234.3f,    "#.0", "1234.3")
    verifyLocale(1234.34f,   "#.0", "1234.3")
    verifyLocale(1234.345f,  "#.0", "1234.3")
    verifyLocale(-1234f,     "#.00", "-1234.00")
    verifyLocale(1234.3f,    "#.00", "1234.30")
    verifyLocale(1234.34f,   "#.00", "1234.34")
    verifyLocale(1234.342f,  "#.00", "1234.34")
    verifyLocale(1234f,      "#.000", "1234.000")
    verifyLocale(1234.3f,    "#.000", "1234.300")
    verifyLocale(1234.04f,   "#.000", "1234.040")
    verifyLocale(1234.002f,  "#.000", "1234.002")
    verifyLocale(1234.0012f, "#.000", "1234.001")

    // min/max fractions
    verifyLocale(3.123432f, "#.00##", "3.1234")
    verifyLocale(3.12343f,  "#.00##", "3.1234")
    verifyLocale(3.0234f,   "#.00##", "3.0234")
    verifyLocale(3.003f,    "#.00##", "3.003")
    verifyLocale(3.12f,     "#.00##", "3.12")
    verifyLocale(3.1f,      "#.00##", "3.10")
    verifyLocale(-3f,       "#.00##", "-3.00")
    verifyLocale(-3.1234f,  "#.0##",  "-3.123")
    verifyLocale(-3.123f,   "#.0##",  "-3.123")
    verifyLocale(-3.12f,    "#.0##",  "-3.12")
    verifyLocale(-3.1f,     "#.0##",  "-3.1")
    verifyLocale(-3f,       "#.0##",  "-3.0")

    // leading zeros
    verifyLocale(0.3f,      "00.0",  "00.3")
    verifyLocale(3f,        "00.0",  "03.0")
    verifyLocale(30f,       "00.0",  "30.0")
    verifyLocale(123f,       "0.#",  "123")
    verifyLocale(123f,    "0000.#",  "0123")
    verifyLocale(0.5f,    "0000.#",  "0000.5")
    verifyLocale(0.01f,   "0000.#",  "0000")

    // grouping
    verifyLocale(1.0f, "#,###.0", "1.0")
    verifyLocale(12.0f, "#,###.0", "12.0")
    verifyLocale(123.0f, "#,###.0", "123.0")
    verifyLocale(123.0f, "#,##0",   "123")
    verifyLocale(1234.0f, "#,###.0", "1,234.0")
    verifyLocale(1234.0f, "#,##0",   "1,234")
    verifyLocale(12345.0f, "#,###.0", "12,345.0")
    verifyLocale(123456.0f, "#,###.0", "123,456.0")
    verifyLocale(1234567.0f, "#,###.0", "1,234,567.0")
    verifyLocale(12345000.0f, "#,###.0", "12,345,000.0")
    verifyLocale(-12345000.0f, "#,###.0", "-12,345,000.0")
    verifyLocale(12345000.0f, "#,####.0", "1234,5000.0")
    verifyLocale(-12345000.0f, "#,####.0", "-1234,5000.0")
    verifyLocale(12345000.0f, "#,##,##.0",  "12,34,50,00.0")
    verifyLocale(-12345000.0f, "#,##,##.0", "-12,34,50,00.0")
    verifyLocale(2.34E+11f, "###,###.0", "234,000,000,000.0")
    verifyLocale(-2.34E+11f, "###,###,###.0", "-234,000,000,000.0")
    verifyLocale(-2.34E+11f, "###,###,#00.0", "-234,000,000,000.0")

    // zero
    verifyLocale(0f, "#.0", ".0")
    verifyLocale(0f, "#.#", "0")
    verifyLocale(0f, "0.#", "0")
    verifyLocale(0f, "0.0", "0.0")
    verifyLocale(0f, "00.00", "00.00")

    // fixed size numbers
    verifyLocale(0f,   "0",   "0")
    verifyLocale(0f,   "00",  "00")
    verifyLocale(0f,   "000", "000")
    verifyLocale(2f,   "0",   "2")
    verifyLocale(-2f,  "00",  "-02")
    verifyLocale(2.3f, "000",  "002")
    verifyLocale(20f,  "000",  "020")
    verifyLocale(500f, "000",  "500")
    verifyLocale(501f, "0000", "0501")

    // rounding
    verifyLocale(2.06f,   "0.0", "2.1")
    verifyLocale(19.288f, "0.00", "19.29")
    verifyLocale(19.298f, "0.00", "19.30")
    verifyLocale(19.97f,  "0.##", "19.97")
    verifyLocale(19.97f,  "0.#",  "20")
    verifyLocale(19.97f,  "0.0",  "20.0")
    verifyLocale(99.97f,  "0.0",  "100.0")
    verifyLocale(-0.994f, "0.00", "-0.99")
    verifyLocale(-0.996f, "0.00", "-1.00")
    verifyLocale(-0.937f, "00.##", "-00.94")
    verifyLocale(-0.937f, "#.##", "-.94", true)

    // more random testing
    verifyLocale(-2.87E-5f, "#.000000", "-.000029")
    verifyLocale(2.87E-5f, "#.######",  ".000029", true)
    verifyLocale(-7.009E+8f, "##,###.0", "-700,900,000.0")
    verifyLocale(10f/3f, "0.000", "3.333")
    verifyLocale(10f/6f, "0.000", "1.667")
    verifyLocale(Float.pi, "0.0", "3.1")
    verifyLocale(Float.pi, "0.00", "3.14")
    verifyLocale(Float.pi, "0.000", "3.142")
    verifyLocale(Float.pi, "0.0000", "3.1416")
    verifyLocale(Float.pi, "0.00000", "3.14159")

    Locale("en-US").use
    {
      verifyEq(0.0003f.toLocale("0.0##"), "0.0")
      verifyEq(0.0003f.toLocale("0.0###"), "0.0003")
      verifyEq(0.0000003f.toLocale("0.######"), "0")
      verifyEq(0.0000003f.toLocale("0.#######"), "0.0000003")

      // specials
      if (Env.cur.vars["java.home"] != null)
      {
        verifyLocale(Float.nan, "#.#", "\ufffd")
        verifyLocale(Float.posInf, "#.#", "\u221e")
        verifyLocale(Float.negInf, "#.#", "-\u221e")
      }
    }

    // default, alternate locale
    verifyLocale(12345.4f, null, "12,345.4")
    Locale("fr-FR").use
    {
      verifyEq(12345.4f.toLocale("#,###.0"), "12\u00a0345,4")
      verifyEq(12345.4f.toLocale("#,###.0", Locale.en), "12,345.4")
    }
  }

  Void verifyLocale(Float f, Str? pattern, Str expected, Bool javaWrong := false)
  {
    Locale("en-US").use
    {
      actual := f.toLocale(pattern)
      //echo("   ==> $actual ?= $expected")
      verifyEq(actual, expected)

      if (f <=> Float.nan != 0 && f != Float.posInf && f != Float.negInf)
      {
        decimal := f.toDecimal.toLocale(pattern)
        //echo("   dec $f.toDecimal")
        //echo("   ==> $decimal ?= $expected")
        verifyEq(decimal, expected)
      }

      // try to verify against what Java does (need using stmt up top)
      /*
      using [java] java.text
      if (!javaWrong && pattern != null) verifyEq(actual, DecimalFormat(pattern).format(f))
      */
    }
  }
*/
  /*
  Void testLocalePerf()
  {
    count := 1_000_000
    pattern := "#,###.00"
    for (i:=0; i<10_000; ++i) i.toFloat.toLocale(pattern)
    for (i:=0; i<10_000; ++i) DecimalFormat(pattern).format(i.toFloat)

    t1 := Duration.now
    for (i:=0; i<count; ++i) i.toFloat.toLocale("#,###.00")
    t2 := Duration.now
    for (i:=0; i<count; ++i) DecimalFormat(pattern).format(i.toFloat)
    t3 := Duration.now

    echo("Fantom  ${(t2-t1).toMillis}ms")
    echo("Java ${(t3-t2).toMillis}ms")
  }
  */

}