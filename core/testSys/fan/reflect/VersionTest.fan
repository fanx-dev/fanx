//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   27 Jul 06  Brian Frank  Creation
//

**
** VersionTest
**
class VersionTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Parse
//////////////////////////////////////////////////////////////////////////

  Void testParse()
  {
    v := Version.fromStr("2")
    verifyEq(v.segments, [2])
    verifyEq(v.toStr, "2")

    v = Version.fromStr("1.2")
    verifyEq(v.segments, [1, 2])
    verifyEq(v.toStr, "1.2")

    v = Version.fromStr("12.0.33")
    verifyEq(v.segments, [12, 0, 33])
    verifyEq(v.toStr, "12.0.33")

    v = Version.fromStr("08.000.300")
    verifyEq(v.segments, [8, 0, 300])
    verifyEq(v.toStr, "8.0.300")

    //verifyEq(Version.fromStr("", false), null)
    //verifyEq(Version.fromStr(".", false), null)
    //verifyEq(Version.fromStr("4.x", false), null)

    verifyErr(ParseErr#) { x := Version.fromStr("") }
    verifyErr(ParseErr#) { x := Version.fromStr(".") }
    verifyErr(ParseErr#) { x := Version.fromStr("x") }
    verifyErr(ParseErr#) { x := Version.fromStr("3a") }
    verifyErr(ParseErr#) { x := Version.fromStr("3.x") }
    verifyErr(ParseErr#) { x := Version.fromStr("3..0") }
    verifyErr(ParseErr#) { x := Version.fromStr(".3.0") }
    verifyErr(ParseErr#) { x := Version.fromStr("3.0.", true) }
    verifyErr(ParseErr#) { x := Version.fromStr("1.0\n", true) }
  }

//////////////////////////////////////////////////////////////////////////
// Make
//////////////////////////////////////////////////////////////////////////

  Void testMake()
  {
    v := Version.make([1])
    verifyEq(v.segments, [1])
    verifyEq(v.segments.isRO, true)
    verifyEq(v.toStr, "1")

    v = Version.make([2, 5])
    verifyEq(v.segments, [2, 5])
    verifyEq(v.toStr, "2.5")

    v = Version.make([3, 0, 20060726])
    verifyEq(v.segments, [3, 0, 20060726])
    verifyEq(v.toStr, "3.0.20060726")

    // verify Version is independent of ints passed in
    ints := [1, 2]
    v = Version.make(ints)
    verifyEq(v.segments, [1, 2])
    verifyEq(v.toStr, "1.2")
    ints[1] = 5
    verifyEq(v.segments, [1, 2])
    verifyEq(v.toStr, "1.2")

    verifyErr(ArgErr#) { x := Version.make(Int[,]) }
    verifyErr(ArgErr#) { x := Version.make(Int[-2]) }
    verifyErr(ArgErr#) { x := Version.make(Int[1, -2]) }
    verifyErr(ReadonlyErr#) { x := Version.make([4, 8]).segments[0] = 9 }
  }

//////////////////////////////////////////////////////////////////////////
// Equals
//////////////////////////////////////////////////////////////////////////

  Void testEquals()
  {
    verifyEq(Version.fromStr("2"), Version.fromStr("2"))
    verifyEq(Version.fromStr("2"), Version.fromStr("02"))
    verifyEq(Version.fromStr("1.5.90"), Version.fromStr("1.5.90"))
    verifyEq(Version.fromStr("1.5.90"), Version.fromStr("1.05.90"))

    verifyNotEq(Version.fromStr("2"), Version.fromStr("3"))
    verifyNotEq(Version.fromStr("2"), Version.fromStr("2.0"))
    verifyNotEq(Version.fromStr("1.3"), Version.fromStr("1.2"))

    verifyEq(Version.fromStr("1.6").hash, "1.6".hash)
    verifyEq(Version.fromStr("1.006").hash, "1.6".hash)

    verifyEq(Version.defVal, Version("0"))
    verifyEq(Version.defVal.major, 0)
  }

//////////////////////////////////////////////////////////////////////////
// Comparision
//////////////////////////////////////////////////////////////////////////

  Void testComparison()
  {
    verifyComparison("1",     "1",      0)
    verifyComparison("1.8",   "1.08",   0)
    verifyComparison("2",     "1",     +1)
    verifyComparison("10",    "7",     +1)
    verifyComparison("1.5",   "1",     +1)
    verifyComparison("1.5",   "1.3",   +1)
    verifyComparison("2.0",   "1.9",   +1)
    verifyComparison("1.2",   "1.2.3", -1)
    verifyComparison("1.2.3", "1.02",  +1)
    verifyComparison("1.11",  "1.9.3", +1)
  }

  Void verifyComparison(Str a, Str b, Int cmp)
  {
    verifyEq(Version.fromStr(a) <=> Version.fromStr(b), cmp)
    //verifyEq(Version.parse(a) <=> b, cmp) - removed support
  }

//////////////////////////////////////////////////////////////////////////
// Segments
//////////////////////////////////////////////////////////////////////////

  Void testSegments()
  {
    v := Version.fromStr("1")
    verifyEq(v.segments.isRO, true)
    verifyEq(v.major, 1)
    verifyEq(v.minor, null)
    verifyEq(v.build, null)
    verifyEq(v.patch, null)

    v = Version.fromStr("1.2")
    verifyEq(v.major, 1)
    verifyEq(v.minor, 2)
    verifyEq(v.build, null)
    verifyEq(v.patch, null)

    v = Version.fromStr("1.2.3")
    verifyEq(v.major, 1)
    verifyEq(v.minor, 2)
    verifyEq(v.build, 3)
    verifyEq(v.patch, null)

    v = Version.fromStr("1.2.3.4")
    verifyEq(v.major, 1)
    verifyEq(v.minor, 2)
    verifyEq(v.build, 3)
    verifyEq(v.patch, 4)
  }

}