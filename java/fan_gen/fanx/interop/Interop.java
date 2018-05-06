//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   13 May 09  Brian Frank  Creation
//
package fanx.interop;

import java.io.InputStream;
import java.io.OutputStream;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import fanx.util.*;

/**
 * Interop defines for converting between Fantom and Java for common types.
 */
public class Interop
{

//////////////////////////////////////////////////////////////////////////
// Reflection
//////////////////////////////////////////////////////////////////////////

  /**
   * Get the java Class of the given object.
   */
  public static Class getClass(Object obj)
  {
    return obj.getClass();
  }
//
//  /**
//   * Convert java.lang.Class to sys::Type.
//   */
//  public static Type toFan(Class cls)
//  {
//    return FanUtil.toFanType(cls, true);
//  }
//
//  /**
//   * Convert sys::Type to java.lang.Class.  You
//   * can also access this functionality using the
//   * trap operator "->toClass" on Type.
//   */
//  public static Class toJava(Type type)
//  {
//    return type.toClass();
//  }
//
////////////////////////////////////////////////////////////////////////////
//// Exceptions
////////////////////////////////////////////////////////////////////////////
//
//  /**
//   * Given a Java exception instance translate to a Fantom exception.
//   * If the exception maps to a built-in Fantom exception then the
//   * native Fantom type is used - for example NullPointerException will
//   * return a NullErr.  Otherwise the Java exception is wrapped
//   * as a generic Err instance.
//   */
//  public static Err toFan(Throwable ex)
//  {
//    return Err.make(ex);
//  }
//
//  /**
//   * Given a Fantom exception instance, get the underlying Java exception.
//   */
//  public static Throwable toJava(Err err)
//  {
//    return err.toJava();
//  }
//
////////////////////////////////////////////////////////////////////////////
//// IO
////////////////////////////////////////////////////////////////////////////
//
//  /**
//   * Convert from java.io.InputStream to sys::InStream
//   * with default buffer size of 4096.
//   */
//  public static InStream toFan(InputStream in)
//  {
//    return SysInStream.make(in, FanInt.Chunk);
//  }
//
//  /**
//   * Convert from java.io.InputStream to sys::InStream
//   * with the given buffer size.
//   */
//  public static InStream toFan(InputStream in, long bufSize)
//  {
//    return SysInStream.make(in, bufSize);
//  }
//
//  /**
//   * Convert from java.io.OutputStream to sys::OutStream
//   * with default buffer size of 4096.
//   */
//  public static OutStream toFan(OutputStream out)
//  {
//    return SysOutStream.make(out, FanInt.Chunk);
//  }
//
//  /**
//   * Convert from java.io.OutputStream to sys::OutStream
//   * with the given buffer size.
//   */
//  public static OutStream toFan(OutputStream out, long bufSize)
//  {
//    return SysOutStream.make(out, bufSize);
//  }
//
//  /**
//   * Convert from java.io.File to sys::File.
//   */
//  public static File toFan(java.io.File file)
//  {
//    return new LocalFile(file);
//  }
//
//  /**
//   * Convert from java.nio.ByteBuffer to sys::Buf.
//   */
//  public static Buf toFan(java.nio.ByteBuffer buf)
//  {
//    return new NioBuf(buf);
//  }
//
//  /**
//   * Convert from sys::Buf to to java.nio.ByteBuffer
//   *
//   * Return a bytebuffer that shares the same storage
//   * as this byte buffer, but independent pos and size.
//   *
//   * Changes made to the resulting ByteBuffer will affect
//   * this ByteBuffer's content but not its pos or size.
//   *
//   * The ByteBuffer will be created with position equal
//   * to this buf's pos and limit equal to this buf's limit,
//   * and no mark set.
//   *
//   * Throws UnsupportedErr if this Buf doesn't use an
//   ** underlying storage system supported by ByteBuffer.
//   *
//   * @see java.nio.ByteBuffer#duplicate
//   * @see java.nio.ByteBuffer#wrap(byte[], int, int)
//   */
//  public static java.nio.ByteBuffer toJava(Buf buf)
//  {
//    return buf.toByteBuffer();
//  }
//
//  /**
//   * Convert from sys::InStream to java.io.InputStream.
//   */
//  public static InputStream toJava(InStream in)
//  {
//    return SysInStream.java(in);
//  }
//
//  /**
//   * Convert from sys::OutStream to java.io.OutputStream.
//   */
//  public static OutputStream toJava(OutStream out)
//  {
//    return SysOutStream.java(out);
//  }
//
//  /**
//   * Convert from sys::File to java.io.File.  Raise
//   * cast exception if not a local file.
//   */
//  public static java.io.File toJava(File file)
//  {
//    return ((LocalFile)file).toJava();
//  }
//
////////////////////////////////////////////////////////////////////////////
//// Collections
////////////////////////////////////////////////////////////////////////////
//
//  /**
//   * Convert a java.util.List to a sys::List with a type of Obj?[].
//   */
//  public static List toFan(java.util.List list)
//  {
//    return toFan(list.iterator(), Sys.ObjType.toNullable());
//  }
//
//  /**
//   * Convert a java.util.List to a sys::List of the specified type.
//   */
//  public static List toFan(java.util.List list, Type of)
//  {
//    return toFan(list.iterator(), of);
//  }
//
//  /**
//   * Convert a java.util.Enumeration to a sys::List with a type of Obj?[].
//   */
//  public static List toFan(Enumeration e)
//  {
//    return toFan(e, Sys.ObjType.toNullable());
//  }
//
//  /**
//   * Convert a java.util.Enumeration to a sys::List of the specified type.
//   */
//  public static List toFan(Enumeration e, Type of)
//  {
//    List list = new List(of);
//    while (e.hasMoreElements()) list.add(e.nextElement());
//    return list;
//  }
//
//  /**
//   * Convert a java.util.Iterator to a sys::List with a type of Obj?[].
//   */
//  public static List toFan(Iterator i)
//  {
//    return toFan(i, Sys.ObjType.toNullable());
//  }
//
//  /**
//   * Convert a java.util.Iterator to a sys::List of the specified type.
//   */
//  public static List toFan(Iterator i, Type of)
//  {
//    List list = new List(of);
//    while (i.hasNext()) list.add(i.next());
//    return list;
//  }
//
//  /**
//   * Convert a java.util.HashMap to a sys::Map with a type of Obj:Obj?.
//   */
//  public static Map toFan(HashMap map)
//  {
//    return new Map(new MapType(Sys.ObjType, Sys.ObjType.toNullable()), map);
//  }
//
//  /**
//   * Convert a java.util.HashMap to a sys::Map with the specified map type.
//   */
//  public static Map toFan(HashMap map, Type type)
//  {
//    return new Map((MapType)type, map);
//  }
//
//  /**
//   * Convert a sys::Map to a java.util.HashMap.  If the fan
//   ** map is not read/write, then ReadonlyErr is thrown.
//   */
//  public static HashMap toJava(Map map)
//  {
//    return map.toJava();
//  }


}