package fan.std;

import fanx.main.Sys;
import fanx.main.Type;

public class TimePointPeer {

	private static Type type;

	public Type typeof() {
		if (type == null) {
			type = Sys.findType("std::TimeUtil");
		}
		return type;
	}

	static long nowMillis() {
		return System.currentTimeMillis();
	}

	static long nanoTicks() {
		return System.nanoTime();
	}

	static long nowUniqueLast = 0;

	static synchronized long nowUnique() {
		long now = System.currentTimeMillis();
		if (now <= nowUniqueLast)
			now = nowUniqueLast + 1;
		nowUniqueLast = now;
		return nowUniqueLast;
	}

}
