//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   3 Jul 06  Brian Frank  Creation
//

//using concurrent

**
** DateTimeTest
**
class DateTimeTest : Test
{

  const Month jan := Month.jan
  const Month feb := Month.feb
  const Month mar := Month.mar
  const Month apr := Month.apr
  const Month may := Month.may
  const Month jun := Month.jun
  const Month jul := Month.jul
  const Month aug := Month.aug
  const Month sep := Month.sep
  const Month oct := Month.oct
  const Month nov := Month.nov
  const Month dec := Month.dec

  const Weekday sun := Weekday.sun
  const Weekday mon := Weekday.mon
  const Weekday tue := Weekday.tue
  const Weekday wed := Weekday.wed
  const Weekday thu := Weekday.thu
  const Weekday fri := Weekday.fri
  const Weekday sat := Weekday.sat

  const TimeZone utc     := TimeZone.utc
  const TimeZone ny      := TimeZone.fromStr("America/New_York")
  const TimeZone la      := TimeZone.fromStr("America/Los_Angeles")
  const TimeZone uk      := TimeZone.fromStr("Europe/London")
  const TimeZone nl      := TimeZone.fromStr("Europe/Amsterdam")
  const TimeZone kiev    := TimeZone.fromStr("Europe/Kiev")
  const TimeZone brazil  := TimeZone.fromStr("America/Sao_Paulo")
  const TimeZone aust    := TimeZone.fromStr("Australia/Sydney")
  const TimeZone riga    := TimeZone.fromStr("Europe/Riga")
  const TimeZone jeru    := TimeZone.fromStr("Asia/Jerusalem")
  const TimeZone stJohn  := TimeZone.fromStr("America/St_Johns")
  const TimeZone godthab := TimeZone.fromStr("America/Godthab")

  const Bool std := false
  const Bool dst := true
  Locale? origLocale


//////////////////////////////////////////////////////////////////////////
// Test Setup
//////////////////////////////////////////////////////////////////////////

  override Void setup()
  {
    origLocale = Locale.cur
    Locale.setCur(Locale.fromStr("en-US"))
  }

  override Void teardown()
  {
    Locale.setCur(origLocale)
  }

//////////////////////////////////////////////////////////////////////////
// Equals
//////////////////////////////////////////////////////////////////////////

  Void testEquals()
  {
    // equals
    verifyEq(makeTicks(123_456_789), makeTicks(123_456_789))
    verifyNotEq(makeTicks(120_456_780), makeTicks(123_456_780))

    // hash
    //verifyEq(makeTicks(123_456_789).hash, 123_456_789)
  }

  Void testDateEquals()
  {
    verifyEq(Date(2000, Month.jun, 6), Date(2000, Month.jun, 6))
    verifyNotEq(Date(2000, Month.jun, 6), Date(2000, Month.jun, 8))
    verifyNotEq(Date(2000, Month.jun, 6), Date(2000, Month.jul, 6))
    verifyNotEq(Date(2000, Month.jun, 6), Date(2001, Month.jun, 6))
  }

  Void testTimeEquals()
  {
    verifyEq(TimeOfDay(1, 2, 3, 4), TimeOfDay(1, 2, 3, 4))
    verifyNotEq(TimeOfDay(1, 2, 3, 4), TimeOfDay(9, 2, 3, 4))
    verifyNotEq(TimeOfDay(1, 2, 3, 4), TimeOfDay(1, 9, 3, 4))
    verifyNotEq(TimeOfDay(1, 2, 3, 4), TimeOfDay(1, 2, 9, 4))
    verifyNotEq(TimeOfDay(1, 2, 3, 4), TimeOfDay(1, 2, 3, 9))
  }

//////////////////////////////////////////////////////////////////////////
// Compare
//////////////////////////////////////////////////////////////////////////
  static DateTime makeTicks(Int t, TimeZone tz := TimeZone.cur) {
    return DateTime#.method("fromTicks").call(t/1000_000, tz)
  }

  Void testCompare()
  {
    verify(makeTicks(723_456_789) >  makeTicks(123_456_789))
    verify(makeTicks(123_456_789) >= makeTicks(123_456_789))
    verify(makeTicks(123_456_789) <= makeTicks(123_456_789))
    verify(makeTicks(123_456_789) <  makeTicks(723_456_789))
  }

  Void testDateCompare()
  {
    verify(Date(2000, aug, 10) <= Date(2000, aug, 10))
    verify(Date(2000, aug, 10) >= Date(2000, aug, 10))

    verify(Date(2000, aug, 10) < Date(2000, aug, 11))
    verify(Date(2000, aug, 10) < Date(2000, sep, 10))
    verify(Date(2000, aug, 10) < Date(2001, aug, 10))

    verifyFalse(Date(2000, aug, 10) > Date(2000, aug, 11))
    verifyFalse(Date(2000, aug, 10) > Date(2000, dec, 10))
  }

  Void testTimeCompare()
  {
    verify(TimeOfDay(1, 2, 3, 4) <= TimeOfDay(1, 2, 3, 4))
    verifyFalse(TimeOfDay(1, 2, 3, 4) < TimeOfDay(1, 2, 3, 4))

    verify(TimeOfDay(1, 2, 3, 4) < TimeOfDay(1, 2, 3, 9))
    verify(TimeOfDay(1, 2, 3, 4) < TimeOfDay(1, 2, 9, 4))
    verify(TimeOfDay(1, 2, 3, 4) < TimeOfDay(1, 9, 3, 4))
    verify(TimeOfDay(1, 2, 3, 4) < TimeOfDay(9, 2, 3, 4))
  }

//////////////////////////////////////////////////////////////////////////
// Now
//////////////////////////////////////////////////////////////////////////

  Void testNow()
  {
    //verify(DateTime.now(null) != DateTime.now(null))

    a := DateTime.now
    verify(a == DateTime.now)
    verifySame(a.tz, TimeZone.cur)

    b := DateTime.now(null)
    //verify(a != b)
    verify(b == DateTime.now)

    /*
    if (!isJS)
    {
      //Actor.sleep(200ms)
      verify(b === DateTime.now)

      c := DateTime.now(180ms)
      verify(b !== c)
    }
    */

    verifyEq(Date.today, DateTime.now.date)
    verifyEq(Date.today(TimeZone.utc), DateTime.nowUtc.date)

    verifyEq(Date.yesterday, DateTime.now.date - 1day)
    verifyEq(Date.yesterday(TimeZone.utc), DateTime.nowUtc.date - 1day)

    verifyEq(Date.tomorrow, DateTime.now.date + 1day)
    verifyEq(Date.tomorrow(TimeZone.utc), DateTime.nowUtc.date + 1day)

    dt1   := DateTime.now(null)
    //ticks := DateTime.nowTicks
    dt2   := DateTime.now(null)
    verify(dt1->ticks <= dt2->ticks)

    dt1   = DateTime.now
    time  := TimeOfDay.now
    dt2   = DateTime.now
    verify(dt1.time <= time && time <= dt2.time)

    dt1   = DateTime.nowUtc(null)
    time  = TimeOfDay.now(TimeZone.utc)
    dt2   = DateTime.nowUtc(null)
    verify(dt1.time <= time && time <= dt2.time)
  }

//////////////////////////////////////////////////////////////////////////
// Now UTC
//////////////////////////////////////////////////////////////////////////

  Void testNowUtc()
  {
    verify(DateTime.nowUtc(null) <= DateTime.nowUtc(null))

    a := DateTime.nowUtc
    verify(a == DateTime.nowUtc)
    verifySame(a.tz, TimeZone.utc)

    b := DateTime.nowUtc(null)
    //verify(a != b)
    verify(b == DateTime.nowUtc)

    /*
    if (!isJS)
    {
      Actor.sleep(200ms)
      verify(b === DateTime.nowUtc)

      c := DateTime.now(180ms)
      verify(b !== c)
    }
    */
  }

//////////////////////////////////////////////////////////////////////////
// Now Unique
//////////////////////////////////////////////////////////////////////////
/*
  Void testNowUnique()
  {
    if (isJS) return;

    // spawn off a bunch of actors to loop on DateTime.nowUnique
    futures := Future[,]
    10.times |->|
    {
      actor := Actor(ActorPool(), #nowUniqueLoop.func)
      futures.add(actor.send(null))
    }

    // aggregate all the results
    acc := Int[,]
    futures.each |f| { acc.addAll(f.get) }

    // sort, but check that acc was unsorted to
    // verify actors were inter-leaved
    sorted := acc.dup.sort
    verifyNotEq(acc, sorted)

    // verify that we have no duplicates
    for (i:=1; i<sorted.size; ++i)
      verify(sorted[i-1] < sorted[i], i.toStr)

    // verify that counter gets reset
    Actor.sleep(10ms)
    verify(DateTime.nowUnique <= DateTime.nowTicks)
  }
*/
  Void testNowUniqueSimple() {
    sorted := nowUniqueLoop
    for (i:=1; i<sorted.size; ++i)
      verify(sorted[i-1] < sorted[i], i.toStr)
  }

  static Int[] nowUniqueLoop()
  {
    acc := Int[,]
    10000.times { acc.add(TimePoint.nowUnique) }
    return acc.toImmutable
  }


//////////////////////////////////////////////////////////////////////////
// Boot
//////////////////////////////////////////////////////////////////////////
/*
  Void testBoot()
  {
    verifySame(DateTime.boot, DateTime.boot)
    verifySame(DateTime.boot.tz, TimeZone.cur)
    verify(DateTime.boot < DateTime.now(null))
  }
*/
//////////////////////////////////////////////////////////////////////////
// Month
//////////////////////////////////////////////////////////////////////////

  Void testMonth()
  {
    //verifyEq(Month#.qname, "sys::Month")
    verifySame(Month#.base, Enum#)
    verifySame(Type.of(Month.jan), Month#)

    verifyEq(Month.vals.isRO, true)
    verifyEq(Month.vals.size, 12)
    verifyEq(Month.vals.capacity, 12)
    verifyEnum(Month.jan, 0,  "jan", Month.vals)
    verifyEnum(Month.feb, 1,  "feb", Month.vals)
    verifyEnum(Month.mar, 2,  "mar", Month.vals)
    verifyEnum(Month.apr, 3,  "apr", Month.vals)
    verifyEnum(Month.may, 4,  "may", Month.vals)
    verifyEnum(Month.jun, 5,  "jun", Month.vals)
    verifyEnum(Month.jul, 6,  "jul", Month.vals)
    verifyEnum(Month.aug, 7,  "aug", Month.vals)
    verifyEnum(Month.sep, 8,  "sep", Month.vals)
    verifyEnum(Month.oct, 9,  "oct", Month.vals)
    verifyEnum(Month.nov, 10, "nov", Month.vals)
    verifyEnum(Month.dec, 11, "dec", Month.vals)

    verifySame(Month.jan.decrement, Month.dec)
    verifySame(Month.feb.decrement, Month.jan)
    verifySame(Month.dec.decrement, Month.nov)

    verifySame(Month.jan.increment, Month.feb)
    verifySame(Month.nov.increment, Month.dec)
    verifySame(Month.dec.increment, Month.jan)

    m := Month.jan
    verifySame(m--, jan); verifySame(m, dec)
    verifySame(--m, nov); verifySame(m, nov)
    verifySame(++m, dec); verifySame(m, dec)
    verifySame(m++, dec); verifySame(m, jan)
  }

  Void testMonthNumDays()
  {
    verifyEq(Month.jan.numDays(2007), 31)
    verifyEq(Month.feb.numDays(2007), 28)
    verifyEq(Month.feb.numDays(2004), 29)
    verifyEq(Month.mar.numDays(2007), 31)
    verifyEq(Month.apr.numDays(2007), 30)
    verifyEq(Month.may.numDays(2007), 31)
    verifyEq(Month.jun.numDays(2007), 30)
    verifyEq(Month.jul.numDays(2007), 31)
    verifyEq(Month.aug.numDays(2007), 31)
    verifyEq(Month.sep.numDays(2007), 30)
    verifyEq(Month.oct.numDays(2007), 31)
    verifyEq(Month.nov.numDays(2007), 30)
    verifyEq(Month.dec.numDays(2007), 31)
  }

  Void testMonthLocale()
  {
    verifyMonthLocale(Month.jan,  "1", "01", "Jan", "January")
    verifyMonthLocale(Month.feb,  "2", "02", "Feb", "February")
    verifyMonthLocale(Month.mar,  "3", "03", "Mar", "March")
    verifyMonthLocale(Month.apr,  "4", "04", "Apr", "April")
    verifyMonthLocale(Month.may,  "5", "05", "May", "May")
    verifyMonthLocale(Month.jun,  "6", "06", "Jun", "June")
    verifyMonthLocale(Month.jul,  "7", "07", "Jul", "July")
    verifyMonthLocale(Month.aug,  "8", "08", "Aug", "August")
    verifyMonthLocale(Month.sep,  "9", "09", "Sep", "September")
    verifyMonthLocale(Month.oct, "10", "10", "Oct", "October")
    verifyMonthLocale(Month.nov, "11", "11", "Nov", "November")
    verifyMonthLocale(Month.dec, "12", "12", "Dec", "December")

    verifyErr(ArgErr#) { Month.jan.toLocale("") }
    verifyErr(ArgErr#) { Month.jan.toLocale("MMMMM") }
    verifyErr(ArgErr#) { Month.jan.toLocale("MMx") }
  }

  Void verifyMonthLocale(Month mon, Str m, Str mm, Str mmm, Str mmmm)
  {
    verifyEq(mon.toLocale("M"), m)
    verifyEq(mon.toLocale("MM"), mm)
    verifyEq(mon.toLocale("MMM"), mmm)
    verifyEq(mon.toLocale("MMMM"), mmmm)
    verifyEq(mon.toLocale(null), mmm)
    verifyEq(mon.localeAbbr, mmm)
    verifyEq(mon.localeFull, mmmm)
    Locale("de").use { verifyEq(mon.toLocale("MMM", Locale.en), mmm) }
  }

//////////////////////////////////////////////////////////////////////////
// Weekday
//////////////////////////////////////////////////////////////////////////

  Void testWeekday()
  {
    //verifyEq(Weekday#.qname, "sys::Weekday")
    verifySame(Weekday#.base, Enum#)
    verifySame(Type.of(Weekday.sun), Weekday#)

    verifyEq(Weekday.vals.isRO, true)
    verifyEq(Weekday.vals.size, 7)
    verifyEq(Weekday.vals.capacity, 7)
    verifyEnum(Weekday.sun, 0, "sun", Weekday.vals)
    verifyEnum(Weekday.mon, 1, "mon", Weekday.vals)
    verifyEnum(Weekday.tue, 2, "tue", Weekday.vals)
    verifyEnum(Weekday.wed, 3, "wed", Weekday.vals)
    verifyEnum(Weekday.thu, 4, "thu", Weekday.vals)
    verifyEnum(Weekday.fri, 5, "fri", Weekday.vals)
    verifyEnum(Weekday.sat, 6, "sat", Weekday.vals)

    verifySame(Weekday.sun.decrement, Weekday.sat)
    verifySame(Weekday.thu.decrement, Weekday.wed)
    verifySame(Weekday.sat.decrement, Weekday.fri)

    verifySame(Weekday.sun.increment, Weekday.mon)
    verifySame(Weekday.fri.increment, Weekday.sat)
    verifySame(Weekday.sat.increment, Weekday.sun)

    w := Weekday.fri
    verifySame(w++, fri); verifySame(w, sat)
    verifySame(++w, sun); verifySame(w, sun)
    verifySame(--w, sat); verifySame(w, sat)
    verifySame(w--, sat); verifySame(w, fri)
  }

  Void verifyEnum(Enum e, Int ordinal, Str name, Enum[] values)
  {
    verifyEq(e.ordinal, ordinal)
    verifyEq(e.name, name)
    verifySame(values[ordinal], e)
  }

  Void testWeekdayLocale()
  {
    verifyEq(Weekday.localeStartOfWeek, Weekday.sun)
    verifyWeekdayLocale(Weekday.sun, "Sun", "Sunday")
    verifyWeekdayLocale(Weekday.mon, "Mon", "Monday")
    verifyWeekdayLocale(Weekday.tue, "Tue", "Tuesday")
    verifyWeekdayLocale(Weekday.wed, "Wed", "Wednesday")
    verifyWeekdayLocale(Weekday.thu, "Thu", "Thursday")
    verifyWeekdayLocale(Weekday.fri, "Fri", "Friday")
    verifyWeekdayLocale(Weekday.sat, "Sat", "Saturday")

    verifyEq(Weekday.localeVals, Weekday.vals)
    verifyEq(Weekday.localeVals.isImmutable, true)
    verifySame(Weekday.localeVals, Weekday.localeVals)
/*
    if (!isJs)
    {
      Locale.fromStr("fi", false).use
      {
        verifyEq(Weekday.localeVals, [Weekday.mon, Weekday.tue, Weekday.wed, Weekday.thu, Weekday.fri, Weekday.sat, Weekday.sun])
        verifyEq(Weekday.localeVals.isImmutable, true)
        verifySame(Weekday.localeVals, Weekday.localeVals)
      }
    }
*/
    verifyErr(ArgErr#) { Weekday.sun.toLocale("") }
    verifyErr(ArgErr#) { Weekday.sun.toLocale("W") }
    verifyErr(ArgErr#) { Weekday.sun.toLocale("WWWWW") }
    verifyErr(ArgErr#) { Weekday.sun.toLocale("x") }
  }

  Void verifyWeekdayLocale(Weekday w, Str www, Str wwww)
  {
    verifyEq(w.toLocale("WWW"), www)
    verifyEq(w.toLocale("WWWW"), wwww)
    verifyEq(w.toLocale(null), www)
    verifyEq(w.localeAbbr, www)
    verifyEq(w.localeFull, wwww)
    Locale("de").use { verifyEq(w.toLocale("WWW", Locale.en), www) }
  }

//////////////////////////////////////////////////////////////////////////
// Math
//////////////////////////////////////////////////////////////////////////

  Void testMath()
  {
    now := DateTime.now

    yesterday1 := now + -1day
    yesterday2 := now - 1day
    tomorrow := now + 1day

    verifyEq((Int)now->ticks - (Int)yesterday1->ticks, 1day->ticks)
    verifyEq((Int)now->ticks - (Int)yesterday2->ticks, 1day->ticks)
    verifyEq((Int)now->ticks - (Int)tomorrow->ticks, -(Int)1day->ticks)

    verifyEq(now - yesterday1, 1day)
    verifyEq(now - yesterday2, 1day)
    verifyEq(now - tomorrow, -1day)
  }

  Void testFloor()
  {
    now := DateTime.now
    verifyEq((Int)now.floor(1min)->ticks % (Int)1min->ticks, 0)
    verifyEq((Int)now.floor(1sec)->ticks % (Int)1sec->ticks, 0)
    now += 12ms
    verifyEq((Int)now.floor(1min)->ticks % (Int)1min->ticks, 0)
    verifyEq((Int)now.floor(1sec)->ticks % (Int)1sec->ticks, 0)

    x := DateTime.make(2008, Month.mar, 14, 12, 30, 44)
    verifyEq(x.floor(1hr), DateTime.make(2008, Month.mar, 14, 12, 00))
    verifyEq(x.floor(1min), DateTime.make(2008, Month.mar, 14, 12, 30))
    verifySame(x.floor(1sec), x)
  }

//////////////////////////////////////////////////////////////////////////
// TimeZone
//////////////////////////////////////////////////////////////////////////

  Void testTimeZone()
  {
    names := TimeZone.listNames
    verify(names.isRO)
    //echo(names)
    verify(names.contains("New_York"))
    verify(names.contains("Los_Angeles"))
    verify(names.contains("London"))
    verify(names.contains("UTC"))
    //verify(names.contains("Rel"))
    verify(!names.contains("America/New_York"))

    names = TimeZone.listFullNames
    verify(names.isRO)
    verify(names.contains("America/New_York"))
    verify(names.contains("America/Los_Angeles"))
    verify(names.contains("Europe/London"))
    verify(names.contains("Etc/UTC"))
    //verify(names.contains("Etc/Rel"))
    verify(!names.contains("New_York"))

    //verify(TimeZone.fromStr("foo bar", false) == null)
    //verifyErr(ParseErr#) { x := TimeZone.fromStr("foo bar") }

    verifySame(TimeZone.utc, TimeZone.fromStr("UTC"))
    verifySame(TimeZone.rel, TimeZone.fromStr("Rel"))

    verifyTimeZone("America/New_York", "EST",  -5hr, "EDT", 1hr)
    verifyTimeZone("America/Phoenix",  "MST",  -7hr, null,  null)
    verifyTimeZone("Asia/Kolkata",     "IST", 5.5hr, null,  null)
    verifyTimeZone("Etc/UTC",          "UTC",   0hr, null,  null)
    //verifyTimeZone("Etc/Rel",          "Rel",   0hr, null,  null)
/*
    // no slashes
    //x := TimeZone.fromStr("EST")
    //verifyEq(x.name, "EST")
    //verifyEq(x.fullName, "EST")

    // 2 slashes
    x := TimeZone.fromStr("America/Kentucky/Louisville")
    verifyEq(x.name, "Louisville")
    verifyEq(x.fullName, "America/Kentucky/Louisville")
    verifySame(TimeZone.fromStr("America/Kentucky/Louisville"), TimeZone.fromStr("Louisville"))
*/
    //verifyEq(TimeZone.fromStr("Asia/New_York", false), null)
  }

  Void verifyTimeZone(Str fullName, Str stdAbbr, Duration offset, Str? dstAbbr, Duration? dstOffset)
  {
    //name := fullName[fullName.index("/")+1 .. -1]

    x := TimeZone.fromStr(fullName)
    //verifySame(TimeZone.fromStr(name), x)
    //verifyEq(x.name, name)
    //verifyEq(x.toStr, name)
    //verifyEq(x.fullName, fullName)
    //verifyEq(x.stdAbbr(2010), stdAbbr)
    //verifyEq(x.dstAbbr(2010), dstAbbr)

    verifyEq(x.fullName, fullName)

    verifyEq(x.offset(2010), offset)
    verifyEq(x.dstOffset(2010), dstOffset)
  }

  Void testToTimeZone()
  {
    a := DateTime.fromStr("2008-11-14T12:00:00Z UTC")
    b := a.toTimeZone(ny)
    //verifyEq(b.toStr, "2008-11-14T07:00:00-05:00 New_York")
    verifySame(a, a.toTimeZone(utc))
    verifySame(a, a.toUtc)
    verifySame(b, b.toTimeZone(ny))
    verifyEq(a, b.toUtc)

    c := b.toTimeZone(la)
    verifyEq(c, DateTime.make(2008, Month.nov, 14, 4, 0, 0, 0, la))
    d := c.toTimeZone(ny)
    verifyEq(d, b)

    //x := DateTime.fromStr("2008-04-06T05:21:20-08:00 Los_Angeles")
    //y := DateTime.fromStr("2008-04-06T09:21:20-04:00 New_York")
    //verifyEq(x->ticks, y->ticks)
  }
/*
  Void testTimeZoneAliases()
  {
    verifyTimeZoneAlias("Asia/Saigon", "Asia/Ho_Chi_Minh")
    verifyTimeZoneAlias("Saigon", "Asia/Ho_Chi_Minh")

    verifyTimeZoneAlias("Australia/Victoria", "Australia/Melbourne")
    verifyTimeZoneAlias("Victoria", "Australia/Melbourne")

    verifyTimeZoneAlias("America/Argentina/ComodRivadavia", "America/Argentina/Catamarca")
    verifyTimeZoneAlias("ComodRivadavia", "America/Argentina/Catamarca")
  }

  Void verifyTimeZoneAlias(Str alias, Str canonicalFull)
  {
    tz := TimeZone(canonicalFull)
    canonicalName := canonicalFull[canonicalFull.indexr("/")+1..-1]
    verifyEq(tz.fullName, canonicalFull)
    verifyEq(tz.name, canonicalName)
    verifySame(TimeZone(alias), tz)
    verifyEq(TimeZone(alias).fullName, canonicalFull)
    verifyEq(TimeZone(alias).name, canonicalName)
  }
*/
//////////////////////////////////////////////////////////////////////////
// Leap Year
//////////////////////////////////////////////////////////////////////////

  Void testLeapYear()
  {
    verifyEq(DateTime.isLeapYear(2000), true)
    verifyEq(DateTime.isLeapYear(2007), false)
    verifyEq(DateTime.isLeapYear(2008), true)
    verifyEq(DateTime.isLeapYear(2012), true)
    verifyEq(DateTime.isLeapYear(2100), false)
    verifyEq(DateTime.isLeapYear(2400), true)
  }

//////////////////////////////////////////////////////////////////////////
// Weekday In Month
//////////////////////////////////////////////////////////////////////////

  Void testWeekdayInMonth()
  {
    verifyWeekdayInMonth(2007, feb, thu, [1, 8, 15, 22])
    verifyWeekdayInMonth(2007, feb, fri, [2, 9, 16, 23])
    verifyWeekdayInMonth(2007, feb, sat, [3, 10, 17, 24])
    verifyWeekdayInMonth(2007, feb, sun, [4, 11, 18, 25])
    verifyWeekdayInMonth(2007, feb, mon, [5, 12, 19, 26])
    verifyWeekdayInMonth(2007, feb, tue, [6, 13, 20, 27])
    verifyWeekdayInMonth(2007, feb, wed, [7, 14, 21, 28])

    verifyWeekdayInMonth(2008, mar, sat, [1, 8, 15, 22, 29])
    verifyWeekdayInMonth(2008, mar, sun, [2, 9, 16, 23, 30])
    verifyWeekdayInMonth(2008, mar, mon, [3, 10, 17, 24, 31])
    verifyWeekdayInMonth(2008, mar, tue, [4, 11, 18, 25])
    verifyWeekdayInMonth(2008, mar, wed, [5, 12, 19, 26])
    verifyWeekdayInMonth(2008, mar, thu, [6, 13, 20, 27])
    verifyWeekdayInMonth(2008, mar, fri, [7, 14, 21, 28])

    verifyWeekdayInMonth(2007, oct, wed, [3, 10, 17, 24, 31])
    verifyWeekdayInMonth(1997, nov, sat, [1, 8, 15, 22, 29])
    verifyWeekdayInMonth(1980, jan, mon, [7, 14, 21, 28])
    verifyWeekdayInMonth(2016, feb, mon, [1, 8, 15, 22, 29])

    verifyEq(DateTime.weekdayInMonth(2007, Month.oct, Weekday.sun, -1), 28)
    verifyErr(ArgErr#) { DateTime.weekdayInMonth(2007, oct, mon, 0) }
    verifyErr(ArgErr#) { DateTime.weekdayInMonth(2007, oct, wed, 6) }
    verifyErr(ArgErr#) { DateTime.weekdayInMonth(2016, feb, tue, -5) }
  }

  Void verifyWeekdayInMonth(Int year, Month mon, Weekday weekday, Int[] days)
  {
    days.each |Int day, Int i|
    {
      verifyEq(DateTime.weekdayInMonth(year, mon, weekday, i+1), day)
      verifyEq(DateTime.weekdayInMonth(year, mon, weekday, i-days.size), day)
    }
  }

//////////////////////////////////////////////////////////////////////////
// Makes
//////////////////////////////////////////////////////////////////////////
/*
  Void testMakes()
  {
    // smoke tests
    verifyDateTime(2678400000_000000, utc,  2000, feb, 1,  0, 0, 0, tue, std, 32)
    verifyDateTime(5270400000_000001, utc,  2000, mar, 2,  0, 0, 0, thu, std, 62, 1)
    verifyDateTime(8035200123_000000, utc,  2000, apr, 3,  0, 0, 0, mon, std, 94, 123_000_000)
    verifyDateTime(10713600000_789000, utc, 2000, may, 4,  0, 0, 0, thu, std, 125, 789000)
    verifyDateTime(13478400000_000000, utc, 2000, jun, 5,  0, 0, 0, mon, std)
    verifyDateTime(16156800000_000000, utc, 2000, jul, 6,  0, 0, 0, thu, std)
    verifyDateTime(18921600000_000000, utc, 2000, aug, 7,  0, 0, 0, mon, std)
    if (!isJs)
      verifyDateTime(21686400123_456789, utc, 2000, sep, 8,  0, 0, 0, fri, std, null, 123_456_789)
    verifyDateTime(24364800000_000000, utc, 2000, oct, 9,  0, 0, 0, mon, std)
    verifyDateTime(27129600000_000000, utc, 2000, nov, 10, 0, 0, 0, fri, std)
    verifyDateTime(29808000000_000000, utc, 2000, dec, 11, 0, 0, 0, mon, std, 346)
    verifyDateTime(-615427197000_000000, utc, 1980, jul, 1, 0, 0, 3, tue, std)
    verifyDateTime(-869961540100_000000, utc, 1972, jun, 7, 0, 0, 59, wed, std, null, 900_000_000)
    verifyDateTime(-869961576544_000000, utc, 1972, jun, 7, 0, 0, 23, wed, std, null, 456_000_000)

    // Fantom epoch is 1-jan-2000
    verifyDateTime(0, utc, 2000, jan, 1, 0, 0, 0, sat, std)

    // Java epoch is 1-jan-1970
    verifyDateTime((-10957day)->ticks, utc, 1970, jan, 1, 0, 0, 0, thu, std)

    // Boundary condition for leap table monForDayOfYearLeap
    verifyDateTime(-220906800000_000000, ny, 1992, dec, 31, 0, 0, 0, thu, std)

    // Fantom epoch +1day
    verifyDateTime(86400000_000000, utc, 2000, jan, 2, 0, 0, 0, sun, std)

    // right now as I code this
    if (!isJs)
      verifyDateTime(245209531000_000099, ny, 2007, oct, 8, 21, 45, 31, mon, dst, null, 99)

    // Halloween 2008 (dst)
    verifyDateTime(278744523000_000000, ny, 2008, oct, 31, 1, 2, 3, fri, dst)

    // Halloween 2006 (std)
    verifyDateTime(215589723000_000000, ny, 2006, oct, 31, 1, 2, 3, tue, std)

    // 2008 Feb 29 leap year
    verifyDateTime(257621400000_000000, ny, 2008, feb, 29, 12, 30, 0, fri, std)

    // 1972 Jun 7
    verifyDateTime(-869917500000_000000, ny, 1972, jun, 7, 8, 15, 0, wed, dst)

    // 2001 Jan 30
    verifyDateTime(34153380000_000000, ny, 2001, jan, 30, 2, 3, 0, tue, std)

    // 2099 Dec 31 (upper boundary)
    verifyDateTime(3155759999000_000000, utc, 2099, dec, 31, 23, 59, 59, thu, std)

    // 1901 Jan 1 (lower boundary UTC)
    verifyDateTime(-3124137600000_000000, utc, 1901, jan, 1, 0, 0, 0, tue, std)

    // clearly EDT
    verifyDateTime(269598645000_000000, ny, 2008, jul, 17, 4, 30, 45, thu, dst)

    // PST->PDT mar edge
    verifyDateTime(447670800000_000000, la, 2014, mar, 9, 1, 0, 0, sun, std)
    verifyDateTime(447674399000_000000, la, 2014, mar, 9, 1, 59, 59, sun, std)
    verifyDateTime(447674400000_000000, la, 2014, mar, 9, 3, 0, 0, sun, dst)

    // PDT->PST nov edge
    verifyDateTime(310377599000_000000, la, 2009, nov, 1, 0, 59, 59, sun, dst)
    verifyDateTime(310381199000_000000, la, 2009, nov, 1, 1, 59, 59, sun, dst)
    verifyDateTime(310381200000_000000, la, 2009, nov, 1, 1, 0, 0, sun, std, null, 0, false)
    verifyDateTime(310384800000_000000, la, 2009, nov, 1, 2, 0, 0, sun, std)
    verifyDateTime(310384807000_000000, la, 2009, nov, 1, 2, 0, 7, sun, std)

    // Amsterdam (+1, with universal dst mode)
    verifyDateTime(289220400000_000000, nl, 2009, mar, 1,  12, 0, 0, sun, std)
    verifyDateTime(291601800000_000000, nl, 2009, mar, 29, 1, 30, 0, sun, std)
    verifyDateTime(291603600000_000000, nl, 2009, mar, 29, 3, 0, 0,  sun, dst)
    verifyDateTime(291722400000_000000, nl, 2009, mar, 30, 12, 0, 0, mon, dst)

    // Kiev (+2, with universal dst mode)
    verifyDateTime(289216800000_000000, kiev, 2009, mar, 1, 12, 0, 0, sun, std)
    verifyDateTime(291592800000_000000, kiev, 2009, mar, 29, 0, 0, 0, sun, std)
    verifyDateTime(291596400000_000000, kiev, 2009, mar, 29, 1, 0, 0, sun, std)
    verifyDateTime(291600000000_000000, kiev, 2009, mar, 29, 2, 0, 0, sun, std)
    verifyDateTime(291603600000_000000, kiev, 2009, mar, 29, 4, 0, 0, sun, dst)
    verifyDateTime(291718800000_000000, kiev, 2009, mar, 30, 12, 0, 0, mon, dst)
    verifyDateTime(309733200000_000000, kiev, 2009, oct, 25, 0, 0, 0, sun, dst)
    verifyDateTime(309736800000_000000, kiev, 2009, oct, 25, 1, 0, 0, sun, dst)
    verifyDateTime(309740400000_000000, kiev, 2009, oct, 25, 2, 0, 0, sun, dst)
    verifyDateTime(309747600000_000000, kiev, 2009, oct, 25, 3, 0, 0, sun, std)
    verifyDateTime(309751200000_000000, kiev, 2009, oct, 25, 4, 0, 0, sun, std)

    // Brazil (southern hemisphere with wall dst, and midnight dst)
    //  2008 DST starts on October 19, 2008 and ends February 15, 2009
    verifyDateTime(252511200000_000000, brazil, 2008, jan, 1, 12, 0, 0, tue, dst)
    verifyDateTime(277700340000_000000, brazil, 2008, oct, 18, 23, 59, 0, sat, std)
    verifyDateTime(277700400000_000000, brazil, 2008, oct, 19, 1, 0, 0, sun, dst)
    verifyDateTime(287978340000_000000, brazil, 2009, feb, 14, 23, 59, 0, sat, dst)
    verifyDateTime(287985600000_000000, brazil, 2009, feb, 15, 1, 0, 0, sun, std)

    // New South Wales (south hemisphere, standard (non-wall) time dst)
    verifyDateTime(246815999000_000000, aust, 2007, oct, 28, 1, 59, 59, sun, std)
    verifyDateTime(246816000000_000000, aust, 2007, oct, 28, 3, 0, 0, sun, dst)
    verifyDateTime(252435906000_000000, aust, 2008, jan, 1, 4, 5, 6, tue, dst)
    verifyDateTime(260326800000_000000, aust, 2008, apr, 1, 12, 0, 0, tue, dst)
    verifyDateTime(260726399999_000000, aust, 2008, apr, 6, 2, 59, 59, sun, dst, null, 999_000_000, false)
    verifyDateTime(260726400000_000000, aust, 2008, apr, 6, 2, 0, 0, sun, std)
    verifyDateTime(260730000000_000000, aust, 2008, apr, 6, 3, 0, 0, sun, std)
    verifyDateTime(261972000000_000000, aust, 2008, apr, 20, 12, 0, 0, sun, std)
    verifyDateTime(276430500000_000000, aust, 2008, oct, 4, 20, 15, 0, sat, std)
    verifyDateTime(276451199000_000000, aust, 2008, oct, 5, 1, 59, 59, sun, std)
    verifyDateTime(276451200000_000000, aust, 2008, oct, 5, 3, 0, 0, sun, dst)

    // Riga did not observe dst in 2000
    verifyDateTime(78786000000_000000,  riga, 2002, jul, 1, 0, 0, 0, mon, dst)
    verifyDateTime(47250000000_000000,  riga, 2001, jul, 1, 0, 0, 0, sun, dst)
    verifyDateTime(15717600000_000000,  riga, 2000, jul, 1, 0, 0, 0, sat, std)
    verifyDateTime(-15908400000_000000, riga, 1999, jul, 1, 0, 0, 0, thu, dst)

    // Israel
    verifyDateTime(195170400000_000000, jeru, 2006, mar,  9, 0, 0, 0, thu, std)
    verifyDateTime(195256800000_000000, jeru, 2006, mar, 10, 0, 0, 0, fri, std)
    verifyDateTime(195343200000_000000, jeru, 2006, mar, 11, 0, 0, 0, sat, std)
    verifyDateTime(197071200000_000000, jeru, 2006, mar, 31, 0, 0, 0, fri, std)
    verifyDateTime(197154000000_000000, jeru, 2006, apr,  1, 0, 0, 0, sat, dst)

    // St. John has -3:30 offset
    verifyDateTime(255148200000_000000, stJohn, 2008, jan, 31, 23, 0, 0, thu, std)
    verifyDateTime(255151800000_000000, stJohn, 2008, feb, 1, 0, 0, 0, fri, std)

    // Godthab Greenland uses universal time like EU but with negative GMT offset
    verifyDateTime(246985200000_000000, godthab, 2007, oct, 29, 12, 0, 0, mon, std)
    verifyDateTime(260074800000_000000, godthab, 2008, mar, 29, 0, 0, 0, sat, std)
    verifyDateTime(260154000000_000000, godthab, 2008, mar, 29, 23, 0, 0, sat, dst)

   // Original notes I captured for testing:
   //  - Chile, etc which starts DST in the fall
   //  - Perth which canceled dst in 2007 and has the year roll over
   //  - Test changes to zone items
   //  - Test changes to zone times with an until not cleanly on year boundary (Asia/Bishkek)
   //  - Future rules for Asia/Jerusalem

    // out of bounds
    verifyErr(ArgErr#) { x := DateTime.make(1899, Month.jun, 1, 0, 0) }
    verifyErr(ArgErr#) { x := DateTime.make(2100, Month.jun, 1, 0, 0) }
    verifyErr(ArgErr#) { x := DateTime.make(2007, Month.feb, 0, 0, 0) }
    verifyErr(ArgErr#) { x := DateTime.make(2007, Month.feb, 29, 0, 0) }
    verifyErr(ArgErr#) { x := DateTime.make(2007, Month.jun, 6, -1, 0) }
    verifyErr(ArgErr#) { x := DateTime.make(2007, Month.jun, 6, 60, 00) }
    verifyErr(ArgErr#) { x := DateTime.make(2007, Month.jun, 6, 0, -1) }
    verifyErr(ArgErr#) { x := DateTime.make(2007, Month.jun, 6, 0, 60) }
    verifyErr(ArgErr#) { x := DateTime.make(2007, Month.jun, 6, 0, 0, -1) }
    verifyErr(ArgErr#) { x := DateTime.make(2007, Month.jun, 6, 0, 0, 60) }
    verifyErr(ArgErr#) { x := DateTime.make(2007, Month.jun, 6, 0, 0, 0, -1) }
    verifyErr(ArgErr#) { x := DateTime.make(2007, Month.jun, 6, 0, 0, 0, 1_000_000_000) }
    //verifyErr(ArgErr#) { x := makeTicks(3155760000000_000000, utc) }

    // JS cannot represent this number, it rounds to _000000, which causes the test  to fail
    if (!isJs)
      verifyErr(ArgErr#) { x := makeTicks(-3124137600000_000001, utc) }
  }

  Void verifyDateTime(Int ticks, TimeZone tz, Int year, Month month, Int day,
                      Int hr, Int min, Int sec,
                      Weekday weekday, Bool isDST, Int? doy := null,
                      Int nanoSec := 0, Bool testMake := true)
  {
    func := |DateTime dt|
    {
      // echo("-- verify $dt " + (dt.dst ? "DST" : "STD"))
      verifySame(dt.tz, tz)
      //verifyEq(dt->ticks,   ticks)
      verifyEq(dt.year,    year)
      verifyEq(dt.month,   month)
      verifyEq(dt.day,     day)
      verifyEq(dt.hour,    hr)
      verifyEq(dt.min,     min)
      verifyEq(dt.sec,     sec)
      verifyEq(dt.nanoSec, nanoSec)
      verifyEq(dt.weekday, weekday)
      verifyEq(dt.dst,     isDST)
      verifyEq(dt.tzAbbr,  isDST ? tz.dstAbbr(year) : tz.stdAbbr(year))
      if (doy != null) verifyEq(dt.dayOfYear, doy)

      verifyEq(dt.date.year,    year)
      verifyEq(dt.date.month,   month)
      verifyEq(dt.date.day,     day)
      verifyEq(dt.date.weekday, weekday)
      if (doy != null) verifyEq(dt.date.dayOfYear, doy)

      verifyEq(dt.time.hour,    hr)
      verifyEq(dt.time.min,     min)
      verifyEq(dt.time.sec,     sec)
      verifyEq(dt.time.nanoSec, nanoSec)
    }

    dtA := makeTicks(ticks, tz)
    dtB := DateTime.make(year, month, day, hr, min, sec, nanoSec, tz)
    func(dtA)
    if (testMake) func(dtB)

    // verify toStr -> fromStr round trip
    dtR := DateTime.fromStr(dtA.toStr)
    verifyEq(dtA, dtR)
    verifyEq(dtA.toStr, dtR.toStr)
    func(dtR)

    // verify date.toStr -> Date.fromStr round trip
    dR := Date.fromStr(dtA.date.toStr)
    verifyEq(dtA.date, dR)
    verifyEq(dtA.date.toStr, dR.toStr)

    // verify time.toStr -> Time.fromStr round trip
    tR := TimeOfDay.fromStr(dtA.time.toStr)
    verifyEq(dtA.time, tR)
    verifyEq(dtA.time.toStr, tR.toStr)
  }
*/
//////////////////////////////////////////////////////////////////////////
// Str
//////////////////////////////////////////////////////////////////////////
/*
  Void testToStr()
  {
    d := makeTicks(8035200123_000000, utc)
    verifyEq(d.toStr, "2000-04-03T00:00:00.123Z UTC")

    if (!isJs)
    {
      d = makeTicks(278744523000_000089, ny)
      verifyEq(d.toStr, "2008-10-31T01:02:03.000000089-04:00 New_York")
    }

    d = makeTicks(215589723000_000000, ny)
    verifyEq(d.toStr, "2006-10-31T01:02:03-05:00 New_York")

    d = makeTicks(289220400000_000000, nl)
    verifyEq(d.toStr, "2009-03-01T12:00:00+01:00 Amsterdam")

    d = makeTicks(290000000000_000000, uk)
    verifyEq(d.toStr, "2009-03-10T11:33:20Z London")

    verifyFromStrErr("2009^03-01T12:00:00+01:00 Amsterdam")
    verifyFromStrErr("2009-03^01T12:00:00+01:00 Amsterdam")
    verifyFromStrErr("2009-03-01^12:00:00+01:00 Amsterdam")
    verifyFromStrErr("2009-03-01T12^00:00+01:00 Amsterdam")
    verifyFromStrErr("2009-03-01T12:00^00+01:00 Amsterdam")
    verifyFromStrErr("2009-03-01T12:00:00^01:00 Amsterdam")
    verifyFromStrErr("2009-03-01T12:00:00+01^00 Amsterdam")
    verifyFromStrErr("2009-03-01T12:00:00+01:00^Amsterdam")
    verifyFromStrErr("2009-03-01T12:00:00+01:00 FooBar")
    verifyFromStrErr("3000-03-01T12:00:00+01:00 FooBar")
    verifyFromStrErr("2009-13-01T12:00:00+01:00 Amsterdam")
    verifyFromStrErr("2009-03-32T12:00:00+01:00 Amsterdam")
    verifyFromStrErr("2009-03-01T24:00:00+01:00 Amsterdam")
    verifyFromStrErr("2009-03-01T12:61:00+01:00 Amsterdam")
    verifyFromStrErr("2009-03-01T12:00:99+01:00 Amsterdam")
    verifyFromStrErr("2009-03-01T12:00:00+01 Amsterdam")
  }
*/
  Void testDateToStr()
  {
    verifyDateToStr(Date(2009, Month.jan, 3), "2009-01-03")
    verifyDateToStr(Date(2009, Month.dec, 30), "2009-12-30")

    verifyEq(Date.fromStr("1972-06-03"), Date(1972, Month.jun, 3))
    //verifyEq(Date.fromIso("2009/05/03", false), null)
    verifyErr(ParseErr#) { x := Date.fromStr("1990") }
    verifyErr(ParseErr#) { x := Date.fromIso("2009-12-30Z") }
    verifyErr(ParseErr#) { x := Date.fromIso("2009-12-30-04:30") }
  }

  Void verifyDateToStr(Date d, Str s)
  {
    verifyEq(d.toStr, s)
    verifyEq(d.toIso, s)
    verifyEq(Date.fromStr(s), d)
    verifyEq(Date.fromIso(s), d)
  }

  Void testTimeToStr()
  {
    verifyTimeToStr(TimeOfDay(2, 30), "02:30:00")
    verifyTimeToStr(TimeOfDay(13, 4, 5), "13:04:05")
    verifyTimeToStr(TimeOfDay(23, 0, 0, 123), "23:00:00.000000123")
    verifyTimeToStr(TimeOfDay(23, 0, 0, 123_456), "23:00:00.000123456")
    verifyTimeToStr(TimeOfDay(23, 0, 43, 123_456_987), "23:00:43.123456987")

    verifyEq(TimeOfDay.fromStr("01:02:03"), TimeOfDay(1, 2, 3))
    verifyEq(TimeOfDay.fromStr("01:02:03.9"), TimeOfDay(1, 2, 3, 900_000_000))
    verifyEq(TimeOfDay.fromStr("01:02:03.308"), TimeOfDay(1, 2, 3, 308_000_000))

    //verifyEq(TimeOfDay.fromStr("30:99", false), null)
    //verifyEq(TimeOfDay.fromIso("12:30:00Z", false), null)
    verifyErr(ParseErr#) { x := TimeOfDay.fromStr("") }
    verifyErr(ParseErr#) { x := TimeOfDay.fromIso("12:30:00+05:00") }
  }

  Void verifyTimeToStr(TimeOfDay t, Str s)
  {
    verifyEq(t.toStr, s)
    verifyEq(t.toIso, s)
    verifyEq(TimeOfDay.fromStr(s), t)
    verifyEq(TimeOfDay.fromIso(s), t)
  }

  Void verifyFromStrErr(Str s)
  {
    verifyEq(DateTime.fromStr(s, false), null)
    verifyErr(ParseErr#) { x := DateTime.fromStr(s) }
    verifyErr(ParseErr#) { x := DateTime.fromStr(s, true) }
  }

//////////////////////////////////////////////////////////////////////////
// Locale
//////////////////////////////////////////////////////////////////////////
/*
  Void testToLocale()
  {
    // basic fields
    x := DateTime.make(2008, Month.feb, 5, 3, 7, 20, 123_000_000, ny)
    verifyEq(x.toLocale("YY, YYYY"), "08, 2008")
    verifyEq(x.toLocale("M, MM, MMM, MMMM"), "2, 02, Feb, February")
    verifyEq(x.toLocale("D, DD, DDD"), "5, 05, 5th")
    verifyEq(x.toLocale("WWW WWWW"), "Tue Tuesday")
    verifyEq(x.toLocale("h, hh, k, kk, a, aa, A, AA"), "3, 03, 3, 03, a, am, A, AM")
    verifyEq(x.toLocale("m, mm"), "7, 07")
    verifyEq(x.toLocale("s, ss"), "20, 20")
    verifyEq(x.toLocale("f, ff, fff, ffff, fffff"), "1, 12, 123, 1230, 12300")
    verifyEq(x.toLocale("F, FF, FFF, FFFF, FFFFF"), "1, 12, 123, 123, 123")
    verifyEq(x.toLocale("F, fF, ffF, ffFF, ffffF"), "1, 12, 123, 123, 1230")
    verifyEq(x.toLocale("z, zzz, zzzz"), "-05:00, EST, New_York")
    Locale("fr").use
    {
      verifyEq(x.toLocale("DD-MMM", Locale.en), "05-Feb")
      verifyEq(x.date.toLocale("DD-MMM", Locale.en), "05-Feb")
    }

    // US locale default pattern (12 hour time)
    verifyEq(x.toLocale(),     "5-Feb-2008 Tue 3:07:20AM EST")
    verifyEq(x.toLocale(null), "5-Feb-2008 Tue 3:07:20AM EST")
    verifyEq(x.date.toLocale(),     "5-Feb-2008")
    verifyEq(x.date.toLocale(null), "5-Feb-2008")
    verifyEq(x.time.toLocale(),     "3:07AM")
    verifyEq(x.time.toLocale(null), "3:07AM")

    // non-US 24 hour time
    Locale("en").use
    {
      verifyEq(x.toLocale(),     "5-Feb-2008 Tue 03:07:20 EST")
      verifyEq(x.toLocale(null), "5-Feb-2008 Tue 03:07:20 EST")
      verifyEq(x.time.toLocale(),     "03:07")
      verifyEq(x.time.toLocale(null), "03:07")
    }

    // 12-hour AM/PM
    x = DateTime.make(2007, Month.may, 9, 0, 5, 0, 0, ny)
    verifyEq(x.toLocale("kk:mma"),  "12:05a")
    verifyEq(x.toLocale("kk:mmaa"), "12:05am")
    verifyEq(x.toLocale("kk:mmA"),  "12:05A")
    verifyEq(x.toLocale("kk:mmAA"), "12:05AM")
    x = DateTime.make(2007, Month.may, 9, 12, 0, 0, 0, ny)
    verifyEq(x.toLocale("kk:mma"),  "12:00p")
    verifyEq(x.toLocale("kk:mmaa"), "12:00pm")
    verifyEq(x.toLocale("kk:mmA"),  "12:00P")
    verifyEq(x.toLocale("kk:mmAA"), "12:00PM")
    x = DateTime.make(2007, Month.may, 9, 23, 12, 00, 0, ny)
    verifyEq(x.toLocale("kk:mma"),  "11:12p")
    verifyEq(x.toLocale("kk:mmaa"), "11:12pm")
    verifyEq(x.toLocale("kk:mmA"),  "11:12P")
    verifyEq(x.toLocale("kk:mmAA"), "11:12PM")

    // time zones
    x = DateTime.make(2007, Month.jun, 17, 1, 2, 3, 0, utc)
    verifyEq(x.toLocale("YYMMDDkkmmssz"), "070617010203Z")
    x = DateTime.make(2007, Month.jun, 17, 1, 2, 3, 0, ny)
    verifyEq(x.toLocale("z|zzz|zzzz"), "-04:00|EDT|New_York")
    x = makeTicks(255148200000_000000, stJohn)
    verifyEq(x.toLocale("z|zzz|zzzz"), "-03:30|NST|St_Johns")
    x = makeTicks(291718800000_000000, kiev)
    verifyEq(x.toLocale("z|zzz|zzzz"), "+03:00|EEST|Kiev")

    // optional secs
    x = DateTime.make(2007, Month.jun, 17, 1, 2, 3, 123_456_789, utc)
    verifyEq(x.toLocale("hh:mm:SS"), "01:02:03")
    verifyEq(x.toLocale("hh:mm:SS.FFF"), "01:02:03.123")
    x = DateTime.make(2007, Month.jun, 17, 1, 2, 0, 123_456_789, utc)
    verifyEq(x.toLocale("hh:mm:SS"), "01:02:00")
    verifyEq(x.toLocale("hh:mm:SS.FFF"), "01:02:00.123")
    x = DateTime.make(2007, Month.jun, 17, 1, 2, 0, 0, utc)
    verifyEq(x.toLocale("hh:mm:SS"), "01:02")
    verifyEq(x.toLocale("hh:mm:SS.FFF"), "01:02")

    // fractions
    x = DateTime.make(2007, Month.jun, 17, 1, 2, 3, 123_456_789, utc)
    verifyEq(x.toLocale("f, ff, fff, ffff, fffff"), "1, 12, 123, 1234, 12345")
    verifyEq(x.toLocale("F, FF, FFF, FFFF, FFFFF"), "1, 12, 123, 1234, 12345")
    verifyEq(x.toLocale("ffffff, fffffff, ffffffff, fffffffff"), "123456, 1234567, 12345678, 123456789")
    verifyEq(x.toLocale("FFFFFF, FFFFFFF, FFFFFFFF, FFFFFFFFF"), "123456, 1234567, 12345678, 123456789")
    verifyEq(x.toLocale("fffFFF, fFFFFFF, fffffffF, fffffffFF"), "123456, 1234567, 12345678, 123456789")
    x = DateTime.make(2007, Month.jun, 17, 1, 2, 3, 009_870_000, utc)
    verifyEq(x.toLocale("f,ff,fff,ffff,fffff,ffffff"), "0,00,009,0098,00987,009870")
    verifyEq(x.toLocale("F,FF,FFF,FFFF,FFFFF,FFFFFF"), "0,00,009,0098,00987,00987")
    verifyEq(x.toLocale("fffFF,fffFFF,ffffffFFF"), "00987,00987,009870")
    x = DateTime.make(2007, Month.jun, 17, 1, 2, 3, 0, utc)
    verifyEq(x.toLocale("|f, |F, |fF"), "|0, , |0")

    // literals
    x = DateTime.make(2007, Month.may, 9, 15, 30, 0, 0, ny)
    verifyEq(x.toLocale("YYMMDD'T'hhmm"), "070509T1530")
    verifyEq(x.toLocale("'It is' k:mmaa!"), "It is 3:30pm!")
    verifyEq(x.toLocale("''YY"), "'07")

    // errors
    verifyErr(ArgErr#) { x.toLocale("Y") }
    verifyErr(ArgErr#) { x.toLocale("YYY") }
    verifyErr(ArgErr#) { x.toLocale("YYYYY") }
    verifyErr(ArgErr#) { x.toLocale("MMMMM") }
    verifyErr(ArgErr#) { x.toLocale("DDDD") }
    verifyErr(ArgErr#) { x.toLocale("WW") }
    verifyErr(ArgErr#) { x.toLocale("WWWWW") }
    verifyErr(ArgErr#) { x.toLocale("hhh") }
    verifyErr(ArgErr#) { x.toLocale("kkk") }
    verifyErr(ArgErr#) { x.toLocale("aaa") }
    verifyErr(ArgErr#) { x.toLocale("mmm") }
    verifyErr(ArgErr#) { x.toLocale("sss") }
  }

  Void testFromLocale()
  {
    verifyFromLocale("02-Jan-99 12:30PM", "DD-MMM-YY kk:mmAA", ny,
                     DateTime(1999, Month.jan, 2, 12, 30, 0, 0, ny))

    verifyFromLocale("3-MARCH-04 12:05:33am", "D-MMMM-YY kk:mm:ssaa", la,
                     DateTime(2004, Month.mar, 3, 0, 5, 33, 0, la))

    verifyFromLocale("2010-04-04T23:45:17.089", "YYYY-MM-DD'T'kk:mm:ss.F", ny,
                     DateTime(2010, Month.apr, 4, 23, 45, 17, 89_000_000, ny))

    verifyFromLocale("2010-04-04 and 23:45:17.000123004", "YYYY-MM-DD 'and' kk:mm:ss.F", ny,
                     DateTime(2010, Month.apr, 4, 23, 45, 17, 123_004, ny))

    // test various combos of SS and FFF

    verifyFromLocale("2010-07-04 23:45:17", "YYYY-MM-DD kk:mm:ss.F", ny,
                     DateTime(2010, Month.jul, 4, 23, 45, 17, 0, ny))

    verifyFromLocale("2010-07-04 23:45:17", "YYYY-MM-DD kk:mm:SS.F", ny,
                     DateTime(2010, Month.jul, 4, 23, 45, 17, 0, ny))

    verifyFromLocale("2010-07-04 23:45", "YYYY-MM-DD kk:mm:SS.FFF", ny,
                     DateTime(2010, Month.jul, 4, 23, 45, 0, 0, ny))

    verifyFromLocale("2010-07-04 23:45:17.052 Los_Angles", "YYYY-MM-DD kk:mm:ss.F", la,
                     DateTime(2010, Month.jul, 4, 23, 45, 17, 52_000_000, la))

    verifyFromLocale("2010-07-04 23:45:17 Los_Angles", "YYYY-MM-DD kk:mm:SS.F", la,
                     DateTime(2010, Month.jul, 4, 23, 45, 17, 0, la))

    verifyFromLocale("2010-07-04 23:45:13.2 Los_Angles", "YYYY-MM-DD kk:mm:SS.F", la,
                     DateTime(2010, Month.jul, 4, 23, 45, 13, 200_000_000, la))

    verifyFromLocale("2010-07-04 23:45:13.2 Los_Angles", "YYYY-MM-DD kk:mm:SS.FFF", la,
                     DateTime(2010, Month.jul, 4, 23, 45, 13, 200_000_000, la))

    verifyFromLocale("2010-07-04 23:45 Los_Angles", "YYYY-MM-DD kk:mm:SS.F", la,
                     DateTime(2010, Month.jul, 4, 23, 45, 0, 0, la))

    // matches passed tz

    verifyFromLocale("2010-03-04 13:00 -08:00", "YYYY-MM-DD kk:mm z", la,
                     DateTime(2010, Month.mar, 4, 13, 0, 0, 0, la))

    verifyFromLocale("2010-06-04 13:00 -07:00", "YYYY-MM-DD kk:mm z", la,
                     DateTime(2010, Month.jun, 4, 13, 0, 0, 0, la))

    verifyFromLocale("2010-03-04 13:00 PST", "YYYY-MM-DD kk:mm zzz", la,
                     DateTime(2010, Month.mar, 4, 13, 0, 0, 0, la))

    verifyFromLocale("2010-03-04 13:00 Los_Angeles", "YYYY-MM-DD kk:mm zzzz", la,
                     DateTime(2010, Month.mar, 4, 13, 0, 0, 0, la))

    verifyFromLocale("2010-03-04 13:00 Z", "YYYY-MM-DD kk:mm z", utc,
                     DateTime(2010, Month.mar, 4, 13, 0, 0, 0, utc))

    verifyFromLocale("2010-03-04 13:00 -05:00", "YYYY-MM-DD kk:mm z", ny,
                     DateTime(2010, Month.mar, 4, 13, 0, 0, 0, ny))

    verifyFromLocale("2010-03-04 13:00 -0500", "YYYY-MM-DD kk:mm z", ny,
                     DateTime(2010, Month.mar, 4, 13, 0, 0, 0, ny))

    verifyFromLocale("2010-03-04 13:00 -05", "YYYY-MM-DD kk:mm z", ny,
                     DateTime(2010, Month.mar, 4, 13, 0, 0, 0, ny))

    // does not match passed tz

    verifyFromLocale("2010-03-04 13:00 Z", "YYYY-MM-DD kk:mm z", la,
                     DateTime(2010, Month.mar, 4, 13, 0, 0, 0, utc))

    verifyFromLocale("2010-03-04 13:00 -04:00", "YYYY-MM-DD kk:mm z", la,
                     DateTime(2010, Month.mar, 4, 13, 0, 0, 0, TimeZone("GMT+4")))

    verifyFromLocale("2010-03-04 13:00 +11:00", "YYYY-MM-DD kk:mm z", la,
                     DateTime(2010, Month.mar, 4, 13, 0, 0, 0, TimeZone("GMT-11")))

    verifyFromLocale("2010-03-04 13:00 New_York", "YYYY-MM-DD kk:mm zzzz", la,
                     DateTime(2010, Month.mar, 4, 13, 0, 0, 0, ny))

    verifyFromLocale("2010-03-04 13:00 -04:00", "YYYY-MM-DD kk:mm z", ny, // std is -5
                     DateTime(2010, Month.mar, 4, 13, 0, 0, 0, TimeZone("GMT+4")))

    verifyFromLocale("2010-06-04 13:00 -08:00", "YYYY-MM-DD kk:mm z", la, // dst is -7
                     DateTime(2010, Month.jun, 4, 13, 0, 0, 0, TimeZone("GMT+8")))

    // various ISO 8601 timezone offsets

    verifyFromLocale("-03:00 10JUN201123:19", "z DMMMYYYYhh:mm", ny,
                     DateTime(2011, Month.jun, 10, 23, 19, 0, 0, TimeZone("GMT+3")))

    verifyFromLocale("-0300 10JUN201123:19", "z DMMMYYYYhh:mm", ny,
                     DateTime(2011, Month.jun, 10, 23, 19, 0, 0, TimeZone("GMT+3")))

    verifyFromLocale("-03 10JUN201123:19", "z DMMMYYYYhh:mm", ny,
                     DateTime(2011, Month.jun, 10, 23, 19, 0, 0, TimeZone("GMT+3")))

    // fractional offsets round to hour - not all that swell, but
    // otherwise we'd need to create non-standard GMT timezones?
    // so we are left with correct offset, but it doesn't match timezone

    ts := DateTime.fromLocale("-0330 10JUN201123:19", "z DMMMYYYYhh:mm")
    verifyEq(ts.tz, TimeZone("GMT+3"))
    verifyEq(ts->ticks, DateTime(2011, Month.jun, 10, 23, 19, 0, 0, TimeZone("GMT+3")).plus(30min)->ticks)

    // cur timezone
    verifyEq(DateTime.fromLocale("10-08-23 4:55", "YY-MM-DD k:mm"), DateTime(2010, Month.aug, 23, 4, 55, 0))

    // more SS and FF tests
    verifyEq(DateTime.fromLocale("2011-01-02T12:37:07.372-05:00 New_York", "YYYY-MM-DD'T'hh:mm:SS.FFFFFFFFFz zzzz"),
                        DateTime("2011-01-02T12:37:07.372-05:00 New_York"))

    verifyEq(DateTime.fromLocale("2011-01-02T12:37:02-05:00 New_York", "YYYY-MM-DD'T'hh:mm:SS.FFFFFFFFFz zzzz"),
                        DateTime("2011-01-02T12:37:02-05:00 New_York"))

    verifyEq(DateTime.fromLocale("2011-01-02T12:37-05:00 New_York", "YYYY-MM-DD'T'hh:mm:SS.FFFFFFFFFz zzzz"),
                        DateTime("2011-01-02T12:37:00-05:00 New_York"))

    // errors
    verifyNull(DateTime.fromLocale("adsfy", "YY-MM-DD k:mm", ny, false))
    verifyErr(ParseErr#) { DateTime.fromLocale("xx-03-02 23:00", "YY-MM-DD k:mm") }
    verifyErr(ParseErr#) { DateTime.fromLocale("03-02 23:00", "YY-MM-DD k:mm", ny, true) }
  }

  Void verifyFromLocale(Str s, Str pattern, TimeZone tz, DateTime expected)
  {
    actual := DateTime.fromLocale(s, pattern, tz)
    verifyEq(actual, expected)
    verifyEq(actual.tz, expected.tz)
  }

  Void testDateLocale()
  {
    d := Date(2009, Month.jan, 10)
    verifyDateLocale(d, "D/M/YYYY", "10/1/2009")
    verifyDateLocale(d, "WWW D-MMM-YYYY", "Sat 10-Jan-2009")
    verifyDateLocale(d, "DD MMM ''YY", "10 Jan '09")
    verifyDateLocale(d, "'Tis is' DD MMM ''YY", "Tis is 10 Jan '09")

    verifyDateLocale(Date(1999, Month.mar, 2), "D-MMMM-YY", "2-March-99")
    verifyDateLocale(Date(2001, Month.oct, 23), "D-MMMM-YY", "23-October-01")

    d = Date(1776, Month.jul, 4)
    verifyDateLocale(d, "MMMM D, YYYY", "July 4, 1776")
    verifyDateLocale(d, "MMMM DDD, YYYY", "July 4th, 1776")

    verifyEq(Date("2010-01-01").toLocale("DDD"), "1st")
    verifyEq(Date("2010-01-02").toLocale("DDD"), "2nd")
    verifyEq(Date("2010-01-03").toLocale("DDD"), "3rd")
    verifyEq(Date("2010-01-04").toLocale("DDD"), "4th")
    verifyEq(Date("2010-01-11").toLocale("DDD"), "11th")
    verifyEq(Date("2010-01-12").toLocale("DDD"), "12th")
    verifyEq(Date("2010-01-13").toLocale("DDD"), "13th")
    verifyEq(Date("2010-01-20").toLocale("DDD"), "20th")
    verifyEq(Date("2010-01-21").toLocale("DDD"), "21st")
    verifyEq(Date("2010-01-22").toLocale("DDD"), "22nd")
    verifyEq(Date("2010-01-23").toLocale("DDD"), "23rd")
    verifyEq(Date("2010-01-24").toLocale("DDD"), "24th")
    verifyEq(Date("2010-01-30").toLocale("DDD"), "30th")
    verifyEq(Date("2010-01-31").toLocale("DDD"), "31st")

    verifyNull(Date.fromLocale("2-nomonth-1999", "D-MMMM-YYYY", false))
    verifyErr(ParseErr#) { Date.fromLocale("xyz", "YY-MM-DD") }
    verifyErr(ParseErr#) { Date.fromLocale("99-xxx-02", "YY-MMM-DD", true) }
  }

  Void verifyDateLocale(Date d, Str pattern, Str expected)
  {
    verifyEq(d.toLocale(pattern), expected)
    verifyEq(Date.fromLocale(expected, pattern), d)
  }

  Void testTimeLocale()
  {
    t := TimeOfDay(13, 2, 4, 123_000_678)
    verifyTimeLocale(t, "h:mmAA",  "13:02PM", TimeOfDay(13, 2))
    verifyTimeLocale(t, "k:mmaa",  "1:02pm",  TimeOfDay(13, 2))
    verifyTimeLocale(t, "kk:mma",  "01:02p", TimeOfDay(13, 2))
    verifyTimeLocale(t, "kk:mmA",  "01:02P", TimeOfDay(13, 2))
    verifyTimeLocale(t, "k:mm:ss.F AA", "1:02:04.1 PM", TimeOfDay(13, 2, 4, 100_000_000))
    verifyTimeLocale(t, "h:mm:ss.ffffff", "13:02:04.123000", TimeOfDay(13, 2, 4, 123_000_000))
    verifyTimeLocale(t, "h:mm:ss.FFFFFFFFF", "13:02:04.123000678")

    verifyTimeLocale(TimeOfDay(1, 2), "hh:mm:SS", "01:02")
    verifyTimeLocale(TimeOfDay(1, 2, 3), "hh:mm:SS", "01:02:03")
    verifyTimeLocale(TimeOfDay(1, 2, 0, 400_000_000), "hh:mm:SS", "01:02:00", TimeOfDay(1, 2))
    verifyTimeLocale(TimeOfDay(1, 2, 0, 400_000_000), "hh:mm:SS.FF", "01:02:00.4")

    verifyTimeLocale(TimeOfDay(0, 0), "k:mm:ss AA", "12:00:00 AM")
    verifyTimeLocale(TimeOfDay(0, 0, 3), "k:mm:ss a", "12:00:03 a")
    verifyTimeLocale(TimeOfDay(11, 59, 59), "k:mm:ss A", "11:59:59 A")
    verifyTimeLocale(TimeOfDay(12, 0), "k:mm:ss aa", "12:00:00 pm")
    verifyTimeLocale(TimeOfDay(3, 0), "''h:mm 'time'", "'3:00 time")

    verifyNull(TimeOfDay.fromLocale("xx:yy", "kk:mm", false))
    verifyErr(ParseErr#) { TimeOfDay.fromLocale("3x:33", "kk:mm") }
    verifyErr(ParseErr#) { TimeOfDay.fromLocale("10:7x", "kk:mm", true) }
    verifyErr(ParseErr#) { TimeOfDay.fromLocale("10:30", "''kk:mm") }
    verifyErr(ParseErr#) { TimeOfDay.fromLocale("10:30 ti", "kk:mm 'time'") }

  }

  Void verifyTimeLocale(TimeOfDay t, Str pattern, Str expected, TimeOfDay fromLocale := t)
  {
    verifyEq(t.toLocale(pattern), expected)
    verifyEq(TimeOfDay.fromLocale(expected, pattern), fromLocale)
  }
*/
//////////////////////////////////////////////////////////////////////////
// Java
//////////////////////////////////////////////////////////////////////////

  Void testJava()
  {
    x := DateTime.fromJava(1227185341155, ny)
    verifyEq(x.tz, ny)
    verifyEq(x.year, 2008)
    verifyEq(x.month, Month.nov)
    verifyEq(x.day, 20)
    verifyEq(x.hour, 7)
    verifyEq(x.min, 49)
    verifyEq(x.toJava, 1227185341155)

    verifyEq(DateTime.fromJava(0, utc), null)
    verifyEq(DateTime.fromJava(-1, utc), null)
    //verifyEq(DateTime.fromJava(-86400000, utc, false).toStr, "1969-12-31T00:00:00Z UTC")
 }

//////////////////////////////////////////////////////////////////////////
// ISO 8601
//////////////////////////////////////////////////////////////////////////
/*
  Void testIso()
  {
    //verifyIso("2000-01-15T02:03:04Z", 2000, jan, 15, 2, 3, 4, 0, utc, 0hr)
    verifyIso("2009-02-15T23:00:00.5-05:00", 2009, feb, 15, 23, 0, 0, 500_000_000, TimeZone("Etc/GMT+5"), -5hr)
    verifyIso("2009-02-15T23:00:00.0+10:00", 2009, feb, 15, 23, 0, 0, 0, TimeZone("Etc/GMT-10"), +10hr)

    //verifyNull(DateTime.fromIso(DateTime.now.toStr, false))
    //verifyNotNull(DateTime.fromIso(DateTime.now.toIso, false))
    //verifyErr(ParseErr#) { DateTime.fromIso(DateTime.now.toStr) }
  }

  Void verifyIso(Str s, Int y, Month mon, Int day, Int h, Int min, Int sec, Int ns, TimeZone tz, Duration offset)
  {
    verifyErr(ParseErr#) { x := DateTime.fromStr(s); }
    d := DateTime.fromIso(s)
    verifyEq(d.year, y)
    verifyEq(d.month, mon)
    verifyEq(d.day, day)
    verifyEq(d.hour, h)
    verifyEq(d.min, min)
    verifyEq(d.sec, sec)
    verifyEq(d.nanoSec, ns)
    verifyEq(d.tz, tz)
    verifyEq(d.tz.offset(y), offset)
    verifyEq(d->ticks, DateTime(y, mon, day, h, min, sec, ns, tz)->ticks)
  }
*/
//////////////////////////////////////////////////////////////////////////
// HTTP
//////////////////////////////////////////////////////////////////////////
/*
  Void testHttpStr()
  {
    x := DateTime.make(1994, Month.nov, 6, 8, 49, 37, 0, utc)
    verifyEq(DateTime.fromHttpStr("Sun, 06 Nov 1994 08:49:37 GMT"), x)
    verifyEq(DateTime.fromHttpStr("Sunday, 06-Nov-94 08:49:37 GMT"), x)
    //verifyEq(DateTime.fromHttpStr("Sun Nov  6 08:49:37 1994"), x)
    verifyEq(x.toHttpStr, "Sun, 06 Nov 1994 08:49:37 GMT")

    x = DateTime("2009-06-04T07:52:00-04:00 New_York")
    verifyEq(x.toHttpStr, "Thu, 04 Jun 2009 11:52:00 GMT")
    verifyEq(DateTime.fromHttpStr("Thu, 04 Jun 2009 11:52:00 GMT"), x)
    Locale("es").use
    {
      verifyEq(x.toHttpStr, "Thu, 04 Jun 2009 11:52:00 GMT")
      verifyEq(DateTime.fromHttpStr("Thu, 04 Jun 2009 11:52:00 GMT"), x)
    }

    verifyEq(DateTime.fromHttpStr("06 Nov 1994 08:49:37", false), null)
    verifyErr(ParseErr#) { DateTime.fromHttpStr("Sun, 06 Nov 08:49:37 GMT") }
  }
*/
//////////////////////////////////////////////////////////////////////////
// Default Values
//////////////////////////////////////////////////////////////////////////

  Void testDefVal()
  {
    verifySame(TimeZone.defVal, TimeZone.utc)
    verifySame(TimeZone#.make, TimeZone.utc)

    verifyEq(DateTime.defVal, DateTime(2000, jan, 1, 0, 0, 0, 0, TimeZone.utc))
    verifyEq(DateTime#.make, DateTime(2000, jan, 1, 0, 0, 0, 0, TimeZone.utc))

    verifyEq(Date.defVal, Date(2000, jan, 1))
    verifyEq(Date#.make, Date(2000, jan, 1))

    verifyEq(TimeOfDay.defVal, TimeOfDay(0, 0, 0))
    verifyEq(TimeOfDay#.make, TimeOfDay(0, 0, 0))
  }

//////////////////////////////////////////////////////////////////////////
// To Code
//////////////////////////////////////////////////////////////////////////
/*
  Void testToCode()
  {
    // DateTime
    verifyEq(DateTime.defVal.toCode, "DateTime.defVal")
    verifyEq(DateTime(2009, Month.jan, 29, 13, 30, 0, 0, TimeZone.utc).toCode, "DateTime(\"2009-01-29T13:30:00Z UTC\")")

    // Date
    verifyEq(Date.defVal.toCode, "Date.defVal")
    verifyEq(Date(2009, Month.jun, 7).toCode, "Date(\"2009-06-07\")")

    // Time
    verifyEq(TimeOfDay.defVal.toCode, "TimeOfDay.defVal")
    verifyEq(TimeOfDay(8, 30, 8).toCode, "TimeOfDay(\"08:30:08\")")
  }
*/
//////////////////////////////////////////////////////////////////////////
// Midnight
//////////////////////////////////////////////////////////////////////////

  Void testMidnight()
  {
    // DateTime.midnight
    verifyEq(DateTime.now.midnight.time, TimeOfDay(0, 0, 0))
    verifyEq(DateTime(2008, apr, 14, 2, 3, 4, 0, utc).midnight,
             DateTime(2008, apr, 14, 0, 0, 0, 0, utc))
    verifyEq(DateTime(1990, feb, 28, 12, 33, 45, 666_777, la).midnight,
             DateTime(1990, feb, 28, 0, 0, 0, 0, la))

    // Date.midnight
    verifyEq(Date.today.midnight.date, Date.today)
    verifyEq(Date.today.midnight.time, TimeOfDay(0, 0, 0))
    verifyEq(Date(2008, apr, 14).midnight(la), DateTime(2008, apr, 14, 0, 0, 0, 0, la))

    // DST
    verifyEq(DateTime(2009, Month.mar, 7, 4, 5, 0, 0, ny).midnight.time, TimeOfDay(0, 0))
    verifyEq(DateTime(2009, Month.nov, 1, 4, 5, 0, 0, ny).midnight.time, TimeOfDay(0, 0))

    // isMidnight
    x := Date.today.midnight
    verifyEq(x.isMidnight, true)
    verifyEq(x.time.isMidnight, true)
    x = x+1ms
    verifyEq(x.isMidnight, false)
    verifyEq(x.time.isMidnight, false)
  }

//////////////////////////////////////////////////////////////////////////
// Date, Time toDateTime
//////////////////////////////////////////////////////////////////////////

  Void testToDateTime()
  {
    f := |DateTime dt|
    {
      verifyEq(dt, DateTime(2009, Month.dec, 31, 12, 30, 47, 123_000_000))
      verifyEq(dt.tz, TimeZone.cur)
      verifyEq(dt.year, 2009)
      verifyEq(dt.month, Month.dec)
      verifyEq(dt.day, 31)
      verifyEq(dt.hour, 12)
      verifyEq(dt.min, 30)
      verifyEq(dt.sec, 47)
      verifyEq(dt.nanoSec, 123_000_000)
    }
    f(Date(2009, Month.dec, 31).toDateTime(TimeOfDay(12, 30, 47, 123_000_000)))
    f(TimeOfDay(12, 30, 47, 123_000_000).toDateTime(Date(2009, Month.dec, 31)))

    f = |DateTime dt|
    {
      verifyEq(dt, DateTime(2008, Month.feb, 28, 23, 0, 0, 0, la))
      verifyEq(dt.tz, la)
    }
    f(Date(2008, Month.feb, 28).toDateTime(TimeOfDay(23, 0), la))
    f(TimeOfDay(23, 0).toDateTime(Date(2008, Month.feb, 28), la))
  }

//////////////////////////////////////////////////////////////////////////
// Time.toDuration
//////////////////////////////////////////////////////////////////////////

  Void testToDuration()
  {
    verifyToDuration(TimeOfDay(0, 0, 0, 0), 0ms)
    verifyToDuration(TimeOfDay(0, 0, 0, 1000_000), 1ms)
    verifyToDuration(TimeOfDay(0, 0, 2, 0), 2sec)
    verifyToDuration(TimeOfDay(0, 3, 0, 0), 3min)
    verifyToDuration(TimeOfDay(4, 0, 0, 0), 4hr)
    verifyToDuration(TimeOfDay(4, 3, 2, 1000_000), 4hr+3min+2sec+1ms)
    verifyToDuration(TimeOfDay(23, 59, 12, 123_000_000), 23hr+59min+12sec+123ms)
    verifyErr(ArgErr#) { TimeOfDay.fromDuration(-10hr) }
    verifyErr(ArgErr#) { TimeOfDay.fromDuration(25hr) }
  }

  Void verifyToDuration(TimeOfDay t, Duration d)
  {
    verifyEq(t.toDuration, d)
    verifyEq(TimeOfDay.fromDuration(d), t)
  }

//////////////////////////////////////////////////////////////////////////
// Time plus/minus
//////////////////////////////////////////////////////////////////////////

  Void testTimeMath()
  {
    verifyTimeMath(TimeOfDay(5,0,0),    TimeOfDay(5,0,0),     0min)
    verifyTimeMath(TimeOfDay(5,0,0),    TimeOfDay(5,30,0),    30min)
    verifyTimeMath(TimeOfDay(5,0,0),    TimeOfDay(4,30,0),    -30min)
    verifyTimeMath(TimeOfDay(2,30,0),   TimeOfDay(3,30,0),    1hr)
    verifyTimeMath(TimeOfDay(2,30,0),   TimeOfDay(1,30,0),    -1hr)
    verifyTimeMath(TimeOfDay(20,12,25), TimeOfDay(20,13, 3),  38sec)
    verifyTimeMath(TimeOfDay(20,12,25), TimeOfDay(20,11,47),  -38sec)
    verifyTimeMath(TimeOfDay(23,59,59), TimeOfDay(0,0,0),     1sec)
    verifyTimeMath(TimeOfDay(0,0,0),    TimeOfDay(0,0,0),     24hr)
    verifyTimeMath(TimeOfDay(22,30,00), TimeOfDay(3,30,0),    5hr)
    verifyTimeMath(TimeOfDay(1,15,00),  TimeOfDay(23,15,0),   -2hr)

    verifyErr(ArgErr#) { x := TimeOfDay(3,30,0) + 25hr }
    verifyErr(ArgErr#) { x := TimeOfDay(3,30,0) + 2day }
  }

  Void verifyTimeMath(TimeOfDay a, TimeOfDay b, Duration diff)
  {
    verifyEq(a + diff, b)
    verifyEq(b + -diff, a)
    verifyEq(b - diff, a)
  }

//////////////////////////////////////////////////////////////////////////
// Date plus/minus
//////////////////////////////////////////////////////////////////////////

  Void testDateMath()
  {
    verifyDateMath(Date(2009, mar, 16),  Date(2009, mar, 16),  0day)
    verifyDateMath(Date(2009, feb, 24),  Date(2009, feb, 25),  1day)
    verifyDateMath(Date(2009, feb, 24),  Date(2009, feb, 21),  -3day)
    verifyDateMath(Date(2009, feb, 25),  Date(2009, mar, 1),   4day)
    verifyDateMath(Date(2009, feb, 1),   Date(2009, jan, 30),  -2day)
    verifyDateMath(Date(2009, dec, 31),  Date(2010, jan, 5),   5day)
    verifyDateMath(Date(2010, jan, 5),   Date(2009, dec, 31),  -5day)
    verifyDateMath(Date(2008, jan, 5),   Date(2009, jan, 4),   365day)
    verifyDateMath(Date(2010, jan, 5),   Date(2011, jan, 5),   365day)
    verifyDateMath(Date(1972, jun, 7),   Date(1972, jun, 6),   -1day)
    verifyDateMath(Date(2000, jan, 1),   Date(2010, jan, 1),   3653day)
    verifyDateMath(Date(1999, dec, 31),  Date(2010, jan, 1),   3654day)
    verifyDateMath(Date(1999, dec, 30),  Date(2010, jan, 1),   3655day)
    verifyDateMath(Date(1999, dec, 30),  Date(2010, jan, 3),   3657day)
    verifyDateMath(Date(1980, feb, 3),   Date(1979, dec, 15),  -50day)
    verifyDateMath(Date(1981, feb, 3),   Date(1979, dec, 15),  -416day)

    verifyErr(ArgErr#) { x := Date.today + 22hr }
    verifyErr(ArgErr#) { x := Date.today + -13min }
    verifyErr(ArgErr#) { x := Date.today - 23hr }
  }

  Void verifyDateMath(Date a, Date b, Duration diff)
  {
    verifyEq(a + diff, b)
    verifyEq(b + -diff, a)
    verifyEq(b - diff, a)
    verifyEq(b - a, diff)
    verifyEq(a - b, -diff)
  }

  Void testDateFirstAndLast()
  {
    verifyDateFirstAndLast(Date(2009, jan, 1))
    verifyDateFirstAndLast(Date(2009, jan, 31))
    verifyDateFirstAndLast(Date(2009, oct, 31))
    verifyDateFirstAndLast(Date(2008, feb, 4))
    verifyDateFirstAndLast(Date(2009, feb, 7))
  }

  Void verifyDateFirstAndLast(Date d)
  {
    first := d.firstOfMonth
    verifyEq(first.year,  d.year)
    verifyEq(first.month, d.month)
    verifyEq(first.day,   1)
    last := d.lastOfMonth
    verifyEq(last.year,  d.year)
    verifyEq(last.month, d.month)
    verifyEq(last.day,   d.month.numDays(d.year))
  }

//////////////////////////////////////////////////////////////////////////
// Today/Tomorrow/Yesterday
//////////////////////////////////////////////////////////////////////////

  Void testIsToday()
  {
    d := Date.today
    verifyEq(d.isYesterday, false)
    verifyEq(d.isToday,     true)
    verifyEq(d.isTomorrow,  false)

    d = Date.today + 1day
    verifyEq(d.isYesterday, false)
    verifyEq(d.isToday,     false)
    verifyEq(d.isTomorrow,  true)

    d = Date.today + -1day
    verifyEq(d.isYesterday, true)
    verifyEq(d.isToday,     false)
    verifyEq(d.isTomorrow,  false)

    d = Date.today + -2day
    verifyEq(d.isYesterday, false)
    verifyEq(d.isToday,     false)
    verifyEq(d.isTomorrow,  false)

    d = Date.today + 365day
    verifyEq(d.isYesterday, false)
    verifyEq(d.isToday,     false)
    verifyEq(d.isTomorrow,  false)
  }

//////////////////////////////////////////////////////////////////////////
// WeekOfYear
//////////////////////////////////////////////////////////////////////////
/*
  Void testWeekOfYear()
  {
    verifyWeekOfYear("2013-01-01", 1, 1, 1)
    verifyWeekOfYear("2013-01-05", 1, 1, 1)
    verifyWeekOfYear("2013-01-06", 2, 1, 1)
    verifyWeekOfYear("2013-01-07", 2, 2, 1)
    verifyWeekOfYear("2013-01-08", 2, 2, 2)
    verifyWeekOfYear("2013-01-12", 2, 2, 2)
    verifyWeekOfYear("2013-01-14", 3, 3, 2)
    verifyWeekOfYear("2013-02-18", 8, 8, 7)
    verifyWeekOfYear("2013-04-15", 16, 16, 15)
    verifyWeekOfYear("2013-12-23", 52, 52, 51)
    verifyWeekOfYear("2013-12-29", 53, 52, 52)
    verifyWeekOfYear("2013-12-30", 53, 53, 52)
    verifyWeekOfYear("2013-12-31", 53, 53, 53)

    verifyEq(Date("2013-01-01").dayOfYear, 1)
    verifyEq(Date("2013-02-01").dayOfYear, 32)
    verifyEq(Date("2013-12-31").dayOfYear, 365)
  }

  Void verifyWeekOfYear(Str date, Int us, Int fi, Int tue)
  {
    d := Date(date)
    Locale("en-US").use { doVerifyWeekOfYear(d, us) }
    if (!isJs)
      Locale("fi").use    { doVerifyWeekOfYear(d, fi) }
    verifyEq(d.weekOfYear(Weekday.tue), tue)
    verifyEq(d.toDateTime(TimeOfDay(23,59)).weekOfYear(Weekday.tue), tue)
  }

  private Void doVerifyWeekOfYear(Date d, Int woy)
  {
    verifyEq(d.weekOfYear, woy)
    verifyEq(d.toDateTime(TimeOfDay(12,0)).weekOfYear, woy)
    verifyEq(d.toLocale("w ww www"), weekOfYearPattern(woy))
    verifyEq(d.toDateTime(TimeOfDay(0,0)).toLocale("w ww www" ), weekOfYearPattern(woy))
  }

  private Str weekOfYearPattern(Int woy)
  {
    switch (woy)
    {
      case 1: return "1 01 1st"
      case 2: return "2 02 2nd"
      case 3: return "3 03 3rd"
      case 7: return "7 07 7th"
      case 8: return "8 08 8th"
      case 52: return "52 52 52nd"
      case 53: return "53 53 53rd"
      default: return "$woy $woy ${woy}th"
    }
  }
*/
//////////////////////////////////////////////////////////////////////////
// HoursInDay
//////////////////////////////////////////////////////////////////////////
/*
  Void testHoursInDay()
  {
    verifyHoursInDay("2013-03-09",  "New_York", 24)
    verifyHoursInDay("2013-03-10", "New_York", 23)
    verifyHoursInDay("2013-03-11", "New_York", 24)
    verifyHoursInDay("2013-06-19", "New_York", 24)
    verifyHoursInDay("2013-11-02", "New_York", 24)
    verifyHoursInDay("2013-11-03", "New_York", 25)
    verifyHoursInDay("2013-12-31", "New_York", 24)

    verifyHoursInDay("2015-03-29", "Madrid", 23)
    verifyHoursInDay("2015-03-30", "Madrid", 24)
    verifyHoursInDay("2015-10-25", "Madrid", 25)
    verifyHoursInDay("2015-10-26", "Madrid", 24)

    verifyHoursInDay("2015-10-26", "UTC", 24)
  }

  private Void verifyHoursInDay(Str d, Str tz, Int expected)
  {
    dt := Date(d).toDateTime(TimeOfDay((0..23).random, 30), TimeZone(tz))
    verifyEq(dt.hoursInDay, expected)
  }
*/
//////////////////////////////////////////////////////////////////////////
// Rel Normalization
//////////////////////////////////////////////////////////////////////////

  Void testRel()
  {
    now := DateTime.now
    verifyRel(now, now.toRel)
    verifyRel(now, now.toTimeZone(TimeZone.rel))

    verifyRelCmp("2010-06-03T12:00:00-04:00 New_York", "2010-06-03T12:00:00-05:00 Chicago", 0)
    verifyRelCmp("2010-06-03T12:00:00-04:00 New_York", "2010-06-03T11:00:00-05:00 Chicago", 1)
    verifyRelCmp("2010-06-03T12:00:00-04:00 New_York", "2010-06-03T12:00:00+08:00 Taipei", 0)
  }

  Void verifyRel(DateTime x, DateTime r)
  {
    verifySame(r.toRel, r)
    verifySame(r.toTimeZone(TimeZone.rel), r)

    verifyEq(x.year,  r.year)
    verifyEq(x.month, r.month)
    verifyEq(x.day,   r.day)
    verifyEq(x.hour,  r.hour)
    verifyEq(x.min,   r.min)
    verifyEq(x.sec,   r.sec)
    verifyEq(x.nanoSec, r.nanoSec)
    verifyEq(x.weekday, r.weekday)
    verifySame(r.dst, false)
    verifySame(r.tz,  TimeZone.rel)
    verifyEq(r->ticks, r.toUtc->ticks)

    y := r.toTimeZone(x.tz)
    verifyEq(x, y)
    verifyEq(x.year,  y.year)
    verifyEq(x.month, y.month)
    verifyEq(x.day,   y.day)
    verifyEq(x.hour,  y.hour)
    verifyEq(x.min,   y.min)
    verifyEq(x.sec,   y.sec)
    verifyEq(x.nanoSec, y.nanoSec)
    verifyEq(x.weekday, y.weekday)
    verifySame(x.dst, x.dst)
    verifySame(x.tz,  y.tz)
  }

  Void verifyRelCmp(Str aStr, Str bStr, Int cmp)
  {
    a := DateTime(aStr).toRel
    b := DateTime(bStr).toRel

    cr := a <=> b
    if (cr > 0) cr = 1
    else if (cr < 0) cr = -1
    verifyEq(cr, cmp)

    if (cmp == 0) verifyEq(a, b)
    else verifyNotEq(a, b)

    if (cmp < 0) verify(a < b)
    if (cmp > 0) verify(a > b)
  }

//////////////////////////////////////////////////////////////////////////
// All Locales
//////////////////////////////////////////////////////////////////////////
/*
  Void testAllLocales()
  {
    if (isJS) return

    locales := Pod.find("sys").files.findAll |f| { f.pathStr.startsWith("/locale/") }.map |f| { f.basename }
    locales.each |locale|
    {
      Locale.setCur(Locale(locale))
      try
      {
        ts := DateTime.now
        verifyNotNull(ts.toLocale)
        verifyNotNull(ts.time.toLocale)
        verifyNotNull(ts.date.toLocale)
        verifyNotNull(ts.month.toLocale)
        verifyNotNull(ts.weekday.toLocale)
      }
      catch (Err e)
      {
        echo("Locale has invalid date time defaults: $locale")
        e.trace
        fail
      }
    }
  }
*/
}