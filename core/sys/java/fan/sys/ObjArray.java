package fan.sys;

import java.lang.reflect.Array;

import fanx.main.*;

public class ObjArray extends FanObj {
	private Object[] array;
	private Type of;
	
	public ObjArray(Object[] a) {
		array = a;
	}
	
	public ObjArray fromJava(Type of, Object[] a) {
		return new ObjArray(a);
	}
	
	public Object toJava(Type of) {
	    return toJava(of.getJavaActualClass(), array.length);
	}
	
	public Object toJava(Class of, int length) {
		// short circuit if values is already correct array type
	    if (length == array.length && of == array.getClass().getComponentType())
	      return array;
	    
	    // make a safe copy of correct length and type
	    Object[] r = (Object[]) Array.newInstance(of, length);
	    System.arraycopy(array, 0, r, 0, Math.min(length, array.length));
	    return r;
	}
	
	public Object raw() { return array; }
	
	public static ObjArray make(long size, Type of) {
		Object[] array;
		if (of != null) {
		    Class<?> jclz = of.getJavaActualClass();
		    array = (Object[])Array.newInstance(jclz, (int) size);
		} else {
			array = new Object[(int)size];
		}
	    ObjArray self = new ObjArray(array);
	    self.of = of;
	    return self;
	}

	public Object get(long pos) {
		return array[(int)pos];
	}

	public void set(long pos, Object val) {
		array[(int)pos] = val;
	}

	public long size() {
		return array.length;
	}

	public ObjArray realloc(long newSize) {
		if (array.length == newSize) return this;
		ObjArray na = ObjArray.make(newSize, of);
		int len = array.length > na.array.length ? na.array.length : array.length;
		System.arraycopy(array, 0, na.array, 0, len);
		return na;
	}
	
	public ObjArray fill(Object val, long times) {
		int t = (int) times;
		for (int i = 0; i < t; ++i) {
			set(i, val);
		}
		return this;
	}

	public ObjArray copyFrom(ObjArray that, long thatOffset, long thisOffset, long length) {
		System.arraycopy(that.array, (int)thatOffset, array, (int)thisOffset, (int)length);
		return this;
	}

	public final Type typeof() { 
		if (type == null) type = Sys.findType("sys::ObjArray");
		return type;
	}
	private static Type type;
}
