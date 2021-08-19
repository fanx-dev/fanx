//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   10 Jan 09  Brian Frank  Creation
//

**
** Time represents a time of day independent of a specific
** date or timezone.
**
@Serializable { simple = true }
const struct class TimeOfDay
{
  private const Int ticks
//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the current time using the specified timezone.
  ** This method may use `DateTime.now` with the default
  ** tolerance 250ms.
  **
  static TimeOfDay now(TimeZone tz := TimeZone.cur) {
    //fromDateTime(DateTime.now.toTimeZone(tz))
    dt := DateTime.now(null).toTimeZone(tz)
    return make(dt.hour, dt.min, dt.sec, dt.nanoSec)
  }

  **
  ** Make for the specified time values:
  **  - hour:  0-23
  **  - min:   0-59
  **  - sec:   0-59
  **  - ns:    0-999_999_999
  **
  ** Throw ArgErr is any of the parameters are out of range.
  **
  new make(Int hour, Int min, Int sec := 0, Int ns := 0) {
    this.ticks = (hour%24) * Duration.nsPerHr + (min%60) * Duration.nsPerMin +
          (sec%60) * Duration.nsPerSec + (ns%Duration.nsPerSec)
  }

  new fromTicks(Int ticks) {
    if (ticks < 0) {
      ticks = - ticks
      ticks = ticks % Duration.nsPerDay
      if (ticks > 0) {
        ticks = Duration.nsPerDay - ticks
      }
      this.ticks = ticks
    }
    else
      this.ticks = ticks % Duration.nsPerDay
  }

  private static Int num(Str s, Int index) {
    return s.get(index) - '0';
  }

  **
  ** Parse the string into a Time from the programmatic encoding
  ** defined by `toStr`.  If the string cannot be parsed into a valid
  ** Time and checked is false then return null, otherwise throw
  ** ParseErr.
  **
  static new fromStr(Str s, Bool checked := true) {
    try
    {
      // hh:mm:ss
      hour  := num(s, 0)*10  + num(s, 1);
      min   := num(s, 3)*10  + num(s, 4);
      sec   := num(s, 6)*10  + num(s, 7);

      // check separator symbols
      if (s[2] != ':' || s[5] != ':')
        throw Err();

      // optional .FFFFFFFFF
      i := 8;
      ns := 0;
      tenth := 100000000;
      len := s.size
      if (i < len && s[i] == '.')
      {
        ++i;
        while (i < len)
        {
          c := s[i]
          if (c < '0' || c > '9') break;
          ns += (c - '0') * tenth;
          tenth /= 10;
          ++i;
        }
      }

      // verify everything has been parsed
      if (i < s.size) throw Err();

      return make(hour, min, sec, ns);
    }
    catch (Err e)
    {
      if (!checked) return defVal;
      throw ParseErr.make("Time:$s");
    }
  }

  **
  ** Default value is "00:00:00".
  **
  const static TimeOfDay defVal := fromTicks(0)

  **
  ** Private constructor.
  **
  //private new privateMake()

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  **
  ** Two times are equal if have identical hour, min, sec, and ns values.
  **
  override Bool equals(Obj? that) {
    if (that is TimeOfDay) {
      return ticks == ((TimeOfDay)that).ticks
    }
    return false
  }

  **
  ** Return hash of hour, min, sec, and ns values.
  **
  override Int hash() { ticks }

  **
  ** Compare based on hour, min, sec, and ns values.
  **
  override Int compare(Obj obj) {
    ticks <=> ((TimeOfDay)obj).ticks
  }

  **
  ** Return programmatic ISO 8601 string encoding formatted as follows:
  **   hh:mm:ss.FFFFFFFFF
  **   12:06:00.0
  **
  ** Also see `fromStr`, `toIso`, and `toLocale`.
  **
  override Str toStr() { toLocale("hh:mm:ss.FFF") }

//////////////////////////////////////////////////////////////////////////
// Access
//////////////////////////////////////////////////////////////////////////

  **
  ** Get the hour of the time as a number between 0 and 23.
  **
  Int hour() { ticks / Duration.nsPerHr }

  **
  ** Get the minutes of the time as a number between 0 and 59.
  **
  Int min() { (ticks / Duration.nsPerMin) % 60 }

  **
  ** Get the whole seconds of the time as a number between 0 and 59.
  **
  Int sec() { (ticks / Duration.nsPerSec) % 60 }

  **
  ** Get the number of nanoseconds (the fraction of seconds) as
  ** a number between 0 and 999,999,999.
  **
  Int nanoSec() { ticks % Duration.nsPerSec }

//////////////////////////////////////////////////////////////////////////
// Locale
//////////////////////////////////////////////////////////////////////////

  **
  ** Format this date according to the specified pattern.  If
  ** pattern is null, then a localized default is used.  The
  ** pattern format is the same as `DateTime.toLocale`:
  **
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
  **   'xyz'  Literal characters
  **
  ** A symbol immediately preceding a "F" pattern with a no
  ** fraction to print is skipped.
  **
  Str toLocale(Str? pattern := null, Locale locale := Locale.cur) {
    //TODO
    buf := StrBuf()
    buf.add(hour.toRadix(10, 2))
       .add(":").add(min.toRadix(10, 2))
       .add(":").add(sec.toRadix(10, 2))
    if (nanoSec != 0) {
       buf.add(".").add(nanoSec.toRadix(10, 9))
    }
    return buf.toStr
  }

  **
  ** Parse a string into a Time using the given pattern.  If
  ** string is not a valid format then return null or raise ParseErr
  ** based on checked flag.  See `toLocale` for pattern syntax.
  **
  static TimeOfDay? fromLocale(Str str, Str pattern, Bool checked := true) {
    //TODO
    fromStr(str)
  }

//////////////////////////////////////////////////////////////////////////
// ISO 8601
//////////////////////////////////////////////////////////////////////////

  **
  ** Parse an ISO 8601 time.  If invalid format and checked is
  ** false return null, otherwise throw ParseErr.  The following
  ** format is supported:
  **   hh:mm:ss.FFFFFFFFF
  **
  ** Also see `toIso` and `fromStr`.
  **
  static TimeOfDay? fromIso(Str s, Bool checked := true) { fromStr(s, checked) }

  **
  ** Format this instance according to ISO 8601 using the pattern:
  **   hh:mm:ss.FFFFFFFFF
  **
  ** Also see `fromIso` and `toStr`.
  **
  Str toIso() { toStr }

//////////////////////////////////////////////////////////////////////////
// Past/Future
//////////////////////////////////////////////////////////////////////////

  **
  ** Add the specified duration to this time. Throw ArgErr if 'dur' is
  ** not between 0 and 24hr.
  **
  ** Example:
  **   Time(5,0,0) + 30min  =>  05:30:00
  **
  @Operator TimeOfDay plus(Duration d) {
    ticks := d.toNanos
    if (ticks == 0) return this

    if (ticks < -Duration.nsPerDay || ticks > Duration.nsPerDay )
      throw ArgErr.make("Duration out of range: " + d)

    return fromTicks(this.ticks + ticks)
  }

  ** Subtract the specified duration to this time. Throw ArgErr if 'dur' is
  ** not between 0 and 24hr.
  **
  ** Example:
  **   Time(5,0,0) - 30min  =>  04:30:00
  **
  @Operator TimeOfDay minus(Duration d) {
    plus(-d)
  }

//////////////////////////////////////////////////////////////////////////
// Misc
//////////////////////////////////////////////////////////////////////////

  **
  ** Translate a duration of time which has elapsed since midnight
  ** into a Time of day.  See `toDuration`.  If the duration is not
  ** between 0 and 24hr throw ArgErr.
  **
  ** Example:
  **   Time.fromDuration(150min)  =>  02:30:00
  **
  static TimeOfDay fromDuration(Duration d) {
    ticks := d.toNanos
    if (ticks == 0) return defVal

    if (ticks < 0 || ticks > Duration.nsPerDay )
      throw ArgErr.make("Duration out of range: " + d)

    return fromTicks(ticks)
  }

  **
  ** Return the duration of time which has elapsed since midnight.
  ** See `fromDuration`.
  **
  ** Example:
  **   Time(2, 30).toDuration  =>  150min
  **
  Duration toDuration() { Duration.fromNanos(ticks) }

  **
  ** Combine this Time with the given Date to return a DateTime.
  **
  DateTime toDateTime(Date d, TimeZone tz := TimeZone.cur) {
    DateTime(d.year, d.month, d.day, hour, min, sec, nanoSec, tz)
  }

  **
  ** Get this Time as a Fantom expression suitable for code generation.
  **
  Str toCode() {
    if (equals(defVal)) return "Time.defVal"
    return "Time(\"" + toStr + "\")"
  }

  **
  ** Return if "00:00:00" which is equal to `defVal`.
  **
  Bool isMidnight() { this == defVal }

}