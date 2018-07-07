
**************************************************************************
** MemBuf
**************************************************************************
@NoDoc
class MemBuf : Buf
{
  protected ByteArray buf

  new make(Int cap) : super.privateMake() {
    buf = ByteArray(cap)
    &size = 0
    &pos = 0
  }

  new makeBuf(ByteArray buf, Int size := buf.size, Int pos := 0) : super.privateMake() {
    this.buf = buf
    this.&size = size
    this.pos = pos
  }

  override Int size {
    set {
      if (it > capacity) {
        capacity = it
      }
      &size = it
    }
  }
  override Int capacity { get{ return buf.size } set{ buf.realloc(it) } }
  override Int pos {
    set {
      if (it > size) {
        size = it
      }
      &pos = it
    }
  }

  override Int getBytes(Int pos, ByteArray dst, Int off, Int len) {
    dst.copyFrom(buf, pos, off, len)
    return len
  }
  override Void setBytes(Int pos, ByteArray src, Int off, Int len) {
    buf.copyFrom(src, off, pos, len)
  }

  override Int getByte(Int index) { buf.get(index) }

  override Void setByte(Int index, Int byte) {
    buf.set(pos, byte)
  }

  override Bool close() { true }
  override This sync() { this }
  override Endian endian {
    set { in.endian = it; out.endian = it }
    get { out.endian }
  }
  override Charset charset {
    set { in.charset = it; out.charset = it }
    get { out.charset }
  }

  override This fill(Int byte, Int times) { buf.fill(byte, times); return this }

  protected override Void pipeTo(OutStream out, Int len) {
    if (pos + len > size) throw IOErr("Not enough bytes to write")
    out.writeBytes(buf, pos, len)
    pos += len
  }
  protected override Int pipeFrom(InStream in, Int len) {
    if (capacity < pos+len) {
      capacity = pos + len
    }
    a := in.readBytes(buf, pos, len)
    if (a > 0) {
      pos += a
    }
    return a
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
    this.&endian = Endian.big
    this.&charset = Charset.defVal
  }

  override Int size { private set { err } }
  override Int capacity { get{ return buf.size } set{ err } }
  override Int pos { set { err } }

  override Int getBytes(Int pos, ByteArray dst, Int off, Int len) {
    dst.copyFrom(buf, pos, off, len)
    return len
  }
  override Void setBytes(Int pos, ByteArray src, Int off, Int len) {
    err
  }

  override Int getByte(Int index) { buf.get(index) }
  override Void setByte(Int index, Int byte) { err }

  override This trim() { this }
  override Bool close() { true }
  override This sync() { this }
  override Endian endian {
    set { err }
  }
  override Charset charset {
    set { err }
  }

  override This fill(Int byte, Int times) { err; return this }

  override OutStream out() { throw err }
  override InStream in() { ConstMemInStream(this)  }

  protected override Void pipeTo(OutStream out, Int len) {
    if (pos + len > size) throw IOErr("Not enough bytes to write")
    out.writeBytes(buf, pos, len)
  }
  protected override Int pipeFrom(InStream in, Int len) { throw err }

  override Bool isImmutable() { true }

  override Buf toImmutable() { return this }
}

internal class ConstMemInStream : InStream {
  override Endian endian
  override Charset charset
  protected ConstMemBuf buf
  protected Int pos

  new make(ConstMemBuf buf) {
    endian = buf.endian
    charset = buf.charset
    this.buf = buf
    pos = 0
  }

  override Int avail() {
    buf.size - pos
  }
  override Int read() {
    if (pos >= buf.size) return -1
    return buf[pos++]
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
  override Int readBytes(ByteArray ba, Int off := 0, Int len := ba.size) {
    m := avail
    if (m <= 0) return 0
    len = len.min(m)
    buf.getBytes(buf.pos, ba, off, len)
    this.pos += len
    return len
  }
  override This unread(Int n) {
    if (this.pos == 0) throw UnsupportedErr("$buf")
    --this.pos
    buf[this.pos] = n
    return this
  }
  override Bool close() { true }

  override Int peek() {
    if (this.pos+1 >= buf.size) return -1
    return buf[this.pos+1]
  }

}