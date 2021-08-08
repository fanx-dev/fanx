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
const struct class Uuid
{
  private const Int hi
  private const Int lo
  private static const Unsafe<UuidFactory> facotry := Unsafe<UuidFactory>(UuidFactory())

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Generate a new UUID globally unique in space and time.
  **
  static Uuid make() {
    facotry.val.genUuid
  }

  **
  ** Create a 128-bit UUID from two 64-bit integers.
  **
  new makeBits(Int hi, Int lo) {
    this.hi = hi
    this.lo = lo
  }

  **
  ** Parse a UUID from according to the string format defined in the
  ** class header documentation.  If invalid format and checked is false
  ** return null, otherwise throw ParseErr.
  **
  static new fromStr(Str str) {
    try
    {
      // sanity check
      if (str.size != 36 || str.get(8) != '-' ||
          str.get(13) != '-' || str.get(18) != '-' || str.get(23) != '-')
        throw ParseErr(str)

      // parse hex components
      a := Int.fromStr(str[0..<8], 16)
      b := Int.fromStr(str[9..<13], 16)
      c := Int.fromStr(str[14..<18], 16)
      d := Int.fromStr(str[19..<23], 16)
      e := Int.fromStr(str[24..-1], 16)

      return Uuid(a.shiftl(32).or(b.shiftl(16)).or(c), d.shiftl(48).or(e));
    }
    catch (Err e)
    {
      throw ParseErr("Uuid:"+ str)
    }
  }

  **
  ** Private constructor
  **
  //private new privateMake()

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the most significant 64 bits of this 128 bit UUID.
  **
  Int bitsHi() { hi }

  **
  ** Get the least significant 64 bits of this 128 bit UUID.
  **
  Int bitsLo() { lo }

  **
  ** Return if the specified object is a Uuid with the same 128 bits.
  **
  override Bool equals(Obj? that) {
    if (that isnot Uuid) return false
    x := that as Uuid
    return x.hi == hi && x.lo == lo
  }

  **
  ** Hashcode is defined as 'bitsHi ^ bitsLow'
  **
  override Int hash() { hi.xor(lo) }

  **
  ** Compare based on the 128 bit value which will
  ** naturally result in sorts by created timestamp.
  **
  override Int compare(Obj that) {
    x := (Uuid)that;
    if (hi != x.hi) return hi < x.hi ? -1 : 1;
    if (lo == x.lo) return 0;
    return lo < x.lo ? -1 : 1;
  }

  **
  ** Return the string representation of this UUID.
  ** See class header for string format.
  **
  override Str toStr() {
    s := StrBuf(36);
    append(s, (hi.shiftr(32).and(0xFFFFFFFF)), 8);
    s.addChar('-');
    append(s, (hi.shiftr(16).and(0xFFFF)), 4);
    s.addChar('-');
    append(s, hi.and(0xFFFF), 4);
    s.addChar('-');
    append(s, lo.shiftr(48).and(0xFFFF), 4);
    s.addChar('-');
    append(s, lo.and(0xFFFFFFFFFFFF), 12);
    return s.toStr
  }

  private static Void append(StrBuf s, Int val, Int width)
  {
    str := val.toHex(width)
    //for (int i=str.length(); i<width; ++i) s.append('0');
    s.add(str)
  }

}

internal class UuidFactory {
    Int lastMillis; // last use of currentTimeMillis
    Int millisCounter; // counter to uniquify currentTimeMillis
    Int seq; // 16 byte sequence to protect against clock changes
    Int nodeAddr; // 6 bytes for this node's address

    new make() {
      nodeAddr = resolveNodeAddr
      seq = Int.random
    }

    private Int resolveNodeAddr() {
      mac := resolveMacAddr
      if (mac == 0) return Int.random
      return mac
    }

    private native static Int resolveMacAddr()

    Uuid genUuid() {
      return Uuid.makeBits(makeHi(), makeLo());
    }

    private Int makeHi() {
      now := TimePoint.nowMillis  //nowUnique
      if (lastMillis != now) {
        millisCounter = 0
        lastMillis = now
      }
      return (now * 1000000) + millisCounter++
    }

    private Int makeLo() {
      ((seq++).and(0xFFFF)).shiftl(48).or(nodeAddr)
    }
}