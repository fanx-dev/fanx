

fan.std.AtomicBool = fan.sys.Obj.$extend(fan.sys.Obj);
fan.std.AtomicBool.prototype.$ctor = function() {}
fan.std.AtomicBool.prototype.$typeof = function() { return fan.std.AtomicBool.$type; }

fan.std.AtomicBool.make = function(v) {
	self = new fan.std.AtomicBool();
	if (v === undefined) v = false;
	self.m_val = v;
	return self;
}

fan.std.AtomicBool.prototype.get = function() {
	return this.m_val;
}

fan.std.AtomicBool.prototype.val = function() {
	return this.m_val;
}

fan.std.AtomicBool.prototype.val$ = function(v) {
	this.m_val = v;
}

fan.std.AtomicBool.prototype.set$ = function(v) {
	this.m_val = v;
}

fan.std.AtomicBool.prototype.getAndSet = function(v) {
	o = this.m_val;
	this.m_val = v;
	return o;
}

fan.std.AtomicBool.prototype.compareAndSet = function(expect, update) {
	if (this.m_val == expect) {
		this.m_val = update;
		return true;
	}
	return false;
}
