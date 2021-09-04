
fan.std.LocalePeer = function(){}


fan.std.LocalePeer.threadLocale = null;

fan.std.LocalePeer.cur = function() {
  if (fan.std.LocalePeer.threadLocale == null)
  {
    // check for explicit locale from Env.vars or fallback to en-US
    var loc = fan.std.Env.cur().m_vars.get("locale");
    if (loc == null) loc = "en-US"
    fan.std.LocalePeer.threadLocale = fan.std.Locale.fromStr(loc);
  }
  return fan.std.LocalePeer.threadLocale
}

fan.std.LocalePeer.setCur = function(local) {
	fan.std.LocalePeer.threadLocale = local
}

