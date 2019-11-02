//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Jan 06  Brian Frank  Creation
//

**
** StrBuf is a mutable sequence of Int characters.
**
native final class StrBuf
{
  private Ptr buf
  private Int _size

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Create with initial capacity (defaults to 16).
  **
  new make(Int capacity := 16) {
    &capacity = capacity
    _size = 0
    buf = Libc.malloc(capacity * Libc.charSize)
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Return if size() == 0.
  **
  Bool isEmpty() { size == 0 }

  **
  ** Return the number of characters in the buffer.
  **
  Int size() { _size }

  **
  ** The number of characters this buffer can hold without
  ** allocating more memory.
  **
  native Int capacity {
    set {
      if (it > &capacity) {
        nbuf := Libc.realloc(buf, it)
        if (nbuf == Ptr.nil) {
          throw Err("realloc fail")
        }
        buf = nbuf
        &capacity = it
      }
    }
  }

  **
  ** Get the character at the zero based index as a Unicode code point.
  ** Negative indexes may be used to access from the end of the string buffer.
  ** This method is accessed via the [] operator.
  **
  @Operator Int get(Int index) {
    Libc.getChar(buf, index)
  }

  **
  ** Return a substring based on the specified range.  Negative indexes
  ** may be used to access from the end of the string buffer.  This method
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
    return Str.fromCStr(buf.get(s*Libc.charSize), e-s)
  }

  **
  ** Replace the existing character at index in this buffer.
  ** Negative indexes may be used to access from the end of
  ** the string buffer.  This method is accessed via the []
  ** operator.  Return this.
  **
  @Operator This set(Int index, Int ch) {
    if (index < 0) {
      index += size
    }
    if (index >= size) {
      throw IndexErr("$index, $size")
    }
    Libc.setChar(buf, index, ch)
    return this
  }

  **
  ** Add x.toStr to the end of this buffer.  If x is null then
  ** the string "null" is inserted.  Return this.
  **
  This add(Obj? x) {
    s := x == null ? "null" : x.toStr
    addStr(s)
    return this
  }

  **
  ** Optimized implementation for add(ch.toChar).  Return this.
  **
  This addChar(Int ch) {
    if (_size == capacity) {
      capacity = 8 + (capacity * 1.5).toInt
    }
    Libc.setChar(buf, _size, ch)
    ++_size
    return this
  }

  private Void grow(Int len) {
    if (_size + len >= capacity) {
      capacity = 8 + ((_size + len) * 1.5).toInt
    }
  }

  This addStr(Str str, Int off := 0, Int len := str.size) {
    grow(len)

    src := str.getCharPtr.get(off*Libc.charSize())
    Libc.memcpy(buf, src, len*Libc.charSize)
    _size += len
    return this
  }

  **
  ** Add x.toStr to the end of the buffer.  If the buffer is not
  ** empty, then first add the specified separator which defaults
  ** to a space if not specified.  Return this.
  **
  This join(Obj? x, Str sep := " ") {
    s := x == null ? "null" : x.toStr
    if (size > 0) addStr(sep)
    addStr(s)
    return this
  }

  **
  ** Insert x.toStr into this buffer at the specified index.
  ** If x is null then the string "null" is inserted.  Negative
  ** indexes may be used to access from the end of the string
  ** buffer.  Throw IndexErr if index is out of range.  Return
  ** this.
  **
  This insert(Int index, Obj? x) {
    if (index < 0) {
      index += size
    }
    if (index >= size) {
      throw IndexErr("$index, $size")
    }
    str := x == null ? "null" : x.toStr
    strLen := str.size
    grow(strLen)

    left := size - index - 1
    Libc.memmove(buf.get((index+strLen) * Libc.charSize), buf.get((index) * Libc.charSize), left * Libc.charSize)

    Libc.memcpy(buf.get((index) * Libc.charSize), str.getCharPtr, strLen * Libc.charSize)
    _size += strLen
    return this
  }

  **
  ** Remove the char at the specified index.  A negative index may be
  ** used to access an index from the end of the list.  Size is decremented
  ** by 1.  Return the this.  Throw IndexErr if index is out of range.
  **
  This remove(Int index) {
    if (index < 0) {
      index += size
    }
    if (index >= size) {
      throw IndexErr("$index, $size")
    }
    left := size - index - 1
    Libc.memmove(buf.get(index * Libc.charSize), buf.get((index+1) * Libc.charSize), left * Libc.charSize)
    --_size
    return this
  }

  **
  ** Remove a range of indices from this buffer.  Negative indexes
  ** may be used to access from the end of the list.  Throw IndexErr
  ** if range illegal.  Return this.
  **
  This removeRange(Range r) {
    s := r.startIndex(size)
    e := r.endIndex(size)
    Libc.memmove(buf.get((s) * Libc.charSize), buf.get((e) * Libc.charSize), (e-s) * Libc.charSize)
    return this
  }

  **
  ** Replaces a range of indices from this buffer with the specified string.
  ** Negative indexes may be used to access from the end of the buffer.
  ** Throw IndexErr if range illegal.  Return this.
  **
  This replaceRange(Range r, Str str) {
    s := r.startIndex(size)
    e := r.endIndex(size)

    strLen := str.size-(e-s)
    grow(strLen)

    left := size - strLen - 1
    Libc.memmove(buf.get((s+strLen) * Libc.charSize), buf.get(e * Libc.charSize), left * Libc.charSize)

    Libc.memmove(buf.get((s) * Libc.charSize), str.getCharPtr, str.size * Libc.charSize)

    _size += strLen
    return this
  }

  **
  ** Clear the contents of the string buffer so that is
  ** has a size of zero.  Return this.
  **
  This clear() { _size = 0; return this }

//////////////////////////////////////////////////////////////////////////
// Conversion
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the current buffer contents as a Str.
  **
  override Str toStr() {
    Str.fromCharPtr(buf, size)
  }

  **
  ** Create an output stream to append characters to this string
  ** buffer.  The output stream is designed to write character data,
  ** attempts to do binary writes will throw UnsupportedErr.
  **
  //OutStream out()
  protected override Void finalize() {
    Libc.free(buf)
    buf = Ptr.nil
    _size = 0
    &capacity = 0
  }
}