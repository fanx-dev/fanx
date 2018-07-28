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
	
	public IntArray fill(long val, long times) {
		int t = (int) times;
		for (int i = 0; i < t; ++i) {
			set(i, val);
		}
		return this;
	}

	public abstract IntArray realloc(long newSize);

	public abstract IntArray copyFrom(IntArray that, long thatOffset, long thisOffset, long length);
	
	public final Type typeof() { 
		if (type == null) type = Sys.findType("sys::IntArray");
		return type;
	}
	private static Type type;
	
	static class I4 extends IntArray {
		final int[] array;
		
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

		public IntArray realloc(long newSize) {
			if (array.length == newSize) return this;
			I4 na = new I4(newSize);
			int len = array.length > na.array.length ? na.array.length : array.length;
			System.arraycopy(array, 0, na.array, 0, len);
			return na;
		}

		public I4 copyFrom(IntArray that, long thatOffset, long thisOffset, long length) {
			System.arraycopy(((I4)that).array, (int)thatOffset, array, (int)thisOffset, (int)length);
			return this;
		}
	}
	
	static class I8 extends IntArray {
		final long[] array;
		
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

		public IntArray realloc(long newSize) {
			if (array.length == newSize) return this;
			I8 na = new I8(newSize);
			int len = array.length > na.array.length ? na.array.length : array.length;
			System.arraycopy(array, 0, na.array, 0, len);
			return na;
		}

		public I8 copyFrom(IntArray that, long thatOffset, long thisOffset, long length) {
			System.arraycopy(((I8)that).array, (int)thatOffset, array, (int)thisOffset, (int)length);
			return this;
		}
	}
	
	static class I2 extends IntArray {
		final short[] array;
		
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

		public IntArray realloc(long newSize) {
			if (array.length == newSize) return this;
			I2 na = new I2(newSize);
			int len = array.length > na.array.length ? na.array.length : array.length;
			System.arraycopy(array, 0, na.array, 0, len);
			return na;
		}

		public I2 copyFrom(IntArray that, long thatOffset, long thisOffset, long length) {
			System.arraycopy(((I2)that).array, (int)thatOffset, array, (int)thisOffset, (int)length);
			return this;
		}
	}
	
	static class I1 extends IntArray {
		final byte[] array;
		
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

		public IntArray realloc(long newSize) {
			if (array.length == newSize) return this;
			I1 na = new I1(newSize);
			int len = array.length > na.array.length ? na.array.length : array.length;
			System.arraycopy(array, 0, na.array, 0, len);
			return na;
		}

		public I1 copyFrom(IntArray that, long thatOffset, long thisOffset, long length) {
			System.arraycopy(((I1)that).array, (int)thatOffset, array, (int)thisOffset, (int)length);
			return this;
		}
	}
}
