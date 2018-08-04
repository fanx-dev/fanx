//
// Copyright (c) 2015, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   17 Aug 2015  Matthew Giannini  Creation
//

fan.concurrent.AtomicIntPeer = fan.sys.Obj.$extend(fan.sys.Obj);
fan.concurrent.AtomicIntPeer.prototype.$ctor = function() {}

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

fan.concurrent.AtomicIntPeer.prototype.m_val = 0;
fan.concurrent.AtomicIntPeer.prototype.val = function(self) { return this.m_val; }
fan.concurrent.AtomicIntPeer.prototype.val$ = function(self, val) { this.m_val = val; }

fan.concurrent.AtomicIntPeer.prototype.getAndSet = function(self, val) {
  var old = this.m_val;
  this.m_val = val;
  return old;
}

fan.concurrent.AtomicIntPeer.prototype.compareAndSet = function(self, expect, update) {
  if (this.m_val == expect) {
    this.m_val = update;
    return true;
  }
  return false;
}

fan.concurrent.AtomicIntPeer.prototype.getAndIncrement = function(self) {
  return this.getAndAdd(self, 1);
}

fan.concurrent.AtomicIntPeer.prototype.getAndDecrement = function(self) {
  return this.getAndAdd(self, -1);
}

fan.concurrent.AtomicIntPeer.prototype.getAndAdd = function(self, delta) {
  var old = this.m_val;
  this.m_val = old + delta;
  return old;
}

fan.concurrent.AtomicIntPeer.prototype.incrementAndGet = function(self) {
  return this.addAndGet(self, 1);
}

fan.concurrent.AtomicIntPeer.prototype.decrementAndGet = function(self) {
  return this.addAndGet(self, -1)
}

fan.concurrent.AtomicIntPeer.prototype.addAndGet = function(self, delta) {
  this.m_val = this.m_val + delta;
  return this.m_val;
}

fan.concurrent.AtomicIntPeer.prototype.increment = function(self) {
  this.add(self, 1);
}

fan.concurrent.AtomicIntPeer.prototype.decrement = function(self) {
  this.add(self, -1)
}

fan.concurrent.AtomicIntPeer.prototype.add = function(self, delta) {
  this.m_val = this.m_val + delta;
}