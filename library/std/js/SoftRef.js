


fan.std.SoftRef = fan.sys.Obj.$extend(fan.sys.Obj);
fan.std.SoftRef.prototype.$ctor = function() {}
fan.std.SoftRef.prototype.$typeof = function() { return fan.std.SoftRef.$type; }

fan.std.SoftRef.make = function(val) {
	var self = new fan.std.SoftRef();
	self.m_val = val;
	return self;
}

fan.std.SoftRef.prototype.get = function() {
	return this.m_val;
}
