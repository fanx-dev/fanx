package fan.sys;

import java.util.Arrays;

import fanx.main.*;

public class ObjArray extends FanObj {
	Object[] array;
	
	public ObjArray(long size) {
		array = new Object[(int)size];
	}
	
	public static ObjArray make(long size) {
		return new ObjArray(size);
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

	public boolean realloc(long newSize) {
		Object[] na = new Object[(int)newSize];
		int len = array.length > na.length ? na.length : array.length;
		System.arraycopy(array, 0, na, 0, len);
		array = na;
		return true;
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
