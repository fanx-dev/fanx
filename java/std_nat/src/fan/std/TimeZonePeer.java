package fan.std;

import java.util.Calendar;

import fan.sys.FanStr;
import fan.sys.List;

public class TimeZonePeer {
	static TimeZone	fromName(String name) {
		java.util.TimeZone jtz = java.util.TimeZone.getTimeZone(name);
		if (jtz == null) return null;
		return TimeZone.make(jtz.getID(), jtz.getDisplayName(), jtz.getRawOffset()/1000);
	}

	static TimeZone cur() {
		java.util.TimeZone jtz = java.util.TimeZone.getDefault();
		return TimeZone.make(jtz.getID(), jtz.getDisplayName(), jtz.getRawOffset()/1000);
	}
	
	static Duration dstOffset(TimeZone self, long year) {
		java.util.TimeZone jtz = java.util.TimeZone.getTimeZone(self.name);
		
		Calendar c = Calendar.getInstance();
		c.set((int)year + 1900, 0, 0);
		
		if (!jtz.inDaylightTime(c.getTime())) {
			return Duration.make(0);
		}
		
		long sec = jtz.getDSTSavings() / 1000;
		return Duration.fromSec(sec);
	}

	static List listNames() {
		String[] tz = java.util.TimeZone.getAvailableIDs();
		List list = List.make(tz.length);
		for (String n : tz) {
			list.add(n);
		}
		return list;
	}
}
