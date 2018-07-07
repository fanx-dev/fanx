//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Mar 06  Brian Frank  Creation
//

**
** Buf is used to model a block of bytes with random access.  Buf is
** typically backed by a block of memory, but can also be backed by
** a file:
**   - `Buf.make`: backed by RAM
**   - `File.open`: backed by random access file
**   - `File.mmap`: backed by memory mapped file
**
** Buf provides an `InStream` and `OutStream` to read and write into
** the buffer using a configurable position accessed via `Buf.pos`
** and `Buf.seek`.
**
** When using an InStream, bytes are read starting at pos where pos
** is advanced after each read.  The end of stream is reached when pos
** reaches size.  When using the OutStream, bytes are written starting at pos
** with pos advanced after each write.  If pos is less then size then
** the existing bytes are rewritten and size is not advanced, otherwise
** the buffer is automatically grown and size is advanced as bytes are
** appended.  It is common to write bytes into the buffer using the
** OutStream, then call `Buf.flip` to prepare the buffer to be used for reading.
**
@NoPeer
rtconst abstract class Buf
{

//////////////////////////////////////////////////////////////////////////
// Factory
//////////////////////////////////////////////////////////////////////////

  **
  ** Allocate a byte buffer in RAM with the initial given capacity.
  **
  static new make(Int capacity := 1024) {
    MemBuf(capacity)
  }

  protected new privateMake() {}

  **
  ** Generate a random series of bytes.
  **
  ** Example:
  **   Buf.random(8).toHex  => "d548b54989028b90"
  **
  native static Buf random(Int size)

  **
  ** Buf cannot be subclassed outside of sys since we do
  ** much optimization under the covers in Java and C#.
  **
  //internal new internalMake()

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  **
  ** Buf equality is based on reference equality using the === operator.
  **
  override Bool equals(Obj? that) { this === that }

  **
  ** Return string summary of the buffer.
  **
  override Str toStr() { super.toStr + "(pos=$pos size=$size)" }

//////////////////////////////////////////////////////////////////////////
// Access
//////////////////////////////////////////////////////////////////////////

  **
  ** Return if size() == 0.
  **
  Bool isEmpty() { size == 0 }

  **
  ** Return the total number of bytes in the buffer.  If the size is
  ** set greater than capacity then the buffer's capacity is automatically
  ** grown, otherwise capacity remains the same.  Setting size does not
  ** actually change any bytes in the buffer.  A mmap buffer can never
  ** be increased from its initial size.
  **
  abstract Int size

  **
  ** The number of bytes this buffer can hold without allocating more
  ** memory.  Capacity is always greater or equal to size.  If adding a
  ** large number of bytes, it may be more efficient to manually set
  ** capacity.  See the `trim` method to automatically set capacity to
  ** size.  Throw ArgErr if attempting to set capacity less than size.
  ** This method is ignored on a file buffer, and unsupported on mmap.
  **
  abstract Int capacity

  **
  ** Return the current position for the next read or write.  The
  ** position is always between 0 and `size`.  If pos is less then
  ** size then future writes will rewrite the existing bytes without
  ** growing size.  Change the position with `seek`.
  **
  abstract Int pos { internal set }

  **
  ** Return the remaining number of bytes to read: size-pos.
  **
  Int remaining() { size - pos }

  **
  ** Return if more bytes are available to read: remaining() > 0.
  **
  Bool more() { remaining > 0 }

  **
  ** Set the current position to the specified byte offset.  A
  ** negative index may be used to access from the end of the buffer.
  ** For example seek(-1) is translated into seek(size-1).
  ** Return this.
  **
  This seek(Int pos) {
    size := this.size
    if (pos < 0) pos = size + pos;
    if (pos < 0 || pos > size) throw IndexErr.make("$pos");
    this.pos = pos
    return this
  }

  **
  ** Flip a buffer from write-mode to read-mode.  This method sets
  ** total size to current position, and position to 0.  Return this.
  **
  This flip() {
    size = pos
    pos = 0
    return this
  }

  **
  ** Get the byte at the specified absolute index.  A negative index
  ** may be used to access from the end of the buffer.  For example
  ** get(-1)  is translated into get(size()-1).  This method accesses
  ** the buffer absolutely independent of current position.  The get
  ** method is accessed via the [] shortcut operator.  Throw IndexErr
  ** if index out of range.
  **
  @Operator Int get(Int index) {
    size := this.size
    if (pos < 0) pos = size + pos
    if (pos < 0 || pos >= size) throw IndexErr.make("$pos")
    return getByte(pos)
  }

  protected abstract Int getByte(Int pos)
  protected abstract Void setByte(Int pos, Int v)

  protected abstract Int getBytes(Int pos, ByteArray dst, Int off, Int len)
  protected abstract Void setBytes(Int pos, ByteArray src, Int off, Int len)

  **
  ** Return a new buffer containing the bytes in the specified absolute
  ** range.  Negative indexes may be used to access from the end of
  ** the buf.  This method accesses the buffer absolutely independent
  ** of current position.  This method is accessed via the [] operator.
  ** Throw IndexErr if range illegal.
  **
  ** Examples:
  **   buf := Buf.make
  **   buf.write(0xaa).write(0xbb).write(0xcc).write(0xdd)
  **   buf[0..2]   => 0x[aabbcc]
  **   buf[3..3]   => 0x[dd]
  **   buf[-2..-1] => 0x[ccdd]
  **   buf[0..<2]  => 0x[aabb]
  **   buf[1..-2]  => 0x[bbcc]
  **
  @Operator virtual Buf getRange(Range range) {
    size := this.size
    s := range.startIndex(size);
    e := range.endIndex(size);
    n := (e - s + 1);
    if (n < 0) throw IndexErr.make("$range");

    a := ByteArray(n)
    getBytes(s, a, 0, n)
    //a.copyFrom(buf, s, 0, n)
    return MemBuf.makeBuf(a)
  }

  **
  ** Create a new buffer in memory which deeply clones this buffer.
  **
  virtual Buf dup() {
    size := this.size
    a := ByteArray(size)
    getBytes(0, a, 0, size)
    //a.copyFrom(buf, 0, 0, size)
    return MemBuf.makeBuf(a)
  }

//////////////////////////////////////////////////////////////////////////
// Modification
//////////////////////////////////////////////////////////////////////////

  **
  ** Set is used to overwrite the byte at the specified the index.  A
  ** negative index may be used to access an index from the end of the
  ** buffer.  The set method is accessed via the []= shortcut operator.
  ** Return this.  Throw IndexErr if index is out of range.
  **
  @Operator This set(Int index, Int byte) {
    size := this.size
    if (pos < 0) pos = size + pos
    if (pos < 0 || pos >= size) throw IndexErr.make("$pos")
    setByte(pos, byte)
    return this
  }

  **
  ** Read the buffer for a fresh read by reseting the buffer's pos
  ** and size to zero.  The buffer's capacity remains the same.
  ** Return this.
  **
  This clear() { pos = 0; size = 0; return this }

  **
  ** Trim the capacity such that the underlying storage is optimized
  ** for the current size.  Return this.
  **
  virtual This trim() {
    if (size != capacity) capacity = size
    return this
  }

  **
  ** If this buffer is backed by a file, then close it.  If a memory
  ** buffer then do nothing.  This method is guaranteed to never
  ** throw an IOErr.  Return true if the buffer was closed
  ** successfully or false if closed abnormally.
  **
  abstract Bool close()

  **
  ** If this Buf is backed by a file, then fsync all changes to
  ** the storage device.  Throw IOErr on error.  Return this.
  **
  abstract This sync()

  **
  ** Byte order mode for both OutStream and InStream.
  ** Default is `Endian.big` (network byte order).
  **
  abstract Endian endian

  **
  ** Character set for both the OutStream and InStream.
  **
  abstract Charset charset

  **
  ** Write the specified byte to the end of the buffer using given count.
  **
  ** Examples:
  **   Buf().fill(0xff, 4)  =>  0xffffffff
  **
  virtual This fill(Int b, Int times) {
    if (capacity < size+times) capacity = size+times
    out := this.out
    for (i := 0; i < times; ++i)
      out.write(b)
    return this
  }

//////////////////////////////////////////////////////////////////////////
// OutStream
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the OutStream which writes to this buffer.
  ** This method always returns the same instance.
  ** If this buffer is backed by a file, then 'out.close'
  ** will not close the file - you must use `Buf.close`.
  **
  virtual once OutStream out() { BufOutStream(this) }

  **
  ** Convenience for [out.write]`OutStream.write`
  ** Return this.
  **
  This write(Int byte) { out.write(byte); return this }

  **
  ** Convenience for [out.writeBuf]`OutStream.writeBuf`
  ** Return this.
  **
  This writeBuf(Buf buf, Int n := buf.remaining) { out.writeBuf(buf, n); return this }

  **
  ** Convenience for [out.writeI2]`OutStream.writeI2`
  ** Return this.
  **
  This writeI2(Int n) { out.writeI2(n); return this }

  **
  ** Convenience for [out.writeI4]`OutStream.writeI4`
  ** Return this.
  **
  This writeI4(Int n) { out.writeI4(n); return this }

  **
  ** Convenience for [out.writeI8]`OutStream.writeI8`
  ** Return this.
  **
  This writeI8(Int n) { out.writeI8(n); return this }

  **
  ** Convenience for [out.writeF4]`OutStream.writeF4`
  ** Return this.
  **
  This writeF4(Float r) { out.writeF4(r); return this }

  **
  ** Convenience for [out.writeF8]`OutStream.writeF8`
  ** Return this.
  **
  This writeF8(Float r) { out.writeF8(r); return this }

  **
  ** Convenience for [out.writeDecimal]`OutStream.writeDecimal`
  ** Return this.
  **
  //This writeDecimal(Decimal d)

  **
  ** Convenience for [out.writeBool]`OutStream.writeBool`
  ** Return this.
  **
  This writeBool(Bool b) { out.writeBool(b); return this }

  **
  ** Convenience for [out.writeUtf]`OutStream.writeUtf`
  ** Return this.
  **
  This writeUtf(Str s) { out.writeUtf(s); return this }

  **
  ** Convenience for [out.writeChar]`OutStream.writeChar`
  ** Return this.
  **
  This writeChar(Int char) { out.writeChar(char); return this }

  **
  ** Convenience for [out.writeChars]`OutStream.writeChars`
  ** Return this.
  **
  This writeChars(Str str, Int off := 0, Int len := str.size-off) { out.writeChars(str, off, len); return this }

  **
  ** Convenience for [out.print]`OutStream.print`
  ** Return this.
  **
  This print(Obj? s) { out.print(s); return this }

  **
  ** Convenience for [out.printLine]`OutStream.printLine`
  ** Return this.
  **
  This printLine(Obj? obj := "") { out.printLine(obj); return this }

  **
  ** Convenience for [out.writeProps]`OutStream.writeProps`
  ** Return this.
  **
  //This writeProps(Str:Str props)

  **
  ** Convenience for [out.writeObj]`OutStream.writeObj`
  ** Return this.
  **
  //This writeObj(Obj? obj, [Str:Obj]? options := null)

  **
  ** Convenience for [out.writeXml]`OutStream.writeXml`
  ** Return this.
  **
  //This writeXml(Str s, Int flags := 0)

//////////////////////////////////////////////////////////////////////////
// InStream
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the InStream which reads from this buffer.
  ** This method always returns the same instance.
  ** If this buffer is backed by a file, then 'in.close'
  ** will not close the file - you must use `Buf.close`.
  **
  virtual once InStream in() { BufInStream(this) }

  **
  ** Convenience for [in.read]`InStream.read`
  **
  Int? read() { in.read }

  **
  ** Convenience for [in.readBuf]`InStream.readBuf`
  **
  Int? readBuf(Buf buf, Int n) { in.readBuf(buf, n) }

  **
  ** Convenience for [in.unread]`InStream.unread`
  ** Memory backed buffers support a stack based pushback model
  ** like IO streams.  File backed buffers will simply rewrite
  ** the last position in the file.  Return this.
  **
  This unread(Int b) { in.unread(b); return this }

  **
  ** Convenience for [in.readAllBuf]`InStream.readAllBuf`
  **
  Buf readAllBuf() { in.readAllBuf }

  **
  ** Convenience for [in.readBufFully]`InStream.readBufFully`
  **
  Buf readBufFully(Buf? buf, Int n) { in.readBufFully(buf, n) }

  **
  ** Convenience for [in.peek]`InStream.peek`
  **
  Int? peek() { in.peek }

  **
  ** Convenience for [in.readU1]`InStream.readU1`
  **
  Int readU1() { in.readU1 }

  **
  ** Convenience for [in.readS1]`InStream.readS1`
  **
  Int readS1() { in.readS1 }

  **
  ** Convenience for [in.readU2]`InStream.readU2`
  **
  Int readU2() { in.readU2 }

  **
  ** Convenience for [in.readS2]`InStream.readS2`
  **
  Int readS2() { in.readS2 }

  **
  ** Convenience for [in.readU4]`InStream.readU4`
  **
  Int readU4() { in.readU4 }

  **
  ** Convenience for [in.readS4]`InStream.readS4`
  **
  Int readS4() { in.readS4 }

  **
  ** Convenience for [in.readS8]`InStream.readS8`
  **
  Int readS8() { in.readS8 }

  **
  ** Convenience for [in.readF4]`InStream.readF4`
  **
  Float readF4() { in.readF4 }

  **
  ** Convenience for [in.readF8]`InStream.readF8`
  **
  Float readF8() { in.readF8 }

  **
  ** Convenience for [in.readDecimal]`InStream.readDecimal`
  **
  //Decimal readDecimal() { in.readDecimal }

  **
  ** Convenience for [in.readBool]`InStream.readBool`
  **
  Bool readBool() { in.readBool }

  **
  ** Convenience for [in.readUtf]`InStream.readUtf`
  **
  Str readUtf() { in.readUtf }

  **
  ** Convenience for [in.readChar]`InStream.readChar`
  **
  Int? readChar() { in.readChar }

  **
  ** Convenience for [in.unreadChar]`InStream.unreadChar`
  ** Memory backed buffers support a stack based pushback model
  ** like IO streams.  File backed buffers will simply rewrite
  ** the last position in the file.  Return this.
  **
  This unreadChar(Int b) { in.unreadChar(b); return this }

  **
  ** Convenience for [in.peekChar]`InStream.peekChar`
  **
  Int? peekChar() { in.peekChar }

  **
  ** Convenience for [in.readChars]`InStream.readChars`
  **
  Str readChars(Int n) { in.readChars(n) }

  **
  ** Convenience for [in.readLine]`InStream.readLine`
  **
  Str? readLine(Int? max := null) { in.readLine(max) }

  **
  ** Convenience for [in.readStrToken]`InStream.readStrToken`
  **
  Str? readStrToken(Int? max := null, |Int ch->Bool|? c := null) { in.readStrToken(max, c) }

  **
  ** Convenience for [in.readAllLines]`InStream.readAllLines`
  **
  Str[] readAllLines() { in.readAllLines }

  **
  ** Convenience for [in.eachLine]`InStream.eachLine`
  **
  Void eachLine(|Str line| f) { in.eachLine(f) }

  **
  ** Convenience for [in.readAllStr]`InStream.readAllStr`
  **
  Str readAllStr(Bool normalizeNewlines := true) { in.readAllStr(normalizeNewlines) }

  **
  ** Convenience for [in.readProps]`InStream.readProps`
  **
  //Str:Str readProps()

  **
  ** Convenience for [in.readObj]`InStream.readObj`
  **
  //Obj? readObj([Str:Obj]? options := null)

//////////////////////////////////////////////////////////////////////////
// Conversions
//////////////////////////////////////////////////////////////////////////

  **
  ** Encode the buffer contents from 0 to size into a
  ** hexadecimal string.  This method is unsupported for
  ** mmap buffers.
  **
  ** Example:
  **   Buf.make.print("\r\n").toHex   => "0d0a"
  **   Buf.fromHex("0d0a").readAllStr => "\r\n"
  **
  native Str toHex()
  //private static const Str := "0123456789abcdef"

  **
  ** Decode the specified hexadecimal string into its binary
  ** contents.  Any characters which are not included in the
  ** set "0-9, a-f, A-F" are ignored as long as they appear
  ** between bytes (hi and lo nibbles must be contiguous).
  **
  ** Example:
  **   Buf.make.print("\r\n").toHex   => "0d0a"
  **   Buf.fromHex("0d0a").readAllStr => "\r\n"
  **
  native static Buf fromHex(Str s)

  **
  ** Encode the buffer contents from 0 to size to a Base64
  ** string as defined by MIME RFC 2045.  No line breaks are
  ** added.  This method is only supported by memory backed
  ** buffers, file backed buffers will throw UnsupportedErr.
  **
  ** Example:
  **   Buf.make.print("Fan").toBase64    => "RmFu"
  **   Buf.fromBase64("RmFu").readAllStr => "Fan"
  **
  native Str toBase64()

  **
  ** Decode the specified Base64 string into its binary contents
  ** as defined by MIME RFC 2045.  Any characters which are not
  ** included in the Base64 character set are safely ignored.
  **
  ** Example:
  **   Buf.make.print("Fan").toBase64    => "RmFu"
  **   Buf.fromBase64("RmFu").readAllStr => "Fan"
  **
  native static Buf fromBase64(Str s)

  **
  ** Apply the specified message digest algorthm to this buffer's
  ** contents from 0 to size and return the resulting hash.  Digests
  ** are secure one-way hash functions which input an arbitrary sized
  ** buffer and return a fixed sized buffer.  Common algorithms include:
  ** "MD5", "SHA-1", and "SHA-256"; the full list supported is platform
  ** dependent.  On the Java VM, the algorithm maps to those avaialble
  ** via the 'java.security.MessageDigest' API.  Throw ArgErr if the
  ** algorithm is not available.  This method is unsupported for mmap
  ** buffers.
  **
  ** Example:
  **   Buf.make.print("password").print("salt").toDigest("MD5").toHex
  **    =>  "b305cadbb3bce54f3aa59c64fec00dea"
  **
  native Buf toDigest(Str algorithm)

  **
  ** Compute a cycle reduancy check code using this buffer's contents
  ** from 0 to size.  The supported algorithm names:
  **    - "CRC-16": also known as CRC-16-ANSI, CRC-16-IBM; used by
  **      USB, ANSI X3.28, and Modbus
  **    - "CRC-32": used by Ethernet, MPEG-2, PKZIP, Gzip, PNG
  **    - "CRC-32-Adler": used by Zlib
  **
  ** Raise ArgErr is algorithm is not available.  This method is
  ** only supported for memory based buffers.
  **
  native Int crc(Str algorithm)

  **
  ** Generate an HMAC message authentication as specified by RFC 2104.
  ** This buffer is the data input, 'algorithm' specifies the hash digest,
  ** and 'key' represents the secret key:
  **   - 'H': specified by algorthim parameter - "MD5" or "SHA1"
  **   - 'K': secret key specified by key parameter
  **   - 'B': fixed at 64
  **   - 'text': this instance
  **
  ** The HMAC is computed using:
  **   ipad = the byte 0x36 repeated B times
  **   opad = the byte 0x5C repeated B times
  **   H(K XOR opad, H(K XOR ipad, text))
  **
  ** Throw ArgErr if the algorithm is not available.  This method is
  ** only supported for memory buffers.
  **
  ** Examples:
  **   "hi there".toBuf.hmac("MD5", "secret".toBuf)
  **
  native Buf hmac(Str algorithm, Buf key)


  protected virtual Void pipeTo(OutStream out, Int len) {
    temp := ByteArray(1024)
    total := 0
    while (total < len) {
      n := getBytes(pos, temp, 0, temp.size.min(len - total))
      out.writeBytes(temp, 0, n)
      total += n
    }
  }

  protected virtual Int pipeFrom(InStream in, Int len) {
    total := 0
    ba := ByteArray(1024)
    while (total < len) {
      n := in.readBytes(ba, 0, ba.size.min(len - total))
      if (n < 0)
        return total == 0 ? -1 : total
      setBytes(pos, ba, 0, n)
      total += n
    }
    return total
  }
}

**************************************************************************
** FileBuf
**************************************************************************

internal class FileBuf : Buf
{
  new make(File file, Str mode) : super.privateMake() {
    init(file, mode)
  }

  protected native Void init(File file, Str mode)

  native override Int size
  native override Int capacity
  native override Int pos

  native override Int getByte(Int index)
  native override Void setByte(Int index, Int byte)

  native override Int getBytes(Int pos, ByteArray dst, Int off, Int len)
  native override Void setBytes(Int pos, ByteArray src, Int off, Int len)

  native override Bool close()
  native override This sync()

  override Endian endian {
    set { in.endian = it; out.endian = it }
    get { out.endian }
  }
  override Charset charset {
    set { in.charset = it; out.charset = it }
    get { out.charset }
  }
}

