//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Nov 06  Brian Frank  Creation
//

**
** DependTest
**
@Js
class DependTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Parse
//////////////////////////////////////////////////////////////////////////

  Void testParse()
  {
    d := Depend.fromStr("foo 0")
    verifyEq(d.toStr, "foo 0")
    verifyEq(d.equals(Depend.fromStr("foo 0")), true)
    verifyEq(d.equals(Depend.fromStr("foo 1")), false)
    verifyEq(d.hash, "foo 0".hash)
    verifyEq(d.name, "foo")
    verifyEq(d.size, 1)
    verifyEq(d.version, Version.make([0]))
    verifyEq(d.isSimple, true)
    verifyEq(d.isPlus, false)
    verifyEq(d.isRange, false)
    verifyEq(d.endVersion, null)

    d = Depend.fromStr("foo    1.2")
    verifyEq(d.toStr, "foo 1.2")
    verifyEq(d.equals(Depend.fromStr("foo 1.2")), true)
    verifyEq(d.equals(Depend.fromStr("foo 1")), false)
    verifyEq(d.hash, "foo 1.2".hash)
    verifyEq(d.name, "foo")
    verifyEq(d.size, 1)
    verifyEq(d.version, Version.make([1, 2]))
    verifyEq(d.version.segments.isRO, true)
    verifyEq(d.isSimple, true)
    verifyEq(d.isPlus, false)
    verifyEq(d.isRange, false)
    verifyEq(d.endVersion, null)

    d = Depend.fromStr("foo 4.2.65+")
    verifyEq(d.toStr, "foo 4.2.65+")
    verifyEq(d.equals(Depend.fromStr("foo   4.2.65+")), true)
    verifyEq(d.equals(Depend.fromStr("foo 4.2.65")), false)
    verifyEq(d.hash, "foo 4.2.65+".hash)
    verifyEq(d.name, "foo")
    verifyEq(d.size, 1)
    verifyEq(d.version, Version.make([4, 2, 65]))
    verifyEq(d.isSimple, false)
    verifyEq(d.isPlus, true)
    verifyEq(d.isRange, false)
    verifyEq(d.endVersion, null)

    d = Depend.fromStr("foo 1.2 - 3.4.5")
    verifyEq(d.toStr, "foo 1.2-3.4.5")
    verifyEq(d.equals(Depend.fromStr("foo 1.2-3.4.5")), true)
    verifyEq(d.equals(Depend.fromStr("foo 1.2+")), false)
    verifyEq(d.hash, "foo 1.2-3.4.5".hash)
    verifyEq(d.name, "foo")
    verifyEq(d.size, 1)
    verifyEq(d.version, Version.make([1, 2]))
    verifyEq(d.isSimple, false)
    verifyEq(d.isPlus, false)
    verifyEq(d.isRange, true)
    verifyEq(d.endVersion, Version.make([3, 4, 5]))

    d = Depend.fromStr("foo 1, 1.1.88-2.3, 5+")
    verifyEq(d.toStr, "foo 1,1.1.88-2.3,5+")
    verifyEq(d.equals(Depend.fromStr("foo 1,1.1.88-2.3,5+")), true)
    verifyEq(d.equals(Depend.fromStr("foo 1,1.1.88-2.3,5")), false)
    verifyEq(d.hash, "foo 1,1.1.88-2.3,5+".hash)
    verifyEq(d.name, "foo")
    verifyEq(d.size, 3)
    verifyEq(d.version(0), Version.make([1]))
    verifyEq(d.isSimple(0), true)
    verifyEq(d.isPlus(0), false)
    verifyEq(d.isRange(0), false)
    verifyEq(d.endVersion(0), null)
    verifyEq(d.version(1), Version.make([1, 1, 88]))
    verifyEq(d.isSimple(1), false)
    verifyEq(d.isPlus(1), false)
    verifyEq(d.isRange(1), true)
    verifyEq(d.endVersion(1), Version.make([2, 3]))
    verifyEq(d.version(2), Version.make([5]))
    verifyEq(d.isSimple(2), false)
    verifyEq(d.isPlus(2), true)
    verifyEq(d.isRange(2), false)
    verifyEq(d.endVersion(2), null)

    verifyEq(Depend.fromStr("", false), null)
    verifyEq(Depend.fromStr("3", false), null)
    verifyErr(ParseErr#) { x := Depend.fromStr("") }
    verifyErr(ParseErr#) { x := Depend.fromStr("3", true) }
    verifyErr(ParseErr#) { x := Depend.fromStr("x") }
    verifyErr(ParseErr#) { x := Depend.fromStr("x5") }
    verifyErr(ParseErr#) { x := Depend.fromStr("foo 1x") }
    verifyErr(ParseErr#) { x := Depend.fromStr("foo 1*") }
    verifyErr(ParseErr#) { x := Depend.fromStr("foo 1-*") }
    verifyErr(ParseErr#) { x := Depend.fromStr(" 8") }
    verifyErr(ParseErr#) { x := Depend.fromStr(" foo 0") }
    verifyErr(ParseErr#) { x := Depend.fromStr("foo\n1.8") }
  }

//////////////////////////////////////////////////////////////////////////
// Match
//////////////////////////////////////////////////////////////////////////

  Void testMatch()
  {
    verifyMatch("x 0", "0",   true)
    verifyMatch("x 0", "0.7", true)
    verifyMatch("x 0", "7",   false)

    verifyMatch("x 1", "1",       true)
    verifyMatch("x 1", "1.2",     true)
    verifyMatch("x 1", "1.2.3",   true)
    verifyMatch("x 1", "1.2.3.4", true)
    verifyMatch("x 1", "2",       false)

    verifyMatch("x 1.2", "1",       false)
    verifyMatch("x 1.2", "1.2",     true)
    verifyMatch("x 1.2", "1.2.3",   true)
    verifyMatch("x 1.2", "1.2.3.4", true)
    verifyMatch("x 1.2", "2",       false)
    verifyMatch("x 1.2", "1.4",     false)

    verifyMatch("x 1.2.3", "1",       false)
    verifyMatch("x 1.2.3", "1.2",     false)
    verifyMatch("x 1.2.3", "1.2.3",   true)
    verifyMatch("x 1.2.3", "1.2.3.4", true)
    verifyMatch("x 1.2.3", "2",       false)
    verifyMatch("x 1.2.3", "1.3",     false)
    verifyMatch("x 1.2.3", "1.2.4",   false)

    verifyMatch("x 2+", "0",    false)
    verifyMatch("x 2+", "1",    false)
    verifyMatch("x 2+", "1.3",  false)
    verifyMatch("x 2+", "2",    true)
    verifyMatch("x 2+", "2.99", true)
    verifyMatch("x 2+", "3",    true)
    verifyMatch("x 2+", "19",   true)

    verifyMatch("x 2.3+", "0",     false)
    verifyMatch("x 2.3+", "1",     false)
    verifyMatch("x 2.3+", "1.3",   false)
    verifyMatch("x 2.3+", "2",     false)
    verifyMatch("x 2.3+", "2.3",   true)
    verifyMatch("x 2.3+", "2.3.4", true)
    verifyMatch("x 2.3+", "2.10",  true)
    verifyMatch("x 2.3+", "3",     true)
    verifyMatch("x 2.3+", "11.2",  true)

    verifyMatch("x 1.2-3", "0",     false)
    verifyMatch("x 1.2-3", "1",     false)
    verifyMatch("x 1.2-3", "1.1",   false)
    verifyMatch("x 1.2-3", "1.2",   true)
    verifyMatch("x 1.2-3", "1.2.3", true)
    verifyMatch("x 1.2-3", "1.3",   true)
    verifyMatch("x 1.2-3", "1.11",  true)
    verifyMatch("x 1.2-3", "2",     true)
    verifyMatch("x 1.2-3", "2.9",   true)
    verifyMatch("x 1.2-3", "3",     true)
    verifyMatch("x 1.2-3", "3.8",   true)
    verifyMatch("x 1.2-3", "3.1.2", true)
    verifyMatch("x 1.2-3", "4",     false)
    verifyMatch("x 1.2-3", "10.0",  false)

    verifyMatch("x 1, 3.0-4.0, 5.2+", "0",       false)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "1",       true)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "1.9",     true)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "1.2.3",   true)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "2",       false)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "2.3",     false)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "3",       false)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "3.0",     true)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "3.0.44",  true)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "3.0.4.5", true)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "3.4",     true)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "3.4.99",  true)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "3.4.99",  true)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "4",       true)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "4.0",     true)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "4.0.22",  true)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "4.1",     false)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "4.1.8",   false)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "5",       false)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "5.0",     false)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "5.1",     false)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "5.2",     true)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "5.2.88",  true)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "5.3",     true)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "6",       true)
    verifyMatch("x 1, 3.0-4.0, 5.2+", "7.1",     true)
  }

  Void verifyMatch(Str depend, Str version, Bool expected)
  {
    verifyEq(Depend.fromStr(depend).match(Version.fromStr(version)), expected)
  }

}