//
// Copyright (c) 2019, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   10 Jun 19  Matthew Giannini  Creation
//

/**
 * ConcurrentMap
 */
fan.std.ConcurrentMap = fan.sys.Obj.$extend(fan.sys.Obj);

//////////////////////////////////////////////////////////////////////////
// Constructors
//////////////////////////////////////////////////////////////////////////

fan.std.ConcurrentMap.make = function(capacity)
{
  var self = new fan.std.ConcurrentMap();
  self.m_map = fan.std.Map.make(fan.sys.Obj.$type, fan.sys.Obj.$type)
  return self;
}

fan.std.ConcurrentMap.prototype.$ctor = function() {}

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

fan.std.ConcurrentMap.prototype.$typeof = function() { return fan.std.ConcurrentMap.$type; }

//////////////////////////////////////////////////////////////////////////
// ConcurrentMap
//////////////////////////////////////////////////////////////////////////

fan.std.ConcurrentMap.prototype.isEmpty = function() { return this.m_map.isEmpty(); }

fan.std.ConcurrentMap.prototype.size = function() { return this.m_map.size(); }

fan.std.ConcurrentMap.prototype.get = function(key) { return this.m_map.get(key); }

fan.std.ConcurrentMap.prototype.set = function(key, val)
{
  this.m_map.set(key, this.$checkImmutable(val));
}
fan.std.ConcurrentMap.prototype.getAndSet = function(key, val)
{
  var old = this.m_map.get(key);
  this.m_map.set(key, this.$checkImmutable(val));
  return old;
}
fan.std.ConcurrentMap.prototype.add = function(key, val)
{
  if (this.containsKey(key)) throw fan.sys.Err("Key already mapped: " + key);
  this.m_map.add(key, this.$checkImmutable(val));
  console.log(this.m_map.toStr());
}

fan.std.ConcurrentMap.prototype.getOrAdd = function(key, defVal)
{
  var val = this.m_map.get(key);
  if (val == null) { this.m_map.add(key, this.$checkImmutable(val = defVal)); }
  return val;
}

fan.std.ConcurrentMap.prototype.setAll = function(m)
{
  if (m.isImmutable()) this.m_map.setAll(m);
  else
  {
    var vals = m.vals();
    for (i=0; i<vals.size(); ++i) { this.$checkImmutable(vals.get(i)); }
    this.m_map.setAll(m);
  }
  return this;
}

fan.std.ConcurrentMap.prototype.remove = function(key) { return this.m_map.remove(key); }

fan.std.ConcurrentMap.prototype.clear = function() { this.m_map.clear(); }

fan.std.ConcurrentMap.prototype.each = function(f) { this.m_map.each(f); }

fan.std.ConcurrentMap.prototype.eachWhile = function(f) { return this.m_map.eachWhile(f); }

fan.std.ConcurrentMap.prototype.containsKey = function(key) { return this.m_map.containsKey(key); }

fan.std.ConcurrentMap.prototype.keys = function(of)
{
  var array = [];
  this.m_map.$each(function(b) { array.push(b.key); });
  return fan.sys.List.make(of, array);
}

fan.std.ConcurrentMap.prototype.vals = function(of)
{
  var array = [];
  this.m_map.$each(function(b) { array.push(b.val); });
  return fan.sys.List.make(of, array);
}

fan.std.ConcurrentMap.prototype.$checkImmutable = function(val)
{
  if (fan.sys.ObjUtil.isImmutable(val)) return val;
  else throw fan.sys.NotImmutableErr.make();
}