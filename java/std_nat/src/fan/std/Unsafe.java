//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   8 Feb 09  Brian Frank  Creation
//
package fan.std;

import fan.sys.FanObj;
import fanx.main.Sys;
import fanx.main.Type;

/**
 * Unsafe
 */
public final class Unsafe
  extends FanObj
{

  public static Unsafe make(Object val) { return new Unsafe(val); }

  public Unsafe(Object val) { this.val = val; }
  
  private static Type type = null;
  public Type typeof() { if (type == null) { type = Sys.findType("std::Unsafe"); } return type;  }

  public Object val() { return val; }
  
  public Object get() { return val; }

  public boolean isImmutable() { return true; }

  private Object val;

}