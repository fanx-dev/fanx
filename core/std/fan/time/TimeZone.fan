//
// Copyright (c) 2007, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   28 Sep 07  Brian Frank  Creation
//

**
** TimeZone represents a region's offset from UTC and its daylight
** savings time rules.  TimeZones are historical - UTC offset and DST
** rules may change depending on the year.  The Fantom implementation of
** historical time zones is optimized to handle only year boundaries (so
** some historical changes which don't occur on year boundaries may
** not be 100% accurate).
**
** The Fantom time zone database and naming model is based on the
** [ZoneInfo database]`http://www.twinsun.com/tz/tz-link.htm` used
** by UNIX and Java (also known as the Olson database).  All time
** zones have both a simple `name` and a `fullName`.  The 'fullName'
** is the full identifier used in the zoneinfo database such as
** "America/New_York".  The simple name is the city name only
** such as "New_York".
**
** Use `cur` to get current default timezone for VM.
**
** Also see [docLang]`docLang::DateTime`.
**
@Serializable { simple = true }
const class TimeZone
{

  **
  ** List the names of all the time zones available in the
  ** local time zone database.  This database is stored in
  ** "{home}/lib/timezone.ftz" as a binary file.  This
  ** list contains only the simple names such as "New_York"
  ** and "London".
  **
  //static Str[] listNames()

  **
  ** List all zoneinfo (Olson database) full names of the
  ** time zones available in the local time zone database.
  ** This list is the full names only such as "America/New_York"
  ** and "Europe/London".
  **
  //static Str[] listFullNames()

  **
  ** Find a time zone by name from the built-in database:
  **   1. First check for simple name like "New_York" or
  **      the zoneinfo full name "America/New_York"
  **   2. Attempt to match against timezone aliases, if a
  **      match is found return the canonical TimeZone instance
  **   3. If no matches are found and checked is false then
  **      return null, otherwise throw ParseErr.
  **
  ** Also see:
  **   - [TimeZone database]`docLang::DateTime#timeZone`
  **   - [TimeZone aliases]`docLang::DateTime#timeZoneAliases`
  **
  static new fromStr(Str name, Bool checked := true) {
    if (name == "UTC") return utc
    return null
  }

  **
  ** UTC time zone instance is "Etc/Utc".
  **
  const static TimeZone utc := TimeZone("UTC", "UTC", 0)

  **
  ** Relative time zone instance is "Etc/Rel".  The relative timezone
  ** has a zero offset like UTC, but is used to normalize by time of
  ** day versus absolute time.  See `DateTime.toRel` and
  ** [docLang]`docLang::DateTime#relTimeZone`.
  **
  static TimeZone rel() { utc }

  **
  ** Get the current default TimeZone of the VM.  The default
  ** timezone is configured by the Java or .NET runtime or it
  ** can be manually configured in "etc/sys/config.props" with the
  ** key "timezone" and any value accepted by `fromStr`.  Once
  ** Fantom is booted, the default timezone cannot be changed.
  **
  static native TimeZone cur()

  **
  ** Default value is UTC.
  **
  static TimeZone defVal() { utc }

  **
  ** Private constructor.
  **
  private new make(Str name, Str fullName, Int offset) {
    this.name = name
    this.fullName = fullName
    this.baseOffset = offset
  }

  **
  ** Get the identifier of this time zone in the time zone
  ** database.  Name is the city name portion of the zoneinfo
  ** `fullName` identifier such as "New_York" or "London".
  **
  const Str name

  **
  ** Get the full name of this time zone as defined by the zoneinfo
  ** database.  These names are formatted as "contintent/location"
  ** where location is a major city within the time zone region.
  ** Examples of full names are "America/New_York" and "Europe/London".
  **
  const Str fullName
  const Int baseOffset

  **
  ** Get the duration of time added to UTC to compute standard time
  ** in this time zone.  The offset is independent of daylight savings
  ** time - during daylight savings the actual offset is this value
  ** plus `dstOffset`.
  **
  Duration offset(Int year := 0) { Duration.fromSec(baseOffset) }

  ** Get generic GMT offset where offset is in seconds
  static TimeZone fromGmtOffset(Int offset)
  {
    if (offset == 0) return TimeZone.utc
    StrBuf s := StrBuf()
    if (offset < 0) { offset = -offset; s.add("GMT+"); } else { s.add("GMT-"); }
    hour := offset / 3600;
    /* we don't have standard GMT timezones to support fractional
       hours like nutjobs that use timezones such as 3:30, so just
       round to nearest GMT hour
    int min  = (offset % 3600)/60;
    if (min != 0) throw new RuntimeException("Cannot convert fractional hour to GMT timezone: " + hour + ":" + min);
    */
    s.add(hour)
    return TimeZone.fromStr(s.toStr)
  }

  **
  ** Get the duration of time which will be added to local standard
  ** time to get wall time during daylight savings time (often 1hr).
  ** If daylight savings time is not observed then return null.
  **
  Duration? dstOffset(Int year) { null }

  **
  ** Get the abbreviated name during standard time.
  **
  Str stdAbbr(Int year) { name }

  **
  ** Get the abbreviated name during daylight savings time
  ** or null if daylight savings time not observed.
  **
  Str? dstAbbr(Int year) { null }

  **
  ** Return `name`.
  **
  override Str toStr() { name }

}