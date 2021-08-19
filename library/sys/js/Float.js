//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Dec 08  Andy Frank  Creation
//   20 May 09  Andy Frank  Refactor to new OO model
//

/**
 * Float
 */
fan.sys.Float = fan.sys.Obj.$extend(fan.sys.Num);

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

fan.sys.Float.prototype.$ctor = function() {}

fan.sys.Float.make = function(val)
{
  var x = new Number(val);
  x.$fanType = fan.sys.Float.$type;
  return x;
}

fan.sys.Float.makeBits = function(bits)
{
  throw fan.sys.Err.make("Float.makeBits not available in JavaScript");
}

fan.sys.Float.makeBits32 = function(bits)
{
  var buffer = new ArrayBuffer(4);
  (new Uint32Array(buffer))[0] = bits;
  return fan.sys.Float.make(new Float32Array(buffer)[0]);
}

fan.sys.Float.prototype.$typeof = function()
{
  return fan.sys.Float.$type;
}

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

fan.sys.Float.equals = function(self, that)
{
  if (that != null && self.$fanType === that.$fanType)
  {
    return self.valueOf() == that.valueOf();
  }
  return false;
}

fan.sys.Float.compare = function(self, that)
{
  if (self == null) return that == null ? 0 : -1;
  if (that == null) return 1;
  if (isNaN(self)) return isNaN(that) ? 0 : -1;
  if (isNaN(that)) return 1;
  if (self < that) return -1;
  return self.valueOf() == that.valueOf() ? 0 : 1;
}

fan.sys.Float.isNaN = function(self)
{
  return isNaN(self);
}

fan.sys.Float.isNegZero = function(self)
{
  return 1/self === -Infinity;
}

fan.sys.Float.normNegZero = function(self)
{
  return fan.sys.Float.isNegZero(self) ? 0.0 : self;
}

// TODO FIXIT: hash
fan.sys.Float.hash = function(self)
{
  return fan.sys.Str.hash(self.toString());
}

fan.sys.Float.bits = function(self)
{
  throw fan.sys.Err.make("Float.bits not available in JavaScript");
}

fan.sys.Float.bitsArray = function(self)
{
  var buf = new ArrayBuffer(8);
  (new Float64Array(buf))[0] = self;
  return [(new Uint32Array(buf))[0], (new Uint32Array(buf))[1]];
}

fan.sys.Float.bits32 = function(self)
{
  var buf = new ArrayBuffer(4);
  (new Float32Array(buf))[0] = self;
  return (new Uint32Array(buf))[0];
}

/////////////////////////////////////////////////////////////////////////
// Conversion
//////////////////////////////////////////////////////////////////////////

fan.sys.Float.toInt = function(val) { return (val<0) ? Math.ceil(val) : Math.floor(val); }
fan.sys.Float.toFloat = function(val) { return val; }
fan.sys.Float.toDecimal = function(val) { return fan.sys.Decimal.make(val); }

//////////////////////////////////////////////////////////////////////////
// Math
//////////////////////////////////////////////////////////////////////////

fan.sys.Float.abs = function(self) { return fan.sys.Float.make(Math.abs(self)); }
fan.sys.Float.approx = function(self, that, tolerance)
{
  // need this to check +inf, -inf, and nan
  if (fan.sys.Float.compare(self, that) == 0) return true;
  var t = tolerance == null
    ? Math.min(Math.abs(self/1e6), Math.abs(that/1e6))
    : tolerance;
  return Math.abs(self - that) <= t;
}
fan.sys.Float.ceil  = function(self) { return fan.sys.Float.make(Math.ceil(self)); }
fan.sys.Float.exp   = function(self) { return fan.sys.Float.make(Math.exp(self)); }
fan.sys.Float.floor = function(self) { return fan.sys.Float.make(Math.floor(self)); }
fan.sys.Float.log   = function(self) { return fan.sys.Float.make(Math.log(self)); }
fan.sys.Float.log10 = function(self) { return fan.sys.Float.make(Math.log(self) / Math.LN10); }
fan.sys.Float.min   = function(self, that) { return fan.sys.Float.make(Math.min(self, that)); }
fan.sys.Float.max   = function(self, that) { return fan.sys.Float.make(Math.max(self, that)); }
fan.sys.Float.negate = function(self) { return fan.sys.Float.make(-self); }
fan.sys.Float.pow   = function(self, exp) { return fan.sys.Float.make(Math.pow(self, exp)); }
fan.sys.Float.round = function(self) { return fan.sys.Float.make(Math.round(self)); }
fan.sys.Float.sqrt  = function(self) { return fan.sys.Float.make(Math.sqrt(self)); }
fan.sys.Float.random = function() { return fan.sys.Float.make(Math.random()); }

// arithmetic
fan.sys.Float.plus     = function(a,b) { return fan.sys.Float.make(a+b); }
fan.sys.Float.plusInt  = function(a,b) { return fan.sys.Float.make(a+b); }
fan.sys.Float.plusDecimal = function(a,b) { return fan.sys.Decimal.make(a+b); }

fan.sys.Float.minus        = function(a,b) { return fan.sys.Float.make(a-b); }
fan.sys.Float.minusInt     = function(a,b) { return fan.sys.Float.make(a-b); }
fan.sys.Float.minusDecimal = function(a,b) { return fan.sys.Decimal.make(a-b); }

fan.sys.Float.mult        = function(a,b) { return fan.sys.Float.make(a*b); }
fan.sys.Float.multInt     = function(a,b) { return fan.sys.Float.make(a*b); }
fan.sys.Float.multDecimal = function(a,b) { return fan.sys.Decimal.make(a*b); }

fan.sys.Float.div        = function(a,b) { return fan.sys.Float.make(a/b); }
fan.sys.Float.divInt     = function(a,b) { return fan.sys.Float.make(a/b); }
fan.sys.Float.divDecimal = function(a,b) { return fan.sys.Decimal.make(a/b); }

fan.sys.Float.mod        = function(a,b) { return fan.sys.Float.make(a%b); }
fan.sys.Float.modInt     = function(a,b) { return fan.sys.Float.make(a%b); }
fan.sys.Float.modDecimal = function(a,b) { return fan.sys.Decimal.make(a%b); }

fan.sys.Float.increment = function(self) { return fan.sys.Float.make(self+1); }

fan.sys.Float.decrement = function(self) { return fan.sys.Float.make(self-1); }

// Trig
fan.sys.Float.acos  = function(self) { return fan.sys.Float.make(Math.acos(self)); }
fan.sys.Float.asin  = function(self) { return fan.sys.Float.make(Math.asin(self)); }
fan.sys.Float.atan  = function(self) { return fan.sys.Float.make(Math.atan(self)); }
fan.sys.Float.atan2 = function(y, x) { return fan.sys.Float.make(Math.atan2(y, x)); }
fan.sys.Float.cos   = function(self) { return fan.sys.Float.make(Math.cos(self)); }
fan.sys.Float.sin   = function(self) { return fan.sys.Float.make(Math.sin(self)); }
fan.sys.Float.tan   = function(self) { return fan.sys.Float.make(Math.tan(self)); }
fan.sys.Float.toDegrees = function(self) { return fan.sys.Float.make(self * 180 / Math.PI); }
fan.sys.Float.toRadians = function(self) { return fan.sys.Float.make(self * Math.PI / 180); }
fan.sys.Float.cosh  = function(self) { return fan.sys.Float.make(0.5 * (Math.exp(self) + Math.exp(-self))); }
fan.sys.Float.sinh  = function(self) { return fan.sys.Float.make(0.5 * (Math.exp(self) - Math.exp(-self))); }
fan.sys.Float.tanh  = function(self) { return fan.sys.Float.make((Math.exp(2*self)-1) / (Math.exp(2*self)+1)); }

//////////////////////////////////////////////////////////////////////////
// Str
//////////////////////////////////////////////////////////////////////////

fan.sys.Float.fromStr = function(s, checked)
{
  if (s == "NaN") return fan.sys.Float.m_nan;
  if (s == "INF") return fan.sys.Float.m_posInf;
  if (s == "-INF") return fan.sys.Float.m_negInf;
  if (isNaN(s))
  {
    if (checked != null && !checked) return null;
    throw fan.sys.ParseErr.makeStr("Float", s);
  }
  return fan.sys.Float.make(parseFloat(s));
}

fan.sys.Float.toStr = function(self)
{
  if (isNaN(self)) return "NaN";
  if (fan.sys.Float.isNegZero(self)) return "-0.0";
  if (self == fan.sys.Float.m_posInf) return "INF";
  if (self == fan.sys.Float.m_negInf) return "-INF";
  return (fan.sys.Float.toInt(self) == self) ? self.toFixed(1) : ""+self;
}

fan.sys.Float.encode = function(self, out)
{
  if (isNaN(self)) out.w("sys::Float(\"NaN\")");
  else if (self == fan.sys.Float.m_posInf) out.w("sys::Float(\"INF\")");
  else if (self == fan.sys.Float.m_negInf) out.w("sys::Float(\"-INF\")");
  else out.w(""+self).w("f");
}

fan.sys.Float.toCode = function(self)
{
  if (isNaN(self)) return "Float.nan";
  if (self == fan.sys.Float.m_posInf) return "Float.posInf";
  if (self == fan.sys.Float.m_negInf) return "Float.negInf";
  var s = ""+self
  if (s.indexOf(".") == -1) s += ".0";
  return s + "f";
}

/////////////////////////////////////////////////////////////////////////
// Locale
//////////////////////////////////////////////////////////////////////////

fan.sys.Float.toLocale = function(self, pattern)
{
  //if (locale === undefined || locale == null) locale = fan.std.Locale.cur();
  if (pattern === undefined) pattern = null;
  try
  {
    // handle special values
    if (isNaN(self)) return "NaN";
    if (self == fan.sys.Float.m_posInf) return "+INF";
    if (self == fan.sys.Float.m_negInf) return "-INF";

    // get default pattern if necessary
    if (pattern == null)
    {
      if (Math.abs(self) >= 100.0)
        return fan.sys.Int.toLocale(Math.round(self), null);

      pattern = fan.sys.Float.toDefaultLocalePattern(self);
    }

    // TODO: if value is < 10^-3 or > 10^7 it will be
    // converted to exponent string, so just bail on that
    var string = ''+self;
// TODO FIXIT
//    if (string.indexOf('E') > 0)
//      string = new java.text.DecimalFormat("0.#########").format(self);
    return fan.sys.NumFormat.formatDigits(string, pattern);

    /*
    // parse pattern and get digits
    var p = fan.sys.NumPattern.parse(pattern);
    var d = fan.sys.NumDigits.makeStr(string);

    // route to common FanNum method
    return fan.sys.Num.toLocale(p, d, locale);
    */
  }
  catch (err)
  {
    fan.sys.ObjUtil.echo(err);
    return ''+self;
  }
}

fan.sys.Float.toDefaultLocalePattern = function(self)
{
  var abs  = Math.abs(self);
  var fabs = Math.floor(abs);

  if (fabs >= 10.0) return "#0.0#";
  if (fabs >= 1.0)  return "#0.0##";

  // format a fractional number (no decimal part)
  var frac = abs - fabs;
  if (frac < 0.00000001) return "0.0";
  if (frac < 0.0000001)  return "0.0000000##";
  if (frac < 0.000001)   return "0.000000##";
  if (frac < 0.00001)    return "0.00000##";
  if (frac < 0.0001)     return "0.0000##";
  if (frac < 0.001)      return "0.000##";
  return "0.0##";
}

