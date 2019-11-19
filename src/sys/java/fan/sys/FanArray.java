package fan.sys;

import fanx.main.Sys;
import fanx.main.Type;

public class FanArray {
	private static Type type = Sys.findType("sys::Array");
	public static Type typeof(Object a) { return type; }
	
	public static Object make(long size) {
		return new Object[(int)size];
	}
	
	public static long size(Object a) {
//		return ((Object[])a).length;
		return java.lang.reflect.Array.getLength(a);
	}
	
	public static Object get(Object a, long i) {
//		return ((Object[])a)[(int)i];
		return java.lang.reflect.Array.get(a, (int)i);
	}
	
	public static void set(Object a, long i, Object v) {
//		((Object[])a)[(int)i] = v;
		java.lang.reflect.Array.set(a, (int)i, v);
	}
}
