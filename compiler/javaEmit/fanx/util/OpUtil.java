//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   11 Jan 06  Brian Frank  Creation
//
package fanx.util;

import fanx.main.IObj;

/**
 * OpUtil provides static methods used to implement special fcode opcodes.
 */
public class OpUtil
{

//////////////////////////////////////////////////////////////////////////
// Object Comparisions
//////////////////////////////////////////////////////////////////////////
  private static long doCompare(Object a, Object b) {
	  if (a instanceof IObj) {
		  return ((IObj)a).compare(b);
	  }
	  else if (a instanceof Comparable) {
	      return ((Comparable)a).compareTo(b);
	  }
	  return a.toString().compareTo(b.toString());
  }

  public static boolean compareEQ(Object a, Object b)
  {
    if (a == null) return (b == null);
    return a.equals(b);
  }

  public static boolean compareNE(Object a, Object b)
  {
    if (a == null) return (b != null);
    return !a.equals(b);
  }

  public static long compare(Object a, Object b)
  {
    if (a == null) return (b == null) ? 0 : -1;
    if (b == null) return +1;
    return doCompare(a, b);
  }

  public static boolean compareLT(Object a, Object b)
  {
    if (a == null) return (b != null);
    if (b == null) return false;
    return doCompare(a, b) < 0;
  }

  public static boolean compareLE(Object a, Object b)
  {
    if (a == null) return true;
    if (b == null) return false;
    return doCompare(a, b) <= 0;
  }

  public static boolean compareGE(Object a, Object b)
  {
    if (a == null) return (b == null);
    if (b == null) return true;
    return doCompare(a, b) >= 0;
  }

  public static boolean compareGT(Object a, Object b)
  {
    if (a == null) return false;
    if (b == null) return true;
    return doCompare(a, b) > 0;
  }

//////////////////////////////////////////////////////////////////////////
// sys::Bool Comparisions
//////////////////////////////////////////////////////////////////////////

  public static boolean compareEQ(boolean a, boolean b) { return a == b; }
  public static boolean compareEQ(boolean a, Object b)  { return (b instanceof Boolean) ? a == ((Boolean)b).booleanValue() : false; }
  public static boolean compareEQ(Object a, boolean b)   { return (a instanceof Boolean) ? b == ((Boolean)a).booleanValue() : false; }

  public static boolean compareNE(boolean a, boolean b) { return a != b; }
  public static boolean compareNE(boolean a, Object b)  { return (b instanceof Boolean) ? a != ((Boolean)b).booleanValue() : true; }
  public static boolean compareNE(Object a, boolean b)   { return (a instanceof Boolean) ? b != ((Boolean)a).booleanValue() : true; }

  public static boolean compareLT(boolean a, boolean b) { return a == b ? false : !a; }
  public static boolean compareLT(boolean a, Object b)  { return (b instanceof Boolean) ? compareLT(a, ((Boolean)b).booleanValue()) : compareLT((Object)a, b); }
  public static boolean compareLT(Object a, boolean b)  { return (a instanceof Boolean) ? compareLT(((Boolean)a).booleanValue(), b) : compareLT(a, (Object)b); }

  public static boolean compareLE(boolean a, boolean b) { return a == b ? true : !a; }
  public static boolean compareLE(boolean a, Object b)  { return (b instanceof Boolean) ? compareLE(a, ((Boolean)b).booleanValue()) : compareLE((Object)a, b); }
  public static boolean compareLE(Object a, boolean b)  { return (a instanceof Boolean) ? compareLE(((Boolean)a).booleanValue(), b) : compareLE(a, (Object)b); }

  public static boolean compareGE(boolean a, boolean b) { return a == b ? true : a; }
  public static boolean compareGE(boolean a, Object b)  { return (b instanceof Boolean) ? compareGE(a, ((Boolean)b).booleanValue()) : compareGE((Object)a, b); }
  public static boolean compareGE(Object a, boolean b)  { return (a instanceof Boolean) ? compareGE(((Boolean)a).booleanValue(), b) : compareGE(a, (Object)b); }

  public static boolean compareGT(boolean a, boolean b) { return a == b ? false : a; }
  public static boolean compareGT(boolean a, Object b)  { return (b instanceof Boolean) ? compareGT(a, ((Boolean)b).booleanValue()) : compareGT((Object)a, b); }
  public static boolean compareGT(Object a, boolean b)  { return (a instanceof Boolean) ? compareGT(((Boolean)a).booleanValue(), b) : compareGT(a, (Object)b); }

  public static long compare(boolean a, boolean b) { return a == b ? 0 : (a ? +1 : -1); }
  public static long compare(boolean a, Object b)  { return (b instanceof Boolean) ? compare(a, ((Boolean)b).booleanValue()) : compare((Object)a, b); }
  public static long compare(Object a, boolean b)  { return (a instanceof Boolean) ? compare(((Boolean)a).booleanValue(), b) : compare(a, (Object)b); }

//////////////////////////////////////////////////////////////////////////
// sys::Int Comparisions
//////////////////////////////////////////////////////////////////////////

  public static boolean compareEQ(long a, long b) { return a == b; }
  public static boolean compareEQ(long a, Object b) { return (b instanceof Long) ? a == ((Long)b).longValue() : false; }
  public static boolean compareEQ(Object a, long b) { return (a instanceof Long) ? b == ((Long)a).longValue() : false; }

  public static boolean compareNE(long a, long b) { return a != b; }
  public static boolean compareNE(long a, Object b) { return (b instanceof Long) ? a != ((Long)b).longValue() : true; }
  public static boolean compareNE(Object a, long b) { return (a instanceof Long) ? b != ((Long)a).longValue() : true; }

  public static boolean compareLT(long a, long b) { return a < b; }
  public static boolean compareLT(long a, Object b) { return (b instanceof Long) ? a < ((Long)b).longValue() : compareLT((Object)a, b); }
  public static boolean compareLT(Object a, long b) { return (a instanceof Long) ? ((Long)a).longValue() < b : compareLT(a, (Object)b); }

  public static boolean compareLE(long a, long b) { return a <= b; }
  public static boolean compareLE(long a, Object b) { return (b instanceof Long) ? a <= ((Long)b).longValue() : compareLE((Object)a, b); }
  public static boolean compareLE(Object a, long b) { return (a instanceof Long) ? ((Long)a).longValue() <= b : compareLE(a, (Object)b); }

  public static boolean compareGE(long a, long b) { return a >= b; }
  public static boolean compareGE(long a, Object b) { return (b instanceof Long) ? a >= ((Long)b).longValue() : compareGE((Object)a, b); }
  public static boolean compareGE(Object a, long b) { return (a instanceof Long) ? ((Long)a).longValue() >= b : compareGE(a, (Object)b); }

  public static boolean compareGT(long a, long b) { return a > b; }
  public static boolean compareGT(long a, Object b) { return (b instanceof Long) ? a > ((Long)b).longValue() : compareGT((Object)a, b); }
  public static boolean compareGT(Object a, long b) { return (a instanceof Long) ? ((Long)a).longValue() > b : compareGT(a, (Object)b); }

  public static long compare(long a, long b) { return a < b ? -1 : (a == b ? 0 : +1); }
  public static long compare(long a, Object b) { return (b instanceof Long) ? compare(a, ((Long)b).longValue()) : compare((Object)a, b); }
  public static long compare(Object a, long b) { return (a instanceof Long) ? compare(((Long)a).longValue(), b) : compare(a, (Object)b); }

//////////////////////////////////////////////////////////////////////////
// sys::Float Comparisions
//////////////////////////////////////////////////////////////////////////

  public static boolean compareEQ(double a, double b) { return a == b; }
  public static boolean compareEQ(double a, Object b) { return (b instanceof Double) ? compareEQ(a, ((Double)b).doubleValue()) : false; }
  public static boolean compareEQ(Object a, double b) { return (a instanceof Double) ? compareEQ(((Double)a).doubleValue(), b) : false; }

  public static boolean compareNE(double a, double b) { return a != b;}
  public static boolean compareNE(double a, Object b) { return (b instanceof Double) ? compareNE(a, ((Double)b).doubleValue()) : true; }
  public static boolean compareNE(Object a, double b) { return (a instanceof Double) ? compareNE(((Double)a).doubleValue(), b) : true; }

  public static boolean compareLT(double a, double b) { return a < b; }
  public static boolean compareLT(double a, Object b) { return (b instanceof Double) ? compareLT(a, ((Double)b).doubleValue()) : compareLT((Object)a, b); }
  public static boolean compareLT(Object a, double b) { return (a instanceof Double) ? compareLT(((Double)a).doubleValue(), b) : compareLT(a, (Object)b); }

  public static boolean compareLE(double a, double b) { return a <= b; }
  public static boolean compareLE(double a, Object b) { return (b instanceof Double) ? compareLE(a, ((Double)b).doubleValue()) : compareLE((Object)a, b); }
  public static boolean compareLE(Object a, double b) { return (a instanceof Double) ? compareLE(((Double)a).doubleValue(), b) : compareLE(a, (Object)b); }

  public static boolean compareGE(double a, double b) { return a >= b; }
  public static boolean compareGE(double a, Object b) { return (b instanceof Double) ? compareGE(a, ((Double)b).doubleValue()) : compareGE((Object)a, b); }
  public static boolean compareGE(Object a, double b) { return (a instanceof Double) ? compareGE(((Double)a).doubleValue(), b) : compareGE(a, (Object)b); }

  public static boolean compareGT(double a, double b) { return a > b; }
  public static boolean compareGT(double a, Object b) { return (b instanceof Double) ? compareGT(a, ((Double)b).doubleValue()) : compareGT((Object)a, b); }
  public static boolean compareGT(Object a, double b) { return (a instanceof Double) ? compareGT(((Double)a).doubleValue(), b) : compareGT(a, (Object)b); }

  public static long compare(double a, Object b) { return (b instanceof Double) ? compare(a, ((Double)b).doubleValue()) : compare((Object)a, b); }
  public static long compare(Object a, double b) { return (a instanceof Double) ? compare(((Double)a).doubleValue(), b) : compare(a, (Object)b); }
  public static long compare(double a, double b)
  {
    if (Double.isNaN(a))
    {
      return (Double.isNaN(b)) ? 0 : -1;
    }
    if (Double.isNaN(b)) return +1;
    return a < b ? -1 : (a == b ? 0 : +1);
  }

//////////////////////////////////////////////////////////////////////////
// Is/As
//////////////////////////////////////////////////////////////////////////

//  public static boolean is(Object instance, ClassType type)
//  {
//    if (instance == null) return false;
//    if (instance instanceof IObj) {
//    	IObj fobj = (IObj)instance;
//    	fobj.typeof().fits(type);
//    }
//    if (type.isObj()) return true;
//    
//    return type.getJavaClass().isInstance(instance);
//  }

//  public static Object toImmutable(Object obj)
//  {
//    if (obj == null) return null;
//    
//    if (obj instanceof IObj) {
//	    IObj fobj = (IObj)obj;
//	    if (fobj.isImmutable()) return obj;
//	    
//	    Type type = fobj.typeof();
//	    if ((type.flags() & FConst.Const) != 0) return obj;
//	    if ((type.flags() & FConst.RuntimeConst) != 0) {
//	    	return fobj.toImmutable();
//	    }
//    } else {
//    	if (FanUtil.isJavaImmutable(obj.getClass())) {
//    		return obj;
//    	}
//    }
//    throw new RuntimeException("NotImmutableErr:"+obj.getClass().getName());
//  }

}