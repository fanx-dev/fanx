//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   23 Apr 08  Brian Frank  Creation
//    4 Oct 08  Brian Frank  Refactor Decimal into BigDecimal/FanDecimal
//
package fan.std;

import java.math.*;

import fan.sys.*;
import fanx.main.Sys;
import fanx.main.Type;

/**
 * FanDecimal defines the methods for sys::Decimal.  The actual
 * class used for representation is java.math.BigDecimal.
 */
public final class FanDecimal
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  public static BigDecimal fromStr(String s) { return fromStr(s, true); }
  public static BigDecimal fromStr(String s, boolean checked)
  {
    try
    {
      return new BigDecimal(s);
    }
    catch (NumberFormatException e)
    {
      if (!checked) return null;
      throw ParseErr.make("Decimal:"+ s);
    }
  }
  
  public static BigDecimal toDecimal(Number self)
  {
    if (self instanceof BigDecimal) return (BigDecimal)self;
    if (self instanceof Long) return new BigDecimal(self.longValue());
    return new BigDecimal(self.doubleValue());
  }

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  public static boolean equals(BigDecimal self, Object obj)
  {
    if (obj instanceof BigDecimal)
    {
      return self.equals(obj);
    }
    return false;
  }

  public static long compare(BigDecimal self, Object obj)
  {
    return self.compareTo((BigDecimal)obj);
  }

  public static long hash(BigDecimal self)
  {
    return self.hashCode();
  }
  
  private static Type type;

  public static Type typeof()
  {
    if (type == null) type = Sys.findType("std::Decimal");
    return type;
  }

//////////////////////////////////////////////////////////////////////////
// Operators
//////////////////////////////////////////////////////////////////////////

  public static BigDecimal negate(BigDecimal self) { return self.negate(); }

  public static BigDecimal increment(BigDecimal self) { return self.add(BigDecimal.ONE); }

  public static BigDecimal decrement(BigDecimal self) { return self.subtract(BigDecimal.ONE); }

  public static BigDecimal mult(BigDecimal self, BigDecimal x) { return self.multiply(x); }
  public static BigDecimal multInt(BigDecimal self, long x) { return self.multiply(BigDecimal.valueOf(x)); }
  public static BigDecimal multFloat(BigDecimal self, double x) { return self.multiply(BigDecimal.valueOf(x)); }

  public static BigDecimal div(BigDecimal self, BigDecimal x)
  {
    // From https://github.com/groovy/groovy-core/blob/master/src/main/org/codehaus/groovy/runtime/typehandling/BigDecimalMath.java
    // as suggested by 'saltnlight5' in "Decimal operation failure?" discussion http://fantom.org/sidewalk/topic/1743
    try
    {
      return self.divide(x);
    }
    catch (ArithmeticException e)
    {
      // set a DEFAULT precision if otherwise non-terminating
      int precision = java.lang.Math.max(self.precision(), x.precision()) + DIVISION_EXTRA_PRECISION;
      BigDecimal result = self.divide(x, new MathContext(precision));
      int scale = java.lang.Math.max(java.lang.Math.max(self.scale(), x.scale()), DIVISION_MIN_SCALE);
      if (result.scale() > scale) result = result.setScale(scale, BigDecimal.ROUND_HALF_UP);
      return result;
    }
  }
  public static BigDecimal divInt(BigDecimal self, long x) { return div(self, BigDecimal.valueOf(x)); }
  public static BigDecimal divFloat(BigDecimal self, double x) { return div(self, BigDecimal.valueOf(x)); }

  public static BigDecimal mod(BigDecimal self, BigDecimal x) { return self.remainder(x); }
  public static BigDecimal modInt(BigDecimal self, long x) { return self.remainder(BigDecimal.valueOf(x)); }
  public static BigDecimal modFloat(BigDecimal self, double x) { return self.remainder(BigDecimal.valueOf(x)); }

  public static BigDecimal plus(BigDecimal self, BigDecimal x) { return self.add(x); }
  public static BigDecimal plusInt(BigDecimal self, long x) { return self.add(BigDecimal.valueOf(x)); }
  public static BigDecimal plusFloat(BigDecimal self, double x) { return self.add(BigDecimal.valueOf(x)); }

  public static BigDecimal minus(BigDecimal self, BigDecimal x) { return self.subtract(x); }
  public static BigDecimal minusInt(BigDecimal self, long x) { return self.subtract(BigDecimal.valueOf(x)); }
  public static BigDecimal minusFloat(BigDecimal self, double x) { return self.subtract(BigDecimal.valueOf(x)); }

//////////////////////////////////////////////////////////////////////////
// Math
//////////////////////////////////////////////////////////////////////////

  public static BigDecimal abs(BigDecimal self)
  {
    return self.abs();
  }

  public static BigDecimal min(BigDecimal self, BigDecimal that)
  {
    if (self.compareTo(that) <= 0) return self;
    return that;
  }

  public static BigDecimal max(BigDecimal self, BigDecimal that)
  {
    if (self.compareTo(that) >= 0) return self;
    return that;
  }

//////////////////////////////////////////////////////////////////////////
// Conversion
//////////////////////////////////////////////////////////////////////////

  public static String toStr(BigDecimal self)
  {
    return self.toString();
  }

//  public static void encode(BigDecimal self, ObjEncoder out)
//  {
//    out.w(self.toString()).w("d");
//  }

  public static String toCode(BigDecimal self)
  {
    return self.toString() + "d";
  }

  public static String toLocale(BigDecimal self) { return toLocale(self, null); }
//  public static String toLocale(BigDecimal self, String pattern) { return toLocale(self, pattern, null); }
  public static String toLocale(BigDecimal self, String pattern)
  {
    // get current locale
//    if (locale == null) locale = Locale.cur();

    // get default pattern if necessary
    if (pattern == null) {
    	return FanFloat.toLocale(self.doubleValue(), pattern);
    }

    return NumFormat.formatDigits(self.toString(), pattern);
  }
  

  public static long toInt(BigDecimal self) {
    return self.longValue();
  }

  public static double toFloat(BigDecimal self) {
    return self.doubleValue();
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  public static BigDecimal defVal = BigDecimal.ZERO;

  // This is an arbitrary value, picked as a reasonable choice for a precision
  // for typical user math when a non-terminating result would otherwise occur.
  private static final int DIVISION_EXTRA_PRECISION = 10;

  // This is an arbitrary value, picked as a reasonable choice for a rounding point
  // for typical user math.
  private static final int DIVISION_MIN_SCALE = 10;

}