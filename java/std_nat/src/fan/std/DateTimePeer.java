package fan.std;

import java.text.SimpleDateFormat;
import java.util.Calendar;

import fan.sys.FanInt;
import fan.sys.List;
import fan.sys.ParseErr;

public class DateTimePeer {
	static DateTime now(Duration tolerance) {
		return null;
	}

	static DateTime nowUtc(Duration tolerance) {
		return null;
	}

	static DateTime fromTicks(long ticks, TimeZone tz) {
		return null;
	}

	static List getTicks(long year, long month, long day, long hour, long min, long sec, long ns, TimeZone tz) {
		List list = List.make(3);
		return list;
	}
	
	static Calendar toCalendar(DateTime self) {
		Calendar c = Calendar.getInstance();
		c.setTime(new java.util.Date(self.toJava()));
		c.setTimeZone(java.util.TimeZone.getTimeZone(self.tz().name));
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
		return c.get(Calendar.HOUR_OF_DAY);
	}

	static String toLocale(DateTime self, String pattern, Locale locale) {
		SimpleDateFormat format = new SimpleDateFormat(pattern, java.util.Locale.forLanguageTag(locale.lang));
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
