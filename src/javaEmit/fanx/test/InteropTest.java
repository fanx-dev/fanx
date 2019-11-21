//
//Copyright (c) 2008, Brian Frank and Andy Frank
//Licensed under the Academic Free License version 3.0
//
//History:
//20 Sep 08  Brian Frank  Creation
//
package fanx.test;

import java.util.*;
import java.io.*;
import java.math.*;
import java.text.*;
import fanx.util.*;

/**
* InteropTest
*/
public class InteropTest
{
//////////////////////////////////////////////////////////////////////////
//Factories
//////////////////////////////////////////////////////////////////////////

public static InteropTest makeOne() { return new InteropTest(); }

//////////////////////////////////////////////////////////////////////////
//Primitives
//////////////////////////////////////////////////////////////////////////

public long num = 1000;

public byte   numb() { return (byte)num; }
public short  nums() { return (short)num; }
public char   numc() { return (char)num; }
public int    numi() { return (int)num; }
public long   numl() { return num; }
public double numd() { return num; }
public float  numf() { return num; }

public void numb(byte x)   { num = x; }
public void nums(short x)  { num = x; }
public void numc(char x)   { num = x; }
public void numi(int x)    { num = x; }
public void numl(long x)   { num = x; }
public void numd(double x) { num = (long)x; }
public void numf(float x)  { num = (long)x; }

public byte   numb = 'b';
public short  nums = 's';
public char   numc = 'c';
public int    numi = 'i';
public long   numl = 'l';
public float  numf = 'f';
public double numd = 'd';

public static byte   snumb = 'B';
public static short  snums = 'S';
public static char   snumc = 'C';
public static int    snumi = 'I';
public static long   snuml = 'L';
public static float  snumf = 'F';
public static double snumd = 'D';

public void numadd(byte b, short s, int i, float f)  { num = b + s + i + (int)f; }

public byte   xnumb() { return (byte)num; }
public short  xnums() { return (short)num; }
public char   xnumc() { return (char)num; }
public int    xnumi() { return (int)num; }
public long   xnuml() { return num; }
public double xnumd() { return num; }
public float  xnumf() { return num; }

public void xnumb(byte x)   { num = x; }
public void xnums(short x)  { num = x; }
public void xnumc(char x)   { num = x; }
public void xnumi(int x)    { num = x; }
public void xnuml(long x)   { num = x; }
public void xnumd(double x) { num = (long)x; }
public void xnumf(float x)  { num = (long)x; }

public long numi(int x, int y) { return num = x + y; }  // 4x overload
public long numi(String s) { return num = Integer.parseInt(s); }  // 4x overload

public static int si(String s, int y) { return Integer.parseInt(s) + y; }

//////////////////////////////////////////////////////////////////////////
//Object Arrays
//////////////////////////////////////////////////////////////////////////

public InteropTest a;
public InteropTest b;
public InteropTest c;

public InteropTest initArray()
{
 a = new InteropTest();
 b = new InteropTest();
 c = new InteropTest();
 return this;
}

public InteropTest[] array1() { return new InteropTest[] { a, b, c}; }

public void array1(InteropTest[] x) { a = x[0]; b = x[1]; c = x[2]; }

public SimpleDateFormat[] formats;
public String[] strings;
public int[] ints;

//////////////////////////////////////////////////////////////////////////
//Primitive Arrays
//////////////////////////////////////////////////////////////////////////

public boolean[] booleanArray(boolean a, boolean b) { return new boolean[] { a, b }; }
public byte[] byteArray(byte a, byte b) { return new byte[] { a, b }; }
public short[] shortArray(short a, short b) { return new short[] { a, b }; }
public char[] charArray(char a, char b) { return new char[] { a, b }; }
public int[] intArray(int a, int b) { return new int[] { a, b }; }
public long[] longArray(long a, long b) { return new long[] { a, b }; }
public float[] floatArray(float a, float b) { return new float[] { a, b }; }
public double[] doubleArray(double a, double b) { return new double[] { a, b }; }

public void setShortArray(short[] a) {}
public void setAmount(Long amount) {}

//////////////////////////////////////////////////////////////////////////
//Multi-dimensional Arrays
//////////////////////////////////////////////////////////////////////////

public Date[][] dateMulti2() { return new Date[3][]; }
public Date[][][] dateMulti3;
public String[][] strMulti2() { return new String[3][]; }
public String[][][] strMulti3;
public int[][] intMulti2() { return new int[3][]; }
public int[][][] intMulti3;
public double[][] doubleMulti2() { return new double[3][]; }
public double[][][] doubleMulti3;

//////////////////////////////////////////////////////////////////////////
//Ambiguous Overloads
//////////////////////////////////////////////////////////////////////////

public void ambiguous1(Object a, int b) {}
public void ambiguous1(int a, Object b) {}

public void ambiguous2(String x) {}
public void ambiguous2(InteropTest x) {}

//////////////////////////////////////////////////////////////////////////
//Overload Resolution
//////////////////////////////////////////////////////////////////////////

public String overload1(Object a) { return "(Object)"; }
public String overload1(String a) { return "(String)"; }
public String overload1(long a)   { return "(long)"; }

public String overload2(int a, Object b) { return "(int, Object)"; }
public String overload2(int a, Number b) { return "(int, Number)"; }
public String overload2(int a, Double b) { return "(int, Double)"; }

//////////////////////////////////////////////////////////////////////////
//Inner Class
//////////////////////////////////////////////////////////////////////////

public static class InnerClass
{
 public String name() { return "InnerClass"; }
}

//////////////////////////////////////////////////////////////////////////
//AbstractOverrides
//////////////////////////////////////////////////////////////////////////

public static abstract class AbstractOverloadsClass
{
 public abstract void foo();
 public abstract void foo(String x);
}

public static interface AbstractOverloadsInterface
{
 public abstract void foo();
 public abstract void foo(String x);
}

public static interface AbstractOverloadsA
{
 public abstract void foo(Object x);
}

public static interface AbstractOverloadsB
{
 public abstract void foo(String x);
}

//////////////////////////////////////////////////////////////////////////
//Class+Interfaces
//////////////////////////////////////////////////////////////////////////

public static interface ComboA { String foo(String x); }
public static interface ComboB { String foo(String x); }
public static abstract class ComboC { public abstract String foo(String x); }
public static abstract class ComboD extends ComboC implements ComboA, ComboB {}

//////////////////////////////////////////////////////////////////////////
//JavaOverrides
//////////////////////////////////////////////////////////////////////////

public interface JavaOverrides
{
 int add(int a, int b);
 JavaOverrides[] arraySelf();
 Object arrayGet(Object[] a, int index);
 String[] swap(String[] a);
 long addfs(double d, String s);
 BigDecimal[] addDecimal(BigDecimal[] a, BigDecimal d);
}

public static interface PrimitiveRouters
{
 public abstract boolean z(boolean x);
 public abstract byte b(byte x);
 public abstract char c(char x);
 public abstract short s(short x);
 public abstract int i(int x);
 public abstract long j(long x);
 public abstract float f(float x);
 public abstract double d(double x);
}

public static class ProtectedOverride
{
 protected String foo() { return "protected"; }
}

public static class PublicOverride extends ProtectedOverride
{
 public String foo() { return "public"; }
}

//////////////////////////////////////////////////////////////////////////
//Funcs
//////////////////////////////////////////////////////////////////////////

public static interface FuncA
{
 public String thru(String s);
}

public static interface FuncB
{
 public int add(int a, int b, int c);
}

public static interface FuncC
{
 public String[] swap(String[] x);
}

//////////////////////////////////////////////////////////////////////////
//Once FFI testing
//////////////////////////////////////////////////////////////////////////

public static interface Once
{
 public String[] array();
 public int i();
}

//////////////////////////////////////////////////////////////////////////
//Builtin Extra Types
//////////////////////////////////////////////////////////////////////////

public static int charSequence(CharSequence x) { return x.length(); }
public static Serializable serializable(Serializable x) { return x; }
public static int comparable(Comparable a, Comparable b) { return a.compareTo(b); }
public static Number number(Number x) { return x; }

}
