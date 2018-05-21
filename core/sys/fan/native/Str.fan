//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Dec 05  Brian Frank  Creation
//

**
** Str represents a sequence of Unicode characters.
**
native const final class Str
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  **
  ** Private constructor.
  **
  private new privateMake()

  **
  ** Default value is "".
  **
  const static Str defVal := ""

  **
  ** Construct a string from a list of unicode code points.
  ** Also see `chars`.
  **
  static Str fromChars(Int[] chars)

//////////////////////////////////////////////////////////////////////////
// Obj Overrides
//////////////////////////////////////////////////////////////////////////

  **
  ** Return true if a Str with exact same char sequence.
  **
  override Bool equals(Obj? obj)

  **
  ** Convenience for 'compareIgnoreCase(s) == 0'.
  ** Only ASCII character case is taken into account.
  ** See `localeCompare` for localized case insensitive
  ** comparisions.
  **
  Bool equalsIgnoreCase(Str s)

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
  override Int compare(Obj obj)

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
  Int compareIgnoreCase(Str s)

  **
  ** The hash for a Str is platform dependent.
  **
  override Int hash()

  **
  ** Return this.
  **
  override Str toStr()

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
  Bool isEmpty()

  **
  ** Return number of characters in this string.
  **
  Int size()

  **
  ** Internalize this Str such that two strings which are equal
  ** via the '==' operator will have the same reference such that
  ** '===' will be true.
  **
  Str intern()

  **
  ** Return if this Str starts with the specified Str.
  **
  Bool startsWith(Str s)

  **
  ** Return if this Str ends with the specified Str.
  **
  Bool endsWith(Str s)

  **
  ** Return the first occurance of the specified substring searching
  ** forward, starting at the specified offset index.  A negative offset
  ** may be used to access from the end of string.  Return Int.invalidVal if no
  ** occurences are found.
  **
  ** Examples:
  **   "abcabc".index("b")     => 1
  **   "abcabc".index("b", 1)  => 1
  **   "abcabc".index("b", 3)  => 4
  **   "abcabc".index("b", -3) => 4
  **   "abcabc".index("x")     => -1
  **
  Int find(Str s, Int offset := 0)
  @Deprecated { msg = "use find" }
  Int? index(Str s, Int offset := 0)

  **
  ** Reverse index - return the first occurance of the specified
  ** substring searching backward, starting at the specified offset
  ** index.  A negative offset may be used to access from the end
  ** of string.  Return Int.invalidVal if no occurences are found.
  **
  ** Examples:
  **   "abcabc".indexr("b")     => 4
  **   "abcabc".indexr("b", -3) => 1
  **   "abcabc".indexr("b", 0)  => -1
  **
  Int findr(Str s, Int offset := s.size-1)
  @Deprecated { msg = "use findr" }
  Int? indexr(Str s, Int offset := -1)

  **
  ** Find the index just like `index`, but ignoring case for
  ** ASCII chars only.
  **
  Int? indexIgnoreCase(Str s, Int offset := 0)

  **
  ** Find the index just like `indexr`, but ignoring case for
  ** ASCII chars only.
  **
  Int? indexrIgnoreCase(Str s, Int offset := -1)

  **
  ** Return if this string contains the specified string.
  ** Convenience for index(s) != null
  **
  Bool contains(Str s)

  **
  ** Return if this string contains the specified character.
  **
  Bool containsChar(Int ch)

//////////////////////////////////////////////////////////////////////////
// Operators
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the character at the zero based index as a Unicode code point.
  ** This method is accessed via the [] operator.  Throw IndexErr if the
  ** index is out of range.
  **
  @Operator Int get(Int index)

  **
  ** Get the character at the zero based index as a Unicode code point.
  ** Negative indexes may be used to access from the end of the string.
  ** Unlike `get`, this method does not throw IndexErr when the index
  ** is out or range, instead it returns 'def'.
  **
  Int getSafe(Int index, Int defV := 0)

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
  @Operator Str getRange(Range range)

  **
  ** Concat the value of obj.toStr
  **
  @Operator Str plus(Obj? obj)

//////////////////////////////////////////////////////////////////////////
// Iterators
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the characters in this string as a list of integer code points.
  ** Also see `fromChars`.
  **
  Int[] chars()

  **
  ** Call the specified function for every char in the starting
  ** with index 0 and incrementing up to size-1.
  **
  ** Example:
  **   "abc".each |Int c| { echo(c.toChar) }
  **
  Void each(|Int ch, Int index| c)

  **
  ** Reverse each - call the specified function for every char in
  ** the string starting with index size-1 and decrementing down
  ** to 0.
  **
  ** Example:
  **   "abc".eachr |Int c| { echo(c.toChar) }
  **
  Void eachr(|Int ch, Int index| c)

  **
  ** Return true if c returns true for any of the characters in
  ** this string.  If this string is empty, return false.
  **
  ** Example:
  **   "Foo".any |c| { c.isUpper } => true
  **   "foo".any |c| { c.isUpper } => false
  **
  Bool any(|Int ch, Int index->Bool| c)

  **
  ** Return true if c returns true for all of the characters in
  ** this string.  If this string is empty, return true.
  **
  ** Example:
  **   "Bar".all |c| { c.isUpper } => false
  **   "BAR".all |c| { c.isUpper } => true
  **
  Bool all(|Int ch, Int index->Bool| c)

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the a Str containing the specified number of spaces.  Also
  ** see `justl` and `justr` to justify an existing string.
  **
  ** Examples:
  **   Str.spaces(1)  =>  " "
  **   Str.spaces(2)  =>  "  "
  **
  static Str spaces(Int n)

  **
  ** Return this string with all uppercase characters replaced
  ** to lowercase.  The case conversion is for ASCII only.
  ** Also see `upper`, `localeLower`, `Int.lower`, `Int.localeLower`.
  **
  ** Example:
  **   "Apple".lower => "apple"
  **
  Str lower()

  **
  ** Return this string with all lowercase characters replaced
  ** to uppercase.  The case conversion is for ASCII only.
  ** Also see `lower`, `localeUpper`, `Int.upper`, `Int.localeUpper`.
  **
  ** Example:
  **   "Foo Bar".upper => "FOO BAR"
  **
  Str upper()

  **
  ** Return this string with the first character converted
  ** uppercase.  The case conversion is for ASCII only.
  ** Also see `decapitalize` and `localeCapitalize`.
  **
  ** Example:
  **   "foo".capitalize => "Foo"
  **
  Str capitalize()

  **
  ** Return this string with the first character converted
  ** lowercase.  The case conversion is for ASCII only.
  ** Also see `capitalize` and `localeDecapitalize`.
  **
  ** Example:
  **   "Foo".decapitalize => "foo"
  **
  Str decapitalize()

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
  Str toDisplayName()

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
  Str fromDisplayName()

  **
  ** If size is less than width, then add spaces to the right
  ** to create a left justified string.  Also see `padr`.
  **
  ** Examples:
  **   "xyz".justl(2) => "xyz"
  **   "xyz".justl(4) => "xyz "
  **
  Str justl(Int width)

  **
  ** If size is less than width, then add spaces to the left
  ** to create a right justified string.  Also see `padl`.
  **
  ** Examples:
  **   "xyz".justr(2) => "xyz"
  **   "xyz".justr(4) => " xyz"
  **
  Str justr(Int width)

  **
  ** If size is less than width, then add the given char to the
  ** left to achieve the specified width.  Also see `justr`.
  **
  ** Examples:
  **   "3".padl(3, '0') => "003"
  **   "123".padl(2, '0') => "123"
  **
  Str padl(Int width, Int char := ' ')

  **
  ** If size is less than width, then add the given char to
  ** the left to acheive the specified with.  Also see `justl`.
  **
  ** Examples:
  **   "xyz".padr(2, '.') => "xyz"
  **   "xyz".padr(5, '-') => "xyz--"
  **
  Str padr(Int width, Int char := ' ')

  **
  ** Reverse the contents of this string.
  **
  ** Example:
  **   "stressed".reverse => "desserts"
  **
  Str reverse()

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
  Str trim()

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
  Str? trimToNull()

  **
  ** Trim whitespace only from the beginning of the string.
  ** See `trim` for definition of whitespace.
  **
  ** Examples:
  **    "foo".trim    =>  "foo"
  **    " foo ".trim  =>  "foo "
  **
  Str trimStart()

  **
  ** Trim whitespace only from the end of the string.
  ** See `trim` for definition of whitespace.
  **
  ** Examples:
  **    "foo".trim    =>  "foo"
  **    " foo ".trim  =>  " foo"
  **
  Str trimEnd()

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
  Str[] split(Int? separator := null, Bool trim := true)

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
  Str[] splitLines()

  **
  ** Replace all occurrences of 'from' with 'to'.
  **
  ** Examples:
  **   "hello".replace("hell", "t")  =>  "to"
  **   "aababa".replace("ab", "-")   =>  "a--a"
  **
  Str replace(Str from, Str to)

  **
  ** Count the number of newline combinations: "\n", "\r", or "\r\n".
  **
  Int numNewlines()

  **
  ** Return if every character in this Str is a US-ASCII character
  ** less than 128.
  **
  Bool isAscii()

  **
  ** Return if every character in this Str is whitespace: space \t \n \r \f
  **
  Bool isSpace()

  **
  ** Return if every character in this Str is ASCII uppercase: 'A'-'Z'.
  **
  Bool isUpper()

  **
  ** Return if every character in this Str is ASCII lowercase: 'a'-'z'.
  **
  Bool isLower()

  **
  ** Return if every char is an ASCII [letter]`Int.isAlpha`.
  **
  Bool isAlpha()

  **
  ** Return if every char is an ASCII [alpha-numeric]`Int.isAlphaNum`.
  **
  Bool isAlphaNum()

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
  Bool toBool(Bool checked := true)

  **
  ** Convenience for `Int.fromStr` using this string.
  **
  Int toInt(Int radix := 10, Bool checked := true)

  **
  ** Convenience for `Float.fromStr` using this string.
  **
  Float toFloat(Bool checked := true)

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
  Str toCode(Int quote := '"', Bool escapeUnicode := false)

  **
  ** Return this string as valid XML text.  The special control
  ** characters amp, lt, apos and quot are always escaped.  The
  ** gt char is escaped only if it is the first char or if preceeded
  ** by the ']' char.  Also see `OutStream.writeXml` which is more
  ** efficient if streaming.
  **
  Str toXml()

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

  ByteArray toUtf8()

  static new fromUtf8(ByteArray ba)

  protected override Void finalize()
}