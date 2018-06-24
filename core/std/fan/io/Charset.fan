//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Mar 06  Brian Frank  Creation
//

**
** Charset represents a specific character encoding used to decode
** bytes to Unicode characters, and encode Unicode characters to bytes.
**
@Serializable { simple = true }
const class Charset
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Attempt to lookup a Charset by name.  Use one of the predefined
  ** methods such as `utf8` to get a standard encoding.  If charset not
  ** found and checked is false return null, otherwise throw ParseErr.
  **
  static new fromStr(Str name, Bool checked := true) {
    if (name == "UTF-8") return utf8
    return privateMake(name)
  }

  **
  ** Private constructor
  **
  protected new privateMake(Str name) {
    this.name = name
  }

//////////////////////////////////////////////////////////////////////////
// Standard Encodings
//////////////////////////////////////////////////////////////////////////

  **
  ** An charset for "UTF-8" format (Eight-bit UCS Transformation Format).
  **
  const static Charset utf8 := Utf8()

  **
  ** Default value is `utf8`.
  **
  const static Charset defVal := utf8

  **
  ** An charset for "UTF-16BE" format (Sixteen-bit UCS Transformation
  ** Format, big-endian byte order).
  **
  const static Charset utf16BE := fromStr("UTF-16BE")

  **
  ** An charset for "UTF-16LE" format (Sixteen-bit UCS Transformation
  ** Format, little-endian byte order).
  **
  const static Charset utf16LE := fromStr("UTF-16LE")

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the name of this character encoding.
  **
  const Str name

  **
  ** Compute hash code based on case-insensitive name.
  **
  override Int hash() { name.hash }

  **
  ** Charset equality is based on the character set name
  ** ignoring case (names are not case-sensitive).
  **
  override Bool equals(Obj? obj) {
    if (obj is Charset) {
      return name.equalsIgnoreCase(((Charset)obj).name)
    }
    return false
  }

  **
  ** Return name().
  **
  override Str toStr() { name }

  virtual Int encode(Int ch, OutStream out) { throw UnsupportedErr("TODO") }
  virtual Int encodeArray(Int ch, ByteArray out, Int offset) { throw UnsupportedErr("TODO") }
  virtual Int decode(InStream in) { throw UnsupportedErr("TODO") }
  //abstract Int decodeArray(ByteArray in, Int offset)
}

//////////////////////////////////////////////////////////////////////////
// UTF-8
//////////////////////////////////////////////////////////////////////////

internal const class Utf8 : Charset {

  new make() : super.privateMake("UTF-8") {}

  override Int encode(Int c, OutStream out)  {
    if (c <= 0x007F) {
      out.write(c)
      return 1
    }
    else if (c <= 0x07FF) {
      out.write(c.shiftr(6).and(0x1F).or(0xC0))
      out.write(c.shiftr(0).and(0x3F).or(0x80))
      return 2
    }
    else if (c <= 0xFFFF) {
      out.write( c.shiftr(12).and(0x0F).or(0xE0))
      out.write( c.shiftr(6).and(0x3F).or(0x80))
      out.write( c.shiftr(0).and(0x3F).or(0x80))
      return 3
    }
    else if (c <= 0x10FFFF) {
      out.write( c.shiftr(18).and(0x07).or(0xF0))
      out.write( c.shiftr(12).and(0x3F).or(0x80))
      out.write( c.shiftr(6).and(0x3F).or(0x80))
      out.write( c.shiftr(0).and(0x3F).or(0x80))
      return 4
    }
    else {
      throw IOErr("Invalid UTF-8 encoding")
    }
  }

  override Int encodeArray(Int c, ByteArray out, Int offset) {
    i := offset
    if (c <= 0x007F) {
      out[i++] = c
    }
    else if (c <= 0x07FF) {
      out[i++] = c.shiftr(6).and(0x1F).or(0xC0)
      out[i++] = c.shiftr(0).and(0x3F).or(0x80)
    }
    else if (c <= 0xFFFF) {
      out[i++] = c.shiftr(12).and(0x0F).or(0xE0)
      out[i++] = c.shiftr(6).and(0x3F).or(0x80)
      out[i++] = c.shiftr(0).and(0x3F).or(0x80)
    }
    else if (c <= 0x10FFFF) {
      out[i++] = c.shiftr(18).and(0x07).or(0xF0)
      out[i++] = c.shiftr(12).and(0x3F).or(0x80)
      out[i++] = c.shiftr(6).and(0x3F).or(0x80)
      out[i++] = c.shiftr(0).and(0x3F).or(0x80)
    }
    else {
      throw IOErr("Invalid UTF-8 encoding")
    }
    return i - offset
  }

  override Int decode(InStream in) {
    //i := offset
    c1 := in.r
    if (c1 < 0) return -1
    size := 0
    ch := 0

    if (c1 < 0x80) {
      ch = c1
      size = 1
    }
    else if (c1 < 0xE0) {
      c2 := in.r
      ch = c1.and(0x1F).shiftl(6).
             or(c2.and(0x3F))
      size = 2
    }
    else if (c1 < 0xF0) {
      c2 := in.r
      c3 := in.r
      ch = c1.and(0x0F).shiftl(12)
             .or(c2.and(0x3F).shiftl(6))
             .or(c2.and(0x3F))
      size = 3
    }
    else if (c1 < 0xF8) {
      c2 := in.r
      c3 := in.r
      c4 := in.r
      ch = c1.and(0x07).shiftl(18)
             .or(c2.and(0x3F).shiftl(12))
             .or(c2.and(0x3F).shiftl(6))
             .or(c2.and(0x3F))
      size = 4
    }
    else {
      throw IOErr("Invalid UTF-8 encoding")
    }
    return ch
  }
}


