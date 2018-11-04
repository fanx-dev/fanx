
fan.std.DateTimePeer = function(){}

fan.std.DateTimePeer.now = function(tolerance) {
	var d = new Date();
	var now = d.getMilliseconds();

    var c = fan.std.DateTimePeer.cached;
    if (tolerance != null && now - c.ticks <= tolerance.toMillis())
        return c;

    fan.std.DateTimePeer.cached = fan.std.DateTime.fromTicks(now, fan.std.TimeZone.cur());
    return fan.std.DateTimePeer.cached;
}

fan.std.DateTimePeer.nowUtc = function(tolerance) {
	var d = new Date();
	var now = d.getMilliseconds();

    var c = fan.std.DateTimePeer.cachedUtc;
    if (tolerance != null && now - c.ticks <= tolerance.toMillis())
        return c;

    fan.std.DateTimePeer.cachedUtc = fan.std.DateTime.fromTicks(now, fan.std.TimeZone.utc());
    return fan.std.DateTimePeer.cachedUtc;
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
	
	var dt = fan.std.DateTime.privateMake(year, month, day, hour, min, sec, ns, ticks, dst, weekday, tz);
	return dt;
}

fan.std.DateTimePeer.make = function( year,  month,  day,  hour,  min,  sec,  ns,  tz) {
	var cal = new Date(year, month, day, hour, min, sec, ns/1000000);
	
	//cal.set(Calendar.MILLISECOND, (int)ns/1000000);
	var dst = 0;
	var weekday = cal.getDay();
	var ticks = cal.getTime()();
	
	var dt = fan.std.DateTime.privateMake(year, month.ordinal(), day, hour, min, sec, ns, ticks, dst, weekday, tz);
	return dt;
}
	
fan.std.DateTimePeer.dayOfYear = function(self) {
	// Calendar c = toCalendar(self);
	// return c.get(Calendar.DAY_OF_YEAR);
	return 0
}

fan.std.DateTimePeer.weekOfYear = function(self, startOfWeek) {
	// Calendar c = toCalendar(self);
	// return c.get(Calendar.WEEK_OF_YEAR);
	return 0;
}

fan.std.DateTimePeer.hoursInDay = function(self) {
	var dst = 0
	return 24 + (dst/Duration.milliPerHr);
}
/*
fan.std.DateTimePeer.replace = function(pattern, from, to, isSingle) {
	if (isSingle === undefined) {
		isSingle = false
	}
	var in_ = false;
	var sb = new Array();
	for (var i=0; i<pattern.length(); ++i) {
		var c = pattern.charAt(i);
		if (c == '\'') {
			if (in_) in_ = false;
			else in_ = true;
			
			sb.push(c);
			continue;
		}
		
		if (in_) {
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
*/
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
		return fan.std.DateTime.fromJava(date.getTime(), tz);
	} catch (e) {
		if (checked) {
			throw fan.std.ParseErr.make(str);
		}
		return null;
	}
}

fan.std.DateTimePeer.weekdayInMonth = function( year,  mon,  weekday,  pos) {
    throw fan.sys.ArgErr.make("TODO: year:"+year+",month:"+mon +",weekday:"+weekday+",pos:"+pos);
}

