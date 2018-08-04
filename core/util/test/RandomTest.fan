//
// Copyright (c) 2011, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   03 Jan 11  Brian Frank  Creation
//

class RandomTest : Test
{

  Void test()
  {
    f := |Random r->Obj[]| { [r.next, r.nextBool, r.nextFloat, r.nextBuf(3).toHex] }

    r1 := Random.makeSeeded(123456789)
    r2 := Random.makeSeeded(123456789)
    verifyEq(f(r1), f(r2))
    verifyEq(f(r1), f(r2))

    r2 = Random.makeSeeded(123456780)
    verifyNotEq(f(r1), f(r2))
    verifyNotEq(f(r1), f(r2))

    verifyRandom(Random.makeSeeded)
    verifyRandom(Random.makeSeeded(1234))
    verifyRandom(Random.makeSecure)
  }

  Void verifyRandom(Random r)
  {
    // next w/out range
    acc := Int[,]
    10.times { acc.add(r.next) }
    verifyEq(acc.unique.size, 10)

    // next w/ range (positives)
    acc.clear
    300.times { acc.add(r.next(0..10)) }
    verify(acc.all { 0 <= it && it <= 10 })
    verifyEq(acc.unique.size, 11)

    // next w/ range (negatives)
    acc.clear
    300.times { acc.add(r.next(-20..<-10)) }
    verify(acc.all { -20 <= it && it < -10 })
    verifyEq(acc.unique.size, 10)

    // nextBool
    b := r.nextBool
    verify(b == true || b == false)

    // nextFloat
    100.times
    {
      f := r.nextFloat
      verify(0.0f <= f && f <= 1.0f)
    }

    // nextBuf
    buf := r.nextBuf(4)
    verify(buf is Buf)
    verifyEq(buf.size, 4)
  }
}


