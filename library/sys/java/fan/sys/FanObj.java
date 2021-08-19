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
public class FanObj extends IObj implements Comparable {

	//////////////////////////////////////////////////////////////////////////
	// Java
	//////////////////////////////////////////////////////////////////////////

	public int hashCode() {
		long hash = hash();
		return (int) (hash ^ (hash >>> 32));
	}

	public final String toString() {
		return toStr();
	}

	//////////////////////////////////////////////////////////////////////////
	// Identity
	//////////////////////////////////////////////////////////////////////////

	public static boolean equals(Object self, Object x) {
		return self.equals(x);
	}

	public static long compare(Object self, Object x) {
		if (self instanceof FanObj)
			return ((FanObj) self).compare(x);
		else if (self instanceof Comparable)
			return ((Comparable) self).compareTo(x);
		else
			return FanStr.compare(toStr(self), toStr(x));
	}

	public long compare(Object obj) {
		return FanStr.compare(toStr(), toStr(obj));
	}

	public int compareTo(Object obj) {
		long r = compare(obj);
		if (r > 0) return 1;
		if (r < 0) return -1;
		return 0;
	}

	public static long hash(Object self) {
		if (self instanceof FanObj)
			return ((FanObj) self).hash();
		else
			return self.hashCode();
	}

	public long hash() {
		return super.hashCode();
	}

	public static String toStr(Object self) {
		if (self instanceof FanObj)
			return ((FanObj) self).toStr();
		else if (self instanceof Err)
			return ((Err) self).toStr();
		else if (self.getClass() == java.lang.Double.class)
			return FanFloat.toStr(((java.lang.Double) self).doubleValue());
		else
			return self.toString();
	}

	public String toStr() {
		return super.toString();
	}

	public static boolean isImmutable(Object self) {
		if (self instanceof FanObj)
			return ((FanObj) self).isImmutable();
		else if (self == null)
			return true;
		else if (self instanceof Err)
			return true;
		else
			return FanUtil.isJavaImmutable(self.getClass());
	}

	public boolean isImmutable() {
		try {
			return typeof().isConst();
		} catch (NullPointerException e) {
			// there are cases where accessing the type in a static initializer
			// can happen before the type is configured; since static init
			// problems
			// are tricky to debug just make sure we dump some diagnostics
			Err err = Err.make("Calling Obj.isImmutable in static initializers before type are available");
			err.trace();
			throw err;
		}
	}

	public static Object toImmutable(Object self) {
		if (self == null)
			return null;
		if (isImmutable(self)) return self;
		
		if (self instanceof FanObj)
			return ((FanObj) self).toImmutable();
		else if (self instanceof Err)
			return self;
		else if (FanUtil.isJavaImmutable(self.getClass()))
			return self;
		throw NotImmutableErr.make(self.getClass().getName());
	}

	public Object toImmutable() {
		if (typeof().isConst())
			return this;
		// throw NotImmutableErr.make(this.getClass().toString());
		throw NotImmutableErr.make(typeof().toString());
	}

	public static Type typeof(Object self) {
		if (self instanceof FanObj)
			return ((FanObj) self).typeof();
		else if (self instanceof Err)
			return ((Err) self).typeof();
		else
			return FanUtil.toFanType(self.getClass(), true);
	}

	public final static Type type = Sys.findType("sys::Obj");

	public Type typeof() {
		return type;
	}

	public static Object with(Object self, Func f) {
		if (self instanceof FanObj) {
			return ((FanObj) self).with(f);
		} else {
			f.call(self);
			return self;
		}
	}

	public Object with(Func f) {
		f.call(this);
		return this;
	}

	public static Object trap(Object self, String name) {
		return trap(self, name, null);
	}

	public static Object trap(Object self, String name, List args) {
		if (self instanceof FanObj)
			return ((FanObj) self).trap(name, args);
		else
			return doTrap(self, name, args, typeof(self));
	}

	public Object trap(String name) {
		return trap(this, name, null);
	}

	public Object trap(String name, List args) {
		return doTrap(this, name, args, typeof());
	}
	
	public static interface InvokeTrapper {
		public abstract Object doTrap(Object self, String name, List args, Type type);
	}
	
	public static InvokeTrapper invokeTrapper = null;
	static {
		try {
			ClassLoader loader = Sys.findPod("std").podClassLoader;
			invokeTrapper = (InvokeTrapper)loader.loadClass("fan.std.ReflectInvoker").newInstance();
		} catch (Throwable e) {
			System.err.println("install InvokeTrapper fail");
		}
	}

	public static Object doTrap(Object self, String name, List args, Type type) {
		return invokeTrapper.doTrap(self, name, args, type);
	}

	// Remap all java.lang.Objects as statics since we emit to FanObj
	public static String toString(Object o) {
		return o.toString();
	}

	public static Class getClass(Object o) {
		return o.getClass();
	}

	public static int hashCode(Object o) {
		return o.hashCode();
	}

	public static void notify(Object o) {
		o.notify();
	}

	public static void notifyAll(Object o) {
		o.notifyAll();
	}

	public static void wait(Object o) throws InterruptedException {
		o.wait();
	}

	public static void wait(Object o, long t) throws InterruptedException {
		o.wait(t);
	}

	public static void wait(Object o, long t, int n) throws InterruptedException {
		o.wait(t, n);
	}

	//////////////////////////////////////////////////////////////////////////
	// Utils
	//////////////////////////////////////////////////////////////////////////

	public static void echo() {
		echo("");
	}

	public static void echo(Object obj) {
		if (obj == null)
			obj = "null";
		String str = toStr(obj);
		System.out.println(str);
	}
	
	public static void assert_(boolean condition) {
		assert_(condition, "");
	}
	
	public static void assert_(boolean condition, String msg) {
		if (!condition) throw AssertErr.make(msg);
	}

}