


fan.std.Lazy = fan.sys.Obj.$extend(fan.sys.Obj);
fan.std.Lazy.prototype.$ctor = function() {}
fan.std.Lazy.prototype.$typeof = function() { return fan.std.Lazy.$type; }

fan.std.Lazy.make = function(init) {
	var self = new fan.std.Lazy();
	self.initial = init.toImmutable();
	return self;
}

fan.std.Lazy.prototype.get = function() {
	if (this.m_val == null) {
		v = initial.call();
		this.m_val = fan.sys.ObjUtil.toImmutable(v);
	}
	return this.m_val;
}

