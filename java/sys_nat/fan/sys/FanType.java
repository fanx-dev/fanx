//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2 Dec 05  Brian Frank  Creation
//
package fan.sys;

import java.io.*;
import java.lang.reflect.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map.Entry;
import fanx.fcode.*;
import fanx.fcode.FAttrs.FFacet;
import fanx.main.*;
import fanx.main.Type;
import fanx.emit.*;
import fanx.util.*;

/**
 * Type models sys::Type.  Implementation classes are:
 *   - ClassType
 *   - GenericType (ListType, MapType, FuncType)
 *   - NullableType
 */
public abstract class FanType
{

//////////////////////////////////////////////////////////////////////////
// Management
//////////////////////////////////////////////////////////////////////////

  public static Type of(Object obj)
  {
    if (obj instanceof FanObj)
      return ((FanObj)obj).typeof();
    else
      return FanUtil.toFanType(obj.getClass(), true);
  }

  public static Type find(String sig) { return find(sig, true); }
  public static Type find(String sig, boolean checked) { return Sys.findType(sig, checked); }

//////////////////////////////////////////////////////////////////////////
// Naming
//////////////////////////////////////////////////////////////////////////

  public static Type type = Sys.findType("sys::Type");
  public static Type typeof(Type self) { return type; }

  public static String podName(Type self) { return self.podName(); }
//  public static Pod pod();
  public static String name(Type self) { return self.name(); }
  public static String qname(Type self) { return self.qname(); }
  public static String signature(Type self) { return self.signature(); }

//////////////////////////////////////////////////////////////////////////
// Flags
//////////////////////////////////////////////////////////////////////////

  public static boolean isAbstract(Type self)  { return (self.flags() & FConst.Abstract) != 0; }
  public static boolean isClass(Type self)     { return (self.flags() & (FConst.Enum|FConst.Mixin)) == 0; }
  public static boolean isConst(Type self)     { return (self.flags() & FConst.Const) != 0; }
  public static boolean isEnum(Type self)      { return (self.flags() & FConst.Enum) != 0; }
  public static boolean isFacet(Type self)     { return (self.flags() & FConst.Facet) != 0; }
  public static boolean isFinal(Type self)     { return (self.flags() & FConst.Final) != 0; }
  public static boolean isInternal(Type self)  { return (self.flags() & FConst.Internal) != 0; }
  public static boolean isMixin(Type self)     { return (self.flags() & FConst.Mixin) != 0; }
  public static boolean isNative(Type self)    { return (self.flags() & FConst.Native) != 0; }
  public static boolean isPublic(Type self)    { return (self.flags() & FConst.Public) != 0; }
  public static boolean isSynthetic(Type self) { return (self.flags() & FConst.Synthetic) != 0; }
  public static long flags(Type self) { return self.flags(); }

  public static Object trap(Type self, String name, List args)
  {
    // private undocumented access
    if (name.equals("flags")) return Long.valueOf(flags(self));
    if (name.equals("toClass")) return toClass(self);
//    if (name.equals("lineNumber")) { return Long.valueOf(lineNum); }
//    if (name.equals("sourceFile")) { return sourceFile; }
//    if (name.equals("finish")) { finish(); return self; }
    return FanObj.trap(self, name, args);
  }

//////////////////////////////////////////////////////////////////////////
// Value Types
//////////////////////////////////////////////////////////////////////////

  public boolean isVal(Type self)
  {
    return (self.flags() & FConst.Struct) != 0;
  }

//////////////////////////////////////////////////////////////////////////
// Nullable
//////////////////////////////////////////////////////////////////////////

  public static boolean isNullable(Type self) { return self.isNullable(); }

  public static Type toNonNullable(Type self) { return self.toNonNullable(); }

  public static Type toNullable(Type self) { return self.toNullable(); }

//////////////////////////////////////////////////////////////////////////
// Generics
//////////////////////////////////////////////////////////////////////////

//  /**
//   * A generic type means that one or more of my slots contain signatures
//   * using a generic parameter (such as V or K).  Fantom supports three built-in
//   * generic types: List, Map, and Func.  A generic instance (such as Str[])
//   * is NOT a generic type (all of its generic parameters have been filled in).
//   * User defined generic types are not supported in Fan.
//   */
  public static boolean isGeneric(Type self)
  {
    return self.isGenericType();
  }
//
//  /**
//   * A generic instance is a type which has "instantiated" a generic type
//   * and replaced all the generic parameter types with generic argument
//   * types.  The type Str[] is a generic instance of the generic type
//   * List (V is replaced with Str).  A generic instance always has a signature
//   * which different from the qname.
//   */
//  public boolean isGenericInstance(Type self)
//  {
//    return false;
//  }
//
//  /**
//   * Return if this type is a generic parameter (such as V or K) in a
//   * generic type (List, Map, or Method).  Generic parameters serve
//   * as place holders for the parameterization of the generic type.
//   * Fantom has a predefined set of generic parameters which are always
//   * defined in the sys pod with a one character name.
//   */
//  public boolean isGenericParameter(Type self)
//  {
//    return pod() == Sys.sysPod && name().length() == 1;
//  }
//
//  /*
//   * If this type is a generic parameter (V, L, etc), then return
//   * the actual type used in the Java method.  For example V is Obj,
//   * and L is List.  This is the type we actually use when constructing
//   * a signature for the invoke opcode.
//   */
//  public Type getRawType(Type self)
//  {
//    if (!isGenericParameter()) return this;
//    if (this == Sys.LType) return Sys.ListType;
//    if (this == Sys.MType) return Sys.MapType;
//    if (this instanceof ListType) return Sys.ListType;
//    if (this instanceof MapType)  return Sys.MapType;
//    if (this instanceof FuncType) return Sys.FuncType;
//    return Sys.ObjType;
//  }
//
//  public final boolean isGeneric(Type self)
//  {
//    return isGenericType();
//  }
//
//  public Map params(Type self)
//  {
//    if (noParams == null) noParams = Sys.emptyStrTypeMap;
//    return (Map)noParams;
//  }
//
//  public Type parameterize(Map params)
//  {
//    if (this == Sys.ListType)
//    {
//      Type v = (Type)params.get("V");
//      if (v == null) throw ArgErr.make("List.parameterize - V undefined");
//      return v.toListOf();
//    }
//
//    if (this == Sys.MapType)
//    {
//      Type v = (Type)params.get("V");
//      Type k = (Type)params.get("K");
//      if (v == null) throw ArgErr.make("Map.parameterize - V undefined");
//      if (k == null) throw ArgErr.make("Map.parameterize - K undefined");
//      return new MapType(k, v);
//    }
//
//    if (this == Sys.FuncType)
//    {
//      Type r = (Type)params.get("R");
//      if (r == null) throw ArgErr.make("Map.parameterize - R undefined");
//      ArrayList p = new ArrayList();
//      for (int i='A'; i<='H'; ++i)
//      {
//        Type x = (Type)params.get(FanStr.ascii[i]);
//        if (x == null) break;
//        p.add(x);
//      }
//      return new FuncType((Type[])p.toArray(new Type[p.size()]), r);
//    }
//
//    throw UnsupportedErr.make("not generic: " + this);
//  }
//
  public static synchronized Type toListOf(Type self)
  {
    return emptyList(self).typeof();
  }

  public static final List emptyList(Type self)
  {
    if (self.emptyList == null) self.emptyList = List.make(self, 0).toImmutable();
    return (List)self.emptyList;
  }

////////////////////////////////////////////////////////////////////////////
//// Slots
////////////////////////////////////////////////////////////////////////////
//
//  public abstract List fields();
//  public abstract List methods();
//  public abstract List slots();
//
//  public final Field field(String name) { return field(name, true); }
//  public Field field(String name, boolean checked) { return (Field)slot(name, checked); }
//
//  public final Method method(String name) { return method(name, true); }
//  public Method method(String name, boolean checked) { return (Method)slot(name, checked); }
//
//  public final Slot slot(String name) { return slot(name, true); }
//  public abstract Slot slot(String name, boolean checked);
//
  public static Object make(Type self) { return make(self, null); }
  public static Object make(Type self, List args)
  {
	Err err;
	try {
		return FanObj.doTrap(null, "make", args, self);
	} catch(Throwable e) { err = Err.make(e); }
	
	try {
		return FanObj.doTrap(null, "defVal", args, self);
	} catch(Throwable e) {}

	throw err;
    //throw Err.make("Type missing 'make' or 'defVal' slots: " + self, err);
  }

////////////////////////////////////////////////////////////////////////////
//// Inheritance
////////////////////////////////////////////////////////////////////////////

  public static Type base(Type self) {
	  return self.base();
  }

  public static List mixins(Type self) {
	  List acc = List.make(type, 4);
	  FType ftype = self.ftype();
	  for (int mixin : ftype.mixins) {
		  Type t = Type.refToType(ftype.pod, mixin);
		  acc.add(t);
	  }
	  return acc.trim().ro();
  }

  public static List inheritance(Type self)
  {
	java.util.HashMap<String, Type> map = new java.util.HashMap<String, Type>();
    List acc = List.make(type, 2);

    // add myself
    map.put(self.qname(), self);
    acc.add(self);

    // add my direct inheritance inheritance
    addInheritance(self, acc, map);
    
    return acc.trim().ro();
  }

  private static void addInheritance(Type t, List acc, java.util.HashMap<String, Type> map)
  {
    if (t == null) return;
    Type b = base(t);
    if (b != null) {
    	map.put(b.qname(), b);
        acc.add(b);
        addInheritance(b, acc, map);
    }
    
    List ti = mixins(t);
    for (int i=0; i<ti.size(); ++i)
    {
      Type x = (Type)ti.get(i);
      if (map.get(x.qname()) == null)
      {
        map.put(x.qname(), x);
        acc.add(x);
      }
    }
  }

  public static boolean fits(Type self, Type type) { return self.fits(type); }
//
//  /**
//   * Given a list of objects, compute the most specific type which they all
//   * share,or at worst return sys::Obj?.  This method does not take into
//   * account interfaces, only extends class inheritance.
//   */
//  public static Type common(Object[] objs, int n)
//  {
//    if (objs.length == 0) return Sys.ObjType.toNullable();
//    boolean nullable = false;
//    Type best = null;
//    for (int i=0; i<n; ++i)
//    {
//      Object obj = objs[i];
//      if (obj == null) { nullable = true; continue; }
//      Type t = typeof(obj);
//      if (best == null) { best = t; continue; }
//      while (!t.is(best))
//      {
//        best = best.base();
//        if (best == null) return nullable ? Sys.ObjType.toNullable() : Sys.ObjType;
//      }
//    }
//    if (best == null) best = Sys.ObjType;
//    return nullable ? best.toNullable() : best;
//  }

//////////////////////////////////////////////////////////////////////////
// Facets
//////////////////////////////////////////////////////////////////////////

  public static List facets(Type self) {
	  List list = List.make(Sys.findType("sys::Facet"), 1);
	  FType ftype = self.ftype();
	  if (ftype != null && ftype.attrs.facets != null) {
		for (FFacet facet : ftype.attrs.facets) {
			FTypeRef tr = ftype.pod.typeRef(facet.type);
			//TODO
		}
	  }
	  return list;
  }

  public static Facet facet(Type self, Type t) { return facet(self, t, true); }
  public static Facet facet(Type self, Type t, boolean checked) {
	  FType ftype = self.ftype();
	  if (ftype != null && ftype.attrs.facets != null) {
		for (FFacet facet : ftype.attrs.facets) {
			FTypeRef tr = ftype.pod.typeRef(facet.type);
			if (tr.podName.equals(t.podName()) && tr.typeName.equals(t.name())) {
				//TODO
				return null;
			}
		}
	  }
	  if (checked) throw UnknownFacetErr.make(t.qname());
	  return null;
  }

  public static boolean hasFacet(Type self, Type t) {return facet(self, t, false) != null; }

////////////////////////////////////////////////////////////////////////////
//// Documentation
////////////////////////////////////////////////////////////////////////////

  public static String doc(Type self) {
	  FType ftype = self.ftype();
	  if (ftype == null) return null;
	  return ftype.doc().tyeDoc();
  }

//////////////////////////////////////////////////////////////////////////
// Conversion
//////////////////////////////////////////////////////////////////////////

  public static String toStr(Type self) { return self.signature(); }

//  public String toLocale() { return signature(); }

//  public void encode(ObjEncoder out)
//  {
//    out.w(signature()).w("#");
//  }

//////////////////////////////////////////////////////////////////////////
// Reflection
//////////////////////////////////////////////////////////////////////////

//  protected Type reflect() { return this; }

//  public void finish() {}

  /**
   * Return if this is a JavaType which represents a Java
   * class imported into the Fantom type system via the Java FFI.
   */
  public static boolean isJava(Type self) { return self instanceof JavaType; }

  /**
   * Return if the Fantom Type is represented as a Java class
   * such as sys::Int as java.lang.Long.
   */
//  public abstract boolean javaRepr();

  /**
   * Get the Java class which represents this type.
   */
  public static Class toClass(Type self) {
	  return self.getJavaClass();
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

//  static final boolean Debug = false;
//  static Object noParams;

//  Type listOf;     // cached value of toListOf()
//  List emptyList;  // cached value of emptyList()

}