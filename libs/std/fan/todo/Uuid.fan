//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   30 Dec 08  Brian Frank  Creation
//

**
** Universally Unique Identifier.  UUIDs are 128-bit identifiers which
** are unique across space and time making them ideal for naming without
** a central naming authority.  Fantom's UUIDs are loosely based on RFC 4122
** with the following parts used in the generation:
**
**   - 8 bytes: nanosecond ticks since 1 Jan 2000 UTC
**   - 2 bytes: sequence number
**   - 6 bytes: node address
**
** The sequence number is initialized from a randomized number, and
** helps protect against collisions when the system clock is changed.
** The node address is ideally mapped to the MAC address if available,
** or the IP address hashed with a random number.
**
** No guarantee is made how the bytes are laid out.  Future versions
** might hash these bytes, or use alternate mechanisms.
**
** The string format for the UUID follows the canonical format of
** 32 hexadecimal digits displayed in five groups for "8-4-4-4-12".
** For example:
**   03f0e2bb-8f1a-c800-e1f8-00623f7473c4
**
@Serializable { simple = true }
const final class Uuid
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Generate a new UUID globally unique in space and time.
  **
  static new make()

  **
  ** Create a 128-bit UUID from two 64-bit integers.
  **
  static Uuid makeBits(Int hi, Int lo)

  **
  ** Parse a UUID from according to the string format defined in the
  ** class header documentation.  If invalid format and checked is false
  ** return null, otherwise throw ParseErr.
  **
  static new fromStr(Str s, Bool checked := true)

  **
  ** Private constructor
  **
  private new privateMake()

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the most significant 64 bits of this 128 bit UUID.
  **
  Int bitsHi()

  **
  ** Get the least significant 64 bits of this 128 bit UUID.
  **
  Int bitsLo()

  **
  ** Return if the specified object is a Uuid with the same 128 bits.
  **
  override Bool equals(Obj? that)

  **
  ** Hashcode is defined as 'bitsHi ^ bitsLow'
  **
  override Int hash()

  **
  ** Compare based on the 128 bit value which will
  ** naturally result in sorts by created timestamp.
  **
  override Int compare(Obj that)

  **
  ** Return the string representation of this UUID.
  ** See class header for string format.
  **
  override Str toStr()

}