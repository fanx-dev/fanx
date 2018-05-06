//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   15 Sep 05  Brian Frank  Creation
//
package fanx.util;

import java.util.*;

/**
 * Box is a byte buffer used to pack a fcode/class file.
 */
public class Box
{

//////////////////////////////////////////////////////////////////////////
// Constructors
//////////////////////////////////////////////////////////////////////////

  public Box()
  {
    this.buf = new byte[256];
    this.len = 0;
  }

  public Box(byte[] buf)
  {
    this.buf = buf;
    this.len = buf.length;
  }

  public Box(byte[] buf, int len)
  {
    this.buf = buf;
    this.len = len;
  }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  public final void u1(int v)
  {
    if (len+1 >= buf.length) grow();
    buf[len++] = (byte)(v >>> 0);
  }

  public final void u2(int v)
  {
    if (len+2 >= buf.length) grow();
    buf[len++] = (byte)(v >>> 8);
    buf[len++] = (byte)(v >>> 0);
  }

  public final void u2(int pos, int v)
  {
    // backpatch
    buf[pos+0] = (byte)(v >>> 8);
    buf[pos+1] = (byte)(v >>> 0);
  }

  public final void u4(int v)
  {
    if (len+4 >= buf.length) grow();
    buf[len++] = (byte)(v >>> 24);
    buf[len++] = (byte)(v >>> 16);
    buf[len++] = (byte)(v >>> 8);
    buf[len++] = (byte)(v >>> 0);
  }

  public final void u4(int pos, int v)
  {
    // backpatch
    buf[pos+0] = (byte)(v >>> 24);
    buf[pos+1] = (byte)(v >>> 16);
    buf[pos+2] = (byte)(v >>> 8);
    buf[pos+3] = (byte)(v >>> 0);
  }

  public final void u8(long v)
  {
    if (len+8 >= buf.length) grow();
    buf[len++] = (byte)(v >>> 56);
    buf[len++] = (byte)(v >>> 48);
    buf[len++] = (byte)(v >>> 40);
    buf[len++] = (byte)(v >>> 32);
    buf[len++] = (byte)(v >>> 24);
    buf[len++] = (byte)(v >>> 16);
    buf[len++] = (byte)(v >>> 8);
    buf[len++] = (byte)(v >>> 0);
  }

  public final void f4(float v)
  {
    u4(Float.floatToIntBits(v));
  }

  public final void f8(double v)
  {
    u8(Double.doubleToLongBits(v));
  }

  public final void append(Box box)
  {
    append(box.buf, box.len);
  }

  public final void append(byte[] bytes, int bytesLen)
  {
    while (len + bytesLen >= buf.length) grow();
    System.arraycopy(bytes, 0, buf, len, bytesLen);
    len += bytesLen;
  }

  public final void skip(int num)
  {
    while (len + num >= buf.length) grow();
    len += num;
  }

  public final void utf(String s)
  {
    int slen = s.length();
    int utflen = 0;

    // first we have to figure out the utf length
    for (int i=0; i<slen; ++i)
    {
      int c = s.charAt(i);
      if (c <= 0x007F)
      {
        // Java requres \0 as 0xC080
        if (c == 0) utflen += 2;
        else utflen += 1;
      }
      else if (c > 0x07FF)
      {
        utflen += 3;
      }
      else
      {
        utflen += 2;
      }
    }

    // sanity check
    if (utflen > 65536) throw new RuntimeException("string too big");

    // ensure capacity
    while (len + 2 + utflen >= buf.length)
      grow();

    // write length as 2 byte value
    buf[len++] = (byte)((utflen >>> 8) & 0xFF);
    buf[len++] = (byte)((utflen >>> 0) & 0xFF);

    // write characters
    for (int i=0; i<slen; ++i)
    {
      int c = s.charAt(i);
      if (c <= 0x007F)
      {
        // Java requres \0 as 0xC080
        if (c == 0) { buf[len++] = (byte)0xC0; buf[len++] = (byte)0x80; }
        else buf[len++] = (byte)c;
      }
      else if (c > 0x07FF)
      {
        buf[len++] = (byte)(0xE0 | ((c >> 12) & 0x0F));
        buf[len++] = (byte)(0x80 | ((c >>  6) & 0x3F));
        buf[len++] = (byte)(0x80 | ((c >>  0) & 0x3F));
      }
      else
      {
        buf[len++] = (byte)(0xC0 | ((c >>  6) & 0x1F));
        buf[len++] = (byte)(0x80 | ((c >>  0) & 0x3F));
      }
    }
  }

  public final void grow() { grow(buf.length*2); }
  public final void grow(int desired)
  {
    if (desired > buf.length)
    {
      byte[] temp = new byte[desired];
      System.arraycopy(buf, 0, temp, 0, buf.length);
      buf = temp;
    }
  }

  public void dump()
  {
    for (int i=0; i<len; ++i)
      System.out.println("  [" + i + "] 0x" + Integer.toHexString(buf[i] & 0xFF));
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  public byte[] buf;
  public int len;

}