//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Jan 06  Brian Frank  Creation
//

using sys::Int32 as Char
using sys::Int32 as NInt
using sys::Int64 as Size_t

**
** StrBuf is a mutable sequence of Int characters.
**
native final class StrBuf
{
  private Array<Char> buf
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
    buf = Array<Char>(capacity)
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
  Int capacity {
    set {
      if (it > &capacity) {
        nbuf := Array.realloc(buf, it)
        //if (nbuf == Ptr.nil) {
        //  throw Err("realloc fail")
        //}
        buf = nbuf
        &capacity = it
      }
    }
    get { buf.size }
  }

  **
  ** Get the character at the zero based index as a Unicode code point.
  ** Negative indexes may be used to access from the end of the string buffer.
  ** This method is accessed via the [] operator.
  **
  @Operator Int get(Int index) {
    if (index < 0 || index >= size) {
      throw IndexErr("$index out $size")
    }
    return buf[index]
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
    return Str.fromChars(buf, s, e+1-s)
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
    buf[index] = ch
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
    buf[_size] = ch
    ++_size
    return this
  }

  private Void grow(Int len) {
    if (_size + len >= capacity) {
      capacity = 8 + ((_size + len) * 1.5).toInt
    }
  }

  This addStr(Str str, Int off := 0, Int len := str.size) {
    if (len > str.size) throw IndexErr("len:$len > str.size:$str.size")
    grow(len)

    bytePos := str.toByteIndex(off)
    readSize := Array<Int>(1)
    for (i:=0; i<len; ++i) {
      c := str.decodeCharAt(bytePos, readSize)
      bytePos += readSize[0]
      buf[_size] = c
      ++_size
    }
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
    Array.arraycopy(buf, index, buf, index+strLen, left)
    //NativeC.memmove(buf+index+strLen, buf+index, left * sizeof(Char))

    bytePos := 0
    readSize := Array<Int>(1)
    destPos := index
    for (i:=0; i<strLen; ++i) {
      c := str.decodeCharAt(bytePos, readSize)
      bytePos += readSize[0]
      buf[destPos] = c
      ++destPos
    }
    //NativeC.memcpy(buf+index, str.getCharPtr, strLen * sizeof(Char))
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
    Array.arraycopy(buf, index+1, buf, index, left)
    //NativeC.memmove(buf+index, buf+index+1, left * sizeof(Char))
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
    Array.arraycopy(buf, e+1, buf, s, (e+1-s))
    //NativeC.memmove(buf+s, buf+e, (e-s) * sizeof(Char))
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

    strLen := str.size-(e+1-s)
    grow(strLen)

    left := size - strLen - 1
    //NativeC.memmove(buf+s+strLen, buf+e, left * sizeof(Char))
    Array.arraycopy(buf, e+1, buf, s+strLen, left)

    //NativeC.memmove(buf+s, str.getCharPtr, str.size * sizeof(Char))
    bytePos := 0
    readSize := Array<Int>(1)
    destPos := s
    for (i:=0; i<strLen; ++i) {
      c := str.decodeCharAt(bytePos, readSize)
      bytePos += readSize[0]
      buf[destPos] = c
      ++destPos
    }

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
    Str.fromChars(buf, 0, size)
  }

  **
  ** Create an output stream to append characters to this string
  ** buffer.  The output stream is designed to write character data,
  ** attempts to do binary writes will throw UnsupportedErr.
  **
  //OutStream out()
  protected override Void finalize() {}
}