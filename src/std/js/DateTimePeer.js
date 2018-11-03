
fan.std.DateTimePeer.cached = fan.std.DateTime.fromTicks(0, fan.std.TimeZone.cur());
fan.std.DateTimePeer.cachedUtc = fan.std.DateTime.fromTicks(0, fan.std.TimeZone.utc());

fan.std.DateTimePeer.now = function(tolerance) {
	var d = new Date();
	var now = d.getMilliseconds();

    var c = cached;
    if (tolerance != null && now - c.ticks <= tolerance.toMillis())
        return c;

    cached = fan.std.DateTime.fromTicks(now, fan.std.TimeZone.cur());
    return cached;
}

fan.std.DateTimePeer.nowUtc = function(tolerance) {
	var d = new Date();
	var now = d.getMilliseconds();

    var c = cachedUtc;
    if (tolerance != null && now - c.ticks <= tolerance.toMillis())
        return c;

    cachedUtc = fan.std.DateTime.fromTicks(now, fan.std.TimeZone.utc());
    return cachedUtc;
}

fan.std.DateTimePeer.fromTicks = function(ticks, tz) {
	var d = new Date(ticks);
	var year = d.getFullYear();
	var month = d.getMonth();//base 0
	var day = d.getDate();//base 1
	var hour = d.getHours();
	var min = d.getMinutes();
	var sec = d.getSeconds();
	var ns = d.getMilliseconds()*1000000;
	var dst = 0;
	var weekday = d.getDay();
	
	if (year < 1901 || year > 2099) {
		System.out.println("ERROR");
	}
	
	DateTime dt = DateTime.privateMake(year, month, day, hour, min, sec, ns, ticks, dst, weekday, tz);
	return dt;
}

fan.std.DateTimePeer.make = function(long year, Month month, long day, long hour, long min, long sec, long ns, TimeZone tz) {
	var cal = new Date(year, month, day, hour, min, sec, ns/1000000);
	
	cal.set(Calendar.MILLISECOND, (int)ns/1000000);
	long dst = 0;
	long weekday = cal.getDay();
	long ticks = cal.getTime()();
	
	DateTime dt = DateTime.privateMake(year, month.ordinal(), day, hour, min, sec, ns, ticks, dst, weekday, tz);
	return dt;
}
	
fan.std.DateTimePeer.dayOfYear = function(self) {
	Calendar c = toCalendar(self);
	return c.get(Calendar.DAY_OF_YEAR);
}

fan.std.DateTimePeer.weekOfYear = function(self, startOfWeek) {
	Calendar c = toCalendar(self);
	return c.get(Calendar.WEEK_OF_YEAR);
}

fan.std.DateTimePeer.hoursInDay = function(self) {
	var dst = 0
	return 24 + (dst/Duration.milliPerHr);
}

fan.std.DateTimePeer.replace = function(String pattern, char from, String to, boolean isSingle) {
	if (isSingle === undefined) {
		isSingle = false
	}
	var in = false;
	var sb = new Array();
	for (int i=0; i<pattern.length(); ++i) {
		char c = pattern.charAt(i);
		if (c == '\'') {
			if (in) in = false;
			else in = true;
			
			sb.push(c);
			continue;
		}
		
		if (in) {
			sb.push(c);
			continue;
		}
		
		if (c == from) {
			boolean single = true;
			if (isSingle) {
				if (i-1 >= 0 && pattern.charAt(i-1) == from) {
					single = false;
				}
				if (i+1 < pattern.length() && pattern.charAt(i+1) == from) {
					single = false;
				}
			}
			
			if (single) {
				sb.push(to);
				continue;
			}
		}
		sb.push(c);
	}
	return sb.join("");
}

// private static String toJavaPattern(String pattern) {
// 	String old = pattern;
// 	if (pattern == null) {
// 		pattern = "YYYY-MM-DD'T'hh:mm:ss.FFFFFFFFFz";
// 	}
// 	pattern = replace(pattern, 'Y', "y");
// 	pattern = replace(pattern, 'D', "d");
// 	pattern = replace(pattern, 'W', "E");
// 	pattern = replace(pattern, 'V', "w");
	
// 	pattern = replace(pattern, 'h', "H");
// 	pattern = replace(pattern, 'k', "h");
	
// 	pattern = replace(pattern, 'a', "A");
// 	pattern = replace(pattern, 'F', "S");
// 	pattern = replace(pattern, 'z', "XXX", true);
	
// //		System.out.println("********************\n"+old+"=>" + pattern);
// 	return pattern;
// }

fan.std.DateTimePeer.toLocale = function( self,  pattern,  locale) {
	var date = new Date(self.toJava());
	var res = date.toISOString();
	return res;
}

fan.std.DateTimePeer.fromLocale = function(str,  pattern,  tz, checked) {
	try {
		var date = new Date(str)
		return DateTime.fromJava(date.getTime(), tz);
	} catch (Exception e) {
		if (checked) {
			throw ParseErr.make(str);
		}
		return null;
	}
}

fan.std.DateTimePeer.weekdayInMonth = function( year,  mon,  weekday,  pos) {
    throw ArgErr.make("TODO: year:"+year+",month:"+mon +",weekday:"+weekday+",pos:"+pos);
}


