package fan.sys;

import fanx.main.Sys;
import fanx.main.Type;

public abstract class IntArray {
	public static IntArray make(long size, long byteSize) {
		switch ((int)byteSize) {
		case 1:
			return new I1(size);
		case 2:
			return new I2(size);
		case 4:
			return new I4(size);
		case 8:
			return new I8(size);
		}
		throw UnsupportedErr.make("IntArray:"+byteSize);
	}

	public abstract long get(long pos);

	public abstract void set(long pos, long val);

	public abstract long size();
	
	public abstract Object raw();

	public abstract boolean realloc(long newSize);

	public abstract IntArray copyFrom(IntArray that, long thatOffset, long thisOffset, long length);
	
	public final Type typeof() { 
		if (type == null) type = Sys.findType("sys::IntArray");
		return type;
	}
	private static Type type;
	
	static class I4 extends IntArray {
		int[] array;
		
		public I4(long size) {
			array = new int[(int)size];
		}
		
		public Object raw() {
			return array;
		}

		public long get(long pos) {
			return array[(int)pos];
		}

		public void set(long pos, long val) {
			array[(int)pos] = (int)val;
		}

		public long size() {
			return array.length;
		}

		public boolean realloc(long newSize) {
			int[] na = new int[(int)newSize];
			System.arraycopy(array, 0, na, 0, na.length);
			array = na;
			return true;
		}

		public I4 copyFrom(IntArray that, long thatOffset, long thisOffset, long length) {
			System.arraycopy(((I4)that).array, (int)thatOffset, array, (int)thisOffset, (int)length);
			return this;
		}
	}
	
	static class I8 extends IntArray {
		long[] array;
		
		public I8(long size) {
			array = new long[(int)size];
		}
		
		public Object raw() {
			return array;
		}

		public long get(long pos) {
			return array[(int)pos];
		}

		public void set(long pos, long val) {
			array[(int)pos] = (long)val;
		}

		public long size() {
			return array.length;
		}

		public boolean realloc(long newSize) {
			long[] na = new long[(int)newSize];
			System.arraycopy(array, 0, na, 0, na.length);
			array = na;
			return true;
		}

		public I8 copyFrom(IntArray that, long thatOffset, long thisOffset, long length) {
			System.arraycopy(((I8)that).array, (int)thatOffset, array, (int)thisOffset, (int)length);
			return this;
		}
	}
	
	static class I2 extends IntArray {
		short[] array;
		
		public I2(long size) {
			array = new short[(int)size];
		}
		
		public Object raw() {
			return array;
		}

		public long get(long pos) {
			return array[(int)pos];
		}

		public void set(long pos, long val) {
			array[(int)pos] = (short)val;
		}

		public long size() {
			return array.length;
		}

		public boolean realloc(long newSize) {
			short[] na = new short[(int)newSize];
			System.arraycopy(array, 0, na, 0, na.length);
			array = na;
			return true;
		}

		public I2 copyFrom(IntArray that, long thatOffset, long thisOffset, long length) {
			System.arraycopy(((I2)that).array, (int)thatOffset, array, (int)thisOffset, (int)length);
			return this;
		}
	}
	
	static class I1 extends IntArray {
		byte[] array;
		
		public I1(long size) {
			array = new byte[(int)size];
		}
		
		public Object raw() {
			return array;
		}

		public long get(long pos) {
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

		public I1 copyFrom(IntArray that, long thatOffset, long thisOffset, long length) {
			System.arraycopy(((I1)that).array, (int)thatOffset, array, (int)thisOffset, (int)length);
			return this;
		}
	}
}
