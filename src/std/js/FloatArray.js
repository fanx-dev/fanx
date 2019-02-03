

fan.std.FloatArray = fan.sys.Obj.$extend(fan.sys.Obj);
fan.std.FloatArray.prototype.$ctor = function() {}
fan.std.FloatArray.prototype.$typeof = function() { return fan.std.FloatArray.$type; }

fan.std.FloatArray.makeF4 = function(size) {
	self = new fan.std.FloatArray()
	self.m_array = new Float32Array(size);
	return self
}

fan.std.FloatArray.makeF8 = function(size) {
	self = new fan.std.FloatArray()
	self.m_array = new Float64Array(size);
	return self
}

fan.std.FloatArray.prototype.get = function(pos) {
	return this.m_array[pos]
}

fan.std.FloatArray.prototype.set = function(pos, val) {
	this.m_array[pos] = val
}

fan.std.FloatArray.prototype.size = function() {
	return this.m_array.length;
}

fan.std.FloatArray.prototype.realloc = function(newSize) {
	if (this.m_array.length == newSize) return this;

	if (newSize > this.m_array.length) {
		for (i = this.m_array.length; i<newSize; ++i) {
			this.m_array.push(null)
		}
		return this;
	}

	var na = fan.std.FloatArray.make(newSize, this.m_of);
	var len = this.m_array.length > newSize ? newSize : this.m_array.length;
	for (var i = 0; i<len; ++i) {
		na.m_array[i] = this.m_array[i]
	}
	return na;
}

fan.std.FloatArray.prototype.fill = function(val, times) {
	for (var i = 0; i < times; ++i) {
		this.m_array[i] = val;
	}
	return this;
}

fan.std.FloatArray.prototype.copyFrom = function(that, thatOffset, thisOffset, length) {
	if (this === that) {
		this.m_array.copyWithin(thisOffset, thatOffset, thatOffset+length)
		return this;
	}

	for (var i = 0; i<length; ++i) {
		this.m_array[thisOffset + i] = that.m_array[i+thatOffset]
	}
	return this;
}

