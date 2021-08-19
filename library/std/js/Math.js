


fan.std.Math = fan.sys.Obj.$extend(fan.sys.Obj);
fan.std.Math.prototype.$ctor = function() {}
fan.std.Math.prototype.$typeof = function() { return fan.std.Math.$type; }


fan.std.Math.pi = function() {
	return Math.PI;
}
fan.std.Math.e = function() {
	return Math.E;
}


fan.std.Math.abs = function(self) { return fan.sys.Float.make(Math.abs(self)); }
fan.std.Math.approx = function(self, that, tolerance)
{
  // need this to check +inf, -inf, and nan
  if (fan.sys.Float.compare(self, that) == 0) return true;
  var t = tolerance == null
    ? Math.min(Math.abs(self/1e6), Math.abs(that/1e6))
    : tolerance;
  return Math.abs(self - that) <= t;
}
fan.std.Math.ceil  = function(self) { return fan.sys.Float.make(Math.ceil(self)); }
fan.std.Math.exp   = function(self) { return fan.sys.Float.make(Math.exp(self)); }
fan.std.Math.floor = function(self) { return fan.sys.Float.make(Math.floor(self)); }
fan.std.Math.log   = function(self) { return fan.sys.Float.make(Math.log(self)); }
fan.std.Math.log10 = function(self) { return fan.sys.Float.make(Math.log(self) / Math.LN10); }
fan.std.Math.min   = function(self, that) { return fan.sys.Float.make(Math.min(self, that)); }
fan.std.Math.max   = function(self, that) { return fan.sys.Float.make(Math.max(self, that)); }
fan.std.Math.clip = function(self, min, max)
{
  if (self < min) return min;
  if (self > max) return max;
  return self;
}
fan.std.Math.negate = function(self) { return fan.sys.Float.make(-self); }
fan.std.Math.pow   = function(self, exp) { return fan.sys.Float.make(Math.pow(self, exp)); }
fan.std.Math.round = function(self) { return fan.sys.Float.make(Math.round(self)); }
fan.std.Math.sqrt  = function(self) { return fan.sys.Float.make(Math.sqrt(self)); }
fan.std.Math.random = function() { return fan.sys.Float.make(Math.random()); }

// arithmetic
fan.std.Math.plus     = function(a,b) { return fan.sys.Float.make(a+b); }
fan.std.Math.plusInt  = function(a,b) { return fan.sys.Float.make(a+b); }
fan.std.Math.plusDecimal = function(a,b) { return fan.sys.Decimal.make(a+b); }

fan.std.Math.minus        = function(a,b) { return fan.sys.Float.make(a-b); }
fan.std.Math.minusInt     = function(a,b) { return fan.sys.Float.make(a-b); }
fan.std.Math.minusDecimal = function(a,b) { return fan.sys.Decimal.make(a-b); }

fan.std.Math.mult        = function(a,b) { return fan.sys.Float.make(a*b); }
fan.std.Math.multInt     = function(a,b) { return fan.sys.Float.make(a*b); }
fan.std.Math.multDecimal = function(a,b) { return fan.sys.Decimal.make(a*b); }

fan.std.Math.div        = function(a,b) { return fan.sys.Float.make(a/b); }
fan.std.Math.divInt     = function(a,b) { return fan.sys.Float.make(a/b); }
fan.std.Math.divDecimal = function(a,b) { return fan.sys.Decimal.make(a/b); }

fan.std.Math.mod        = function(a,b) { return fan.sys.Float.make(a%b); }
fan.std.Math.modInt     = function(a,b) { return fan.sys.Float.make(a%b); }
fan.std.Math.modDecimal = function(a,b) { return fan.sys.Decimal.make(a%b); }

fan.std.Math.increment = function(self) { return fan.sys.Float.make(self+1); }

fan.std.Math.decrement = function(self) { return fan.sys.Float.make(self-1); }

// Trig
fan.std.Math.acos  = function(self) { return fan.sys.Float.make(Math.acos(self)); }
fan.std.Math.asin  = function(self) { return fan.sys.Float.make(Math.asin(self)); }
fan.std.Math.atan  = function(self) { return fan.sys.Float.make(Math.atan(self)); }
fan.std.Math.atan2 = function(y, x) { return fan.sys.Float.make(Math.atan2(y, x)); }
fan.std.Math.cos   = function(self) { return fan.sys.Float.make(Math.cos(self)); }
fan.std.Math.sin   = function(self) { return fan.sys.Float.make(Math.sin(self)); }
fan.std.Math.tan   = function(self) { return fan.sys.Float.make(Math.tan(self)); }
fan.std.Math.toDegrees = function(self) { return fan.sys.Float.make(self * 180 / Math.PI); }
fan.std.Math.toRadians = function(self) { return fan.sys.Float.make(self * Math.PI / 180); }
fan.std.Math.cosh  = function(self) { return fan.sys.Float.make(0.5 * (Math.exp(self) + Math.exp(-self))); }
fan.std.Math.sinh  = function(self) { return fan.sys.Float.make(0.5 * (Math.exp(self) - Math.exp(-self))); }
fan.std.Math.tanh  = function(self) { return fan.sys.Float.make((Math.exp(2*self)-1) / (Math.exp(2*self)+1)); }
