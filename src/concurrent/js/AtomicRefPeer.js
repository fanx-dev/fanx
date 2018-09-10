//
// Copyright (c) 2012, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2 Nov 2012  Andy Frank  Creation
//

/**
 * AtomicRefPeer.
 */
fan.concurrent.AtomicRefPeer = fan.sys.Obj.$extend(fan.sys.Obj);
fan.concurrent.AtomicRefPeer.prototype.$ctor = function() {}

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

fan.concurrent.AtomicRefPeer.prototype.m_val = null;
fan.concurrent.AtomicRefPeer.prototype.val = function(self) { return this.m_val; }
fan.concurrent.AtomicRefPeer.prototype.val$ = function(self, val)
{
  if (!fan.sys.ObjUtil.isImmutable(val)) throw fan.sys.NotImmutableErr.make();
  this.m_val = val;
}

fan.concurrent.AtomicRefPeer.prototype.getAndSet = function(self, val)
{
  if (!fan.sys.ObjUtil.isImmutable(val)) throw fan.sys.NotImmutableErr.make();
  var old = this.m_val;
  this.m_val = val;
  return old;
}

fan.concurrent.AtomicRefPeer.prototype.compareAndSet = function(self, expect, update)
{
  if (!fan.sys.ObjUtil.isImmutable(update)) throw fan.sys.NotImmutableErr.make();
  if (this.m_val != expect) return false;
  this.m_val = update;
  return true;
}
