//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Dec 05  Brian Frank  Creation
//

using sys::Int32 as Char

**
** Str represents a sequence of Unicode characters.
**
native const final class Str
{
  private readonly Array<Int8> utf8
  private const Int charLen
  private const Int hashCode

  **
  ** Default value is "".
  **
  const static Str defVal := ""

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  private new make(Array<Int8> utf8) {
    this.utf8 = utf8
    hashValue := 0
    charCount := 0
    for (i:=0; i<utf8.size; ++i) {
      ch := utf8[i]
      if (ch.and(0xC0) != 0x80) {
        ++charCount
      }
      hashValue = ch + 31 * hashValue
    }
    this.charLen = charCount
    this.hashCode = hashValue
  }

  private new makeWithSize(Array<Int8> utf8, Int charLen) {
    this.utf8 = utf8
    //this.byteLen = i
    this.charLen = charLen

    hashValue := 0
    for (j:=0; j<byteLen; ++j) {
        hashValue = utf8[j] + 31 * hashValue
    }
    this.hashCode = hashValue
  }

  **
  ** allocType: 0:copy, 1:static, 2:move
  **
  static Str fromCStr(Ptr<Int8> utf8, Int byteLen := -1) {
    if (byteLen == -1) {
      byteLen = Libc.strlen(utf8)
    }

    array := Array<Int8>(byteLen)
    for (i:=0; i<byteLen; ++i) {
      array[i] = utf8[i]
    }
    return make(array)
  }

  **
  ** Construct a string from a list of unicode code points.
  ** Also see `chars`.
  **
  static Str fromChars(Array<Char> charPtr, Int offset := 0, Int len := charPtr.size) {
    if (len == 0) return ""
    
    Array<Int8> out := Array<Int8>(len * 4)
    i := 0
    for (k := offset; k<len; ++k) {
      c := charPtr[k]
      //echo("encode1 $c")
      if (c <= 0x007F) {
        out[i] = c
        ++i
      }
      else if (c <= 0x07FF) {
        out[i] = c.shiftr(6).and(0x1F).or(0xC0)
        ++i
        out[i] = c.shiftr(0).and(0x3F).or(0x80)
        ++i
      }
      else if (c <= 0xFFFF) {
        out[i] = c.shiftr(12).and(0x0F).or(0xE0)
        ++i
        out[i] = c.shiftr(6).and(0x3F).or(0x80)
        ++i
        out[i] = c.shiftr(0).and(0x3F).or(0x80)
        ++i
        //echo("encode ${out[i-3]}, ${out[i-2]}, ${out[i-1]}")
      }
      else if (c <= 0x10FFFF) {
        out[i] = c.shiftr(18).and(0x07).or(0xF0)
        ++i
        out[i] = c.shiftr(12).and(0x3F).or(0x80)
        ++i
        out[i] = c.shiftr(6).and(0x3F).or(0x80)
        ++i
        out[i] = c.shiftr(0).and(0x3F).or(0x80)
        ++i
      }
      else {
        throw IOErr("Invalid UTF-8 encoding")
      } 
    }

    utf8 := Array.realloc(out, i)
    return makeWithSize(utf8, len)
  }

  **
  ** Get the byte at postion
  **
  Int getByte(Int i) {
    c := utf8[i]
    return 0xff.and(c)
  }

  **
  ** size of utf8
  **
  Int byteLen() { utf8.size }

//////////////////////////////////////////////////////////////////////////
// Obj Overrides
//////////////////////////////////////////////////////////////////////////

  **
  ** Return true if a Str with exact same char sequence.
  **
  override Bool equals(Obj? obj) {
    that := obj as Str
    if (that == null) return false
    if (this.size != that.size) return false

    for (i:=0; i<byteLen; ++i)
    {
      if (getByte(i) != that.getByte(i)) return false
    }
    return true
  }

  **
  ** Convenience for 'compareIgnoreCase(s) == 0'.
  ** Only ASCII character case is taken into account.
  ** See `localeCompare` for localized case insensitive
  ** comparisions.
  **
  Bool equalsIgnoreCase(Str s) {
    a := this
    b := s
    if (a == b) return true;

    an := a.byteLen
    bn := b.byteLen
    if (an != bn) return false;

    for (i:=0; i<an; ++i)
    {
      ac := a.getByte(i);
      bc := b.getByte(i);
      if ('A' <= ac && ac <= 'Z') ac = ac.or(0x20)
      if ('A' <= bc && bc <= 'Z') bc = bc.or(0x20)
      if (ac != bc) return false;
    }
    return true;
  }

  **
  ** Compare based on Unicode character values.  Case is not
  ** not taken into account - also see `compareIgnoreCase`
  ** and `localeCompare`.
  **
  ** Examples:
  **   "a".compare("b")    =>  -1
  **   "hi".compare("hi")  =>  0
  **   "hi".compare("HI")  =>  1
  **   "b".compare("a")    =>  1
  **
  override Int compare(Obj obj) {
    that := (Str)obj
    i := 0
    while (i < this.byteLen && i < that.byteLen) {
      if (getByte(i) == that.getByte(i)) {
        ++i
        continue
      }
      return getByte(i) - that.getByte(i)
    }
    return this.size - that.size
  }

  **
  ** Compare two strings without regard to case and return -1, 0, or 1
  ** if this string is less than, equal to, or greater than the specified
  ** string.  Only ASCII character case is taken into account.
  ** See `localeCompare` for localized case insensitive comparisions.
  **
  ** Examples:
  **   "a".compareIgnoreCase("b")    =>  -1
  **   "hi".compareIgnoreCase("HI")  =>  0
  **   "b".compareIgnoreCase("a")    =>  1
  **
  Int compareIgnoreCase(Str s) {
    a := this
    b := s
    if (a == b) return 0;

    an := a.byteLen
    bn := b.byteLen

    for (i:=0; i<an && i<bn; ++i)
    {
      ac := a.getByte(i);
      bc := b.getByte(i);
      if ('A' <= ac && ac <= 'Z') ac = ac.or(0x20)
      if ('A' <= bc && bc <= 'Z') bc = bc.or(0x20)
      if (ac != bc) return ac < bc ? -1 : +1;
    }

    if (an == bn) return 0;
    return an < bn ? -1 : +1;
  }

  **
  ** The hash for a Str is platform dependent.
  **
  override Int hash() { hashCode }

  **
  ** Return this.
  **
  override Str toStr() { this }

  **
  ** Return this.  This method is used to enable 'toLocale' to
  ** be used with duck typing across most built-in types.
  **
  //Str toLocale()

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  **
  ** Return if 'size() == 0'.
  **
  Bool isEmpty() { size == 0 }

  **
  ** Return number of characters in this string.
  **
  Int size() { charLen }

  **
  ** Internalize this Str such that two strings which are equal
  ** via the '==' operator will have the same reference such that
  ** '===' will be true.
  **
  @NoDoc
  native Str intern()

  **
  ** Return if this Str starts with the specified Str.
  **
  Bool startsWith(Str s) {
    if (s.byteLen > this.byteLen) return false
    for (i:=0; i<s.byteLen; ++i) {
      if (s.getByte(i) != this.getByte(i)) return false
    }
    return true
  }

  **
  ** Return if this Str ends with the specified Str.
  **
  Bool endsWith(Str s) {
    if (s.byteLen > this.byteLen) return false
    offset := byteLen - s.byteLen
    for (i:=0; i<s.byteLen; ++i) {
      if (s.getByte(i) != this.getByte(offset+i)) return false
    }
    return true
  }

  **
  ** Return the first occurance of the specified substring searching
  ** forward, starting at the specified offset index. Return -1 if no
  ** occurences are found.
  **
  ** Examples:
  **   "abcabc".index("b")     => 1
  **   "abcabc".index("b", 1)  => 1
  **   "abcabc".index("b", 3)  => 4
  **   "abcabc".index("x")     => -1
  **
  Int find(Str s, Int offset := 0) {
    if (s.size == 0) return 0
    if (offset < 0) offset += size
    if (s.size > this.size-offset) return -1

    if (s.size > 10 && this.size > 20) {
      return kmpFindIndex(this, s, offset)
    }

    byteOffset := toByteIndex(offset)
    len := s.byteLen
    end := this.byteLen-s.byteLen
    charCount := offset
    for (i:=byteOffset; i<=end; ++i) {
      ch := getByte(i)
      if (ch.and(0xC0) == 0x80) {
        continue
      }
      else {
        ++charCount
      }
      match := true
      for (j:=0; j<len; ++j) {
        if (getByte(i+j) != s.getByte(j)) {
          match = false
          break
        }
      }
      if (match) return charCount-1
    }
    return -1
  }

  private static Array<Int8> kmpNext(Str t) {
    next := Array<Int8>(t.byteLen)
    i := 0
    next[0] = -1
    j := -1
    while(i < t.byteLen-1) {
      if(j == -1 || t.getByte(i) == t.getByte(j)) {
        ++i;
        ++j;
        if (t.getByte(i) != t.getByte(j)) next[i] = j;
        else next[i] = next[j];
      }
      else
        j = next[j];
    }
    return next
  }

  **
  ** D.E.Knuth V.R.Pratt J.H.Morris Algorithm
  **
  internal static Int kmpFindIndex(Str self, Str t, Int offset) {
    charCount := offset
    byteOffset := self.toByteIndex(offset)

    next := kmpNext(t)
    j := 0
    i := byteOffset
    while (i < self.byteLen) {
      ch := self.getByte(i)
      if (ch.and(0xC0) == 0x80) {
        continue
      }
      else {
        ++charCount
      }

      if (self.getByte(i) == t.getByte(j)) {
        ++i
        ++j
        if (j == t.byteLen) return charCount
      }
      else {
        if (j == 0) {
          ++i
          if ((self.byteLen-i) < t.byteLen) return -1
        }
        else {
          j = next[j]
        }
      }
    }
    return -1
  }

  @NoDoc
  Int? index(Str s, Int offset := 0) {
    i := find(s, offset)
    return i == -1 ? null : i
  }

  **
  ** Reverse index - return the first occurance of the specified
  ** substring searching backward, starting at the specified offset
  ** index.  A negative offset may be used to access from the end
  ** of string.  Return -1 if no occurences are found.
  **
  ** Examples:
  **   "abcabc".indexr("b")     => 4
  **   "abcabc".indexr("b", -3) => 1
  **   "abcabc".indexr("b", 0)  => -1
  **
  Int findr(Str s, Int offset := this.size-1) {
    if (s.isEmpty) return 0
    if (offset < 0) offset += size
    if (s.size > offset+1) return -1

    start := toByteIndex(offset)
    pos := -1
    len := s.byteLen
    for (i:=start; i>=0; --i) {
      ch := getByte(i)
      if (ch.and(0xC0) == 0x80) {
        continue
      }

      match := true
      for (j:=0; j<len; ++j) {
        if (i+j >= byteLen) {
          match = false
          break
        }
        if (getByte(i+j) != s.getByte(j)) {
          match = false
          break
        }
      }
      if (match) {
        pos = i
        break
      }
    }

    //byte pos to charCount
    if (pos != -1) {
      return toCharIndex(pos)
    }

    return -1
  }

  @NoDoc
  Int? indexr(Str s, Int offset := -1) {
    i := findr(s, offset)
    return i == -1 ? null : i
  }

  **
  ** Find the index just like `index`, but ignoring case for
  ** ASCII chars only.
  **
  Int? indexIgnoreCase(Str s, Int offset := 0) {
    this.lower.index(s.lower, offset)
  }

  **
  ** Find the index just like `indexr`, but ignoring case for
  ** ASCII chars only.
  **
  Int? indexrIgnoreCase(Str s, Int offset := -1) {
    this.lower.indexr(s.lower, offset)
  }

  **
  ** Return if this string contains the specified string.
  ** Convenience for index(s) != null
  **
  Bool contains(Str s) { find(s) != -1 }

  **
  ** Return if this string contains the specified character.
  **
  Bool containsChar(Int ch) {
    if (isAscii) {
      for (i:=0; i<byteLen; ++i) {
        if (ch == getByte(i)) return true
      }
      return false
    }

    for (i:=0; i<size; ++i) {
      if (ch == get(i)) return true
    }
    return false
  }

//////////////////////////////////////////////////////////////////////////
// Operators
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the character at the zero based index as a Unicode code point.
  ** This method is accessed via the [] operator.  Throw IndexErr if the
  ** index is out of range.
  **
  @Operator Int get(Int index) {
    if (index < 0) index = size+index;

    if (isAscii) {
      return getByte(index)
    }

    bytePos := toByteIndex(index)
    return decodeCharAt(bytePos)
  }

  private Int toCharIndex(Int byteIndex) {
    charCount := 0
    for (i:=0; i<byteIndex; ++i) {
      ch := utf8[i]
      if (ch.and(0xC0) != 0x80) {
        ++charCount
      }
    }
    return charCount
  }

  internal Int toByteIndex(Int index) {
    if (index == 0) return 0
    //if (index < 0 || index < size) throw IndexErr("$index not in [0..$size]")
    charCount := 0
    for (i:=0; i<utf8.size; ++i) {
      ch := utf8[i]
      if (ch.and(0xC0) != 0x80) {
        ++charCount
        if (charCount == index+1) {
          return i;
        }
      }
    }
    throw IndexErr("$index not in [0..$size]") 
  }

  private Int toByteIndexEnd(Int index) {
    charCount := 0
    for (i:=0; i<utf8.size; ++i) {
      ch := utf8[i]
      if (ch.and(0xC0) != 0x80) {
        ++charCount
        if (charCount == index+2) {
          return i;
        }
      }
    }
    return utf8.size
  }

  internal Int decodeCharAt(Int i, Array<Int>? readSize := null) {
    c1 := getByte(i); ++i
    //if (c1 < 0) return -1
    size := 0
    ch := 0
    //echo("decod1 $c1")

    if (c1 < 0x80) {
      ch = c1
      size = 1
    }
    else if (c1 < 0xE0) {
      c2 := getByte(i); ++i
      ch = c1.and(0x1F).shiftl(6).
             or(c2.and(0x3F))
      size = 2
    }
    else if (c1 < 0xF0) {
      c2 := getByte(i); ++i
      c3 := getByte(i); ++i
      //echo("decode $c1, $c2, $c3")
      if ((c2.and(0xC0) != 0x80) || (c3.and(0xC0) != 0x80))
            throw IOErr("Invalid UTF-8 encoding")
      ch = c1.and(0x0F).shiftl(12)
             .or(c2.and(0x3F).shiftl(6))
             .or(c3.and(0x3F))
      size = 3
    }
    else if (c1 < 0xF8) {
      c2 := getByte(i); ++i
      c3 := getByte(i); ++i
      c4 := getByte(i); ++i
      ch = c1.and(0x07).shiftl(18)
             .or(c2.and(0x3F).shiftl(12))
             .or(c3.and(0x3F).shiftl(6))
             .or(c4.and(0x3F))
      size = 4
    }
    else {
      throw IOErr("Invalid UTF-8 encoding")
    }
    if (readSize != null) {
      readSize[0] = size
    }
    return ch
  }

  **
  ** Get the character at the zero based index as a Unicode code point.
  ** Negative indexes may be used to access from the end of the string.
  ** Unlike `get`, this method does not throw IndexErr when the index
  ** is out or range, instead it returns 'def'.
  **
  Int getSafe(Int index, Int defV := 0) {
    if (index < 0) index += size
    if (index < 0 || index >= size) return defV
    return get(index)
  }

  **
  ** Return a substring based on the specified range.  Negative indexes
  ** may be used to access from the end of the string.  This method
  ** is accessed via the [] operator.  Throw IndexErr if range illegal.
  **
  ** Examples:
  **   "abcd"[0..2]   => "abc"
  **   "abcd"[3..3]   => "d"
  **   "abcd"[-2..-1] => "cd"
  **   "abcd"[0..<2]  => "ab"
  **   "abcd"[1..-2]  => "bc"
  **   "abcd"[4..-1]  => ""
  **
  @Operator Str getRange(Range range) {
    s := range.startIndex(size)
    e := range.endIndex(size)
    if (e < 0 || s >= size) return ""
    bs := toByteIndex(s)
    es := toByteIndexEnd(e)
    if (e+1 < s) throw IndexErr("range:$range, size:$size")
    return substring(bs, es)
  }

  **
  ** [byteStart..<byteEnd]
  **
  private Str substring(Int byteStart, Int byteEnd) {
    len := byteEnd - byteStart
    if (len <= 0) return ""
    bytes := Array<Int8>(len)
    Array.arraycopy(utf8, byteStart, bytes, 0, len)
    return make(bytes)
  }

  **
  ** Concat the value of obj.toStr
  **
  @Operator Str plus(Obj? obj) {
    if (obj == null) obj = "null";
    Str str := obj.toStr

    if (size() == 0) return str
    if (str.size() == 0) return this

    len := byteLen + str.byteLen
    bytes := Array<Int8>(len)
    Array.arraycopy(utf8, 0, bytes, 0, byteLen)
    Array.arraycopy(str.utf8, 0, bytes, byteLen, str.byteLen)
    return make(bytes)
  }

//////////////////////////////////////////////////////////////////////////
// Iterators
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the characters in this string as a list of integer code points.
  ** Also see `fromChars`.
  **
  Array<Char> chars() {
    wstr := Array<Char>(size)
    bytePos := 0
    readSize := Array<Int>(1)
    for (i:=0; i<size; ++i) {
      c := decodeCharAt(bytePos, readSize)
      bytePos += readSize[0]
      wstr[i] = c
    }
    return wstr
  }

  **
  ** Call the specified function for every char in the starting
  ** with index 0 and incrementing up to size-1.
  **
  ** Example:
  **   "abc".each |Int c| { echo(c.toChar) }
  **
  Void each(|Int ch, Int index| f) {
    bytePos := 0
    readSize := Array<Int>(1)
    for (i:=0; i<size; ++i) {
      c := decodeCharAt(bytePos, readSize)
      bytePos += readSize[0]
      f(c, i)
    }
  }

  **
  ** Reverse each - call the specified function for every char in
  ** the string starting with index size-1 and decrementing down
  ** to 0.
  **
  ** Example:
  **   "abc".eachr |Int c| { echo(c.toChar) }
  **
  Void eachr(|Int ch, Int index| f) {
    charIndex := size
    for (i:=byteLen-1; i>=0; --i) {
      ch := getByte(i)
      if (ch.and(0xC0) != 0x80) {
        --charIndex
        uc := decodeCharAt(i)
        f(uc, charIndex)
      }
    }
  }

  **
  ** Return true if c returns true for any of the characters in
  ** this string.  If this string is empty, return false.
  **
  ** Example:
  **   "Foo".any |c| { c.isUpper } => true
  **   "foo".any |c| { c.isUpper } => false
  **
  Bool any(|Int ch, Int index->Bool| f) {
    bytePos := 0
    readSize := Array<Int>(1)
    for (i:=0; i<size; ++i) {
      c := decodeCharAt(bytePos, readSize)
      bytePos += readSize[0]
      if (f(c, i)) return true
    }
    return false
  }

  **
  ** Return true if c returns true for all of the characters in
  ** this string.  If this string is empty, return true.
  **
  ** Example:
  **   "Bar".all |c| { c.isUpper } => false
  **   "BAR".all |c| { c.isUpper } => true
  **
  Bool all(|Int ch, Int index->Bool| f) {
    bytePos := 0
    readSize := Array<Int>(1)
    for (i:=0; i<size; ++i) {
      c := decodeCharAt(bytePos, readSize)
      bytePos += readSize[0]
      if (!f(c, i)) return false
    }
    return true
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////
  private static const Str[] spacesCache = premakeSpaces()

  private static Str[] premakeSpaces()
  {
    spaces := Str[,]
    s := StrBuf()
    for (i:=0; i<20; ++i)
    {
      spaces.add(s.toStr)
      s.addChar(' ')
    }
    return spaces
  }

  **
  ** Get the a Str containing the specified number of spaces.  Also
  ** see `justl` and `justr` to justify an existing string.
  **
  ** Examples:
  **   Str.spaces(1)  =>  " "
  **   Str.spaces(2)  =>  "  "
  **
  static Str spaces(Int n) {
    if (n < spacesCache.size) return spacesCache[n]

    sb := StrBuf()
    for (i:=0; i<n; ++i) {
      sb.addChar(' ')
    }
    return sb.toStr
  }
  
  **
  ** Return this string with all uppercase characters replaced
  ** to lowercase.  The case conversion is for ASCII only.
  ** Also see `upper`, `localeLower`, `Int.lower`, `Int.localeLower`.
  **
  ** Example:
  **   "Apple".lower => "apple"
  **
  Str lower() {
    found := false
    sb := Array<Int8>(byteLen)
    for (i:=0; i<byteLen; ++i) {
      ch := this.getByte(i)
      if ('A' <= ch && ch <= 'Z') {
        ch = ch.or(0x20)
        found = true
      }
      sb[i] = ch
    }
    if (!found) return this
    return make(sb)
  }

  **
  ** Return this string with all lowercase characters replaced
  ** to uppercase.  The case conversion is for ASCII only.
  ** Also see `lower`, `localeUpper`, `Int.upper`, `Int.localeUpper`.
  **
  ** Example:
  **   "Foo Bar".upper => "FOO BAR"
  **
  Str upper() {
    found := false
    sb := Array<Int8>(byteLen)
    for (i:=0; i<byteLen; ++i) {
      ch := this.getByte(i)
      if ('a' <= ch && ch <= 'z') {
        ch = ch.and(0x20.not)
        found = true
      }
      sb[i] = ch
    }
    if (!found) return this
    return make(sb)
  }

  **
  ** Trim whitespace from the beginning and end of the string.  For the purposes
  ** of this method, whitespace is defined as any character equal to or less
  ** than the 0x20 space character (including ' ', '\r', '\n', and '\t').
  **
  ** Examples:
  **    "foo".trim      =>  "foo"
  **    "  foo".trim    =>  "foo"
  **    " foo ".trim    =>  "foo"
  **    "  foo\n".trim  =>  "foo"
  **    "   ".trim      =>  ""
  **
  Str trim() {
    self := this
    len := self.byteLen
    if (len == 0) return self;
    if (self.getByte(0) > ' ' && self.getByte(len-1) > ' ') return self;
    
    start := 0;
    while (start < len && self.getByte(start) <= ' ') start++;

    end := len-1;
    while (end >= 0 && self.getByte(end) <= ' ') end--;

    return substring(start, end+1)
  }

  **
  ** Trim whitespace from the beginning and end of the string.
  ** Should the resultant string be empty, 'null' is returned.
  **
  ** For the purposes of this method, whitespace is defined as any character
  ** equal to or less than the 0x20 space character (including ' ', '\r', '\n',
  ** and '\t').
  **
  ** Examples:
  **    "foo".trimToNull      =>  "foo"
  **    "  foo  ".trimToNull  =>  "foo"
  **    "".trimToNull         =>  null
  **    "   ".trimToNull      =>  null
  **
  Str? trimToNull() {
    trimmed := this.trim()
    return trimmed.size() == 0 ? null : trimmed;
  }

  **
  ** Trim whitespace only from the beginning of the string.
  ** See `trim` for definition of whitespace.
  **
  ** Examples:
  **    "foo".trim    =>  "foo"
  **    " foo ".trim  =>  "foo "
  **
  Str trimStart() {
    self := this
    len := self.byteLen
    if (len == 0) return self;
    if (self.getByte(0) > ' ') return self;
    
    start := 0;
    while (start < len && self.getByte(start) <= ' ') start++;

    return substring(start, len)
  }

  **
  ** Trim whitespace only from the end of the string.
  ** See `trim` for definition of whitespace.
  **
  ** Examples:
  **    "foo".trim    =>  "foo"
  **    " foo ".trim  =>  " foo"
  **
  Str trimEnd() {
    self := this
    len := self.byteLen
    if (len == 0) return self;
    if (self.getByte(len-1) > ' ') return self;
    
    end := len-1;
    while (end >= 0 && self.getByte(end) <= ' ') end--;

    return substring(0, end+1)
  }

  **
  ** Split a string into a list of substrings using the
  ** given separator character.  If there are contiguous separators,
  ** then they are split into empty strings.  If trim is true,
  ** then whitespace is trimmed from the beginning and end of
  ** the results.
  **
  ** If separator is null, then the string is split according
  ** to any sequence of whitespace characters (any character equal
  ** to or less than the 0x20 space character including ' ', '\r', '\n',
  ** and '\t').
  **
  ** If this is the empty string or there are no splits return a
  ** list of one item.
  **
  ** Examples:
  **   // split on whitespace
  **   "".split                   =>  [""]
  **   "x".split                  =>  ["x"]
  **   "x y".split                =>  ["x", "y"]
  **   " x y ".split              =>  ["x", "y"]
  **   " x \n y \n z ".split      =>  ["x", "y", "z"]
  **
  **   // split on sep with trim
  **   "".split('|')              =>  [""]
  **   "22".split(';')            =>  ["22"]
  **   "22;33".split(';')         =>  ["22","33"]
  **   "22, 33".split(',')        =>  ["22","33"]
  **   " 22 ; 33 ".split(';')     =>  ["22","33"]
  **
  **   // split on sep with no trim
  **   "22#33".split('#', false)  =>  ["22","33"]
  **   " x ; y".split(';', false) =>  [" x "," y"]
  **
  Str[] split(Int? separator := null, Bool trimmed := true) {
    self := this
    if (separator == null) return splitws(self);
    Int sep := separator;
    Bool trim = trimmed;
    toks := List<Str>(16);
    len := self.byteLen
    x := 0;
    for (i:=0; i<len; ++i)
    {
      if (self.getByte(i) != sep) continue;
      if (x <= i) toks.add(splitStr(self, x, i, trim));
      x = i+1;
    }
    if (x <= len) toks.add(splitStr(self, x, len, trim));
    return toks;
  }

  private static Str splitStr(Str val, Int s, Int e, Bool trim)
  {
    if (trim)
    {
      while (s < e && val.getByte(s) <= ' ') ++s;
      while (e > s && val.getByte(e-1) <= ' ') --e;
    }
    return val.substring(s, e)
  }

  private static Str[] splitws(Str val)
  {
    toks := List<Str>(16);
    len := val.byteLen;
    while (len > 0 && val.getByte(len-1) <= ' ') --len;
    x := 0;
    while (x < len && val.getByte(x) <= ' ') ++x;
    for (i:=x; i<len; ++i)
    {
      if (val.getByte(i) > ' ') continue;
      toks.add(val.substring(x, i));
      x = i + 1;
      while (x < len && val.getByte(x) <= ' ') ++x;
      i = x;
    }
    if (x <= len) toks.add(val.substring(x, len));
    if (toks.size == 0) toks.add("");
    return toks;
  }

  **
  ** Replace all occurrences of 'from' with 'to'.
  **
  ** Examples:
  **   "hello".replace("hell", "t")  =>  "to"
  **   "aababa".replace("ab", "-")   =>  "a--a"
  **
  Str replace(Str from, Str to) {
    if (from.size == 0) return this
    StrBuf? buf
    i := 0
    while (i < size) {
      pos := this.find(from, i)
      if (pos == -1) {
        if (buf == null) return this
        buf.addStr(this, i, this.size-i)
        return buf.toStr
      }
      if (buf == null) buf = StrBuf(this.size)
      buf.addStr(this, i, pos-i)
      buf.add(to)
      i = pos+from.size
    }
    if (buf == null) return this
    return buf.toStr
  }

  **
  ** Return if every character in this Str is a US-ASCII character
  ** less than 128.
  **
  Bool isAscii() { byteLen == charLen }

  **
  ** Return if every character in this Str is whitespace: space \t \n \r \f
  **
  Bool isSpace() {
    self := this
    len := self.byteLen
    for (i:=0; i<len; ++i)
    {
      ch := self.getByte(i);
      if (!ch.isSpace)
        return false;
    }
    return true;
  }

  **
  ** Return if every character in this Str is ASCII uppercase: 'A'-'Z'.
  **
  Bool isUpper() {
    self := this
    len := self.byteLen;
    for (i:=0; i<len; ++i)
    {
      ch := self.getByte(i);
      if (!ch.isUpper)
        return false;
    }
    return true;
  }

  **
  ** Return if every character in this Str is ASCII lowercase: 'a'-'z'.
  **
  Bool isLower() {
    self := this
    len := self.byteLen;
    for (i:=0; i<len; ++i)
    {
      ch := self.getByte(i);
      if (!ch.isLower)
        return false;
    }
    return true;
  }

  **
  ** Return if every char is an ASCII [letter]`Int.isAlpha`.
  **
  Bool isAlpha() {
    if (!isAscii) return false
    self := this
    len := self.byteLen
    for (i:=0; i<len; ++i)
    {
      ch := self.getByte(i);
      if (!ch.isAlpha)
        return false;
    }
    return true;
  }

  **
  ** Return if every char is an ASCII [alpha-numeric]`Int.isAlphaNum`.
  **
  Bool isAlphaNum() {
    if (!isAscii) return false
    self := this
    len := self.byteLen
    for (i:=0; i<len; ++i)
    {
      ch := self.getByte(i);
      if (!ch.isAlphaNum)
        return false;
    }
    return true;
  }

//////////////////////////////////////////////////////////////////////////
// Locale
//////////////////////////////////////////////////////////////////////////
/*
  **
  ** Compare two strings without regard to case according to the
  ** current locale.  Return -1, 0, or 1 if this string is less
  ** than, equal to, or greater than the specified string.
  **
  ** Examples (assuming English locale):
  **   "a".localeCompare("b")   =>  -1
  **   "hi".localeCompare("HI") =>  0
  **   "b".localeCompare("A")   =>  1
  **
  Int localeCompare(Str s)

  **
  ** Return this string with all uppercase characters
  ** replaced to lowercase using the current locale.
  ** Also see `localeUpper`, `lower`, and `Int.localeLower`.
  **
  Str localeLower()

  **
  ** Return this string with all lowercase characters
  ** replaced to uppercase using the current locale.
  ** Also see `localeLower`, `upper`, and `Int.localeUpper`.
  **
  Str localeUpper()

  **
  ** Return this string with the first character
  ** converted to uppercase using the current locale.
  ** Also see `localeDecapitalize` and `capitalize`.
  **
  Str localeCapitalize()

  **
  ** Return this string with the first character
  ** converted to lowercase using the current locale.
  ** Also see `localeCapitalize` and `decapitalize`.
  **
  Str localeDecapitalize()
*/
//////////////////////////////////////////////////////////////////////////
// Coersions
//////////////////////////////////////////////////////////////////////////

  **
  ** Convenience for `Bool.fromStr` using this string.
  **
  Bool toBool(Bool checked := true) { Bool.fromStr(this, checked) }

  **
  ** Convenience for `Int.fromStr` using this string.
  **
  Int toInt(Int radix := 10, Bool checked := true) { Int.fromStr(this, radix, checked) }

  **
  ** Convenience for `Float.fromStr` using this string.
  **
  Float toFloat(Bool checked := true) { Float.fromStr(this, checked) }

  **
  ** Convenience for `Decimal.fromStr` using this string.
  **
  //Decimal? toDecimal(Bool checked := true)

  **
  ** Return this string as its Fantom source code and serialization
  ** representation surrounded by the specified quote character (which
  ** defaults to '"').  If quote is null then the return is unquoted.
  ** This method will backslash escape the following characters:
  ** '\n \r \f \t \\ $'.  If the quote character is the double quote,
  ** single quote, or backtick then it is escaped too.  Control chars
  ** less than 0x20 are escaped as '\uXXXX'.  If 'escapeUnicode' is
  ** true then any char over 0x7F it is escaped as '\uXXXX'.
  **
  Str toCode(Int quote := '"', Bool escapeUnicode := false) {
    self := this
    s := StrBuf(self.size()+10);

    // opening quote
    escu := escapeUnicode;
    q := 0;
    if (quote != 0)
    {
      q = quote;
      s.addChar(q);
    }

    // NOTE: these escape sequences are duplicated in ObjEncoder
    len := self.byteLen;
    readSize := Array<Int>(1)
    for (i:=0; i<len; )
    {
      c := self.decodeCharAt(i, readSize);
      i += readSize[0]
      switch (c)
      {
        case '\n': s.addChar('\\').addChar('n'); //break;
        case '\r': s.addChar('\\').addChar('r'); //break;
        case '\f': s.addChar('\\').addChar('f'); //break;
        case '\t': s.addChar('\\').addChar('t'); //break;
        case '\\': s.addChar('\\').addChar('\\'); //break;
        case '"':  if (q == '"')  s.addChar('\\').addChar('"');  else s.addChar(c); //break;
        case '`':  if (q == '`')  s.addChar('\\').addChar('`');  else s.addChar(c); //break;
        case '\'': if (q == '\'') s.addChar('\\').addChar('\''); else s.addChar(c); //break;
        case '$':  s.addChar('\\').addChar('\$'); //break;
        default:
          if (c < ' ' || (escu && c > 127))
          {
            s.addChar('\\').addChar('u')
             .addChar(hex((c.shiftr(12).and(0xf))))
             .addChar(hex((c.shiftr(8).and(0xf))))
             .addChar(hex((c.shiftr(4).and(0xf))))
             .addChar(hex(c.and(0xf)))
          }
          else
          {
            s.addChar(c);
          }
      }
    }

    // closing quote
    if (q != 0) s.addChar(q);

    return s.toStr();
  }

  private static Int hex(Int nib) { return "0123456789abcdef".getByte(nib); }

  **
  ** Return this string as valid XML text.  The special control
  ** characters amp, lt, apos and quot are always escaped.  The
  ** gt char is escaped only if it is the first char or if preceeded
  ** by the ']' char.  Also see `OutStream.writeXml` which is more
  ** efficient if streaming.
  **
  //Str toXml()

  **
  ** Convenience for `Uri.fromStr` using this string.
  **
  //Uri toUri()

  **
  ** Convenience for `Regex.fromStr` using this string.
  **
  //Regex toRegex()

  **
  ** Create an input stream to read characters from the this string.
  ** The input stream is designed only to read character data.  Attempts
  ** to perform binary reads will throw UnsupportedErr.
  **
  //InStream in()

  **
  ** Get this string encoded into a buffer of bytes.
  **
  //Buf toBuf(Charset charset := Charset.utf8)

  Array<Int8> toUtf8() { utf8 }

  static new fromUtf8(Array<Int8> ba, Int offset := 0, Int len := ba.size) {
    bytes := Array<Int8>(len)
    Array.arraycopy(ba, offset, bytes, 0, len)
    return make(bytes)
  }


  **
  ** Returns a formatted string using the specified format string and arguments.
  **
  native static Str format(Str format, Obj[] args)
}
