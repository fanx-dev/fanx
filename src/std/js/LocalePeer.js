
fan.std.LocalePeer = function(){}


fan.std.LocalePeer.threadLocale = fan.std.Locale.make("en", "US");

fan.std.LocalePeer.cur = function() {
	return fan.std.LocalePeer.threadLocale
}

fan.std.LocalePeer.setCur = function(local) {
	fan.std.LocalePeer.threadLocale = local
}

