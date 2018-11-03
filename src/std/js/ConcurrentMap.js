
fan.std.ConcurrentMap = fan.sys.Obj.$extend(fan.sys.Obj);
fan.std.ConcurrentMap.prototype.$ctor = function() {}
fan.std.ConcurrentMap.prototype.$typeof = function() { return fan.sys.AtomicRef.$type; }

fan.std.ConcurrentMap.make = function(capacity) {
  self = new fan.std.ConcurrentMap();
  if (capacity === undefined) v = 256;
  self.m_val = new Map();
  return self;
}

fan.std.ConcurrentMap.prototype.isEmpty = function() {
  return this.m_val.size == 0;
}

fan.std.ConcurrentMap.prototype.size = function() {
  return this.m_val;
}

fan.std.ConcurrentMap.prototype.get = function(k) {
  return this.m_val.get(k);
}

fan.std.ConcurrentMap.prototype.set = function(k, v) {
  fan.std.ConcurrentMap.checkImmutable(v);
  return this.m_val.set(k, v);
}

fan.std.ConcurrentMap.prototype.add = function(k, v) {
  if (this.m_val.has(k)) throw fan.sys.Err.make("Duplicate key:  " + key);
  fan.std.ConcurrentMap.checkImmutable(values);
  return this.m_val.set(k, v);
}

fan.std.ConcurrentMap.prototype.getOrAdd = function(k, defVal) {
  if (this.m_val.has(k)) {
    return this.m_val.get(k)
  }
  this.m_val.set(k, defVal)
  return defVal;
}

fan.std.ConcurrentMap.prototype.setAll = function(m) {
  for (var [key, value] of this.m_val) {
    fan.std.ConcurrentMap.checkImmutable(value);
    m.set(key, value)
  }
  return this;
}

fan.std.ConcurrentMap.prototype.remove = function(k) {
  old = this.m_val.get(k)
  this.m_val.delete(k)
  return old;
}

fan.std.ConcurrentMap.prototype.clear = function(m) {
  this.m_val.clear();
}


fan.std.ConcurrentMap.prototype.each = function(f) {
  for (var [key, value] of this.m_val) {
    f.call(value, key)
  }
}

fan.std.ConcurrentMap.prototype.eachWhile = function(f) {
  for (var [key, value] of this.m_val) {
    var r = f.call(value, key)
    if (r == null) return r;
  }
  return null;
}

fan.std.ConcurrentMap.prototype.containsKey = function(k) {
  return this.m_val.has(k)
}

fan.std.ConcurrentMap.prototype.keys = function() {
  var list = fan.sys.List.make(this.m_val.size);
  for (var key of myMap.keys()) {
    list.add(key)
  }
  return list;
}

fan.std.ConcurrentMap.prototype.vals = function() {
  var list = fan.sys.List.make(this.m_val.size);
  for (var key of myMap.values()) {
    list.add(key)
  }
  return list;
}

fan.std.ConcurrentMap.checkImmutable = function(val) {
  if (fan.sys.Obj.isImmutable(val))
    return val;
  else
    throw NotImmutableErr.make();
}
