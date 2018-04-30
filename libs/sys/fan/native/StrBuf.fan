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

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Create with initial capacity (defaults to 16).
  **
  new make(Int capacity := 16)

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Return if size() == 0.
  **
  Bool isEmpty()

  **
  ** Return the number of characters in the buffer.
  **
  Int size()

  **
  ** The number of characters this buffer can hold without
  ** allocating more memory.
  **
  Int capacity

  **
  ** Get the character at the zero based index as a Unicode code point.
  ** Negative indexes may be used to access from the end of the string buffer.
  ** This method is accessed via the [] operator.
  **
  @Operator Int get(Int index)

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
  @Operator Str getRange(Range range)

  **
  ** Replace the existing character at index in this buffer.
  ** Negative indexes may be used to access from the end of
  ** the string buffer.  This method is accessed via the []
  ** operator.  Return this.
  **
  @Operator This set(Int index, Int ch)

  **
  ** Add x.toStr to the end of this buffer.  If x is null then
  ** the string "null" is inserted.  Return this.
  **
  This add(Obj? x)

  **
  ** Optimized implementation for add(ch.toChar).  Return this.
  **
  This addChar(Int ch)

  **
  ** Add x.toStr to the end of the buffer.  If the buffer is not
  ** empty, then first add the specified separator which defaults
  ** to a space if not specified.  Return this.
  **
  This join(Obj? x, Str sep := " ")

  **
  ** Insert x.toStr into this buffer at the specified index.
  ** If x is null then the string "null" is inserted.  Negative
  ** indexes may be used to access from the end of the string
  ** buffer.  Throw IndexErr if index is out of range.  Return
  ** this.
  **
  This insert(Int index, Obj? x)

  **
  ** Remove the char at the specified index.  A negative index may be
  ** used to access an index from the end of the list.  Size is decremented
  ** by 1.  Return the this.  Throw IndexErr if index is out of range.
  **
  This remove(Int index)

  **
  ** Remove a range of indices from this buffer.  Negative indexes
  ** may be used to access from the end of the list.  Throw IndexErr
  ** if range illegal.  Return this.
  **
  This removeRange(Range r)

  **
  ** Replaces a range of indices from this buffer with the specified string.
  ** Negative indexes may be used to access from the end of the buffer.
  ** Throw IndexErr if range illegal.  Return this.
  **
  This replaceRange(Range r, Str str)

  **
  ** Clear the contents of the string buffer so that is
  ** has a size of zero.  Return this.
  **
  This clear()

//////////////////////////////////////////////////////////////////////////
// Conversion
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the current buffer contents as a Str.
  **
  override Str toStr()

  **
  ** Create an output stream to append characters to this string
  ** buffer.  The output stream is designed to write character data,
  ** attempts to do binary writes will throw UnsupportedErr.
  **
  //OutStream out()
  protected override Void finalize()
}