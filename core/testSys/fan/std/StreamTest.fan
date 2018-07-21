//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   27 Mar 06  Brian Frank  Creation
//

**
** StreamTest
**
class StreamTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Basic IO
//////////////////////////////////////////////////////////////////////////

  Void testBasicIO()
  {
    // open file output stream
    f := tempDir + `stream.txt`
    OutStream out := f.out

    // verify typing of out stream
    verifyIsType(out, OutStream#)
    //verifyEq(Type.of(out).qname, "sys::SysOutStream")

    // write one byte
    out.write('x')
    out.close()
    verifyEq(f.size, 1)

    // open file input stream
    InStream in := f.in

    // verify typing of in stream
    verifyIsType(in, InStream#)
    //verifyEq(Type.of(in).qname, "sys::SysInStream")

    // read one byte back
    verifyEq(in.read, 'x')
    verifyEq(in.read, -1)
    verifyEq(in.read, -1)
    in.close()
  }

//////////////////////////////////////////////////////////////////////////
// Buf IO
//////////////////////////////////////////////////////////////////////////

  Void testBufIO()
  {
    // open file output stream
    f := tempDir + `buf.txt`
    OutStream out := f.out

    // write buf and flip for draining
    buf := Buf.make
    buf.write('f').write('a').write('n').write(0xFF)
    buf.flip
    verifyEq(buf.pos,  0)
    verifyEq(buf.size, 4)

    // drain to out stream
    out.writeBuf(buf)
    verifyEq(buf.pos, 4)
    verifyEq(buf.remaining, 0)
    verifyEq(buf.size, 4)

    // flip and drain just one byte
    out.writeBuf(buf.flip, 1)
    verifyEq(buf.pos, 1)
    verifyEq(buf.remaining, 3)
    verifyEq(buf.size, 4)

    // close file
    out.close()
    verifyEq(f.size, 5)

    // ok, now read entire file back in
    InStream in := f.in
    buf.clear
    verifyEq(in.readBuf(buf, f.size), f.size)
    verifyEq(buf.size, 5)
    verifyEq(buf.pos,  5)
    verifyEq(buf.remaining, 0)
    verifyEq(buf[0], 'f')
    verifyEq(buf[1], 'a')
    verifyEq(buf[2], 'n')
    verifyEq(buf[3], 0xFF)
    verifyEq(buf[4], 'f')

    // read at end of stream
    verifyEq(in.readBuf(buf, f.size), -1)
    verifyEq(buf.size, 5)
    verifyEq(buf.pos,  5)
    verifyEq(buf.remaining, 0)
    in.close

    // reopen, and read one byte at a time
    in = f.in
    buf.clear
    5.times |Int i|
    {
      verifyEq(in.readBuf(buf, 1), 1)
      verifyEq(buf.size, i+1)
      verifyEq(buf.pos,  i+1)
      verifyEq(buf.remaining, 0)
    }
    verifyEq(in.readBuf(buf, f.size), -1)
    verifyEq(buf.size, 5)
    verifyEq(buf.pos,  5)
    verifyEq(buf[0], 'f')
    verifyEq(buf[1], 'a')
    verifyEq(buf[2], 'n')
    verifyEq(buf[3], 0xFF)
    verifyEq(buf[4], 'f')
    in.close
  }

//////////////////////////////////////////////////////////////////////////
// Binary IO
//////////////////////////////////////////////////////////////////////////

  Void testBinary()
  {
    f := tempDir + `binary.hex`
    OutStream out := f.out
    writeBinary(out)
    out.close

    InStream in := f.in
    readBinary(this, in)
    in.close
  }

  static Void writeBinary(OutStream out)
  {
    buf := Buf.make
    buf.writeI4(0xabcd9876)
    buf.flip

    0xff.times |Int b| { out.write(b); }
    out.write(0)
    out.write(1)
    out.write(255)
    out.write(-1)
    out.write(127)
    out.write(-128)
    out.writeBuf(buf)
    out.writeI2(0)
    out.writeI2(0xabcd)
    out.writeI2(0x0023)
    out.writeI2(0x00ff)
    out.writeI2(0xff00)
    out.writeI2(0x1600)
    out.writeI2(0xffff)
    out.writeI2(1)
    out.writeI2(257)
    out.writeI2(32767)
    out.writeI2(-1)
    out.writeI2(-256)
    out.writeI2(-32768)
    out.writeI4(0x7654_3210)
    out.writeI4(0xff00_0000)
    out.writeI4(0x00ff_0000)
    out.writeI4(0x0000_ff00)
    out.writeI4(0x0000_00ff)
    out.writeI4(0x8004_3001)
    out.writeI4(-1)
    out.writeI4(-67800)
    out.writeI4(2_147_483_647)
    out.writeI4(-2_147_483_648)
    if (!isJs)
    {
      out.writeI8(0x0123_4567_89ab_cdef)
      out.writeI8(0xff00_0300_8001_0050)
      out.writeI8(0x7fff_ffff_ffff_ffff)
      out.writeI8(0)
      out.writeI8(-1)
      out.writeI8(-2)
      out.writeF4(0.0f)
      out.writeF4(-1.0f)
      out.writeF4(1.0f)
      out.writeF4(0.0005f)
      out.writeF4(-960.05f)
      out.writeF4(128e22f)
      out.writeF4(-128e22f)
      out.writeF4(Float.nan)
      out.writeF4(Float.posInf)
      out.writeF4(Float.negInf)
      out.writeF8(0.0f)
      out.writeF8(-1.0f)
      out.writeF8(2.0f)
      out.writeF8(71.9003e30f)
      out.writeF8(-0.000000074f)
      out.writeF8(3.12456789f)
      out.writeF8(Float.nan)
      out.writeF8(Float.posInf)
      out.writeF8(Float.negInf)
      //out.writeDecimal(-123.456d)
      //out.writeDecimal(61e-20d)
    }
    out.writeBool(false)
    out.writeBool(true)
    out.writeUtf("")
    out.writeI4(0x01_02_03_04)
    out.writeUtf("Z")
    out.writeUtf("Apple")
    out.writeUtf("a\u00FF\uabcd")
    out.writeUtf("\u00F7*\uFB6E\u043B\u0000\n&cool")

    // little endian
    if (out.endian !== Endian.big) throw Err()
    out.endian = Endian.little
    if (out.endian !== Endian.little) throw Err()
    out.writeI2(0xaabb)
    out.writeI4(0xaabbccdd)
    if (!isJs)
    {
      out.writeI8(0xaabbccdd11223344)
    }
    out.writeI2(0xaabb)
    out.writeI2(-2398)
    out.writeI4(0xaabbccdd)
    out.writeI4(-123_456)
    if (!isJs)
    {
      out.writeI8(0xaabbccdd11223344)
    }
    out.endian = Endian.big
    if (out.endian !== Endian.big) throw Err()

    // end-of-stream tests
    out.writeI4(0x01_02_03_04)
  }

  static Void readBinary(Test test, InStream in, Bool testSize := true)
  {
    0xff.times |Int b| { test.verifyEq(in.read, b); }
    test.verifyEq(in.readU1, 0)
    test.verifyEq(in.readU1, 1)
    test.verifyEq(in.readU1, 255)
    test.verifyEq(in.readS1, -1)
    test.verifyEq(in.readS1, 127)
    test.verifyEq(in.readS1, -128)
    buf := in.readBufFully(null, 4); test.verifyEq(buf.size, 4); test.verifyEq(buf.readU4, 0xabcd9876)
    test.verifyEq(in.readU2, 0)
    test.verifyEq(in.readU2, 0xabcd)
    test.verifyEq(in.readU2, 0x0023)
    test.verifyEq(in.readU2, 0x00ff)
    test.verifyEq(in.readU2, 0xff00)
    test.verifyEq(in.peek, 0x16)
    test.verifyEq(in.readU2, 0x1600)
    test.verifyEq(in.readU2, 0xffff)
    test.verifyEq(in.readS2, 1)
    test.verifyEq(in.readS2, 257)
    test.verifyEq(in.readS2, 32767)
    test.verifyEq(in.readS2, -1)
    test.verifyEq(in.readS2, -256)
    test.verifyEq(in.readS2, -32768)
    test.verifyEq(in.peek, 0x76)
    test.verifyEq(in.readU4, 0x7654_3210)
    test.verifyEq(in.readU4, 0xff00_0000)
    test.verifyEq(in.readU4, 0x00ff_0000)
    test.verifyEq(in.readU4, 0x0000_ff00)
    test.verifyEq(in.readU4, 0x0000_00ff)
    test.verifyEq(in.readU4, 0x8004_3001)
    test.verifyEq(in.readS4, -1)
    test.verifyEq(in.readS4, -67800)
    test.verifyEq(in.readS4, 2_147_483_647)
    test.verifyEq(in.readS4, -2_147_483_648)
    if (!isJs)
    {
      test.verifyEq(in.readS8, 0x0123_4567_89ab_cdef)
      test.verifyEq(in.readS8, 0xff00_0300_8001_0050)
      test.verifyEq(in.readS8, 0x7fff_ffff_ffff_ffff)
      test.verifyEq(in.readS8, 0)
      test.verifyEq(in.readS8, -1)
      test.verifyEq(in.readS8, -2)
      test.verifyEq(in.readF4, 0.0f)
      test.verifyEq(in.readF4, -1.0f)
      test.verifyEq(in.readF4, 1.0f)
      test.verify(in.readF4.approx(0.0005f))
      test.verify(in.readF4.approx(-960.05f))
      test.verify(in.readF4.approx(128e22f))
      test.verify(in.readF4.approx(-128e22f))
      test.verifyEq(in.readF4, Float.nan)
      test.verifyEq(in.readF4, Float.posInf)
      test.verifyEq(in.readF4, Float.negInf)
      test.verifyEq(in.readF8, 0.0f)
      test.verifyEq(in.readF8, -1.0f)
      test.verifyEq(in.readF8, 2.0f)
      test.verify(in.readF8.approx(71.9003e30f))
      test.verify(in.readF8.approx(-0.000000074f))
      test.verify(in.readF8.approx(3.12456789f))
      test.verifyEq(in.readF8, Float.nan)
      test.verifyEq(in.readF8, Float.posInf)
      test.verifyEq(in.readF8, Float.negInf)
      //test.verifyEq(in.readDecimal, -123.456d)
      //test.verifyEq(in.readDecimal, 61e-20d)
    }
    test.verifyEq(in.readBool, false)
    test.verifyEq(in.readBool, true)
    test.verifyEq(in.readUtf, "")
    test.verifyEq(in.skip(4), 4)
    test.verifyEq(in.readUtf, "Z")
    test.verifyEq(in.readUtf, "Apple")
    test.verifyEq(in.readUtf, "a\u00FF\uabcd")
    test.verifyEq(in.readUtf, "\u00F7*\uFB6E\u043B\u0000\n&cool")

    // little endian
    test.verifyEq(in.readU2, 0xbbaa)
    test.verifyEq(in.readU4, 0xddccbbaa)
    if (!isJs)
    {
      test.verifyEq(in.readS8, 0x44332211ddccbbaa)
    }
    test.verifySame(in.endian, Endian.big)
    in.endian = Endian.little
    test.verifySame(in.endian, Endian.little)
    test.verifyEq(in.readU2, 0xaabb)
    test.verifyEq(in.readS2, -2398)
    test.verifyEq(in.readU4, 0xaabbccdd)
    test.verifyEq(in.readS4, -123_456)
    if (!isJs)
    {
      test.verifyEq(in.readS8, 0xaabbccdd11223344)
    }
    in.endian = Endian.big
    test.verifySame(in.endian, Endian.big)

    // end of stream tests
    if (testSize)
    {
      // Java PushbackInputStream seems broken
      // test.verifyEq(in.skip(6), 4)
      in.skip(6)
      test.verifyEq(in.peek, -1)
      test.verifyEq(in.read, -1)
      test.verifyEq(in.peek, -1)
      test.verifyEq(in.read, -1)

      test.verifyErr(IOErr#) { in.readBufFully(null, 1) }
      test.verifyErr(IOErr#) { in.readU1 }
      test.verifyErr(IOErr#) { in.readS1 }
      test.verifyErr(IOErr#) { in.readU2 }
      test.verifyErr(IOErr#) { in.readS2 }
      test.verifyErr(IOErr#) { in.readU4 }
      test.verifyErr(IOErr#) { in.readS4 }
      if (!isJs)
      {
        test.verifyErr(IOErr#) { in.readS8 }
        test.verifyErr(IOErr#) { in.readF4 }
        test.verifyErr(IOErr#) { in.readF8 }
      }
      test.verifyErr(IOErr#) { in.readUtf}
    }
  }

//////////////////////////////////////////////////////////////////////////
// Bits
//////////////////////////////////////////////////////////////////////////
/*
  Void testBits()
  {
    // basic writes
    buf := Buf()
    out := buf.out
    out.writeBits(0x1, 1); verifyEq(out.numPendingBits, 1)
    out.writeBits(0x5, 3); verifyEq(out.numPendingBits, 4)
    out.writeBits(0x9, 5); verifyEq(out.numPendingBits, 1)
    out.writeBits(0x4, 4); verifyEq(out.numPendingBits, 5)
    out.writeBits(0x7bcd, 15)
    out.flush
    verifyEq(buf.toHex, "d4a7bcd0")

    // write arg checking
    100.times { buf.out.writeBits(0xabcd, 0) }
    verifyErr(ArgErr#) { buf.out.writeBits(1, -1) }
    verifyErr(ArgErr#) { buf.out.writeBits(1, 65) }
    verifyEq(buf.toHex, "d4a7bcd0")

    // basic reads
    buf.flip
    verifyErr(ArgErr#) { buf.in.readBits(-1) }
    verifyErr(ArgErr#) { buf.in.readBits(65) }
    verifyEq(buf.in.numPendingBits, 0)
    verifyEq(buf.in.readBits(1),  0x1);  verifyEq(buf.in.numPendingBits, 7)
    verifyEq(buf.in.readBits(3),  0x5);  verifyEq(buf.in.numPendingBits, 4)
    verifyEq(buf.in.readBits(5),  0x9);  verifyEq(buf.in.numPendingBits, 7)
    verifyEq(buf.in.readBits(4),  0x4);  verifyEq(buf.in.numPendingBits, 3)
    verifyEq(buf.in.readBits(15), 0x7bcd);  verifyEq(buf.in.numPendingBits, 4)

    // test large sampling of random value/bit sizes
    vals := Int[,]
    nums := Int[,]
    buf = Buf()
    1000.times
    {
      num := (1..64).random
      val := num == 64 ? Int.random : (0..(1.shiftl(num-1))).random
      vals.add(val)
      nums.add(num)
      buf.out.writeBits(val, num)
    }
    buf.out.flush

    // read back out
    buf.flip
    vals.each |val, i|
    {
      num := nums[i]
      actual := buf.in.readBits(num)
      verifyEq(val, actual)
    }

  }
*/
//////////////////////////////////////////////////////////////////////////
// Char UTF-8
//////////////////////////////////////////////////////////////////////////

  Void testCharUtf8()
  {
    // write default utf-8
    f := tempDir + `chars-utf8.txt`;
    out := f.out
    verifyEq(f.size, 0)
    out.writeChar('a')
    out.writeChar('b')
    out.writeChar('c')
    out.writeChars("def")
    out.close
    out = f.out(true)
    out.writeChars("badass", 3)
    out.writeChars("BADADD", 0, 3)
    out.close
    out = f.out(true, 0)
    out.writeChar(0xf6)
    out.writeChar(0xabcd)
    out.write(0x33)
    out.close
    verifyEq(f.size, 18)

    // read file back in
    in := f.in(0)
    verifyEq(in.readChar, 'a')
    verifyEq(in.readChar, 'b')
    verifyEq(in.readChar, 'c')
    verifyEq(in.peekChar, 'd')
    verifyEq(in.readChar, 'd')
    verifyEq(in.readChar, 'e')
    verifyEq(in.readChar, 'f')
    verifyEq(in.readChar, 'a')
    verifyEq(in.readChar, 's')
    verifyEq(in.readChar, 's')
    verifyEq(in.readChar, 'B')
    verifyEq(in.readChar, 'A')
    verifyEq(in.readChar, 'D')
    verifyEq(in.readChar, 0xf6)
    verifyEq(in.peekChar, 0xabcd)
    verifyEq(in.readChar, 0xabcd)
    verifyEq(in.read,     0x33)
    verifyEq(in.readChar, -1)
    verifyEq(in.peekChar, -1)
    verifyEq(in.read,     -1)
    in.close
  }

//////////////////////////////////////////////////////////////////////////
// Char UTF-16BE
//////////////////////////////////////////////////////////////////////////

  Void testCharUtf16BE()
  {
    // write utf-16BE
    f := tempDir + `chars-utf16be.txt`;
    out := f.out
    out.charset = Charset.utf16BE
    verifyEq(f.size, 0)
    out.writeChar('a')
    out.writeChar('b')
    out.writeChar('c')
    out.writeChars("def")
    out.writeChars("badass", 3)
    out.writeChars("BADADD", 1, 3)
    out.writeChar(0xf6)
    out.writeChar(0xabcd)
    out.close
    verifyEq(f.size, 28)

    // read file back in
    in := f.in
    in.charset = Charset.utf16BE
    verifyEq(in.readChar, 'a')
    verifyEq(in.readChar, 'b')
    verifyEq(in.readChar, 'c')
    verifyEq(in.readChar, 'd')
    verifyEq(in.readChar, 'e')
    verifyEq(in.readChar, 'f')
    verifyEq(in.readChar, 'a')
    verifyEq(in.readChar, 's')
    verifyEq(in.readChar, 's')
    verifyEq(in.readChar, 'A')
    verifyEq(in.peekChar, 'D')
    verifyEq(in.readChar, 'D')
    verifyEq(in.readChar, 'A')
    verifyEq(in.peekChar, 0xf6)
    verifyEq(in.readChar, 0xf6)
    verifyEq(in.readChar, 0xabcd)
    verifyEq(in.readChar, -1)
    verifyEq(in.peekChar, -1)
    verifyEq(in.read,     -1)
    verifyEq(in.readChar, -1)
    in.close
  }

//////////////////////////////////////////////////////////////////////////
// Char UTF-16LE
//////////////////////////////////////////////////////////////////////////

  Void testCharUtf16LE()
  {
    // write utf-16LE
    f := tempDir + `chars-utf16le.txt`;
    out := f.out
    out.charset = Charset.utf16LE
    verifyEq(f.size, 0)
    out.writeChar('a')
    out.writeChars(" r ")
    out.writeChar(0xff)
    out.writeChar(0xbcde)
    out.close
    verifyEq(f.size, 12)

    // read file back in
    in := f.in
    in.charset = Charset.utf16LE
    verifyEq(in.readChar, 'a')
    verifyEq(in.readChar, ' ')
    verifyEq(in.readChar, 'r')
    verifyEq(in.readChar, ' ')
    verifyEq(in.readChar, 0xff)
    verifyEq(in.readChar, 0xbcde)
    verifyEq(in.read, -1)
    verifyEq(in.readChar, -1)
    in.close
  }

//////////////////////////////////////////////////////////////////////////
// Char ISO-8859
//////////////////////////////////////////////////////////////////////////

  Void testISO_8859()
  {
    // Since ISO-8859 maps to bytes, we have to select specific
    // Unicode characters present in each charset to test

    // ISO-8859-1 Latin 1 Western Europe (maps directly to Unicode)
    // http://www.unicode.org/Public/MAPPINGS/ISO8859/8859-1.TXT
    s := "ab\u00C0\u00FD\u00FE"
    verifyISO_8859(s, Charset.fromStr("ISO-8859-1"))

    // ISO-8859-2 Latin 2 Central Europe
    // http://www.unicode.org/Public/MAPPINGS/ISO8859/8859-2.TXT
    s = "ab\u0107\u00f7\u02D9"
    verifyISO_8859(s, Charset.fromStr("ISO-8859-2"))

    // ISO-8859-5 Latin/Cyrillic
    // http://www.unicode.org/Public/MAPPINGS/ISO8859/8859-5.TXT
    s = "ab\u0440\u2116\u045f"
    verifyISO_8859(s, Charset.fromStr("ISO-8859-5"))

    // .NET *may* have this same issue for ISO-8859-8:
    //   http://bugs.sun.com/bugdatabase/view_bug.do?bug_id=4758951

    // ISO-8859-8 Latin/Hebrew
    // http://www.unicode.org/Public/MAPPINGS/ISO8859/8859-8.TXT
    s = "ab\u05d0\u05e0\u200F"
    verifyISO_8859(s, Charset.fromStr("ISO-8859-8"))
  }

  Void verifyISO_8859(Str s, Charset charset)
  {
    f := tempDir + "char-${charset.name}.hex".toUri
    OutStream out := f.out
    out.charset = charset
    out.writeChars(s)
    out.close
    verifyEq(f.size, s.size); // ISO-8859 is one byte encoding

    InStream in := f.in
    in.charset = charset
    back := in.readAllStr
    in.close
    verifyEq(s, back)
  }

//////////////////////////////////////////////////////////////////////////
// Char - Mixed
//////////////////////////////////////////////////////////////////////////

  Void testChar()
  {
    f := tempDir + `char.hex`
    OutStream out := f.out
    writeChar(out)
    out.close

    InStream in := f.in
    readChar(this, in)
    in.close
  }

  const static Charset[] charsets := [ Charset.utf8, Charset.utf16BE, Charset.utf16LE ]
  const static Str[] strings := [ "a", "ab", "abc", "\u0080", "\u00FE", "\uabcd", "x\u00FE",
                      "x\uabcd", "\uabcd-\u00FE", ]

  static Void writeChar(OutStream out)
  {
    charsets.each |Charset charset|
    {
      out.charset = charset    // change charset mid-stream
      strings.each |Str str|
      {
        out.write('{')         // binary marker
        out.writeChars(str)    // charset encoding
        out.write('}')         // binary marker
      }
    }
    out.flush
  }

  static Void readChar(Test test, InStream in)
  {
    charsets.each |Charset charset|
    {
      in.charset = charset   // change charset mid-stream
      strings.each |Str str|
      {
        test.verifyEq(in.read, '{')            // binary marker
        for (Int j:=0; j<str.size; ++j)
          test.verifyEq(in.readChar(), str[j]) // charset encoding
        test.verifyEq(in.read, '}')            // binary marker
      }
    }
  }

//////////////////////////////////////////////////////////////////////////
// Unread
//////////////////////////////////////////////////////////////////////////

  Void testUnread()
  {
    f := tempDir + `unread.hex`
    OutStream out := f.out
    writeUnread(out)
    out.close

    InStream in := f.in
    readUnread(this, in)
    in.close
  }

  static Void writeUnread(OutStream out)
  {
    out.charset = Charset.utf8
    out.write(0)
    out.write(1)
    out.write(2)
    out.writeChar('a')
    out.writeChar('b')
    out.writeChar('c')
    out.charset = Charset.utf16BE
    out.writeChar('x')
    out.writeChar('y')
    out.writeChar('z')
    out.charset = Charset.utf16LE
    out.writeChar('!')
  }

  static Void readUnread(Test test, InStream in)
  {
    in.charset = Charset.utf8
    pushback(test, in);  test.verifyEq(in.read, 0)
    pushback(test, in);  test.verifyEq(in.read, 1)
    pushback(test, in);  test.verifyEq(in.read, 2)
    pushback(test, in);  test.verifyEq(in.readChar, 'a')
    pushback(test, in);  test.verifyEq(in.readChar, 'b')
    pushback(test, in);  test.verifyEq(in.readChar, 'c')
    in.charset = Charset.utf16BE
    pushback(test, in);  test.verifyEq(in.readChar, 'x')
    pushback(test, in);  test.verifyEq(in.readChar, 'y')
    pushback(test, in);  test.verifyEq(in.readChar, 'z')
    in.charset = Charset.utf16LE
    pushback(test, in);  test.verifyEq(in.readChar, '!')
  }

  static Void pushback(Test test, InStream in)
  {
    in.unread(7)
    in.unread(0xFF)
    test.verifyEq(in.read, 0xFF)
    test.verifyEq(in.read, 7)
    in.unreadChar('a')
    in.unreadChar('\u00df')
    in.unreadChar('\u00f7')
    in.unread(0)
    in.unread(0xFF)
    in.unreadChar('\u82ab')
    test.verifyEq(in.readChar, '\u82ab')
    test.verifyEq(in.read, 0xFF)
    test.verifyEq(in.read, 0)
    test.verifyEq(in.readChar, '\u00f7')
    test.verifyEq(in.readChar, '\u00df')
    test.verifyEq(in.readChar, 'a')
  }

//////////////////////////////////////////////////////////////////////////
// Read Chars
//////////////////////////////////////////////////////////////////////////

  Void testReadChars()
  {
    f := tempDir + `readChars`
    f.out.print("hello;_\u01ab_\u2c34;foo").close
    in := f.in
    verifyErr(ArgErr#) { in.readChars(-1) }
    verifyEq(in.readChars(0), "")
    verifyEq(in.readChars(6), "hello;")
    verifyEq(in.readChars(5), "_\u01ab_\u2c34;")
    verifyErr(IOErr#) { in.readChars(4) }
    in.close
  }

//////////////////////////////////////////////////////////////////////////
// Read Line
//////////////////////////////////////////////////////////////////////////

  Void testReadLine()
  {
    f := tempDir + `readLine.hex`
    f.create

    // verify empty file
    in := f.in
    verifyEq(in.readLine, null)
    in.close

    OutStream out := f.out
    writeLines(out)
    out.close

    in = f.in
    verifyReadLine(this, in)
    in.close

    out = f.out
    5000.times |Int i| { out.print("a") }
    out.printLine
    9876.times |Int i| { out.print("b") }
    out.close

    in = f.in
    verifyEq(in.readLine(20).size, 20)
    verifyEq(in.readLine.size, 5000 - 20)
    verifyEq(in.readLine.size, 9876)
    in.close
  }

  Void testReadStrToken()
  {
    f := tempDir + `readStrToken.hex`
    f.create

    // verify empty file
    in := f.in
    verifyEq(in.readStrToken, null)
    in.close

    OutStream out := f.out
    out.print("a bc def\nfoo:bar.wow")
    out.close

    in = f.in
    verifyEq(in.readStrToken, "a"); in.readChar
    verifyEq(in.readStrToken, "bc"); in.readChar
    verifyEq(in.readStrToken(2), "de");
    verifyEq(in.readStrToken, "f"); in.readChar
    verifyEq(in.readStrToken(-1) |Int c->Bool| { return c == ':' }, "foo"); in.readChar
    verifyEq(in.readStrToken(-1) |Int c->Bool| { return c == ':' }, "bar.wow");
    verifyEq(in.readStrToken(-1) |Int c->Bool| { return c == ':' }, null);

    in.close
  }

  Void testReadNullTerminatedStr()
  {
    f := tempDir + `readNullTerminatedStr.hex`
    f.create

    // verify empty file
    in := f.in
    verifyEq(in.readNullTerminatedStr, null)
    in.close

    OutStream out := f.out
    out.print("foo\u0000|bar\u0000longer one\u0000")
    out.close

    in = f.in
    verifyEq(in.readNullTerminatedStr, "foo")
    verifyEq(in.readChar, '|')
    verifyEq(in.readNullTerminatedStr, "bar")
    verifyEq(in.readNullTerminatedStr(4), "long");
    verifyEq(in.readNullTerminatedStr(0), "");
    verifyEq(in.readNullTerminatedStr(1), "e");
    verifyEq(in.readNullTerminatedStr(9), "r one");
    verifyEq(in.readNullTerminatedStr(4), null);

    in.close
  }

  Void testReadAllLines()
  {
    f := tempDir + `readAllLines.hex`
    f.create

    // verify empty file
    in := f.in
    verifyEq(in.readAllLines, Str[,])
    in.close

    writeLines(f.out).close

    in = f.in
    verifyReadAllLines(this, in)
  }

  Void testEachLine()
  {
    f := tempDir + `eachLine.hex`
    f.create

    writeLines(f.out).close

    verifyEachLine(this, f.in)
  }

  Void testReadAllStr()
  {
    f := tempDir + `readAllStr.hex`
    f.create

    // verify empty file
    in := f.in
    verifyEq(in.readAllStr, "")
    in.close

    writeLines(f.out).close

    in = f.in
    verifyReadAllStr0(this, in)
    in.close

    in = f.in
    verifyReadAllStr1(this, in)
    in.close
  }

  const static Str[] ReadLinesOut := [ "Line 1\n", "Line 2\n", "Line 3 \r",
    "  Line 4  \r\n", "Line 5\r", "\r", "\r\n", "\n", "Line 9" ]

  const static Str[] ReadLinesIn := [ "Line 1", "Line 2", "Line 3 ",
    "  Line 4  ", "Line 5", "", "", "", "Line 9" ]

  static OutStream writeLines(OutStream out)
  {
    out.charset = Charset.utf8
    ReadLinesOut.each |Str s| { out.writeChars(s) }
    return out
  }

  static Void verifyReadLine(Test test, InStream in)
  {
    in.charset = Charset.utf8
    ReadLinesIn.each |Str s| { test.verifyEq(in.readLine, s) }
    test.verifyEq(in.readLine, null)
    test.verifyEq(in.readLine, null)
  }

  static Void verifyEachLine(Test test, InStream in)
  {
    in.charset = Charset.utf8
    lines := Str[,]
    in.eachLine |Str line| { lines.add(line) }
    test.verifyEq(lines.size, ReadLinesIn.size)
    test.verifyEq(lines, ReadLinesIn)
  }

  static Void verifyReadAllLines(Test test, InStream in)
  {
    in.charset = Charset.utf8
    lines := in.readAllLines
    test.verify(lines is Str[])
    test.verifyEq(lines.size, ReadLinesIn.size)
    test.verifyEq(lines, ReadLinesIn)
  }

  static Void verifyReadAllStr0(Test test, InStream in)
  {
    in.charset = Charset.utf8
    str := in.readAllStr(false)
    test.verifyEq(str, ReadLinesOut.join)
  }

  static Void verifyReadAllStr1(Test test, InStream in)
  {
    in.charset = Charset.utf8
    str := in.readAllStr
    test.verifyEq(str, ReadLinesIn.join("\n"))
  }

//////////////////////////////////////////////////////////////////////////
// Props
//////////////////////////////////////////////////////////////////////////

  Void testProps()
  {
    str :=
      "// header\n" +
      "# not in there\n" +
      "# another comment\n" +
      "a=alpha\n"+
      " b = beta \r"+
      "c = charlie // who /* block ignored\r\n"+
      "\t  \r\n" +
      "d={\\n_\\r_\\t_\\\\_}\n"+
      "e.e=line 1 \\\r"+
      "    line 2\n"+
      "f/f=line 1 \\\n"+
      "  line 2 \\\r\n"+
      "      line 3\n"+
      ""+
      "g=\\\n"+
      " g\\u0001value\r\n"+
      "/*"+
      "# line comment\n" +
      "no=nope/*"+
      "no=\\uJKEK"+
      "*/ */"+
      "u=\u0123_\u70f0 /*foo // end-of-line ignored*/\n"+
      "esc=\\u0123_\\u70f0\n"+
      "eq1=a != b\n"+
      "eq2\\u003d=~!@#\$%^&*()_+\n"+
      "comment=\\u002f* \\u002f/!\n" +
      "# line comment\n" +
      "// skip\n" +
      "foo=http://foo/"

    expected :=
      ["a":"alpha",
       "b":"beta",
       "c":"charlie",
       "d":"{\n_\r_\t_\\_}",
       "e.e":"line 1 line 2",
       "f/f":"line 1 line 2 line 3",
       "g":"g\u0001value",
       "u":"\u0123_\u70f0",
       "esc":"\u0123_\u70f0",
       "eq1":"a != b",
       "eq2=":"~!@#\$%^&*()_+",
       "comment":"/* //!",
       "foo":"http://foo/",
      ]
/*TODO
    props := str.in.readProps
    verifyEq(props.isRW(), true)
    verifyEq(props, expected)

    // verify we always use UTF-8 (even if in stream is configured otherwise)
    buf := Buf.make
    buf.print(str)
    buf.flip
    buf.charset = Charset.utf16BE
    verifyEq(buf.in.readProps, expected)
    verifySame(buf.charset, Charset.utf16BE)

    // write props back to buf and verify read after round-trip
    buf.clear
    buf.out.writeProps(expected)
    buf.flip
    verifyEq(buf.in.readProps, expected)
    verifySame(buf.charset, Charset.utf16BE)

    verifyErr(ArgErr#) { "dupKey=1\ndupKey=2".in.readProps }
    verifyErr(IOErr#) { "a=\\u56G0\n".in.readProps }
    verifyErr(IOErr#) { "a=1\\x".in.readProps }
    verifyErr(IOErr#) { "novalue".in.readProps }
    verifyErr(IOErr#) { "novalue\na=b".in.readProps }
    */
  }
/*
  Void testTicket2436()
  {
    verify("#".in.readProps.isEmpty)
    verify("#\n".in.readProps.isEmpty)
    verify("#\r".in.readProps.isEmpty)
    verify("#\r\n".in.readProps.isEmpty)
    verify("#oops".in.readProps.isEmpty)
  }
*/

//////////////////////////////////////////////////////////////////////////
// Pipe
//////////////////////////////////////////////////////////////////////////

  Void testPipe()
  {
    f1 := tempDir + `src.txt`
    f2 := tempDir + `sink.txt`

    // write a small file
    OutStream out := f1.out
    out.printLine("This is my file!")
    out.close

    // copy it all via the pipe method
    in := f1.in
    out = f2.out
    n := in.pipe(out)
    in.close
    out.close
    verifyEq(f1.size, "This is my file!".size+1)
    verifyEq(f2.size, f1.size)
    verifyEq(n, f1.size)

    // copy just the beginning
    in = f1.in
    out = f2.out
    n = in.pipe(out, 4)
    in.close
    out.close
    verifyEq(f2.size, 4)
    verifyEq(n, 4)

    // verify can't copy more than is available
    in = f1.in
    out = f2.out
    verifyErr(IOErr#) { n = in.pipe(out, "This is my file!".size+2) }
    in.close
    out.close
    verifyEq(f1.size, f2.size)

    // verify a really big file pipe
    out = f1.out
    10000.times |Int i| { out.printLine("Floatly big file [Line " + (i+1) + "]") }
    out.close

    // pipe the big one!
    in = f1.in
    out = f2.out
    n = in.pipe(out)
    in.close
    out.close
    verifyEq(f2.size, f1.size)
    verifyEq(n, f1.size)
  }

//////////////////////////////////////////////////////////////////////////
// Make For Str
//////////////////////////////////////////////////////////////////////////

  Void testMakeForStr()
  {
    buf := Buf.make

    in := "a_\u007f_\u00ff_\uabcd!xyz".in
    verifyEq(in.readChar, 'a')
    verifyEq(in.readChar, '_')
    in.unreadChar('z')
    in.unreadChar('y')
    in.unreadChar('x')
    verifyEq(in.readChar, 'x')
    verifyEq(in.readChar, 'y')
    verifyEq(in.readChar, 'z')
    verifyEq(in.readChar, 0x007f)
    verifyEq(in.readChar, '_')
    verifyEq(in.readChar, '\u00ff')
    verifyEq(in.readChar, '_')
    verifyEq(in.readChar, 0xabcd)
    verifyEq(in.readChar, '!')
    verifyErr(UnsupportedErr#) { in.read }
    verifyEq(in.readChar, 'x')
    verifyErr(UnsupportedErr#) { in.readBuf(buf, 2) }
    verifyErr(UnsupportedErr#) { in.unread(32) }
    verifyEq(in.readChars(2), "yz")
    in.unreadChar('@')
    verifyEq(in.readChar, '@')
    verifyEq(in.readChar, -1)
    verifyEq(in.close(), true)
  }

//////////////////////////////////////////////////////////////////////////
// Make For StrBuf
//////////////////////////////////////////////////////////////////////////

  Void testMakeForStrBuf()
  {
    buf := StrBuf.make
    out := buf.out
    verifyErr(UnsupportedErr#) { out.write(6) }
    verifyErr(UnsupportedErr#) { out.writeBuf(Buf.make) }
    verifyErr(UnsupportedErr#) { out.writeI4(7) }
    out.writeChar('a')
    out.flush()
    out.writeChars("bc")
    out.writeChars("hello", 3)
    out.writeChars("xyz!", 1, 2)
    out.print("|").print(null).printLine.printLine(2).printLine(null)
    verifyEq(out.close(), true)
    verifyEq(buf.toStr, "abcloyz|null\n2\nnull\n")
  }

//////////////////////////////////////////////////////////////////////////
// Xml
//////////////////////////////////////////////////////////////////////////
/*
  Void testXml()
  {
    nl := OutStream.xmlEscNewlines
    q  := OutStream.xmlEscQuotes
    u  := OutStream.xmlEscUnicode

    verifyXml("", "", 0)
    verifyXml("a", "a", 0)
    verifyXml(" a\t", " a\t", 0)

    // lt and amp
    verifyXml("<", "&lt;", 0)
    verifyXml("+&-", "+&amp;-", 0)

    // gt only escaped when possible CDATA
    verifyXml(">", "&gt;", 0)
    verifyXml(" >", " >", 0)
    verifyXml("]>", "]&gt;", 0)
    verifyXml("&", "&amp;", 0)
    verifyXml("-\u0000-", "-&#x00;-", 0)

    // optional quotes
    verifyXml("a='aval' b=\"bval\"", "a='aval' b=\"bval\"", 0)
    verifyXml("a='aval' b=\"bval\"", "a=&#39;aval&#39; b=&quot;bval&quot;", q)

    // optional newlines
    verifyXml("x\n y\r z", "x\n y\r z", 0)
    verifyXml("x\n y\r z", "x&#x0a; y&#x0d; z", nl)

    // optional unicode
    verifyXml("\u00ff \u0abc \u147d", "\u00ff \u0abc \u147d", 0)
    verifyXml("\u00ff \u0abc \u147d", "&#xff; &#x0abc; &#x147d;", u)
  }

  Void verifyXml(Str s, Str expected, Int flags)
  {
    actual := Buf().writeXml(s, flags).flip.readAllStr(false)
    verifyEq(actual, expected)
  }
*/
}