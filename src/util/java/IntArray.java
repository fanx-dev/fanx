package fan.std;

import fanx.main.Sys;
import fanx.main.Type;
import fan.sys.FanObj;

public abstract class IntArray extends FanObj {
	public static IntArray makeS1(long size) {
		return new S1((int) size);
	}

	public static IntArray makeU1(long size) {
		return new U1((int) size);
	}

	public static IntArray makeS2(long size) {
		return new S2((int) size);
	}

	public static IntArray makeU2(long size) {
		return new U2((int) size);
	}

	public static IntArray makeS4(long size) {
		return new S4((int) size);
	}

	public static IntArray makeU4(long size) {
		return new U4((int) size);
	}

	public static IntArray makeS8(long size) {
		return new S8((int) size);
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
		if (type == null)
			type = Sys.findType("std::IntArray");
		return type;
	}

	private static Type type;

	static class S1 extends IntArray {
		final byte[] array;

		public S1(long size) {
			array = new byte[(int) size];
		}

		public Object raw() {
			return array;
		}

		public long get(long pos) {
			return array[(int) pos];
		}

		public void set(long pos, long val) {
			array[(int) pos] = (byte) val;
		}

		public long size() {
			return array.length;
		}

		public IntArray realloc(long newSize) {
			if (array.length == newSize)
				return this;
			S1 na = new S1(newSize);
			int len = array.length > na.array.length ? na.array.length : array.length;
			System.arraycopy(array, 0, na.array, 0, len);
			return na;
		}

		public S1 copyFrom(IntArray that, long thatOffset, long thisOffset, long length) {
			System.arraycopy(((S1) that).array, (int) thatOffset, array, (int) thisOffset, (int) length);
			return this;
		}
	}

	static class S2 extends IntArray {
		final short[] array;

		public S2(long size) {
			array = new short[(int) size];
		}

		public Object raw() {
			return array;
		}

		public long get(long pos) {
			return array[(int) pos];
		}

		public void set(long pos, long val) {
			array[(int) pos] = (short) val;
		}

		public long size() {
			return array.length;
		}

		public IntArray realloc(long newSize) {
			if (array.length == newSize)
				return this;
			S2 na = new S2(newSize);
			int len = array.length > na.array.length ? na.array.length : array.length;
			System.arraycopy(array, 0, na.array, 0, len);
			return na;
		}

		public S2 copyFrom(IntArray that, long thatOffset, long thisOffset, long length) {
			System.arraycopy(((S2) that).array, (int) thatOffset, array, (int) thisOffset, (int) length);
			return this;
		}
	}

	static class S4 extends IntArray {
		final int[] array;

		public S4(long size) {
			array = new int[(int) size];
		}

		public Object raw() {
			return array;
		}

		public long get(long pos) {
			return array[(int) pos];
		}

		public void set(long pos, long val) {
			array[(int) pos] = (int) val;
		}

		public long size() {
			return array.length;
		}

		public IntArray realloc(long newSize) {
			if (array.length == newSize)
				return this;
			S4 na = new S4(newSize);
			int len = array.length > na.array.length ? na.array.length : array.length;
			System.arraycopy(array, 0, na.array, 0, len);
			return na;
		}

		public S4 copyFrom(IntArray that, long thatOffset, long thisOffset, long length) {
			System.arraycopy(((S4) that).array, (int) thatOffset, array, (int) thisOffset, (int) length);
			return this;
		}
	}

	static class S8 extends IntArray {
		final long[] array;

		public S8(long size) {
			array = new long[(int) size];
		}

		public Object raw() {
			return array;
		}

		public long get(long pos) {
			return array[(int) pos];
		}

		public void set(long pos, long val) {
			array[(int) pos] = (long) val;
		}

		public long size() {
			return array.length;
		}

		public IntArray realloc(long newSize) {
			if (array.length == newSize)
				return this;
			S8 na = new S8(newSize);
			int len = array.length > na.array.length ? na.array.length : array.length;
			System.arraycopy(array, 0, na.array, 0, len);
			return na;
		}

		public S8 copyFrom(IntArray that, long thatOffset, long thisOffset, long length) {
			System.arraycopy(((S8) that).array, (int) thatOffset, array, (int) thisOffset, (int) length);
			return this;
		}
	}

	static class U1 extends S1 {
		U1(int size) {
			super(size);
		}

		public final String kind() {
			return "U1";
		}

		public final long get(long i) {
			return array[(int) i] & 0xFFL;
		}
	}

	static class U2 extends S2 {
		U2(int size) {
			super(size);
		}

		public final String kind() {
			return "U2";
		}

		public final long get(long i) {
			return array[(int) i] & 0xFFFFL;
		}
	}

	static class U4 extends S4 {
		U4(int size) {
			super(size);
		}

		public final String kind() {
			return "U4";
		}

		public final long get(long i) {
			return array[(int) i] & 0xFFFFFFFFL;
		}
	}
}
