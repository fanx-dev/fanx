//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Sep 06  Brian Frank  Creation
//

**
** Enum for twelve months of the year.
**
enum class Month
{
  ** January
  jan("January"),

  ** February
  feb("February"),

  ** March
  mar("March"),

  ** April
  apr("April"),

  ** May
  may("May"),

  ** June
  jun("June"),

  ** July
  jul("July"),

  ** August
  aug("August"),

  ** September
  sep("September"),

  ** October
  oct("October"),

  ** November
  nov("November"),

  ** December
  dec("December")

  private const Str fullName
  private const Str abbrName

  private new make(Str fullName) {
    this.fullName = fullName
    this.abbrName = name.capitalize
  }

  **
  ** Return the month after this month.
  **
  @Operator Month increment() {
    m := (ordinal + 1) % Month.vals.size
    return Month.vals[m]
  }

  **
  ** Return the month before this month.
  **
  @Operator Month decrement() {
    m := (ordinal - 1) % Month.vals.size
    return Month.vals[m]
  }

  static const Int[] daysInMon     := [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ]
  static const Int[] daysInMonLeap := [ 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ]

  **
  ** Return the number of days in this month for the specified year.
  **
  Int numDays(Int year) {
    if (DateTime.isLeapYear(year))
      return daysInMonLeap[ordinal]
    else
      return daysInMon[ordinal]
  }

  **
  ** Return the month as a localized string according to the
  ** specified pattern.  The pattern rules are a subset of the
  ** `DateTime.toLocale`:
  **
  **    M      One/two digit month        6, 11
  **    MM     Two digit month            06, 11
  **    MMM    Three letter abbr month    Jun, Nov
  **    MMMM   Full month name            June, November
  **
  ** If pattern is null it defaults to "MMM".  Also see `localeAbbr`
  ** and `localeFull`.
  **
  Str toLocale(Str? pattern := null, Locale locale := Locale.cur) {
    if (pattern == null) pattern = "MMM"
    else {
      if (pattern.size == 0 || pattern.size > 4) throw ArgErr(pattern)
      if (pattern.any { it != 'M' }) throw ArgErr(pattern)
    }

    switch (pattern.size)
    {
      case 1: return (ordinal+1).toStr
      case 2: return ordinal < 9 ? "0" + (ordinal+1).toStr : (ordinal+1).toStr
      case 3: return abbrName
      case 4: return fullName
    }
    return abbrName
  }

  **
  ** Get the abbreviated name for the current locale.
  ** Configured by the 'sys::<name>Abbr' localized property.
  **
  Str localeAbbr() { abbrName }

  **
  ** Get the full name for the current locale.
  ** Configured by the 'sys::<name>Full' localized property.
  **
  Str localeFull() { fullName }

}