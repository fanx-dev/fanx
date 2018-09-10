//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   10 Jan 09  Brian Frank  Creation
//

**
** Date represents a day in time independent of a timezone.
**
@Serializable { simple = true }
const struct class Date
{
  private const DateTime datetime

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Get today's Date using specified timezone.
  **
  static Date today(TimeZone tz := TimeZone.cur) {
    dt := DateTime.now.toTimeZone(tz)
    return dt.date
  }

  **
  ** Make for the specified date values:
  **  - year:  no restriction (although only 1901-2099 maps to DateTime)
  **  - month: Month enumeration
  **  - day:   1-31
  **
  ** Throw ArgErr is any of the parameters are out of range.
  **
  new make(Int year, Month month, Int day) {
    datetime = DateTime(year, month, day, 0, 0, 0, 0)
  }

  private static Int num(Str s, Int index) {
    return s.get(index) - '0';
  }

  **
  ** Parse the string into a Date from the programmatic encoding
  ** defined by `toStr`.  If the string cannot be parsed into a valid
  ** Date and checked is false then return null, otherwise throw
  ** ParseErr.
  **
  static new fromStr(Str s, Bool checked := true) {
    try
    {
      // YYYY-MM-DD
      year  := num(s, 0)*1000 + num(s, 1)*100 + num(s, 2)*10 + num(s, 3)
      month := num(s, 5)*10   + num(s, 6) - 1
      day   := num(s, 8)*10   + num(s, 9)

      // check separator symbols and length
      if (s[4]  != '-' || s[7]  != '-' || s.size != 10)
        throw Err()

      return Date(year, Month.vals[month], day)
    }
    catch (Err e)
    {
      if (!checked) return defVal
      throw ParseErr.make("Date:" + s)
    }
  }

  **
  ** Default value is "2000-01-01".
  **
  static const Date defVal := Date(2000, Month.vals[0], 1)


//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  **
  ** Two dates are equal if have the same year, month, and day.
  **
  override Bool equals(Obj? that) {
    if (that is Date) {
      return datetime == ((Date)that).datetime
    }
    return false
  }

  **
  ** Return hash of year, month, and day.
  **
  override Int hash() { datetime.hash }

  **
  ** Compare based on year, month, and day.
  **
  override Int compare(Obj obj) {
    this.datetime.compare(((Date)obj).datetime)
  }

  **
  ** Return programmatic ISO 8601 string encoding formatted as follows:
  **   YYYY-MM-DD
  **   2009-01-10
  **
  ** Also `fromStr`, `toIso`, and `toLocale`.
  **
  override Str toStr() {
    toLocale("YYYY-MM-DD")
  }

//////////////////////////////////////////////////////////////////////////
// Access
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the year as a number such as 2009.
  **
  Int year() { datetime.year }

  **
  ** Get the month of this date.
  **
  Month month() { datetime.month }

  **
  ** Get the day of the month as a number between 1 and 31.
  **
  Int day() { datetime.day }

  **
  ** Get the day of the week for this date.
  **
  Weekday weekday() { datetime.weekday }

  **
  ** Return the day of the year as a number between
  ** 1 and 365 (or 1 to 366 if a leap year).
  **
  Int dayOfYear() { datetime.dayOfYear }

  **
  ** Return the week number of the year as a number
  ** between 1 and 53 using the given weekday as the
  ** start of the week (defaults to current locale).
  **
  Int weekOfYear(Weekday startOfWeek := Weekday.localeStartOfWeek) {
    datetime.weekOfYear(startOfWeek)
  }

//////////////////////////////////////////////////////////////////////////
// Locale
//////////////////////////////////////////////////////////////////////////

  **
  ** Format this date according to the specified pattern.  If
  ** pattern is null, then a localized default is used.  The
  ** pattern format is the same as `DateTime.toLocale`:
  **
  **   YY     Two digit year             07
  **   YYYY   Four digit year            2007
  **   M      One/two digit month        6, 11
  **   MM     Two digit month            06, 11
  **   MMM    Three letter abbr month    Jun, Nov
  **   MMMM   Full month                 June, November
  **   D      One/two digit day          5, 28
  **   DD     Two digit day              05, 28
  **   DDD    Day with suffix            1st, 2nd, 3rd, 24th
  **   WWW    Three letter abbr weekday  Tue
  **   WWWW   Full weekday               Tuesday
  **   'xyz'  Literal characters
  **
  Str toLocale(Str? pattern := null, Locale locale := Locale.cur) {
    datetime.toLocale(pattern, locale)
  }

  **
  ** Parse a string into a Date using the given pattern.  If
  ** string is not a valid format then return null or raise ParseErr
  ** based on checked flag.  See `toLocale` for pattern syntax.
  **
  static Date? fromLocale(Str str, Str pattern, Bool checked := true) {
    dt := DateTime.fromLocale(str, pattern, TimeZone.cur, checked)
    return dt.date
  }

//////////////////////////////////////////////////////////////////////////
// ISO 8601
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse an ISO 8601 date.  If invalid format and checked is
  ** false return null, otherwise throw ParseErr.  The following
  ** format is supported:
  **   YYYY-MM-DD
  **
  ** Also see `toIso` and `fromStr`.
  **
  static Date? fromIso(Str s, Bool checked := true) { fromStr(s, checked) }

  **
  ** Format this instance according to ISO 8601 using the pattern:
  **   YYYY-MM-DD
  **
  ** Also see `fromIso` and `toStr`.
  **
  Str toIso() { toStr }

//////////////////////////////////////////////////////////////////////////
// Past/Future
//////////////////////////////////////////////////////////////////////////

  **
  ** Add the specified number of days to this date to get a date in
  ** the future.  Throw ArgErr if 'days' parameter it not an even number
  ** of days.
  **
  ** Example:
  **   Date(2008, Month.feb, 28) + 2day  =>  2008-03-01
  **
  @Operator Date plus(Duration days) {
    if (days.toNanos % Duration.nsPerDay != 0) throw ArgErr("$days")
    d := datetime + days
    return d.date
  }

  **
  ** Subtract the specified number of days to this date to get a date in
  ** the past.  Throw ArgErr if 'days' parameter it not an even number
  ** of days.
  **
  ** Example:
  **   Date(2008, Month.feb, 28) - 2day  =>  2008-02-26
  **
  @Operator Date minus(Duration days) {
    plus(-days)
  }

  **
  ** Return the delta between this and the given date.  The
  ** result is always an exact multiple of 24 hour days.
  **
  ** Example:
  **   Date(2009, Month.jan, 5) - Date(2009, Month.jan, 2)  =>  3day
  **
  @Operator Duration minusDate(Date days) {
    d := datetime - days.datetime
    return d
  }

  **
  ** Get the first day of this Date's current month.
  **
  ** Example:
  **   Date("2009-10-28").firstOfMonth  =>  2009-10-01
  **
  Date firstOfMonth() {
    if (day == 1) return this
    return Date(year, month, 1)
  }

  **
  ** Get the last day of this Date's current month.
  **
  ** Example:
  **   Date("2009-10-28").lastOfMonth  =>  2009-10-31
  **
  Date lastOfMonth() {
    last := month.numDays(year)
    if (day == last) return this
    return Date(year, month, last)
  }

//////////////////////////////////////////////////////////////////////////
// Misc
//////////////////////////////////////////////////////////////////////////

  **
  ** Return is this date equal to `today` - 1day.
  **
  Bool isYesterday() { this == today.plus(-1day) }

  **
  ** Return is this date equal to `today`.
  **
  Bool isToday() { this == today }

  **
  ** Return is this date equal to `today` + 1day.
  **
  Bool isTomorrow() { this == today + 1day }

  **
  ** Combine this Date with the given Time to return a DateTime.
  **
  DateTime toDateTime(TimeOfDay t, TimeZone tz := TimeZone.cur) { DateTime(year, month, day, t.hour, t.min, t.sec, t.nanoSec, tz) }

  **
  ** Return a DateTime for the beginning of the this day at midnight.
  **
  DateTime midnight(TimeZone tz := TimeZone.cur) { DateTime(year, month, day, 0, 0, 0, 0, tz) }

  **
  ** Get this Date as a Fantom expression suitable for code generation.
  **
  Str toCode() {
    if (equals(defVal)) return "Date.defVal"
    return "Date(\"" + toStr + "\")"
  }

}