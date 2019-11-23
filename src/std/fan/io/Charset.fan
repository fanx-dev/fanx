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
    switch (name) {
     case "UTF-8": return utf8
     case "UTF-16BE": return utf16BE
     case "UTF-16LE": return utf16LE
    }
    res := NativeCharset.fromStr(name)
    if (res == null) {
      if (checked) throw ParseErr("invalid charset $name")
      return utf8
    }
    return res
  }

  **
  ** Private constructor
  **
  protected new privateMake(Str name, Encoder coder) {
    this.name = name
    this.encoder = coder
  }

//////////////////////////////////////////////////////////////////////////
// Standard Encodings
//////////////////////////////////////////////////////////////////////////

  **
  ** An charset for "UTF-8" format (Eight-bit UCS Transformation Format).
  **
  const static Charset utf8 := privateMake("UTF-8", Utf8())

  **
  ** Default value is `utf8`.
  **
  const static Charset defVal := utf8

  **
  ** An charset for "UTF-16BE" format (Sixteen-bit UCS Transformation
  ** Format, big-endian byte order).
  **
  const static Charset utf16BE := privateMake("UTF-16BE", Utf16(true))

  **
  ** An charset for "UTF-16LE" format (Sixteen-bit UCS Transformation
  ** Format, little-endian byte order).
  **
  const static Charset utf16LE := privateMake("UTF-16LE", Utf16(false))

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

  protected const Encoder encoder

  Int encode(Int ch, OutStream out) { encoder.encode(ch, out) }
  Int encodeArray(Int ch, Array<Int8> out, Int offset) { encoder.encodeArray(ch, out, offset) }
  Int decode(InStream in) { encoder.decode(in) }
}

@NoDoc
const abstract class Encoder {
  abstract Int encode(Int ch, OutStream out)
  abstract Int encodeArray(Int ch, Array<Int8> out, Int offset)
  abstract Int decode(InStream in)
  //abstract Int decodeArray(Array<Int8> in, Int offset)
}

//////////////////////////////////////////////////////////////////////////
// Native
//////////////////////////////////////////////////////////////////////////

internal const class NativeCharset : Encoder {

  native static Charset? fromStr(Str name)

  native override Int encode(Int ch, OutStream out)
  native override Int encodeArray(Int ch, Array<Int8> out, Int offset)
  native override Int decode(InStream in)
}

//////////////////////////////////////////////////////////////////////////
// UTF-8
//////////////////////////////////////////////////////////////////////////

internal const class Utf8 : Encoder {

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

  override Int encodeArray(Int c, Array<Int8> out, Int offset) {
    i := offset
    //echo("encode1 $c")
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
      //echo("encode ${out[i-3]}, ${out[i-2]}, ${out[i-1]}")
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
    c1 := in.r
    if (c1 < 0) return -1
    size := 0
    ch := 0
    //echo("decod1 $c1")

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
      //echo("decode $c1, $c2, $c3")
      if ((c2.and(0xC0) != 0x80) || (c3.and(0xC0) != 0x80))
            throw IOErr("Invalid UTF-8 encoding")
      ch = c1.and(0x0F).shiftl(12)
             .or(c2.and(0x3F).shiftl(6))
             .or(c3.and(0x3F))
      size = 3
    }
    else if (c1 < 0xF8) {
      c2 := in.r
      c3 := in.r
      c4 := in.r
      ch = c1.and(0x07).shiftl(18)
             .or(c2.and(0x3F).shiftl(12))
             .or(c3.and(0x3F).shiftl(6))
             .or(c4.and(0x3F))
      size = 4
    }
    else {
      throw IOErr("Invalid UTF-8 encoding")
    }
    return ch
  }
}

//////////////////////////////////////////////////////////////////////////
// UTF-16
//////////////////////////////////////////////////////////////////////////
internal const class Utf16 : Encoder {
  const Bool bigEndian

  new make(Bool bigEndian) {
    this.bigEndian = bigEndian
  }

  protected virtual Void writeBE16(Int c, OutStream out) {
    if (bigEndian) {
      out.write(c.shiftr(8).and(0xFF))
      out.write(c.and(0xFF))
    } else {
      out.write(c.and(0xFF))
      out.write(c.shiftr(8).and(0xFF))
    }
  }

  override Int encode(Int c, OutStream out)  {
    if (c <= 0xD7FF || (0xE000 <= c && c <= 0xFFFF)) {
      writeBE16(c, out)
      return 2
    }
    //surrogate pairs
    else {
      h := c.shiftr(10).and(0x3FF).or(0xD800)
      l := c.and(0x3FF).or(0xDc00)
      writeBE16(h, out)
      writeBE16(l, out)
      return 4
    }
  }

  protected virtual Void setBE16(Int c, Array<Int8> out, Int i) {
    if (bigEndian) {
      out.set(i, c.shiftr(8).and(0xFF))
      out.set(i+1, c.and(0xFF))
    } else {
      out.set(i, c.and(0xFF))
      out.set(i+1, c.shiftr(8).and(0xFF))
    }
  }

  override Int encodeArray(Int c, Array<Int8> out, Int offset) {
    i := offset
    if (c <= 0xD7FF || (0xE000 <= c && c <= 0xFFFF)) {
      setBE16(c, out, i)
      return 2
    }
    //surrogate pairs
    else {
      h := c.shiftr(10).and(0x3FF).or(0xD800)
      l := c.and(0x3FF).or(0xDc00)
      setBE16(h, out, i)
      setBE16(l, out, i+2)
      return 4
    }
  }

  protected virtual Int readBE16(InStream in) {
    c1 := in.r
    c2 := in.r
    if (c1 < 0 || c2 < 0) return -1
    if (bigEndian) {
      return c1.shiftl(8).or(c2)
    } else {
      return c1.or(c2.shiftl(8))
    }
  }

  override Int decode(InStream in) {
    c1 := readBE16(in)
    if (c1 < 0) return -1
    size := 0
    ch := 0

    if (c1 <= 0xD7FF || (0xE000 <= c1 && c1 <= 0xFFFF)) {
      ch = c1
      size = 2
    }
    //surrogate pairs
    else {
      c2 := readBE16(in)
      ch = c1.shiftl(6).or(c2.and(0x3FF))
      size = 4
    }
    return ch
  }
}

