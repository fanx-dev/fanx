//
// Copyright (c) 2007, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 07  Brian Frank  Creation
//

**
** Regex represents a regular expression.
**
const final class Regex
{
  private const Str source
  private const Int handle
  private native Void init(Str source)
//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Compile a regular expression pattern string.
  **
  static Regex fromStr(Str pattern) {
    return make(pattern)
  }

  **
  ** Make a Regex which will match a glob pattern:
  **   - "?": match one unknown char (maps to "." in regex)
  **   - "*": match zero or more unknown char (maps to ".*" in regex)
  **   - any other character is matched exactly
  **
  static Regex glob(Str pattern) {
    s := StrBuf()
    for (i:=0; i<pattern.size; ++i)
    {
      c := pattern.get(i);
      if (c.isAlphaNum) s.addChar(c);
      else if (c == '?') s.addChar('.');
      else if (c == '*') s.addChar('.').addChar('*');
      else s.addChar('\\').addChar(c);
    }
    return Regex.make(s.toStr)
  }

  **
  ** Make a Regex that matches the given string exactly.
  ** All non-alpha numeric characters are escaped.
  **
  static Regex quote(Str str) {
    s := StrBuf()
    for (i:=0; i<str.size; ++i)
    {
      c := str.get(i);
      if (c.isAlphaNum) s.addChar(c);
      else s.addChar('\\').addChar(c);
    }
    return Regex.make(s.toStr)
  }

  **
  ** Private constructor.
  **
  private new make(Str source) {
    this.source = source
    init(source)
  }

  **
  ** Default value is Regex("").
  **
  const static Regex defVal := Regex.make("")

//////////////////////////////////////////////////////////////////////////
// Obj Overrides
//////////////////////////////////////////////////////////////////////////

  **
  ** Equality is based on pattern string.
  **
  override Bool equals(Obj? obj) {
    if (obj is Regex)
      return ((Regex)obj).source.equals(this.source)
    else
      return false
  }

  **
  ** Return 'toStr.hash'.
  **
  override Int hash() { source.hash }

  **
  ** Return the regular expression pattern string.
  **
  override Str toStr() { source }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  **
  ** Convenience for [matcher(s).matches]`RegexMatcher.matches`.
  **
  native Bool matches(Str s)

  **
  ** Return a 'RegexMatcher' instance to use for matching
  ** operations against the specified string.
  **
  native RegexMatcher matcher(Str s)

  **
  ** Split the specified string around matches of this pattern.
  ** The 'limit' parameter specifies how many times to apply
  ** the pattern:
  **   - If 'limit' is greater than zero, the pattern is applied
  **     at most 'limit-1' times and any remaining input will
  **     be returned as the list's last item.
  **   - If 'limit' is less than zero, then the pattern is
  **     matched as many times as possible.
  **   - If 'limit' is zero, then the pattern is matched as many
  **     times as possible, but trailing empty strings are
  **     discarded.
  **
  native Str[] split(Str s, Int limit := 0)


  // TODO: flags support
  // TODO: examples in fandoc
  //protected native override Void finalize()
}