//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Dec 05  Brian Frank  Creation
//
package fan.sys;

import fanx.main.*;

/**
 * Void is the absence of a type.
 */
public class Void
{
  private static Type type = Sys.findType("sys::Void");
  public Type typeof() { return type; }

}