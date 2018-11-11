
fan.std.LogPeer = function(){}


fan.std.LogPeer.make = function(self) {
	var t = fan.std.LogPeer();
	self.m_level = LogLevel.info;
	return t;
}

fan.std.LogPeer.m_byName = [];

fan.std.LogPeer.list = function()
{
  var list = fan.sys.List.make(fan.std.LogPeer.m_byName.length, fan.std.LogPeer.$typ);
  for (var k in fan.std.LogPeer.m_byName) {
  	list.add(fan.std.LogPeer.m_byName[k]);
  }
  return list.ro();
}

fan.std.LogPeer.find = function(name, checked)
{
  if (checked === undefined) checked = true;
  var log = fan.std.LogPeer.m_byName[name];
  if (log != null) return log;
  if (checked) throw fan.sys.Err.make("Unknown log: " + name);
  return null;
}

fan.std.LogPeer.doRegister = function(self)
{
  	var name = self.m_name;
	// verify unique
	if (fan.std.LogPeer.m_byName[name] != null)
	  throw fan.sys.ArgErr.make("Duplicate log name: " + name);

	// init and put into map
	fan.std.LogPeer.m_byName[name] = self;
}

fan.std.LogPeer.level = function(self) {
	return self.m_level;
}

fan.std.LogPeer.level$ = function(self, l) {
	self.m_level = l;
}

fan.std.LogPeer.slog = function(name, rec) {
  for (var i=0; i<fan.std.LogPeer.m_handlers.length; ++i)
  {
    try { fan.std.LogPeer.m_handlers[i].call(rec); }
    catch (e) { fan.sys.Err.make(e).trace(); }
  }
}


fan.std.LogPeer.log = function(self, rec) {
  if (!self.enabled(rec.m_level)) return;

  for (var i=0; i<fan.std.LogPeer.m_handlers.length; ++i)
  {
    try { fan.std.LogPeer.m_handlers[i].call(rec); }
    catch (e) { fan.sys.Err.make(e).trace(); }
  }
}

fan.std.LogPeer.printLogRec = function(rec, out) {
    //out.printLine(rec.toStr());
    fan.sys.ObjUtil.echo(rec);
}

//////////////////////////////////////////////////////////////////////////
// Handlers
//////////////////////////////////////////////////////////////////////////

fan.std.LogPeer.handlers = function()
{
  return fan.sys.List.makeFromJs(fan.sys.Func.$type, fan.std.LogPeer.m_handlers).ro();
}

fan.std.LogPeer.addHandler = function(func)
{
  if (!func.isImmutable()) throw fan.sys.NotImmutableErr.make("handler must be immutable");
  fan.std.LogPeer.m_handlers.push(func);
}

fan.std.LogPeer.removeHandler = function(func)
{
  var index = null;
  for (var i=0; i<fan.std.LogPeer.m_handlers.length; i++)
    if (fan.std.LogPeer.m_handlers[i] == func) { index=i; break }

  if (index == null) return;
  fan.std.LogPeer.m_handlers.splice(index, 1);
}

fan.std.LogPeer.m_handlers = [];

