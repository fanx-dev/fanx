

native class TimeUtil {
  **
  ** Return the current time as millisecond ticks since 1 Jan 1970 UTC.
  **
  static Int currentTimeMillis()

  **
  ** Get the current value of the system timer.  This method returns
  ** a relative time unrelated to system or wall-clock time.  Typically
  ** it is the number of nanosecond ticks which have elapsed since system
  ** startup.
  **
  static Int nanoTicks()

  **
  ** Return the current time as nanosecond ticks since 1 Jan 1970 UTC
  **
  static Int nowUnique()


  internal static Locale getLocale()
  internal static Void setLocale(Locale local)

  internal static TimeZone? findTimeZone(Str name)
  internal static TimeZone curTimeZone()
  internal static Duration? daylightSavingsOffset(TimeZone tz, Int year)
  internal static Str[] listTimeZoneNames()
}