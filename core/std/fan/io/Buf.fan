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
  static Buf random(Int size) {
    x := Buf.make(size)
    x.size = size
    for (i:=0; i<size; ++i) { x[i] = Int.random(0..255) }
    return x
  }

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
  @Operator Int get(Int pos) {
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
    buf := MemBuf.makeBuf(a)
    buf.charset = this.charset
    return buf
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
  @Operator This set(Int pos, Int byte) {
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

  ** throw err in ConstBuf
  internal virtual InStream privateIn() { in }

  **
  ** Convenience for [in.read]`InStream.read`
  **
  Int read() { privateIn.read }

  **
  ** Convenience for [in.readBuf]`InStream.readBuf`
  **
  Int? readBuf(Buf buf, Int n) { privateIn.readBuf(buf, n) }

  **
  ** Convenience for [in.unread]`InStream.unread`
  ** Memory backed buffers support a stack based pushback model
  ** like IO streams.  File backed buffers will simply rewrite
  ** the last position in the file.  Return this.
  **
  This unread(Int b) { privateIn.unread(b); return this }

  **
  ** Convenience for [in.readAllBuf]`InStream.readAllBuf`
  **
  Buf readAllBuf() { privateIn.readAllBuf }

  **
  ** Convenience for [in.readBufFully]`InStream.readBufFully`
  **
  Buf readBufFully(Buf? buf, Int n) { privateIn.readBufFully(buf, n) }

  **
  ** Convenience for [in.peek]`InStream.peek`
  **
  Int peek() { privateIn.peek }

  **
  ** Convenience for [in.readU1]`InStream.readU1`
  **
  Int readU1() { privateIn.readU1 }

  **
  ** Convenience for [in.readS1]`InStream.readS1`
  **
  Int readS1() { privateIn.readS1 }

  **
  ** Convenience for [in.readU2]`InStream.readU2`
  **
  Int readU2() { privateIn.readU2 }

  **
  ** Convenience for [in.readS2]`InStream.readS2`
  **
  Int readS2() { privateIn.readS2 }

  **
  ** Convenience for [in.readU4]`InStream.readU4`
  **
  Int readU4() { privateIn.readU4 }

  **
  ** Convenience for [in.readS4]`InStream.readS4`
  **
  Int readS4() { privateIn.readS4 }

  **
  ** Convenience for [in.readS8]`InStream.readS8`
  **
  Int readS8() { privateIn.readS8 }

  **
  ** Convenience for [in.readF4]`InStream.readF4`
  **
  Float readF4() { privateIn.readF4 }

  **
  ** Convenience for [in.readF8]`InStream.readF8`
  **
  Float readF8() { privateIn.readF8 }

  **
  ** Convenience for [in.readDecimal]`InStream.readDecimal`
  **
  //Decimal readDecimal() { in.readDecimal }

  **
  ** Convenience for [in.readBool]`InStream.readBool`
  **
  Bool readBool() { privateIn.readBool }

  **
  ** Convenience for [in.readUtf]`InStream.readUtf`
  **
  Str readUtf() { privateIn.readUtf }

  **
  ** Convenience for [in.readChar]`InStream.readChar`
  **
  Int readChar() { privateIn.readChar }

  **
  ** Convenience for [in.unreadChar]`InStream.unreadChar`
  ** Memory backed buffers support a stack based pushback model
  ** like IO streams.  File backed buffers will simply rewrite
  ** the last position in the file.  Return this.
  **
  This unreadChar(Int b) { privateIn.unreadChar(b); return this }

  **
  ** Convenience for [in.peekChar]`InStream.peekChar`
  **
  Int peekChar() { privateIn.peekChar }

  **
  ** Convenience for [in.readChars]`InStream.readChars`
  **
  Str readChars(Int n) { privateIn.readChars(n) }

  **
  ** Convenience for [in.readLine]`InStream.readLine`
  **
  Str? readLine(Int max := -1) { privateIn.readLine(max) }

  **
  ** Convenience for [in.readStrToken]`InStream.readStrToken`
  **
  Str? readStrToken(Int? max := -1, |Int ch->Bool|? c := null) { privateIn.readStrToken(max, c) }

  **
  ** Convenience for [in.readAllLines]`InStream.readAllLines`
  **
  Str[] readAllLines() { privateIn.readAllLines }

  **
  ** Convenience for [in.eachLine]`InStream.eachLine`
  **
  Void eachLine(|Str line| f) { privateIn.eachLine(f) }

  **
  ** Convenience for [in.readAllStr]`InStream.readAllStr`
  **
  Str readAllStr(Bool normalizeNewlines := true) { privateIn.readAllStr(normalizeNewlines) }

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

  protected virtual ByteArray? unsafeArray() { null }
  protected virtual ByteArray safeArray() {
    ba := ByteArray(size)
    getBytes(0, ba, 0, size)
    return ba
  }

  **
  ** Encode the buffer contents from 0 to size into a
  ** hexadecimal string.  This method is unsupported for
  ** mmap buffers.
  **
  ** Example:
  **   Buf.make.print("\r\n").toHex   => "0d0a"
  **   Buf.fromHex("0d0a").readAllStr => "\r\n"
  **
  virtual Str toHex() {
    buf := unsafeArray()
    if (buf != null) {
      sb := StrBuf(this.size*2)
      memToHex(buf, this.size, sb)
      return sb.toStr
    }

    oldPos := pos
    temp := ByteArray(1024)
    total := 0
    in := this.in
    size := size
    sb := StrBuf(size*2)
    pos = 0
    while (total < size) {
      n := in.readBytes(temp, 0, temp.size.min(size - total))
      if (n < 0) {
        break
      }
      memToHex(temp, n, sb)
      total += n
    }
    this.pos = oldPos
    return sb.toStr
  }
  internal static const Str hexChars := "0123456789abcdef"

  private Void memToHex(ByteArray temp, Int n, StrBuf sb) {
    for (i:=0; i<n; ++i) {
      b := temp[i].and(0xFF)
      h := b.shiftr(4)
      l := b.and(0xF)
      sb.addChar(hexChars[h])
       .addChar(hexChars[l])
    }
  }

  private static Int parseHex(Int ch) {
    nib := -1
    if ('0' <= ch && ch <= '9') nib = ch - '0'
    else if ('a' <= ch && ch <= 'f') nib = 10 + ch - 'a'
    else if ('A' <= ch && ch <= 'F') nib = 10 + ch - 'A'
    return nib
  }

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
  static Buf fromHex(Str s) {
    slen := s.size
    buf := ByteArray(slen/2)
    size := 0

    for (i:=0; i<slen; ++i) {
      c0 := s[i]
      n0 := parseHex(c0)
      if (n0 < 0) continue

      n1 := -1
      if (++i < slen) {
        c1 := s[i]
        n1 = parseHex(c1)
      }
      if (n1 < 0) throw IOErr.make("Invalid hex str")

      buf[size++] = n0.shiftl(4).or(n1)
    }

    return MemBuf.makeBuf(buf, size)
  }


  protected virtual Void pipeTo(OutStream out, Int len) {
    temp := ByteArray(1024)
    total := 0
    in := this.in
    while (total < len) {
      n := in.readBytes(temp, 0, temp.size.min(len - total))
      if (n < 0) {
        break
      }
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
      this.pos += n
      total += n
    }
    return total
  }

  **
  ** Create an in-memory File instance for this buffer with the given
  ** file URI.  The buffer must be a RAM based buffer which is converted
  ** to an immutable buffer via 'Obj.toImmutable' semantics.  The current
  ** time is used for the file's modified time.
  **
  virtual File toFile(Uri uri) { throw UnsupportedErr("Only supported on memory buffers") }
}

