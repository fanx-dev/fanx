package fan.sys;

import fanx.main.Sys;
import fanx.main.Type;

public class ByteArray extends FanObj {
	private final byte[] array;
	
	public ByteArray(byte[] bs) {
		array = bs;
	}
	
	public static ByteArray make(long size) {
		return new ByteArray(new byte[(int)size]);
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

	public ByteArray realloc(long newSize) {
		if (array.length == newSize) return this;
		
		ByteArray na = ByteArray.make(newSize);
		int len = array.length > na.array.length ? na.array.length : array.length;
		System.arraycopy(array, 0, na.array, 0, len);
		return na;
	}

	public ByteArray copyFrom(ByteArray that, long thatOffset, long thisOffset, long length) {
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
