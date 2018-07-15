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
  sun,
  ** Monday
  mon,
  ** Tuesday
  tue,
  ** Wednesday
  wed,
  ** Thursday
  thu,
  ** Friday
  fri,
  ** Saturday
  sat

  **
  ** Return the day after this weekday.
  **
  @Operator Weekday increment() {
    o := this.ordinal + 1
    return Weekday.vals[o]
  }

  **
  ** Return the day before this weekday.
  **
  @Operator Weekday decrement() {
    o := this.ordinal - 1
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
    result := ""
    switch(this) {
      case sun:
      result = "Sunday"
      case mon:
      result = "Monday"
      case tue:
      result = "Tuesday"
      case wed:
      result = "Wednesday"
      case thu:
      result = "Thursday"
      case fri:
      result = "Friday"
      case sat:
      result = "Saturday"
    }

    if (pattern == null || pattern == "WWW") {
      return result[0..<3]
    }
    return result
  }

  **
  ** Get the abbreviated name for the current locale.
  ** Configured by the 'sys::<name>Abbr' localized property.
  **
  Str localeAbbr() {
    //TODO
    toStr
  }

  **
  ** Get the full name for the current locale.
  ** Configured by the 'sys::<name>Full' localized property.
  **
  Str localeFull() {
    //TODO
    toStr
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