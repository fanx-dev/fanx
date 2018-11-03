

fan.std.ThreadLocal = fan.sys.Obj.$extend(fan.sys.Obj);
fan.std.ThreadLocal.prototype.$ctor = function() {}
fan.std.ThreadLocal.prototype.$typeof = function() { return fan.std.ThreadLocal.$type; }

fan.std.ThreadLocal.make = function(init) {
	var self = new fan.std.ThreadLocal();
	if (init != null) self.m_val = init.call();
	else self.m_val = null;
	return self;
}

fan.std.ThreadLocal.prototype.get = function() {
	return this.m_val;
}

fan.std.ThreadLocal.prototype.set = function(val) {
	this.m_val = val;
}

fan.std.ThreadLocal.prototype.remove = function() {
	this.m_val = null;
}


