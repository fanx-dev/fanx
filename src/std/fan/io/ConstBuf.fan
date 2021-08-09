//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-07-14  Jed Young
//


**************************************************************************
** Const Buf
**************************************************************************
internal rtconst class ConstBuf : Buf
{
  protected Array<Int8> buf

  protected Err err() { ReadonlyErr() }

  new makeBuf(Array<Int8> buf, Int size, Endian e, Charset c) : super.privateMake() {
    this.buf = buf
    this.&size = size
    this.&endian = e
    this.&charset = c
  }

  protected override Array<Int8>? unsafeArray() { buf }

  override Int size { private set { throw err } }
  override Int capacity { get{ throw err } set{ throw err } }
  override Int pos { set { throw err } get { 0 } }

  override Int getBytes(Int pos, Array<Int8> dst, Int off, Int len) {
    Array.arraycopy(buf, pos, dst, off, len)
    return len
  }
  override Void setBytes(Int pos, Array<Int8> src, Int off, Int len) {
   throw err
  }

  override Int getByte(Int index) {
    Int8 b = buf.get(index)
    //signed to unsigned
    return b.and(0xFF)
  }
  override Void setByte(Int index, Int byte) { throw err }

  override This trim() { throw err }
  override Bool close() { true }
  override This sync() { throw err }
  override Endian endian {
    set { throw err }
  }
  override Charset charset {
    set { throw err }
  }

  override This fill(Int byte, Int times) { throw err }

  override OutStream out() { throw err }
  override InStream in() { ConstBufInStream(this)  }
  internal override InStream privateIn() { throw err }

  protected override Void pipeTo(OutStream out, Int len) {
    if (pos + len > size) throw IOErr("Not enough bytes to write")
    out.writeBytes(buf, pos, len)
  }
  protected override Int pipeFrom(InStream in, Int len) { throw err }

  override Bool isImmutable() { true }

  override Buf toImmutable() { return this }

  override File toFile(Uri uri) {
    return MemFile(this, uri)
  }
}
**************************************************************************
**************************************************************************
internal class ConstBufInStream : InStream {
  override Endian endian
  override Charset charset
  protected ConstBuf buf
  protected Int pos

  new make(ConstBuf buf) {
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
    return buf.getByte(pos++)
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
  override Int readBytes(Array<Int8> ba, Int off := 0, Int len := ba.size) {
    m := avail
    if (m <= 0) return -1
    len = len.min(m)
    buf.getBytes(pos, ba, off, len)
    this.pos += len
    return len
  }
  override This unread(Int n) {
    if (pos > 0 && buf[pos-1] == n) {
      pos--
    }
    else {
      throw buf.err
    }
    return this
  }
  //override Bool close() { true }

  override Int peek() {
    if (this.pos >= buf.size) return -1
    return buf.getByte(this.pos+1)
  }
}

**************************************************************************
** Mem File
**************************************************************************
internal const class MemFile : File {
    const ConstBuf buf
    const TimePoint ts

    new makeBuf(Array<Int8> buf, Str uri) : super.privateMake(uri.toUri) {
      this.buf = ConstBuf.makeBuf(buf, buf.size, Endian.big, Charset.utf8)
      this.ts = TimePoint.now
    }

    new make(ConstBuf buf, Uri uri) : super.privateMake(uri) {
      this.buf = buf
      this.ts = TimePoint.now
    }

    private Err err() { UnsupportedErr("ConstBufFile") }

    override Bool exists() { true }
    override Int size() { buf.size }
    override TimePoint? modified { get { ts } set { throw err }}
    override Str? osPath() { null }
    override File[] list() { List.defVal }
    override File normalize() { this }
    override File create() { throw err }
    override File moveTo(File to) { throw err }
    override Void delete() { throw err }
    override File deleteOnExit() { throw err }
    override Buf open(Str mode := "rw") { throw err }
    override Buf mmap(Str mode := "rw", Int pos := 0, Int size := this.size) { throw err }
    override InStream in(Int bufferSize := 4096) { return buf.in }
    override OutStream out(Bool append := false, Int bufferSize := 4096) { throw err }
}