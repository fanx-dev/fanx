//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   2 Junc 09  Andy Frank  Creation
//   13 May 10  Andy Frank  Move from sys to concurrent
//

/**
 * Actor.
 */
fan.concurrent.Actor = fan.sys.Obj.$extend(fan.sys.Obj);
fan.concurrent.Actor.prototype.$ctor = function() {}
fan.concurrent.Actor.prototype.$typeof = function() { return fan.concurrent.Actor.$type; }

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

fan.concurrent.Actor.locals = function()
{
  if (fan.concurrent.Actor.$locals == null)
  {
    var k = fan.sys.Str.$type;
    var v = fan.sys.Obj.$type.toNullable();
    fan.concurrent.Actor.$locals = fan.sys.Map.make(k, v);
  }
  return fan.concurrent.Actor.$locals;
}
fan.concurrent.Actor.$locals = null;

