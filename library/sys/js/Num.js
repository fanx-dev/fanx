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

fan.sys.Num.toDecimal = function(val) { return fan.std.Decimal.make(val.valueOf()); }
fan.sys.Num.toFloat = function(val) { return fan.sys.Float.make(val.valueOf()); }
fan.sys.Num.toInt = function(val)
{
  if (isNaN(val)) return 0;
  if (val == Number.POSITIVE_INFINITY) return fan.sys.Int.m_maxVal;
  if (val == Number.NEGATIVE_INFINITY) return fan.sys.Int.m_minVal;
  if (val < 0) return Math.ceil(val);
  return Math.floor(val);
}
/*
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
*/
