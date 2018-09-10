//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   04 Dec 08  Brian Frank  Creation
//
package fanx.interop;

/**
 * ByteArray dummy class for byte[]
 */
public class ByteArray
{
  public static ByteArray make(int size) { return null; }
  public byte get(int index) { return 0; }
  public void set(int index, byte val) {}
  public int size() { return 0; }
}