//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   27 Feb 09  Andy Frank  Creation
//   20 May 09  Andy Frank  Refactor to new OO model
//

fan.sys.EnumPeer = function(){}

fan.sys.EnumPeer.doFromStr = function(type, name, checked)
{
  // the compiler marks the value fields with the Enum flag
  var t = fan.sys.Type.find(type)
  var slot = t.slot(name, false);
  if (slot != null && (slot.m_flags & fan.sys.FConst.Enum) != 0)
  {
    try
    {
      return slot.get(null);
    }
    catch (err) {}
  }
  if (!checked) return null;
  throw fan.sys.ParseErr.makeStr(t.qname(), name);
}

