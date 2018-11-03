//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 08  Andy Frank  Creation
//   20 May 09  Andy Frank  Refactor to new OO model
//

/**
 * Num
 */
fan.sys.Num = fan.sys.Obj.$extend(fan.sys.Obj);

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

fan.sys.Num.prototype.$ctor = function() {}
fan.sys.Num.prototype.$typeof = function() { return fan.sys.Num.$type; }

//////////////////////////////////////////////////////////////////////////
// Static Methods
//////////////////////////////////////////////////////////////////////////

fan.sys.Num.toDecimal = function(val) { return fan.sys.Decimal.make(val.valueOf()); }
fan.sys.Num.toFloat = function(val) { return fan.sys.Float.make(val.valueOf()); }
fan.sys.Num.toInt = function(val)
{
  if (isNaN(val)) return 0;
  if (val == Number.POSITIVE_INFINITY) return fan.sys.Int.m_maxVal;
  if (val == Number.NEGATIVE_INFINITY) return fan.sys.Int.m_minVal;
  if (val < 0) return Math.ceil(val);
  return Math.floor(val);
}

//////////////////////////////////////////////////////////////////////////
// Locale
//////////////////////////////////////////////////////////////////////////

fan.sys.Num.localeDecimal = function()
{
  return fan.sys.Locale.cur().numSymbols().decimal;
}

fan.sys.Num.localeGrouping = function()
{
  return fan.sys.Locale.cur().numSymbols().grouping;
}

fan.sys.Num.localeMinus = function()
{
  return fan.sys.Locale.cur().numSymbols().minus;
}

fan.sys.Num.localePercent = function()
{
  return fan.sys.Locale.cur().numSymbols().percent;
}

fan.sys.Num.localePosInf = function()
{
  return fan.sys.Locale.cur().numSymbols().posInf;
}

fan.sys.Num.localeNegInf = function()
{
  return fan.sys.Locale.cur().numSymbols().negInf;
}

fan.sys.Num.localeNaN = function()
{
  return fan.sys.Locale.cur().numSymbols().nan;
}

fan.sys.Num.toLocale = function(p, d, locale)
{
  var symbols = locale.numSymbols();

  // string buffer
  var s = "";
  if (d.m_negative) s += symbols.minus;

  // if we have more frac digits then maxFrac, then round off
  d.round(p.m_maxFrac);

  // if we have an optional integer part, and only
  // fractional digits, then don't include leading zero
  var start = 0;
  if (p.m_optInt && d.zeroInt()) start = d.m_decimal;

  // if min required fraction digits are zero and we
  // have nothing but zeros, then truncate to a whole number
  if (p.m_minFrac == 0 && d.zeroFrac(p.m_maxFrac)) d.m_size = d.m_decimal;

  // leading zeros
  for (var i=0; i<p.m_minInt-d.m_decimal; ++i) s += '0';

  // walk thru the digits and apply locale symbols
  var decimal = false;
  for (var i=start; i<d.m_size; ++i)
  {
    if (i < d.m_decimal)
    {
      if ((d.m_decimal - i) % p.m_group == 0 && i > 0)
        s += symbols.grouping;
    }
    else
    {
      if (i == d.m_decimal && p.m_maxFrac > 0)
      {
        s += symbols.decimal;
        decimal = true;
      }
      if (i-d.m_decimal >= p.m_maxFrac) break;
    }
    s += String.fromCharCode(d.m_digits[i]);
  }

  // trailing zeros
  for (var i=0; i<p.m_minFrac-d.fracSize(); ++i)
  {
    if (!decimal) { s += symbols.decimal; decimal = true; }
    s += '0';
  }

  // handle #.# case
  if (s.length == 0) return "0";
  return s;
}

//////////////////////////////////////////////////////////////////////////
// NumDigits
//////////////////////////////////////////////////////////////////////////

/**
 * NumDigits is used to represents the character digits in
 * a number for locale pattern processing.  It inputs a long,
 * double, or BigDecimal into an array of digit chars and the
 * index to the decimal point.
 */
fan.sys.NumDigits = fan.sys.Obj.$extend(fan.sys.Obj);
fan.sys.NumDigits.prototype.$ctor = function()
{
  this.m_digits;            // char digits
  this.m_decimal;           // index where decimal fits into digits
  this.m_size = 0;          // size of digits used
  this.m_negative = false;  // is this a negative number
}

//fan.sys.NumDigits.makeDecimal = function(d)
//{
//  return fan.sys.NumDigits.makeStr(d.toString());
//}

fan.sys.NumDigits.makeStr = function(s)
{
  var obj = new fan.sys.NumDigits();
  obj.m_digits = [];

  var expPos = -1;
  obj.m_decimal = -99;
  for (var i=0; i<s.length; ++i)
  {
    var c = s.charCodeAt(i);
    if (c == 45) { obj.m_negative = true; continue; }
    if (c == 46) { obj.m_decimal = obj.m_negative ? i-1 : i; continue; }
    if (c == 101 || c == 69) { expPos = i; break; }
    obj.m_digits.push(c); obj.m_size++;
  }
  if (obj.m_decimal < 0) obj.m_decimal = obj.m_size;

  // if we had an exponent, then we need to normalize it
  if (expPos >= 0)
  {
    // move the decimal by the exponent
    var exp = parseInt(s.substring(expPos+1), 10);
    obj.m_decimal += exp;

    // add leading/trailing zeros as necessary
    if (obj.m_decimal >= obj.m_size)
    {
      while(obj.m_size <= obj.m_decimal) obj.m_digits[obj.m_size++] = 48;
    }
    else if (obj.m_decimal < 0)
    {
      for (var i=0; i<-obj.m_decimal; ++i) obj.m_digits.unshift(48);
      obj.m_size += -obj.m_decimal;
      obj.m_decimal = 0;
    }
  }
  return obj;
}

fan.sys.NumDigits.makeLong = function(l)
{
  var obj = new fan.sys.NumDigits();
  if (l < 0) { obj.m_negative = true; l = -l; }
  var s = l.toString();
  // TODO FIXIT: js prec issues
  if (s.charAt(0) === '-') s = "9223372036854775808"; // handle overflow case
  obj.m_digits = [];
  for (var i=0; i<s.length; i++) obj.m_digits.push(s.charCodeAt(i));
  obj.m_size = obj.m_decimal = obj.m_digits.length;
  return obj;
}

fan.sys.NumDigits.prototype.intSize = function()  { return this.m_decimal; }

fan.sys.NumDigits.prototype.fracSize = function() { return this.m_size - this.m_decimal; }

fan.sys.NumDigits.prototype.zeroInt = function()
{
  for (var i=0; i<this.m_decimal; ++i) if (this.m_digits[i] != 48) return false;
  return true;
}

fan.sys.NumDigits.prototype.zeroFrac = function(maxFrac)
{
  var until = this.m_decimal + maxFrac;
  for (var i=this.m_decimal; i<until; ++i) if (this.m_digits[i] != 48) return false;
  return true;
}

fan.sys.NumDigits.prototype.round = function(maxFrac)
{
  // if frac sie already eq or less than maxFrac no rounding needed
  if (this.fracSize() <= maxFrac) return;

  // if we need to round, then round the prev digit
  if (this.m_digits[this.m_decimal+maxFrac] >= 53)
  {
    var i = this.m_decimal + maxFrac - 1;
    while (true)
    {
      if (this.m_digits[i] < 57) { this.m_digits[i]++; break; }
      this.m_digits[i--] = 48;
      if (i < 0)
      {
        this.m_digits.unshift(49);
        this.m_size++; this.m_decimal++;
        break;
      }
    }
  }

  // update size and clip any trailing zeros
  this.m_size = this.m_decimal + maxFrac;
  while (this.m_digits[this.m_size-1] == 48 && this.m_size > this.m_decimal) this.m_size--;
}

fan.sys.NumDigits.prototype.toString = function()
{
  var s = "";
  for (var i=0; i<this.m_digits.length; i++) s += String.fromCharCode(this.m_digits[i]);
  return s + " neg=" + this.m_negative + " decimal=" + this.m_decimal;
}

//////////////////////////////////////////////////////////////////////////
// NumPattern
//////////////////////////////////////////////////////////////////////////

/**
 * NumPattern parses and models a numeric locale pattern.
 */
fan.sys.NumPattern = fan.sys.Obj.$extend(fan.sys.Obj);
fan.sys.NumPattern.prototype.$ctor = function()
{
  this.m_pattern;   // pattern parsed
  this.m_group;     // grouping size (typically 3 for 1000)
  this.m_optInt;    // if we have "#." then the int part if optional (no leading zero)
  this.m_minInt;    // min digits in integer part (leading zeros)
  this.m_minFrac;   // min digits in fractional part (trailing zeros)
  this.m_maxFrac;   // max digits in fractional part (clipping)
}

fan.sys.NumPattern.parse = function(s)
{
  var x = fan.sys.NumPattern.m_cache[s];
  if (x != null) return x;
  return fan.sys.NumPattern.make(s);
}

fan.sys.NumPattern.make = function(s)
{
  var group = fan.sys.Int.m_maxVal;
  var optInt = true;
  var comma = false;
  var decimal = false;
  var minInt = 0, minFrac = 0, maxFrac = 0;
  var last = 0;
  for (var i=0; i<s.length; ++i)
  {
    var c = s.charAt(i);
    switch (c)
    {
      case ',':
        comma = true;
        group = 0;
        break;
      case '0':
        if (decimal)
          { minFrac++; maxFrac++; }
        else
          { minInt++; if (comma) group++; }
        break;
      case '#':
        if (decimal)
          maxFrac++;
        else
          if (comma) group++;
        break;
      case '.':
        decimal = true;
        optInt  = last == '#';
        break;
    }
    last = c;
  }
  if (!decimal) optInt = last == '#';

  var obj = new fan.sys.NumPattern();
  obj.m_pattern = s;
  obj.m_group   = group;
  obj.m_optInt  = optInt;
  obj.m_minInt  = minInt;
  obj.m_minFrac = minFrac;
  obj.m_maxFrac = maxFrac;
  return obj;
}

fan.sys.NumPattern.prototype.toString = function()
{
  return this.m_pattern + " group=" + this.m_group + " minInt=" + this.m_minInt +
    " maxFrac=" + this.m_maxFrac + " minFrac=" + this.m_minFrac + " optInt=" + this.m_optInt;
}

// pre-compute common patterns to avoid parsing
fan.sys.NumPattern.m_cache = {};
fan.sys.NumPattern.cache = function(p)
{
  fan.sys.NumPattern.m_cache[p] = fan.sys.NumPattern.make(p);
}

