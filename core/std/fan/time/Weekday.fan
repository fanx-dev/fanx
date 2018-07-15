//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Sep 06  Brian Frank  Creation
//

**
** Enum for seven days of the week.
**
enum class Weekday
{
  ** Sunday
  sun("Sunday"),
  ** Monday
  mon("Monday"),
  ** Tuesday
  tue("Tuesday"),
  ** Wednesday
  wed("Wednesday"),
  ** Thursday
  thu("Thursday"),
  ** Friday
  fri("Friday"),
  ** Saturday
  sat("Saturday")

  private const Str fullName
  private const Str abbrName

  private new make(Str fullName) {
    this.fullName = fullName
    this.abbrName = name.capitalize
  }

  **
  ** Return the day after this weekday.
  **
  @Operator Weekday increment() {
    o := this.ordinal + 1
    o = o % 7
    return Weekday.vals[o]
  }

  **
  ** Return the day before this weekday.
  **
  @Operator Weekday decrement() {
    o := this.ordinal - 1
    o = o % 7
    return Weekday.vals[o]
  }

  **
  ** Return the weekday as a localized string according to the
  ** specified pattern.  The pattern rules are a subset of the
  ** `DateTime.toLocale`:
  **
  **    WWW    Three letter abbr weekday  Tue
  **    WWWW   Full weekday name          Tuesday
  **
  ** If pattern is null it defaults to "WWW".  Also see `localeAbbr`
  ** and `localeFull`.
  **
  Str toLocale(Str? pattern := null, Locale locale := Locale.cur) {
    if (pattern == null || pattern == "WWW") {
      return abbrName
    }
    else if (pattern == "WWWW") {
      return fullName
    }
    throw ArgErr(pattern)
  }

  **
  ** Get the abbreviated name for the current locale.
  ** Configured by the 'sys::<name>Abbr' localized property.
  **
  Str localeAbbr() {
    abbrName
  }

  **
  ** Get the full name for the current locale.
  ** Configured by the 'sys::<name>Full' localized property.
  **
  Str localeFull() {
    fullName
  }

  **
  ** Get the first day of the week for the current locale.
  ** For example in the United States, 'sun' is considered
  ** the start of the week.  Configured by 'sys::weekdayStart'
  ** localized property.  Also see `localeVals`.
  **
  static Weekday localeStartOfWeek() {
    //TODO
    sun
  }

  **
  ** Get the days of the week ordered according to the
  ** locale's start of the week.  Also see `localeStartOfWeek`.
  **
  static Weekday[] localeVals() {
    //TODO
    vals
  }

}