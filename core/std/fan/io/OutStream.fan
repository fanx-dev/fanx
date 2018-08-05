//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Mar 06  Brian Frank  Creation
//

**
** OutStream is used to write binary and text data
** to an output stream.
**
abstract class OutStream
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Constructor for an OutStream which wraps another stream.
  ** All writes to this stream will be routed to the specified
  ** inner stream.
  **
  ** If out is null, then it is the subclass responsibility to
  ** handle writes by overriding the following methods: `write`
  ** and `writeBuf`.
  **
  //protected new make(OutStream? out)

//////////////////////////////////////////////////////////////////////////
// Virtuals
//////////////////////////////////////////////////////////////////////////

  **
  ** Write a byte to the output stream.  Throw IOErr on error.
  ** Return this.
  **
  abstract This write(Int byte)

  **
  ** Write n bytes from the specified Buf at it's current position to
  ** this output stream.  If n is defaulted to buf.remaining(), then
  ** everything left in the buffer is drained to this output stream.
  ** The buf's position is advanced n bytes upon return.  Throw
  ** IOErr on error.  Return this.
  **
  virtual This writeBuf(Buf buf, Int n := buf.remaining) {
    buf.pipeTo(this, n)
    return this
  }

  **
  ** Writes len bytes from the specified byte array starting at offset off to this output stream.
  **
  abstract This writeBytes(ByteArray ba, Int off := 0, Int len := ba.size)

  **
  ** Flush the stream so any buffered bytes are written out.  Default
  ** implementation does nothing.  Throw IOErr on error.  Return this.
  **
  abstract This flush()

  **
  ** If this output stream is mapped to a file device, then
  ** synchronize all memory buffers to the physical storage device.
  ** Throw IOErr on error.  Return this.
  **
  abstract This sync()

  **
  ** Close the output stream.  This method is guaranteed to never
  ** throw an IOErr.  Return true if the stream was closed successfully
  ** or false if the stream was closed abnormally.  Default implementation
  ** does nothing and returns true.
  **
  abstract Bool close()

//////////////////////////////////////////////////////////////////////////
// Binary Data
//////////////////////////////////////////////////////////////////////////

  **
  ** Byte order mode for binary writes.
  ** Default is `Endian.big` (network byte order).
  **
  abstract Endian endian
  Bool bigEndian() { endian == Endian.big }

  **
  ** Write two bytes as a 16-bit number using configured `endian`.  This method
  ** may be paired with `InStream.readU2` or `InStream.readS2`.  Throw IOErr
  ** on error.  Return this.
  **
  virtual This writeI2(Int n) {
    v := n
    if (bigEndian)
      return write((v.shiftr(8)).and(0xFF))
                 .write(v.and(0xFF));
    else
      return write(v.and(0xFF))
                 .write((v.shiftr(8)).and(0xFF));
  }

  **
  ** Write four bytes as a 32-bit number using configured `endian`.  This
  ** method may be paired with `InStream.readU4` or `InStream.readS4`.  Throw
  ** IOErr on error.  Return this.
  **
  virtual This writeI4(Int n) {
    v := n
    if (bigEndian)
      return write((v.shiftr(24)).and(0xFF))
                 .write((v.shiftr(16)).and(0xFF))
                 .write((v.shiftr(8)).and(0xFF))
                 .write(v.and(0xFF));
    else
      return write(v.and(0xFF))
                 .write((v.shiftr(8)).and(0xFF))
                 .write((v.shiftr(16)).and(0xFF))
                 .write((v.shiftr(24)).and(0xFF))
  }

  **
  ** Write eight bytes as a 64-bit number using configured `endian`.  This
  ** is paired with `InStream.readS8`.  Throw IOErr on error.  Return this.
  **
  virtual This writeI8(Int n) {
    v := n
    if (bigEndian)
      return write((v.shiftr(56)).and(0xFF))
                 .write((v.shiftr(48)).and(0xFF))
                 .write((v.shiftr(40)).and(0xFF))
                 .write((v.shiftr(32)).and(0xFF))
                 .write((v.shiftr(24)).and(0xFF))
                 .write((v.shiftr(16)).and(0xFF))
                 .write((v.shiftr(8)).and(0xFF))
                 .write(v.and(0xFF));
    else
      return write(v.and(0xFF))
                 .write((v.shiftr(8)).and(0xFF))
                 .write((v.shiftr(16)).and(0xFF))
                 .write((v.shiftr(24)).and(0xFF))
                 .write((v.shiftr(32)).and(0xFF))
                 .write((v.shiftr(40)).and(0xFF))
                 .write((v.shiftr(48)).and(0xFF))
                 .write((v.shiftr(56)).and(0xFF))
  }

  **
  ** Write four bytes as a 32-bit floating point number using configured `endian`
  ** order according to `Float.bits32`.  This is paired with `InStream.readF4`.
  ** Throw IOErr on error.  Return this.
  **
  virtual This writeF4(Float r) { writeI4(r.bits32) }

  **
  ** Write eight bytes as a 64-bit floating point number using configured `endian`
  ** order according to `Float.bits`.  This is paired with `InStream.readF8`.
  ** Throw IOErr on error.  Return this.
  **
  virtual This writeF8(Float r) { writeI8(r.bits) }

  **
  ** Write a decimal as a string according to `writeUtf`.
  **
  //virtual This writeDecimal(Decimal d) { writeUtf(d.toStr) }

  **
  ** Write one byte, one if true or zero if false.  This method is paired
  ** with `InStream.readBool`.  Throw IOErr on error.  Return this.
  **
  This writeBool(Bool b) { write(b?1:0) }

  **
  ** Write a Str in modified UTF-8 format according the 'java.io.DataOutput'
  ** specification.  This method is paired with `InStream.readUtf`.  Throw
  ** IOErr on error.  Return this.
  **
  virtual This writeUtf(Str s) {
    ba := s.toUtf8
    writeI2(ba.size)
    writeBytes(ba)
    return this
  }

//////////////////////////////////////////////////////////////////////////
// Text Data
//////////////////////////////////////////////////////////////////////////

  **
  ** The current charset used to encode Unicode characters into
  ** bytes.  The default charset should always be UTF-8.
  **
  abstract Charset charset

  **
  ** Write one or more bytes to the stream for the specified Unicode
  ** character based on the current charset encoding.  Return this.
  **
  virtual This writeChar(Int ch) {
    charset.encode(ch, this)
    return this
  }

  **
  ** Write the Unicode characters in the specified string to the
  ** stream using the current charset encoding.  Off specifies
  ** the index offset to start writing characters and len the
  ** number of characters in str to write.  Return this.
  **
  virtual This writeChars(Str str, Int off := 0, Int len := str.size-off) {
    for (i:=0; i<len; ++i) {
      ch := str[i+off]
      charset.encode(ch, this)
    }
    return this
  }

  **
  ** Convenience for 'writeChars(obj.toStr)'.  If obj is null,
  ** then print the string "null".  Return this.
  **
  virtual This print(Obj? s) { writeChars(s == null ? "null" : s.toStr) }

  **
  ** Convenience for 'writeChars(obj.toStr + "\n")'.  If obj
  ** is null then print the string "null\n".  Return this.
  **
  virtual This printLine(Obj? obj := "") { print(obj).writeChar('\n') }


//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  **
  ** This OutStream is guaranteed to be closed upon return
  **
  Void use(|OutStream| f) {
    try f(this)
    finally this.close
  }
}

**************************************************************************
** SysOutStream
**************************************************************************
@NoDoc
class ProxyOutStream : OutStream
{
  protected OutStream out
  new make(OutStream out) {
    this.out = out
  }

  override This write(Int byte) { out.write(byte); return this }
  override This writeBytes(ByteArray ba, Int off := 0, Int len := ba.size) { out.writeBytes(ba, off, len); return this }
  override This sync() { out.sync; return this }
  override This flush() { out.flush; return this }
  override Bool close() { out.close }
  override Endian endian {
    get { out.endian }
    set { out.endian = it }
  }
  override Charset charset {
    get { out.charset }
    set { out.charset = it }
  }

  override This writeChar(Int ch) { out.writeChar(ch); return this }

  override This writeChars(Str str, Int off := 0, Int len := str.size-off) { out.writeChars(str, off, len); return this }
}

internal class SysOutStream : OutStream {
  override Endian endian
  override Charset charset

  new make(Endian e, Charset c) {
    endian = e
    charset = c
  }

  native override This write(Int byte)
  native override This writeBytes(ByteArray ba, Int off := 0, Int len := ba.size)
  native override This sync()
  native override This flush()
  native override Bool close()
}

