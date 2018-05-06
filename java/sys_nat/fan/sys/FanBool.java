//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2 Dec 05  Brian Frank  Creation
//   4 Oct 08  Brian Frank  Refactor Bool into Boolean/FanBool
//
package fan.sys;

import fanx.main.*;

/**
 * FanBoolean defines the methods for sys::Bool:
 *   sys::Bool   =>  boolean primitive
 *   sys::Bool?  =>  java.lang.Boolean
 */
public final class FanBool
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  public static Boolean fromStr(String s) { return fromStr(s, true); }
  public static Boolean fromStr(String s, boolean checked)
  {
    if (s.equals("true")) return Boolean.TRUE;
    if (s.equals("false")) return Boolean.FALSE;
    if (!checked) return null;
    throw ParseErr.make("Bool:" + s);
  }

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  public static boolean equals(boolean self, Object obj)
  {
    if (obj instanceof Boolean)
      return self == ((Boolean)obj).booleanValue();
    else
      return false;
  }

  public static long hash(boolean self)
  {
    return self ? 1231 : 1237;
  }

  private static Type type = Sys.findType("sys::Bool");
  public static Type typeof(boolean self)
  {
    return type;
  }

//////////////////////////////////////////////////////////////////////////
// Operators
//////////////////////////////////////////////////////////////////////////

  public static boolean not(boolean self)
  {
    return !self;
  }

  public static boolean and(boolean self, boolean b)
  {
    return self & b;
  }

  public static boolean or(boolean self, boolean b)
  {
    return self | b;
  }

  public static boolean xor(boolean self, boolean b)
  {
    return self ^ b;
  }

//////////////////////////////////////////////////////////////////////////
// Conversion
//////////////////////////////////////////////////////////////////////////

  public static String toStr(boolean self)
  {
    return self ? "true" : "false";
  }

//  public static String toLocale(boolean self)
//  {
//    return Env.cur().locale(Sys.sysPod, self ? "boolTrue" : "boolFalse", toStr(self));
//  }

//  public static void encode(boolean self, ObjEncoder out)
//  {
//    out.w(self ? "true" : "false");
//  }

  public static String toCode(boolean self)
  {
    return self ? "true" : "false";
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  public static final boolean defVal = false;

}