//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Dec 05  Brian Frank  Creation
//   6 Oct 08  Brian Frank  Refactor String into String/FanStr
//
package fan.sys;

import java.io.UnsupportedEncodingException;
import java.util.HashMap;

import fanx.main.*;
import fanx.util.StrUtil;

/**
 * FanString defines the methods for sys::Str.  The actual
 * class used for representation is java.lang.String.
 */
public class FanStr
{

  public static String fromChars(List chars)
  {
    if (chars.size() == 0) return "";
    StringBuilder s = new StringBuilder((int)chars.size());
    for (int i=0; i<chars.size(); ++i)
      s.append((char)((Long)chars.get(i)).longValue());
    return s.toString();
  }

  public static String makeTrim(StringBuilder s)
  {
    int start = 0;
    int end = s.length();
    while (start < end) if (FanInt.isSpace(s.charAt(start))) start++; else break;
    while (end > start) if (FanInt.isSpace(s.charAt(end-1))) end--; else break;
    return s.substring(start, end);
  }

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  public static boolean equals(String self, Object obj)
  {
    return self.equals(obj);
  }

  public static boolean equalsIgnoreCase(String a, String b)
  {
    if (a == b) return true;

    int an = a.length();
    int bn = b.length();
    if (an != bn) return false;

    for (int i=0; i<an; ++i)
    {
      int ac = a.charAt(i);
      int bc = b.charAt(i);
      if ('A' <= ac && ac <= 'Z') ac |= 0x20;
      if ('A' <= bc && bc <= 'Z') bc |= 0x20;
      if (ac != bc) return false;
    }
    return true;
  }

  public static long compare(String a, Object b)
  {
    int cmp = a.compareTo((String)b);
    if (cmp < 0) return -1;
    return cmp == 0 ? 0 : 1;
  }

  public static long compareIgnoreCase(String a, String b)
  {
    if (a == b) return 0;

    int an = a.length();
    int bn = b.length();

    for (int i=0; i<an && i<bn; ++i)
    {
      int ac = a.charAt(i);
      int bc = b.charAt(i);
      if ('A' <= ac && ac <= 'Z') ac |= 0x20;
      if ('A' <= bc && bc <= 'Z') bc |= 0x20;
      if (ac != bc) return ac < bc ? -1 : +1;
    }

    if (an == bn) return 0;
    return an < bn ? -1 : +1;
  }

  public static long hash(String self)
  {
    return self.hashCode();
  }

  public static int caseInsensitiveHash(String self)
  {
    int n = self.length();
    int hash = 0;

    for (int i=0; i<n; ++i)
    {
      int c = self.charAt(i);
      if ('A' <= c && c <= 'Z') c |= 0x20;
      hash = 31*hash + c;
    }

    return hash;
  }

  public static String toStr(String self)
  {
    return self;
  }

  public static String toLocale(String self)
  {
    return self;
  }

  private static Type type = Sys.findType("sys::Str");
  public static Type typeof(String self)
  {
    return type;
  }

//////////////////////////////////////////////////////////////////////////
// Operators
//////////////////////////////////////////////////////////////////////////

  public static long get(String self, long index)
  {
    try
    {
      int i = (int)index;
      //I don't want a bug sine the find/index return -1
//      if (i < 0) i = self.length()+i;
      return self.charAt(i);
    }
    catch (IndexOutOfBoundsException e)
    {
      throw IndexErr.make(""+index);
    }
  }

  public static long getSafe(String self, long index) { return getSafe(self, index, 0); }
  public static long getSafe(String self, long index, long def)
  {
    try
    {
      int i = (int)index;
      if (i < 0) i = self.length()+i;
      return self.charAt(i);
    }
    catch (IndexOutOfBoundsException e)
    {
      return def;
    }
  }

  public static String getRange(String self, Range r)
  {
    int size = self.length();

    int s = (int)r.startIndex(size);
    int e = (int)r.endIndex(size);
    if (e+1 < s) throw IndexErr.make(""+r);

    return self.substring(s, e+1);
  }

  public static String plus(String self, Object obj)
  {
    if (obj == null) return self.concat("null");
    String x = FanObj.toStr(obj);
    if (self.length() == 0) return x;
    if (x.length() == 0) return self;
    return self.concat(x);
  }

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  public static String intern(String self)
  {
    return self.intern();
  }

  public static boolean isEmpty(String self)
  {
    return self.length() == 0;
  }

  public static long size(String self)
  {
    return self.length();
  }

  public static boolean startsWith(String self, String s)
  {
    return self.startsWith(s, 0);
  }

  public static boolean endsWith(String self, String s)
  {
    return self.endsWith(s);
  }

  public static boolean contains(String self, String s)
  {
    return index(self, s, 0L) != null;
  }

  public static boolean containsChar(String self, long ch)
  {
    return self.indexOf((int)ch) >= 0;
  }
  
  public static Long index(String self, String s) { return index(self, s, 0L); }
  public static Long index(String self, String s, long off){
	  long res = find(self, s, off);
	  if (res == -1) {
		  return null;
	  }
	  return res;
  }

  public static long find(String self, String s) { return find(self, s, 0L); }
  public static long find(String self, String s, long off)
  {
    int i = (int)off;
    if (i < 0) i = self.length()+i;

    int r;
    if (s.length() == 1)
      r = self.indexOf(s.charAt(0), i);
    else
      r = self.indexOf(s, i);

//    if (r < 0) return -1;
    return r;
  }
  
  public static Long indexr(String self, String s) { return indexr(self, s, s.length()-1L); }
  public static Long indexr(String self, String s, long off)
  {
    long res = findr(self, s, off);
    if (res == -1) {
    	return null;
    }
    return res;
  }

  public static long findr(String self, String s) { return indexr(self, s, s.length()-1L); }
  public static long findr(String self, String s, long off)
  {
    int i = (int)off;
    if (i < 0) i = self.length()+i;

    int r;
    if (s.length() == 1)
      r = self.lastIndexOf(s.charAt(0), i);
    else
      r = self.lastIndexOf(s, i);

//    if (r < 0) return -1;
    return r;
  }

  public static Long indexIgnoreCase(String self, String s) { return indexIgnoreCase(self, s, 0L); }
  public static Long indexIgnoreCase(String self, String s, long off)
  {
    int len = self.length(), slen = s.length();
    int r = -1;

    int i = (int)off;
    if (i < 0) i = len+i;

    int first = s.charAt(0);
    for (; i<=len-slen; ++i)
    {
      // test first char
      if (neic(first, self.charAt(i))) continue;

      // test remainder of chars
      r = i;
      for (int si=1, vi=i+1; si<slen; ++si, ++vi)
        if (neic(s.charAt(si), self.charAt(vi)))
          { r = -1; break; }
      if (r >= 0) break;
    }

    if (r < 0) return null;
    return Long.valueOf(r);
  }

  public static Long indexrIgnoreCase(String self, String s) { return indexrIgnoreCase(self, s, -1L); }
  public static Long indexrIgnoreCase(String self, String s, long off)
  {
    int len = self.length(), slen = s.length();
    int r = -1;

    int i = (int)off;
    if (i < 0) i = len+i;
    if (i+slen >= len) i = len-slen;

    int first = s.charAt(0);
    for (; i>=0; --i)
    {
      // test first char
      if (neic(first, self.charAt(i))) continue;

      // test remainder of chars
      r = i;
      for (int si=1, vi=i+1; si<slen; ++si, ++vi)
        if (neic(s.charAt(si), self.charAt(vi)))
          { r = -1; break; }
      if (r >= 0) break;
    }

    if (r < 0) return null;
    return Long.valueOf(r);
  }

  private static boolean neic(int a, int b)
  {
    if (a == b) return false;
    if ((a | 0x20) == (b | 0x20)) return FanInt.lower(a) != FanInt.lower(b);
    return true;
  }

//////////////////////////////////////////////////////////////////////////
// Iterators
//////////////////////////////////////////////////////////////////////////

  public static List chars(String self)
  {
    int len = self.length();
    if (len == 0) return FanType.emptyList(FanInt.type);
    List list = List.make(FanInt.type, len);
    for (int i=0; i<len; ++i) {
    	list.add(self.charAt(i));
    }
    return list;
  }

  public static void each(String self, Func f)
  {
    int len = self.length();
//    if (f.arity() == 1)
//    {
//      for (int i=0; i<len ; ++i)
//        f.call(Long.valueOf(self.charAt(i)));
//    }
//    else
    {
      for (int i=0; i<len ; ++i)
        f.call(Long.valueOf(self.charAt(i)), Long.valueOf(i));
    }
  }

  public static void eachr(String self, Func f)
  {
//    if (f.arity() == 1)
//    {
//      for (int i=self.length()-1; i>=0; --i)
//        f.call(Long.valueOf(self.charAt(i)));
//    }
//    else
    {
      for (int i=self.length()-1; i>=0; --i)
        f.call(Long.valueOf(self.charAt(i)), Long.valueOf(i));
    }
  }

  public static boolean any(String self, Func f)
  {
    int len = self.length();
//    if (f.arity() == 1)
//    {
//      for (int i=0; i<len ; ++i)
//        if (f.callBool(Long.valueOf(self.charAt(i))))
//          return true;
//    }
//    else
    {
      for (int i=0; i<len ; ++i)
        if (f.callBool(Long.valueOf(self.charAt(i)), Long.valueOf(i)))
          return true;
    }
    return false;
  }

  public static boolean all(String self, Func f)
  {
    int len = self.length();
//    if (f.arity() == 1)
//    {
//      for (int i=0; i<len ; ++i)
//        if (!f.callBool(Long.valueOf(self.charAt(i))))
//          return false;
//    }
//    else
    {
      for (int i=0; i<len ; ++i)
        if (!f.callBool(Long.valueOf(self.charAt(i)), Long.valueOf(i)))
          return false;
    }
    return true;
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  public static String spaces(long n)
  {
    // do an array lookup for reasonable length
    // strings since that is the common case
    int count = (int)n;
    try { return spaces[count]; } catch (ArrayIndexOutOfBoundsException e) {}

    // otherwise we build a new one
    StringBuilder s = new StringBuilder(spaces[spaces.length-1]);
    for (int i=spaces.length-1; i<count; ++i)
      s.append(' ');
    return s.toString();
  }
  static String[] spaces = new String[20];
  static
  {
    StringBuilder s = new StringBuilder();
    for (int i=0; i<spaces.length; ++i)
    {
      spaces[i] = s.toString();
      s.append(' ');
    }
  }

  public static String lower(String self)
  {
    StringBuilder s = new StringBuilder(self.length());
    for (int i=0; i<self.length(); ++i)
    {
      int ch = self.charAt(i);
      if ('A' <= ch && ch <= 'Z') ch |= 0x20;
      s.append((char)ch);
    }
    return s.toString();
  }

  public static String upper(String self)
  {
    StringBuilder s = new StringBuilder(self.length());
    for (int i=0; i<self.length(); ++i)
    {
      int ch = self.charAt(i);
      if ('a' <= ch && ch <= 'z') ch &= ~0x20;
      s.append((char)ch);
    }
    return s.toString();
  }

  public static String capitalize(String self)
  {
    if (self.length() > 0)
    {
      int ch = self.charAt(0);
      if ('a' <= ch && ch <= 'z')
      {
        StringBuilder s = new StringBuilder(self.length());
        s.append((char)(ch & ~0x20));
        s.append(self, 1, self.length());
        return s.toString();
      }
    }
    return self;
  }

  public static String decapitalize(String self)
  {
    if (self.length() > 0)
    {
      int ch = self.charAt(0);
      if ('A' <= ch && ch <= 'Z')
      {
        StringBuilder s = new StringBuilder(self.length());
        s.append((char)(ch | 0x20));
        s.append(self, 1, self.length());
        return s.toString();
      }
    }
    return self;
  }

  public static String toDisplayName(String self)
  {
    if (self.length() == 0) return "";
    StringBuilder s = new StringBuilder(self.length()+4);

    // capitalize first word
    int c = self.charAt(0);
    if ('a' <= c && c <= 'z') c &= ~0x20;
    s.append((char)c);

    // insert spaces before every capital
    int last = c;
    for (int i=1; i<self.length(); ++i)
    {
      c = self.charAt(i);
      if ('A' <= c && c <= 'Z' && last != '_')
      {
        int next = i+1 < self.length() ? self.charAt(i+1) : 'Q';
        if (!('A' <= last && last <= 'Z' ) || !('A' <= next && next <= 'Z'))
          s.append(' ');
      }
      else if ('a' <= c && c <= 'z')
      {
        if (('0' <= last && last <= '9')) { s.append(' '); c &= ~0x20; }
        else if (last == '_') c &= ~0x20;
      }
      else if ('0' <= c && c <= '9')
      {
        if (!('0' <= last && last <= '9')) s.append(' ');
      }
      else if (c == '_')
      {
        s.append(' ');
        last = c;
        continue;
      }
      s.append((char)c);
      last = c;
    }
    return s.toString();
  }

  public static String fromDisplayName(String self)
  {
    if (self.length() == 0) return "";
    StringBuilder s = new StringBuilder(self.length());
    int c = self.charAt(0);
    int c2 = self.length() == 1 ? 0 : self.charAt(1);
    if ('A' <= c && c <= 'Z' && !('A' <= c2 && c2 <= 'Z')) c |= 0x20;
    s.append((char)c);
    int last = c;
    for (int i=1; i<self.length(); ++i)
    {
      c = self.charAt(i);
      if (c != ' ')
      {
        if (last == ' ' && 'a' <= c && c <= 'z') c &= ~0x20;
        s.append((char)c);
      }
      last = c;
    }
    return s.toString();
  }

  public static String mult(String self, long times)
  {
    int n = (int)times;
    if (n <= 0) return "";
    if (n == 1) return self;
    StringBuilder s = new StringBuilder(self.length()*n);
    for (int i=0; i<n; ++i) s.append(self);
    return s.toString();
  }

  public static String justl(String self, long width)
  {
    return padr(self, width, ' ');
  }

  public static String justr(String self, long width)
  {
    return padl(self, width, ' ');
  }

  public static String padl(String self, long width) { return padl(self, width, ' '); }
  public static String padl(String self, long width, long ch)
  {
    int w = (int)width;
    if (self.length() >= w) return self;
    char c = (char)ch;
    StringBuilder s = new StringBuilder(w);
    for (int i=self.length(); i<w; ++i) s.append(c);
    s.append(self);
    return s.toString();
  }

  public static String padr(String self, long width) { return padr(self, width, ' '); }
  public static String padr(String self, long width, long ch)
  {
    int w = (int)width;
    if (self.length() >= w) return self;
    char c = (char)ch;
    StringBuilder s = new StringBuilder(w);
    s.append(self);
    for (int i=self.length(); i<w; ++i) s.append(c);
    return s.toString();
  }

  public static String reverse(String self)
  {
    if (self.length() < 2) return self;
    StringBuilder s = new StringBuilder(self.length());
    for (int i=self.length()-1; i>=0; --i)
      s.append(self.charAt(i));
    return s.toString();
  }

  public static String trim(String self)
  {
    int len = self.length();
    if (len == 0) return self;
    if (self.charAt(0) > ' ' && self.charAt(len-1) > ' ') return self;
    return self.trim();
  }

  public static String trimStart(String self)
  {
    int len = self.length();
    if (len == 0) return self;
    if (self.charAt(0) > ' ') return self;
    int pos = 1;
    while (pos < len && self.charAt(pos) <= ' ') pos++;
    return self.substring(pos);
  }

  public static String trimEnd(String self)
  {
    int len = self.length();
    if (len == 0) return self;
    int pos = len-1;
    if (self.charAt(pos) > ' ') return self;
    while (pos >= 0 && self.charAt(pos) <= ' ') pos--;
    return self.substring(0, pos+1);
  }

  public static String trimToNull(String self)
  {
    String trimmed = self.trim();
    return trimmed.length() == 0 ? null : trimmed;
  }

  public static List split(String self) { return split(self, null, true); }
  public static List split(String self, Long separator) { return split(self, separator, true); }
  public static List split(String self, Long separator, boolean trimmed)
  {
    if (separator == null) return splitws(self);
    int sep = separator.intValue();
    boolean trim = trimmed;
    List toks = List.make(type, 16);
    int len = self.length();
    int x = 0;
    for (int i=0; i<len; ++i)
    {
      if (self.charAt(i) != sep) continue;
      if (x <= i) toks.add(splitStr(self, x, i, trim));
      x = i+1;
    }
    if (x <= len) toks.add(splitStr(self, x, len, trim));
    return toks;
  }

  private static String splitStr(String val, int s, int e, boolean trim)
  {
    if (trim)
    {
      while (s < e && val.charAt(s) <= ' ') ++s;
      while (e > s && val.charAt(e-1) <= ' ') --e;
    }
    return val.substring(s, e);
  }

  public static List splitws(String val)
  {
    List toks = List.make(type, 16);
    int len = val.length();
    while (len > 0 && val.charAt(len-1) <= ' ') --len;
    int x = 0;
    while (x < len && val.charAt(x) <= ' ') ++x;
    for (int i=x; i<len; ++i)
    {
      if (val.charAt(i) > ' ') continue;
      toks.add(val.substring(x, i));
      x = i + 1;
      while (x < len && val.charAt(x) <= ' ') ++x;
      i = x;
    }
    if (x <= len) toks.add(val.substring(x, len));
    if (toks.size() == 0) toks.add("");
    return toks;
  }

  public static List splitLines(String self)
  {
    List lines = List.make(type, 16);
    int len = self.length();
    int s = 0;
    for (int i=0; i<len; ++i)
    {
      int c = self.charAt(i);
      if (c == '\n' || c == '\r')
      {
        lines.add(self.substring(s, i));
        s = i+1;
        if (c == '\r' && s < len && self.charAt(s) == '\n') { i++; s++; }
      }
    }
    lines.add(self.substring(s, len));
    return lines;
  }

  public static String replace(String self, String from, String to)
  {
    if (self.length() == 0) return self;
    return StrUtil.replace(self, from, to);
  }

  public static long numNewlines(String self)
  {
    int numLines = 0;
    int len = self.length();
    for (int i=0; i<len; ++i)
    {
      int c = self.charAt(i);
      if (c == '\n') numLines++;
      else if (c == '\r')
      {
        numLines++;
        if (i+1<len && self.charAt(i+1) == '\n') i++;
      }
    }
    return numLines;
  }

  public static boolean isAscii(String self)
  {
    int len = self.length();
    for (int i=0; i<len; ++i)
      if (self.charAt(i) >= 128) return false;
    return true;
  }

  public static boolean isSpace(String self)
  {
    int len = self.length();
    for (int i=0; i<len; ++i)
    {
      int ch = self.charAt(i);
      if (ch >= 128 || (FanInt.charMap[ch] & FanInt.SPACE) == 0)
        return false;
    }
    return true;
  }

  public static boolean isUpper(String self)
  {
    int len = self.length();
    for (int i=0; i<len; ++i)
    {
      int ch = self.charAt(i);
      if (ch >= 128 || (FanInt.charMap[ch] & FanInt.UPPER) == 0)
        return false;
    }
    return true;
  }

  public static boolean isLower(String self)
  {
    int len = self.length();
    for (int i=0; i<len; ++i)
    {
      int ch = self.charAt(i);
      if (ch >= 128 || (FanInt.charMap[ch] & FanInt.LOWER) == 0)
        return false;
    }
    return true;
  }

  public static boolean isAlpha(String self)
  {
    int len = self.length();
    for (int i=0; i<len; ++i)
    {
      int ch = self.charAt(i);
      if (ch >= 128 || (FanInt.charMap[ch] & FanInt.ALPHA) == 0)
        return false;
    }
    return true;
  }

  public static boolean isAlphaNum(String self)
  {
    int len = self.length();
    for (int i=0; i<len; ++i)
    {
      int ch = self.charAt(i);
      if (ch >= 128 || (FanInt.charMap[ch] & FanInt.ALPHANUM) == 0)
        return false;
    }
    return true;
  }

  public static boolean isEveryChar(String self, int ch)
  {
    int len = self.length();
    for (int i=0; i<len; ++i)
      if (self.charAt(i) != ch) return false;
    return true;
  }

//////////////////////////////////////////////////////////////////////////
// Locale
//////////////////////////////////////////////////////////////////////////

//  public static long localeCompare(String self, String x)
//  {
//    int cmp = Locale.cur().collator().compare(self, x);
//    if (cmp < 0) return -1;
//    return cmp == 0 ? 0 : +1;
//  }
//
//  public static String localeLower(String self)
//  {
//    return self.toLowerCase(Locale.cur().java());
//  }
//
//  public static String localeUpper(String self)
//  {
//    return self.toUpperCase(Locale.cur().java());
//  }
//
//  public static String localeCapitalize(String self)
//  {
//    if (self.length() > 0)
//    {
//      int ch = self.charAt(0);
//      if (Character.isLowerCase(ch))
//      {
//        StringBuilder s = new StringBuilder(self.length());
//        s.append(Character.toString((char)ch).toUpperCase(Locale.cur().java()).charAt(0));
//        s.append(self, 1, self.length());
//        return s.toString();
//      }
//    }
//    return self;
//  }
//
//  public static String localeDecapitalize(String self)
//  {
//    if (self.length() > 0)
//    {
//      int ch = self.charAt(0);
//      if (Character.isUpperCase(ch))
//      {
//        StringBuilder s = new StringBuilder(self.length());
//        s.append(Character.toString((char)ch).toLowerCase(Locale.cur().java()).charAt(0));
//        s.append(self, 1, self.length());
//        return s.toString();
//      }
//    }
//    return self;
//  }

//////////////////////////////////////////////////////////////////////////
// Conversion
//////////////////////////////////////////////////////////////////////////

  public static boolean toBool(String self) { return FanBool.fromStr(self, true); }
  public static boolean toBool(String self, boolean checked) { return FanBool.fromStr(self, checked); }

  public static long toInt(String self) { return FanInt.fromStr(self, 10, true); }
  public static long toInt(String self, long radix) { return FanInt.fromStr(self, radix, true); }
  public static long toInt(String self, long radix, boolean checked) { return FanInt.fromStr(self, radix, checked); }

  public static double toFloat(String self) { return FanFloat.fromStr(self, true); }
  public static double toFloat(String self, boolean checked) { return FanFloat.fromStr(self, checked); }

//  public static BigDecimal toDecimal(String self) { return FanDecimal.fromStr(self, true); }
//  public static BigDecimal toDecimal(String self, boolean checked) { return FanDecimal.fromStr(self, checked); }

//  public static Uri toUri(String self) { return Uri.fromStr(self); }
//
//  public static Regex toRegex(String self) { return Regex.fromStr(self); }

  public static String toCode(String self) { return toCode(self, FanInt.pos['"'], false); }
  public static String toCode(String self, long quote) { return toCode(self, quote, false); }
  public static String toCode(String self, long quote, boolean escapeUnicode)
  {
    StringBuilder s = new StringBuilder(self.length()+10);

    // opening quote
    boolean escu = escapeUnicode;
    int q = 0;
    if (quote != 0)
    {
      q = (char)quote;
      s.append((char)q);
    }

    // NOTE: these escape sequences are duplicated in ObjEncoder
    int len = self.length();
    for (int i=0; i<len; ++i)
    {
      int c = self.charAt(i);
      switch (c)
      {
        case '\n': s.append('\\').append('n'); break;
        case '\r': s.append('\\').append('r'); break;
        case '\f': s.append('\\').append('f'); break;
        case '\t': s.append('\\').append('t'); break;
        case '\\': s.append('\\').append('\\'); break;
        case '"':  if (q == '"')  s.append('\\').append('"');  else s.append((char)c); break;
        case '`':  if (q == '`')  s.append('\\').append('`');  else s.append((char)c); break;
        case '\'': if (q == '\'') s.append('\\').append('\''); else s.append((char)c); break;
        case '$':  s.append('\\').append('$'); break;
        default:
          if (c < ' ' || (escu && c > 127))
          {
            s.append('\\').append('u')
             .append((char)hex((c>>12)&0xf))
             .append((char)hex((c>>8)&0xf))
             .append((char)hex((c>>4)&0xf))
             .append((char)hex(c&0xf));
          }
          else
          {
            s.append((char)c);
          }
      }
    }

    // closing quote
    if (q != 0) s.append((char)q);

    return s.toString();
  }

  private static int hex(int nib) { return "0123456789abcdef".charAt(nib); }

  public static String toXml(String self)
  {
    StringBuilder s = null;
    int len = self.length();
    for (int i=0; i<len; ++i)
    {
      int c = self.charAt(i);
      if (c > '>')
      {
        if (s != null) s.append((char)c);
      }
      else
      {
        String esc = xmlEsc[c];
        if (esc != null && (c != '>' || i==0 || self.charAt(i-1) == ']'))
        {
          if (s == null)
          {
            s = new StringBuilder(len+12);
            s.append(self, 0, i);
          }
          s.append(esc);
        }
        else if (s != null)
        {
          s.append((char)c);
        }
      }
    }
    if (s == null) return self;
    return s.toString();
  }

  private static String[] xmlEsc = new String['>'+1];
  static
  {
    xmlEsc['&']  = "&amp;";
    xmlEsc['<']  = "&lt;";
    xmlEsc['>']  = "&gt;";
    xmlEsc['\''] = "&#39;";
    xmlEsc['"']  = "&quot;";
  }

//  public static InStream in(String self)
//  {
//    return new StrInStream(self);
//  }
//
//  public static Buf toBuf(String self) { return toBuf(self, Charset.utf8); }
//  public static Buf toBuf(String self, Charset charset)
//  {
//    MemBuf buf = new MemBuf(self.length()*2);
//    buf.charset(charset);
//    buf.print(self);
//    return buf.flip();
//  }
  
  public ByteArray toUtf8(String self) {
	  byte[] bs;
	try {
		bs = self.getBytes("UTF-8");
		return new ByteArray(bs);
	} catch (UnsupportedEncodingException e) {
		throw UnsupportedErr.make(e);
	}
  }
  
  public static String fromUtf8(ByteArray ba) {
	try {
		return new String(ba.array(), "UTF-8");
	} catch (UnsupportedEncodingException e) {
		throw UnsupportedErr.make(e);
	}
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  static final String[] ascii = new String[128];
  static
  {
    for (int i=0; i<ascii.length; ++i)
      ascii[i] = String.valueOf((char)i).intern();
  }

  public static final String defVal = "";

}