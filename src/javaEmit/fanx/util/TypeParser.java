//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   30 Jan 06  Brian Frank  Creation
//
package fanx.util;

import java.util.*;

/**
 * TypeParser is used to parser formal type signatures which are
 * used in Sys.type() and in fcode for typeRefs.def.  Signatures
 * are formated as (with arbitrary nesting):
 *
 *   x::N
 *   x::V[]
 *   x::V[x::K]
 *   |x::A, ... -> x::R|
 */
public class TypeParser
{
//
////////////////////////////////////////////////////////////////////////////
//// Factory
////////////////////////////////////////////////////////////////////////////
//
//  /**
//   * Parse the signature into a loaded type.
//   */
//  public static Type load(String sig, boolean checked, Pod loadingPod)
//  {
//    // if last character is ?, then parse a nullable
//    int len = sig.length();
//    int last = len > 1 ? sig.charAt(len-1) : 0;
//    if (last == '?')
//      return load(sig.substring(0, len-1), checked, loadingPod).toNullable();
//
//    // if the last character isn't ] or |, then this a non-generic
//    // type and we don't even need to allocate a parser
//    if (last != ']' && last != '|' && last != '>')
//    {
//      String podName, typeName;
//      try
//      {
//        int colon = sig.indexOf("::");
//        podName  = sig.substring(0, colon);
//        typeName = sig.substring(colon+2);
//        if (podName.length() == 0 || typeName.length() == 0) throw new Exception();
//      }
//      catch (Exception e)
//      {
//        throw ArgErr.make("Invalid type signature '" + sig + "', use <pod>::<type>");
//      }
//
//      // if podName starts with [java] this is a direct Java type
//      if (podName.charAt(0) == '[')
//        return Env.cur().loadJavaType(loadingPod, podName, typeName);
//
//      // if the type is from the pod being loaded then return to the pod
//      if (loadingPod != null && podName.equals(loadingPod.name()))
//        return loadingPod.type(typeName, checked);
//
//      // do a straight lookup
//      return find(podName, typeName, checked);
//    }
//
//    // we got our work cut out for us - create parser
//    try
//    {
//      return new TypeParser(sig, checked, loadingPod).loadTop();
//    }
//    catch (Err e)
//    {
//      throw e;
//    }
//    catch (Exception e)
//    {
//      throw err(sig);
//    }
//  }
//
//  public static Type find(String podName, String typeName, boolean checked)
//  {
//    Pod pod = Pod.find(podName, checked);
//    if (pod == null) return null;
//    return pod.type(typeName, checked);
//  }
//
////////////////////////////////////////////////////////////////////////////
//// Constructor
////////////////////////////////////////////////////////////////////////////
//
//  private TypeParser(String sig, boolean checked, Pod loadingPod)
//  {
//    this.sig        = sig;
//    this.len        = sig.length();
//    this.pos        = 0;
//    this.cur        = sig.charAt(pos);
//    this.peek       = sig.charAt(pos+1);
//    this.checked    = checked;
//    this.loadingPod = loadingPod;
//  }
//
////////////////////////////////////////////////////////////////////////////
//// Parse
////////////////////////////////////////////////////////////////////////////
//
//  private Type loadTop()
//  {
//    Type type = load();
//    if (cur != 0) throw err();
//    return type;
//  }
//
//  private Type load()
//  {
//    Type type;
//
//    // |...| is func
//    if (cur == '|')
//      type = loadFunc();
//
//    // [ is either [ffi]xxx or [K:V] map
//    else if (cur == '[')
//    {
//      boolean ffi = true;
//      for (int i=pos+1; i<len; ++i)
//      {
//        int ch = sig.charAt(i);
//        if (isIdChar(ch)) continue;
//        ffi = (ch == ']');
//        break;
//      }
//
//      if (ffi)
//        type = loadFFI();
//      else
//        type = loadMap();
//    }
//
//    // otherwise must be basic[]
//    else
//      type = loadBasic();
//
//    // nullable
//    if (cur == '?')
//    {
//      consume('?');
//      type = type.toNullable();
//    }
//
//    if (cur == '<') {
//      type = loadGeneric(type);
//    }
//
//    // anything left must be []
//    while (cur == '[')
//    {
//      consume('[');
//      consume(']');
//      type = type.toListOf();
//      if (cur == '?')
//      {
//        consume('?');
//        type = type.toNullable();
//      }
//    }
//
//    // nullable
//    if (cur == '?')
//    {
//      consume('?');
//      type = type.toNullable();
//    }
//
//    return type;
//  }
//
//  private Type loadGeneric(Type type) {
//    consume('<');
//    ArrayList params = new ArrayList();
//    while (true) {
//      if (cur == '>') {
//        consume('>');
//        break;
//      }
//      else if (cur == ',') {
//        consume(',');
//        continue;
//      }
//      params.add(load());
//    }
//    //return ParameterizedType(base, params);
//    return type;
//  }
//
//  private Type loadMap()
//  {
//    consume('[');
//    Type key = load();
//    consume(':');
//    Type val = load();
//    consume(']');
//    return new MapType(key, val);
//  }
//
//  private Type loadFunc()
//  {
//    consume('|');
//    ArrayList params = new ArrayList(8);
//    if (cur != '-')
//    {
//      while (true)
//      {
//        params.add(load());
//        if (cur == '-') break;
//        consume(',');
//      }
//    }
//    consume('-');
//    consume('>');
//    Type ret = load();
//    consume('|');
//
//    return new FuncType((Type[])params.toArray(new Type[params.size()]), ret);
//  }
//
//  private Type loadFFI()
//  {
//    // [java]foo.bar.foo
//    int start = pos;
//    while (cur != ':' || peek != ':') consume();
//    String podName = sig.substring(start, pos);
//
//    consume(':');
//    consume(':');
//
//    // Baz or [Baz
//    start = pos;
//    while (cur == '[') consume();
//    while (isIdChar(cur)) consume();
//    String typeName = sig.substring(start, pos);
//
//    return Env.cur().loadJavaType(loadingPod, podName, typeName);
//  }
//
//  private Type loadBasic()
//  {
//    String podName = consumeId();
//    consume(':');
//    consume(':');
//    String typeName = consumeId();
//
//    // check for generic parameter like sys::V
//    if (typeName.length() == 1 && podName.equals("sys"))
//    {
//      Type type = Sys.genericParamType(typeName);
//      if (type != null) return type;
//    }
//
//    if (loadingPod != null && podName.equals(loadingPod.name()))
//      return loadingPod.type(typeName, checked);
//    else
//      return find(podName, typeName, checked);
//  }
//
////////////////////////////////////////////////////////////////////////////
//// Utils
////////////////////////////////////////////////////////////////////////////
//
//  private String consumeId()
//  {
//    int start = pos;
//    while (isIdChar(cur)) consume();
//    return sig.substring(start, pos);
//  }
//
//  public static boolean isIdChar(int ch)
//  {
//    return FanInt.isAlphaNum(ch) || ch == '_';
//  }
//
//  private void consume(int expected)
//  {
//    if (cur != expected) throw err();
//    consume();
//  }
//
//  private void consume()
//  {
//    if (pos > len + 10) throw new RuntimeException("Unexpected end of string");
//    cur = peek;
//    pos++;
//    peek = pos+1 < len ? sig.charAt(pos+1) : 0;
//  }
//
//  private Err err() { return err(sig); }
//  private static Err err(String sig)
//  {
//    return ArgErr.make("Invalid type signature '" + sig + "'");
//  }
//
////////////////////////////////////////////////////////////////////////////
//// Fields
////////////////////////////////////////////////////////////////////////////
//
//  private String sig;          // signature being parsed
//  private int len;             // length of sig
//  private int pos;             // index of cur in sig
//  private int cur;             // cur character; sig[pos]
//  private int peek;            // next character; sig[pos+1]
//  private boolean checked;     // pass thru checked flag
//  private Pod loadingPod;      // used to map types within a loading pod

}