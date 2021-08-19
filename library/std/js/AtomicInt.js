
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
	return this.m_val;
}

fan.std.AtomicInt.prototype.val = function() {
	return this.m_val;
}

fan.std.AtomicInt.prototype.val$ = function(v) {
	this.m_val = v;
}

fan.std.AtomicInt.prototype.set$ = function(v) {
	this.m_val = v;
}

fan.std.AtomicInt.prototype.getAndSet = function(v) {
	o = this.m_val;
	this.m_val = v;
	return o;
}

fan.std.AtomicInt.prototype.increment = function() {
	++this.m_val;
}

fan.std.AtomicInt.prototype.decrement = function() {
	--this.m_val;
}

fan.std.AtomicInt.prototype.incrementAndGet = function() {
	return ++this.m_val;
}

fan.std.AtomicInt.prototype.decrementAndGet = function() {
	return --this.m_val;
}

fan.std.AtomicInt.prototype.getAndIncrement = function() {
	return this.m_val++;
}

fan.std.AtomicInt.prototype.getAndDecrement = function() {
	return this.m_val--;
}

fan.std.AtomicInt.prototype.compareAndSet = function(expect, update) {
	if (this.m_val == expect) {
		this.m_val = update;
		return true;
	}
	return false;
}
