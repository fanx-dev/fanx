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
mixin OutStream
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
  abstract This writeBuf(Buf buf, Int n := buf.remaining)

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
  virtual This writeF8(Float r) { writeI4(r.bits) }

  **
  ** Write a decimal as a string according to `writeUtf`.
  **
  //virtual This writeDecimal(Decimal d) { writeUtf(d.toStr) }

  **
  ** Write one byte, one if true or zero if false.  This method is paired
  ** with `InStream.readBool`.  Throw IOErr on error.  Return this.
  **
  virtual This writeBool(Bool b) { write(b?1:0) }

  **
  ** Write a Str in modified UTF-8 format according the 'java.io.DataOutput'
  ** specification.  This method is paired with `InStream.readUtf`.  Throw
  ** IOErr on error.  Return this.
  **
  abstract This writeUtf(Str s)

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
  abstract This writeChar(Int char)

  **
  ** Write the Unicode characters in the specified string to the
  ** stream using the current charset encoding.  Off specifies
  ** the index offset to start writing characters and len the
  ** number of characters in str to write.  Return this.
  **
  abstract This writeChars(Str str, Int off := 0, Int len := str.size-off)

  **
  ** Convenience for 'writeChars(obj.toStr)'.  If obj is null,
  ** then print the string "null".  Return this.
  **
  virtual This print(Obj? s) { writeChars("$s") }

  **
  ** Convenience for 'writeChars(obj.toStr + "\n")'.  If obj
  ** is null then print the string "null\n".  Return this.
  **
  virtual This printLine(Obj? obj := "") { writeChars("$obj\n") }

  **
  ** Write a serialized object from the stream according to
  ** the Fantom [serialization format]`docLang::Serialization`.
  ** Throw IOErr on error.  Return this.
  **
  ** The options may be used to specify the format of the output:
  **   - "indent": Int specifies how many spaces to indent
  **     each level.  Default is 0.
  **   - "skipDefaults": Bool specifies if we should skip fields
  **     at their default values.  Field values are compared according
  **     to the 'equals' method.  Default is false.
  **   - "skipErrors": Bool specifies if we should skip objects which
  **     aren't serializable. If true then we output null and a comment.
  **     Default is false.
  **
  //This writeObj(Obj? obj, [Str:Obj]? options := null)

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  **
  ** Write the given map of Str name/value pairs to the output stream
  ** according to the Fantom props file format (see `InStream.readProps` for
  ** full specification).  The props are written using UTF-8 regardless
  ** of this stream's current charset.  If close argument is true, then
  ** automatically close the stream.  Return this.
  **
  //This writeProps(Str:Str props, Bool close := true)

  **
  ** Write a string to this output stream using XML escape sequences.
  ** By default only the '< > &' characters are escaped. You can
  ** use the following flags to escape additional characters:
  **   - `xmlEscNewlines`: escape the '\n' and '\r' characters
  **   - `xmlEscQuotes`: escape the single and double quote characters
  **   - `xmlEscUnicode`: escape any character greater than 0x7f
  **
  ** Any control character less than 0x20 which is not '\t', '\n' or
  ** '\r' is always escaped with a numeric reference.  Return this.
  **
  //This writeXml(Str str, Int mode := 0)

  ** XML escape newline characters.  See `writeXml`.
  //static const Int xmlEscNewlines := 0x01

  ** XML escape single and double quotes.  See `writeXml`.
  //static const Int xmlEscQuotes := 0x02

  ** XML escape any character greater then 0x7f.  See `writeXml`.
  //static const Int xmlEscUnicode := 0x04

}

**************************************************************************
** SysOutStream
**************************************************************************

class ProxyOutStream : OutStream
{
  protected OutStream out
  new make(OutStream out) {
    this.out = out
  }

  override This write(Int byte) { out.write(byte); return this }
  override This writeBuf(Buf buf, Int n := buf.remaining) { out.writeBuf(buf, n); return this }
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
  override This writeUtf(Str s) { out.writeUtf(s) }
  override This writeChar(Int char) { out.writeChar(char) }
  override This writeChars(Str str, Int off := 0, Int len := str.size-off) { out.writeChars(str, off, len) }
}