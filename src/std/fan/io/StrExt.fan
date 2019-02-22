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

  **
  ** Return this string with the first character converted
  ** uppercase.  The case conversion is for ASCII only.
  ** Also see `decapitalize` and `localeCapitalize`.
  **
  ** Example:
  **   "foo".capitalize => "Foo"
  **
  extension static Str capitalize(Str self) {
    if (self.size > 0)
    {
      fch := self.get(0);
      if ('a' <= fch && fch <= 'z') {
        sb := StrBuf()
        sb.addChar(fch.upper)
        for (i:=1; i<self.size; ++i) {
          sb.addChar(self.get(i))
        }
        return sb.toStr
      }
    }
    return self;
  }

  **
  ** Return this string with the first character converted
  ** lowercase.  The case conversion is for ASCII only.
  ** Also see `capitalize` and `localeDecapitalize`.
  **
  ** Example:
  **   "Foo".decapitalize => "foo"
  **
  extension static Str decapitalize(Str self) {
    if (self.size > 0)
    {
      fch := self.get(0);
      if ('A' <= fch && fch <= 'Z') {
        sb := StrBuf()
        sb.addChar(fch.lower)
        for (i:=1; i<self.size; ++i) {
          sb.addChar(self.get(i))
        }
        return sb.toStr
      }
    }
    return self;
  }

  **
  ** Translate a programmer name like "fooBar" to "Foo Bar".
  ** This method capitalizes the first letter, then walks
  ** the string looking for ASCII capital letters and inserting
  ** a space.  Any underbars are replaced with a space.  Also
  ** see `fromDisplayName`.
  **
  ** Examples:
  **   "foo".toDisplayName       ->  "Foo
  **   "fooBar".toDisplayName    ->  "Foo Bar"
  **   "fooBarBaz".toDisplayName ->  "Foo Bar Baz"
  **   "foo33".toDisplayName     ->  "Foo 33"
  **   "fooXML".toDisplayName    ->  "Foo XML"
  **   "Foo".toDisplayName       ->  "Foo"
  **   "foo_bar".toDisplayName   ->  "Foo Bar"
  **
  extension static Str toDisplayName(Str self) {
    if (self.size() == 0) return "";
    StrBuf s = StrBuf(self.size()+4);

    // capitalize first word
    c := self.get(0);
    if ('a' <= c && c <= 'z') c = c.upper;
    s.addChar(c);

    // insert spaces before every capital
    last := c;
    for (i:=1; i<self.size(); ++i)
    {
      c = self.get(i);
      if ('A' <= c && c <= 'Z' && last != '_')
      {
        next := i+1 < self.size() ? self.get(i+1) : 'Q';
        if (!('A' <= last && last <= 'Z' ) || !('A' <= next && next <= 'Z'))
          s.addChar(' ');
      }
      else if ('a' <= c && c <= 'z')
      {
        if (('0' <= last && last <= '9')) { s.addChar(' '); c = c.upper; }
        else if (last == '_') c = c.upper;
      }
      else if ('0' <= c && c <= '9')
      {
        if (!('0' <= last && last <= '9')) s.addChar(' ');
      }
      else if (c == '_')
      {
        s.addChar(' ');
        last = c;
        continue;
      }
      s.addChar(c);
      last = c;
    }
    return s.toStr();
  }

  **
  ** Translate a display name like "Foo Bar" to a programmatic
  ** name "fooBar".  This method decapitalizes the first letter,
  ** then walks the string removing spaces.  Also see `toDisplayName`.
  **
  ** Examples:
  **   "Foo".fromDisplayName         ->  "foo"
  **   "Foo Bar".fromDisplayName     ->  "fooBar"
  **   "Foo Bar Baz".fromDisplayName ->  "fooBarBaz"
  **   "Foo 33 Bar".fromDisplayName  ->  "foo33Bar"
  **   "Foo XML".fromDisplayName     ->  "fooXML"
  **   "foo bar".fromDisplayName     ->  "fooBar"
  **
  extension static Str fromDisplayName(Str self) {
    if (self.size() == 0) return "";
    s := StrBuf(self.size());
    c := self.get(0);
    c2 := self.size() == 1 ? 0 : self.get(1);
    if ('A' <= c && c <= 'Z' && !('A' <= c2 && c2 <= 'Z')) c = c.lower;
    s.addChar(c);
    last := c;
    for (i:=1; i<self.size(); ++i)
    {
      c = self.get(i);
      if (c != ' ')
      {
        if (last == ' ' && 'a' <= c && c <= 'z') c = c.upper
        s.addChar(c);
      }
      last = c;
    }
    return s.toStr();
  }

  **
  ** If size is less than width, then add spaces to the right
  ** to create a left justified string.  Also see `padr`.
  **
  ** Examples:
  **   "xyz".justl(2) => "xyz"
  **   "xyz".justl(4) => "xyz "
  **
  extension static Str justl(Str self, Int width) { padr(self, width, ' ') }

  **
  ** If size is less than width, then add spaces to the left
  ** to create a right justified string.  Also see `padl`.
  **
  ** Examples:
  **   "xyz".justr(2) => "xyz"
  **   "xyz".justr(4) => " xyz"
  **
  extension static Str justr(Str self, Int width) { padl(self, width, ' ') }

  **
  ** If size is less than width, then add the given char to the
  ** left to achieve the specified width.  Also see `justr`.
  **
  ** Examples:
  **   "3".padl(3, '0') => "003"
  **   "123".padl(2, '0') => "123"
  **
  extension static Str padl(Str self, Int width, Int ch := ' ') {
    w := width;
    if (self.size() >= w) return self;
    c := ch;
    s := StrBuf(w);
    for (i:=self.size(); i<w; ++i) s.addChar(c);
    s.add(self);
    return s.toStr;
  }

  **
  ** If size is less than width, then add the given char to
  ** the left to acheive the specified with.  Also see `justl`.
  **
  ** Examples:
  **   "xyz".padr(2, '.') => "xyz"
  **   "xyz".padr(5, '-') => "xyz--"
  **
  extension static Str padr(Str self, Int width, Int ch := ' ') {
    w := width;
    if (self.size() >= w) return self;
    c := ch;
    s := StrBuf(w);
    s.add(self);
    for (i:=self.size(); i<w; ++i) s.addChar(c);
    return s.toStr;
  }

  **
  ** Reverse the contents of this string.
  **
  ** Example:
  **   "stressed".reverse => "desserts"
  **
  extension static Str reverse(Str self) {
    if (self.size() < 2) return self;
    s := StrBuf(self.size());
    for (i:=self.size()-1; i>=0; --i)
      s.addChar(self.get(i));
    return s.toStr();
  }
  **
  ** Count the number of newline combinations: "\n", "\r", or "\r\n".
  **
  extension static Int numNewlines(Str self) {
    numLines := 0;
    len := self.size();
    for (i:=0; i<len; ++i)
    {
      c := self.get(i);
      if (c == '\n') numLines++;
      else if (c == '\r')
      {
        numLines++;
        if (i+1<len && self.get(i+1) == '\n') i++;
      }
    }
    return numLines;
  }

  **
  ** Split this string into individual lines where lines are
  ** terminated by \n, \r\n, or \r.  The returned strings
  ** do not contain the newline character.
  **
  ** Examples:
  **   "x\ny".splitLines  => ["x", "y"]
  **   "".splitLines      => [""]
  **   "x".splitLines     => ["x"]
  **   "\r\n".splitLines  => ["", ""]
  **   "x\n".splitLines   => ["x", ""]
  **
  extension static Str[] splitLines(Str self) {
    lines := List<Str>.make(16);
    len := self.size();
    s := 0;
    for (i:=0; i<len; ++i)
    {
      c := self.get(i);
      if (c == '\n' || c == '\r')
      {
        lines.add(self[s..<i]);
        s = i+1;
        if (c == '\r' && s < len && self.get(s) == '\n') { i++; s++; }
      }
    }
    lines.add(self[s..<len]);
    return lines;
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