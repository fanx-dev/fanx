package fan.sys;

import fanx.main.Sys;
import fanx.main.Type;

public class BoolArray {
	private final long size;
	private final int[] words;

	BoolArray(long size) {
		this.size = size;
		this.words = new int[((int) size >> 0x5) + 1];
	}

	public static BoolArray make(long size) {
		BoolArray self = new BoolArray(size);
		return self;
	}

	public boolean get(long index) {
		int i = (int)index;
	    return (words[i>>0x5] & (1 << (i & 0x1F))) != 0;
	}

	public void set(long index, boolean v) {
		int i = (int)index;
	    int mask = 1 << (i & 0x1F);
	    if (v)
	      words[i>>0x5] |= mask;
	    else
	      words[i>>0x5] &= ~mask;
	}

	public long size() {
		return this.size;
	}

	public BoolArray realloc(long newSize) {
		if (size == newSize)
			return this;
		BoolArray na = BoolArray.make(newSize);
		int len = words.length > na.words.length ? na.words.length : words.length;
		System.arraycopy(words, 0, na.words, 0, len);
		return na;
	}

	public BoolArray copyFrom(BoolArray that, long thatOffset, long thisOffset, long length) {
		System.arraycopy(that.words, (int) thatOffset, words, (int) thisOffset, (int) length);
		return this;
	}

	public final Type typeof() {
		if (type == null)
			type = Sys.findType("sys::BoolArray");
		return type;
	}

	private static Type type;

	public BoolArray fill(boolean val, long times) {
		int t = (int) times;
		for (int i = 0; i < t; ++i) {
			set(i, val);
		}
		return this;
	}

}
