

fan.sys.IntArray = fan.sys.Obj.$extend(fan.sys.Obj);
fan.sys.IntArray.prototype.$ctor = function() {}
fan.sys.IntArray.prototype.$typeof = function() { return fan.sys.IntArray.$type; }

fan.sys.IntArray.makeS1(long size) {
	self = new fan.sys.IntArray()
	self.m_array = new Int8Array(size);
	return self
}

fan.sys.IntArray.makeU1(long size) {
	self = new fan.sys.IntArray()
	self.m_array = new Uint8Array(size);
	return self
}

fan.sys.IntArray.makeS2(long size) {
	self = new fan.sys.IntArray()
	self.m_array = new Int16Array(size);
	return self
}

fan.sys.IntArray.makeU2(long size) {
	self = new fan.sys.IntArray()
	self.m_array = new Uint16Array(size);
	return self
}

fan.sys.IntArray.makeS4(long size) {
	self = new fan.sys.IntArray()
	self.m_array = new Int32Array(size);
	return self
}

fan.sys.IntArray.makeU4(long size) {
	self = new fan.sys.IntArray()
	self.m_array = new Uint32Array(size);
	return self
}

fan.sys.IntArray.makeS8(long size) {
	self = new fan.sys.IntArray()
	self.m_array = new Int8Array(size);
	return self
}

fan.sys.IntArray.prototype.get = function(pos) {
	return this.m_array[pos]
}

fan.sys.IntArray.prototype.set = function(pos, val) {
	this.m_array[pos] = val
}

fan.sys.IntArray.prototype.size = function() {
	return this.m_size;
}

fan.sys.IntArray.prototype.realloc = function(newSize) {
	if (this.m_array.length == newSize) return this;

	if (newSize > this.m_array.length) {
		for (i = this.m_array.length; i<newSize; ++i) {
			this.m_array.push(null)
		}
		return this;
	}

	na = fan.sys.IntArray.make(newSize, of);
	len = this.m_array.length > newSize ? newSize : this.m_array.length;
	for (i = 0; i<len; ++i) {
		na.m_array[i] = this.m_array[i]
	}
	return na;
}

fan.sys.IntArray.prototype.fill = function(val, times) {
	for (i = 0; i < times; ++i) {
		this.m_array[i] = val;
	}
	return this;
}

fan.sys.IntArray.prototype.copyFrom = function(that, thatOffset, thisOffset, length) {
	if (this == that) {
		this.m_array.copyWithin(thisOffset, thisOffset, thisOffset+length)
		return this;
	}

	for (i = 0; i<length; ++i) {
		this.m_array[thisOffset + i] = that.m_array[i+thatOffset]
	}
	return this;
}

