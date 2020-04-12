//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Jan 06  Brian Frank  Creation
//
package fan.std;

import fan.sys.*;
import fanx.fcode.*;
import fanx.main.*;


/**
 * Param represents one parameter definition of a Func (or Method).
 */
public class Param
  extends FanObj
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  public Param(String name, Type type, int mask)
  {
    this.name = name;
    this.type = type;
    this.mask = mask;
  }
  
  public static Param fromFCode(FMethodVar var, FPod pod) {
	  FTypeRef tref = pod.typeRef(var.type);
	  Type type2 = Sys.findType(tref.signature);
	  return new Param(var.name, type2, var.hasDefault() ? HAS_DEFAULT : 0);
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////
  static Type typeof = Sys.findType("std::Param");

  public Type typeof() { 
	  return typeof;
  }

  public String name()  { return name; }
  public Type type()   { return type; }
  public boolean hasDefault() { return (mask & HAS_DEFAULT) != 0; }

  public String toStr() { return type + " " + name; }

  public boolean isImmutable() {
    return true;
  }

  public Object toImmutable() {
    return this;
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  public static final int HAS_DEFAULT   = 0x01;  // is a default value provided

  final String name;
  final Type type;
  final int mask;

}