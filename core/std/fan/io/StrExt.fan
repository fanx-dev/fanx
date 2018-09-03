//
// Copyright (c) 2018, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-07-14  Jed Young
//

**
** Str Extension
**
class StrExt {
  **
  ** Create an input stream to read characters from the this string.
  ** The input stream is designed only to read character data.  Attempts
  ** to perform binary reads will throw UnsupportedErr.
  **
  static extension InStream in(Str str) {
    StrInStream(str)
  }

  **
  ** Create an output stream to append characters to this string
  ** buffer.  The output stream is designed to write character data,
  ** attempts to do binary writes will throw UnsupportedErr.
  **
  static extension OutStream out(StrBuf buf) {
    StrOutStream(buf)
  }

  **
  ** Get this string encoded into a buffer of bytes.
  **
  static extension Buf toBuf(Str str, Charset charset := Charset.utf8) {
    buf := MemBuf(str.size * 2)
    buf.charset = charset
    buf.print(str)
    return buf.flip
  }

  **
  ** split by any char
  **
  extension static Str[] splitAny(Str str, Str sp, Bool normalize := true) {
    res := Str[,]
    buf := StrBuf()
    for (i:=0; i<str.size; ++i) {
      c := str[i]
      if (sp.containsChar(c)) {
        part := buf.toStr
        if (normalize) part = part.trim
        if (part.size > 0 || !normalize) {
          res.add(part)
          buf.clear()
        }
      }
      else {
        buf.addChar(c)
      }
    }
    return res
  }

  **
  ** split by Str
  **
  extension static Str[] splitBy(Str str, Str sp, Int max := Int.maxVal) {
    if (sp.size == 0) {
      return [str]
    }
    res := Str[,]
    while (true) {
      if (res.size == max-1) {
        res.add(str)
        break
      }
      i := str.index(sp)
      if (i == null) {
        res.add(str)
        break
      }

      part := str[0..<i]
      res.add(part)

      start := i + sp.size
      if (start < str.size) {
        str = str[start..-1]
      } else {
        str = ""
      }
    }

    return res
  }

  **
  ** get the sub string between begin and end
  **
  extension static Str? extract(Str str, Str? begin, Str? end) {
    s := 0
    if (begin != null) {
      p0 := str.index(begin)
      if (p0 == null) {
        return null
      }
      s = p0 + begin.size
    }

    e := str.size
    if (end != null) {
      p0 := str.index(end, s)
      if (p0 == null) {
        return null
      }
      e = p0
    }
    return str[s..<e]
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