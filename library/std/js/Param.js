//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 May 09  Andy Frank  Creation
//   20 May 09  Andy Frank  Refactor to new OO model
//

/**
 * Param.
 */
fan.std.Param = fan.sys.Obj.$extend(fan.sys.Obj);

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

fan.std.Param.prototype.$ctor = function(name, type, hasDefault)
{
  this.m_name = name;
  this.m_type = (type instanceof fan.std.Type) ? type : fan.std.Type.find(type);
  this.m_hasDefault = hasDefault;
}

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

fan.std.Param.prototype.$name = function() { return this.m_name; }
fan.std.Param.prototype.type = function() { return this.m_type; }
fan.std.Param.prototype.hasDefault = function() { return this.m_hasDefault; }
fan.std.Param.prototype.$typeof = function() { return fan.std.Param.$type; }
fan.std.Param.prototype.toStr = function() { return this.m_type.toStr() + " " + this.m_name; }
