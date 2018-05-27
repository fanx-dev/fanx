package fan.std;

import fan.sys.FanStr;
import fan.sys.List;
import fanx.main.Sys;
import fanx.main.Type;

public class TimeUtil {
	
	private static Type type;
	
	public Type typeof() {
		if (type == null) {
			type = Sys.findType("std::TimeUtil");
		}
		return type;
	}
	
	static long currentTimeMillis() {
		return System.currentTimeMillis();
	}
	
	static long nanoTicks() {
		return System.nanoTime();
	}
	
	static List listTimeZoneNames() {
		String[] tz = java.util.TimeZone.getAvailableIDs();
		List list = List.make(FanStr.type, tz.length);
		for (String n : tz) {
			list.add(n);
		}
		return list;
	}
}
