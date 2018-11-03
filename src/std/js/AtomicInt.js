
fan.std.AtomicInt = fan.sys.Obj.$extend(fan.sys.Obj);
fan.std.AtomicInt.prototype.$ctor = function() {}
fan.std.AtomicInt.prototype.$typeof = function() { return fan.std.AtomicInt.$type; }

fan.std.AtomicInt.make = function(v) {
	self = new fan.std.AtomicInt();
	if (v === undefined) v = false;
	self.m_val = v;
	return self;
}

fan.std.AtomicInt.prototype.get = function() {
	return self.m_val;
}

fan.std.AtomicInt.prototype.val = function() {
	return self.m_val;
}

fan.std.AtomicInt.prototype.val$ = function(v) {
	self.m_val = v;
}

fan.std.AtomicInt.prototype.set$ = function(v) {
	self.m_val = v;
}

fan.std.AtomicInt.prototype.getAndSet = function(v) {
	o = this.m_val;
	this.m_val = v;
	return o;
}

fan.std.AtomicInt.prototype.compareAndSet = function(expect, update) {
	if (this.m_val == expect) {
		this.m_val = update;
		return true;
	}
	return false;
}
