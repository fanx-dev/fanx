

fan.util.FloatArray = fan.sys.Obj.$extend(fan.sys.Obj);
fan.util.FloatArray.prototype.$ctor = function() {}
fan.util.FloatArray.prototype.$typeof = function() { return fan.util.FloatArray.$type; }

fan.util.FloatArray.makeF4 = function(size) {
	self = new fan.util.FloatArray()
	self.m_array = new Float32Array(size);
	return self
}

fan.util.FloatArray.makeF8 = function(size) {
	self = new fan.util.FloatArray()
	self.m_array = new Float64Array(size);
	return self
}

fan.util.FloatArray.prototype.get = function(pos) {
	return this.m_array[pos]
}

fan.util.FloatArray.prototype.set = function(pos, val) {
	this.m_array[pos] = val
}

fan.util.FloatArray.prototype.size = function() {
	return this.m_array.length;
}

fan.util.FloatArray.prototype.realloc = function(newSize) {
	if (this.m_array.length == newSize) return this;

	if (newSize > this.m_array.length) {
		for (i = this.m_array.length; i<newSize; ++i) {
			this.m_array.push(null)
		}
		return this;
	}

	var na = fan.util.FloatArray.make(newSize, this.m_of);
	var len = this.m_array.length > newSize ? newSize : this.m_array.length;
	for (var i = 0; i<len; ++i) {
		na.m_array[i] = this.m_array[i]
	}
	return na;
}

fan.util.FloatArray.prototype.fill = function(val, times) {
	for (var i = 0; i < times; ++i) {
		this.m_array[i] = val;
	}
	return this;
}

fan.util.FloatArray.prototype.copyFrom = function(that, thatOffset, thisOffset, length) {
	if (this === that) {
		this.m_array.copyWithin(thisOffset, thatOffset, thatOffset+length)
		return this;
	}

	for (var i = 0; i<length; ++i) {
		this.m_array[thisOffset + i] = that.m_array[i+thatOffset]
	}
	return this;
}

