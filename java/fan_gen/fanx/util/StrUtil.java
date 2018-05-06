//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//
package fanx.util;

import java.io.*;
import java.net.*;
import java.text.*;
import java.util.*;
import fanx.fcode.*;

/**
 * StrUtil provides helpful methods for string manipulation.
 */
public class StrUtil
{

  /**
   * Return a new string replacing all occurrences
   * of match with replace in s
   */
  public static String replace(String s, String match, String replace)
  {
    if (match.length() == 0) return s;

    StringBuilder b = new StringBuilder();

    int mlen = match.length();
    int last = 0;
    int curr = s.indexOf(match);

    while (curr != -1)
    {
      b.append(s.substring(last, curr));
      b.append(replace);

      last = curr + mlen;
      curr = s.indexOf(match, last);
    }

    if (last < s.length())
      b.append(s.substring(last));

    return b.toString();
  }

  /**
   * Translate the specified string as it would appear in
   * code as a string literal.  For example all newlines
   * appear as \n.
   */
  public static String asCode(String s)
  {
    StringBuilder b = new StringBuilder();
    for (int i=0; i<s.length(); ++i)
    {
      char c = s.charAt(i);
      switch (c)
      {
        case '\0': b.append("\\0");  break;
        case '\t': b.append("\\t");  break;
        case '\n': b.append("\\n");  break;
        case '\r': b.append("\\r");  break;
        case '\\': b.append("\\\\"); break;
        default:   b.append(c);      break;
      }
    }
    return b.toString();
  }

  /**
   * Get a string containing the specified number of spaces.
   */
  public static String getSpaces(int len)
  {
    // do an array lookup for reasonable length
    // strings since that is the common case
    try { return spaces[len]; } catch (ArrayIndexOutOfBoundsException e) {}

    // otherwise we build a new one
    StringBuilder s = new StringBuilder(spaces[spaces.length-1]);
    for (int i=spaces.length-1; i<len; ++i)
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

  /**
   * Pad to the left to ensure string is specified length.
   * If s.length already greater than len, do nothing.
   */
  public static String padl(String s, int len)
  {
    if (s.length() >= len) return s;
    return getSpaces(len-s.length()) + s;
  }

  /**
   * Pad to the right to ensure string is specified length.
   * If s.length already greater than len, do nothing.
   */
  public static String padr(String s, int len)
  {
    if (s.length() >= len) return s;
    return s + getSpaces(len-s.length());
  }

  /**
   * Get current hostname.
   */
  public static String hostname()
  {
    if (hostname == null)
    {
      try
      {
        hostname = InetAddress.getLocalHost().getHostName();
      }
      catch (Exception e)
      {
        hostname = "Unknown";
      }
    }
    return hostname;
  }
  static String hostname = null;

  /**
   * Get a timestamp string for current time.
   */
  public static String timestamp()
  {
    return new SimpleDateFormat("d-MMM-yyyy HH:mm:ss zzz").format(new Date());
  }

  /**
   * Get simple class name from specified class.
   */
  public static String getName(Class cls)
  {
    String name = cls.getName();
    int dot = name.lastIndexOf('.');
    if (dot < 0) return name;
    return name.substring(dot+1);
  }

  /**
   * Write the stack trace to a string.
   */
  public static String traceToString(Throwable e)
  {
    StringWriter out = new StringWriter();
    e.printStackTrace(new PrintWriter(out));
    return out.toString();
  }

  /**
   * Return a zero based index as "first", "second", etc.
   */
  public static String toOrder(int index)
  {
    switch (index)
    {
      case 0:  return "first";
      case 1:  return "second";
      case 2:  return "third";
      case 3:  return "fourth";
      case 4:  return "fifth";
      case 5:  return "sixth";
      case 6:  return "seventh";
      case 7:  return "eighth";
      case 8:  return "ninth";
      case 9:  return "tenth";
      default: return (index+1) + "th";
    }
  }

  /**
   * Convert FConst flags to a string.
   */
  public static String flagsToString(int flags)
  {
    StringBuilder s = new StringBuilder();
    if ((flags & FConst.Public)    != 0) s.append("public ");
    if ((flags & FConst.Protected) != 0) s.append("protected ");
    if ((flags & FConst.Private)   != 0) s.append("private ");
    if ((flags & FConst.Internal)  != 0) s.append("internal ");
    if ((flags & FConst.Native)    != 0) s.append("native ");
    if ((flags & FConst.Enum)      != 0) s.append("enum ");
    if ((flags & FConst.Mixin)     != 0) s.append("mixin ");
    if ((flags & FConst.Final)     != 0) s.append("final ");
    if ((flags & FConst.Ctor)      != 0) s.append("new ");
    if ((flags & FConst.Override)  != 0) s.append("override ");
    if ((flags & FConst.Abstract)  != 0) s.append("abstract ");
    if ((flags & FConst.Static)    != 0) s.append("static ");
    if ((flags & FConst.Virtual)   != 0) s.append("virtual ");
    return s.toString();
  }

  public static Comparator comparator = new Comparator()
  {
    public int compare(Object a, Object b)
    {
      return String.valueOf(a).compareTo(String.valueOf(b));
    }
  };

}