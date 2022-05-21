//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   24 Mar 09  Andy Frank  Creation
//   20 May 09  Andy Frank  Refactor to new OO model
//

/**
 * Func.
 */
fan.sys.Func = fan.sys.Obj.$extend(fan.sys.Obj);

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

fan.sys.Func.prototype.$ctor = function()
{
}

fan.sys.Func.make$closure = function(spec, func)
{
  var self = new fan.sys.Func();
  self.m_params = spec.m_params;
  self.m_return = spec.m_type.ret;
  self.m_type   = spec.m_type;
  self.m_func   = func;
  return self;
}

fan.sys.Func.make = function(params, ret, func)
{
  var self = new fan.sys.Func();
  fan.sys.Func.make$(self, params, ret, func);
  return self;
}

fan.sys.Func.make$ = function(self, params, ret, func)
{
  // var types = [];
  // for (var i=0; i<params.size(); i++)
  //   types.push(params.get(i).m_type);

  self.m_params = params;
  self.m_return = ret;
  self.m_type   = fan.sys.Sys.find("sys", "Func", true);
  self.m_func   = func;
}

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

fan.sys.Func.prototype.$typeof = function() { return fan.sys.Func.$type; }

fan.sys.Func.prototype.isImmutable = function()
{
  return true;
}

fan.sys.Func.prototype.toImmutable = function()
{
  if (this.isImmutable()) return this;
  throw fan.sys.NotImmutableErr.make("Func");
}

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

fan.sys.Func.prototype.params = function() { return this.m_params; }
fan.sys.Func.prototype.arity = function() { return this.m_params.size(); }
fan.sys.Func.prototype.returns = function() { return this.m_return; }
fan.sys.Func.prototype.method = function() { return null; }

fan.sys.Func.prototype.call = function() { return this.m_func.apply(null, arguments); }
fan.sys.Func.prototype.callList = function(args) { return this.m_func.apply(null, args===null?null:args.toJs()); }
fan.sys.Func.prototype.callOn = function(obj, args) { return this.m_func.apply(obj, args===null?null:args.toJs()); }

fan.sys.Func.prototype.enterCtor = function(obj) {}
fan.sys.Func.prototype.exitCtor = function() {}
fan.sys.Func.prototype.checkInCtor = function(obj) {}

fan.sys.Func.prototype.toStr = function() { return "sys::Func"; }

/*
fan.sys.Func.prototype.retype = function(t)
{
  if (t instanceof fan.sys.FuncType)
  {
    var params = [];
    for (var i=0; i < t.pars.length; ++i)
      params.push(new fan.std.Param(String.fromCharCode(i+65), t.pars[i], 0));
    var paramList = fan.sys.List.make(fan.std.Param.$type, params);
    return fan.sys.Func.make(paramList, t.ret, this.m_func);
  }
  else
    throw fan.sys.ArgErr.make(fan.sys.Str.plus("Not a Func type: ", t));
}
*/

fan.sys.Func.prototype.bind = function(args) {
  if (args.size() == 0) return this;
  return fan.sys.BindFunc.make(this, args);
}

fan.sys.BindFuncPeer = function() {};
fan.sys.BindFuncPeer.call = function(self) {
  var args = fan.sys.List.make(8);
  for(var i=1; i<arguments.length; i++) {
    var a = arguments[i];
    args.add(a);
  }
  return self.callList(args);
}


/*************************************************************************
 * ClosureFuncSpec
 ************************************************************************/

fan.sys.ClosureFuncSpec$ = function(name, ret, params)
{
  var types = [];
  var paramDefs = [];
  var i, param;

  if (params.length % 3 != 0) {
   throw fan.sys.ArgErr("Invalid params " + params.toString);
  }

  for (i=0; i<params.length; i+=3) {
    param = new fan.std.Param(params[i], params[i+1], params[i+2]);
    paramDefs.push(param);
    types.push(param.m_type);
  }

  this.m_params = (fan.sys.List.make(fan.std.Param.$type, paramDefs));
  this.m_params.m_readOnly = true;
  this.m_params.m_immutable = true;
  var type = new fan.std.Type(name, "sys::Func", [], "", 0);
  this.m_type = type;//fan.sys.ObjUtil.toImmutable(new fan.sys.FuncType(types, ret));
}

