//
// Copyright (c) 2011, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   08 Oct 11  Brian Frank  Creation
//

class IntArrayTest : Test
{

  Void testS1()
  {
    a := IntArray.makeS1(5)
    verifyMake(a, 5)
    verifyStore(a, -128)
    verifyStore(a, 127)
    verifyStore(a, 0x7f)
  }

  Void testU1()
  {
    a := IntArray.makeU1(5)
    verifyStore(a, 255)
    verifyStore(a, 0x1234, 0x34)
    verifyStore(a, 0xff)
  }

  Void testS2()
  {
    a := IntArray.makeS2(5)
    verifyStore(a, -32_768)
    verifyStore(a, 32_767)
    verifyStore(a, 0x7fff)
  }

  Void testU2()
  {
    a := IntArray.makeU2(5)
    verifyStore(a, 65_535)
    verifyStore(a, 0xabcd_7f23_3876, 0x3876)
    verifyStore(a, 0xffff)
  }

  Void testS4()
  {
    a := IntArray.makeS4(5)
    verifyStore(a, 1)
    verifyStore(a, -9)
    verifyStore(a, 123456789)
    verifyStore(a, -2_147_483_648)
    verifyStore(a, 2_147_483_647)
    verifyStore(a, 0x0bcd_7f12_3456, 0x7f12_3456)
  }

  Void testU4()
  {
    a := IntArray.makeU4(5)
    verifyStore(a, 1)
    verifyStore(a, 4_294_967_295)
    verifyStore(a, 0xfedc_0123)
    verifyStore(a, 0x7fff_ffff)
  }

  Void testS8()
  {
    a := IntArray.makeS8(2000)
    verifyStore(a, 1)
    verifyStore(a, -9)
    verifyStore(a, -2_147_483_649)
    verifyStore(a, 2_147_483_648)
    verifyStore(a, 0x0123_4567_abcd_0982)
  }
/*
  Void testCopyFrom()
  {
    a := IntArray.makeS4(8)
    b := IntArray.makeS4(4)

    reset := |->|
    {
      for (i:=0; i<a.size; ++i) a[i] = i+1
      for (i:=0; i<b.size; ++i) b[i] = (i+1)*10
    }

    reset()
    verifyInts(a, "1,2,3,4,5,6,7,8")

    reset()
    a.copyFrom(IntArray.makeS4(0))
    verifyInts(a, "1,2,3,4,5,6,7,8")

    reset()
    a.copyFrom(b)
    verifyInts(a, "10,20,30,40,5,6,7,8")

    reset()
    a.copyFrom(b, 0..2)
    verifyInts(a, "10,20,30,4,5,6,7,8")

    reset()
    a.copyFrom(b, 0..<2)
    verifyInts(a, "10,20,3,4,5,6,7,8")

    reset()
    a.copyFrom(b, 1..-1)
    verifyInts(a, "20,30,40,4,5,6,7,8")

    reset()
    a.copyFrom(b, -3..-2)
    verifyInts(a, "20,30,3,4,5,6,7,8")

    reset()
    a.copyFrom(b, 1..2, 1)
    verifyInts(a, "1,20,30,4,5,6,7,8")

    reset()
    a.copyFrom(b, null, 3)
    verifyInts(a, "1,2,3,10,20,30,40,8")

    reset()
    a.copyFrom(b, null, 4)
    verifyInts(a, "1,2,3,4,10,20,30,40")

    reset()
    a.copyFrom(b, -1..-1, 7)
    verifyInts(a, "1,2,3,4,5,6,7,40")

    reset()
    a.copyFrom(b, 0..<0, 7)
    verifyInts(a, "1,2,3,4,5,6,7,8")

    verifyErr(ArgErr#) { a.copyFrom(IntArray.makeU4(2)) }
    verifyErr(ArgErr#) { a.copyFrom(IntArray.makeS8(2)) }
  }
*/
  Void testFill()
  {
    a := IntArray.makeU1(10)
    verifyInts(a, "0,0,0,0,0,0,0,0,0,0")
    a.fill(9, a.size)
    verifyInts(a, "9,9,9,9,9,9,9,9,9,9")
    /*
    a.fill(3, 6..-2)
    verifyInts(a, "9,9,9,9,9,9,3,3,3,9")
    a.fill(4, 0..<3)
    verifyInts(a, "4,4,4,9,9,9,3,3,3,9")
    */
    a.fill(-1, a.size)
    verifyInts(a, "255,255,255,255,255,255,255,255,255,255")
  }
/*
  Void testSort()
  {
    verifySort(IntArray.makeS1(10))
    verifySort(IntArray.makeU1(10))
    verifySort(IntArray.makeS2(10))
    verifySort(IntArray.makeU2(10))
    verifySort(IntArray.makeS4(10))
    verifySort(IntArray.makeU4(10))
    verifySort(IntArray.makeS8(10))
  }

  Void verifySort(IntArray a)
  {
    expected     := Int[,]
    expected2to5 := Int[,]
    a.size.times |i|
    {
      val := Int.random(0..100)
      a[i] = val
      expected.add(val)
      if (2 <= i && i <= 5) expected2to5.add(val)
    }

    expected2to5.sort
    a.sort(2..5)
    actual2to5 := Int[,]
    (2..5).each |i| { actual2to5.add(a[i]) }
    verifyEq(expected2to5, actual2to5)

    expected.sort
    a.sort
    actual := Int[,]
    a.size.times |i| { actual.add(a[i]) }
    verifyEq(expected, actual)
  }
*/
  Void verifyMake(IntArray a, Int size)
  {
    verifySame(a.typeof, IntArray#)
    verifyEq(a.size, size)
    for (i:=0; i<a.size; ++i) verifyEq(a[i], 0)
  }

  Void verifyStore(IntArray a, Int val, Int expected := val)
  {
    a[0] = val
    a[a.size-1] = val
    verifyEq(a[0], expected)
    verifyEq(a[a.size-1], expected)
  }

  Void verifyInts(IntArray a, Str list)
  {
    s := StrBuf()
    for(i:=0; i<a.size; ++i) s.join(a[i], ",")
    verifyEq(list, s.toStr)
  }

}


