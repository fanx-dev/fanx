package fan.std;

import java.text.SimpleDateFormat;
import java.util.Calendar;

import fan.sys.ParseErr;

public class DateTimePeer {
	private static volatile DateTime cached = DateTime.fromTicks(0, TimeZone.cur());
	private static volatile DateTime cachedUtc = DateTime.fromTicks(0, TimeZone.utc);
	  
	static DateTime now(Duration tolerance) {
		long now = System.currentTimeMillis();

	    DateTime c = cached;
	    if (tolerance != null && now - c.ticks <= tolerance.ticks)
	        return c;

	    return cached = DateTime.fromTicks(now, TimeZone.cur());
	}

	static DateTime nowUtc(Duration tolerance) {
		long now = System.currentTimeMillis();

	    DateTime c = cachedUtc;
	    if (tolerance != null && now - c.ticks <= tolerance.ticks)
	        return c;

	    return cachedUtc = DateTime.fromTicks(now, TimeZone.utc);
	}

	static DateTime fromTicks(long ticks, TimeZone tz) {
		java.util.TimeZone jtz = java.util.TimeZone.getTimeZone(tz.name);
		Calendar cal = Calendar.getInstance(jtz);
		cal.setTimeInMillis(ticks);
		
		long year = cal.get(Calendar.YEAR);
		long month = cal.get(Calendar.MONTH);//base 0
		long day = cal.get(Calendar.DAY_OF_MONTH);//base 1
		long hour = cal.get(Calendar.HOUR_OF_DAY);
		long min = cal.get(Calendar.MINUTE);
		long sec = cal.get(Calendar.SECOND);
		long ns = cal.get(Calendar.MILLISECOND)*1000000;
		long dst = cal.get(Calendar.DST_OFFSET);
		long weekday = cal.get(Calendar.DAY_OF_WEEK)-1;//base 1
		
		DateTime dt = DateTime.privateMake(year, month, day, hour, min, sec, ns, ticks, dst, weekday, tz);
		return dt;
	}

	static DateTime make(long year, Month month, long day, long hour, long min, long sec, long ns, TimeZone tz) {
		java.util.TimeZone jtz = java.util.TimeZone.getTimeZone(tz.name);
		Calendar cal = Calendar.getInstance(jtz);
		
		cal.set(Calendar.YEAR, (int)year);
		cal.set(Calendar.MONTH, (int)month.ordinal());
		cal.set(Calendar.DAY_OF_MONTH, (int)day);
		cal.set(Calendar.HOUR_OF_DAY, (int)hour);
		cal.set(Calendar.MINUTE, (int)min);
		cal.set(Calendar.SECOND, (int)sec);
		
		cal.set(Calendar.MILLISECOND, (int)ns/1000000);
		long dst = cal.get(Calendar.DST_OFFSET);
		long weekday = cal.get(Calendar.DAY_OF_WEEK)-1;
		long ticks = cal.getTimeInMillis();
		
		DateTime dt = DateTime.privateMake(year, month.ordinal(), day, hour, min, sec, ns, ticks, dst, weekday, tz);
		return dt;
	}
	
	static Calendar toCalendar(DateTime self) {
		java.util.TimeZone jtz = java.util.TimeZone.getTimeZone(self.tz().name);
		Calendar c = Calendar.getInstance(jtz);
		c.setTimeInMillis((self.toJava()));
		return c;
	}

	static long dayOfYear(DateTime self) {
		Calendar c = toCalendar(self);
		return c.get(Calendar.DAY_OF_YEAR);
	}

	static long weekOfYear(DateTime self, Weekday startOfWeek) {
		Calendar c = toCalendar(self);
		return c.get(Calendar.WEEK_OF_YEAR);
	}

	static long hoursInDay(DateTime self) {
		Calendar c = toCalendar(self);
		long dst = c.get(Calendar.DST_OFFSET);
//		return c.get(Calendar.HOUR_OF_DAY);
		return 24 + (dst/Duration.milliPerHr);
	}

	static String toLocale(DateTime self, String pattern, Locale locale) {
		java.util.Locale jlocale = java.util.Locale.forLanguageTag(locale.lang);
		if (pattern == null) {
			pattern = "YYYY-MM-DD'T'hh:mm:ss.FFFFFFFFFz";
		}
		SimpleDateFormat format = new SimpleDateFormat(pattern, jlocale);
		java.util.Date date = new java.util.Date(self.toJava());
		return format.format(date);
	}

	static DateTime fromLocale(String str, String pattern, TimeZone tz, boolean checked) {
		try {
			SimpleDateFormat format = new SimpleDateFormat(pattern);
			java.util.Date date = format.parse(str);
			return DateTime.fromJava(date.getTime(), tz);
		} catch (Exception e) {
			if (checked) {
				throw ParseErr.make(str);
			}
			return null;
		}
	}

	static long weekdayInMonth(long year, Month mon, Weekday weekday, long pos) {
		Calendar cal = Calendar.getInstance();
	    cal.set(Calendar.DATE,1);
	    cal.set(Calendar.YEAR, (int)year);
	    cal.set(Calendar.MONTH, (int)mon.ordinal());
	    
	    if (pos < 0) {
	    	pos = 31 + pos;
	    }
	    int count = 0;
	    for (int i = 0; i < 31; i++) {
	        if (cal.get(Calendar.DAY_OF_WEEK) == weekday.ordinal()) {
	            count++;
	            if (count == pos) {
	            	return i;
	            }
	        }
	        cal.add(Calendar.DATE,1);
	    }
	    return -1;
	}

}
