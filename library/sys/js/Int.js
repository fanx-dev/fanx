//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Dec 08  Andy Frank  Creation
//   20 May 09  Andy Frank  Refactor to new OO model
//

/**
 * Int
 */
fan.sys.Int = fan.sys.Obj.$extend(fan.sys.Num);

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

fan.sys.Int.prototype.$ctor = function() {}
fan.sys.Int.prototype.$typeof = function() { return fan.sys.Int.$type; }

fan.sys.Int.make = function(val) { return val; }

fan.sys.Int.MAX_SAFE = 9007199254740991;
fan.sys.Int.MIN_SAFE = -9007199254740991;

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

fan.sys.Int.fromStr = function(s, radix, checked)
{
  if (radix === undefined) radix = 10;
  if (checked === undefined) checked = true;
  try
  {
    if (radix === 10) { var n = fan.sys.Int.parseDecimal(s); return n; }
    if (radix === 16) { var n = fan.sys.Int.parseHex(s); return n; }
    throw new Error("Unsupported radix " + radix);
  }
  catch (err) {}
  if (checked) throw fan.sys.ParseErr.makeStr("Int", s);
  return null;
}

fan.sys.Int.parseDecimal = function(s)
{
  var n = 0;
  if (s.charCodeAt(0) === 45) n++;
  for (var i=n; i<s.length; i++)
  {
    ch = s.charCodeAt(i);
    if (ch >= 48 && ch <= 57) continue;
    throw new Error("Illegal decimal char " + s.charAt(i));
  }
  var x = parseInt(s, 10);
  if (isNaN(x)) throw new Error("Invalid number");
  return x;
}

fan.sys.Int.parseHex = function(s)
{
  for (var i=0; i<s.length; i++)
  {
    ch = s.charCodeAt(i);
    if (ch >= 48 && ch <= 57) continue;
    if (ch >= 65 && ch <= 70) continue;
    if (ch >= 97 && ch <= 102) continue;
    throw new Error("Illegal hex char " + s.charAt(i));
  }
  var x = parseInt(s, 16);
  if (isNaN(x)) throw new Error("Invalid number");
  return x;
}

fan.sys.Int.toStr = function(self)
{
  return self.toString();
}

fan.sys.Int.equals = function(self, obj)
{
  return self === obj;
}

fan.sys.Int.hash = function(self) { return self; }

fan.sys.Int.abs = function(self)      { return self < 0 ? -self : self; }
fan.sys.Int.min = function(self, val) { return self < val ? self : val; }
fan.sys.Int.max = function(self, val) { return self > val ? self : val; }
fan.sys.Int.clip = function(self, min, max)
{
  if (self < min) return min;
  if (self > max) return max;
  return self;
}
fan.sys.Int.isEven  = function(self) { return self % 2 == 0; }
fan.sys.Int.isOdd   = function(self) { return self % 2 != 0; }
fan.sys.Int.isSpace = function(self) { return self == 32 || self == 9 || self == 10 || self == 13; }

fan.sys.Int.isDigit = function(self, radix)
{
  if (radix == null || radix == 10) return self >= 48 && self <= 57;
  if (radix == 16)
  {
    if (self >= 48 && self <= 57) return true;
    if (self >= 65 && self <= 70) return true;
    if (self >= 97 && self <= 102) return true;
    return false;
  }
  if (radix <= 10) return 48 <= self && self <= (48+radix);
  var x = self-10;
  if (97 <= self && self <= 97+x) return true;
  if (65 <= self && self <= 65+x) return true;
  return false;
}

fan.sys.Int.toDigit = function(self, radix)
{
  if (radix == null || radix == 10) return 0 <= self && self <= 9 ? 48+self : null;
  if (self < 0 || self >= radix) return null;
  if (self < 10) return 48+self;
  return self-10+97;
}

fan.sys.Int.fromDigit = function(self, radix)
{
  if (self < 0 || self >= 128) return null;
  var ten = radix < 10 ? radix : 10;
  if (48 <= self && self < 48+ten) return self-48;
  if (radix > 10)
  {
    var alpha = radix-10;
    if (97 <= self && self < 97+alpha) return self+10-97;
    if (65 <= self && self < 65+alpha) return self+10-65;
  }
  return null;
}

fan.sys.Int.random = function(r)
{
  if (r === undefined) return Math.floor(Math.random() * Math.pow(2, 64));
  else
  {
    var start = r.start();
    var end   = r.end();
    if (r.inclusive()) ++end;
    if (end <= start) throw fan.sys.ArgErr.make("Range end < start: " + r);
    r = end-start;
    if (r < 0) r = -r;
    return Math.floor(Math.random()*r) + start;
  }
}

fan.sys.Int.isUpper    = function(self) { return self >= 65 && self <= 90; }
fan.sys.Int.isLower    = function(self) { return self >= 97 && self <= 122; }
fan.sys.Int.upper      = function(self) { return fan.sys.Int.isLower(self) ? self-32 : self; }
fan.sys.Int.lower      = function(self) { return fan.sys.Int.isUpper(self) ? self+32 : self; }
fan.sys.Int.isAlpha    = function(self) { return fan.sys.Int.isUpper(self) || fan.sys.Int.isLower(self); }
fan.sys.Int.isAlphaNum = function(self) { return fan.sys.Int.isAlpha(self) || fan.sys.Int.isDigit(self); }
fan.sys.Int.equalsIgnoreCase = function(self, ch) { return (self|0x20) == (ch|0x20); }


//////////////////////////////////////////////////////////////////////////
// Iterators
//////////////////////////////////////////////////////////////////////////

fan.sys.Int.times = function(self, f)
{
  for (var i=0; i<self; i++)
    f.call(i);
}

//////////////////////////////////////////////////////////////////////////
// Arithmetic
//////////////////////////////////////////////////////////////////////////

fan.sys.Int.negate    = function(self) { return -self; }
fan.sys.Int.increment = function(self) { return self+1; }
fan.sys.Int.decrement = function(self) { return self-1; }

fan.sys.Int.plus        = function(a, b) { return a + b; }
fan.sys.Int.plusFloat   = function(a, b) { return fan.sys.Float.make(a + b); }
fan.sys.Int.plusDecimal = function(a, b) { return fan.sys.Decimal.make(a + b); }

fan.sys.Int.minus        = function(a, b) { return a - b; }
fan.sys.Int.minusFloat   = function(a, b) { return fan.sys.Float.make(a - b); }
fan.sys.Int.minusDecimal = function(a, b) { return fan.sys.Decimal.make(a - b); }

fan.sys.Int.mult         = function(a, b) { return a * b; }
fan.sys.Int.multFloat    = function(a, b) { return fan.sys.Float.make(a * b); }
fan.sys.Int.multDecimal  = function(a, b) { return fan.sys.Decimal.make(a * b); }

fan.sys.Int.div = function(a, b)
{
  var r = a / b;
  if (r < 0) return Math.ceil(r);
  return Math.floor(r);
}
fan.sys.Int.divFloat   = function(a, b) { return fan.sys.Float.make(a / b); }
fan.sys.Int.divDecimal = function(a, b) { return fan.sys.Decimal.make(fan.sys.Int.div(a, b)); }

fan.sys.Int.mod        = function(a, b) { return a % b; }
fan.sys.Int.modFloat   = function(a, b) { return fan.sys.Float.make(a % b); }
fan.sys.Int.modDecimal = function(a, b) { return fan.sys.Decimal.make(a % b); }

fan.sys.Int.pow = function(self, pow)
{
  if (pow < 0) throw fan.sys.ArgErr.make("pow < 0");
  return Math.pow(self, pow);
}

//////////////////////////////////////////////////////////////////////////
// Bitwise operators
//////////////////////////////////////////////////////////////////////////

// NOTE: these methods only operate on the lowest 32 bits of the integer

fan.sys.Int.not = function(a)    { return ~a; }
fan.sys.Int.and = function(a, b) { var x = a & b;  if (x<0) x += 0xffffffff+1; return x; }
fan.sys.Int.or  = function(a, b) { var x = a | b;  if (x<0) x += 0xffffffff+1; return x; }
fan.sys.Int.xor = function(a, b) { var x = a ^ b;  if (x<0) x += 0xffffffff+1; return x; }
fan.sys.Int.shiftl = function(a, b) { var x = a << b; if (x<0) x += 0xffffffff+1; return x; }
fan.sys.Int.shiftr = function(a, b) { var x = a >>> b; if (x<0) x += 0xffffffff+1; return x; }
fan.sys.Int.shifta = function(a, b) { var x = a >> b; return x; }

//////////////////////////////////////////////////////////////////////////
// Conversion
//////////////////////////////////////////////////////////////////////////

fan.sys.Int.toInt = function(val) { return val; }
fan.sys.Int.toFloat = function(val) { return fan.sys.Float.make(val); }
fan.sys.Int.toDecimal = function(val) { return fan.sys.Decimal.make(val); }

fan.sys.Int.toChar = function(self)
{
  if (self < 0 || self > 0xFFFF) throw fan.sys.Err.make("Invalid unicode char: " + self);
  return String.fromCharCode(self);
}

fan.sys.Int.toHex = function(self, width)
{
  if (width === undefined) width = null;

  // make sure non-null to prevent infinite loop
  if (self == null) self = 0;

  // TODO FIXIT: how do we handle negative numbers?
  var val = self;
  if (val < 0) val += fan.sys.Int.MAX_SAFE;

  // convert to hex string
  var s = "";
  while (true)
  {
    // write chars backwards
    s = "0123456789abcdef".charAt(val % 16) + s;
    val = Math.floor(val / 16);
    if (val === 0) break
  }

  // pad width
  if (width != null && s.length < width)
  {
    var zeros = width - s.length;
    for (var i=0; i<zeros; ++i) s = '0' + s;
  }

  return s;
}

fan.sys.Int.toRadix = function(self, radix, width)
{
  if (width === undefined) width = null;

  // convert to hex string
  var s = self.toString(radix);

  // pad width
  if (width != null && s.length < width)
  {
    var zeros = width - s.length;
    for (var i=0; i<zeros; ++i) s = '0' + s;
  }

  return s;
}

fan.sys.Int.toCode = function(self, base)
{
  if (base === undefined) base = 10;
  if (base == 10) return self.toString();
  if (base == 16) return "0x" + fan.sys.Int.toHex(self);
  throw fan.sys.ArgErr.make("Invalid base " + base);
}

fan.sys.Int.toDuration = function(self)
{
  return fan.sys.Duration.make(self);
}

fan.sys.Int.toDateTime = function(self, tz)
{
  return (tz === undefined)
    ? fan.sys.DateTime.makeTicks(self)
    : fan.sys.DateTime.makeTicks(self, tz);
}

//////////////////////////////////////////////////////////////////////////
// CharMap
//////////////////////////////////////////////////////////////////////////

fan.sys.Int.charMap = [];
fan.sys.Int.SPACE    = 0x01;
fan.sys.Int.UPPER    = 0x02;
fan.sys.Int.LOWER    = 0x04;
fan.sys.Int.DIGIT    = 0x08;
fan.sys.Int.HEX      = 0x10;
fan.sys.Int.ALPHA    = fan.sys.Int.UPPER | fan.sys.Int.LOWER;
fan.sys.Int.ALPHANUM = fan.sys.Int.UPPER | fan.sys.Int.LOWER | fan.sys.Int.DIGIT;

fan.sys.Int.charMap[32] |= fan.sys.Int.SPACE;
fan.sys.Int.charMap[10] |= fan.sys.Int.SPACE;
fan.sys.Int.charMap[13] |= fan.sys.Int.SPACE;
fan.sys.Int.charMap[9]  |= fan.sys.Int.SPACE;
fan.sys.Int.charMap[12] |= fan.sys.Int.SPACE;

// alpha characters
for (var i=97; i<=122; ++i) fan.sys.Int.charMap[i] |= fan.sys.Int.LOWER;
for (var i=65; i<=90;  ++i) fan.sys.Int.charMap[i] |= fan.sys.Int.UPPER;

// digit characters
for (var i=48; i<=57; ++i) fan.sys.Int.charMap[i] |= fan.sys.Int.DIGIT;

// hex characters
for (var i=48; i<=57;  ++i) fan.sys.Int.charMap[i] |= fan.sys.Int.HEX;
for (var i=97; i<=102; ++i) fan.sys.Int.charMap[i] |= fan.sys.Int.HEX;
for (var i=65; i<=70;  ++i) fan.sys.Int.charMap[i] |= fan.sys.Int.HEX;

//////////////////////////////////////////////////////////////////////////
// Locale
//////////////////////////////////////////////////////////////////////////

fan.sys.Int.toLocale = function(self, pattern)
{
  //if (locale === undefined || locale == null) locale = fan.sys.Locale.cur();
  if (pattern === undefined) pattern = null;
  return fan.sys.NumFormat.formatInt(self, pattern);
/*
  // if pattern is "B" format as bytes
  if (pattern != null && pattern.length == 1 && pattern.charAt(0) == 'B')
    return fan.sys.Int.toLocaleBytes(self);

  // get default pattern if necessary
  if (pattern == null)
// TODO FIXIT
//    pattern = Env.cur().locale(Sys.sysPod, "int", "#,###");
    pattern = "#,###";

  // parse pattern and get digits
  var p = fan.sys.NumPattern.parse(pattern);
  var d = fan.sys.NumDigits.makeLong(self);

  // route to common FanNum method
  return fan.sys.Num.toLocale(p, d, locale);
*/
}

fan.sys.Int.toLocaleBytes = function(b)
{
  var KB = fan.sys.Int.m_KB;
  var MB = fan.sys.Int.m_MB;
  var GB = fan.sys.Int.m_GB;
  if (b < KB)    return b + "B";
  if (b < 10*KB) return fan.sys.Float.toLocale(b/KB, "#.#") + "KB";
  if (b < MB)    return Math.round(b/KB) + "KB";
  if (b < 10*MB) return fan.sys.Float.toLocale(b/MB, "#.#") + "MB";
  if (b < GB)    return Math.round(b/MB) + "MB";
  if (b < 10*GB) return fan.sys.Float.toLocale(b/GB, "#.#") + "GB";
  return Math.round(b/fan.sys.Int.m_GB) + "GB";
}
fan.sys.Int.m_KB = 1024;
fan.sys.Int.m_MB = 1024*1024;
fan.sys.Int.m_GB = 1024*1024*1024;

// TODO FIXIT
fan.sys.Int.localeIsUpper = function(self) { return fan.sys.Int.isUpper(self); }
fan.sys.Int.localeIsLower = function(self) { return fan.sys.Int.isLower(self); }
fan.sys.Int.localeUpper   = function(self) { return fan.sys.Int.upper(self); }
fan.sys.Int.localeLower   = function(self) { return fan.sys.Int.lower(self); }
