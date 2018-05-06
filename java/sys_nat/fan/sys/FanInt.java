//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2 Dec 05  Brian Frank  Creation
//   4 Oct 08  Brian Frank  Refactor long into Long/FanInt
//
package fan.sys;

import java.math.*;
import fanx.main.*;

/**
 * FanInt defines the methods for sys::Int
 *   sys::Int   =>  long primitive
 *   sys::Int?  =>  java.lang.Long
 */
public final class FanInt
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  public static Long fromStr(String s) { return fromStr(s, 10, true); }
  public static Long fromStr(String s, long radix) { return fromStr(s, radix, true); }
  public static Long fromStr(String s, long radix, boolean checked)
  {
    try
    {
      if (radix == 16) return parseHex(s);
      if (radix == 10) return Long.valueOf(s);
      if (s.charAt(0) == '-') throw new NumberFormatException();
      return Long.valueOf(s, (int)radix);
    }
    catch (NumberFormatException e)
    {
      if (!checked) return null;
      throw ParseErr.make("Int:"+ s);
    }
  }

  private static Long parseHex(String s)
  {
    long r = 0;
    for (int i=0; i<s.length(); ++i)
    {
      int ch = s.charAt(i);
      int nib;
      if ('0' <= ch && ch <= '9') nib = ch - '0';
      else if ('a' <= ch && ch <= 'f') nib = 10 + ch - 'a';
      else if ('A' <= ch && ch <= 'F') nib = 10 + ch - 'A';
      else throw new NumberFormatException();
      r = (r << 4) | nib;
    }
    return Long.valueOf(r);
  }

  public static long random() { return random(null); }
  public static long random(Range r)
  {
    long v = random.nextLong();
    if (r == null) return v;
    if (v < 0) v = -v;
    long start = r.start();
    long end   = r.end();
    if (r.inclusive()) ++end;
    if (end <= start) throw ArgErr.make("Range end < start: " + r);
    return start + (v % (end-start));
  }
  static final java.util.Random random = new java.security.SecureRandom();

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  public static boolean equals(long self, Object obj)
  {
    if (obj instanceof Long)
      return self == ((Long)obj).longValue();
    else
      return false;
  }

  public static long compare(long self, Object obj)
  {
    long that = (Long)obj;
    if (self < that) return -1; return self == that ? 0 : +1;
  }

  public static long hash(long self)
  {
    return self;
  }

  public static Type type = Sys.findType("sys::Int");
  public static Type typeof(long self)
  {
    return type;
  }

//////////////////////////////////////////////////////////////////////////
// Operators
//////////////////////////////////////////////////////////////////////////

  public static long negate(long self) { return -self; }

  public static long increment(long self) { return self+1; }

  public static long decrement(long self) { return self-1; }

  public static long mult(long self, long x) { return self * x; }
  public static double multFloat(long self, double x) { return (double)self * x; }
  public static BigDecimal multDecimal(long self, BigDecimal x) { return BigDecimal.valueOf(self).multiply(x); }

  public static long div(long self, long x) { return self / x; }
  public static double divFloat(long self, double x) { return (double)self / x; }
  public static BigDecimal divDecimal(long self, BigDecimal x) { return BigDecimal.valueOf(self).divide(x); }

  public static long mod(long self, long x) { return self % x; }
  public static double modFloat(long self, double x) { return (double)self % x; }
  public static BigDecimal modDecimal(long self, BigDecimal x) { return BigDecimal.valueOf(self).remainder(x); }

  public static long plus(long self, long x) { return self + x; }
  public static double plusFloat(long self, double x) { return (double)self + x; }
  public static BigDecimal plusDecimal(long self, BigDecimal x) { return BigDecimal.valueOf(self).add(x); }

  public static long minus(long self, long x) { return self - x; }
  public static double minusFloat(long self, double x) { return (double)self - x; }
  public static BigDecimal minusDecimal(long self, BigDecimal x) { return BigDecimal.valueOf(self).subtract(x); }

//////////////////////////////////////////////////////////////////////////
// Bitwise
//////////////////////////////////////////////////////////////////////////

  public static long not(long self) { return ~self; }

  public static long and(long self, long x) { return self & x; }

  public static long or(long self, long x) { return self | x; }

  public static long xor(long self, long x) { return self ^ x; }

  public static long shiftl(long self, long x) { return self << x; }

  public static long shiftr(long self, long x) { return self >>> x; }

  public static long shifta(long self, long x) { return self >> x; }

//////////////////////////////////////////////////////////////////////////
// Math
//////////////////////////////////////////////////////////////////////////

  public static long abs(long self)
  {
    if (self >= 0) return self;
    return -self;
  }

  public static long min(long self, long that)
  {
    if (self <= that) return self;
    return that;
  }

  public static long max(long self, long that)
  {
    if (self >= that) return self;
    return that;
  }

  public static long pow(long self, long pow)
  {
    if (pow < 0) throw ArgErr.make("pow < 0");
    long result = 1;
    for (; pow>0; pow>>=1)
    {
      if ((pow&1) == 1) result *= self;
      self *= self;
    }
    return result;
  }

  public static boolean isEven(long self)
  {
    return (self % 2) == 0;
  }

  public static boolean isOdd(long self)
  {
    return (self % 2) != 0;
  }

/////////////////////////////////////////////////////////////////////////
// Char
//////////////////////////////////////////////////////////////////////////


  public static boolean isSpace(long self)
  {
    try
    {
      return (self < 128 && (charMap[(int)self] & SPACE) != 0);
    }
    catch (ArrayIndexOutOfBoundsException e)
    {
      // should be very rare to use this method with negative
      // numbers, so don't take the hit every call
      return false;
    }
  }

  public static boolean isAlpha(long self)
  {
    try
    {
      return self < 128 && (charMap[(int)self] & ALPHA) != 0;
    }
    catch (ArrayIndexOutOfBoundsException e)
    {
      // should be very rare to use this method with negative
      // numbers, so don't take the hit every call
      return false;
    }
  }

  public static boolean isAlphaNum(long self)
  {
    try
    {
      return (self < 128 && (charMap[(int)self] & ALPHANUM) != 0);
    }
    catch (ArrayIndexOutOfBoundsException e)
    {
      // should be very rare to use this method with negative
      // numbers, so don't take the hit every call
      return false;
    }
  }

  public static boolean isUpper(long self)
  {
    return 'A' <= self && self <= 'Z';
  }

  public static boolean isLower(long self)
  {
    return 'a' <= self && self <= 'z';
  }

  public static long upper(long self)
  {
    if ('a' <= self && self <= 'z')
      return self & ~0x20L;
    else
      return self;
  }

  public static long lower(long self)
  {
    if ('A' <= self && self <= 'Z')
      return self | 0x20L;
    else
      return self;
  }

  public static boolean isDigit(long self)
  {
    return '0' <= self && self <= '9';
  }

  public static boolean isDigit(long self, long r)
  {
    if (self < 0 || self >= 128) return false;

    int val = (int)self;
    int radix = (int)r;
    if (radix == 10)
    {
      return ((charMap[val] & DIGIT) != 0);
    }

    if (radix == 16)
    {
      return ((charMap[val] & HEX) != 0);
    }

    if (radix <= 10)
    {
      return '0' <= val && val <= ('0'+radix);
    }
    else
    {
      if ((charMap[val] & DIGIT) != 0) return true;
      int x = radix - 10;
      if ('a' <= val && val < 'a'+x) return true;
      if ('A' <= val && val < 'A'+x) return true;
      return false;
    }
  }

  public static Long toDigit(long self)
  {
    if (0 <= self && self <= 9) return pos[(int)self+ '0'];
    return null;
  }

  public static Long toDigit(long self, long radix)
  {
    if (self < 0 || self >= radix) return null;

    if (self < 10) return pos[(int)self + '0'];
    return pos[(int)self - 10 + 'a'];
  }

  public static Long fromDigit(long self)
  {
    if ('0' <= self && self <= '9') return pos[(int)self - '0'];
    return null;
  }

  public static Long fromDigit(long self, long r)
  {
    if (self < 0 || self >= 128) return null;
    int val = (int)self;

    int radix = (int)r;
    int ten = radix < 10 ? radix : 10;
    if ('0' <= val && val < '0'+ten) return pos[val - '0'];
    if (radix > 10)
    {
      int alpha = radix-10;
      if ('a' <= val && val < 'a'+alpha) return pos[val + 10 - 'a'];
      if ('A' <= val && val < 'A'+alpha) return pos[val + 10 - 'A'];
    }
    return null;
  }

  public static boolean equalsIgnoreCase(long self, long ch)
  {
    if ('A' <= self && self <= 'Z') self |= 0x20;
    if ('A' <= ch   && ch   <= 'Z') ch   |= 0x20;
    return self == ch;
  }

  static final byte[] charMap = new byte[128];
  static final int SPACE    = 0x01;
  static final int UPPER    = 0x02;
  static final int LOWER    = 0x04;
  static final int DIGIT    = 0x08;
  static final int HEX      = 0x10;
  static final int ALPHA    = UPPER | LOWER;
  static final int ALPHANUM = UPPER | LOWER | DIGIT;
  static
  {
    charMap[' ']  |= SPACE;
    charMap['\n'] |= SPACE;
    charMap['\r'] |= SPACE;
    charMap['\t'] |= SPACE;
    charMap['\f'] |= SPACE;

    // alpha characters
    for (int i='a'; i<='z'; ++i) charMap[i] |= LOWER;
    for (int i='A'; i<='Z'; ++i) charMap[i] |= UPPER;

    // digit characters
    for (int i='0'; i<='9'; ++i) charMap[i] |= DIGIT;

    // hex characters
    for (int i='0'; i<='9'; ++i) charMap[i] |= HEX;
    for (int i='a'; i<='f'; ++i) charMap[i] |= HEX;
    for (int i='A'; i<='F'; ++i) charMap[i] |= HEX;
  }

//////////////////////////////////////////////////////////////////////////
// Locale
//////////////////////////////////////////////////////////////////////////

//  public static String toLocale(long self) { return toLocale(self, null, null); }
//  public static String toLocale(long self, String pattern) { return toLocale(self, pattern, null); }
//  public static String toLocale(long self, String pattern, Locale locale)
//  {
//    // get current locale
//    if (locale == null) locale = Locale.cur();
//
//    // if pattern is "B" format as bytes
//    if (pattern != null && pattern.length() == 1 && pattern.charAt(0) == 'B')
//      return toLocaleBytes(self);
//
//    // get default pattern if necessary
//    if (pattern == null)
//      pattern = Env.cur().locale(Sys.sysPod, "int", "#,###", locale);
//
//    // parse pattern and get digits
//    NumPattern p = NumPattern.parse(pattern);
//    NumDigits d = new NumDigits(self);
//
//    // route to common FanNum method
//    return FanNum.toLocale(p, d, locale);
//  }
//
//  static String toLocaleBytes(long b)
//  {
//    if (b < KB)    return b + "B";
//    if (b < 10*KB) return FanFloat.toLocale((double)b/KB, "#.#") + "KB";
//    if (b < MB)    return Math.round((double)b/KB) + "KB";
//    if (b < 10*MB) return FanFloat.toLocale((double)b/MB, "#.#") + "MB";
//    if (b < GB)    return Math.round((double)b/MB) + "MB";
//    if (b < 10*GB) return FanFloat.toLocale((double)b/GB, "#.#") + "GB";
//    return Math.round((double)b/GB) + "GB";
//  }
//  private static final long KB = 1024L;
//  private static final long MB = 1024L*1024L;
//  private static final long GB = 1024L*1024L*1024L;

//  public static boolean localeIsUpper(long self)
//  {
//    return Character.isUpperCase((int)self);
//  }
//
//  public static boolean localeIsLower(long self)
//  {
//    return Character.isLowerCase((int)self);
//  }

//  public static long localeUpper(long self)
//  {
//    // Java doesn't provide a locale Character API
//    return Character.toString((char)self).toUpperCase(Locale.cur().java()).charAt(0);
//  }
//
//  public static long localeLower(long self)
//  {
//    // Java doesn't provide a locale Character API
//    return Character.toString((char)self).toLowerCase(Locale.cur().java()).charAt(0);
//  }

//////////////////////////////////////////////////////////////////////////
// Conversion
//////////////////////////////////////////////////////////////////////////

  public static String toChar(long self)
  {
    if (self < 0 || self > 0xFFFF) throw Err.make("Invalid unicode char: " + self);
    if (self < FanStr.ascii.length) return FanStr.ascii[(int)self];
    return String.valueOf((char)self);
  }

  public static String toHex(long self) { return toHex(self, null); }
  public static String toHex(long self, Long width)
  {
    return pad(Long.toHexString(self), width);
  }

  public static String toRadix(long self, long radix) { return toRadix(self, radix, null); }
  public static String toRadix(long self, long radix, Long width)
  {
    return pad(Long.toString(self, (int)radix), width);
  }

  private static String pad(String s, Long width)
  {
    if (width == null || s.length() >= width.intValue()) return s;
    StringBuilder sb = new StringBuilder(width.intValue());
    int zeros = width.intValue() - s.length();
    for (int i=0; i<zeros; ++i) sb.append('0');
    sb.append(s);
    return sb.toString();
  }

  public static String toStr(long self)
  {
    return String.valueOf(self);
  }

  public static String toCode(long self) { return String.valueOf(self); }
  public static String toCode(long self, long base)
  {
    if (base == 10) return String.valueOf(self);
    if (base == 16) return "0x" + Long.toHexString(self);
    throw ArgErr.make("Invalid base " + base);
  }
//
//  public static Duration toDuration(long self) { return Duration.make(self); }
//
//  public static DateTime toDateTime(long self) { return DateTime.makeTicks(self); }
//  public static DateTime toDateTime(long self, TimeZone tz) { return DateTime.makeTicks(self, tz); }

//////////////////////////////////////////////////////////////////////////
// Closures
//////////////////////////////////////////////////////////////////////////

  public static void times(long self, Func f)
  {
//    if (f.arity() == 0)
//    {
//      for (long i=0; i<self; ++i) f.call();
//    }
//    else
    {
      for (long i=0; i<self; ++i) f.call(Long.valueOf(i));
    }
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  /** sys::Int.maxValue */
  public static final long maxVal = Long.MAX_VALUE;

  /** sys::Int.minValue */
  public static final long minVal = Long.MIN_VALUE;

  /** sys::Int.defVal */
  public static final long defVal = 0L;

  // default chunk size for IO buffering (defaults to 4KB)
  public static final Long Chunk = Long.valueOf(4096);

  // internalized boxed Longs used for byte IO
  static final Long[] pos = new Long[256];
  static { for (int i=0; i<pos.length; ++i) pos[i] = Long.valueOf(i); }

}
