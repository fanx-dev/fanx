


fan.sys.ObjArray = fan.sys.Obj.$extend(fan.sys.Obj);
fan.sys.ObjArray.prototype.$ctor = function() {}
fan.sys.ObjArray.prototype.$typeof = function() { return fan.sys.ObjArray.$type; }

fan.sys.ObjArray.make = function(size, of) {
	self = new fan.sys.ObjArray()
	self.m_array = new Array(size);
	self.m_of = of;
	return self
}

fan.sys.ObjArray.prototype.get = function(pos) {
	return this.m_array[pos]
}

fan.sys.ObjArray.prototype.set = function(pos, val) {
	this.m_array[pos] = val
}

fan.sys.ObjArray.prototype.size = function() {
	return this.m_array.length;
}

fan.sys.ObjArray.prototype.realloc = function(newSize) {
	if (this.m_array.length == newSize) return this;

	if (newSize > this.m_array.length) {
		for (i = this.m_array.length; i<newSize; ++i) {
			this.m_array.push(null)
		}
		return this;
	}

	var na = fan.sys.ObjArray.make(newSize, this.m_of);
	var len = this.m_array.length > newSize ? newSize : this.m_array.length;
	for (var i = 0; i<len; ++i) {
		na.m_array[i] = this.m_array[i]
	}
	return na;
}

fan.sys.ObjArray.prototype.fill = function(val, times) {
	for (var i = 0; i < times; ++i) {
		this.m_array[i] = val;
	}
	return this;
}

fan.sys.ObjArray.prototype.copyFrom = function(that, thatOffset, thisOffset, length) {
	if (this == that) {
		this.m_array.copyWithin(thisOffset, thisOffset, thisOffset+length)
		return this;
	}

	for (var i = 0; i<length; ++i) {
		this.m_array[thisOffset + i] = that.m_array[i+thatOffset]
	}
	return this;
}

