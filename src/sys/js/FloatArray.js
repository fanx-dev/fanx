

fan.sys.FloatArray = fan.sys.Obj.$extend(fan.sys.Obj);
fan.sys.FloatArray.prototype.$ctor = function() {}
fan.sys.FloatArray.prototype.$typeof = function() { return fan.sys.FloatArray.$type; }

fan.sys.FloatArray.makeF4(long size) {
	self = new fan.sys.FloatArray()
	self.m_array = new Float32Array(size);
	return self
}

fan.sys.FloatArray.makeF8(long size) {
	self = new fan.sys.FloatArray()
	self.m_array = new Float64Array(size);
	return self
}

fan.sys.FloatArray.prototype.get = function(pos) {
	return this.m_array[pos]
}

fan.sys.FloatArray.prototype.set = function(pos, val) {
	this.m_array[pos] = val
}

fan.sys.FloatArray.prototype.size = function() {
	return this.m_size;
}

fan.sys.FloatArray.prototype.realloc = function(newSize) {
	if (this.m_array.length == newSize) return this;

	if (newSize > this.m_array.length) {
		for (i = this.m_array.length; i<newSize; ++i) {
			this.m_array.push(null)
		}
		return this;
	}

	na = fan.sys.FloatArray.make(newSize, of);
	len = this.m_array.length > newSize ? newSize : this.m_array.length;
	for (i = 0; i<len; ++i) {
		na.m_array[i] = this.m_array[i]
	}
	return na;
}

fan.sys.FloatArray.prototype.fill = function(val, times) {
	for (i = 0; i < times; ++i) {
		this.m_array[i] = val;
	}
	return this;
}

fan.sys.FloatArray.prototype.copyFrom = function(that, thatOffset, thisOffset, length) {
	if (this == that) {
		this.m_array.copyWithin(thisOffset, thisOffset, thisOffset+length)
		return this;
	}

	for (i = 0; i<length; ++i) {
		this.m_array[thisOffset + i] = that.m_array[i+thatOffset]
	}
	return this;
}

