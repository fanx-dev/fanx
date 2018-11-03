//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   4 Jun 10  Brian Frank  Creation
//

/**
 * Unsafe.
 */
fan.std.Unsafe = fan.sys.Obj.$extend(fan.sys.Obj);

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

fan.std.Unsafe.make = function(val)
{
  var self = new fan.std.Unsafe();
  self.m_val = val;
  return self;
}

fan.std.Unsafe.prototype.$ctor = function()
{
}

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

fan.std.Unsafe.prototype.$typeof = function () {
  return fan.std.Unsafe.$type;
}

fan.std.Unsafe.prototype.val = function() { return this.m_val; }

fan.std.Unsafe.prototype.get = function() { return this.m_val; }

