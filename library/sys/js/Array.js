

fan.sys.Array = fan.sys.Obj.$extend(fan.sys.Obj);
fan.sys.Array.prototype.$ctor = function() {}
fan.sys.Array.prototype.$typeof = function() { return fan.sys.Array.$type; }

fan.sys.Array.make = function(size, type) {
  var self = new fan.sys.Array();
  if (type == "sys::Int8") {
    self.m_array = new Uint8ClampedArray(size);
  }
  else if (type == "sys::Int8") {
    self.m_array = new Uint8ClampedArray(size);
  }
  else if (type == "sys::Int16") {
    self.m_array = new Int16Array(size);
  }
  else if (type == "sys::Int32") {
    self.m_array = new Int32Array(size);
  }
  /*
  else if (type == "Int" || type == "Int64") {
    self.m_array = new Int64Array(size);
  }
  */
  else if (type == "sys::Float32") {
    self.m_array = new Float32Array(size);
  }
  else if (type == "sys::Float" || type == "sys::Float64") {
    self.m_array = new Float64Array(size);
  }
  else {
    self.m_array = new Array(size);
  }
  self.m_of = type;
  return self;
}

fan.sys.Array.prototype.get = function(pos) {
  return this.m_array[pos];
}

fan.sys.Array.prototype.set = function(pos, val) {
  this.m_array[pos] = val;
}

fan.sys.Array.prototype.size = function() {
  return this.m_array.length;
}

fan.sys.Array.realloc = function(self, newSize) {
  if (self.m_array.length == newSize) return self;

  if (newSize > self.m_array.length) {
    for (i = self.m_array.length; i<newSize; ++i) {
      self.m_array.push(null)
    }
    return self;
  }

  var na = fan.sys.Array.make(newSize, self.m_of);
  var len = self.m_array.length > newSize ? newSize : self.m_array.length;
  for (i = 0; i<len; ++i) {
    na.m_array[i] = self.m_array[i]
  }
  return na;
}

fan.sys.Array.fill = function(self, val, times) {
  for (var i = 0; i < times; ++i) {
    self.m_array[i] = val;
  }
  return;
}

fan.sys.Array.arraycopy = function(that, thatOffset, desc, descOffset, length) {
  if (desc === that) {
    desc.m_array.copyWithin(descOffset, thatOffset, thatOffset+length)
    return;
  }

  for (var i = 0; i<length; ++i) {
    desc.m_array[descOffset + i] = that.m_array[i+thatOffset]
  }
  return;
}

