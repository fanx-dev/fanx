//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   22 Mar 06  Brian Frank  Creation
//

**
** RangeTest
**
@Js
class RangeTest : Test
{

  Void testType()
  {
    r := 0..2
    verifyType(r, Range#)
  }

  Void testEquals()
  {
    Obj? x := 0..2
    verifySame(Type.of(x), Range#)
    verify(x == Range.makeInclusive(0, 2))
    verify(x != Range.makeExclusive(0, 2))
    verify(0..<2 != Range.makeInclusive(0, 2))
    verify(0..<2 == Range.makeExclusive(0, 2))
    verify(x!= "wow")
    verify(0..1  == 0..1)
    verify(0..-1 == 0..-1)
    verify(0..-1 != 0..1)
    verify(0..-1 != -1..0)
    verify(x != null)
    verify(null != x)
  }

  Void testToStr()
  {
    verifyEq((0..2).toStr, "0..2")
    verifyEq((0..<2).toStr, "0..<2")
  }

  Void testStartEnd()
  {
    verifyEq((0..2).start, 0)
    verifyEq((0..2).end, 2)
    verifyEq((0..2).inclusive, true)
    verifyEq((0..2).exclusive, false)

    verifyEq((0..<2).start, 0)
    verifyEq((0..<2).end, 2)
    verifyEq((0..<2).inclusive, false)
    verifyEq((0..<2).exclusive, true)

    verifyEq((-2..-1).start, -2)
    verifyEq((-2..-1).end, -1)
    verifyEq((-2..-1).inclusive, true)
    verifyEq((-2..-1).exclusive, false)
  }

  Void testContains()
  {
    verifyEq((-2..2).contains(-3), false)
    verifyEq((-2..2).contains(-2), true)
    verifyEq((-2..2).contains(0), true)
    verifyEq((-2..2).contains(2), true)
    verifyEq((-2..<2).contains(2), false)
    verifyEq((-2..2).contains(3), false)
    verifyEq((-2..<2).contains(3), false)

    verifyEq((3..0).contains(4), false)
    verifyEq((3..0).contains(3), true)
    verifyEq((3..0).contains(1), true)
    verifyEq((3..0).contains(0), true)
    verifyEq((3..0).contains(-1), false)
    verifyEq((3..<0).contains(0), false)
    verifyEq((3..<0).contains(1), true)
    verifyEq((3..<0).contains(3), true)
    verifyEq((3..<0).contains(3), true)
  }

  Void testOffset()
  {
    verifyEq((10..20).offset(0), 10..20)
    verifyEq((10..20).offset(5), 15..25)
    verifyEq((10..20).offset(-5), 5..15)
    verifyEq((-10..<-20).offset(0), -10..<-20)
    verifyEq((-10..<-20).offset(5), -5..<-15)
    verifyEq((-10..<-20).offset(-5), -15..<-25)
  }

  Void testEach()
  {
    list := Int[,]

    list.clear;
    (2..4).each |Int i| { list.add(i) }
    verifyEq(list, [2, 3, 4])

    list.clear;
    ('a'..<'d').each |Int i| { list.add(i) }
    verifyEq(list, ['a', 'b', 'c'])

    list.clear;
    (5..-2).each |Int i| { list.add(i) }
    verifyEq(list, [5, 4, 3, 2, 1, 0, -1, -2])

    list.clear;
    (6..<3).each |Int i| { list.add(i) }
    verifyEq(list, [6, 5, 4])
  }

  Void testEachWhile()
  {
    list := Int[,]

    list.clear
    r := (4..99).eachWhile |i| { if (i == 7) return "foo"; list.add(i); return null }
    verifyEq(r, "foo")
    verifyEq(list, [4, 5, 6])

    list.clear
    r = (4..7).eachWhile |i| { list.add(i); return null }
    verifyEq(r, null)
    verifyEq(list, [4, 5, 6, 7])

    list.clear
    r = (4..<7).eachWhile |i| { list.add(i); return null }
    verifyEq(r, null)
    verifyEq(list, [4, 5, 6])

    list.clear
    r = (-1..-4).eachWhile |i| { list.add(i); return null }
    verifyEq(r, null)
    verifyEq(list, [-1, -2, -3, -4])

    list.clear
    r = (-1..<-4).eachWhile |i| { list.add(i); return null }
    verifyEq(r, null)
    verifyEq(list, [-1, -2, -3])

    list.clear
    r = (-1..<-4).eachWhile |i| { if (i == -2) return this; list.add(i); return null }
    verifySame(r, this)
    verifyEq(list, [-1])
  }

  Void testMap()
  {
    verifyEq((0..3).map { it.toStr }, Obj?["0", "1", "2", "3"])
    verifyEq((0..<3).map { it.toStr }, Obj?["0", "1", "2"])
    verifyEq((0..<3).map |i->Str| { i.toStr }, Str["0", "1", "2"])
    verifyEq((9..7).map |i->Float| { i.toFloat }, Float[9f, 8f, 7f])
    verifyEq((9..<7).map |i->Float| { i.toFloat }, Float[9f, 8f])
  }

  Void testList()
  {
    verifyList(0..0,   [0])
    verifyList(0..<0,  Int[,])
    verifyList(3..<3,  Int[,])
    verifyList(2..4,   [2,3,4])
    verifyList(2..<4,  [2,3])
    verifyList(-2..2,  [-2,-1,0,1,2])
    verifyList(10..8,  [10,9,8])
    verifyList(10..<8, [10,9])
    verifyList(-4..-8, [-4,-5,-6,-7,-8])
  }

  Void verifyList(Range r, Int[] list)
  {
    verifyEq(r.toList,  list)
    verifyEq(r.isEmpty, list.isEmpty)
    verifyEq(r.min,     list.min)
    verifyEq(r.max,     list.max)
    verifyEq(r.first,   list.first)
    verifyEq(r.last,    list.last)
  }

  Void testRandom()
  {
    acc := Int:Bool[:]
    1000.times { acc.set((0..20).random, true) }
    21.times { verify(acc[it]) }

    acc.clear
    1000.times { acc.set((0..<20).random, true) }
    20.times { verify(acc[it]) }
    verifyNull(acc[20])
  }

  Void testFromStr()
  {
    verifyEq(Range.fromStr("2..3"), 2..3)
    verifyEq(Range.fromStr("123..456"), 123..456)
    verifyEq(Range.fromStr("-6..<-2"), -6..<-2)
    //verifyEq(Range.fromStr("3.4", false), null)
    verifyErr(ParseErr#) { r := Range.fromStr("x..4", true) }
    verifyErr(ParseErr#) { r := Range.fromStr("3..x") }
    //verifyEq(0..<7.toStr.in.readObj, 0..<7)
    verifyEq(Range#.method("fromStr").call("0..10"), 0..10)
  }


}