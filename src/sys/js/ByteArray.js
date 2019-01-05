

fan.sys.ByteArray = fan.sys.Obj.$extend(fan.sys.Obj);
fan.sys.ByteArray.prototype.$ctor = function() {}
fan.sys.ByteArray.prototype.$typeof = function() { return fan.sys.ByteArray.$type; }

fan.sys.ByteArray.make = function(size) {
	self = new fan.sys.ByteArray()
	self.m_array = new Uint8ClampedArray(size);
	return self
}

fan.sys.ByteArray.prototype.get = function(pos) {
	return this.m_array[pos]
}

fan.sys.ByteArray.prototype.set = function(pos, val) {
	this.m_array[pos] = val
}

fan.sys.ByteArray.prototype.size = function() {
	return this.m_array.length;
}

fan.sys.ByteArray.prototype.realloc = function(newSize) {
	if (this.m_array.length == newSize) return this;

	if (newSize > this.m_array.length) {
		for (i = this.m_array.length; i<newSize; ++i) {
			this.m_array.push(null)
		}
		return this;
	}

	var na = fan.sys.ByteArray.make(newSize, this.m_of);
	var len = this.m_array.length > newSize ? newSize : this.m_array.length;
	for (i = 0; i<len; ++i) {
		na.m_array[i] = this.m_array[i]
	}
	return na;
}

fan.sys.ByteArray.prototype.fill = function(val, times) {
	for (var i = 0; i < times; ++i) {
		this.m_array[i] = val;
	}
	return this;
}

fan.sys.ByteArray.prototype.copyFrom = function(that, thatOffset, thisOffset, length) {
	if (this === that) {
		this.m_array.copyWithin(thisOffset, thatOffset, thatOffset+length)
		return this;
	}

	for (var i = 0; i<length; ++i) {
		this.m_array[thisOffset + i] = that.m_array[i+thatOffset]
	}
	return this;
}

