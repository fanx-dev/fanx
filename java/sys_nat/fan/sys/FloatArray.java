package fan.sys;

import fanx.main.Sys;
import fanx.main.Type;

public abstract class FloatArray {

	public static FloatArray make(long size, long byteSize) {
		if (byteSize == 4) {
			return new F4(size);
		} else if (byteSize == 8) {
			return new F4(size);
		}
		throw UnsupportedErr.make("IntArray:" + byteSize);
	}

	public abstract double get(long pos);

	public abstract void set(long pos, double val);

	public abstract long size();

	public abstract Object raw();

	public abstract boolean realloc(long newSize);

	public abstract FloatArray copyFrom(FloatArray that, long thatOffset, long thisOffset, long length);

	public final Type typeof() {
		if (type == null)
			type = Sys.findType("sys::FloatArray");
		return type;
	}

	private static Type type;

	static class F4 extends FloatArray {
		float[] array;

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

		public boolean realloc(long newSize) {
			float[] na = new float[(int) newSize];
			System.arraycopy(array, 0, na, 0, na.length);
			array = na;
			return true;
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

		public boolean realloc(long newSize) {
			double[] na = new double[(int) newSize];
			System.arraycopy(array, 0, na, 0, na.length);
			array = na;
			return true;
		}

		public F8 copyFrom(FloatArray that, long thatOffset, long thisOffset, long length) {
			System.arraycopy(((F8) that).array, (int) thatOffset, array, (int) thisOffset, (int) length);
			return this;
		}
	}
}
