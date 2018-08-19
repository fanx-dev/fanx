package fan.sys;

import fanx.main.Sys;
import fanx.main.Type;

public abstract class FloatArray extends FanObj {

	public static FloatArray makeF4(long size) { return new F4((int)size); }
	public static FloatArray makeF8(long size) { return new F8((int)size); }

	public abstract double get(long pos);

	public abstract void set(long pos, double val);

	public abstract long size();

	public abstract Object raw();
	
	public FloatArray fill(double val, long times) {
		int t = (int) times;
		for (int i = 0; i < t; ++i) {
			set(i, val);
		}
		return this;
	}

	public abstract FloatArray realloc(long newSize);

	public abstract FloatArray copyFrom(FloatArray that, long thatOffset, long thisOffset, long length);

	public final Type typeof() {
		if (type == null)
			type = Sys.findType("sys::FloatArray");
		return type;
	}

	private static Type type;

	static class F4 extends FloatArray {
		final float[] array;

		public F4(long size) {
			array = new float[(int) size];
		}

		public Object raw() {
			return array;
		}

		public double get(long pos) {
			return array[(int) pos];
		}

		public void set(long pos, double val) {
			array[(int) pos] = (float) val;
		}

		public long size() {
			return array.length;
		}

		public FloatArray realloc(long newSize) {
			if (array.length == newSize) return this;
			F4 na = new F4(newSize);
			int len = array.length > na.array.length ? na.array.length : array.length;
			System.arraycopy(array, 0, na.array, 0, len);
			return na;
		}

		public F4 copyFrom(FloatArray that, long thatOffset, long thisOffset, long length) {
			System.arraycopy(((F4) that).array, (int) thatOffset, array, (int) thisOffset, (int) length);
			return this;
		}
	}

	static class F8 extends FloatArray {
		double[] array;

		public F8(long size) {
			array = new double[(int) size];
		}

		public Object raw() {
			return array;
		}

		public double get(long pos) {
			return array[(int) pos];
		}

		public void set(long pos, double val) {
			array[(int) pos] = val;
		}

		public long size() {
			return array.length;
		}

		public FloatArray realloc(long newSize) {
			if (array.length == newSize) return this;
			F8 na = new F8(newSize);
			int len = array.length > na.array.length ? na.array.length : array.length;
			System.arraycopy(array, 0, na.array, 0, len);
			return na;
		}

		public F8 copyFrom(FloatArray that, long thatOffset, long thisOffset, long length) {
			System.arraycopy(((F8) that).array, (int) thatOffset, array, (int) thisOffset, (int) length);
			return this;
		}
	}
}
