//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2 Apr 06  Brian Frank  Creation
//

**
** AbstractBufTest
**
@Js
abstract class AbstractBufTest : Test
{
//////////////////////////////////////////////////////////////////////////
// Setup
//////////////////////////////////////////////////////////////////////////

  Buf makeMem()
  {
    b := Buf.make;
    bufs.add(b);
    return b
  }

  Buf makeFile()
  {
    // js doesn't support files
    if ("js" == Env.cur.runtime) return makeMem

    name := "buf" + bufs.size
    file := tempDir + name.toUri
    b := file.open("rw")
    bufs.add(b)
    return b
  }

  Buf[] bufs := Buf[,]

  override Void teardown()
  {
    bufs.each |Buf b| { verify(b.close) }
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  Buf ascii(Str ascii)
  {
    return Buf.make.print(ascii)
  }

  Void verifyBufEq(Buf a, Buf b)
  {
    verify(eq(a, b))
  }

  Void verifyBufNotEq(Buf a, Buf b)
  {
    verify(!eq(a, b))
  }

  Bool eq(Buf a, Buf b)
  {
    if (a.size != b.size) return false
    for (i := 0; i<a.size; ++i)
      if (a[i] != b[i]) return false
    return true
  }

  Void verifyBufEqStr(Buf buf, Str ascii)
  {
    verifyEq(buf.size, ascii.size)
    for (i := 0; i<buf.size; ++i)
      verifyEq(buf[i], ascii[i])
  }
}

**
** BufTest
**
@Js
class BufTest : AbstractBufTest
{

//////////////////////////////////////////////////////////////////////////
// Equality
//////////////////////////////////////////////////////////////////////////

  Void testEquality()
  {
    verifyEquality(makeMem,  makeMem)
    verifyEquality(makeMem,  makeFile)
    verifyEquality(makeFile, makeMem)
    verifyEquality(makeFile, makeFile)
  }

  Void verifyEquality(Buf a, Buf b)
  {
    verifyBufEq(a, b)

    a.write(0); b.write(0)
    verifyBufEq(a, b)

    a.write(0xff); b.write(0xff)
    verifyBufEq(a, b)

    a.flip
    verifyBufEq(a, b)

    a.write(0xab); b.write(0xab)
    verifyBufNotEq(a, b)
  }

//////////////////////////////////////////////////////////////////////////
// Basic IO
//////////////////////////////////////////////////////////////////////////

  Void testBasicIO()
  {
    verifyBasicIO(makeMem)
    verifyBasicIO(makeFile)
  }

  Void verifyBasicIO(Buf buf)
  {
    verifyEq(buf.pos,  0)
    verifyEq(buf.size, 0)
    verify(buf.isEmpty)
    verifyEq(buf.in.avail, 0)

    // write size=1
    buf.write('a')
    verifyEq(buf.pos,  1)
    verifyEq(buf.size, 1)
    verifyEq(buf[0], 'a')
    verifyFalse(buf.isEmpty)

    // write size=2
    buf.write('b')
    verifyEq(buf.pos,  2)
    verifyEq(buf.size, 2)
    verifyEq(buf[0], 'a')
    verifyEq(buf[1], 'b')

    // write size=3
    buf.write('c')
    verifyEq(buf.pos,  3)
    verifyEq(buf.size, 3)
    verifyEq(buf[0], 'a')
    verifyEq(buf[1], 'b')
    verifyEq(buf[2], 'c')
    verifyEq(buf.in.avail, 0)

    // rewrite pos 1
    buf.seek(1).write('x')
    verifyEq(buf.pos,  2)
    verifyEq(buf.size, 3)
    verifyEq(buf[0], 'a')
    verifyEq(buf[1], 'x')
    verifyEq(buf[2], 'c')
    buf.seek(1).write('b')

    // seek pos=0
    buf.seek(0)
    verifyEq(buf.pos,  0)
    verifyEq(buf.size, 3)
    verifyEq(buf.remaining, 3)
    verifyEq(buf.in.avail, 3)

    // read pos=1
    verifyEq(buf.read, 'a')
    verifyEq(buf.pos,  1)
    verifyEq(buf.size, 3)
    verifyEq(buf.remaining, 2)
    verifyEq(buf.in.avail, 2)

    // read pos=2
    verifyEq(buf.peek, 'b')
    verifyEq(buf.read, 'b')
    verifyEq(buf.pos,  2)
    verifyEq(buf.size, 3)
    verifyEq(buf.remaining, 1)
    verifyEq(buf.in.avail, 1)

    // read pos=3
    verifyEq(buf.read, 'c')
    verifyEq(buf.pos,  3)
    verifyEq(buf.size, 3)
    verifyEq(buf.remaining, 0)
    verifyEq(buf.in.avail, 0)

    // read pos=end
    verifyEq(buf.read, null)
    verifyEq(buf.read, null)
    verifyEq(buf.peek, null)
    verifyEq(buf.pos,  3)
    verifyEq(buf.size, 3)
    verifyEq(buf.remaining, 0)
    verifyEq(buf.in.avail, 0)

    // gets
    verifyEq(buf[0],  'a')
    verifyEq(buf[1],  'b')
    verifyEq(buf[2],  'c')
    verifyEq(buf[-1], 'c')
    verifyEq(buf[-2], 'b')
    verifyEq(buf[-3], 'a')

    // seek
    verifyEq(buf.seek(0).read,  'a')
    verifyEq(buf.seek(1).read,  'b')
    verifyEq(buf.seek(2).read,  'c')
    verifyEq(buf.seek(-1).read, 'c')
    verifyEq(buf.seek(-2).read, 'b')
    verifyEq(buf.seek(-3).read, 'a')

    // get errors
    verifyErr(IndexErr#) |->Int| { return Buf.make[0] }
    verifyErr(IndexErr#) |->Int| { return buf[3] }
    verifyErr(IndexErr#) |->Int| { return buf[-4] }
    verifyErr(IndexErr#) { buf.seek(-4) }

    // sets
    buf[0] = 'A';
    buf[1] = 'B';
    buf[2] = 'C';
    verifyEq(buf[0], 'A')
    verifyEq(buf[1], 'B')
    verifyEq(buf[2], 'C')
    buf[-1] = 0xff;
    buf[-2] = 0xdd;
    buf[-3] = 0xcc;
    verifyEq(buf[0], 0xcc)
    verifyEq(buf[1], 0xdd)
    verifyEq(buf[2], 0xff)

    // set errors
    verifyErr(IndexErr#) { Buf.make[0] = 99 }
    verifyErr(IndexErr#) { buf[3] = 99 }
    verifyErr(IndexErr#) { buf[-4] = 99 }

    // clear
    buf.clear
    verifyEq(buf.pos,  0)
    verifyEq(buf.size, 0)
    verifyEq(buf.read, null)
  }

//////////////////////////////////////////////////////////////////////////
// Size and Capacity
//////////////////////////////////////////////////////////////////////////

  Void testSizeCapacity()
  {
    verifyEq(Buf.make.capacity, 1024)

    b := Buf.make(2)
    verifyEq(b.capacity, 2)
    verifyEq(b.size, 0)

    b.write('a').write('b')
    verifyEq(b.capacity, 2)
    verifyEq(b.size, 2)

    b.write('c')
    verifyEq(b.capacity, 4)
    verifyEq(b.size, 3)

    b.write('d').write('e')
    verifyEq(b.capacity, 8)
    verifyEq(b.size, 5)

    b.capacity = 6
    verifyEq(b.capacity, 6)
    verifyEq(b.size, 5)

    b.write('f')
    verifyEq(b.capacity, 6)
    verifyEq(b.size, 6)

    b.write('g')
    verifyEq(b.capacity, 12)
    verifyEq(b.size, 7)

    b.capacity = 7
    verifyEq(b.capacity, 7)
    verifyEq(b.size, 7)

    verifyErr(ArgErr#) { b.capacity = 6 }
    verifyErr(ArgErr#) { b.capacity = -9 }

    b.size = 8
    verifyEq(b.capacity, 8)
    verifyEq(b.size, 8)
    verifyEq(b[0], 'a')
    verifyEq(b[6], 'g')
    verifyEq(b[7], 0)

    b.size = 4
    verifyEq(b.capacity, 8)
    verifyEq(b.size, 4)
    verifyEq(b[0], 'a')
    verifyEq(b[3], 'd')
    verifyErr(IndexErr#) |->Int| { return b[4] }
    verifyErr(IndexErr#) |->Int| { return b[7] }

    b.size = 7
    verifyEq(b.capacity, 8)
    verifyEq(b.size, 7)
    verifyEq(b[0], 'a')
    verifyEq(b[6], 'g')
    verifyErr(IndexErr#) |->Int| { return b[7] }

    if (Env.cur.runtime != "js")
    {
      f := makeFile
      verifyEq(f.capacity, Int.maxVal)
      f.capacity = 10
      verifyEq(f.capacity, Int.maxVal)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Slice
//////////////////////////////////////////////////////////////////////////

  Void testSlice()
  {
    verifySlice(makeMem)
    verifySlice(makeFile)
  }

  Void verifySlice(Buf buf)
  {
     buf.charset = Charset.utf16BE
     buf.write(0xaa).write(0xbb).write(0xcc).write(0xdd)
     verifyEq(buf[0..0].toHex, "aa")
     verifyEq(buf[0..1].toHex, "aabb")
     verifyEq(buf[1..2].toHex, "bbcc")
     verifyEq(buf[0..2].toHex, "aabbcc")
     verifyEq(buf[3..3].toHex, "dd")
     verifyEq(buf[0..-1].toHex, "aabbccdd")
     verifyEq(buf[-3..-2].toHex, "bbcc")
     verifyEq(buf[1..<2].toHex, "bb")
     verifyEq(buf[1..<3].toHex, "bbcc")
     verifyEq(buf[-2..-1].toHex, "ccdd")
     verifyEq(buf[0..<2].toHex, "aabb")
     verifyEq(buf[1..-2].toHex, "bbcc")
     verifyEq(buf[4..-1].toHex, "")

     verifyEq(buf[1..-2].size, 2)
     verifyEq(buf[1..-2].charset, Charset.utf16BE)

     verifyErr(IndexErr#) |->Buf| { return buf[0..4] }
     verifyErr(IndexErr#) |->Buf| { return buf[3..4] }
     verifyErr(IndexErr#) |->Buf| { return buf[0..<5] }
     verifyErr(IndexErr#) |->Buf| { return buf[3..1] }
     verifyErr(IndexErr#) |->Buf| { return buf[3..<2] }
  }

//////////////////////////////////////////////////////////////////////////
// Fill
//////////////////////////////////////////////////////////////////////////

  Void testFill()
  {
    buf := Buf().fill(0xab, 4)
    verifyEq(buf.toHex, "abababab")
    buf.fill(0x0f, 2)
    verifyEq(buf.toHex, "abababab0f0f")
    buf.seek(2).fill(0xff, 3)
    verifyEq(buf.toHex, "ababffffff0f")
  }

//////////////////////////////////////////////////////////////////////////
// Dup
//////////////////////////////////////////////////////////////////////////

  Void testDup()
  {
    verifyDup(makeMem)
    verifyDup(makeFile)
  }

  Void verifyDup(Buf buf)
  {
    buf.write(0xaa).write(0xbb).write(0xcc).write(0xdd)

    dup := buf.dup
    verifyEq(dup.pos, 0)
    verifyEq(dup.size, buf.size)

    verifyNotSame(buf, dup)
    verifyEq(buf.toHex, dup.toHex)

    dup[0] = 0; dup[3] = 99
    verifyEq(dup[0], 0)
    verifyEq(dup[1], 0xbb)
    verifyEq(dup[2], 0xcc)
    verifyEq(dup[3], 99)

    verifyEq(buf[0], 0xaa)
    verifyEq(buf[1], 0xbb)
    verifyEq(buf[2], 0xcc)
    verifyEq(buf[3], 0xdd)
  }

//////////////////////////////////////////////////////////////////////////
// Dummies
//////////////////////////////////////////////////////////////////////////

  Void testBufDummies()
  {
    b := Buf.make
    b.out.flush
    verifyEq(b.close, true)
    verifyEq(b.out.close, true)
    b.in.close

    b.print("hello")
    verifyEq(b.flip.readAllStr, "hello")
  }

//////////////////////////////////////////////////////////////////////////
// Write
//////////////////////////////////////////////////////////////////////////

  Void testWriteBuf()
  {
    verifyWriteBuf(makeMem,  makeMem)
    verifyWriteBuf(makeMem,  makeFile)
    verifyWriteBuf(makeFile, makeMem)
    verifyWriteBuf(makeFile, makeFile)
  }

  Void verifyWriteBuf(Buf a, Buf b)
  {
    a.write('a').write('b').write('c')
    verifyEq(a.pos, 3)
    verifyBufEqStr(a, "abc")

    // write entire buf
    a.flip
    b.writeBuf(a)
    verifyEq(a.pos,  3)
    verifyEq(a.size, 3)
    verifyEq(a.remaining, 0)
    verifyEq(b.pos,  3)
    verifyEq(b.size, 3)
    verifyEq(b.remaining, 0)
    verifyBufEqStr(b, "abc")

    // write one byte at a time
    a.flip
    3.times |Int i|
    {
      b.writeBuf(a, 1)
      verifyEq(a.pos,  i+1)
      verifyEq(a.size, 3)
      verifyEq(a.remaining, 3-i-1)
      verifyEq(b.pos,  4+i)
      verifyEq(b.size, 4+i)
      verifyEq(b.remaining, 0)
    }
    verifyBufEqStr(b, "abcabc")

    a.flip
    verifyEq(b.size, 6)
    b.seek(1).writeBuf(a).write('|')
    verifyBufEqStr(b, "aabc|c")
    verifyEq(b.pos, 5)
    verifyEq(b.size, 6)

    b.seek(b.size).write('x')
    verifyBufEqStr(b, "aabc|cx")
  }

//////////////////////////////////////////////////////////////////////////
// Read
//////////////////////////////////////////////////////////////////////////

  Void testReadBuf()
  {
    verifyReadBuf(makeMem,  makeMem)
    verifyReadBuf(makeMem,  makeFile)
    verifyReadBuf(makeFile, makeMem)
    verifyReadBuf(makeFile, makeFile)
  }

  Void verifyReadBuf(Buf a, Buf b)
  {
    a.write('a').write('b').write('c')
    verifyEq(a.pos,  3)
    verifyBufEqStr(a, "abc")

    // read the entirity exactly
    a.seek(0)
    verifyEq(a.readBuf(b, 3), 3)
    verifyEq(a.pos,  3)
    verifyEq(a.remaining, 0)
    verifyEq(b.pos,  3)
    verifyBufEqStr(b, "abc")
    verifyEq(b.readBuf(b, 1), null)

    // reset and read the more than entirity
    a.seek(0)
    b.clear
    verifyEq(a.readBuf(b, 100), 3)
    verifyEq(a.pos,  3)
    verifyEq(a.remaining, 0)
    verifyEq(b.pos,  3)
    verifyBufEqStr(b, "abc")
    verifyEq(b.readBuf(b, 1), null)

    // reset and read 1 byte at a time
    a.seek(0)
    b.clear
    verifyEq(a.readBuf(b, 1), 1)
    verifyEq(a.pos,  1)
    verifyEq(a.remaining, 2)
    verifyEq(b.pos,  1)
    verifyBufEqStr(b, "a")
    verifyEq(a.readBuf(b, 1), 1)
    verifyEq(a.pos,  2)
    verifyEq(a.remaining, 1)
    verifyEq(b.pos,  2)
    verifyBufEqStr(b, "ab")
    verifyEq(a.readBuf(b, 1), 1)
    verifyEq(a.pos,  3)
    verifyEq(a.remaining, 0)
    verifyEq(b.pos,  3)
    verifyBufEqStr(b, "abc")
    verifyEq(a.readBuf(b, 1), null)
    verifyBufEqStr(b, "abc")

    // reset and read 2 bytes at a time
    a.seek(0)
    b.clear
    verifyEq(a.readBuf(b, 2), 2)
    verifyEq(a.pos,  2)
    verifyEq(a.remaining, 1)
    verifyEq(b.pos,  2)
    verifyBufEqStr(b, "ab")
    verifyEq(a.readBuf(b, 2), 1)
    verifyEq(a.pos,  3)
    verifyEq(a.remaining, 0)
    verifyEq(b.pos,  3)
    verifyBufEqStr(b, "abc")
  }

//////////////////////////////////////////////////////////////////////////
// Binary IO
//////////////////////////////////////////////////////////////////////////

  Void testBinary()
  {
    verifyBinary(Buf.make(0))
    verifyBinary(makeFile)
  }

  Void verifyBinary(Buf buf)
  {
    // reuse StreamTests
    StreamTest.writeBinary(buf.out)

    buf.flip()
    StreamTest.readBinary(this, buf.in)

    // sanity check sizes
    buf.charset = Charset.utf8
    buf.clear; buf.writeChar('a'); verifyEq(buf.size, 1)
    buf.clear; buf.writeChar('\u00fe'); verifyEq(buf.size, 2)
    buf.clear; buf.writeChar('\uabcd'); verifyEq(buf.size, 3)

    buf.charset = Charset.utf16BE
    buf.clear; buf.writeChar('a'); verifyEq(buf.size, 2)
    buf.clear; buf.writeChar('\u00fe'); verifyEq(buf.size, 2)
    buf.clear; buf.writeChar('\uabcd'); verifyEq(buf.size, 2)
  }

//////////////////////////////////////////////////////////////////////////
// IO Conveniences
//////////////////////////////////////////////////////////////////////////

  Void testConveniences()
  {
    verifyConveniences(makeMem,  makeMem)
    verifyConveniences(makeMem,  makeFile)
    verifyConveniences(makeFile, makeMem)
    verifyConveniences(makeFile, makeFile)
  }

  Void verifyConveniences(Buf buf, Buf temp)
  {
    js := Env.cur.runtime == "js"

    // convenience writes
    temp.print("fool")
    buf.clear
    temp.seek(0); buf.writeBuf(temp)
    temp.seek(0); buf.writeBuf(temp, 3)
    buf.writeI2(0xa00a)
    buf.writeI4(-1234)
    buf.writeI4(0xabcd0123)
    if (!js) buf.writeI8(0xabcd0123ffffeeee)
    buf.writeF4(2f)
    if (!js) buf.writeF8(77.0f)
    if (!js) buf.writeDecimal(50.03D)
    buf.writeBool(true)
    buf.print("harry").printLine(" potter")
    buf.writeUtf("deathly hallows")
    buf.writeChar('x')
    buf.writeChars("riddle\n", 1)

    // convenience writes
    buf.flip
    temp.clear; buf.readBuf(temp, 4); verifyEq(temp.flip.readAllStr, "fool")
    temp.clear; buf.readBuf(temp, 3); verifyEq(temp.flip.readAllStr, "foo")
    verifyEq(buf.readU2, 0xa00a)
    verifyEq(buf.readS4, -1234)
    verifyEq(buf.readU4, 0xabcd0123)
    if (!js) verifyEq(buf.readS8, 0xabcd0123ffffeeee)
    verifyEq(buf.readF4, 2f)
    if (!js) verifyEq(buf.readF8, 77f)
    if (!js) verifyEq(buf.readDecimal, 50.03d)
    verifyEq(buf.readBool, true)
    verifyEq(buf.readLine, "harry potter")
    verifyEq(buf.readUtf, "deathly hallows")
    verifyEq(buf.readChar, 'x')
    buf.unreadChar('y')
    verifyEq(buf.readChar, 'y')
    verifyEq(buf.readLine, "iddle")

    // string conveniences
    buf.clear
    buf.printLine("one").printLine("two")
    buf.seek(0)
    verifyEq(buf.readAllLines, ["one", "two"])
    buf.seek(0)
    verifyEq(buf.readAllStr, "one\ntwo\n")
    buf.seek(0)
    verifyEq(buf.readStrToken, "one")
    buf.seek(0)
    acc := Str[,]; buf.eachLine |Str s| { acc.add(s) }
    verifyEq(acc, ["one", "two"])

    // props
    buf.clear.writeProps(["a":"Apple", "b":"Bear"])
    verifyEq(buf.flip.readProps, ["a":"Apple", "b":"Bear"])

    // obj
    buf.clear.writeObj(3)
    verifyEq(buf.flip.readObj, 3)
    buf.clear.writeObj(3, ["dummy":true])
    verifyEq(buf.flip.readObj(["dummy":true]), 3)

  }

//////////////////////////////////////////////////////////////////////////
// Endian
//////////////////////////////////////////////////////////////////////////

  Void testEndian()
  {
    buf := Buf()
    verifySame(buf.endian, Endian.big)
    buf.endian = Endian.little
    verifySame(buf.endian, Endian.little)
    buf.writeI2(0xaabb).writeI4(0xaabbccdd).writeI2(0xccdd).writeI4(0x11223344).flip
    buf.endian = Endian.big
    verifyEq(buf.readU2, 0xbbaa)
    verifyEq(buf.readU4, 0xddccbbaa)
    buf.endian = Endian.little
    verifyEq(buf.readU2, 0xccdd)
    verifyEq(buf.readU4, 0x11223344)
  }

//////////////////////////////////////////////////////////////////////////
// Char IO
//////////////////////////////////////////////////////////////////////////

  Void testChar()
  {
    verifyChar(makeMem)
    verifyChar(makeFile)
  }

  Void verifyChar(Buf buf)
  {
    buf.clear
    StreamTest.writeChar(buf.out)

    buf.flip
    StreamTest.readChar(this, buf.in)
  }

//////////////////////////////////////////////////////////////////////////
// Unread
//////////////////////////////////////////////////////////////////////////

  Void testUnread()
  {
    // memory backed
    buf := makeMem
    buf.write(0xaa).write(0xbb)
    buf.flip
    buf.unread(0x11)
    buf.unread(0x22)
    verifyEq(buf.read, 0x22)
    verifyEq(buf.read, 0x11)
    verifyEq(buf.read, 0xaa)
    buf.unread(0xaa)
    verifyEq(buf.read, 0xaa)
    verifyEq(buf.peek, 0xbb)
    verifyEq(buf.read, 0xbb)
    verifyEq(buf.read, null)
    verifyEq(buf.peek, null)

    buf.clear
    StreamTest.writeUnread(buf.out)

    buf.flip
    StreamTest.readUnread(this, buf.in)

    // file backed
    buf = makeFile
    buf.write('a')
    buf.write('b')
    buf.write('c')
    buf.flip
    verifyEq(buf.read,   'a')
    verifyEq(buf.peek,   'b')
    buf.unread('x')
    verifyEq(buf.peek,   'x')
    verifyEq(buf.read,   'x')
    verifyEq(buf.peek,   'b')
    verifyEq(buf.read,   'b')
  }

//////////////////////////////////////////////////////////////////////////
// Read Chars
//////////////////////////////////////////////////////////////////////////

  Void testReadChars()
  {
    buf := Buf().print("hello;_\u01ab_\u2c34;foo").flip
    verifyErr(ArgErr#) { buf.readChars(-1) }
    verifyEq(buf.readChars(0), "")
    verifyEq(buf.readChars(6), "hello;")
    verifyEq(buf.readChars(5), "_\u01ab_\u2c34;")
    verifyErr(IOErr#) { buf.readChars(4) }
  }

//////////////////////////////////////////////////////////////////////////
// Read Lines
//////////////////////////////////////////////////////////////////////////

  Void testReadLine()
  {
    verifyReadLine(makeMem)
    verifyReadLine(makeFile)
  }

  Void verifyReadLine(Buf buf)
  {
    StreamTest.writeLines(buf.out)
    buf.flip
    StreamTest.verifyReadLine(this, buf.in)
  }

  Void testReadAllLines()
  {
    verifyReadAllLines(makeMem)
    verifyReadAllLines(makeFile)
  }

  Void verifyReadAllLines(Buf buf)
  {
    StreamTest.writeLines(buf.out)
    buf.flip
    StreamTest.verifyReadAllLines(this, buf.in)
  }

  Void testEachLine()
  {
    verifyEachLine(makeMem)
    verifyEachLine(makeFile)
  }

  Void verifyEachLine(Buf buf)
  {
    StreamTest.writeLines(buf.out)
    buf.flip
    StreamTest.verifyEachLine(this, buf.in)
  }

  Void testReadAllStr()
  {
    verifyReadAllStr(makeMem)
    verifyReadAllStr(makeFile)
  }

  Void verifyReadAllStr(Buf buf)
  {
    StreamTest.writeLines(buf.out)

    buf.flip
    StreamTest.verifyReadAllStr0(this, buf.in)

    buf.seek(0)
    StreamTest.verifyReadAllStr1(this, buf.in)
  }

//////////////////////////////////////////////////////////////////////////
// Pipe
//////////////////////////////////////////////////////////////////////////

  Void testPipe()
  {
    // test for js env
    src := makeMem
    dst := makeMem
    1800.times |Int i| { src.write(i) }
    src.flip
    src.in.pipe(dst.out, null, false)
    verifyEq(dst.size, 1800)
    1800.times |Int i| { verifyEq(dst[i], i.and(0xff)) }

    if (Env.cur.runtime != "js")
    {
      verifyPipe(makeMem,  makeMem)
      verifyPipe(makeMem,  makeFile)
      verifyPipe(makeFile, makeMem)
      verifyPipe(makeFile, makeFile)
    }
  }

  Void verifyPipe(Buf src, Buf dst)
  {
    2300.times |Int i| { src.write(i) }

    src.flip
    src.in.pipe(dst.out, null, false)
    verifyEq(dst.size, 2300)
    2300.times |Int i| { verifyEq(dst[i], i.and(0xff)) }

    src.seek(0)
    f := tempDir + `pipeit`
    f.out.writeBuf(src).close
    src.write('!')
    verifyEq(src[2300], '!')
    verifyEq(f.size, 2300)

    x := f.open("rw")
    dst.clear
    x.in.readBuf(dst, 2003)
    verifyEq(dst.size, 2003)
    2003.times |Int i| { verifyEq(dst[i], i.and(0xff)) }
    src.seek(0)
    x.clear
    x.out.writeBuf(src)
    x.close
    verifyEq(f.size, 2301)

    dst.clear
    in := f.in
    in.readBuf(dst, 2001)
    in.close
    verifyEq(dst.size, 2001)
    2001.times |Int i| { verifyEq(dst[i], i.and(0xff)) }

    src.seek(0)
    dst.clear
    src.in.pipe(dst.out, 5)
    verifyEq(dst.size, 5)
    5.times |Int i| { verifyEq(dst[i], i) }
  }

//////////////////////////////////////////////////////////////////////////
// Hex
//////////////////////////////////////////////////////////////////////////

  Void testHex()
  {
    verifyHexStr("", "");
    verifyHexStr("+", "2b");
    verifyHexStr("Fan", "46616e");
    verifyHexStr("\r\n", "0d0a");

    verifyErr(IOErr#) { Buf.fromHex("3x") }
    verifyErr(IOErr#) { Buf.fromHex("a") }
  }

  Void verifyHexStr(Str src, Str hex)
  {
    verifyEq(makeMem.print(src).toHex, hex)
    verifyEq(makeFile.print(src).toHex, hex)

    verifyBufEq(Buf.fromHex(hex), makeMem.print(src))

    breaks := StrBuf.make
    hex.each |Int ch, Int i| { breaks.addChar(ch); if (i % 2 == 1) breaks.add("\uabcd\r\n") }
    verifyBufEq(Buf.fromHex(breaks.toStr), ascii(src))
  }

//////////////////////////////////////////////////////////////////////////
// Random
//////////////////////////////////////////////////////////////////////////

  Void testRandom()
  {
    24.times |Int i| { verifyEq(Buf.random(i).size, i) }
  }

//////////////////////////////////////////////////////////////////////////
// CRC
//////////////////////////////////////////////////////////////////////////

  Void testCRC()
  {
    buf := Buf.fromHex("F70302640008")
    verifyEq(buf.crc("CRC-16"), 0xFD10)
    verifyEq(buf.crc("CRC-32"), 0x15f9_d197)
    verifyEq(buf.crc("CRC-32-Adler"), 0x071b_0169)
  }

//////////////////////////////////////////////////////////////////////////
// ToFile
//////////////////////////////////////////////////////////////////////////

  Void testToFile()
  {
    if (Env.cur.runtime == "js") return

    mut := Buf().print("test!")
    f := mut.toFile(`test/path/file.txt`)
    verifyToFile(f)

    mut.print("more data!")
    verifyToFile(f)

    f = Buf().print("test!").toImmutable.toFile(`test/path/file.txt`)
    verifyToFile(f)
  }

  Void verifyToFile(File f)
  {
    verifyEq(f.readAllStr, "test!")
    verifyEq(f.typeof.qname, "sys::MemFile")
    verifyEq(f.in.readAllStr, "test!")
    verifyEq(f.size, 5)
    verifyEq(f.modified.date, Date.today)
    verifyEq(f.uri, `test/path/file.txt`)
    verifyEq(f.name, "file.txt")
    verifyEq(f.ext, "txt")
    verifyErr(UnsupportedErr#) { f.modified = DateTime.now }
    verifyErr(UnsupportedErr#) { f.out }
    verifyErr(UnsupportedErr#) { f.open("r") }
  }

//////////////////////////////////////////////////////////////////////////
// Immutable
//////////////////////////////////////////////////////////////////////////

  Void testImmutable()
  {
    js := Env.cur.runtime == "js"

    orig := "ABCD".toBuf
    buf := orig.toImmutable
    e := ReadonlyErr#

    verifyEq(buf.isImmutable, true)
    verifySame(buf.toImmutable, buf)
    verifyEq(buf.typeof.qname, "sys::ConstBuf")
    verifyEq(buf.size, 4)
    verifyEq(buf.size, 4)
    verifyEq(buf.isEmpty, false)
    verifyEq(buf.pos, 0)
    verifyEq(buf.remaining, 4)
    verifyEq(buf.more, true)
    verifyEq(buf[0], 'A')
    verifyEq(buf[-1], 'D')
    verifyEq(buf[1..2].readAllStr, "BC")
    verifyEq(buf.in.readAllStr, "ABCD")
    verifyEq(buf.close, true)

    verifyEq(buf.toHex, "41424344")
    verifyEq(buf.toBase64, "QUJDRA==")
    verifyEq(buf.toBase64Uri, "QUJDRA")
    verifyEq(buf.crc("CRC-16"), 3973)
    verifyEq(buf.hmac("SHA1", "key".toBuf).toHex, "465da90ea0ce68e62e9b17cd9bdc7c81e6eb128b")
    verifyEq(buf.toDigest("SHA-1").toHex, "fb2f85c88567f3c8ce9b799c7c54642d0c7b41f6")

    verifyEq(orig.size, 0)
    verifyEq(orig.capacity, 0)
    orig.print("1234567")
    verifyEq(orig.flip.readAllStr, "1234567")
    verifyEq(buf.in.readAllStr, "ABCD")

    in := buf.in
    verifyEq(in.read, 'A')
    verifyEq(in.read, 'B')
    in.unread('B')
    verifyEq(in.read, 'B')
    verifyEq(in.read, 'C')
    verifyErr(e) { in.unread('%') }
    verifyEq(in.read, 'D')
    verifyEq(in.read, null)

    newBuf := Buf()
    newBuf.out.writeBuf(buf)
    verifyEq(newBuf.flip.readAllStr, "ABCD")

    verifyErr(e) { x := buf.capacity }
    verifyErr(e) { buf.capacity = 6 }
    verifyErr(e) { buf.charset = Charset.utf16BE }
    verifyErr(e) { buf.clear }
    verifyErr(e) { buf.eachLine |line| {} }
    verifyErr(e) { buf.endian = Endian.big }
    verifyErr(e) { buf.fill(0xff, 100) }
    verifyErr(e) { buf.flip }
    verifyErr(e) { buf.out.printLine("x") }
    verifyErr(e) { buf.peek }
    verifyErr(e) { buf.print("x") }
    verifyErr(e) { buf.printLine("x") }
    verifyErr(e) { buf.read }
    verifyErr(e) { buf.readAllBuf }
    verifyErr(e) { buf.readAllLines }
    verifyErr(e) { buf.readAllStr }
    verifyErr(e) { buf.readBool }
    verifyErr(e) { buf.readBuf(Buf(),3) }
    verifyErr(e) { buf.readBufFully(Buf(),3)  }
    verifyErr(e) { buf.readChar }
    verifyErr(e) { buf.readChars(3) }
    verifyErr(e) { buf.readDecimal }
    verifyErr(e) { buf.readF4 }
// TODO
if (!js) verifyErr(e) { buf.readF8 }
    verifyErr(e) { buf.readLine }
    verifyErr(e) { buf.readObj }
    verifyErr(e) { buf.readProps }
    verifyErr(e) { buf.readS1 }
    verifyErr(e) { buf.readS2 }
    verifyErr(e) { buf.readS4 }
// TODO
if (!js) verifyErr(e) { buf.readS8 }
    verifyErr(e) { buf.readStrToken }
    verifyErr(e) { buf.readU1 }
    verifyErr(e) { buf.readU2 }
    verifyErr(e) { buf.readU4 }
    verifyErr(e) { buf.readUtf }
    verifyErr(e) { buf.seek(0) }
    verifyErr(e) { buf[0] = 'x' }
    verifyErr(e) { buf.size = 2 }
    verifyErr(e) { buf.sync }
    verifyErr(e) { buf.unread('x') }
    verifyErr(e) { buf.unreadChar('x') }
    verifyErr(e) { buf.write('x') }
    verifyErr(e) { buf.writeBool(true) }
    verifyErr(e) { buf.writeBuf("a".toBuf) }
    verifyErr(e) { buf.writeChar('x') }
    verifyErr(e) { buf.writeChars("abc") }
    verifyErr(e) { buf.writeDecimal(10d) }
    verifyErr(e) { buf.writeF4(10f) }
// TODO
if (!js) verifyErr(e) { buf.writeF8(10f) }
    verifyErr(e) { buf.writeI2(10) }
    verifyErr(e) { buf.writeI4(10) }
// TODO
if (!js) verifyErr(e) { buf.writeI8(10) }
    verifyErr(e) { buf.writeObj("x") }
    verifyErr(e) { buf.writeProps(["x":"x"]) }
    verifyErr(e) { buf.writeUtf("x") }
    verifyErr(e) { buf.writeXml("x") }

    d := buf.dup
    d[1] = '!'
    verifyEq(d.readAllStr, "A!CD")
    verifyEq(buf.size, 4)
    verifyEq(buf[1], 'B')
    verifyEq(buf.in.readAllStr, "ABCD")

    // endian
    buf = Buf()
    verifyEq(buf.endian, Endian.big)
    buf.endian = Endian.little
    buf = buf.toImmutable
    verifyErr(e) { buf.endian = Endian.big }
    verifyEq(buf.endian, Endian.little)
    verifyEq(buf.in.endian, Endian.little)

    // charset
    buf = Buf()
    verifyEq(buf.charset, Charset.utf8)
    buf.charset = Charset.utf16BE
    buf = buf.toImmutable
    verifyErr(e) { buf.charset = Charset.utf8 }
    verifyEq(buf.charset, Charset.utf16BE)
    verifyEq(buf.in.charset, Charset.utf16BE)
  }
}