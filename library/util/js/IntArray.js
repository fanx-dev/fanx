

fan.util.IntArray = fan.sys.Obj.$extend(fan.sys.Obj);
fan.util.IntArray.prototype.$ctor = function() {}
fan.util.IntArray.prototype.$typeof = function() { return fan.util.IntArray.$type; }

fan.util.IntArray.makeS1 = function(size) {
	self = new fan.util.IntArray()
	self.m_array = new Int8Array(size);
	return self
}

fan.util.IntArray.makeU1 = function(size) {
	self = new fan.util.IntArray()
	self.m_array = new Uint8Array(size);
	return self
}

fan.util.IntArray.makeS2 = function(size) {
	self = new fan.util.IntArray()
	self.m_array = new Int16Array(size);
	return self
}

fan.util.IntArray.makeU2 = function(size) {
	self = new fan.util.IntArray()
	self.m_array = new Uint16Array(size);
	return self
}

fan.util.IntArray.makeS4 = function(size) {
	self = new fan.util.IntArray()
	self.m_array = new Int32Array(size);
	return self
}

fan.util.IntArray.makeU4 = function(size) {
	self = new fan.util.IntArray()
	self.m_array = new Uint32Array(size);
	return self
}

fan.util.IntArray.makeS8 = function(size) {
	self = new fan.util.IntArray()
	self.m_array = new Int8Array(size);
	return self
}

fan.util.IntArray.prototype.get = function(pos) {
	return this.m_array[pos]
}

fan.util.IntArray.prototype.set = function(pos, val) {
	this.m_array[pos] = val
}

fan.util.IntArray.prototype.size = function() {
	return this.m_array.length;
}

fan.util.IntArray.prototype.realloc = function(newSize) {
	if (this.m_array.length == newSize) return this;

	if (newSize > this.m_array.length) {
		for (i = this.m_array.length; i<newSize; ++i) {
			this.m_array.push(null)
		}
		return this;
	}

	var na = fan.util.IntArray.make(newSize, this.m_of);
	var len = this.m_array.length > newSize ? newSize : this.m_array.length;
	for (var i = 0; i<len; ++i) {
		na.m_array[i] = this.m_array[i]
	}
	return na;
}

fan.util.IntArray.prototype.fill = function(val, times) {
	for (var i = 0; i < times; ++i) {
		this.m_array[i] = val;
	}
	return this;
}

fan.util.IntArray.prototype.copyFrom = function(that, thatOffset, thisOffset, length) {
	if (this === that) {
		this.m_array.copyWithin(thisOffset, thatOffset, thatOffset+length)
		return this;
	}

	for (var i = 0; i<length; ++i) {
		this.m_array[thisOffset + i] = that.m_array[i+thatOffset]
	}
	return this;
}

