fan.std.TimeZonePeer = function(){}


fan.std.TimeZonePeer.make = function(self) {
	return new fan.std.TimeZonePeer();
}

fan.std.TimeZonePeer.fromName = function(name) {
	return new fan.std.TimeZone.make(name, name, 0);
}

fan.std.TimeZonePeer.m_cur = null;

fan.std.TimeZonePeer.cur = function() {
	if (fan.std.TimeZonePeer.m_cur == null) {
	    try
	    {
	      // check for explicit tz from Env.vars or fallback to local if avail
	      var tz = fan.std.Env.cur().m_vars.get("timezone");
	      if (tz == null) tz = Intl.DateTimeFormat().resolvedOptions().timeZone.split("/")[1];
	      if (tz == null) tz = "UTC"
	      fan.std.TimeZone.m_cur = fan.std.TimeZone.fromStr(tz);
	    }
	    catch (err)
	    {
	      // fallback to UTC if we get here
	      console.log(fan.sys.Err.make(err).m_msg);
	      fan.std.TimeZone.m_cur = fan.std.TimeZone.m_utc;
	      throw fan.sys.Err.make(err);
	    }
	}
	return fan.std.TimeZonePeer.m_cur;
}

fan.std.TimeZonePeer.prototype.dstOffset = function(self, year) {
	var d = new Date();
	return d.getTimezoneOffset();
}

fan.std.TimeZonePeer.listFullNames = function() {
	var list =  fan.sys.List.make(4);
	list.add(fan.std.TimeZonePeer.m_cur);
	return list;
}

