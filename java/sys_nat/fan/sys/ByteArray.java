package fan.sys;

import fanx.main.Sys;
import fanx.main.Type;

public class ByteArray {
	byte[] array;
	
	public ByteArray(long size) {
		array = new byte[(int)size];
	}
	
	public ByteArray(byte[] bs) {
		array = bs;
	}
	
	public static ByteArray make(long size) {
		return new ByteArray(size);
	}
	
	public byte[] array() {
		return array;
	}
	
	public Object raw() {
		return array;
	}

	public long get(long pos) {
		byte b = array[(int)pos];
		return b & 0xFF;
	}

	public void set(long pos, long val) {
		array[(int)pos] = (byte)val;
	}

	public long size() {
		return array.length;
	}

	public boolean realloc(long newSize) {
		if (array.length == newSize) return true;
		byte[] na = new byte[(int)newSize];
		int len = array.length > na.length ? na.length : array.length;
		System.arraycopy(array, 0, na, 0, len);
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
