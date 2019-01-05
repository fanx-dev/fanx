

fan.sys.BoolArray = fan.sys.Obj.$extend(fan.sys.Obj);
fan.sys.BoolArray.prototype.$ctor = function() {}
fan.sys.BoolArray.prototype.$typeof = function() { return fan.sys.BoolArray.$type; }

fan.sys.BoolArray.make = function(size) {
	self = new fan.sys.BoolArray()
	self.m_array = new Int8Array(size);
	return self
}

fan.sys.BoolArray.prototype.get = function(pos) {
	return this.m_array[pos]
}

fan.sys.BoolArray.prototype.set = function(pos, val) {
	this.m_array[pos] = val
}

fan.sys.BoolArray.prototype.size = function() {
	return this.m_array.length;
}

fan.sys.BoolArray.prototype.realloc = function(newSize) {
	if (this.m_array.length == newSize) return this;

	if (newSize > this.m_array.length) {
		for (i = this.m_array.length; i<newSize; ++i) {
			this.m_array.push(null)
		}
		return this;
	}

	na = fan.sys.BoolArray.make(newSize, this.m_of);
	len = this.m_array.length > newSize ? newSize : this.m_array.length;
	for (var i = 0; i<len; ++i) {
		na.m_array[i] = this.m_array[i]
	}
	return na;
}

fan.sys.BoolArray.prototype.fill = function(val, times) {
	for (var i = 0; i < times; ++i) {
		this.m_array[i] = val;
	}
	return this;
}

fan.sys.BoolArray.prototype.copyFrom = function(that, thatOffset, thisOffset, length) {
	if (this === that) {
		this.m_array.copyWithin(thisOffset, thatOffset, thatOffset+length)
		return this;
	}

	for (var i = 0; i<length; ++i) {
		this.m_array[thisOffset + i] = that.m_array[i+thatOffset]
	}
	return this;
}

