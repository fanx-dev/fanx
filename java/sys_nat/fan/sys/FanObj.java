//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2 Dec 05  Brian Frank  Creation
//
package fan.sys;

import java.lang.reflect.Modifier;

import fanx.main.*;
import fanx.util.*;

/**
 * FanObj is the root class of all classes in Fantom - it is the class
 * representation of Obj.
 */
public class FanObj extends IObj {

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
		return (int) compare(obj);
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
		if (self instanceof FanObj)
			return ((FanObj) self).trap(name, (List) null);
		else
			return doTrap(self, name, null, typeof(self));
	}

	public static Object trap(Object self, String name, List args) {
		if (self instanceof FanObj)
			return ((FanObj) self).trap(name, args);
		else
			return doTrap(self, name, args, typeof(self));
	}

	public Object trap(String name) {
		return doTrap(this, name, null, typeof());
	}

	public Object trap(String name, List args) {
		return doTrap(this, name, args, typeof());
	}
	
	private static Object invokeMethod(java.lang.reflect.Method m, Object obj, List args, Type type) {
		//Fan.Int.and(a, b)
		if ((m.getModifiers() & Modifier.STATIC) !=0 && FanUtil.specialJavaImpl(type.podName(), type.name())) {
			args.insert(0, obj);
			return doInvokeMethod(m, null, args);
		}
		return doInvokeMethod(m, obj, args);
	}
	
	private static Object doInvokeMethod(java.lang.reflect.Method m, Object obj, List args) {
		try {
			
			Object result = null;
			if (args == null) {
				result = m.invoke(obj);
				return result;
			}
			
			int argc = (int)args.size();
			switch (argc) {
			case 0:
				result = m.invoke(obj);
				break;
			case 1:
				result = m.invoke(obj, args.get(0));
				break;
			case 2:
				result = m.invoke(obj, args.get(0), args.get(1));
				break;
			case 3:
				result = m.invoke(obj, args.get(0), args.get(1), args.get(2));
				break;
			case 4:
				result = m.invoke(obj, args.get(0), args.get(1), args.get(2), args.get(3));
				break;
			case 5:
				result = m.invoke(obj, args.get(0), args.get(1), args.get(2), args.get(3), args.get(4));
				break;
			case 6:
				result = m.invoke(obj, args.get(0), args.get(1), args.get(2), args.get(3), args.get(4), args.get(5));
				break;
			case 7:
				result = m.invoke(obj, args.get(0), args.get(1), args.get(2), args.get(3), args.get(4), args.get(5),
						args.get(6));
				break;
			case 8:
				result = m.invoke(obj, args.get(0), args.get(1), args.get(2), args.get(3), args.get(4), args.get(5),
						args.get(6), args.get(7));
				break;
			default:
				throw ArgErr.make("too many args:" + m + "," + args);
			}

			return result;
			
		} catch (Throwable e) {
			throw Err.make(e);
		}
	}

	static Object doTrap(Object self, String name, List args, Type type) {
		if (type.jslots == null) {
			java.util.Map<String, java.util.List<Object>> jslots = new java.util.HashMap<String, java.util.List<Object>>();
			Class<?> clz = type.getJavaClass();
			java.lang.reflect.Method[] ms = clz.getMethods();
			for (java.lang.reflect.Method m : ms) {
				java.util.List<Object> ml = jslots.get(m.getName());
				if (ml == null) {
					ml = new java.util.ArrayList<Object>();
					jslots.put(m.getName(), ml);
				}
				ml.add(m);
			}
			ms = clz.getDeclaredMethods();
			for (java.lang.reflect.Method m : ms) {
				java.util.List<Object> ml = jslots.get(m.getName());
				if (ml == null) {
					ml = new java.util.ArrayList<Object>();
					jslots.put(m.getName(), ml);
				} else {
					if (ml.contains(m)) {
						continue;
					}
				}
				m.setAccessible(true);
				ml.add(m);
			}
			java.lang.reflect.Field[] fs = clz.getFields();
			for (java.lang.reflect.Field m : fs) {
				java.util.List<Object> ml = jslots.get(m.getName());
				if (ml == null) {
					ml = new java.util.ArrayList<Object>();
					jslots.put(m.getName(), ml);
					ml.add(m);
				}
			}
			fs = clz.getDeclaredFields();
			for (java.lang.reflect.Field m : fs) {
				java.util.List<Object> ml = jslots.get(m.getName());
				if (ml == null) {
					ml = new java.util.ArrayList<Object>();
					jslots.put(m.getName(), ml);
					m.setAccessible(true);
					ml.add(m);
				}
			}
			type.jslots = jslots;
		}

		java.util.List<Object> ml = type.jslots.get(name);
		if (ml == null || ml.size() == 0) {
			throw UnknownSlotErr.make(type.qname() + "." + name);
		}

		if (ml.size() == 1) {
			Object slot = ml.get(0);
			if (slot instanceof java.lang.reflect.Method) {
				java.lang.reflect.Method m = (java.lang.reflect.Method) slot;
				return invokeMethod(m, self, args, type);
			}
			else if (slot instanceof java.lang.reflect.Field) {
				java.lang.reflect.Field field = (java.lang.reflect.Field)slot;
				if (args == null || args.size() == 0) {
					try {
						return field.get(self);
					} catch (IllegalArgumentException | IllegalAccessException e) {
						throw Err.make(e);
					}
				}
				else if (args.size() == 1) {
					try {
						field.set(self, args.get(0));
						return null;
					} catch (IllegalArgumentException | IllegalAccessException e) {
						throw Err.make(e);
					}
				}
				else {
					throw ArgErr.make("Invalid number of args to get or set field '" +name + "'");
				}
			}
		}
		else {
			int argc = args == null ? 0 : (int)args.size();
			for (Object slot : ml) {
				java.lang.reflect.Method m = (java.lang.reflect.Method) slot;
				int paramSize = m.getParameterTypes().length;
				if (paramSize == argc) {
					return invokeMethod(m, self, args, type);
				}
			}
			throw ArgErr.make("Invalid number of args to call method '" +name + "'");
		}
		
		// Slot slot = type.slot(name, true);
		//
		// if (slot instanceof Method)
		// {
		// Method m = (Method)slot;
		// return m.func.callOn(self, args);
		// }
		// else
		// {
		// // handle FFI field overloaded with a method
		// Field f = (Field)slot;
		// if (f.overload != null)
		// return f.overload.func.callOn(self, args);
		//
		// // zero args -> getter
		// int argSize = (args == null) ? 0 : args.sz();
		// if (argSize == 0)
		// {
		// return f.get(self);
		// }
		//
		// // one arg -> setter
		// if (argSize == 1)
		// {
		// Object val = args.get(0);
		// f.set(self, val);
		// return val;
		// }
		//
		// throw ArgErr.make("Invalid number of args to get or set field '" +
		// name + "'");
		// }
		return null;
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

}