
fan.std.AtomicRef = fan.sys.Obj.$extend(fan.sys.Obj);
fan.std.AtomicRef.prototype.$ctor = function() {}
fan.std.AtomicRef.prototype.$typeof = function() { return fan.std.AtomicRef.$type; }

fan.std.AtomicRef.make = function(v) {
	self = new fan.std.AtomicRef();
	if (v === undefined) v = false;
	self.m_val = v;
	return self;
}

fan.std.AtomicRef.prototype.get = function() {
	return self.m_val;
}

fan.std.AtomicRef.prototype.val = function() {
	return self.m_val;
}

fan.std.AtomicRef.prototype.val$ = function(v) {
	self.m_val = v;
}

fan.std.AtomicRef.prototype.set$ = function(v) {
	self.m_val = v;
}

fan.std.AtomicRef.prototype.getAndSet = function(v) {
	o = this.m_val;
	this.m_val = v;
	return o;
}

fan.std.AtomicRef.prototype.compareAndSet = function(expect, update) {
	if (this.m_val == expect) {
		this.m_val = update;
		return true;
	}
	return false;
}
