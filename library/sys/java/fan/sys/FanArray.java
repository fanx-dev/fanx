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
		return java.lang.reflect.Array.getLength(a);
	}
	
	public static Object get(Object a, long i) {
		return java.lang.reflect.Array.get(a, (int)i);
	}
	
	public static void set(Object a, long i, Object v) {
		java.lang.reflect.Array.set(a, (int)i, v);
	}

	public static Object realloc(Object self, long newSize) {
		long selfSize = size(self);
		if (selfSize == newSize) return self;
		Object na = java.lang.reflect.Array.newInstance(
				self.getClass().getComponentType(), (int)newSize);
		
		long len = selfSize > newSize ? newSize : selfSize;
		System.arraycopy(self, 0, na, 0, (int)len);
		return na;
	}
	
	public static void fill(Object self, Object val, long times) {
		int t = (int) times;
		for (int i = 0; i < t; ++i) {
			set(val, i, val);
			java.lang.reflect.Array.set(self, i, val);
		}
	}

	public static void arraycopy(Object that, long thatOffset
			, Object desc, long descOffset, long length) {
		System.arraycopy(that, (int)thatOffset, desc, (int)descOffset, (int)length);
	}
}
