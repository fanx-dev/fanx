//
// Copyright (c) 2011, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Jan 11  Brian Frank  Creation
//

**
** Random provides different implementation of random number
** generators with more flexibility than the methods available
** in sys.  Also see `sys::Int.random`, `sys::Float.random`,
** `sys::Range.random`, and `sys::List.random`.
**
abstract class Random
{

  **
  ** Construct a cryptographically strong random number generator.
  **
  static Random makeSecure() { SecureRandom() }

  **
  ** Construct a repeatable, seeded random number generator.
  **
  static Random makeSeeded(Int seed := TimePoint.nowMillis) { SeededRandom(seed) }

  **
  ** Protected constructor for implementation classes
  **
  @NoDoc protected new makeImpl() {}

  **
  ** Generate 64-bit integer within the given range.
  ** If range is null, assume full range of 64-bit integers
  **
  abstract Int next(Range? r := null)

  **
  ** Generate random boolean.
  **
  abstract Bool nextBool()

  **
  ** Generate 64-bit floating point number between 0.0f and 1.0f.
  **
  abstract Float nextFloat()

  **
  ** Generate a randomized number of bytes.
  **
  abstract Buf nextBuf(Int size)

}

internal class SeededRandom : Random
{
  new make(Int seed) { this.seed = seed; init }
  native Void init()
  native override Int next(Range? r := null)
  native override Bool nextBool()
  native override Float nextFloat()
  native override Buf nextBuf(Int size)
  const Int seed
}

internal class SecureRandom : Random
{
  new make() { init }
  native Void init()
  native override Int next(Range? r := null)
  native override Bool nextBool()
  native override Float nextFloat()
  native override Buf nextBuf(Int size)
}