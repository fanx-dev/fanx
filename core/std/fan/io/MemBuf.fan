
**************************************************************************
** MemBuf
**************************************************************************

internal class MemBuf : Buf
{
  protected ByteArray buf

  new make(Int cap) : super.privateMake() {
    size = 0
    pos = 0
    buf = ByteArray(cap)
  }

  new makeBuf(ByteArray buf, Int size := buf.size, Int pos := 0) : super.privateMake() {
    this.buf = buf
    this.size = size
    this.pos = pos
  }

  override Int size
  override Int capacity { get{ return buf.size } set{ buf.realloc(it) } }
  override Int pos

  @Operator override Int get(Int index) { buf.get(index) }
  @Operator override Buf getRange(Range range) {
    size := this.size
    s := range.startIndex(size);
    e := range.endIndex(size);
    n := (e - s + 1);
    if (n < 0) throw IndexErr.make("$range");

    a := ByteArray(n)
    a.copyFrom(buf, s, 0, n)
    return makeBuf(a)
  }

  override Buf dup() {
    size := this.size
    a := ByteArray(size)
    a.copyFrom(buf, 0, 0, size)
    return makeBuf(a)
  }

  @Operator override This set(Int index, Int byte) {
    size := this.size
    if (pos < 0) pos = size + pos;
    if (pos < 0 || pos >= size) throw IndexErr.make("$pos");
    buf.set(pos, byte)
    return this
  }
  override This trim() { this }
  override Bool close() { true }
  override This flush() { this }
  override Endian endian {
    set { out.endian = it; in.endian = it }
    get { out.endian }
  }
  override Charset charset {
    set { out.charset = it; in.charset = it }
    get { out.charset }
  }
  override This fill(Int byte, Int times) { buf.fill(byte, times); return this }

  private OutStream createOut() { MemOutStream(this) }
  private InStream createIn() { MemInStream(this) }

  once override OutStream out() { createOut }
  once override InStream in() { createIn }

  protected override Void writeTo(OutStream out, Int len) {
    if (pos + len > size) throw IOErr("Not enough bytes to write")
    out.writeByteArray(buf, pos, len)
    pos += len
  }
  protected override Int readFrom(InStream in, Int len) {
    grow(pos+len)
    a := in.readByteArray(buf, pos, len)
    pos += a
    return a
  }

  protected Void grow(Int cap) {
    if (cap >= capacity) return
    c := cap.max(capacity*2)
    capacity = c
  }

  override Bool isImmutable() { false }

  override Buf toImmutable() {
    old := buf
    osize := size
    opos := pos
    this.buf = ByteArray(0)
    this.size = 0
    this.pos = 0
    return ConstMemBuf.makeBuf(old, osize, opos)
  }
}

internal class ConstMemBuf : Buf
{
  protected ByteArray buf

  protected ReadonlyErr err() {
    throw ReadonlyErr()
  }

  new makeBuf(ByteArray buf, Int size := buf.size, Int pos := 0) : super.privateMake() {
    this.buf = buf
    this.size = size
    this.pos = pos
  }

  override Int size { private set { err } }
  override Int capacity { get{ return buf.size } set{ err } }
  override Int pos { set { err } }

  @Operator override Int get(Int index) { buf.get(index) }
  @Operator override Buf getRange(Range range) {
    size := this.size
    s := range.startIndex(size);
    e := range.endIndex(size);
    n := (e - s + 1);
    if (n < 0) throw IndexErr.make("$range");

    a := ByteArray(n)
    a.copyFrom(buf, s, 0, n)
    return makeBuf(a)
  }

  override Buf dup() {
    size := this.size
    a := ByteArray(size)
    a.copyFrom(buf, 0, 0, size)
    return makeBuf(a)
  }

  @Operator override This set(Int index, Int byte) {
    err
    return this
  }
  override This trim() { this }
  override Bool close() { true }
  override This flush() { this }
  override Endian endian {
    set { err }
    get { out.endian }
  }
  override Charset charset {
    set { err }
    get { out.charset }
  }
  override This fill(Int byte, Int times) { err; return this }

  private InStream createIn() { ConstMemInStream(this) }

  override OutStream out() { throw err }
  once override InStream in() { createIn }

  protected override Void writeTo(OutStream out, Int len) { out.writeByteArray(buf, pos, len) }
  protected override Int readFrom(InStream in, Int len) { throw err }

  override Bool isImmutable() { true }

  override Buf toImmutable() { return this }
}

internal class MemOutStream : OutStream {
  override Endian endian
  override Charset charset
  protected MemBuf buf

  new make(MemBuf buf) {
    endian = Endian.big
    charset = Charset.defVal
    this.buf = buf
  }

  override This write(Int byte) {
    buf.grow(buf.pos+1)
    buf.buf[buf.pos] = byte
    ++buf.pos
    if (buf.pos > buf.size) buf.size = buf.pos
    return this
  }
  override This writeByteArray(ByteArray ba, Int off := 0, Int len := ba.size) {
    buf.grow(buf.pos+len)
    buf.buf.copyFrom(ba, off, buf.pos, len)
    buf.pos += len
    if (buf.pos > buf.size) buf.size = buf.pos
    return this
  }
  override This sync() { this }
  override This flush() { this }
  override Bool close() { true }
}

internal class MemInStream : InStream {
  override Endian endian
  override Charset charset
  protected MemBuf buf

  new make(MemBuf buf) {
    endian = Endian.big
    charset = Charset.defVal
    this.buf = buf
  }

  override Int avail() {
    buf.size - buf.pos
  }
  override Int r() {
    if (buf.pos >= buf.size) return -1
    return buf.buf[buf.pos++]
  }
  override Int skip(Int n) {
    pos := buf.pos + n
    if (pos > buf.size) {
      pos = buf.size
      n = pos - buf.pos
    }
    buf.pos = pos
    return n
  }
  override Int readByteArray(ByteArray ba, Int off := 0, Int len := ba.size) {
    m := avail
    if (m <= 0) return 0
    len = len.min(m)
    ba.copyFrom(buf.buf, buf.pos, off, len)
    buf.pos += len
    return len
  }
  override This unread(Int n) {
    if (buf.pos == 0) throw UnsupportedErr("$buf")
    --buf.pos
    buf.buf[buf.pos] = n
    return this
  }
  override Bool close() { true }

  override Int peek() {
    if (buf.pos+1 >= buf.size) return -1
    return buf.buf[buf.pos+1]
  }

  //override Int peekChar() {  }
}


internal class ConstMemInStream : InStream {
  override Endian endian
  override Charset charset
  protected ConstMemBuf buf
  protected Int pos

  new make(ConstMemBuf buf) {
    endian = Endian.big
    charset = Charset.defVal
    this.buf = buf
    pos = 0
  }

  override Int avail() {
    buf.size - pos
  }
  override Int r() {
    if (pos >= buf.size) return -1
    return buf.buf[pos++]
  }
  override Int skip(Int n) {
    pos := this.pos + n
    if (pos > buf.size) {
      pos = buf.size
      n = pos - this.pos
    }
    this.pos = pos
    return n
  }
  override Int readByteArray(ByteArray ba, Int off := 0, Int len := ba.size) {
    m := avail
    if (m <= 0) return 0
    len = len.min(m)
    ba.copyFrom(buf.buf, this.pos, off, len)
    this.pos += len
    return len
  }
  override This unread(Int n) {
    if (this.pos == 0) throw UnsupportedErr("$buf")
    --this.pos
    buf.buf[this.pos] = n
    return this
  }
  override Bool close() { true }

  override Int peek() {
    if (this.pos+1 >= buf.size) return -1
    return buf.buf[this.pos+1]
  }

  //override Int peekChar() {  }
}