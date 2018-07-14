//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-07-14  Jed Young
//

internal class BufOutStream : OutStream {
  override Endian endian
  override Charset charset
  protected Buf buf

  new make(Buf buf) {
    endian = Endian.big
    charset = Charset.defVal
    this.buf = buf
  }

  override This write(Int byte) {
    if (buf.capacity < buf.pos+1) {
      buf.capacity = buf.capacity * 2  + 1
    }
    buf.setByte(buf.pos, byte)
    ++buf.pos
    if (buf.pos > buf.size) buf.size = buf.pos
    return this
  }
  override This writeBytes(ByteArray ba, Int off := 0, Int len := ba.size) {
    if (buf.capacity < buf.pos+len) {
      buf.capacity = buf.capacity * 2  + len
    }
    buf.setBytes(buf.pos, ba, off, len)
    buf.pos += len
    if (buf.pos > buf.size) buf.size = buf.pos
    return this
  }

  //Buf stream is not buffered
  override This writeChars(Str str, Int off := 0, Int len := str.size-off) {
    ba := ByteArray(str.size*3)
    pos := 0
    for (i:=0; i<len; ++i) {
      ch := str[i+off]
      n := charset.encodeArray(ch, ba, pos)
      pos += n
      if (pos > ba.size-8 && i < len-1) {
        this.writeBytes(ba, 0, pos)
        pos = 0
      }
    }
    if (pos > 0) {
      this.writeBytes(ba, 0, pos)
    }
    return this
  }
  override This sync() { buf.sync; return this }
  override This flush() { this }
  override Bool close() { true }
}

internal class BufInStream : InStream {
  override Endian endian
  override Charset charset
  protected Buf buf

  new make(Buf buf) {
    endian = Endian.big
    charset = Charset.defVal
    this.buf = buf
  }

  override Int avail() {
    buf.size - buf.pos
  }
  override Int read() {
    if (buf.pos >= buf.size) return -1
    return buf.getByte(buf.pos++)
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
  override Int readBytes(ByteArray ba, Int off := 0, Int len := ba.size) {
    m := avail
    if (m <= 0) return 0
    len = len.min(m)
    buf.getBytes(buf.pos, ba, off, len)
    buf.pos += len
    return len
  }
  override This unread(Int n) {
    if (buf.pos == 0) throw UnsupportedErr("$buf")
    --buf.pos
    buf.setByte(buf.pos, n)
    return this
  }
  override Bool close() { true }

  override Int peek() {
    if (buf.pos+1 >= buf.size) return -1
    return buf.getByte(buf.pos)
  }

}

