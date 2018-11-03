//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 May 09  Andy Frank  Creation
//   20 May 09  Andy Frank  Refactor to new OO model
//

/**
 * Pod is a module containing Types.
 */
fan.std.Pod = fan.sys.Obj.$extend(fan.sys.Obj);

//////////////////////////////////////////////////////////////////////////
// Management
//////////////////////////////////////////////////////////////////////////

fan.std.Pod.of = function(obj)
{
  return fan.sys.Type.of(obj).pod();
}

fan.std.Pod.list = function()
{
  if (fan.std.Pod.$list == null)
  {
    var pods = fan.std.Pod.$pods;
    var list = fan.sys.List.make(fan.std.Pod.$type);
    for (var n in pods) list.add(pods[n]);
    fan.std.Pod.$list = list.sort().toImmutable();
  }
  return fan.std.Pod.$list;
}

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

fan.std.Pod.prototype.$ctor = function(name)
{
  this.m_name  = name;
  this.m_types = [];
  this.m_meta = [];
  this.m_version = fan.sys.Version.m_defVal;
}

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

fan.std.Pod.prototype.$typeof = function() { return fan.std.Pod.$type; }

fan.std.Pod.prototype.$name = function()
{
  return this.m_name;
}

fan.std.Pod.prototype.meta = function()
{
  return this.m_meta;
}

fan.std.Pod.prototype.version = function()
{
  return this.m_version;
}

fan.std.Pod.prototype.uri = function()
{
  if (this.m_uri == null) this.m_uri = fan.sys.Uri.fromStr("fan://" + this.m_name);
  return this.m_uri;
}

fan.std.Pod.prototype.toStr = function() { return this.m_name; }

//////////////////////////////////////////////////////////////////////////
// Types
//////////////////////////////////////////////////////////////////////////

fan.std.Pod.prototype.types = function()
{
  if (this.$typesArray == null)
  {
    var arr = [];
    for (p in this.m_types) arr.push(this.m_types[p]);
    this.$typesArray = fan.sys.List.make(fan.sys.Type.$type, arr);
  }
  return this.$typesArray;
}

fan.std.Pod.prototype.type = function(name, checked)
{
  if (checked === undefined) checked = true;
  var t = this.m_types[name];
  if (t == null && checked)
  {
    //fan.sys.ObjUtil.echo("UnknownType: " + this.m_name + "::" + name);
    //print("# UnknownType: " + this.m_name + "::" + name + "\n");
    throw fan.sys.UnknownTypeErr.make(this.m_name + "::" + name);
  }
  return t;
}

fan.std.Pod.prototype.locale = function(key, def)
{
  return fan.sys.Env.cur().locale(this, key, def);
}

// addType
fan.std.Pod.prototype.$at = function(name, baseQname, mixins, facets, flags)
{
  var qname = this.m_name + "::" + name;
  if (this.m_types[name] != null)
    throw fan.sys.Err.make("Type already exists " + qname);
  var t = new fan.sys.Type(qname, baseQname, mixins, facets, flags);
  this.m_types[name] = t;
  return t;
}

// addMixin
fan.std.Pod.prototype.$am = function(name, baseQname, mixins, facets, flags)
{
  var t = this.$at(name, baseQname, mixins, facets, flags);
  t.m_isMixin = true;
  return t;
}

//////////////////////////////////////////////////////////////////////////
// Static Methods
//////////////////////////////////////////////////////////////////////////

fan.std.Pod.find = function(name, checked)
{
  if (checked === undefined) checked = true;
  var p = fan.std.Pod.$pods[name];
  if (p == null && checked)
    throw fan.sys.UnknownPodErr.make(name);
  return p;
}

fan.std.Pod.$add = function(name)
{
  if (fan.std.Pod.$pods[name] != null)
    throw fan.sys.Err.make("Pod already exists " + name);
  var p = new fan.std.Pod(name);
  fan.std.Pod.$pods[name] = p;
  return p;
}
fan.std.Pod.$pods = [];

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

fan.std.Pod.prototype.log = function()
{
  if (this.m_log == null) this.m_log = fan.sys.Log.get(this.m_name);
  return this.m_log;
}
