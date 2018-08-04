//
// Copyright (c) 2015, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   17 Aug 2015  Matthew Giannini  Creation
//

fan.concurrent.AtomicBoolPeer = fan.sys.Obj.$extend(fan.sys.Obj);
fan.concurrent.AtomicBoolPeer.prototype.$ctor = function() {}

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

fan.concurrent.AtomicBoolPeer.prototype.m_val = false;
fan.concurrent.AtomicBoolPeer.prototype.val = function(self) { return this.m_val; }
fan.concurrent.AtomicBoolPeer.prototype.val$ = function(self, val) { this.m_val = val; }

fan.concurrent.AtomicBoolPeer.prototype.getAndSet = function(self, val) {
  var old = this.m_val;
  this.m_val = val;
  return old;
}

fan.concurrent.AtomicBoolPeer.prototype.compareAndSet = function(self, expect, update) {
  if (this.m_val == expect) {
    this.m_val = update;
    return true;
  }
  return false;
}
