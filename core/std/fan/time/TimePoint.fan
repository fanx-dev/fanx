//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2018-5-26  Jed Young  Creation
//

**
** TimePoint represents an absolute instance in time.
** It's more light-weight than DateTime and independent of a timezone.
** TimePoint provides millisecond precision in current implemention.
**
@Serializable { simple = true }
@NoPeer
const struct class TimePoint
{
  ** millisecond since 1970
  private const Int ticks

  private new make(Int ticks) {
  }

  **
  ** Return the current time as millisecond ticks since 1 Jan 1970 UTC.
  **
  native static Int nowMillis()

  **
  ** Get the current value of the system timer.  This method returns
  ** a relative time unrelated to system or wall-clock time.  Typically
  ** it is the number of nanosecond ticks which have elapsed since system
  ** startup.
  **
  native static Int nanoTicks()

  **
  ** Return the current time as nanosecond ticks since 1 Jan 1970 UTC
  **
  native static Int nowUnique()

  ** Return the current time
  static new now() {
    make(nowMillis)
  }

  ** make from millisecond since 1970
  static new fromMillis(Int m) {
    make(m)
  }

  **
  ** millisecond since 1970
  **
  Int toMillis() {
    ticks
  }

  **
  ** Two times are equal if have identical nanosecond ticks.
  **
  override Bool equals(Obj? that) {
    if (that is TimePoint)
    {
      return ticks == ((TimePoint)that).ticks;
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
    return ticks - ((TimePoint)that).ticks
  }

  override Str toStr() { ticks.toStr }

  static new fromStr(Str s) { make(s.toInt) }

  **
  ** Return the delta between this and the given time.
  **
  @Operator Duration minusDateTime(TimePoint time) { Duration.fromMillis(ticks-time.ticks) }

  **
  ** Add a duration to compute a new time.
  **
  @Operator TimePoint plus(Duration duration) { make(ticks+duration.toMillis) }

  **
  ** Subtract a duration to compute a new time.
  **
  @Operator TimePoint minus(Duration duration) { make(ticks-duration.toMillis) }
}