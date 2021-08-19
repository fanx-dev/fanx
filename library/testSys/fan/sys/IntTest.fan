//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   1 Jan 06  Brian Frank  Creation
//


**
** IntTest
**
class IntTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Constants
//////////////////////////////////////////////////////////////////////////

  Void testConstants()
  {
    if (isJs)
    {
      verifyEq(Int.maxVal, 9007199254740992)
      verifyEq(Int.minVal, -9007199254740992)
    }
    else
    {
      verifyEq(Int.maxVal, 9223372036854775807)
      verifyEq(Int.minVal, -9223372036854775807-1)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Def Val
//////////////////////////////////////////////////////////////////////////

  Void testDefVal()
  {
    verifyEq(Int.defVal, 0)
    verifyEq(Int#.make, 0)
  }

//////////////////////////////////////////////////////////////////////////
// Is
//////////////////////////////////////////////////////////////////////////

  Void testIs()
  {
    Obj x := 3

    verifyTrue(Type.of(x) === Int#)
    verifyTrue(Type.of(3) === Int#)
    verifyTrue(x.isImmutable)
    verifyTrue(8.isImmutable)

    verifyTrue(x is Obj)
    verifyTrue(x is Num)
    verifyTrue(x is Int)
    verifyFalse(x is Float)
  }

//////////////////////////////////////////////////////////////////////////
// Equals
//////////////////////////////////////////////////////////////////////////

  Void testEquals()
  {
    Obj? x := 99
    verify(-2 == -2)
    verify(0 == 0)
    verify(15 == 0xf)
    verify(1_000 == 1000)
    verify(0xABCD == 0xabcd)
    verify(x == 99)
    verify(99 == x)
    verifyFalse(x == 9)
    verifyFalse(9 == x)
    verifyFalse(9 == (Obj?)"hi")
    verifyFalse((Obj?)"hi" == 9)

    verify(0xffff_ffff_ffff_ffff == 0xffff_ffff_ffff_ffff)
    verify(2 != 3)
    verify(-2 != 0)
    verifyFalse(x != 99)
    verifyFalse(99 != x)
    verify(x != 9)
    verify(9 != x)
    verify(x as Obj != "foo")
    verify(x != null)
    verify(null != x)

    verify(44.equals(44))
    verify(!44.equals("x"))
  }

//////////////////////////////////////////////////////////////////////////
// Compare
//////////////////////////////////////////////////////////////////////////

  Void testCompare()
  {
    Obj? x := -9
    verify(2 < 3)
    verify(x < 3)
    verifyFalse(3 < -9)
    verify(null < 3)
    verifyFalse(3 < 3)
    verifyFalse(6 < 4)
    verifyFalse(3 < x)
    verifyFalse(-9 < x)
    verifyFalse(3 < null)

    verify(3 <= 3)
    verify(3 <= 3)
    verify(-9 <= x)
    verify(-99 <= x)
    verify(x <= -8)
    verify(x <= -9)
    verify(null <= 3)
    verifyFalse(6 <= 5)
    verifyFalse(5 <= null)

    verify(-2 > -3)
    verify(0 > -2)
    verify(x > -11)
    verifyFalse(-11 > x)
    verify(-2 > null)
    verifyFalse(null > 77)
    verifyFalse(3 > 4)

    verify(-3 >= -4)
    verify(-3 >= -3)
    verify(x >= -9)
    verify(x >= -11)
    verify(-3 >= null)
    verifyFalse(null >= 4)
    verifyFalse(-3 >= -2)
    verifyFalse(-10 >= x)
    verify(-7 >= x)

    verifyEq(3 <=> 4, -1)
    verifyEq(3 <=> 3, 0)
    verifyEq(4 <=> 3, 1)
    verifyEq(x <=> 4, -1)
    verifyEq(4 <=> x, 1)
    verifyEq(-9 <=> x, 0)
    verifyEq(null <=> 3, -1)
    verifyEq(-9 <=> null, 1)
  }

//////////////////////////////////////////////////////////////////////////
// Operators
//////////////////////////////////////////////////////////////////////////

  Void testOperators()
  {
    x := 5;   verifyEq(-x, -5)
    x = -44; verifyEq(-x, 44)

    verifyEq(3*2,   6)
    verifyEq(3*-2f, -6f)
    //verifyEq(-2*3d, -6d)
    verifyEq(-3*-2, 6)
    x=2*2; x*=3; verifyEq(x, 12)

    verifyEq(-16/4, -4)
    verifyEq(16 / 5, 3)
    verifyEq(15 / 5f, 3f)
    //verifyEq(15 / 5d, 3d)
    verifyEq(-6/4, -1)
    x = 20 / 2; x /= -5; verifyEq(x, -2)

    verifyEq(21%-6, 3)
    verifyEq(16%5, 1)
    verifyEq(12%5, 2)
    verifyEq(12%5f, 2f)
    //verifyEq(12%5d, 2d)
    x = 19 % 10; x %= 5; verifyEq(x, 4)

    verifyEq(2 + 3,  5)
    verifyEq(2 + -1, 1)
    verifyEq(2+3,  5)
    verifyEq(2+-1, 1)
    verifyEq(2 + 3.2f, 5.2f)
    //verifyEq(2 + 13.2d, 15.2d)
    fx=4 + 3; fx+=5; verifyEq(fx, 12)

    verifyEq(7 - 3,  4)
    verifyEq(2 - 3, -1)
    verifyEq(2 - 0.5f, 1.5f)
    //verifyEq(2 - 0.5d, 1.5d)
    verifyEq(7-3,  4)
    verifyEq(2-3, -1)
    fy=5 - 2; fy-=-3; verifyEq(fy, 6)
  }

//////////////////////////////////////////////////////////////////////////
// Increment
//////////////////////////////////////////////////////////////////////////

  Void testIncrement()
  {
    x := 4
    verifyEq(++x, 5); verifyEq(x, 5)
    verifyEq(x++, 5); verifyEq(x, 6)
    verifyEq(--x, 5); verifyEq(x, 5)
    verifyEq(x--, 5); verifyEq(x, 4)

    Int? y := 4
    verifyEq(++y, 5); verifyEq(y, 5)
    verifyEq(y++, 5); verifyEq(y, 6)
    verifyEq(--y, 5); verifyEq(y, 5)
    verifyEq(y--, 5); verifyEq(y, 4)

    fx = 4
    verifyEq(++fx, 5); verifyEq(fx, 5)
    verifyEq(fx++, 5); verifyEq(fx, 6)
    verifyEq(--fx, 5); verifyEq(fx, 5)
    verifyEq(fx--, 5); verifyEq(fx, 4)

    fy = 4
    verifyEq(++fy, 5); verifyEq(fy, 5)
    verifyEq(fy++, 5); verifyEq(fy, 6)
    verifyEq(--fy, 5); verifyEq(fy, 5)
    verifyEq(fy--, 5); verifyEq(fy, 4)

    lx = [4]
    verifyEq(++lx[0], 5); verifyEq(lx[0], 5)
    verifyEq(lx[0]++, 5); verifyEq(lx[0], 6)
    verifyEq(--lx[0], 5); verifyEq(lx[0], 5)
    verifyEq(lx[0]--, 5); verifyEq(lx[0], 4)

    ly = [4]
    verifyEq(++ly[0], 5); verifyEq(ly[0], 5)
    verifyEq(ly[0]++, 5); verifyEq(ly[0], 6)
    verifyEq(--ly[0], 5); verifyEq(ly[0], 5)
    verifyEq(ly[0]--, 5); verifyEq(ly[0], 4)
  }

  Int fx
  Int? fy
  Int[] lx := Int[,]
  Int?[] ly := Int?[,]

//////////////////////////////////////////////////////////////////////////
// Bitwise
//////////////////////////////////////////////////////////////////////////

  Void testBitwise()
  {
    // not
    verifyEq(0x3bc7.not.and(0xffff), 0xc438)

    // and
    verifyEq(0xff.and(0x0f), 0x0f)
    verifyEq(0xf1->and(0x0f), 0x01)

    // xor
    verifyEq(0x03.xor(0x02), 0x01)
    verifyEq(0xff->xor(0x17), 0xe8)

    // or
    verifyEq(0xa0.or(0x0b),  0xab)
    verifyEq(0xaabbcc->or(0xff000000), 0xffaabbcc)

    // shiftl
    verifyEq(0x01.shiftl(1), 0x02)
    verifyEq(0x0a->shiftl(4), 0xa0)

    // shiftr
    verifyEq(0x80.shiftr(1), 0x40)
    verifyEq(0x80.shiftr(3), 0x10)

    // shifta
    verifyEq(0x80.shifta(1), 0x40)
    verifyEq(0x80.shifta(3), 0x10)

    if (!isJs)
    {
      verifyEq(0xabcd_0000_1111_0000.shiftr(4), 0x0abc_d000_0111_1000)
      verifyEq(0xabcd_0000_1111_0000->shiftr(4), 0x0abc_d000_0111_1000)
      verifyEq((-1).shiftr(1), 0x7fff_ffff_ffff_ffff)
      verifyEq((-1).shiftr(3), 0x1fff_ffff_ffff_ffff)
      verifyEq((-1).shifta(1), -1)
      verifyEq((-1).shifta(3), -1)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Num
//////////////////////////////////////////////////////////////////////////

  Void testNum()
  {
    verifyEq(9.toFloat, 9.0f)
    //verifyEq(9.toDecimal, 9d)
    //verifyEq(-123456789.toDecimal, -123456789d)
    verifyEq(-7.toInt, -7)
    verifyEq((-2.3f).toInt, -2)
    verify(93757393754.toInt == 93757393754)
  }

//////////////////////////////////////////////////////////////////////////
// Math
//////////////////////////////////////////////////////////////////////////

  Void testMath()
  {
    verifyEq(3.abs, 3)
    verifyEq(0.abs, 0)
    verifyEq((-5).abs, 5)

    verifyEq(3.min(2), 2)
    verifyEq((-7).min(-7), -7)
    verifyEq(3.min(5), 3)
    verifyEq(8.min(-5), -5)

    verifyEq(0.max(1), 1)
    verifyEq((-99).max(-6666), -99)
    verifyEq('a'.max(' '), 'a')

    verifyEq(3.clip(0, 100), 3)
    verifyEq(3.clip(4, 4), 4)
    verifyEq((-3).clip(0, 100), 0)
    verifyEq(0.clip(0, 100), 0)
    verifyEq(100.clip(0, 100), 100)
    verifyEq(101.clip(0, 100), 100)
    verifyEq(201.clip(0, 100), 100)

    verifyEq(5.pow(0), 1)
    verifyEq(5.pow(1), 5)
    verifyEq(5.pow(2), 25)
    verifyEq(10.pow(5), 100_000)
    verifyEq(8.pow(5), 32768)
    verifyEq((-2).pow(2), 4)
    verifyEq((-2).pow(3), -8)
    verifyErr(ArgErr#) { 6.pow(-1) }

    verifyEq((-2).isEven,    true)
    verifyEq((-1).isEven,    false)
    verifyEq(0.isEven,       true)
    verifyEq(1.isEven,       false)
    verifyEq(2.isEven,       true)
    verifyEq(140_806.isEven, true)
    verifyEq((-2).isOdd,     false)
    verifyEq(0.isOdd,        false)
    verifyEq(1.isOdd,        true)
    verifyEq(77.isOdd,       true)
  }

//////////////////////////////////////////////////////////////////////////
// Char Test
//////////////////////////////////////////////////////////////////////////

  Void testCharTests()
  {
    verifyChar(' ',  "s")
    verifyChar('\t', "s")
    verifyChar('\n', "s")
    verifyChar('\r', "s")

    for (Int c := 'A'; c <= 'F'; ++c) verifyChar(c, "auh")
    for (Int c := 'a'; c <= 'f'; ++c) verifyChar(c, "alh")
    for (Int c := 'G'; c <= 'Z'; ++c) verifyChar(c, "au")
    for (Int c := 'g'; c <= 'z'; ++c) verifyChar(c, "al")
    for (Int c := '0'; c <= '9'; ++c) verifyChar(c, "dh")

    symbols := "`~!@#%^&*()-_=+[]{}\\|;:'\"<>?,./\u007F\u00FF\u01cc"
    symbols.each |Int ch| { verifyChar(ch, "") }

    verifyChar(-1, "")

    verifyEq('1'.isDigit(2), true)
    verifyEq('3'.isDigit(2), false)

    verifyEq('g'.isDigit(17), true)
    verifyEq('g'.isDigit(16), false)
    verifyEq('G'.isDigit(17), true)
    verifyEq('G'.isDigit(16), false)

    verifyEq('h'.isDigit(17), false)
    verifyEq('h'.isDigit(18), true)
    verifyEq('H'.isDigit(17), false)
    verifyEq('H'.isDigit(18), true)
  }

  Void verifyChar(Int char, Str pattern)
  {
    verifyEq(char.isSpace,     pattern.contains("s"))
    verifyEq(char.isDigit,     pattern.contains("d"))
    verifyEq(char.isDigit(16), pattern.contains("h"))
    verifyEq(char.isAlpha,     pattern.contains("a"))
    verifyEq(char.isUpper,     pattern.contains("u"))
    verifyEq(char.isLower,     pattern.contains("l"))
  }

//////////////////////////////////////////////////////////////////////////
// Char Conv
//////////////////////////////////////////////////////////////////////////

  Void testCharConv()
  {
    // upper
    verifyEq('a'.upper, 'A')
    verifyEq('z'.upper, 'Z')
    verifyEq('G'.upper, 'G')
    verifyEq('3'.upper, '3')
    verifyEq(999.upper, 999)
    verifyEq((-6).upper, -6)

    // lower
    verifyEq('A'.lower, 'a')
    verifyEq('Z'.lower, 'z')
    verifyEq('i'.lower, 'i')
    verifyEq((-88).lower, -88)

    // ensure locale doesn't work for ASCII methods
    /*
    Locale.fromStr("tr").use
    {
      verifyEq('I'.lower, 'i')
      verifyEq('i'.upper, 'I')
    }
    */

    // toDigit - decimal
    verifyEq((-1).toDigit, null)
    verifyEq(0.toDigit, '0')
    verifyEq(3.toDigit, '3')
    verifyEq(9.toDigit, '9')
    verifyEq(10.toDigit, null)
    verifyEq((-1).toDigit(10), null)
    verifyEq(0.toDigit(10), '0')
    verifyEq(3.toDigit(10), '3')
    verifyEq(9.toDigit(10), '9')
    verifyEq(10.toDigit(10), null)

    // toDigit - hex
    verifyEq(' '.toDigit(16), null)
    verifyEq(0.toDigit(16), '0')
    verifyEq(9.toDigit(16), '9')
    verifyEq(10.toDigit(16), 'a')
    verifyEq(15.toDigit(16), 'f')
    verifyEq(17.toDigit(16), null)
    verifyEq(99.toDigit(16), null)

    // toDigit - base36
    verifyEq(0.toDigit(36), '0')
    verifyEq(9.toDigit(36), '9')
    verifyEq(15.toDigit(36), 'f')
    verifyEq(35.toDigit(36), 'z')
    verifyEq(36.toDigit(36), null)

    // toDigit - binary
    verifyEq((-1).toDigit(2), null)
    verifyEq(0.toDigit(2), '0')
    verifyEq(1.toDigit(2), '1')
    verifyEq(2.toDigit(2), null)

    // fromDigit - decimal
    verifyEq(' '.fromDigit, null)
    verifyEq('0'.fromDigit, 0)
    verifyEq('3'.fromDigit, 3)
    verifyEq('9'.fromDigit, 9)
    verifyEq('a'.fromDigit, null)
    verifyEq(' '.fromDigit(10), null)
    verifyEq('0'.fromDigit(10), 0)
    verifyEq('3'.fromDigit(10), 3)
    verifyEq('9'.fromDigit(10), 9)
    verifyEq('a'.fromDigit(10), null)

    // fromDigit - hex
    verifyEq('0'.fromDigit(16), 0)
    verifyEq('9'.fromDigit(16), 9)
    verifyEq('a'.fromDigit(16), 0xa)
    verifyEq('f'.fromDigit(16), 0xf)
    verifyEq('g'.fromDigit(16), null)
    verifyEq('A'.fromDigit(16), 0xa)
    verifyEq('F'.fromDigit(16), 0xf)
    verifyEq('G'.fromDigit(16), null)
    verifyEq(3.fromDigit(16), null)

    // fromDigit - base36
    verifyEq(' '.fromDigit(36), null)
    verifyEq('5'.fromDigit(36), 5)
    verifyEq('c'.fromDigit(36), 12)
    verifyEq('Z'.fromDigit(36), 35)
    verifyEq('['.fromDigit(36), null)
    verifyEq('z'.fromDigit(36), 35)
    verifyEq('{'.fromDigit(36), null)

    // fromDigit - binary
    verifyEq('0'.fromDigit(2), 0)
    verifyEq('1'.fromDigit(2), 1)
    verifyEq('2'.fromDigit(2), null)
  }

//////////////////////////////////////////////////////////////////////////
// EqualsIgnoreCase
//////////////////////////////////////////////////////////////////////////

  Void testEqualsIgnoreCase()
  {
    verifyEq('a'.equalsIgnoreCase('a'), true)
    verifyEq('a'.equalsIgnoreCase('b'), false)
    verifyEq('a'.equalsIgnoreCase('A'), true)
    verifyEq('Z'.equalsIgnoreCase('z'), true)
    verifyEq('^'.equalsIgnoreCase('~'), false)
    /*
    Locale.fromStr("tr").use
    {
      verifyEq('I'.equalsIgnoreCase('i'), true)
      verifyEq('i'.equalsIgnoreCase('I'), true)
    }
    */
  }

//////////////////////////////////////////////////////////////////////////
// ToChar
//////////////////////////////////////////////////////////////////////////

  Void testToChar()
  {
    verifyEq(97.toChar, "a")
    verifyEq(32.toChar, " ")
    verifyEq(0x1234.toChar, "\u1234")

    //verifyErr(Err#) { 0x10000.toChar }
  }

//////////////////////////////////////////////////////////////////////////
// Locale
//////////////////////////////////////////////////////////////////////////
/*
  Void testLocale()
  {
    verifyLocale("en", 'a', 'a', 'A')
    verifyLocale("en", 'i', 'i', 'I')
    verifyLocale("en", 'Z', 'z', 'Z')

    verifyLocale("en", '\u0391', '\u03b1', '\u0391') // Greek A
    verifyLocale("el", '\u03c9', '\u03c9', '\u03a9') // Greek Omega
    verifyLocale("sk", '\u0414', '\u0434', '\u0414') // Cryllic DE
    verifyLocale("tr", 'i', 'i', '\u0130')           // Turkish dotted i
    verifyLocale("tr", 'I', '\u0131', 'I')           // Turkish undotted I
  }

  Void verifyLocale(Str locale, Int c, Int lower, Int upper)
  {
    Locale.fromStr(locale).use
    {
      verifyEq(c.localeIsLower, c == lower)
      verifyEq(c.localeIsUpper, c == upper)
      verifyEq(c.localeLower,   lower)
      verifyEq(c.localeUpper,   upper)
      verifyEq(c.localeLower.localeUpper, upper)
      verifyEq(c.localeUpper.localeLower, lower)
    }
  }
*/
//////////////////////////////////////////////////////////////////////////
// ToHex
//////////////////////////////////////////////////////////////////////////

  Void testToHex()
  {
    verifyEq(255.toHex, "ff")
    verifyEq(255.toHex(4), "00ff")
    verifyEq(0.toHex(10), "0000000000")
    verifyEq(1.toHex(20), "00000000000000000001")
    if (!isJs)
    {
      verifyEq(0x123456789abcdef.toHex, "123456789abcdef")
      verifyEq(0x123456789abcdef.toHex(18), "000123456789abcdef")
      verifyEq(0xaabbccdd00112233.toHex, "aabbccdd00112233")
    }
    if (isJs)
    {
      // TODO FIXIT: sign bit is not extended so doesn't work quite right...
      // test special rules for negative values which differ
      // from JVM since safe range is only 2^53
      verifyEq((-100).toHex, "1fffffffffff9b")
      verifyEq((-9007199254734720).toHex, "187f")
      verifyEq(9007199254740991.toHex, "1fffffffffffff")
    }
  }

//////////////////////////////////////////////////////////////////////////
// ToRadix
//////////////////////////////////////////////////////////////////////////

  Void testToRadix()
  {
    verifyEq(255.toRadix(10), "255")
    verifyEq(255.toRadix(10, 5), "00255")
    verifyEq(255.toRadix(16), "ff")
    verifyEq(255.toRadix(16, 4), "00ff")
    verifyEq(255.toRadix(8), "377")
    verifyEq(255.toRadix(8, 2), "377")
    verifyEq(255.toRadix(8, 4), "0377")
  }

//////////////////////////////////////////////////////////////////////////
// Parse
//////////////////////////////////////////////////////////////////////////

  Void testParse()
  {
    verifyEq(Int.fromStr("0"), 0)
    verifyEq(Int.fromStr("-1"), -1)
    verifyEq(Int.fromStr("999"), 999)
    verifyEq(Int.fromStr("1234567890"), 1234567890)
    verifyEq(Int.fromStr("10", 16), 0x10)
    verifyEq(Int.fromStr("abcdef", 16), 0xabcdef)
    verifyEq(Int.fromStr("AbCdEf", 16), 0xabcdef)
    verifyEq(Int.fromStr("77", 10, true), 77)
    verifyEq(Int.fromStr("x", 10, false), 0)
    if (!isJs)
    {
      verifyEq(Int.fromStr("aabbccdd00112233", 16), 0xaabbccdd00112233)
      verifyEq(Int.fromStr("80BF3ecA63100DdE", 16), 0x80bf3eca63100dde)
      verifyEq(Int.fromStr("10111", 2), 0x17)
    }
    verifyEq(Int.fromStr("badz", 16, false), 0)
    verifyErr(ParseErr#) { x := Int.fromStr("") }
    verifyErr(ParseErr#) { x := Int.fromStr("x") }
    verifyErr(ParseErr#) { x := Int.fromStr("3", 2, true) }
    verifyErr(ParseErr#) { x := Int.fromStr("3g", 16, true) }
    verifyErr(ParseErr#) { x := Int.fromStr("-10111", 2) }

    verifyErrMsg(ParseErr#, "Invalid Int: 'ABC'") { x := Int.fromStr("ABC") }
  }

//////////////////////////////////////////////////////////////////////////
// Random
//////////////////////////////////////////////////////////////////////////

  Void testRandom()
  {
    acc := Int:Obj[:]
    10.times |->| { acc.set(Int.random, this) }
    verifyEq(acc.size, 10)

    acc.clear
    1000.times |->|
    {
      i := Int.random(0..10)
      verify((0..10).contains(i))
      acc.set(i, this)
    }
    verifyEq(acc.size, 11)

    acc.clear
    1000.times |->|
    {
      i := Int.random(10..<20)
      verify((10..<20).contains(i))
      acc.set(i, this)
    }
    verifyEq(acc.size, 10)

    verifyErr(ArgErr#) { Int.random(20..<10) }
    verifyErr(ArgErr#) { Int.random(2..1) }
  }

//////////////////////////////////////////////////////////////////////////
// Reflect
//////////////////////////////////////////////////////////////////////////
/*
  //TODO
  Void testReflect()
  {
    verifyEq(Int#fromStr.callList(["3"]), 3)
    verifyEq(Int#fromStr.call("3"), 3)
    verifyEq(Int#fromStr.call("xxx", 10, false), null)

    verifyEq(Int#toHex.callList([0xab]), "ab")
    verifyEq(Int#toHex.call(0xab, 4), "00ab")
    verifyEq(Int#toHex.callOn(0xab, null), "ab")
    verifyEq(Int#toHex.callOn(0xab, [3]), "0ab")

    verifyEq(Obj#hash.callList([66]), 66)
    verifyEq(Obj#toStr.callOn(66, null), "66")

    Obj x := 10
    verifyEq(x->toStr, "10")
    verifyEq(x->toHex, "a")
    verifyEq(x->toHex(2), "0a")
  }
*/
//////////////////////////////////////////////////////////////////////////
// To Code
//////////////////////////////////////////////////////////////////////////

  Void testToCode()
  {
    verifyEq(0.toCode, "0")
    verifyEq(493446.toCode, "493446")
    verifyEq((-3345).toCode(10), "-3345")
    verifyEq(0xabcd.toCode(16), "0xabcd")
    verifyErr(ArgErr#) { 3999.toCode(8) }
  }

//////////////////////////////////////////////////////////////////////////
// Conversions
//////////////////////////////////////////////////////////////////////////
/*
  Void testConversions()
  {
    verifyEq(3_000_000.toDuration, 3ms)
    verifyEq(-5_000_000_000.toDuration, -5sec)

    now := DateTime.now
    verifyEq(now.ticks.toDateTime, now)
    verifyEq(0.toDateTime(TimeZone.utc), DateTime.defVal)
    verifyEq(289658280000000000.toDateTime(TimeZone("New_York")), DateTime(2009, Month.mar, 6, 7, 38, 0, 0, TimeZone("New_York")))
  }
*/
//////////////////////////////////////////////////////////////////////////
// Locale
//////////////////////////////////////////////////////////////////////////
/*
  Void testToLocale()
  {
    verifyToLocale(4, "#", "4")
    verifyToLocale(1234, "#,###", "1,234")
    verifyToLocale(123_456_789, "#,####", "1,2345,6789")
    verifyToLocale(123_456_789, "#,###",  "123,456,789")
    verifyToLocale(-123_456_789, "#,##",  "-1,23,45,67,89")
    if (isJs)
    {
      verifyToLocale(Int.maxVal, "#,###",   "9,007,199,254,740,992")
      verifyToLocale(Int.minVal, "#,###",   "-9,007,199,254,740,992")
    }
    else
    {
      verifyToLocale(Int.maxVal, "#,###",   "9,223,372,036,854,775,807")
      verifyToLocale(Int.minVal, "#,###",   "-9,223,372,036,854,775,808")
    }

    verifyToLocale(4, "0",   "4")
    verifyToLocale(4, "00",  "04")
    verifyToLocale(4, "000", "004")
    verifyToLocale(-45, "000", "-045")
    verifyToLocale(-70, "0000", "-0070")

    verifyToLocale(0, "#", "0")
    verifyToLocale(0, "0", "0")

    // default, alternate locale
    verifyToLocale(12345, null, "12,345")
    Locale("fr-FR").use
    {
      verifyEq(12345.toLocale("#,###"), "12\u00a0345")
      verifyEq(12345.toLocale("#,###", Locale.en), "12,345")
    }

    // bytes
    kb := 1024; mb := 1024*1024; gb := 1024*1024*1024;
    verifyToLocale(0, "B", "0B")
    verifyToLocale(123, "B", "123B")
    verifyToLocale(kb, "B", "1KB")
    verifyToLocale(8397, "B", "8.2KB")
    verifyToLocale(30*kb-500, "B", "30KB")
    verifyToLocale(123*kb, "B", "123KB")
    verifyToLocale(mb, "B", "1MB")
    verifyToLocale(6_606_028, "B", "6.3MB")
    verifyToLocale(15*mb-100, "B", "15MB")
    verifyToLocale(682*mb+30*kb, "B", "682MB")
    verifyToLocale(gb, "B", "1GB")
    verifyToLocale((2.8f*gb.toFloat).toInt, "B", "2.8GB")
    verifyToLocale(13*gb-10*mb, "B", "13GB")
  }

  Void verifyToLocale(Int i, Str? pattern, Str expected)
  {
    Locale("en-US").use
    {
      // echo("====> $i $pattern ?= $expected")
      actual := i.toLocale(pattern)
      // echo("   ==> $actual ?= $expected")
      verifyEq(actual, expected)
    }
  }
*/

}