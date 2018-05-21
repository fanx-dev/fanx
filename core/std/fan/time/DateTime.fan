//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Jul 06  Brian Frank  Creation
//

**
** DateTime represents an absolute instance in time.  Fantom time is
** normalized as nanosecond ticks since 1 Jan 2000 UTC with a
** supported range of 1901 to 2099.  Fantom time does not support
** leap seconds (same as Java and UNIX).  An instance of DateTime
** also models the date and time of an absolute instance against
** a specific `TimeZone`.
**
** Also see [docLang]`docLang::DateTime`.
**
@Serializable { simple = true }
const struct class DateTime
{
  // Fields Bitmask
  //   Field       Width    Mask   Start Bit
  //   ---------   ------   -----  ---------
  //   year-1900   8 bits   0xff   0
  //   month       4 bits   0xf    8
  //   day         5 bits   0x1f   12
  //   hour        5 bits   0x1f   17
  //   min         6 bits   0x3f   22
  //   weekday     3 bits   0x7    28
  //   dst         1 bit    0x1    31

  private static const Int minTicks   := -3124137600000000000 // 1901
  private static const Int maxTicks   := 3155760000000000000  // 2100

  private const Int ticks      // ns ticks from 1-Jan-2000 UTC
  private const Int fields     // bitmask of year, month, day, etc
  private const TimeZone tz    // time used to resolve fields

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Return the current time using `TimeZone.cur`.  The tolerance
  ** parameter specifies that you are willing to use a cached DateTime
  ** instance as long as (now - cached <= tolerance).  If tolerance is null,
  ** then this method always creates a new DateTime instance.  Using
  ** tolerance can increase performance and save memory.  The
  ** tolerance default is 250ms.
  **
  ** If you are using time to calculate relative time periods,
  ** then use `Duration.now` instead.  Duration is more efficient
  ** and won't cause you grief when the system clock is modified.
  **
  native static DateTime now(Duration? tolerance := 250ms)

  **
  ** Return the current time using `TimeZone.utc`.
  ** See `now` for a description of the tolerance parameter.
  **
  native static DateTime nowUtc(Duration? tolerance := 250ms)

  **
  ** Return the current time as nanosecond ticks since 1 Jan 2000 UTC.
  **
  private native static Int nowTicks()

  **
  ** Return the current time as nanosecond ticks since 1 Jan 2000 UTC,
  ** but with the guarantee that every call returns a unique value for
  ** the lifetime of this VM.  Since most platforms don't actually support
  ** nanosecond resolution, the unused nanoseconds are used as a counter
  ** to ensure uniqueness.  However, bursts of calls may result in a
  ** drift from the actual system time.  For example if the platform's
  ** clock supports millisecond resolution, then calling this method
  ** more than one million time within a millisecond will introduce
  ** a millisecond drift (1,000,000ns in a ms).
  **
  native static Int nowUnique()

  **
  ** Make for nanosecond ticks since 1 Jan 2000 UTC.  Throw
  ** ArgErr if ticks represent a year out of the range 1901
  ** to 2099.
  **
  native static DateTime makeTicks(Int ticks, TimeZone tz := TimeZone.cur)

  **
  ** Make for the specified date and time values:
  **  - year:  1901-2099
  **  - month: Month enumeration
  **  - day:   1-31
  **  - hour:  0-23
  **  - min:   0-59
  **  - sec:   0-59
  **  - ns:    0-999_999_999
  **  - tz:    time zone used to map date/time to ns ticks
  **
  ** Throw ArgErr is any of the parameters are out of range.
  **
  native static Int[] create(Int year, Month month, Int day, Int hour, Int min, Int sec := 0, Int ns := 0, TimeZone tz := TimeZone.cur)
  new make(Int year, Month month, Int day, Int hour, Int min, Int sec := 0, Int ns := 0, TimeZone tz := TimeZone.cur) {
    res := create(year, month, day, hour, min, sec, ns, tz)
    Int ticks := res[0]
    Int dst := res[1]
    Int weekday := res[2]

    if (year < 1901 || year > 2099) throw ArgErr.make("year " + year.toStr);
    if (month.ordinal < 0 || month.ordinal > 11)    throw ArgErr.make("month " + month.toStr);
    if (day < 1 || day > numDaysInMonth(year, month.ordinal)) throw ArgErr.make("day " + day);
    if (hour < 0 || hour > 23)      throw ArgErr.make("hour " + hour);
    if (min < 0 || min > 59)        throw ArgErr.make("min " + min);
    if (sec < 0 || sec > 59)        throw ArgErr.make("sec " + sec);
    if (ns < 0 || ns > 999999999)  throw ArgErr.make("ns " + ns);

    // fields
    Int fields := 0
    fields = fields.or(((year-1900).and(0xff)).shiftl(0))
    fields = fields.or((month.ordinal.and(0xf)).shiftl(8))
    fields = fields.or((day.and(0x1f)).shiftl(12))
    fields = fields.or((hour.and(0x1f)).shiftl(17))
    fields = fields.or((min.and(0x3f)).shiftl(22))
    fields = fields.or((weekday.and(0x7)).shiftl(28))
    fields = fields.or((dst).shiftl(31))

    // commit
    this.ticks = ticks;
    this.tz    = tz;
    this.fields   = fields;
  }

  private static Int numDaysInMonth(Int year, Int month) { Month.vals[month].numDays(year) }

  private static Int num(Str s, Int index) {
    return s.get(index) - '0';
  }

  **
  ** Parse the string into a DateTime from the programmatic encoding
  ** defined by `toStr`.  If the string cannot be parsed into a valid
  ** DateTime and checked is false then return null, otherwise throw ParseErr.
  ** Also see `fromIso` and `fromHttpStr`.
  **
  static new fromStr(Str s, Bool checked := true, Bool iso := false) {
    try
    {
      // YYYY-MM-DD'T'hh:mm:ss
      year  := num(s, 0)*1000 + num(s, 1)*100 + num(s, 2)*10 + num(s, 3);
      month := num(s, 5)*10   + num(s, 6) - 1;
      day   := num(s, 8)*10   + num(s, 9);
      hour  := num(s, 11)*10  + num(s, 12);
      min   := num(s, 14)*10  + num(s, 15);
      sec   := num(s, 17)*10  + num(s, 18);

      // check separator symbols
      if (s.get(4)  != '-' || s.get(7)  != '-' ||
          s.get(10) != 'T' || s.get(13) != ':' ||
          s.get(16) != ':')
        throw Err();

      // optional .FFFFFFFFF
      i := 19;
      ns := 0;
      tenth := 100000000;
      if (s.get(i) == '.')
      {
        ++i;
        while (true)
        {
          c := s.get(i);
          if (c < '0' || c > '9') break;
          ns += (c - '0') * tenth;
          tenth /= 10;
          ++i;
        }
      }

      // zone offset
      offset := 0;
      c := s.get(i++);
      if (c != 'Z')
      {
        offHour := num(s, i++)*10 + num(s, i++);
        if (s.get(i++) != ':') throw Err();
        offMin  := num(s, i++)*10 + num(s, i++);
        offset = offHour*3600 + offMin*60;
        if (c == '-') offset = -offset;
        else if (c != '+') throw Err();
      }

      // timezone - we share this method b/w fromStr and fromIso
      TimeZone? tz;
      if (iso)
      {
        if (i < s.size) throw Err();
        tz = TimeZone.fromGmtOffset(offset);
      }
      else
      {
        if (s.get(i++) != ' ') throw Err();
        tz = TimeZone.fromStr(s[i..-1], true);
      }

      return DateTime(year, Month.vals[month], day, hour, min, sec, ns, tz);
    }
    catch (ParseErr e)
    {
      if (!checked) return defVal;
      throw e;
    }
    catch (Err e)
    {
      if (!checked) return defVal;
      throw ParseErr.make("DateTime:$s");
    }
  }

  **
  ** Get the boot time of the Fantom VM with `TimeZone.cur`
  **
  native static DateTime boot()

  **
  ** Default value is "2000-01-01T00:00:00Z UTC".
  **
  static const DateTime defVal := make(2000, Month.jan, 1, 0, 0, 0, 0, TimeZone.utc)

  **
  ** Private constructor.
  **
  //private new privateMake()

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  **
  ** Two times are equal if have identical nanosecond ticks.
  **
  override Bool equals(Obj? that) {
    if (that is DateTime)
    {
      return ticks == ((DateTime)that).ticks;
    }
    return false;
  }

  **
  ** Return nanosecond ticks for the hashcode.
  **
  override Int hash() { ticks }

  **
  ** Compare based on nanosecond ticks.
  **
  override Int compare(Obj that) {
    return ticks - ((DateTime)that).ticks
  }

  **
  ** Return programmatic string encoding formatted as follows:
  **   "YYYY-MM-DD'T'hh:mm:ss.FFFFFFFFFz zzzz"
  **
  ** See `toLocale` for the pattern legend.  The base of the
  ** string encoding conforms to ISO 8601 and XML Schema
  ** Part 2.  The Fantom format also appends the timezone name to
  ** avoid the ambiguities associated with interpretting the time
  ** zone offset.  Also see `toIso` and `toHttpStr`.
  **
  ** Examples:
  **   "2000-04-03T00:00:00.123Z UTC"
  **   "2006-10-31T01:02:03-05:00 New_York"
  **   "2009-03-10T11:33:20Z London"
  **   "2009-03-01T12:00:00+01:00 Amsterdam"
  **
  override Str toStr() { toLocale("YYYY-MM-DD'T'hh:mm:ss.FFFFFFFFFz zzzz") }

//////////////////////////////////////////////////////////////////////////
// Access
//////////////////////////////////////////////////////////////////////////

  **
  ** Return number of nanosecond ticks since 1 Jan 2000 UTC.
  ** Dates before this epoch will return a negative integer.
  **
  //Int ticks()

  **
  ** Get the date component of this timestamp.
  **
  Date date() { Date(year(), month, day) }

  **
  ** Get the time component of this timestamp.
  **
  Time time() { Time(hour, min, sec, nanoSec) }

  **
  ** Get the year as a number such as 2007.
  **
  Int year() { (fields.and(0xff)) + 1900 }

  **
  ** Get the month of this date.
  **
  Month month() { Month.vals[(fields.shiftr(8)).and(0xf)] }

  **
  ** Get the day of the month as a number between 1 and 31.
  **
  Int day() { fields.shiftr(12).and(0x1f) }

  **
  ** Get the hour of the time as a number between 0 and 23.
  **
  Int hour() { fields.shiftr(17).and(0x1f) }

  **
  ** Get the minutes of the time as a number between 0 and 59.
  **
  Int min() { fields.shiftr(22).and(0x3f) }

  native private Int yearTicks()
  **
  ** Get the whole seconds of the time as a number between 0 and 59.
  **
  Int sec() {
    rem := ticks >= 0 ? ticks : ticks - yearTicks
    return ((rem % Duration.nsPerMin) / Duration.nsPerSec);
  }

  **
  ** Get the number of nanoseconds (the fraction of seconds) as
  ** a number between 0 and 999,999,999.
  **
  Int nanoSec() {
    rem := ticks >= 0 ? ticks : ticks - yearTicks
    return (rem % Duration.nsPerSec);
  }

  **
  ** Get the day of the week for this time.
  **
  Weekday weekday() { Weekday.vals[(fields.shiftr(28)).and(0x7)] }

  **
  ** Get the time zone associated with this date time.
  **
  //TimeZone tz()

  **
  ** Return if this time is within daylight savings time
  ** for its associated time zone.
  **
  Bool dst() { ((fields.shiftr(31)).and(0x1)) != 0; }

  **
  ** Get the time zone's abbreviation for this time.
  ** See `TimeZone.stdAbbr` and `TimeZone.dstAbbr`.
  **
  Str tzAbbr() { return dst ? tz.dstAbbr(year) : tz.stdAbbr(year) }

  **
  ** Return the day of the year as a number between
  ** 1 and 365 (or 1 to 366 if a leap year).
  **
  native Int dayOfYear()

  **
  ** Return the week number of the year as a number
  ** between 1 and 53 using the given weekday as the
  ** start of the week (defaults to current locale).
  **
  native Int weekOfYear(Weekday startOfWeek := Weekday.localeStartOfWeek)
  /*private static Int _weekOfYear(Int year, Int month, Int day, Weekday startOfWeek)
  {
    firstWeekday := firstWeekday(year, 0); // zero based
    lastDayInFirstWeek := 7 - (firstWeekday - startOfWeek.ord)

    // special case for first week
    if (month == 0 && day <= lastDayInFirstWeek) return 1;

    // compute from dayOfYear - lastDayInFirstWeek
    doy := dayOfYear(year, month, day) + 1;
    woy := (doy - lastDayInFirstWeek - 1) / 7;
    return woy + 2; // add first week and make one based
  }
  */

  **
  ** Return the number of hours for this date and this timezone.
  ** Days which transition to DST will be 23 hours and days which
  ** transition back to standard time will be 25 hours.  Note there
  ** one timezone "Lord_Howe" which has a 30min offset which is
  ** not handled by this method (WTF).
  **
  Int hoursInDay() { 24 }

//////////////////////////////////////////////////////////////////////////
// Locale
//////////////////////////////////////////////////////////////////////////

  **
  ** Format this time according to the specified pattern.  If
  ** pattern is null, then a localized default is used.  Any
  ** ASCII letter in the pattern is interpreted as follows:
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
  **   V      One/two digit week of year 1,52
  **   VV     Two digit week of year     01,52
  **   VVV    Week of year with suffix   1st,52nd
  **   h      One digit 24 hour (0-23)   3, 22
  **   hh     Two digit 24 hour (0-23)   03, 22
  **   k      One digit 12 hour (1-12)   3, 11
  **   kk     Two digit 12 hour (1-12)   03, 11
  **   m      One digit minutes (0-59)   4, 45
  **   mm     Two digit minutes (0-59)   04, 45
  **   s      One digit seconds (0-59)   4, 45
  **   ss     Two digit seconds (0-59)   04, 45
  **   SS     Optional seconds (only if non-zero)
  **   f*     Fractional secs trailing zeros
  **   F*     Fractional secs no trailing zeros
  **   a      Lower case a/p for am/pm   a, p
  **   aa     Lower case am/pm           am, pm
  **   A      Upper case A/P for am/pm   A, P
  **   AA     Upper case AM/PM           AM, PM
  **   z      Time zone offset           Z, +03:00 (ISO 8601, XML Schema)
  **   zzz    Time zone abbr             EST, EDT
  **   zzzz   Time zone name             New_York
  **   'xyz'  Literal characters
  **
  ** A symbol immediately preceding a "F" pattern with a no
  ** fraction to print is skipped.
  **
  ** Examples:
  **   YYYY-MM-DD'T'hh:mm:ss.FFFz  =>  2009-01-16T09:57:35.097-05:00
  **   DD MMM YYYY                 =>  06 Jan 2009
  **   DD/MMM/YY                   =>  06/Jan/09
  **   MMMM D, YYYY                =>  January 16, 2009
  **   hh:mm:ss.fff zzzz           =>  09:58:54.845 New_York
  **   k:mma                       =>  9:58a
  **   k:mmAA                      =>  9:58AM
  **
  native Str toLocale(Str? pattern := null, Locale locale := Locale.cur)

  **
  ** Parse a string into a DateTime using the given pattern.  If
  ** string is not a valid format then return null or raise ParseErr
  ** based on checked flag.  See `toLocale` for pattern syntax.
  **
  ** The timezone is inferred from the zone pattern, or else the
  ** given 'tz' parameter is used for the timezone.  The 'z' pattern
  ** will match "hh:mm", "hhmm", or "hh".  If only a zone offset is
  ** available and it doesn't match the expected 'tz' parameter,
  ** then use a "GMT+/-" timezone.  Note that if offset is a fractional
  ** hour such as GMT-3:30, then result will have ticks, but its
  ** tz will be floored hour based GMT timezone such as GMT-3.
  **
  native static DateTime? fromLocale(Str str, Str pattern, TimeZone tz := TimeZone.cur, Bool checked := true)

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  **
  ** Convert this DateTime to the specific timezone.  The absolute point
  ** time as ticks remains the same, but the date and time fields will
  ** be converted to represent the new time zone.  However if converting
  ** to or from `TimeZone.rel` then the resulting DateTime has the same
  ** day and time.  Also see `toUtc` and `toRel`.
  **
  ** Example:
  **   dt := DateTime("2010-06-03T10:30:00-04:00 New_York")
  **   dt.toUtc  =>  2010-06-03T14:30:00Z UTC
  **   dt.toRel  =>  2010-06-03T10:30:00Z Rel
  **
  DateTime toTimeZone(TimeZone tz) {
    if (this.tz == tz) return this;
    if (tz == TimeZone.rel || this.tz == TimeZone.rel)
    {
      return DateTime(year, month, day,
                          hour, min, sec, nanoSec,
                          tz);
    }
    else
    {
      return makeTicks(ticks, tz);
    }
  }

  **
  ** Convenience for 'toTimeZone(TimeZone.utc)'.
  **
  DateTime toUtc() { toTimeZone(TimeZone.utc) }

  **
  ** Convenience for 'toTimeZone(TimeZone.rel)'.
  ** See [docLang]`docLang::DateTime#relTimeZone`.
  **
  DateTime toRel() { toTimeZone(TimeZone.rel) }

  **
  ** Return the delta between this and the given time.
  **
  ** Example:
  **   elapsed := DateTime.now - startTime
  **
  @Operator Duration minusDateTime(DateTime time) { Duration.fromDateTime(ticks-time.ticks); }

  **
  ** Add a duration to compute a new time.  This method works
  ** off absolute time, so adding 1days means to add 24 hours to
  ** the ticks.  This might be a different time of day if on
  ** a DST boundry.  Use `Date.plus` for daily increments.
  **
  ** Example:
  **   nextHour := DateTime.now + 1hr
  **
  @Operator DateTime plus(Duration duration) { DateTime.makeTicks(ticks+duration.toNanos, tz); }

  **
  ** Subtract a duration to compute a new time.  This method works
  ** off absolute time, so subtracting 1days means to subtract 24
  ** hours from the ticks.  This might be a different time of day if
  ** on a DST boundry.  Use `Date.minus` for daily increments.
  **
  ** Example:
  **   prevHour := DateTime.now - 1hr
  **
  @Operator DateTime minus(Duration duration) { DateTime.makeTicks(ticks-duration.toNanos); }

  **
  ** Return a new DateTime with this time's nanosecond ticks truncated
  ** according to the specified accuracy.  For example 'floor(1min)'
  ** will truncate this time to the minute such that seconds
  ** are 0.0.  This method is strictly based on absolute ticks,
  ** it does not take into account wall-time rollovers.
  **
  DateTime floor(Duration accuracy) {
    if (ticks % accuracy.toNanos == 0) return this;
    return makeTicks(ticks - (ticks % accuracy.toNanos), tz);
  }

  **
  ** Return a DateTime for the beginning of the current day at midnight.
  **
  DateTime midnight() { DateTime(year, month, day, 0, 0, 0, 0, tz) }

  **
  ** Return if the time portion is "00:00:00".
  **
  Bool isMidnight() { hour == 0 && min == 0 && sec == 0 && nanoSec == 0; }

  **
  ** Return if the specified year is a leap year.
  **
  static Bool isLeapYear(Int year) {
    if ((year.and(3)) != 0) return false
    return (year % 100 != 0) || (year % 400 == 0)
  }

  **
  ** This method computes the day of month (1-31) for a given
  ** weekday.  The pos parameter specifies the first, second,
  ** third, or fourth occurence of the weekday.  A negative pos
  ** is used to compute the last (or second to last, etc) weekday
  ** in the month.
  **
  ** Examples:
  **   // compute the second monday in Apr 2007
  **   weekdayInMonth(2007, Month.apr, Weekday.mon, 2)
  **
  **   // compute the last sunday in Oct 2007
  **   weekdayInMonth(2007, Month.oct, Weekday.sun, -1)
  **
  native static Int weekdayInMonth(Int year, Month mon, Weekday weekday, Int pos)

//////////////////////////////////////////////////////////////////////////
// Java
//////////////////////////////////////////////////////////////////////////

  **
  ** Create date for Java milliseconds since the epoch of 1 Jan 1970
  ** using the specified timezone (defaults to current).  If millis
  ** are less than or equal to zero then return null.
  **
  native static DateTime? fromJava(Int millis, TimeZone tz := TimeZone.cur)

  **
  ** Get this date in Java milliseconds since the epoch of 1 Jan 1970.
  **
  native Int toJava()

//////////////////////////////////////////////////////////////////////////
// ISO 8601
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse an ISO 8601 timestamp.  If invalid format and checked is
  ** false return null, otherwise throw ParseErr.  The following formats
  ** are supported:
  **   YYYY-MM-DD'T'hh:mm:ss[.FFFFFFFFF]
  **   YYYY-MM-DD'T'hh:mm:ss[.FFFFFFFFF]+HH:MM
  **   YYYY-MM-DD'T'hh:mm:ss[.FFFFFFFFF]-HH:MM
  **
  ** If a timezone offset is specified, then one the predefined "Etc/GMT+x"
  ** timezones are used for the result:
  **   DateTime("2009-01-15T12:00:00Z")       =>  2009-01-15T12:00:00Z UTC
  **   DateTime("2009-01-15T12:00:00-05:00")  =>  2009-01-15T12:00:00-05:00 GMT+5
  **
  ** Also see `toIso`, `fromStr`, and `fromHttpStr`.
  **
  static DateTime? fromIso(Str s, Bool checked := true) { fromStr(s, checked, true) }

  **
  ** Format this instance according to ISO 8601 using the pattern:
  **   YYYY-MM-DD'T'hh:mm:ss.FFFz
  **
  ** Also see `fromIso`, `toStr`, and `toHttpStr`.
  **
  Str toIso() { toLocale("YYYY-MM-DD'T'hh:mm:ss.FFFFFFFFFz") }

//////////////////////////////////////////////////////////////////////////
// HTTP
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse an HTTP date according to the RFC 2616 section 3.3.1.  If
  ** invalid format and checked is false return null, otherwise
  ** throw ParseErr.  The following date formats are supported:
  **
  **   Sun, 06 Nov 1994 08:49:37 GMT  ; RFC 822, updated by RFC 1123
  **   Sunday, 06-Nov-94 08:49:37 GMT ; RFC 850, obsoleted by RFC 1036
  **   Sun Nov  6 08:49:37 1994       ; ANSI C's asctime() format
  **
  native static DateTime? fromHttpStr(Str s, Bool checked := true)

  **
  ** Format this time for use in an MIME or HTTP message
  ** according to RFC 2616 using the RFC 1123 format:
  **
  **   Sun, 06 Nov 1994 08:49:37 GMT
  **
  Str toHttpStr() {
    toTimeZone(TimeZone.utc).toLocale("WWW, DD MMM YYYY hh:mm:ss", Locale.en) + " GMT"
  }

//////////////////////////////////////////////////////////////////////////
// Misc
//////////////////////////////////////////////////////////////////////////

  **
  ** Get this DateTime as a Fantom expression suitable for code generation.
  **
  Str toCode() {
    if (equals(defVal)) return "DateTime.defVal"
    return "DateTime(\"" + toStr + "\")"
  }
}