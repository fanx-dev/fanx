//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Apr 08  Brian Frank  Creation
//

**
** Decimal is used to represent a decimal floating point
** more precisely than a Float.  Decimal is the preferred
** numeric type for financial applications.
**
@Serializable { simple = true }
native const struct class Decimal : Num
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse a Str into a Decimal.  If invalid format and
  ** checked is false return null, otherwise throw ParseErr.
  **
  static new fromStr(Str s, Bool checked := true)


  extension static Decimal toDecimal(Num f)

  **
  ** Default value is 0.
  **
  static const Decimal defVal

  **
  ** Private constructor.
  **
  //private new privateMake()

//////////////////////////////////////////////////////////////////////////
// Obj Overrides
//////////////////////////////////////////////////////////////////////////

  **
  ** Return true if same decimal with same scale.
  **
  override Bool equals(Obj? obj)

  **
  ** Compare based on decimal value, scale is not
  ** considered for equality (unlike `equals`).
  **
  override Int compare(Obj obj)

  **
  ** Return platform specific hashcode.
  **
  override Int hash()

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  ////////// unary //////////

  ** Negative of this.  Shortcut is -a.
  @Operator Decimal negate()

  ** Increment by one.  Shortcut is ++a or a++.
  @Operator Decimal increment()

  ** Decrement by one.  Shortcut is --a or a--.
  @Operator Decimal decrement()

  ////////// mult //////////

  ** Multiply this with b.  Shortcut is a*b.
  @Operator Decimal mult(Decimal b)

  ** Multiply this with b.  Shortcut is a*b.
  @Operator Decimal multInt(Int b)

  ** Multiply this with b.  Shortcut is a*b.
  @Operator Decimal multFloat(Float b)

  ////////// div //////////

  ** Divide this by b.  Shortcut is a/b.
  @Operator Decimal div(Decimal b)

  ** Divide this by b.  Shortcut is a/b.
  @Operator Decimal divInt(Int b)

  ** Divide this by b.  Shortcut is a/b.
  @Operator Decimal divFloat(Float b)

  ////////// mod //////////

  ** Return remainder of this divided by b.  Shortcut is a%b.
  @Operator Decimal mod(Decimal b)

  ** Return remainder of this divided by b.  Shortcut is a%b.
  @Operator Decimal modInt(Int b)

  ** Return remainder of this divided by b.  Shortcut is a%b.
  @Operator Decimal modFloat(Float b)

  ////////// plus //////////

  ** Add this with b.  Shortcut is a+b.
  @Operator Decimal plus(Decimal b)

  ** Add this with b.  Shortcut is a+b.
  @Operator Decimal plusInt(Int b)

  ** Add this with b.  Shortcut is a+b.
  @Operator Decimal plusFloat(Float b)

  ////////// minus //////////

  ** Subtract b from this.  Shortcut is a-b.
  @Operator Decimal minus(Decimal b)

  ** Subtract b from this.  Shortcut is a-b.
  @Operator Decimal minusInt(Int b)

  ** Subtract b from this.  Shortcut is a-b.
  @Operator Decimal minusFloat(Float b)

/////////////////////////////////////////////////////////////////////////
// Math
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the absolute value of this decimal.  If this value is
  ** positive then return this, otherwise return the negation.
  **
  Decimal abs()

  **
  ** Return the smaller of this and the specified Decimal values.
  **
  Decimal min(Decimal that)

  **
  ** Return the larger of this and the specified Decimal values.
  **
  Decimal max(Decimal that)

//////////////////////////////////////////////////////////////////////////
// Conversion
//////////////////////////////////////////////////////////////////////////

  **
  ** Get string representation.
  **
  override Str toStr()

  **
  ** Get this Decimal as a Fantom code literal.
  **
  Str toCode()

//////////////////////////////////////////////////////////////////////////
// Locale
//////////////////////////////////////////////////////////////////////////

  **
  ** Format this decimal number for the current locale.
  ** If pattern is null, then the locale's default pattern is used.
  ** See `Float.toLocale` for pattern language and examples.
  **
  Str toLocale(Str? pattern := null)

}