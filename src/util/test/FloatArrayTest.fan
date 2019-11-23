//
// Copyright (c) 2012, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   29 Feb 12  Brian Frank  Creation
//

class FloatArrayTest : Test
{

  Void testS4()
  {
    a := FloatArray.makeF4(5)
    verifyMake(a, 5)
    verifyStores(a, true)
  }

  Void testS8()
  {
    a := FloatArray.makeF8(200)
    verifyMake(a, 200)
    verifyStores(a, false)
 }
/*
  Void testCopyFrom()
  {
    a := FloatArray.makeF4(8)
    b := FloatArray.makeF4(4)

    reset := |->|
    {
      for (i:=0; i<a.size; ++i) a[i] = (i+1).toFloat
      for (i:=0; i<b.size; ++i) b[i] = ((i+1)*10).toFloat
    }

    reset()
    verifyFloats(a, "1,2,3,4,5,6,7,8")

    reset()
    a.copyFrom(FloatArray.makeF4(0))
    verifyFloats(a, "1,2,3,4,5,6,7,8")

    reset()
    a.copyFrom(b)
    verifyFloats(a, "10,20,30,40,5,6,7,8")

    reset()
    a.copyFrom(b, 0..2)
    verifyFloats(a, "10,20,30,4,5,6,7,8")

    reset()
    a.copyFrom(b, 0..<2)
    verifyFloats(a, "10,20,3,4,5,6,7,8")

    reset()
    a.copyFrom(b, 1..-1)
    verifyFloats(a, "20,30,40,4,5,6,7,8")

    reset()
    a.copyFrom(b, -3..-2)
    verifyFloats(a, "20,30,3,4,5,6,7,8")

    reset()
    a.copyFrom(b, 1..2, 1)
    verifyFloats(a, "1,20,30,4,5,6,7,8")

    reset()
    a.copyFrom(b, null, 3)
    verifyFloats(a, "1,2,3,10,20,30,40,8")

    reset()
    a.copyFrom(b, null, 4)
    verifyFloats(a, "1,2,3,4,10,20,30,40")

    reset()
    a.copyFrom(b, -1..-1, 7)
    verifyFloats(a, "1,2,3,4,5,6,7,40")

    reset()
    a.copyFrom(b, 0..<0, 7)
    verifyFloats(a, "1,2,3,4,5,6,7,8")

    verifyErr(ArgErr#) { a.copyFrom(FloatArray.makeF8(2)) }
  }
*/
  Void testFill()
  {
    a := FloatArray.makeF4(10)
    verifyFloats(a, "0,0,0,0,0,0,0,0,0,0")
    a.fill(9f, a.size)
    verifyFloats(a, "9,9,9,9,9,9,9,9,9,9")
    /*
    a.fill(3f, 6..-2)
    verifyFloats(a, "9,9,9,9,9,9,3,3,3,9")
    a.fill(4f, 0..<3)
    verifyFloats(a, "4,4,4,9,9,9,3,3,3,9")
    */
  }
/*
  Void testSort()
  {
    verifySort(FloatArray.makeF4(10))
    verifySort(FloatArray.makeF8(10))
  }

  Void verifySort(FloatArray a)
  {
    expected     := Float[,]
    expected2to5 := Float[,]
    a.size.times |i|
    {
      val := Int.random(0..100).toFloat
      a[i] = val
      expected.add(val)
      if (2 <= i && i <= 5) expected2to5.add(val)
    }

    expected2to5.sort
    a.sort(2..5)
    actual2to5 := Float[,]
    (2..5).each |i| { actual2to5.add(a[i]) }
    verifyEq(expected2to5, actual2to5)

    expected.sort
    a.sort
    actual := Float[,]
    a.size.times |i| { actual.add(a[i]) }
    verifyEq(expected, actual)
  }
*/
  Void verifyMake(FloatArray a, Int size)
  {
    verifySame(a.typeof, FloatArray#)
    verifyEq(a.size, size)
    for (i:=0; i<a.size; ++i) verifyEq(a[i], 0f)
  }

  Void verifyStores(FloatArray a, Bool f4)
  {
    verifyStore(a, f4, 1f)
    verifyStore(a, f4, -9000.7f)
    verifyStore(a, f4, 0.02f)
    verifyStore(a, f4, Float.nan)
    verifyStore(a, f4, Float.posInf)
    verifyStore(a, f4, Float.negInf)
  }

  Void verifyStore(FloatArray a, Bool f4, Float val)
  {
    expected := val
    if (f4) expected = Float.makeBits32(val.bits32)
    a[0] = val
    a[a.size-1] = val
    verifyEq(a[0], expected)
    verifyEq(a[a.size-1], expected)
  }

  Void verifyFloats(FloatArray a, Str list)
  {
    s := StrBuf()
    for(i:=0; i<a.size; ++i) s.join(a[i].toInt, ",")
    verifyEq(list, s.toStr)
  }

}


