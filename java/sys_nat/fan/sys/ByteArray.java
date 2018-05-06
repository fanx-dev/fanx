package fan.sys;

import fanx.main.Sys;
import fanx.main.Type;

public class ByteArray {
	byte[] array;
	
	public ByteArray(long size) {
		array = new byte[(int)size];
	}
	
	public static ByteArray make(long size) {
		return new ByteArray(size);
	}

	public Object get(long pos) {
		return array[(int)pos];
	}

	public void set(long pos, long val) {
		array[(int)pos] = (byte)val;
	}

	public long size() {
		return array.length;
	}

	public boolean realloc(long newSize) {
		byte[] na = new byte[(int)newSize];
		System.arraycopy(array, 0, na, 0, na.length);
		array = na;
		return true;
	}

	public ByteArray copyFrom(ObjArray that, long thatOffset, long thisOffset, long length) {
		System.arraycopy(that.array, (int)thatOffset, array, (int)thisOffset, (int)length);
		return this;
	}
	
	public final Type typeof() { 
		if (type == null) type = Sys.findType("sys::ByteArray");
		return type;
	}
	private static Type type;
	
	public ByteArray fill(long val, long times) {
		int t = (int)times;
		byte b = (byte)val;
		for (int i=0; i<t; ++i) {
			array[i] = b;
		}
		return this;
	}

}
