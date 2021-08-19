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
import java.lang.reflect.Array;
import java.util.Enumeration;
import java.util.Iterator;

import fan.std.*;
import fan.sys.*;
import fanx.main.*;
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

  /**
   * Convert java.lang.Class to sys::Type.
   */
  public static Type toFan(Class cls)
  {
    return FanUtil.toFanType(cls, true);
  }

  /**
   * Convert sys::Type to java.lang.Class.  You
   * can also access this functionality using the
   * trap operator "->toClass" on Type.
   */
  public static Class toJava(Type type)
  {
    return type.getJavaActualClass();
  }

////////////////////////////////////////////////////////////////////////////
//// Exceptions
////////////////////////////////////////////////////////////////////////////

  /**
   * Given a Java exception instance translate to a Fantom exception.
   * If the exception maps to a built-in Fantom exception then the
   * native Fantom type is used - for example NullPointerException will
   * return a NullErr.  Otherwise the Java exception is wrapped
   * as a generic Err instance.
   */
  public static Err toFan(Throwable ex)
  {
    return Err.make(ex);
  }

  /**
   * Given a Fantom exception instance, get the underlying Java exception.
   */
  public static Throwable toJava(Err err)
  {
    return err.toJava();
  }

////////////////////////////////////////////////////////////////////////////
//// IO
////////////////////////////////////////////////////////////////////////////

  /**
   * Convert from java.io.InputStream to sys::InStream
   * with default buffer size of 4096.
   */
  public static InStream toFan(InputStream in)
  {
    return toFan(in, 4096);
  }

  /**
   * Convert from java.io.InputStream to sys::InStream
   * with the given buffer size.
   */
  public static InStream toFan(InputStream in, long bufSize)
  {
    return SysInStreamPeer.fromJava(in, bufSize);
  }

  /**
   * Convert from java.io.OutputStream to sys::OutStream
   * with default buffer size of 4096.
   */
  public static OutStream toFan(OutputStream out)
  {
    return toFan(out, 4096);
  }

  /**
   * Convert from java.io.OutputStream to sys::OutStream
   * with the given buffer size.
   */
  public static OutStream toFan(OutputStream out, long bufSize)
  {
    return SysOutStreamPeer.fromJava(out, bufSize);
  }

  /**
   * Convert from java.io.File to sys::File.
   */
  public static File toFan(java.io.File file)
  {
    return LocalFile.fromJava(file);
  }
  
  /**
   * Convert from java.nio.file.Path to sys::File.
   */
  public static File toFan(java.nio.file.Path path)
  {
    return new PathFile(path);
  }

  /**
   * Convert from java.nio.ByteBuffer to sys::Buf.
   */
  public static Buf toFan(java.nio.ByteBuffer buf)
  {
    return NioBufPeer.fromJava(buf);
  }

  /**
   * Convert from sys::Buf to to java.nio.ByteBuffer
   *
   * Return a bytebuffer that shares the same storage
   * as this byte buffer, but independent pos and size.
   *
   * Changes made to the resulting ByteBuffer will affect
   * this ByteBuffer's content but not its pos or size.
   *
   * The ByteBuffer will be created with position equal
   * to this buf's pos and limit equal to this buf's limit,
   * and no mark set.
   *
   * Throws UnsupportedErr if this Buf doesn't use an
   ** underlying storage system supported by ByteBuffer.
   *
   * @see java.nio.ByteBuffer#duplicate
   * @see java.nio.ByteBuffer#wrap(byte[], int, int)
   */
  public static java.nio.ByteBuffer toJava(Buf buf)
  {
	  if (buf instanceof MemBuf) {
		  byte[] b = ((MemBuf)buf).buf;
		  return java.nio.ByteBuffer.wrap(b, (int)buf.pos(), (int)(buf.size()-buf.pos()));
	  }
	  else if (buf instanceof NioBuf) {
		  NioBufPeer peer = ((NioBuf)buf).peer;
		  peer.toByteBuffer();
	  }
	  throw UnsupportedErr.make(buf.typeof()+".toByteBuffer");
  }

  /**
   * Convert from sys::InStream to java.io.InputStream.
   */
  public static InputStream toJava(InStream in)
  {
    return SysInStreamPeer.toJava(in);
  }

  /**
   * Convert from sys::OutStream to java.io.OutputStream.
   */
  public static OutputStream toJava(OutStream out)
  {
    return SysOutStreamPeer.toJava(out);
  }

  /**
   * Convert from sys::File to java.io.File.  Raise
   * cast exception if not a local file.
   */
  public static java.io.File toJava(File file)
  {
    return LocalFile.toJava(file);
  }

////////////////////////////////////////////////////////////////////////////
//// Collections
////////////////////////////////////////////////////////////////////////////

  /**
   * Convert a java.util.List to a sys::List with a type of Obj?[].
   */
  public static List toFan(java.util.List list)
  {
    return toFan(list, FanObj.type.toNullable());
  }

  /**
   * Convert a java.util.List to a sys::List of the specified type.
   */
  public static List toFan(java.util.List list, Type of)
  {
	  List flist = List.make(list.size());
	  Iterator e = list.iterator();
	  while (e.hasNext()) flist.add(e.next());
	  return flist;
  }

  /**
   * Convert a java.util.Enumeration to a sys::List with a type of Obj?[].
   */
  public static List toFan(Enumeration e)
  {
    return toFan(e, FanObj.type.toNullable());
  }

  /**
   * Convert a java.util.Enumeration to a sys::List of the specified type.
   */
  public static List toFan(Enumeration e, Type of)
  {
    List list = List.make(4);
    while (e.hasMoreElements()) list.add(e.nextElement());
    return list;
  }

  /**
   * Convert a java.util.Iterator to a sys::List with a type of Obj?[].
   */
  public static List toFan(Iterator i)
  {
    return toFan(i, FanObj.type.toNullable());
  }
  
  /**
   * Convert a java.util.stream.Stream to a sys::List of the specified type.
   */
  public static List toFan(java.util.stream.Stream s, Type of)
  {
    return toFan(s.iterator(), of);
  }

  /**
   * Convert a java.util.Iterator to a sys::List of the specified type.
   */
  public static List toFan(Iterator i, Type of)
  {
    List list = List.make(4);
    while (i.hasNext()) list.add(i.next());
    return list;
  }

  /**
   * Convert a java.util.HashMap to a sys::Map with a type of Obj:Obj?.
   */
  public static Map toFan(java.util.HashMap<?,?> map)
  {
	  Map fmap = Map.make(map.size());
	  for (java.util.Map.Entry entry : map.entrySet()) {
		  fmap.set(entry.getKey(), entry.getValue());
	  }
	  return fmap;
  }
  
  public static java.util.List toJava(fan.sys.List list) {
	  java.util.List objs = new java.util.ArrayList((int)list.size());
	  for (int i=0; i<list.size(); ++i) {
		  objs.add(list.get(i));
	  }
	  return objs;
  }

//  /**
//   * Convert a java.util.HashMap to a sys::Map with the specified map type.
//   */
//  public static Map toFan(java.util.HashMap<?,?> map, Type type)
//  {
//    return new Map((MapType)type, map);
//  }

  /**
   * Convert a sys::Map to a java.util.HashMap.  If the fan
   ** map is not read/write, then ReadonlyErr is thrown.
   */
  public static java.util.HashMap toJava(Map map)
  {
	  final java.util.HashMap jmap = new java.util.HashMap();
	  map.each(new Func(){
//		@Override
//		public long arity() {
//			return 2;
//		}
		@Override
		public Object call(Object v, Object k) {
			jmap.put(k, v);
			return null;
		}
	  });
	  return jmap;
  }

////////////////////////////////////////////////////////////////////////////
////Array
////////////////////////////////////////////////////////////////////////////
  
//  public static byte[] toJava(byte[] a) {
//	  return a;
//  }
//  
//  public static byte[] toFan(byte[] a) {
//	  return a;
//  }
  
  public static byte[] toJavaByteArray(fan.std.MemBuf a) {
	  return a.buf;
  }
  
  public static fan.std.MemBuf toFanBuf(byte[] a) {
	  return fan.std.MemBuf.makeBuf(a);
  }
  
  public static fan.sys.List toFanList(Type of, Object[] objs) {
	  if (objs == null) return null;
	  List list = List.make(objs.length);
	  for (Object o : objs) {
		  list.add(o);
	  }
	  return list;
  }
  
  public static Object[] toJavaArray(fan.sys.List list, Class clz) {
	  if (list == null) return null;
	  
//	  if (list instanceof fan.sys.ArrayList) {
//		  fan.sys.ArrayList al = (fan.sys.ArrayList)list;
//		  Object[] oa = (Object[]) Reflection.getField(al, "array");
////		  JavaType jt = JavaType.loadJavaType(clz);
//		  //return (Object[])(oa.toJava(clz, (int)list.size()));
//		  return oa;
//	  }
	  
	  Object[] objs = (Object[]) Array.newInstance(clz, (int)list.size());
	  for (int i=0; i<list.size(); ++i) {
		  objs[i] = list.get(i);
	  }
	  return objs;
  }
//  
//  public static fan.sys.ObjArray toFan(Object[] objs) {
//	  ObjArray list = ObjArray.make(objs.length, FanObj.type);
//	  for (int i=0; i<objs.length; ++i) {
//		  list.set(i, objs[i]);
//	  }
//	  return list;
//  }
//  
//  public static Object[] toJava(fan.sys.ObjArray list) {
//	  Object[] objs = new Object[(int)list.size()];
//	  for (int i=0; i<list.size(); ++i) {
//		  objs[i] = list.get(i);
//	  }
//	  return objs;
//  }
}