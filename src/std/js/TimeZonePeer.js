

fan.std.TimeZonePeer.make = function(self) {
	return new fan.std.TimeZonePeer();
}

fan.std.TimeZonePeer.fromName = function(name) {
	return new fan.std.TimeZone.make(name, name, 0);
}

fan.std.TimeZonePeer.m_cur = fan.std.TimeZonePeer.fromName("cur");

fan.std.TimeZonePeer.cur = function() {
	return fan.std.TimeZonePeer.m_cur;
}

fan.std.TimeZonePeer.prototype.dstOffset(self, year) {
	var d = new Date();
	return d.getTimezoneOffset();
}

fan.std.TimeZonePeer.listFullNames = function() {
	var list =  fan.sys.List.make();
	list.add(fan.std.TimeZonePeer.m_cur);
	return list;
}

