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

	static DateTime now() {
		return now(Duration.fromMillis(250));
	}

	static DateTime nowUtc(Duration tolerance) {
		return null;
	}

	static DateTime nowUtc() {
		return nowUtc(Duration.fromMillis(250));
	}

	static DateTime fromTicks(long ticks, TimeZone tz) {
		return null;
	}

	static DateTime fromTicks(long ticks) {
		return fromTicks(ticks, TimeZone.cur());
	}

	static List getTicks(long year, long month, long day, long hour, long min, long sec, long ns, TimeZone tz) {
		List list = List.make(FanInt.type, 3);
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

	static long weekOfYear(DateTime self) {
		return weekOfYear(self, Weekday.localeStartOfWeek());
	}

	static long hoursInDay(DateTime self) {
		return 24;
	}

	static String toLocale(DateTime self, String pattern, Locale locale) {
		SimpleDateFormat format = new SimpleDateFormat(pattern, java.util.Locale.forLanguageTag(locale.lang));
		java.util.Date date = new java.util.Date(self.toJava());
		return format.format(date);
	}

	static String toLocale(DateTime self, String pattern) {
		return toLocale(self, pattern, Locale.cur());
	}

	static String toLocale(DateTime self) {
		return toLocale(self, null, Locale.cur());
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

	static DateTime fromLocale(String str, String pattern, TimeZone tz) {
		return fromLocale(str, pattern, tz, true);
	}

	static DateTime fromLocale(String str, String pattern) {
		return fromLocale(str, pattern, TimeZone.cur(), true);
	}

	static long weekdayInMonth(long year, Month mon, Weekday weekday, long pos) {
//		Calendar c = Calendar.getInstance();
//		c.set((int)year, (int)mon.ordinal(), 0);
//		return c.get(Calendar.WEEK_OF_MONTH);
		//TODO
		return 0;
	}

}
