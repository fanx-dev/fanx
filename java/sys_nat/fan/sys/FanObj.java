//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2 Dec 05  Brian Frank  Creation
//
package fan.sys;


import fanx.main.*;
import fanx.util.*;

/**
 * FanObj is the root class of all classes in Fantom - it is the class
 * representation of Obj.
 */
public class FanObj implements IObj
{

//////////////////////////////////////////////////////////////////////////
// Java
//////////////////////////////////////////////////////////////////////////

  public int hashCode()
  {
    long hash = hash();
    return (int)(hash ^ (hash >>> 32));
  }

  public final String toString()
  {
    return toStr();
  }

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  public static boolean equals(Object self, Object x)
  {
    return self.equals(x);
  }

  public static long compare(Object self, Object x)
  {
    if (self instanceof FanObj)
      return ((FanObj)self).compare(x);
    else if (self instanceof Comparable)
      return ((Comparable)self).compareTo(x);
    else
      return FanStr.compare(toStr(self), toStr(x));
  }

  public long compare(Object obj)
  {
    return FanStr.compare(toStr(), toStr(obj));
  }
  
  public int compareTo(Object obj)
  {
    return (int) compare(obj);
  }

  public static long hash(Object self)
  {
    if (self instanceof FanObj)
      return ((FanObj)self).hash();
    else
      return self.hashCode();
  }

  public long hash()
  {
    return super.hashCode();
  }

  public static String toStr(Object self)
  {
    if (self instanceof FanObj)
      return ((FanObj)self).toStr();
    else if (self instanceof Err)
      return ((Err)self).toStr();
    else if (self.getClass() == java.lang.Double.class)
      return FanFloat.toStr(((java.lang.Double)self).doubleValue());
    else
      return self.toString();
  }

  public String toStr()
  {
    return super.toString();
  }

  public static boolean isImmutable(Object self)
  {
    if (self instanceof FanObj)
      return ((FanObj)self).isImmutable();
    else if (self == null)
      return true;
    else if (self instanceof Err)
      return true;
    else
      return FanUtil.isJavaImmutable(self.getClass());
  }

  public boolean isImmutable()
  {
    try
    {
      return typeof().isConst();
    }
    catch (NullPointerException e)
    {
      // there are cases where accessing the type in a static initializer
      // can happen before the type is configured; since static init problems
      // are tricky to debug just make sure we dump some diagnostics
      Err err = Err.make("Calling Obj.isImmutable in static initializers before type are available");
      err.trace();
      throw err;
    }
  }

  public static Object toImmutable(Object self)
  {
    if (self == null) return null;
    if (self instanceof FanObj)
      return ((FanObj)self).toImmutable();
    else if (self instanceof Err)
      return self;
    else if (FanUtil.isJavaImmutable(self.getClass()))
      return self;
    throw NotImmutableErr.make(self.getClass().getName());
  }

  public Object toImmutable()
  {
    if (typeof().isConst()) return this;
//    throw NotImmutableErr.make(this.getClass().toString());
    throw NotImmutableErr.make(typeof().toString());
  }

  public static Type typeof(Object self)
  {
    if (self instanceof FanObj)
      return ((FanObj)self).typeof();
    else if (self instanceof Err)
      return ((Err)self).typeof();
    else
      return FanUtil.toFanType(self.getClass(), true);
  }
  
  static Type type = Sys.findType("sys::Obj");

  public Type typeof()
  {
    return type;
  }

  public static Object with(Object self, Func f)
  {
    if (self instanceof FanObj)
    {
      return ((FanObj)self).with(f);
    }
    else
    {
      f.call(self);
      return self;
    }
  }

  public Object with(Func f) { f.call(this); return this; }

  public static Object trap(Object self, String name)
  {
    if (self instanceof FanObj)
      return ((FanObj)self).trap(name, (List)null);
    else
      return doTrap(self, name, null, typeof(self));
  }

  public static Object trap(Object self, String name, List args)
  {
    if (self instanceof FanObj)
      return ((FanObj)self).trap(name, args);
    else
      return doTrap(self, name, args, typeof(self));
  }

  public Object trap(String name) { return doTrap(this, name, null, typeof()); }
  public Object trap(String name, List args) { return doTrap(this, name, args, typeof()); }

  private static Object doTrap(Object self, String name, List args, Type type)
  {
	  //TODO
//    Slot slot = type.slot(name, true);
//
//    if (slot instanceof Method)
//    {
//      Method m = (Method)slot;
//      return m.func.callOn(self, args);
//    }
//    else
//    {
//      // handle FFI field overloaded with a method
//      Field f = (Field)slot;
//      if (f.overload != null)
//        return f.overload.func.callOn(self, args);
//
//      // zero args -> getter
//      int argSize = (args == null) ? 0 : args.sz();
//      if (argSize == 0)
//      {
//        return f.get(self);
//      }
//
//      // one arg -> setter
//      if (argSize == 1)
//      {
//        Object val = args.get(0);
//        f.set(self, val);
//        return val;
//      }
//
//      throw ArgErr.make("Invalid number of args to get or set field '" + name + "'");
//    }
	  return null;
  }

  // Remap all java.lang.Objects as statics since we emit to FanObj
  public static String toString(Object o) { return o.toString(); }
  public static Class getClass(Object o) { return o.getClass(); }
  public static int hashCode(Object o) { return o.hashCode(); }
  public static void notify(Object o) { o.notify(); }
  public static void notifyAll(Object o) { o.notifyAll(); }
  public static void wait(Object o) throws InterruptedException { o.wait(); }
  public static void wait(Object o, long t) throws InterruptedException { o.wait(t); }
  public static void wait(Object o, long t, int n) throws InterruptedException { o.wait(t, n); }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  public static void echo() { echo(""); }
  public static void echo(Object obj)
  {
    if (obj == null) obj = "null";
    String str = toStr(obj);
    System.out.println(str);
  }

}