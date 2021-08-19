package fan.std;

import java.util.Calendar;

import fan.sys.List;

public class TimeZonePeer {
	private java.util.TimeZone jtz;
	
	static TimeZonePeer make(TimeZone self) {
		return new TimeZonePeer();
	}
	
	public static java.util.TimeZone getJtz(TimeZone self) {
		if (self.peer.jtz == null) {
			java.util.TimeZone jtz = java.util.TimeZone.getTimeZone(self.fullName);
			if (jtz == null) {
				jtz = java.util.TimeZone.getDefault();
			}
			self.peer.jtz = jtz;
		}
		return self.peer.jtz;
	}
	
	static TimeZone	fromName(String name) {
		java.util.TimeZone jtz = java.util.TimeZone.getTimeZone(name);
		if (jtz == null) {
			return null;
		}
		TimeZone tz= TimeZone.make(jtz.getDisplayName(), jtz.getID(), jtz.getRawOffset()/1000);
		tz.peer.jtz = jtz;
		return tz;
	}
	
	static TimeZone curTz;
	static {
		java.util.TimeZone jtz = java.util.TimeZone.getDefault();
		curTz = TimeZone.make(jtz.getDisplayName(), jtz.getID(), jtz.getRawOffset()/1000);
	}

	static TimeZone cur() {
		return curTz;
	}
	
	Duration dstOffset(TimeZone self, long year) {
		java.util.TimeZone jtz = getJtz(self);
		if (!jtz.useDaylightTime()) {
			return null;
		}
		
//		Calendar c = Calendar.getInstance(jtz);
//		c.set((int)year, 0, 0);
//		
//		if (!jtz.inDaylightTime(c.getTime())) {
//			return Duration.zero;
//		}
		
//		long millis = c.get(Calendar.DST_OFFSET);
//		return Duration.fromMillis(millis);
		
		long sec = jtz.getDSTSavings() / 1000;
		return Duration.fromSec(sec);
	}

	static List listFullNames() {
		String[] tz = java.util.TimeZone.getAvailableIDs();
		List list = List.make(tz.length);
		for (String n : tz) {
			list.add(n);
		}
		list = (List)list.toImmutable();
		return list;
	}
}
