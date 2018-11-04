
fan.std.LocalePeer = function(){}


fan.std.LocalePeer.threadLocale = fan.std.Locale.make("en", "US");

fan.std.LocalePeer.cur = function() {
	return threadLocale
}

fan.std.LocalePeer.setCur = function(local) {
	threadLocale = local
}

