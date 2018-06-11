//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   11 Dec 05  Brian Frank  Creation
//

**
** Range represents a contiguous range of integers from start to
** end.  Ranges may be represented as literals in Fantom source code as
** "start..end" for an inclusive end or "start..<end" for an exlusive
** range.
**
@Serializable { simple = true }
const struct class Range
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Convenience for make(start, end, false).
  **
  static new makeInclusive(Int start, Int end) {
    return make(start, end, false)
  }

  **
  ** Convenience for make(start, end, true).
  **
  static new makeExclusive(Int start, Int end) {
    return make(start, end, true)
  }

  **
  ** Constructor with start, end, and exclusive flag (all must be non-null).
  **
  new make(Int start, Int end, Bool exclusive) {
    this._start = start
    this._end = end
    this._exclusive = exclusive
  }

  **
  ** Parse from string format - inclusive is "start..end", or
  ** exclusive is "start..<end".  If invalid format then
  ** throw ParseErr or return null based on checked flag.
  **
  static new fromStr(Str str, Bool checked := true) {
    pos := str.find("..")
    if (pos == -1 || pos+2>= str.size) {
      if (checked) throw ParseErr("Invalide Range: $str")
      return make(0, 0, true)
    }
    s := str[0..<pos]
    Str? e
    exclusive := false
    if (str[pos+2] == '<') {
      e = str[pos+3..-1]
      exclusive = true
    }
    else {
      e = str[pos+2..-1]
      exclusive = false
    }
    return make(s.toInt, e.toInt, exclusive)
  }

//////////////////////////////////////////////////////////////////////////
// Obj Overrides
//////////////////////////////////////////////////////////////////////////

  **
  ** Return true if same start, end, and exclusive.
  **
  override Bool equals(Obj? obj) {
    if (obj == null) return false
    if (obj isnot Range) return false
    other := obj as Range
    if (start != other.start) return false
    if (end != other.end) return false
    if (exclusive != other.exclusive) return false
    return true
  }

  **
  ** Return start ^ end.
  **
  override Int hash() {
    return start.xor(end)
  }

  **
  ** If inclusive return "start..end", if exclusive return "start..<end".
  **
  override Str toStr() {
    if (exclusive) {
      return "${start}..<$end"
    } else {
      return "${start}..$end"
    }
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Return start index.
  **
  ** Example:
  **   (1..3).start  =>  1
  **
  Int start() { _start }
  private const Int _start

  **
  ** Return end index.
  **
  ** Example:
  **   (1..3).end  =>  3
  **
  Int end() { _end }
  private const Int _end

  **
  ** Return last inclusive index
  ** Example:
  ** (1..<3).end => 2
  **
  Int lastEnd() {
    if (start == end) return end
    else if (start < end)
      return exclusive ? end-1 : end
    else
      return exclusive ? end+1 : end
  }

  **
  ** Is the end index inclusive.
  **
  ** Example:
  **   (1..3).inclusive   =>  true
  **   (1..<3).inclusive  =>  false
  **
  Bool inclusive() { !exclusive }

  **
  ** Is the end index exclusive.
  **
  ** Example:
  **   (1..3).exclusive   =>  false
  **   (1..<3).exclusive  =>  true
  **
  Bool exclusive() { _exclusive }
  private const Bool _exclusive

  **
  ** Return if this range contains no integer values.
  ** Equivalent to 'toList.isEmpty'.
  **
  Bool isEmpty() { exclusive && start == end }

  **
  ** Get the minimum value of the range. If range contains
  ** no values then return null.  Equivalent to 'toList.min'.
  **
  Int? min() {
    if (isEmpty) return null
    if (end < start) return exclusive ? end+1 : end
    return start
  }

  **
  ** Get the maximum value of the range. If range contains
  ** no values then return null.  Equivalent to 'toList.max'.
  **
  Int? max() {
    if (isEmpty) return null
    if (end < start) return start
    return exclusive ? end-1 : end
  }

  **
  ** Get the first value of the range.   If range contains
  ** no values then return null.  Equivalent to 'toList.first'.
  **
  Int? first() {
    if (isEmpty) return null
    return start
  }

  **
  ** Get the last value of the range.   If range contains
  ** no values then return null.  Equivalent to 'toList.last'.
  **
  Int? last() {
    if (isEmpty()) return null
    return lastEnd
  }

  **
  ** Return if this range contains the specified integer.
  **
  ** Example:
  **   (1..3).contains(2)  =>  true
  **   (1..3).contains(4)  =>  false
  **
  Bool contains(Int i) {
    if (start < end) {
      if (exclusive)
        return start <= i && i < end
      else
        return start <= i && i <= end
    }
    else {
      if (exclusive)
        return end < i && i <= start
      else
        return end <= i && i <= start
    }
  }

  **
  ** Create a new range by adding offset to this range's
  ** start and end values.
  **
  ** Example:
  **   (3..5).offset(2)   =>  5..7
  **   (3..<5).offset(-2) =>  1..<3
  **
  Range offset(Int offset) {
    return Range(start+offset, end+offset, exclusive)
  }

  **
  ** Call the specified function for each integer in the range.
  ** Also see `Int.times`.
  **
  ** Example:
  **   (1..3).each |i| { echo(i) }          =>  1, 2, 3
  **   (1..<3).each |i| { echo(i) }         => 1, 2
  **   ('a'..'z').each |Int i| { echo(i) }  => 'a', 'b', ... 'z'
  **
  Void each(|Int i| f) {
    start := this.start
    end := this.lastEnd
    if (start < end) {
      for (i:=start; i<=end; ++i) f.call(i)
    }
    else {
      for (i:=start; i>=end; --i) f.call(i)
    }
  }

  **
  ** Iterate every integer in the range until the function returns
  ** non-null.  If function returns non-null, then break the iteration
  ** and return the resulting object.  Return null if the function returns
  ** null for every integer in the range.
  **
  Obj? eachWhile(|Int i->Obj?| f) {
    start := this.start
    end := this.lastEnd
    if (start < end) {
      for (i:=start; i<=end; ++i) {
        r := f.call(i)
        if (r != null) return r
      }
    }
    else {
      for (i:=start; i>=end; --i) {
        r := f.call(i)
        if (r != null) return r
      }
    }
    return null
  }

  **
  ** Create a new list which is the result of calling c for
  ** every integer in the range.  The new list is typed based on
  ** the return type of c.
  **
  ** Example:
  **   (10..15).map |i->Str| { i.toHex }  =>  Str[a, b, c, d, e, f]
  **
  Obj?[] map(|Int i->Obj?| f) {
    tof := f.returns
    if (tof == Void#) tof = Obj?#
    cp := start < end ? end-start+1 : start-end+1

    nlist := List.make(tof, cp)
    start := this.start
    end := this.lastEnd
    if (start < end) {
      for (i:=start; i<=end; ++i) {
        r := f.call(i)
        nlist.add(r)
      }
    }
    else {
      for (i:=start; i>=end; --i) {
        r := f.call(i)
        nlist.add(r)
      }
    }
    return nlist
  }

  **
  ** Convert this range into a list of Ints.
  **
  ** Example:
  **   (2..4).toList   =>  [2,3,4]
  **   (2..<4).toList  =>  [2,3]
  **   (10..8).toList  =>  [10,9,8]
  **
  Int[] toList() {
    nlist := Int[,]
    if (isEmpty) return nlist
    start := this.start
    end := this.lastEnd
    if (start < end) {
      nlist.capacity = end-start+1
      for (i:=start; i<=end; ++i) {
        nlist.add(i)
      }
    }
    else {
      nlist.capacity = start-end+1
      for (i:=start; i>=end; --i) {
        nlist.add(i)
      }
    }
    return nlist
  }

  **
  ** Convenience for [Int.random(this)]`Int.random`.
  ** Also see `Int.random`, `Float.random`, `List.random`,
  ** and `util::Random`.
  **
  Int random() {
    Int.random(this)
  }

  Int startIndex(Int size)
  {
    x := start
    if (x < 0) x = size + x
    if (x > size) throw IndexErr.make("Range: $this, $size")
    return x
  }

  Int endIndex(Int size)
  {
    x := end
    if (x < 0) x = size + x
    if (exclusive) x--
    if (x >= size) throw IndexErr.make("Range: $this, $size")
    return x
  }
}