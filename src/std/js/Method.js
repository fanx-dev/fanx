//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   24 Mar 09  Andy Frank  Creation
//   20 May 09  Andy Frank  Refactor to new OO model
//

/**
 * Method.
 */
fan.std.Method = fan.sys.Obj.$extend(fan.std.Slot);

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

fan.std.Method.prototype.$ctor = function(parent, name, flags, returns, params, facets, generic)
{
  if (generic === undefined) generic = null;

  this.m_parent  = parent;
  this.m_name    = name;
  this.m_qname   = parent.qname() + "." + name;
  this.m_flags   = flags;
  this.m_returns = returns;
  this.m_params  = params;
  this.m_func    = new fan.std.MethodFunc(this, returns);
  this.m_$name   = this.$$name(name);
  this.m_$qname  = this.m_parent.m_$qname + '.' + this.m_$name;
  this.m_facets  = new fan.sys.Facets(facets);
  this.m_mask    = 0;//(generic != null) ? 0 : fan.std.Method.toMask(parent, returns, params);
  this.m_generic = generic;
}
/*
fan.std.Method.GENERIC = 0x01;
fan.std.Method.toMask = function(parent, returns, params)
{
  // we only use generics in Sys
  if (parent.pod().$name() != "sys") return 0;

  var p = returns.isGenericParameter() ? 1 : 0;
  for (var i=0; i<params.size(); ++i)
    p |= params.get(i).m_type.isGenericParameter() ? 1 : 0;

  var mask = 0;
  if (p != 0) mask |= fan.std.Method.GENERIC;
  return mask;
}
*/
//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

fan.std.Method.prototype.invoke = function(instance, args)
{
  var func = (this.isCtor() || this.isStatic())
    ? eval(this.m_$qname)
    : instance[this.m_$name];
  var vals = args==null ? [] : args.toJs();

  // if not found, assume this is primitive that needs
  // to map into a static call
  if (func == null && instance != null)
  {
    // Obj maps to ObjUtil
    qname = this.m_$qname;
    if (this.m_parent.m_qname === "sys::Obj")
      qname = "fan.sys.ObjUtil." + this.m_$name;

    func = eval(qname);
    vals.splice(0, 0, instance);
    instance = null;
  }

// TODO FIXIT: if func is null - most likley native
// method hasn't been implemented
if (func == null) fan.sys.ObjUtil.echo("### Method.invoke missing: " + this.m_$qname);

  return func.apply(instance, vals);
}

fan.std.Method.prototype.$typeof = function() { return fan.std.Method.$type; }
fan.std.Method.prototype.returns = function() { return this.m_returns; }
fan.std.Method.prototype.params  = function() { return this.m_params.ro(); }
fan.std.Method.prototype.func = function() { return this.m_func; }

//////////////////////////////////////////////////////////////////////////
// Generics
//////////////////////////////////////////////////////////////////////////

fan.std.Method.prototype.isGenericMethod = function() { return (this.m_mask & fan.std.Method.GENERIC) != 0; }
fan.std.Method.prototype.isGenericInstance = function() { return this.m_generic != null; }
fan.std.Method.prototype.getGenericMethod = function() { return this.m_generic; }

//////////////////////////////////////////////////////////////////////////
// Call Conveniences
//////////////////////////////////////////////////////////////////////////

fan.std.Method.prototype.callOn = function(target, args) { return this.invoke(target, args); }
fan.std.Method.prototype.call = function()
{
  var instance = null;
  var args = arguments;

  if (!this.isCtor() && !this.isStatic())
  {
    instance = args[0];
    args = Array.prototype.slice.call(args).slice(1);
  }

  return this.invoke(instance, fan.sys.List.makeFromJs(fan.sys.Obj.$type, args));
}

fan.std.Method.prototype.callList = function(args)
{
  var instance = null;
  if (!this.isCtor() && !this.isStatic())
  {
    instance = args.get(0);
    args = args.getRange(new fan.sys.Range(1, -1));
  }
  return this.invoke(instance, args);
}





//////////////////////////////////////////////////////////////////////////
// MethodFunc
//////////////////////////////////////////////////////////////////////////


//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   1 Aug 2013  Andy Frank  Break out from Method.js to fix dependency order
//

/**
 * MethodFunc.
 */
fan.std.MethodFunc = fan.sys.Obj.$extend(fan.sys.Func);
fan.std.MethodFunc.prototype.$ctor = function(method, returns)
{
  this.m_method = method;
  this.m_returns = returns;
  this.m_type = null;
}
fan.std.MethodFunc.prototype.returns = function() { return this.m_returns; }
fan.std.MethodFunc.prototype.arity = function() { return this.params().size(); }
fan.std.MethodFunc.prototype.params = function()
{
  // lazy load functions param
  if (this.m_fparams == null)
  {
    var mparams = this.m_method.m_params;
    var fparams = mparams;
    if ((this.m_method.m_flags & (fan.sys.FConst.Static|fan.sys.FConst.Ctor)) == 0)
    {
      var temp = [];
      temp[0] = new fan.std.Param("this", this.m_method.m_parent, 0);
      fparams = fan.sys.List.make(fan.std.Param.$type, temp.concat(mparams.toJs()));
    }
    this.m_fparams = fparams.ro();
  }
  return this.m_fparams;
}
fan.std.MethodFunc.prototype.method = function() { return this.m_method; }
fan.std.MethodFunc.prototype.isImmutable = function() { return true; }

fan.std.MethodFunc.prototype.$typeof = function()
{
  // lazy load type and params
  if (this.m_type == null)
  {
    this.m_type = fan.Sys.find("sys", "Func", true);
    /*
    var params = this.params();
    var types = [];
    for (var i=0; i<params.size(); i++)
      types.push(params.get(i).m_type);
    this.m_type = new fan.sys.FuncType(types, this.m_returns);
    */
  }
  return this.m_type;
}

fan.std.MethodFunc.prototype.call = function()
{
  return this.m_method.call.apply(this.m_method, arguments);
}

fan.std.MethodFunc.prototype.callList = function(args)
{
  return this.m_method.callList.apply(this.m_method, arguments);
}

fan.std.MethodFunc.prototype.callOn = function(obj, args)
{
  return this.m_method.callOn.apply(this.m_method, arguments);
}

// fan.std.MethodFunc.prototype.retype = function(t)
// {
//   if (t instanceof fan.sys.FuncType)
//   {
//     var params = [];
//     for (var i=0; i < t.pars.length; ++i)
//       params.push(new fan.std.Param(String.fromCharCode(i+65), t.pars[i], 0));
//     var paramList = fan.sys.List.make(fan.std.Param.$type, params);

//     var func = new fan.std.MethodFunc(this.m_method, t.ret);
//     func.m_type = t;
//     func.m_fparams = paramList;
//     return func;
//   }
//   else
//     throw fan.sys.ArgErr.make(fan.sys.Str.plus("Not a Func type: ", t));
// }
