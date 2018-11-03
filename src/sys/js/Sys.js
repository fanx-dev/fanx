//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 Jan 10  Andy Frank  Creation
//

fan.sys.Sys = fan.sys.Obj.$extend(fan.sys.Obj);
fan.sys.Sys.prototype.$ctor = function() {}
/*
//////////////////////////////////////////////////////////////////////////
// Init Types
//////////////////////////////////////////////////////////////////////////

fan.sys.Sys.genericParamTypes = [];

fan.sys.Sys.initGenericParamTypes = function()
{
  fan.sys.Sys.AType = fan.sys.Sys.initGeneric('A');
  fan.sys.Sys.BType = fan.sys.Sys.initGeneric('B');
  fan.sys.Sys.CType = fan.sys.Sys.initGeneric('C');
  fan.sys.Sys.DType = fan.sys.Sys.initGeneric('D');
  fan.sys.Sys.EType = fan.sys.Sys.initGeneric('E');
  fan.sys.Sys.FType = fan.sys.Sys.initGeneric('F');
  fan.sys.Sys.GType = fan.sys.Sys.initGeneric('G');
  fan.sys.Sys.HType = fan.sys.Sys.initGeneric('H');
  fan.sys.Sys.KType = fan.sys.Sys.initGeneric('K');
  fan.sys.Sys.LType = fan.sys.Sys.initGeneric('L');
  fan.sys.Sys.MType = fan.sys.Sys.initGeneric('M');
  fan.sys.Sys.RType = fan.sys.Sys.initGeneric('R');
  fan.sys.Sys.VType = fan.sys.Sys.initGeneric('V');
}

fan.sys.Sys.initGeneric = function(ch)
{
  var name = ch;
  try
  {
    var pod = fan.sys.Pod.find("sys");
    return fan.sys.Sys.genericParamTypes[ch] = pod.$at(name, "sys::Obj", [], 0);
  }
  catch (err)
  {
    throw initFail("generic " + name, e);
  }
}

fan.sys.Sys.genericParamType = function(name)
{
  if (name.length == 1)
    return fan.sys.Sys.genericParamTypes[name];
  else
    return null;
}

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

fan.sys.Sys.initWarn = function(field, e)
{
  fan.sys.ObjUtil.echo("WARN: cannot init Sys." + field);
  fan.sys.ObjUtil.echo(e);
  //e.printStackTrace();
}

fan.sys.Sys.initFail = function(field, e)
{
  fan.sys.ObjUtil.echo("ERROR: cannot init Sys." + field);
  fan.sys.ObjUtil.echo(e);
  //e.printStackTrace();
  throw new Error("Cannot boot fan: " + e);
}

*/
