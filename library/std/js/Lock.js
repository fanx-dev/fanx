


fan.std.Lock = fan.sys.Obj.$extend(fan.sys.Obj);
fan.std.Lock.prototype.$ctor = function() {}
fan.std.Lock.prototype.$typeof = function() { return fan.std.Lock.$type; }

fan.std.Lock.make = function() {
	var self = new fan.std.Lock();
	self.m_lock = false;
	return self;
}

fan.std.Lock.prototype.tryLock = function(nanoTime) {
	if (this.m_lock) {
		return false;
	}
	return true;
}

fan.std.Lock.prototype.lock = function() {
	this.m_lock = true;
}

fan.std.Lock.prototype.unlock = function() {
	this.m_lock = false;
}

fan.std.Lock.prototype.sync = function(c) {
	try {
		this.lock();
		return c.call();
	}
	finally {
		this.unlock();
	}
}
