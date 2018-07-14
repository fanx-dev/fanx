//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-07-14  Jed Young
//

class StrStream {
    static extension InStream in(Str str) {
      StrInStream(str)
    }

    static extension OutStream out(StrBuf buf) {
      StrOutStream(buf)
    }

    static extension Buf toBuf(Str str, Charset charset := Charset.utf8) {
      buf := MemBuf(str.size * 2)
      buf.charset = charset
      buf.print(str)
      return buf.flip
    }
}

internal class StrInStream : InStream {
  override Endian endian := Endian.big
  override Charset charset := Charset.defVal

  private Str str
  private Int pos
  private Int size
  private Int[]? pushback

  protected new make(Str str) {
    this.str = str
    size = str.size
    pos = 0
    pushback = [,]
  }

  override Int avail() { size - pos }
  override Int read() { throw UnsupportedErr("Binary read on Str.in") }
  override Int skip(Int n) { pos += n }
  override Int readBytes(ByteArray ba, Int off := 0, Int len := ba.size) { throw UnsupportedErr("Binary read on Str.in") }
  override This unread(Int n) { throw UnsupportedErr("Binary read on Str.in") }
  override Bool close() { true }

  override Int readChar() {
    if (pushback != null && pushback.size > 0)
        return pushback.pop
    if (pos >= size)
        return -1
    return str.get(pos++)
  }

  override This unreadChar(Int b) {
    if (pushback == null)
        pushback = List<Int>.make(8)
    pushback.push(b)
    return this
  }
}

internal class StrOutStream : OutStream {
  override Endian endian := Endian.big
  override Charset charset := Charset.defVal

  private StrBuf buf

  protected new make(StrBuf str) {
    buf = str
  }

  override This write(Int byte) { throw UnsupportedErr("Binary write on StrBuf.out") }
  override This writeBytes(ByteArray ba, Int off := 0, Int len := ba.size) { throw UnsupportedErr("Binary write on StrBuf.out") }
  override This sync() { this }
  override This flush() { this }
  override Bool close() { true }

  override This writeChar(Int ch) {
    buf.addChar(ch)
    return this
  }

  override This writeChars(Str str, Int off := 0, Int len := str.size-off) {
    buf.addStr(str, off, len)
    return this
  }
}