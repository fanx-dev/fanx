//
// Copyright (c) 2011, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Jan 11  Andy Frank  Creation
//

/**
 * DateTimeStr is used to format/parse DateTime, Date, and Time
 * using the standard pattern syntax.
 */
fan.sys.DateTimeStr = fan.sys.Obj.$extend(fan.sys.Obj);
fan.sys.DateTimeStr.prototype.$ctor = function()
{
  this.pattern = "";
  this.year = 0;
  this.mon  = null;
  this.day  = 0;
  this.hour = 0;
  this.min  = 0;
  this.sec  = 0;
  this.ns   = 0;
  this.weekday  = null;
  this.tz       = null;
  this.tzName   = null;
  this.tzOffset = 0;
  this.dst  = 0;
  this.loc  = null;
  this.str  = "";  // when parsing
  this.pos  = 0;   // index in str for parse
}

fan.sys.DateTimeStr.makeDateTime = function(pattern, locale, dt)
{
  var x = new fan.sys.DateTimeStr();
  x.valDateTime = dt;
  x.pattern = pattern;
  x.loc     = locale;
  x.year    = dt.year();
  x.mon     = dt.month();
  x.day     = dt.day();
  x.hour    = dt.hour();
  x.min     = dt.min();
  x.sec     = dt.sec();
  x.ns      = dt.nanoSec();
  x.weekday = dt.weekday();
  x.tz      = dt.tz();
  x.dst     = dt.dst();
  return x;
}

fan.sys.DateTimeStr.makeDate = function(pattern, locale, d)
{
  var x = new fan.sys.DateTimeStr();
  x.valDate = d;
  x.pattern = pattern;
  x.loc     = locale;
  x.year    = d.year();
  x.mon     = d.month();
  x.day     = d.day();
  try { x.weekday = d.weekday(); } catch (e) {}
  return x;
}

fan.sys.DateTimeStr.makeTime = function(pattern, locale, t)
{
  var x = new fan.sys.DateTimeStr();
  x.pattern = pattern;
  x.loc     = locale;
  x.hour    = t.hour();
  x.min     = t.min();
  x.sec     = t.sec();
  x.ns      = t.nanoSec();
  return x;
}

fan.sys.DateTimeStr.make = function(pattern, locale)
{
  var x = new fan.sys.DateTimeStr();
  x.pattern = pattern;
  x.loc     = locale;
  return x;
}

//////////////////////////////////////////////////////////////////////////
// Formatting
//////////////////////////////////////////////////////////////////////////

fan.sys.DateTimeStr.prototype.format = function()
{
  var s = "";
  var len = this.pattern.length;
  for (var i=0; i<len; ++i)
  {
    // character
    var c = this.pattern.charAt(i);

    // literals
    if (c == '\'')
    {
      var numLiterals = 0;
      while (true)
      {
        ++i;
        if (i >= len) throw fan.sys.ArgErr.make("Invalid pattern: unterminated literal");
        c = this.pattern.charAt(i);
        if (c == '\'') break;
        s += c;
        numLiterals++;
      }
      if (numLiterals == 0) s += "'";
      continue;
    }

    // character count
    var n = 1;
    while (i+1<len && this.pattern.charAt(i+1) == c) { ++i; ++n; }

    // switch
    var invalidNum = false;
    switch (c)
    {
      case 'Y':
        var y = this.year;
        switch (n)
        {
          case 2:  y %= 100; if (y < 10) s += '0';
          case 4:  s += y; break;
          default: invalidNum = true;
        }
        break;

      case 'M':
        switch (n)
        {
          case 4:
            s += this.mon.full(this.locale());
            break;
          case 3:
            s += this.mon.abbr(this.locale());
            break;
          case 2:  if (this.mon.ordinal()+1 < 10) s += '0';
          case 1:  s += this.mon.ordinal()+1; break;
          default: invalidNum = true;
        }
        break;

      case 'D':
        switch (n)
        {
          case 3:  s += this.day + fan.sys.DateTimeStr.daySuffix(this.day); break;
          case 2:  if (this.day < 10) s += '0';
          case 1:  s += this.day; break;
          default: invalidNum = true;
        }
        break;

      case 'W':
        switch (n)
        {
          case 4:
            s += this.weekday.full(this.locale());
            break;
          case 3:
            s += this.weekday.abbr(this.locale());
            break;
          default: invalidNum = true;
        }
        break;

      case 'V':
        var woy = this.weekOfYear();
        if (woy < 1) throw fan.sys.ArgErr.make("Week of year not available");
        switch (n)
        {
          case 3:  s += woy + fan.sys.DateTimeStr.daySuffix(woy); break;
          case 2:  if (woy < 10) s += '0';
          case 1:  s += woy; break;
          default: invalidNum = true;
        }
        break;

      case 'h':
      case 'k':
        var h = this.hour;
        if (c == 'k')
        {
          if (h == 0) h = 12;
          else if (h > 12) h -= 12;
        }
        switch (n)
        {
          case 2:  if (h < 10) s += '0';
          case 1:  s += h; break;
          default: invalidNum = true;
        }
        break;

      case 'm':
        switch (n)
        {
          case 2:  if (this.min < 10) s += '0';
          case 1:  s += this.min; break;
          default: invalidNum = true;
        }
        break;

      case 's':
        switch (n)
        {
          case 2:  if (this.sec < 10) s += '0';
          case 1:  s += this.sec; break;
          default: invalidNum = true;
        }
        break;

      case 'S':
        if (this.sec != 0 || this.ns != 0)
        {
          switch (n)
          {
            case 2:  if (this.sec < 10) s += '0';
            case 1:  s += this.sec; break;
            default: invalidNum = true;
          }
        }
        break;

      case 'a':
        switch (n)
        {
          case 1:  s += (this.hour < 12 ? "a"  : "p"); break;
          case 2:  s += (this.hour < 12 ? "am" : "pm"); break;
          default: invalidNum = true;
        }
        break;

      case 'A':
        switch (n)
        {
          case 1:  s += (this.hour < 12 ? "A"  : "P"); break;
          case 2:  s += (this.hour < 12 ? "AM" : "PM"); break;
          default: invalidNum = true;
        }
        break;

      case 'f':
      case 'F':
        var req = 0, opt = 0; // required, optional
        if (c == 'F') opt = n;
        else
        {
          req = n;
          while (i+1<len && this.pattern.charAt(i+1) == 'F') { ++i; ++opt; }
        }
        var frac = this.ns;
        for (var x=0, tenth=100000000; x<9; ++x)
        {
          if (req > 0) req--;
          else
          {
            if (frac == 0 || opt <= 0) break;
            opt--;
          }
          s += Math.floor(frac / tenth);
          frac %= tenth;
          tenth  = Math.floor(tenth / 10);
        }
        break;

      case 'z':
        var rule = this.tz.rule(this.year);
        switch (n)
        {
          case 1:
            var offset = rule.offset;
            if (this.dst) offset += rule.dstOffset;
            if (offset == 0) { s += 'Z'; break; }
            if (offset < 0) { s += '-'; offset = -offset; }
            else { s += '+'; }
            var zh = Math.floor(offset / 3600);
            var zm = Math.floor((offset % 3600) / 60);
            if (zh < 10) s += '0'; s += zh + ':';
            if (zm < 10) s += '0'; s += zm;
            break;
          case 3:
            s += this.dst ? rule.dstAbbr : rule.stdAbbr;
            break;
          case 4:
            s += this.tz.$name();
            break;
          default:
            invalidNum = true;
            break;
        }
        break;

      default:
        if (fan.sys.Int.isAlpha(c.charCodeAt(0)))
          throw fan.sys.ArgErr.make("Invalid pattern: unsupported char '" + c + "'");

        // check for symbol skip
        if (i+1 < len)
        {
          var next = this.pattern.charAt(i+1);

          // don't display symbol between ss.FFF if fractions is zero
          if (next  == 'F' && this.ns == 0) break;

          // don't display symbol between mm:SS if secs is zero
          if (next == 'S' && this.sec == 0 && this.ns == 0) break;
        }

        s += c;
    }

    // if invalid number of characters
    if (invalidNum)
      throw fan.sys.ArgErr.make("Invalid pattern: unsupported num of '" + c + "' (x" + n + ")");
  }

  return s;
}

fan.sys.DateTimeStr.daySuffix = function(day)
{
  // eventually need localization
  if (day == 11 || day == 12 || day == 13) return "th";
  switch (day % 10)
  {
    case 1:  return "st";
    case 2:  return "nd";
    case 3:  return "rd";
    default: return "th";
  }
}

//////////////////////////////////////////////////////////////////////////
// Parse
//////////////////////////////////////////////////////////////////////////

fan.sys.DateTimeStr.prototype.parseDateTime = function(s, defTz, checked)
{
  try
  {
    // parse into fields
    this.tzOffset = null;
    this.parse(s);

    // now figure out what timezone to use
    var defRule = defTz.rule(this.year);
    if (this.tzName != null)
    {
      // use defTz if tzName was specified and matches any variations of defTz
      if (this.tzName == defTz.$name() ||
          this.tzName == defRule.stdAbbr ||
          this.tzName == defRule.dstAbbr)
      {
        this.tz = defTz;
      }

      // try to map tzName to TimeZone, use defTz as fallback
      else
      {
        this.tz = fan.sys.TimeZone.fromStr(this.tzName, false);
        if (this.tz == null) this.tz = defTz;
      }
    }

    // if tzOffset was specified...
    else if (this.tzOffset != null)
    {
      // figure out what expected offset was for defTz
      var time = this.hour*3600 + this.min*60 + this.sec;
      var defOffset = defRule.offset + fan.sys.TimeZone.dstOffset(defRule, this.year, this.mon.ordinal(), this.day, time);

      // if specified offset matches expected offset for defTz then
      // use defTz, otherwise use a vanilla GMT+/- timezone
      if (this.tzOffset == defOffset)
        this.tz = defTz;
      else
        this.tz = fan.sys.TimeZone.fromGmtOffset(this.tzOffset);
    }

    // no tzName or tzOffset specified, use defTz
    else this.tz = defTz;

    // construct DateTime
    return fan.sys.DateTime.doMake(this.year, this.mon, this.day, this.hour, this.min, this.sec, this.ns, this.tzOffset, this.tz);
  }
  catch (err)
  {
    if (checked) throw fan.sys.ParseErr.makeStr("DateTime", s, fan.sys.Err.make(err));
    return null;
  }
}

fan.sys.DateTimeStr.prototype.parseDate = function(s, checked)
{
  try
  {
    this.parse(s);
    return fan.sys.Date.make(this.year, this.mon, this.day);
  }
  catch (err)
  {
    if (checked) throw fan.sys.ParseErr.makeStr("Date", s, fan.sys.Err.make(err));
    return null;
  }
}

fan.sys.DateTimeStr.prototype.parseTime = function(s, checked)
{
  try
  {
    this.parse(s);
    return fan.sys.Time.make(this.hour, this.min, this.sec, this.ns);
  }
  catch (err)
  {
    if (checked) throw fan.sys.ParseErr.makeStr("Time", s, fan.sys.Err.make(err));
    return null;
  }
}

fan.sys.DateTimeStr.prototype.parse = function(s)
{
  this.str = s;
  this.pos = 0;
  var len = this.pattern.length;
  var skippedLast = false;
  for (var i=0; i<len; ++i)
  {
    // character
    var c = this.pattern.charAt(i);

    // character count
    var n = 1;
    while (i+1<len && this.pattern.charAt(i+1) == c) { ++i; ++n; }

    // switch
    switch (c)
    {
      case 'Y':
        this.year = this.parseInt(n);
        if (this.year < 30) this.year += 2000;
        else if (this.year < 100) this.year += 1900;
        break;

      case 'M':
        switch (n)
        {
          case 4:  this.mon = this.parseMon(); break;
          case 3:  this.mon = this.parseMon(); break;
          default: this.mon = fan.sys.Month.m_vals.get(this.parseInt(n)-1); break;
        }
        break;

      case 'D':
        if (n != 3) this.day = this.parseInt(n);
        else
        {
          // suffix like st, nd, th
          this.day = this.parseInt(1);
          this.skipWord();
        }
        break;

      case 'h':
      case 'k':
        this.hour = this.parseInt(n);
        break;

      case 'm':
        this.min = this.parseInt(n);
        break;

      case 's':
        this.sec = this.parseInt(n);
        break;

      case 'S':
        if (!skippedLast) this.sec = this.parseInt(n);
        break;

      case 'a':
      case 'A':
        var amPm = this.str.charAt(this.pos); this.pos += n;
        if (amPm == 'P' || amPm == 'p')
        {
          if (this.hour < 12) this.hour += 12;
        }
        else
        {
          if (this.hour == 12) this.hour = 0;
        }
        break;

      case 'W':
        this.skipWord();
        break;

      case 'F':
        if (skippedLast) break;
        // fall-thru

      case 'f':
        this.ns = 0;
        var tenth = 100000000;
        while (true)
        {
          var digit = this.parseOptDigit();
          if (digit < 0) break;
          this.ns += tenth * digit;
          tenth = Math.floor(tenth / 10);
        }
        break;

      case 'z':
        switch (n)
        {
          case 1:  this.parseTzOffset(); break;
          default: this.parseTzName();
        }
        break;

      case '\'':
        if (n == 2)
        {
          var actual = this.str.charAt(this.pos++);
          if (actual != '\'')
            throw fan.sys.Err.make("Expected single quote, not '" + actual + "' [pos " + this.pos +"]");
        }
        else
        {
          while (true)
          {
            var expected = this.pattern.charAt(++i);
            if (expected == '\'') break;
            var actual = this.str.charAt(this.pos++);
            if (actual != expected)
              throw fan.sys.Err.make("Expected '" + expected + "', not '" + actual + "' [pos " + this.pos +"]");
          }
        }
        break;

      default:
        var match = this.pos+1 < this.str.length ? this.str.charAt(this.pos++) : 0;

        // handle skipped symbols
        if (i+1 < this.pattern.length)
        {
          var next = this.pattern.charAt(i+1);
          if (next == 'F' || next == 'S')
          {
            if (match != c) { skippedLast = true; --this.pos; break; }
          }
        }

        skippedLast = false;
        if (match != c)
          throw fan.sys.Err.make("Expected '" + c + "' literal char, not '" + match + "' [pos " + this.pos +"]");
    }
  }
}

fan.sys.DateTimeStr.prototype.parseInt = function(n)
{
  // parse n digits
  var num = 0;
  for (var i=0; i<n; ++i) num = num*10 + this.parseReqDigit();

  // one char like 'k' really implies one or two digits
  if (n == 1)
  {
    var digit = this.parseOptDigit();
    if (digit >= 0) num = num*10 + digit;
  }

  return num;
}

fan.sys.DateTimeStr.prototype.parseReqDigit = function()
{
  var ch = this.str.charCodeAt(this.pos++);
  if (48 <= ch && ch <= 57) return ch - 48;
  throw fan.sys.Err.make("Expected digit, not '" + String.fromCharCode(ch) + "' [pos " + (this.pos-1) + "]");
}

fan.sys.DateTimeStr.prototype.parseOptDigit = function()
{
  if (this.pos < this.str.length)
  {
    var ch = this.str.charCodeAt(this.pos);
    if (48 <= ch && ch <= 57) { this.pos++; return ch-48; }
  }
  return -1;
}

fan.sys.DateTimeStr.prototype.parseMon = function()
{
  var s = "";
  while (this.pos < this.str.length)
  {
    var ch = this.str.charCodeAt(this.pos);
    if (97 <= ch && ch <= 122) { s += String.fromCharCode(ch); this.pos++; continue; }
    if (65 <= ch && ch <= 90)  { s += String.fromCharCode(fan.sys.Int.lower(ch)); this.pos++; continue; }
    break;
  }
  var m = this.locale().monthByName(s);
  if (m == null) throw fan.sys.Err.make("Invalid month: " + s);
  return m;
}

fan.sys.DateTimeStr.prototype.parseTzOffset = function()
{
  var ch = this.str.charAt(this.pos++);
  var neg = false;
  switch (ch)
  {
    case '-': neg = true; break;
    case '+': neg = false; break;
    case 'Z': this.tzOffset = 0; return;
    default: throw fan.sys.Err.make("Unexpected tz offset char: " + ch + " [pos " + (this.pos-1) + "]");
  }

  var hr = this.parseInt(1);
  var min = 0;
  if (this.pos < this.str.length)
  {
    ch = this.str.charCodeAt(this.pos);
    if (ch == 58)
    {
      this.pos++;
      min = this.parseInt(1);
    }
    else if (48 <= ch && ch <= 57)
    {
      min = this.parseInt(1);
    }
  }
  this.tzOffset = hr*3600 + min*60;
  if (neg) this.tzOffset = -this.tzOffset;
}

fan.sys.DateTimeStr.prototype.parseTzName = function()
{
  var s = "";
  while (this.pos < this.str.length)
  {
    var ch = this.str.charCodeAt(this.pos);
    if ((97 <= ch && ch <= 122) ||
        (65 <= ch && ch <= 90) ||
        (48 <= ch && ch <= 57) ||
        ch == 43 || ch == 45 || ch == 95)
    {
      s += String.fromCharCode(ch);
      this.pos++;
    }
    else break;
  }
  this.tzName = s;
}

fan.sys.DateTimeStr.prototype.skipWord = function()
{
  while (this.pos < this.str.length)
  {
    var ch = this.str.charCodeAt(this.pos);
    if ((97 <= ch && ch <= 122) || (65 <= ch && ch <= 90))
      this.pos++;
    else
      break;
  }
}

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

fan.sys.DateTimeStr.prototype.locale = function()
{
  if (this.loc == null) this.loc = fan.sys.Locale.cur();
  return this.loc;
}

fan.sys.DateTimeStr.prototype.weekOfYear = function()
{
  var sow = fan.sys.Weekday.localeStartOfWeek(this.locale());
  if (this.valDateTime !== undefined) return this.valDateTime.weekOfYear(sow);
  if (this.valDate !== undefined)     return this.valDate.weekOfYear(sow);
  return 0;
}

