//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   27 Jul 06  Brian Frank  Creation
//

**
** Version is defined as a list of decimal digits separated
** by the dot.  Convention for Fantom pods is a four part version
** format of 'major.minor.build.patch'.
**
@Serializable { simple = true }
const final class Version
{
  private const Str str
//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse a string representation into a Version.
  ** If invalid format and checked is false return null,
  ** otherwise throw ParseErr.
  **
  static new fromStr(Str version, Bool checked := true) {
    try {
      fs := version.split('.', false)
      seg := Int[,]
      fs.each |Str p| { seg.add(p.toInt) }
      return Version.make(seg)
    } catch (Err e) {
      if (checked) throw ParseErr(version, e)
      return defVal
    }
  }

  **
  ** Construct with list of integer segments.
  ** Throw ArgErr if segments is empty or contains negative numbers.
  **
  new make(Int[] segments) {
    if (segments.size == 0) throw ArgErr("$segments")
    if (segments.any { it < 0 }) throw ArgErr("$segments")
    this.segments = segments
    this.str = segments.join(".")
  }

  **
  ** Default value is "0".
  **
  static const Version defVal := fromStr("0")

  **
  ** Private constructor
  **
  //private new privateMake()

//////////////////////////////////////////////////////////////////////////
// Obj Overrides
//////////////////////////////////////////////////////////////////////////

  **
  ** Return true if equal segments.
  **
  override Bool equals(Obj? obj) {
    if (obj isnot Version) return false
    return str == ((Version)obj).str
  }

  **
  ** Compare from from most significant segment to least significant
  ** segment.
  **
  ** Examples:
  **   1.6 > 1.4
  **   2.0 > 1.9
  **   1.2.3 > 1.2
  **   1.11 > 1.9.3
  **
  override Int compare(Obj obj) {
    Version that := (Version)obj;
    a := this.segments;
    b := that.segments;
    for (i:=0; i<a.size && i<b.size; ++i)
    {
      ai := a.get(i);
      bi := b.get(i);
      if (ai < bi) return -1;
      if (ai > bi) return +1;
    }
    if (a.size < b.size) return -1;
    if (a.size > b.size) return +1;
    return 0;
  }

  **
  ** Return toStr.hash
  **
  override Int hash() { str.hash }

  **
  ** The string format is equivalent to segments.join(".")
  **
  override Str toStr() { str }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Get a readonly list of the integer segments.
  **
  const Int[] segments

  **
  ** Get the first, most significant segment which represents the major version.
  **
  Int major() { segments[0] }

  **
  ** Get the second segment which represents the minor version.
  ** Return null if version has less than two segments.
  **
  Int? minor() { segments.getSafe(1) }

  **
  ** Get the third segment which represents the build number.
  ** Return null if version has less than three segments.
  **
  Int? build() { segments.getSafe(2) }

  **
  ** Get the fourth segment which represents the patch number.
  ** Return null if version has less than four segments.
  **
  Int? patch() { segments.getSafe(3) }

}