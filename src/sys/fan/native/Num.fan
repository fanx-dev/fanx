//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   8 Mar 06  Brian Frank  Creation
//

**
** Num is the base class for number classes: `Int`, `Float`, and `Decimal`.
**
native const abstract class Num
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** internal constructor.
  **
  //internal new make()

//////////////////////////////////////////////////////////////////////////
// Virtuals
//////////////////////////////////////////////////////////////////////////

  **
  ** Convert this number to an Int.
  **
  virtual Int toInt()

  **
  ** Convert this number to a Float.
  **
  virtual Float toFloat()

  **
  ** Convert this number to a Decimal.
  **
  //TODO
  //Decimal toDecimal()

//////////////////////////////////////////////////////////////////////////
// Locale
//////////////////////////////////////////////////////////////////////////
/*
  **
  ** Get the current locale's decimal separator.
  ** For example in the the US this is a dot.
  **
  static Str localeDecimal()

  **
  ** Get the current locale's separator for grouping thousands
  ** together.  For example in the the US this is a comma.
  **
  static Str localeGrouping()

  **
  ** Get the current locale's minus sign used to represent a negative number.
  **
  static Str localeMinus()

  **
  ** Get the current locale's symbol for the percent sign.
  **
  static Str localePercent()

  **
  ** Get the current locale's string representation for positive infinity.
  **
  static Str localePosInf()

  **
  ** Get the current locale's string representation for negative infinity.
  **
  static Str localeNegInf()

  **
  ** Get the current locale's string representation for not-a-number.
  **
  static Str localeNaN()
*/
}