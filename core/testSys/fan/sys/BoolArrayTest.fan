//
// Copyright (c) 2011, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   22 Oct 11  Brian Frank  Creation
//

class BoolArrayTest : Test
{

  Void testBits()
  {
    (0..<1000).each |i| { verifyBits(i) }
  }

  Void verifyBits(Int index)
  {
    a := BoolArray(1000)
    a[index] = true
    (0..<1000).each |i| { verifyEq(a[i], i==index) }

    a.fill(true, a.size)
    a[index] = false
    (0..<1000).each |i| { verifyEq(a[i], i!=index) }
  }

  Void testBitsCombo()
  {
    verifyBitCombo(2,   [1])
    verifyBitCombo(3,   [0,2])
    verifyBitCombo(100, [0, 17, 32, 63, 99])
    verifyBitCombo(100, [2, 17, 33, 64, 77])
    verifyBitCombo(100, [30, 32, 33, 35, 64, 63])
  }

  Void verifyBitCombo(Int size, Int[] indices)
  {
    a := BoolArray(size)
    indices.each |i| { a[i] = true }
    verifyEq(a.size, size)
    (0..<size).each |i| { verifyEq(a[i], indices.contains(i)) }

    c := BoolArray(size * 2)
    c.copyFrom(a, 0, 0, a.size)
    (0..<size).each |i| { verifyEq(c[i], indices.contains(i)) }
    (size..<c.size).each |i| { verifyEq(c[i], false) }
  }

}


