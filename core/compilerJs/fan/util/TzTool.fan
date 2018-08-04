//
// Copyright (c) 2016, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Feb 16  Matthew Giannini  Creation
//

**
** Tool for managing JS time zones.
**
class TzTool
{
  new make() { }

  Void run()
  {
    parseArgs
    if (gen) generateTimeZones
  }

//////////////////////////////////////////////////////////////////////////
// Gen
//////////////////////////////////////////////////////////////////////////

  private Void generateTimeZones()
  {
    loadAliases
    orderByContinent
    writeTzJs
  }

  private Void loadAliases()
  {
    // load aliases
    if (!aliasProps.exists) log.warn("$aliasProps does not exist")
    else this.aliases = aliasProps.readProps
  }

  private Void orderByContinent()
  {
    TimeZone.listFullNames.each |fullName|
    {
      byContinent.getOrAdd(continent(fullName)) { [,] }.add(TimeZone.fromStr(fullName))
    }
    // sort time zones by city name
    byContinent.vals.each { it.sort |a,b| { a.name <=> b.name } }
  }

  ** Get the continent name from the full name, or ""
  ** if the full name doesn't have a continent.
  private Str continent(Str fullName)
  {
    fullName.contains("/") ? fullName.split('/').first : ""
  }

  private Void writeTzJs()
  {
    jsOut := js.out
    try
    {
      jsOut.printLine(
        "(function() {
          ${JsPod.requireSys}
          var c=fan.sys.TimeZone.cache\$;
          var a;")

      // write built-in timezones
      byContinent.each |TimeZone[] timezones, Str continent|
      {
        jsOut.printLine("a=${continent.toCode};")
        timezones.each |TimeZone tz|
        {
          log.debug("$tz.fullName")
          encoded := encodeTimeZone(tz)
          jsOut.printLine("c(a,${tz.fullName.toCode},${encoded.toBase64.toCode});")
        }
      }

      // write aliases
      jsOut.printLine("c=fan.sys.TimeZone.alias\$;")
      aliases.each |target, alias|
      {
        log.debug("Alias $alias = $target")
        jsOut.printLine("c(${alias.toCode},${target.toCode});")
      }

      // assign static utc and rel fields
      jsOut.printLine("fan.sys.TimeZone.m_utc = fan.sys.TimeZone.fromStr('UTC');")
      jsOut.printLine("fan.sys.TimeZone.m_rel = fan.sys.TimeZone.fromStr('Rel');")


      jsOut.printLine("}).call(this);")
    }
    finally jsOut.close
    log.info("Wrote: ${js.osPath ?: js}")
  }

  private Buf encodeTimeZone(TimeZone tz)
  {
    buf   := Buf().writeUtf(tz.fullName);
    rules := ([Str:Obj][])tz->rules
    rules.each |r| { encodeRule(r, buf.out) }
    return buf
  }

  private Void encodeRule(Str:Obj r, OutStream out)
  {
    dstOffset := r["dstOffset"]
    out.writeI2(r["startYear"])
       .writeI4(r["offset"])
       .writeUtf(r["stdAbbr"])
       .writeI4(dstOffset)
    if (dstOffset != 0)
    {
      out.writeUtf(r["dstAbbr"])
      encodeDst(r["dstStart"], out)
      encodeDst(r["dstEnd"], out)
    }
  }

  private Void encodeDst(Str:Obj dst, OutStream out)
  {
    out.write(dst["mon"])
       .write(dst["onMode"])
       .write(dst["onWeekday"])
       .write(dst["onDay"])
       .writeI4(dst["atTime"])
       .write(dst["atMode"])
  }

//////////////////////////////////////////////////////////////////////////
// Args
//////////////////////////////////////////////////////////////////////////

  private Bool gen := false

  private Void parseArgs()
  {
    args := Env.cur.args.dup.reverse
    if (args.isEmpty) usage()
    while (!args.isEmpty)
    {
      arg := args.pop
      switch (arg)
      {
        case "-gen":
          this.gen = true
        case "-verbose":
        case "-v":
          log.level = LogLevel.debug
        case "-help":
        case "-?":
          usage()
        default:
          Env.cur.err.printLine("Bad option: ${arg}")
          usage()
      }
    }
  }

  private Void usage()
  {
    out  := Env.cur.out
    main := Env.cur.mainMethod?.parent?.name ?: "TzTool"
    out.printLine(
      "Usage:
         $main [options]
       Options:
         -gen          Generate tz.js
         -verbose, -v  Enable verbose logging
         -help, -?     Print usage help
       ")
    Env.cur.exit(1)
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private Log log := Log.get("TzTool")

  // gen
  private File js := Env.cur.homeDir + `etc/sys/tz.js`
  private File aliasProps := Env.cur.homeDir + `etc/sys/timezone-aliases.props`
  private Str:Str aliases := [:]
  private Str:TimeZone[] byContinent := [:]

//////////////////////////////////////////////////////////////////////////
// Main
//////////////////////////////////////////////////////////////////////////

  static Void main()
  {
    TzTool().run
  }

}
