//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   16 Mar 06  Brian Frank  Creation
//

**
** Charset represents a specific character encoding used to decode
** bytes to Unicode characters, and encode Unicode characters to bytes.
**
@Serializable { simple = true }
const final class Charset
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Attempt to lookup a Charset by name.  Use one of the predefined
  ** methods such as `utf8` to get a standard encoding.  If charset not
  ** found and checked is false return null, otherwise throw ParseErr.
  **
  native static new fromStr(Str name, Bool checked := true)

  **
  ** Private constructor
  **
  private new privateMake(Str name) {
    this.name = name
  }

  **
  ** Default value is `utf8`.
  **
  const static Charset defVal := utf8

//////////////////////////////////////////////////////////////////////////
// Standard Encodings
//////////////////////////////////////////////////////////////////////////

  **
  ** An charset for "UTF-8" format (Eight-bit UCS Transformation Format).
  **
  const static Charset utf8 := fromStr("UTF-8")

  **
  ** An charset for "UTF-16BE" format (Sixteen-bit UCS Transformation
  ** Format, big-endian byte order).
  **
  const static Charset utf16BE := fromStr("UTF-16BE")

  **
  ** An charset for "UTF-16LE" format (Sixteen-bit UCS Transformation
  ** Format, little-endian byte order).
  **
  const static Charset utf16LE := fromStr("UTF-16LE")

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the name of this character encoding.
  **
  const Str name

  **
  ** Compute hash code based on case-insensitive name.
  **
  override Int hash() { name.hash }

  **
  ** Charset equality is based on the character set name
  ** ignoring case (names are not case-sensitive).
  **
  override Bool equals(Obj? obj) {
    if (obj is Charset) {
      return name.equalsIgnoreCase(((Charset)obj).name)
    }
    return false
  }

  **
  ** Return name().
  **
  override Str toStr() { name }

}