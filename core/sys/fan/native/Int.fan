//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2 Dec 05  Brian Frank  Creation
//

facet class I8 {}
facet class I16 {}
facet class I32 {}
facet class I64 {}

facet class U8 {}
facet class U16 {}
facet class U32 {}
facet class U64 {}

**
** Int is used to represent a signed 64-bit integer.
**
@Serializable { simple = true }
native const struct class Int : Num
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse a Str into a Int using the specified radix.  Unless
  ** the radix is 10, then a leading minus sign is illegal.
  ** If invalid format and checked is false return null,
  ** otherwise throw ParseErr.
  **
  static new fromStr(Str s, Int radix := 10, Bool checked := true)

  **
  ** Generate a random number.  If range is null then all 2^64
  ** integer values (both negative and positive) are produced with
  ** equal probability.  If range is non-null, then the result
  ** is guaranteed to be inclusive of the range.  Also see `Float.random` ,
  ** `Range.random` , `List.random` , and `util::Random`.
  **
  ** Examples:
  **   r := Int.random
  **   r := Int.random(0..100)
  **
  static Int random(Range? r := null)

  **
  ** Private constructor.
  **
  //TODO static new
  static private new privateMake()

  **
  ** Default value is zero.
  **
  const static Int defVal

  **
  ** Maximum value which can be stored in a
  ** signed 64-bit Int: 9,223,372,036,854,775,807
  **
  const static Int maxVal

  **
  ** Minimum value which can be stored in a
  ** signed 64-bit Int: -9,223,372,036,854,775,808
  **
  const static Int minVal

  //const static Int invalidVal

//////////////////////////////////////////////////////////////////////////
// Obj Overrides
//////////////////////////////////////////////////////////////////////////

  **
  ** Return true if same integer value.
  **
  override Bool equals(Obj? obj)

  **
  ** Compare based on integer value.
  **
  override Int compare(Obj obj)

  **
  ** Return this.
  **
  override Int hash()

//////////////////////////////////////////////////////////////////////////
// Operations
//////////////////////////////////////////////////////////////////////////

  ////////// unary //////////

  ** Negative of this.  Shortcut is -a.
  @Operator Int negate()

  ** Increment by one.  Shortcut is ++a or a++.
  @Operator Int increment()

  ** Decrement by one.  Shortcut is --a or a--.
  @Operator Int decrement()

  ////////// mult //////////

  ** Multiply this with b.  Shortcut is a*b.
  @Operator Int mult(Int b)

  ** Multiply this with b.  Shortcut is a*b.
  @Operator Float multFloat(Float b)

  ** Multiply this with b.  Shortcut is a*b.
  //@Operator Decimal multDecimal(Decimal b)

  ////////// div //////////

  ** Divide this by b.  Shortcut is a/b.
  @Operator Int div(Int b)

  ** Divide this by b.  Shortcut is a/b.
  @Operator Float divFloat(Float b)

  ** Divide this by b.  Shortcut is a/b.
  //@Operator Decimal divDecimal(Decimal b)

  ////////// mod //////////

  ** Return remainder of this divided by b.  Shortcut is a%b.
  @Operator Int mod(Int b)

  ** Return remainder of this divided by b.  Shortcut is a%b.
  @Operator Float modFloat(Float b)

  ** Return remainder of this divided by b.  Shortcut is a%b.
  //@Operator Decimal modDecimal(Decimal b)

  ////////// plus //////////

  ** Add this with b.  Shortcut is a+b.
  @Operator Int plus(Int b)

  ** Add this with b.  Shortcut is a+b.
  @Operator Float plusFloat(Float b)

  ** Add this with b.  Shortcut is a+b.
  //@Operator Decimal plusDecimal(Decimal b)

  ////////// minus //////////

  ** Subtract b from this.  Shortcut is a-b.
  @Operator Int minus(Int b)

  ** Subtract b from this.  Shortcut is a-b.
  @Operator Float minusFloat(Float b)

  ** Subtract b from this.  Shortcut is a-b.
  //@Operator Decimal minusDecimal(Decimal b)

//////////////////////////////////////////////////////////////////////////
// Bitwise
//////////////////////////////////////////////////////////////////////////

  **
  ** Bitwise not/inverse of this.
  **
  Int not()

  **
  ** Bitwise-and of this and b.
  **
  Int and(Int b)

  **
  ** Bitwise-or of this and b.
  **
  Int or(Int b)

  **
  ** Bitwise-exclusive-or of this and b.
  **
  Int xor(Int b)

  **
  ** Bitwise left shift of this by b.
  **
  Int shiftl(Int b)

  **
  ** Bitwise right shift of this by b.  Zero is shifted into the
  ** highest bits performing like an unsigned shift.  This is equivalent
  ** to the Java '>>>' operator.
  **
  Int shiftr(Int b)

/////////////////////////////////////////////////////////////////////////
// Math
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the absolute value of this integer.  If this value is
  ** positive then return this, otherwise return the negation.
  **
  Int abs()

  **
  ** Return the smaller of this and the specified Int values.
  **
  Int min(Int that)

  **
  ** Return the larger of this and the specified Int values.
  **
  Int max(Int that)

  **
  ** Return this value raised to the specified power.
  ** Throw ArgErr if pow is less than zero.
  **
  Int pow(Int pow)

  **
  ** Return if this integer is evenly divisible by two.
  **
  Bool isEven()

  **
  ** Return if this integer is not evenly divisible by two.
  **
  Bool isOdd()

/////////////////////////////////////////////////////////////////////////
// Char
//////////////////////////////////////////////////////////////////////////

  **
  ** Return if this Unicode char is whitespace: space \t \n \r \f
  **
  Bool isSpace()

  **
  ** Return if this Unicode char is an ASCII alpha char: isUpper||isLower
  **
  Bool isAlpha()

  **
  ** Return if this Unicode char is an ASCII alpha-numeric char: isAlpha||isDigit
  **
  Bool isAlphaNum()

  **
  ** Return if this Unicode char is an ASCII uppercase alphabetic char: A-Z
  **
  Bool isUpper()

  **
  ** Return if this Unicode char is an ASCII lowercase alphabetic char: a-z
  **
  Bool isLower()

  **
  ** If this Unicode char is an ASCII lowercase char, then return
  ** it as uppercase, otherwise return this.
  **
  ** Example:
  **   'a'.upper => 'A'
  **   '4'.upper => '4'
  **
  Int upper()

  **
  ** If this Unicode char is an ASCII uppercase char, then return
  ** it as lowercase, otherwise return this.
  **
  ** Example:
  **   'A'.lower => 'a'
  **   'h'.lower => 'h'
  **
  Int lower()

  **
  ** Return if this Unicode char is an digit in the specified radix.
  ** A decimal radix of ten returns true for 0-9.  A radix of 16
  ** also returns true for a-f and A-F.
  **
  ** Example:
  **   '3'.toDigit     => true
  **   3.toDigit       => false
  **   'B'.toDigit(16) => true
  **
  Bool isDigit(Int radix := 10)

  **
  ** Convert this number into a Unicode char '0'-'9'.  If radix is
  ** is greater than 10, then use a lower case letter.  Return null if
  ** this number cannot be represented as a single digit character for
  ** the specified radix.
  **
  ** Example:
  **   3.toDigit      => '3'
  **   15.toDigit(16) => 'f'
  **   99.toDigit     => null
  **
  Int? toDigit(Int radix := 10)

  **
  ** Convert a Unicode digit character into a number for the specified
  ** radix.  Return null if this char is not a valid digit.
  **
  ** Example:
  **   '3'.fromDigit     => 3
  **   'f'.fromDigit(16) => 15
  **   '%'.fromDigit     => null
  **
  Int? fromDigit(Int radix := 10)

  **
  ** Return if the two Unicode chars are equal without regard
  ** to ASCII case.
  **
  Bool equalsIgnoreCase(Int ch)

/////////////////////////////////////////////////////////////////////////
// Locale
//////////////////////////////////////////////////////////////////////////

  **
  ** Format this integer number for the current locale.
  ** If pattern is null, then the locale's default pattern is used.
  ** See `Float.toLocale` for pattern language.  Fractional formatting
  ** is not supported for integers.
  **
  ** In addition 'Int.toLocale' supports the "B" pattern which will
  ** format a number of bytes with the appropiate B, KB, MB, GB suffix
  ** based on the magnitide (1024B == 1KB).
  **
  ** Examples:
  **   3.toLocale("00")             =>  03
  **   3.toLocale("000")            =>  003
  **   123456789.toLocale("#,###")  =>  123,456,789
  **   123.toLocale("B")            =>  123B
  **   1234.toLocale("B")           =>  1.2KB
  **   100_000.toLocale("B")        =>  98KB
  **   (3*1024*1024).toLocale("B")  =>  3MB
  **
  //Str toLocale(Str? pattern := null, Locale locale := Locale.cur)
/*
  **
  ** Return if this Unicode char is an uppercase letter in
  ** the current locale.  See also `localeIsLower` and `isUpper`.
  **
  Bool localeIsUpper()

  **
  ** Return if this Unicode char is a lowercase letter in
  ** the current locale.  See also `localeIsUpper` and `isLower`.
  **
  Bool localeIsLower()

  **
  ** If this Unicode char is a lowercase char, then return
  ** it as uppercase according to the current locale.  Note that
  ** Unicode contains some case conversion rules that don't work
  ** correctly on a single character, so `Str.localeLower` should
  ** be preferred.  See also `localeLower` and `upper`.
  **
  Int localeUpper()

  **
  ** If this Unicode char is an uppercase char, then return
  ** it as lowercase according to the current locale.  Note that
  ** Unicode contains some case conversion rules that don't work
  ** correctly on a single character, so `Str.localeLower` should
  ** be preferred.  See also `localeUpper` and `lower`.
  **
  Int localeLower()
*/
/////////////////////////////////////////////////////////////////////////
// Conversion
//////////////////////////////////////////////////////////////////////////

  **
  ** Return decimal string representation.
  **
  override Str toStr()

  **
  ** Return hexdecimal string representation.  If width is non-null,
  ** then leading zeros are prepended to ensure the specified number
  ** of nibble characters.
  **
  ** Examples:
  **   255.toHex     =>  "ff"
  **   255.toHex(4)  =>  "00ff"
  **
  Str toHex(Int width := 0)

  **
  ** Return string representation in given radix.  If width is non-null,
  ** then leading zeros are prepended to ensure the specified width.
  **
  ** Examples:
  **   255.toRadix(8)    =>  "ff"
  **   255.toRadix(8, 3) =>  "00ff"
  **
  Str toRadix(Int radix, Int width := 0)

  **
  ** Map as a Unicode code point to a single character Str.
  **
  Str toChar()

  **
  ** Get this Int as a Fantom code literal.  Base must be 10 or 16.
  **
  Str toCode(Int base := 10)

  **
  ** Convert nano-seconds ticks to a Duration.
  ** Convenience for `Duration.make`.
  **
  //Duration toDuration()

  **
  ** Convert nano-seconds ticks since 1-Jan-2000 to a DateTime.
  ** Convenience for `DateTime.makeTicks`.
  **
  //DateTime toDateTime(TimeZone tz := TimeZone.cur)

/////////////////////////////////////////////////////////////////////////
// Closures
//////////////////////////////////////////////////////////////////////////

  **
  ** Call the specified function to this times passing the current counter.
  ** The counter begins at zero.  Also see `Range.each`.
  **
  ** Example:
  **   3.times |i| { echo(i) }  =>  0, 1, 2
  **
  Void times(|Int i| c)

}