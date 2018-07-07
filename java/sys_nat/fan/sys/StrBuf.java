//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   28 Dec 05  Brian Frank  Creation
//
package fan.sys;

import fanx.main.*;

/**
 * StrBuf mutable random-access sequence of integer characters.
 */
public class StrBuf
  extends FanObj
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  /**
   * Create with initial capacity of 16.
   */
  public static StrBuf make()
  {
    return new StrBuf(new StringBuilder(16));
  }

  /**
   * Create with specified capacity.
   */
  public static StrBuf make(long capacity)
  {
    return new StrBuf(new StringBuilder((int)capacity));
  }

  public StrBuf(StringBuilder sb)
  {
    this.sb = sb;
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  public boolean isEmpty()
  {
    return sb.length() == 0;
  }

  public long size()
  {
    return sb.length();
  }

  public long capacity()
  {
    return sb.capacity();
  }

  public void capacity(long size)
  {
    sb.ensureCapacity((int)size);
  }

  public long get(long index)
  {
    int i = (int)index;
    if (i < 0) i = sb.length()+i;
    return sb.charAt(i);
  }

  public String getRange(Range r)
  {
    int size = sb.length();

    int s = (int)r.startIndex(size);
    int e = (int)r.endIndex(size);
    if (e+1 < s) throw IndexErr.make(""+r);

    return sb.substring(s, e+1);
  }

  public StrBuf set(long index, long ch)
  {
    int i = (int)index;
    if (i < 0) i = sb.length()+i;
    sb.setCharAt(i, (char)ch);
    return this;
  }

  public StrBuf add(Object x)
  {
    String s = (x == null) ? "null" : toStr(x);
    sb.append(s);
    return this;
  }

  public StrBuf addChar(long ch)
  {
//  sb.append((char)ch);
	sb.appendCodePoint((int)ch);
    return this;
  }
  
  public StrBuf addStr(String str, long off, long len)
  {
	sb.append(str, (int)off, (int)(off+len));
    return this;
  }

  public StrBuf join(Object x) { return join(x, " "); }
  public StrBuf join(Object x, String sep)
  {
    String s = (x == null) ? "null" : toStr(x);
    if (sb.length() > 0) sb.append(sep);
    sb.append(s);
    return this;
  }

  public StrBuf insert(long index, Object x)
  {
    String s = (x == null) ? "null" : toStr(x);
    int i = (int)index;
    if (i < 0) i = sb.length()+i;
    if (i > sb.length()) throw IndexErr.make(""+index);
    sb.insert(i, s);
    return this;
  }

  public StrBuf remove(long index)
  {
    int i = (int)index;
    if (i < 0) i = sb.length()+i;
    if (i >= sb.length()) throw IndexErr.make(""+index);
    sb.delete(i, i+1);
    return this;
  }

  public StrBuf removeRange(Range r)
  {
    int s = (int)r.startIndex(sb.length());
    int e = (int)r.endIndex(sb.length());
    int n = e - s + 1;
    if (n < 0) throw IndexErr.make(""+r);
    sb.delete(s, e+1);
    return this;
  }

  public StrBuf replaceRange(Range r, String str)
  {
    int s = (int)r.startIndex(sb.length());
    int e = (int)r.endIndex(sb.length());
    if (e+1 < s) throw IndexErr.make(""+r);
    sb.replace(s, e+1, str);
    return this;
  }

  public StrBuf clear()
  {
    sb.setLength(0);
    return this;
  }

  public String toStr()
  {
    return sb.toString();
  }

  private static Type type;
  public Type typeof()
  {
	if (type == null) type = Sys.findType("sys::StrBuf");
    return type;
  }
//
//  public OutStream out()
//  {
//    return new StrBufOutStream(this);
//  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  public StringBuilder sb;

}