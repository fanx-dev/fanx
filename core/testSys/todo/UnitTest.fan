//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   20 Dec 08  Brian Frank  Creation
//

**
** UnitTest
**
@Js
class UnitTest : Test
{

  const static Str deg  := "\u00b0"
  const static Str exp2 := "\u00b2"
  const static Str exp3 := "\u00b3"

//////////////////////////////////////////////////////////////////////////
// Define
//////////////////////////////////////////////////////////////////////////

  Void testDefine()
  {
    verifyDefine("test_one,tone;kg2*m-3;33;100",
      ["test_one", "tone"], ["kg":2, "m":-3], 33f, 100f)

    verifyDefine("test_two , ttwo ;  kg1 * m 2 * sec3*K4*A5*mol6*cd7 ; -99 ;  -77",
      ["test_two", "ttwo"], ["kg":1, "m":2, "sec":3, "K":4, "A":5, "mol":6, "cd":7], -99f, -77f)

    verifyDefine("test_three, tthree; sec1; 1E10",
      ["test_three", "tthree"], ["sec":1], 1E10f, 0f)

    verifyDefine("test_four, tfour; m-9",
      ["test_four", "tfour"], ["m":-9], 1f, 0f)

    verifyDefine("test_five,test/five, testfive, tfive",
      ["test_five", "test/five", "testfive", "tfive"], Str:Int[:], 1f, 0f)

    verifyDefine("test_six",
      ["test_six"], Str:Int[:], 1f, 0f)

    verifyDefine("test_seven;kg2",
      ["test_seven"], ["kg":2], 1f, 0f)

    // bad identifiers
    verifyErr(ParseErr#) { Unit.define(";kg22") }
    verifyErr(ParseErr#) { Unit.define("test_bad,;kg22") }
    verifyErr(ParseErr#) { Unit.define("test_bad,foo bar;kg22") }
    verifyErr(ParseErr#) { Unit.define("test_bad,foo-bar;kg22") }
    verifyErr(ParseErr#) { Unit.define("test_bad,foo+bar;kg22") }
    verifyErr(ParseErr#) { Unit.define("test_bad,foo#bar;kg22") }
    verifyErr(ParseErr#) { Unit.define("test_bad,foo(bar);kg22") }

    // bad dimensions/scales
    verifyErr(ParseErr#) { Unit.define("test_bad,t8;foo2") }
    verifyErr(ParseErr#) { Unit.define("test_bad,t8;m2;xx") }
    verifyErr(ParseErr#) { Unit.define("test_bad,t8;m2;5;#") }

    verifyEq(Unit.fromStr("test_bad", false), null)
    verifyErr(Err#) { x := Unit("test_bad") }
    verifyErr(Err#) { x := Unit.fromStr("test_bad", true) }
  }

  Void verifyDefine(Str s, Str[] ids, Str:Int dim, Float scale, Float offset := 0f)
  {
    // define
    u := Unit.define(s)

    // verify identity
    verifyEq(u.ids.isImmutable, true)
    verifyEq(u.ids, ids)
    verifyEq(u.name, ids.first)
    verifyEq(u.symbol, ids.last)
    verifyEq(u.scale, scale)
    verifyEq(u.offset, offset)
    verifyEq(u, u)
    verifyEq(u.definition.contains(ids.join(", ")), true)
    verifyEq(u.hash, u.toStr.hash)
    verifyEq(u.toStr, u.symbol)
    zeroes := ["kg", "m", "sec", "K", "A", "mol", "cd"].exclude |k| { dim.keys.contains(k) }
    zeroes.each |Str x| { verifyEq(u.trap(x, null), 0) }
    dim.each |Int v, Str x| { verifyEq(u.trap(x, null), v) }

    // verify additional definitions throw
    if (Env.cur.runtime != "js")
    {
      verifyErr(Err#) { Unit.define(s) }
    }

    // verify round trip
    verifySame(Unit(u.name), u)
    verifySame(Unit(u.symbol), u)
    verifySame(Unit(u.toStr), u)

    // verify defined
    verify(Unit.list.contains(u))
    ids.each |id| { verifySame(Unit(id), u) }
  }

//////////////////////////////////////////////////////////////////////////
// Database
//////////////////////////////////////////////////////////////////////////

  Void testDatabase()
  {
    m := Unit("meter")
    verifyEq(m.ids.isImmutable, true)
    verifyEq(m.ids, ["meter", "m"])
    verifyEq(m.name, "meter")
    verifyEq(m.symbol, "m")
    verifyEq(m.m, 1)
    verifyEq(m.dim, "m1")

    m3 := Unit("m${exp3}")
    verifyEq(m3.ids, ["cubic_meter", "m${exp3}"])
    verifyEq(m3.name, "cubic_meter")
    verifyEq(m3.symbol, "m${exp3}")
    verifyEq(m3.m, 3)
    verifyEq(m3.dim, "m3")

    all := Unit.list
    verifyType(all, Unit[]#)
    verify(all.contains(m))
    verify(all.contains(m3))
    n := 0
    all.each |u| { if (u === m) n++ }
    verifyEq(n, 1)

    quantities := Unit.quantities
    verify(quantities.size > 0)
    verify(quantities.isImmutable)
    verifyType(quantities, Str[]#)

    verify(quantities.contains("length"))
    verify(Unit.quantity("length").contains(m))
    verifyEq(Unit.quantity("length").of, Unit#)
    verify(Unit.quantity("length").isImmutable)

    verify(quantities.contains("volume"))
    verify(Unit.quantity("volume").contains(m3))

    verifyNotNull(Unit.quantity(quantities.last))
  }

//////////////////////////////////////////////////////////////////////////
// Conversion
//////////////////////////////////////////////////////////////////////////

  Void testConversionLength()
  {
    m  := Unit("meter")
    km := Unit("kilometer")
    mm := Unit("millimeter")
    in := Unit("inch")
    ft := Unit("foot")
    mi := Unit("mile")

    verifyConv(1f, m, 0.001f, km)
    verifyConv(1f, m, 1000f, mm)
    verifyConv(1f, m, 39.3700787f, in)
    verifyConv(1f, m, 3.2808399f, ft)
    verifyConv(1f, m, 0.000621371192f, mi)

    verifyConv(1000f, m, 1f, km)
    verifyConv(2f, km, 1.24274238f, mi)
    verifyConv(12f, in, 1f, ft)
    verifyConv(1f, mi, 5280f, ft)
    verifyConv(70f, mm, 2.75590551f, in)

    verifyErr(Err#) { verifyConv(60f, m, 1f, Unit("cubic_meter")) }
  }

  Void testConversionTime()
  {
    sec := Unit("second")
    min := Unit("minute")
    hr  := Unit("hour")

    verifyConv(60f, sec, 1f, min)
    verifyConv(60f, min, 1f, hr)
    verifyConv(2.5f, hr, 150f, min)

    verifyErr(Err#) { verifyConv(60f, sec, 1f, Unit("meter")) }
  }

  Void testConversionTemp()
  {
    k := Unit("kelvin")
    c := Unit("celsius")
    f := Unit("fahrenheit")

    verifyConv(0f, c, 273.15f, k)
    verifyConv(273.15f, k, 32f, f)
    verifyConv(0f, c, 32f, f)
    verifyConv(100f, c, 212f, f)
    verifyConv(75f, f, 23.88889f, c)
    verifyConv(37f, c, 98.6f, f)
  }

  Void testConversionBytes()
  {
    b  := Unit("byte")
    kb := Unit("kB")
    mb := Unit("MB")
    gb := Unit("GB")
    tb := Unit("TB")

    verifyConv(1f, kb, 1024f, b)
    verifyConv(1f, mb, 1048576f, b)
    verifyConv(2f, mb, 2048f, kb)
    verifyConv(0.5f, gb, 524288f, kb)
    verifyConv(1024f, kb, 1f, mb)
    verifyConv(1f, tb, 1024f, gb)
  }

  Void verifyConv(Float from, Unit fromUnit, Float to, Unit toUnit)
  {
    actual := fromUnit.convertTo(from, toUnit)
    //echo("$from $fromUnit.symbol -> $to $toUnit.symbol ?= " + actual)
    verify(actual.approx(to))
  }

//////////////////////////////////////////////////////////////////////////
// Serialization
//////////////////////////////////////////////////////////////////////////

  Void testSerialization()
  {
    mph := Unit("miles_per_hour")
    s := Buf().writeObj(mph).flip.readAllStr
    verifyEq(s, Str<|sys::Unit("mph")|>)
    verifySame(s.in.readObj, mph)
  }

//////////////////////////////////////////////////////////////////////////
// Mult/Div
//////////////////////////////////////////////////////////////////////////

  Void testMult()
  {
    verifyMult("m", "m", "m${exp2}")
    verifyMult("ft", "ft", "ft${exp2}")
    verifyMult("ft", "ft${exp2}", "ft${exp3}")
    verifyMult("kW", "h", "kWh")
    verifyMult("BTU/h", "h", "BTU")
    verifyErr(Err#) { x := Unit("ft") * Unit("L") }
  }

  Void verifyMult(Str a, Str b, Str prod)
  {
    verifySame(Unit(a) * Unit(b), Unit(prod))
  }

  Void testDiv()
  {
    verifyDiv("km", "h", "km/h")
    verifyDiv("mile", "h", "mph")
    verifyDiv("kW", "ft\u00b2", "kW/ft${exp2}")
    verifyDiv("kWh", "m\u00b2", "kWh/m${exp2}")
    verifyDiv("${deg}C", "min", "${deg}C/min")
    verifyDiv("ft${exp3}", "min", "cfm")
    verifyErr(Err#) { x := Unit("ft") / Unit("${deg}C/min") }
  }

  Void verifyDiv(Str a, Str b, Str quotient)
  {
    verifySame(Unit(a) / Unit(b), Unit(quotient))
  }

//////////////////////////////////////////////////////////////////////////
// Unicode
//////////////////////////////////////////////////////////////////////////

  Void testUnicode()
  {
    // test ohm \u2126 which can normalized into \u03A9
    verifySame(Unit.fromStr("\u2126"), Unit.fromStr("\u03A9"))
    Unit.list.each |unit|
    {
      if (unit.symbol.contains("\u2126"))
        verifySame(unit, Unit.fromStr(unit.symbol.replace("\u2126", "\u03A9")))
    }
  }

}