fan.std.TimePointPeer = function(){}


fan.std.TimePointPeer.nowMillis = function() {
	var d = new Date();
	return d.getTime();
}

fan.std.TimePointPeer.nanoTicks = function() {
	var d = new Date();
	return d.getTime() * fan.std.Duration.m_nsPerMilli;
}

fan.std.TimePointPeer.nowUniqueLast = 0;

fan.std.TimePointPeer.nowUnique = function() {
	var d = new Date();
	var now = d.getTime();

	if (now <= fan.std.TimePointPeer.nowUniqueLast)
		now = fan.std.TimePointPeer.nowUniqueLast + 1;
	fan.std.TimePointPeer.nowUniqueLast = now;
	return now;
}
