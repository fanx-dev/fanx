//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Mar 06  Brian Frank  Creation
//

**
** InStream is used to read binary and text stream based input.
**
abstract class InStream
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Constructor for an InStream which wraps another stream.
  ** All reads from this stream will be routed to the specified
  ** inner stream.
  **
  ** If in is null, then it is the subclass responsibility to
  ** handle reads by overriding the following methods: `read`,
  ** `readBuf`, and `unread`.
  **
  //protected new make(InStream? in)

//////////////////////////////////////////////////////////////////////////
// Virtuals
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the number of bytes available on input stream without
  ** blocking.  Return zero if no bytes available or it is unknown.
  ** Throw IOErr on error.
  **
  abstract Int avail()

  **
  ** Read the next unsigned byte from the input stream.
  ** Return -1 if at end of stream.  Throw IOErr on error.
  **
  abstract Int read()
  internal Int r() { read }

  **
  ** Attempt to read the next n bytes into the Buf at it's current
  ** position.  The buffer will be grown as needed.  Return the number
  ** of bytes read and increment buf's size and position accordingly.
  ** Return null and leave buf's state untouched if end of stream.
  ** Note this method may not read the full number of n bytes, use
  ** `readBufFully` if you must block until all n bytes read.
  ** Throw IOErr on error.
  **
  virtual Int readBuf(Buf buf, Int n) {
    return buf.pipeFrom(this, n)
  }

  **
  ** Reads up to len bytes of data from the input stream into an array of bytes.
  **
  abstract Int readBytes(ByteArray ba, Int off := 0, Int len := ba.size)

  **
  ** Pushback a byte so that it is the next byte to be read.  There
  ** is a finite limit to the number of bytes which may be pushed
  ** back.  Return this.
  **
  abstract This unread(Int b)

  **
  ** Close the input stream.  This method is guaranteed to never
  ** throw an IOErr.  Return true if the stream was closed successfully
  ** or false if the stream was closed abnormally.  Default implementation
  ** does nothing and returns true.
  **
  abstract Bool close()

  **
  ** Attempt to skip 'n' number of bytes.  Return the number of bytes
  ** actually skipped which may be equal to or lesser than n.
  **
  virtual Int skip(Int n) {
    for (i:=0; i<n; ++i) {
      if (r() < 0) return i
    }
    return n
  }

//////////////////////////////////////////////////////////////////////////
// Buf Support
//////////////////////////////////////////////////////////////////////////

  private const static Int chunkSize := 4096
  **
  ** Read the entire contents of the stream into a memory Buf.
  ** The resulting buffer is automatically positioned at the beginning.
  ** This InStream is guaranteed to be closed.
  **
  virtual Buf readAllBuf() {
    try
    {
      size := chunkSize;
      Buf buf := Buf.make(size)
      while (readBuf(buf, size) != -1) {}
      buf.flip
      return buf
    }
    finally
    {
      try { close() } catch (Err e) { e.trace }
    }
  }

  **
  ** Read the next n bytes from the stream into the Buf at it's
  ** current position.  The buffer will be grown as needed.  If the
  ** buf parameter is null, then a memory buffer is automatically created
  ** with a capacity of n.  Block until exactly n bytes have been
  ** read or throw IOErr if end of stream is reached first.  Return
  ** the Buf passed in or the one created automatically if buf is null.
  ** The buffer is automatically positioned at zero.
  **
  Buf readBufFully(Buf? buf, Int n) {
    if (buf == null) buf = Buf.make(n)

    total := n
    got := 0
    while (got < total)
    {
      r := readBuf(buf, total-got)
      if (r == -1) throw IOErr("Unexpected end of stream")
      got += r
    }

    buf.flip
    return buf
  }

//////////////////////////////////////////////////////////////////////////
// Binary Data
//////////////////////////////////////////////////////////////////////////

  **
  ** Byte order mode for binary reads.
  ** Default is `Endian.big` (network byte order).
  **
  abstract Endian endian
  Bool bigEndian() { endian == Endian.big }

  **
  ** Peek at the next byte to be read without actually consuming
  ** it.  Peek has the same semantics as a read/unread.  Return
  ** -1 if at end of stream.
  **
  virtual Int peek() {
    x := r()
    if (x != -1) unread(x)
    return x
  }

  **
  ** Read the next byte as an unsigned 8-bit number.  This method may
  ** be paired with `OutStream.write`.  Throw IOErr on error or if the
  ** end of stream is reached before one byte can be read.  This method
  ** differs from `read` in that it will throw IOErr on end of stream
  ** rather than return null.
  **
  Int readU1() {
    c := r
    if (c < 0) throw IOErr.make("Unexpected end of stream");
    return c
  }

  **
  ** Read the next byte as a signed 8-bit number.  This method may be
  ** paired with `OutStream.write`.  Throw IOErr on error or if the end
  ** of stream is reached before one byte can be read.
  **
  virtual Int readS1() { x := readU1; return SysInStream.toSigned(x, 1) }

  **
  ** Read the next two bytes as an unsigned 16-bit number using configured
  ** `endian`.  This method may be paired with `OutStream.writeI2`.
  ** Throw IOErr on error or if the end of stream is reached before
  ** two bytes can be read.
  **
  Int readU2() {
    c1 := r();
    c2 := r();
    if ((c1.or(c2)) < 0) throw IOErr.make("Unexpected end of stream");
    if (bigEndian)
      return c1.shiftl(8).or(c2)
    else
      return c2.shiftl(8).or(c1)
  }

  **
  ** Read the next two bytes as a signed 16-bit number using configured
  ** `endian`.  This method may be paired with `OutStream.writeI2`.
  ** Throw IOErr on error or if the end of stream is reached before
  ** two bytes can be read.
  **
  virtual Int readS2() {
    x := readU2
    return SysInStream.toSigned(x, 2)
  }

  **
  ** Read the next four bytes as an unsigned 32-bit number using configured
  ** `endian`.  This method may be paired with `OutStream.writeI4`.
  ** Throw IOErr on error or if the end of stream is reached before
  ** four bytes can be read.
  **
  Int readU4() {
    c1 := r();
    c2 := r();
    c3 := r();
    c4 := r();
    if ((c1.or(c2).or(c3).or(c4) < 0)) throw IOErr.make("Unexpected end of stream");
    if (bigEndian)
      //return (c1 << 24) + (c2 << 16) + (c3 << 8) + c4;
      return c1.shiftl(24).or(c2.shiftl(16)).or(c3.shiftl(8)).or(c4)
    else
      //return (c4 << 24) + (c3 << 16) + (c2 << 8) + c1;
      return c4.shiftl(24).or(c3.shiftl(16)).or(c2.shiftl(8)).or(c1)
  }

  **
  ** Read the next four bytes as a signed 32-bit number using configured
  ** `endian`.  This method may be paired with `OutStream.writeI4`.
  ** Throw IOErr on error or if the end of stream is reached before
  ** four bytes can be read.
  **
  virtual Int readS4() {
    x := readU4
    return SysInStream.toSigned(x, 4)
  }

  **
  ** Read the next eight bytes as a signed 64-bit number using configured
  ** `endian`.  This method may be paired with `OutStream.writeI8`.
  ** Throw IOErr on error or if the end of stream is reached before
  ** eight bytes can be read.  Note there is no readU8 (because Java
  ** doesn't support unsigned longs).
  **
  Int readS8() {
    c1 := r();
    c2 := r();
    c3 := r();
    c4 := r();
    c5 := r();
    c6 := r();
    c7 := r();
    c8 := r();
    if ((c1.or(c2).or(c3).or(c4).or(c5).or(c6).or(c7).or(c8) < 0)) throw IOErr.make("Unexpected end of stream");
    if (bigEndian)
      return ((c1.shiftl(56)) + (c2.shiftl(48)) + (c3.shiftl(40)) + (c4.shiftl(32)) +
              (c5.shiftl(24)) + (c6.shiftl(16)) + (c7.shiftl(8)) + c8);
    else
      return ((c8.shiftl(56)) + (c7.shiftl(48)) + (c6.shiftl(40)) + (c5.shiftl(32)) +
              (c4.shiftl(24)) + (c3.shiftl(16)) + (c2.shiftl(8)) + c1);
  }

  **
  ** Read the next four bytes as a 32-bit floating point number using
  ** using configured `endian` according to `Float.bits32`.  This method
  ** may be paired with `OutStream.writeF4`.  Throw IOErr on error or if
  ** the end of stream is reached before four bytes can be read.
  **
  Float readF4() { Float.makeBits32(readS4) }

  **
  ** Read the next eight bytes as a 64-bit floating point number using
  ** configured `endian` according to `Float.bits`.  This method may be
  ** paired with `OutStream.writeF8`.  Throw IOErr on error or if the
  ** end of stream is reached before four bytes can be read.
  **
  Float readF8() { Float.makeBits(readS8) }

  **
  ** Read the next byte and return true if nonzero.  This method may
  ** be paired with `OutStream.writeBool`.  Throw IOErr on error or if
  ** the end of stream is reached before one byte can be read.
  **
  Bool readBool() {
    n := r();
    if (n < 0) throw IOErr.make("Unexpected end of stream");
    return n != 0;
  }

  **
  ** Read a decimal string according to `readUtf`.
  **
  //Decimal readDecimal()

  **
  ** Read a Str in modified UTF-8 format according the java.io.DataInput
  ** specification. This method may be paired with `OutStream.writeUtf`.
  ** Throw IOErr on error, invalid UTF encoding, or if the end of stream
  ** is reached before the string is fully read.
  **
  virtual Str readUtf() {
    sz := readS2
    ba := ByteArray(sz)
    readBytes(ba)
    return Str.fromUtf8(ba)
  }

//////////////////////////////////////////////////////////////////////////
// Text Data
//////////////////////////////////////////////////////////////////////////

  **
  ** The current charset used to decode bytes into Unicode
  ** characters.  The default charset should always be UTF-8.
  **
  abstract Charset charset

  **
  ** Read a single Unicode character from the stream using the
  ** current charset encoding.  Return -1 if at end of stream.
  ** Throw IOErr if there is a problem reading the stream, or
  ** an invalid character encoding is encountered.
  **
  virtual Int readChar() { charset.decode(this) }

  **
  ** Pushback a char so that it is the next char to be read.  This
  ** method pushes back one or more bytes depending on the current
  ** character encoding.  Return this.
  **
  virtual This unreadChar(Int b) {
    ba := ByteArray(8)
    n := charset.encodeArray(b, ba, 0)
    for (i:=n-1; i>=0; --i) {
      unread(ba[i])
    }
    return this
  }

  **
  ** Peek at the next char to be read without actually consuming
  ** it.  Peek has the same semantics as a readChar/unreadChar.
  ** Return null if at end of stream.
  **
  virtual Int peekChar() {
    x := readChar()
    if (x != -1) unreadChar(x)
    return x
  }

  **
  ** Read the next n chars from the stream as a Str using the
  ** current `charset`.  Block until exactly n chars have been
  ** read or throw IOErr if end of stream is reached first.
  **
  virtual Str readChars(Int n) {
    if (n < 0) throw ArgErr("readChars n < 0: $n")
    if (n == 0) return ""
    buf := StrBuf()
    for (i:=n; i>0; --i)
    {
      ch := readChar
      if (ch < 0) throw IOErr("Unexpected end of stream")
      buf.addChar(ch)
    }
    return buf.toStr
  }

  **
  ** Read the next line from the input stream as a Str based on the
  ** configured charset.  A line is terminated by \n, \r\n, \r, or
  ** EOF.  The Str returned never contains the trailing newline.
  **
  ** The max parameter specifies the maximum number of Unicode
  ** chacters (not bytes) to read before truncating the line and
  ** returning.  If max is null, then no boundary is enforced except
  ** of course the end of the stream.  Max defaults to 4kb.
  **
  ** Return null if the end of stream has been reached.  Throw IOErr
  ** if there is a problem reading the stream or an invalid character
  ** encoding is encountered.
  **
  virtual Str? readLine(Int max := -1) {
    if (max < 0) max = Int.maxVal
    if (max == 0) return ""
    buf := StrBuf()
    for (i:=max; i>0; --i) {
      c := readChar
      if (c < 0) {
        if (buf.size == 0) return null
        break
      }
      else if (c == '\n') break
      else if (c == '\r') {
        c = readChar
        if (c >= 0 && c != '\n') unreadChar(c);
        break
      }
      buf.addChar(c)
    }
    return buf.toStr
  }

  **
  ** Read a Str token from the input stream which is terminated
  ** when the specified function 'c' returns true.  The terminating
  ** char is unread and will be the next char read once this
  ** method returns.  Characters are read based on the currently
  ** configured charset.
  **
  ** If 'c' is null then the default implementation tokenizes up
  ** until the next character which returns true for `Int.isSpace`.
  **
  ** The max parameter specifies the maximum number of Unicode
  ** chacters (not bytes) to read before truncating the line and
  ** returning.  If max is null, then no boundary is enforced except
  ** of course the end of the stream.  Max defaults to 4kb.
  **
  ** Return null if the end of stream has been reached.  Throw IOErr
  ** if there is a problem reading the stream or an invalid character
  ** encoding is encountered.
  **
  Str? readStrToken(Int max := -1, |Int ch->Bool|? callback := null) {
    if (max == -1) max = Int.maxVal
    sb := StrBuf()
    while (sb.size < max) {
      c := readChar
      if (c < 0) {
        if (sb.size == 0) return null
        break
      }
      terminate := false
      if (callback == null)
        terminate = c.isSpace
      else
        terminate = callback.call(c)
      if (terminate)
      {
        unreadChar(c)
        break
      }
      sb.addChar(c)
    }
    return sb.toStr
  }

  **
  ** Read a string terminated by the "\0" character.  The "\0"
  ** character is read from the stream, but not included in the
  ** string result.
  **
  ** The max parameter specifies the maximum number of Unicode
  ** chacters (not bytes) to read before truncating the string and
  ** returning.  If max is null, then no boundary is enforced except
  ** of course the end of the stream.
  **
  Str? readNullTerminatedStr(Int max := -1) {
    if (max < 0) max = Int.maxVal
    buf := StrBuf()
    while (buf.size < max) {
      ch := readChar
      if (ch < 0) {
        if (buf.size == 0) return null
        break
      }
      if (ch == 0) break
      buf.addChar(ch)
    }
    return buf.toStr
  }

  **
  ** Read the entire stream into a list of Str lines based on the
  ** configured charset encoding.  Each Str in the list maps
  ** to a line terminated by \n, \r\n, \r, or EOF.  The Str lines
  ** themselves do not contain a trailing newline.  Empty lines
  ** are returned as the empty Str "".  Return an empty list if
  ** currently at end of stream (not null).  Throw IOErr if there
  ** is a problem reading the stream or an invalid character encoding
  ** is encountered.  This InStream is guaranteed to be closed upon
  ** return.
  **
  Str[] readAllLines() {
    try {
      res := Str[,]
      Str? line
      while ((line = readLine) != null) {
        res.add(line)
      }
      return res
    }
    finally {
      try { close } catch (Err e) { e.trace }
    }
  }

  **
  ** Read the entire stream into Str lines based on the current
  ** encoding.  Call the specified function for each line read.
  ** Each line is terminated by \n, \r\n, \r, or EOF.  The Str
  ** lines themselves do not contain a trailing newline.  Empty
  ** lines are returned as the empty Str "".  This InStream is
  ** guaranteed to be closed upon return.
  **
  Void eachLine(|Str line| f) {
    try {
      Str? line
      while ((line = readLine) != null) {
        f.call(line)
      }
    }
    finally {
      try { close } catch (Err e) { e.trace }
    }
  }

  **
  ** Read the entire stream into a Str based on the configured
  ** charset encoding.  If the normalizeNewlines flag is true,
  ** then all occurances of \r\n or \r newlines are normalized
  ** into \n.  Return "" if the stream is empty.  Throw IOErr if
  ** there is a problem reading the stream or an invalid character
  ** encoding is encountered.  This InStream is guaranteed to
  ** be closed.
  **
  virtual Str readAllStr(Bool normalizeNewlines := true) {
    buf := StrBuf()
    last := -1
    while (true) {
      ch := readChar
      if (ch < 0) break
      if (normalizeNewlines)
      {
        if (last == '\r' && ch == '\n') {
          last = -1
          continue
        }
        last = ch
        if (ch == '\r') ch = '\n'
      }

      buf.addChar(ch)
    }
    return buf.toStr
  }


//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  **
  ** Pipe bytes from this input stream to the specified output stream.
  ** If n is specified, then block until exactly n bytes have been
  ** read or throw IOErr if end of stream is reached first.  If n is
  ** null then the entire contents of this input stream are piped.  If
  ** close is true, then this input stream is guaranteed to be closed
  ** upon return (the OutStream is never closed).  Return the number
  ** of bytes piped to the output stream.
  **
  Int pipe(OutStream out, Int toPipe := -1, Bool close := true) {
    try
    {
      bufSize := chunkSize
      Buf buf := Buf.make(bufSize);
      total := 0;
      if (toPipe == -1)
      {
        while (true)
        {
          n := readBuf(buf.clear(), bufSize);
          if (n < 0) break;
          out.writeBuf(buf.flip(), buf.remaining());
          total += n;
        }
      }
      else
      {
        toPipeVal := toPipe;
        while (total < toPipeVal)
        {
          if (toPipeVal - total < bufSize) bufSize = toPipeVal - total;
          n := readBuf(buf.clear(), bufSize);
          if (n < 0) throw IOErr.make("Unexpected end of stream");
          out.writeBuf(buf.flip(), buf.remaining());
          total += n;
        }
      }
      return total;
    }
    finally
    {
      if (close) this.close
    }
  }

  **
  ** This InStream is guaranteed to be closed upon return
  **
  Void use(|InStream| f) {
    try f(this)
    finally this.close
  }

  **
  ** Read the entire stream into a 'Str:Str' of name/value pairs using the
  ** Fantom props file format.  This format is similiar but different than
  ** the Java properties file format:
  **   - Input must be UTF-8 encoded (current charset is ignored)
  **   - Name/value pairs formatted as logical line: '<name>=<value>'
  **   - Any Unicode character allowed in name or value
  **   - Leading and trailing whitespace trimmed from both name and value
  **   - Duplicate name keys within one file is an error condition
  **   - Comment to end of line is '//' if start of line or preceeded
  **     by whitespace
  **   - Block comment is '/* */' (may be nested)
  **   - Use trailing '\' to continue logical line to another actual line,
  **     any leading whitespace (space or tab char) is trimmed from beginning
  **     of continued line
  **   - Fantom Str literal escape sequences supported: '\n \r \t or \uxxxx'
  **   - The '$' character is treated as a normal character and should not be
  **     escaped, but convention is to indicate a variable in a format string
  **   - Convention is that name is lower camel case with dot separators
  **
  ** Throw IOErr if there is a problem reading the stream or an invalid
  ** props format is encountered.  This InStream is guaranteed to be closed.
  **
  ** Also see `Env.props`.
  **
  Str:Str readProps() { Props.readProps(this) }

  @NoDoc
  Str:Str[] readPropsListVals() { Props.readPropsListVals(this) }
}

**************************************************************************
** SysInStream
**************************************************************************
@NoDoc
class ProxyInStream : InStream
{
  protected InStream in
  new make(InStream in) {
    this.in = in
  }

  override Int avail() { in.avail }
  override Int read() { in.read }
  override Int skip(Int n) { in.skip(n) }
  override Int readBytes(ByteArray ba, Int off := 0, Int len := ba.size) { in.readBytes(ba, off, len) }
  override This unread(Int n) { in.unread(n) }
  override Bool close() { in.close }

  override Endian endian { set{ in.endian = it } get{ in.endian } }
  override Charset charset { set{ in.charset = it } get { in.charset } }

  override Int readChar() { in.readChar }
  override This unreadChar(Int b) { in.unreadChar(b) }
  override Int peekChar() { in.peekChar }
  override Str readChars(Int n) { in.readChars(n) }
  override Str? readLine(Int max := -1) { in.readLine(max) }
  override Str readAllStr(Bool normalizeNewlines := true) { in.readAllStr(normalizeNewlines) }
}

internal class SysInStream : InStream
{
  override Endian endian
  override Charset charset

  protected new make(Endian e, Charset c) {
    endian = e
    charset = c
  }

  static native Int toSigned(Int val, Int byteNum)

  native override Int avail()
  native override Int read()
  native override Int skip(Int n)
  native override Int readBytes(ByteArray ba, Int off := 0, Int len := ba.size)
  native override This unread(Int n)
  native override Bool close()

  //native override Int peek()
  //native override Str readUtf()
  //native override Int rChar()
  //native override This unreadChar(Int b)
  //native override Int peekChar()
  //native override Str readChars(Int n)
  //native override Str? readLine(Int max := -1)
  //native override Str readAllStr(Bool normalizeNewlines := true)
}


