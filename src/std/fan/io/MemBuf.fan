//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-07-14  Jed Young
//

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

  protected override ByteArray? unsafeArray() { buf }

  override Int size {
    set {
      if (it > capacity) {
        capacity = it
      }
      &size = it
    }
  }
  override Int capacity { get{ return buf.size }
    set {
      if (it < size) throw ArgErr("capacity < size")
      buf = buf.realloc(it)
    }
  }
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
    buf.set(index, byte)
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
  /*
  override This fill(Int byte, Int times) {
    if (capacity < size+times) capacity = size+times
    buf.fill(byte, times); return this
  }
  */

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
    //opos := pos
    this.buf = ByteArray(0)
    this.size = 0
    this.pos = 0
    return ConstBuf.makeBuf(old, osize, endian, charset)
  }

  override File toFile(Uri uri) {
    return MemFile(toImmutable, uri)
  }
}

