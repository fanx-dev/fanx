//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   9 Apr 06  Brian Frank  Creation
//

**
** DurationTest
**
class DurationTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Val Fields
//////////////////////////////////////////////////////////////////////////

  Void testValFields()
  {
    verifySame(Duration.defVal, 0ms)
    verifySame(Duration#.make, 0ms)
    //verifyEq(Duration.minVal.ticks, Int.minVal)
    //verifyEq(Duration.maxVal.ticks, Int.maxVal)
  }

//////////////////////////////////////////////////////////////////////////
// Is
//////////////////////////////////////////////////////////////////////////

  Void testIs()
  {
    verify(Type.of(3ms) === Duration#)

    verify(0sec is Obj)
    verify(3ms is Duration)
  }

//////////////////////////////////////////////////////////////////////////
// Equals
//////////////////////////////////////////////////////////////////////////

  Void testEquals()
  {
    Obj? x := 9hr
    verify(0ms == 0sec)
    verify(1ms != 1sec)
    verify(x != null)
    verify(null != x)
    verify(8ms as Obj != 8)
  }

//////////////////////////////////////////////////////////////////////////
// Literals
//////////////////////////////////////////////////////////////////////////
/*
  Void testLiterals()
  {
    verifyEq(3ns.ticks,   3)
    verifyEq(3ms.ticks,   3_000_000)
    verifyEq(3sec.ticks,  3_000_000_000)
    verifyEq(-3sec.ticks, -3_000_000_000)
    verifyEq(1min.ticks,  60_000_000_000)
    verifyEq(1hr.ticks,   3_600_000_000_000)
    verifyEq(1day.ticks,  86_400_000_000_000)

    verifyEq(0.5hr.ticks,    1_800_000_000_000)
    verifyEq(-2.5hr.ticks,   -9_000_000_000_000)
    verifyEq(0.001sec.ticks, 1_000_000)
  }
*/
//////////////////////////////////////////////////////////////////////////
// Now
//////////////////////////////////////////////////////////////////////////
/*
  Void testNow()
  {
    x := Duration.now
    y := Duration.nowTicks
    z := Duration.now
    verify(x.ticks <= y)
    verify(y <= z.ticks)
  }
*/
//////////////////////////////////////////////////////////////////////////
// Boot/Uptime
//////////////////////////////////////////////////////////////////////////
/*
  Void testBoot()
  {
    verifySame(Duration.boot, Duration.boot)
    verify(Duration.boot < Duration.now)
    verify(Duration.uptime > 0ns)
  }
*/
//////////////////////////////////////////////////////////////////////////
// Compare
//////////////////////////////////////////////////////////////////////////

  Void testCompare()
  {/*
    verify(2ns < 3ns)
    verify(2ns < 2ms)
    verify(null < 3ns)
    verifyFalse(3ns < 3ns)
    verifyFalse(6ns < 4ns)
    verifyFalse(3ns < null)

    verify(3ns <= 3ns)
    verify(3ns <= 3ns)
    verify(null <= 3ns)
    verifyFalse(6ns <= 5ns)
    verifyFalse(5ns <= null)

    verify(-2ns > -3ns)
    verify(0ns > -2ns)
    verify(-2ns > null)
    verifyFalse(null > 77ns)
    verifyFalse(3ns > 4ns)
*/
    verify(-3ms >= -4ms)
    verify(-3ms >= -3ms)
    verify(-3ms >= null)
    verifyFalse(null >= 4ms)
    verifyFalse(-3ms >= -2ms)

    verifyEq(3ms <=> 4ms, -1)
    verifyEq(3ms <=> 3ms, 0)
    verifyEq(4ms <=> 3ms, 1)
  }

//////////////////////////////////////////////////////////////////////////
// Math
//////////////////////////////////////////////////////////////////////////

  Void testMath()
  {
    x := 2hr
    verifyEq(-x, -2hr)
    verifyEq(x + 1min, 121min)
    verifyEq(x - 1day, -22hr)
    verifyEq(x * 8, 16hr)
    verifyEq(x * 3f, 6hr)
    verifyEq(x * 0.25f, 30min)
    verifyEq(x / 4, 30min)
    verifyEq(x / 12f, 10min)
    verifyEq(x / 0.5f, 4hr)
  }

//////////////////////////////////////////////////////////////////////////
// ToInt
//////////////////////////////////////////////////////////////////////////

  Void testToInt()
  {
    verifyEq(123ms.toMillis, 123)
    verifyEq(34_567ms.toSec, 34)
    verifyEq(123sec.toMin, 2)
    verifyEq(123_456_789sec.toHour, 34293)
    verifyEq(123_456_789sec.toDay, 1428)
  }

//////////////////////////////////////////////////////////////////////////
// MinMax
//////////////////////////////////////////////////////////////////////////

  Void testMinMax()
  {
    a := 10ms
    b := -10ms
    c := 1min
    verifySame(a.min(b), b)
    verifySame(b.min(a), b)
    verifySame(a.max(b), a)
    verifySame(b.max(a), a)
    verifySame(a.max(c), c)
  }

//////////////////////////////////////////////////////////////////////////
// Abs
//////////////////////////////////////////////////////////////////////////

  Void testAbs()
  {
    verifySame(0ms.abs, 0ms)
    verifySame(88sec.abs, 88sec)
    verifyEq((-9ms).abs, 9ms)
    verifyEq((-55day).abs, 55day)
    verifyEq((3min-5min).abs, 2min)
  }

//////////////////////////////////////////////////////////////////////////
// Floor
//////////////////////////////////////////////////////////////////////////

  Void testFloor()
  {
    verifySame(2sec.floor(1sec), 2sec)
    verifyEq(119999ms.floor(1min), 1min)
    verifyEq(120001ms.floor(1min), 2min)
    verifyEq(123500ms.floor(1sec), 123sec)
    verifySame(123500ms.floor(1ms), 123500ms)
  }

//////////////////////////////////////////////////////////////////////////
// Parse/Str
//////////////////////////////////////////////////////////////////////////

  Void testStr()
  {
    // whole numbers
    //verifyStr(1ns, "1ns")
    //verifyStr(7ns, "7ns")
    verifyStr(-99ms, "-99ms")
    verifyStr(61sec, "61sec")
    verifyStr(60sec, "1min")
    verifyStr(100min, "100min")
    verifyStr(-5hr, "-5hr")
    verifyStr(365day, "365day")
    verifyStr(54750day, "54750day") // 150yr

    // TODO - underbars?

    // fractions
    verifyEq(0.5hr.toStr, "30min")
    verifyEq(Duration.fromStr("0.5hr"), 0.5hr)
    verifyEq((-1.5day).toStr, "-36hr")
    verifyEq(Duration.fromStr("-1.5day"), -36hr)

    // invalid
    verifyErr(ParseErr#) { x := Duration.fromStr("4") }
    verifyErr(ParseErr#) { x := Duration.fromStr("4x") }
    verifyErr(ParseErr#) { x := Duration.fromStr("4seconds") }
    verifyErr(ParseErr#) { x := Duration.fromStr("xms") }
    verifyErr(ParseErr#) { x := Duration.fromStr("x4ms") }
    verifyErr(ParseErr#) { x := Duration.fromStr("4days") }
  }

  Void verifyStr(Duration dur, Str format)
  {
    verifyEq(dur.toStr, format)
    verifyEq(Duration.fromStr(format), dur)
  }

//////////////////////////////////////////////////////////////////////////
// Locale
//////////////////////////////////////////////////////////////////////////
/*TODO
  Void testLocale()
  {
    //verifyEq(0ns.toLocale, "0ns")
    //verifyEq(1ns.toLocale, "1ns")
    //verifyEq(3ns.toLocale, "3ns")
    //verifyEq(999ns.toLocale, "999ns")
    //verifyEq(3000ns.toLocale, "0.003ms")
    //verifyEq(78000ns.toLocale, "0.078ms")
    //verifyEq(800_000ns.toLocale, "0.8ms")
    //verifyEq(803_900ns.toLocale, "0.803ms")
    //verifyEq(1_123_000ns.toLocale, "1.123ms")
    verifyEq(1ms.toLocale, "1ms")
    verifyEq(2ms.toLocale, "2ms")
    verifyEq(1999ms.toLocale, "1999ms")
    verifyEq(2004ms.toLocale, "2sec")
    verifyEq((6sec+88ms).toLocale, "6sec")
    verifyEq((5min+2sec).toLocale, "5min 2sec")
    verifyEq((10hr + 5min+2sec).toLocale, "10hr 5min 2sec")
    verifyEq((1day + 10hr + 5min+2sec).toLocale, "1day 10hr 5min 2sec")
    verifyEq((3day + 55sec).toLocale, "3days 55sec")
    verifyEq(5min.toLocale, "5min")
    verifyEq((1day+2min).toLocale, "1day 2min")
  }
*/
//////////////////////////////////////////////////////////////////////////
// ISO 8601
//////////////////////////////////////////////////////////////////////////
/*TODO
  Void testIso()
  {
    verifyIso(0ms,     "PT0S")
    //verifyIso(2ns,     "PT0.000000002S")
    //verifyIso(89ns,    "PT0.000000089S")
    //verifyIso(123ns,   "PT0.000000123S")
    //verifyIso(9876ns,  "PT0.000009876S")
    //verifyIso(80004ns, "PT0.000080004S")
    //verifyIso(800ns,   "PT0.0000008S")
    verifyIso(50ms,    "PT0.05S")
    verifyIso(3sec,    "PT3S")
    verifyIso(-3.6sec, "-PT3.6S")
    verifyIso(24sec,   "PT24S")
    verifyIso(6min,    "PT6M")
    verifyIso(63sec,   "PT1M3S")
    verifyIso(4hr,     "PT4H")
    verifyIso(99day,   "P99D")
    verifyIso(-26hr,   "-P1DT2H")
    verifyIso(1day+2hr+3min+4sec+5ms, "P1DT2H3M4.005S")
    verifyEq(Duration.fromIso("PT.7S"), 0.7sec) // string is PT0.7S

    verifyEq(Duration.fromIso("", false), null)
    verifyEq(Duration.fromIso("PTH4M", false), null)
    verifyEq(Duration.fromIso("PT4D", false), null)
    verifyEq(Duration.fromIso("P4ST", false), null)
    verifyErr(ParseErr#) { Duration.fromIso("3") }
    verifyErr(ParseErr#) { Duration.fromIso("3S", true) }
    verifyErr(ParseErr#) { Duration.fromIso("P3S") }
    verifyErr(ParseErr#) { Duration.fromIso("PT3S5") }
    verifyErr(ParseErr#) { Duration.fromIso("P5.0M") }
    verifyErr(ParseErr#) { Duration.fromIso("P2Y") }
  }

  Void verifyIso(Duration d, Str s)
  {
    verifyEq(d.toIso, s)
    verifyEq(Duration.fromIso(s), d)
  }
*/
//////////////////////////////////////////////////////////////////////////
// ToCode
//////////////////////////////////////////////////////////////////////////

  Void testToCode()
  {
    //verifyEq(0ns.toCode, "0ns")
    //verifyEq(3ns.toCode, "3ns")
    verifyEq((-9ms).toCode, "-9ms")
    verifyEq(40sec.toCode, "40sec")
    verifyEq(1.5hr.toCode, "90min")
    verifyEq(5hr.toCode, "5hr")
    verifyEq(2day.toCode, "2day")
  }

}