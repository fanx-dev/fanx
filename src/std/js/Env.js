//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 Jan 10  Andy Frank  Creation
//

/**
 * Env.
 */
fan.std.Env = fan.sys.Obj.$extend(fan.sys.Obj);

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

fan.std.Env.cur = function()
{
  if (fan.std.Env.$cur == null) fan.std.Env.$cur = new fan.std.Env();
  return fan.std.Env.$cur;
}

fan.std.Env.prototype.$ctor = function()
{
  this.m_args = fan.sys.List.make(fan.sys.Str.$type).toImmutable();

  this.m_index = fan.sys.Map.make(fan.sys.Str.$type, new fan.sys.ListType(fan.sys.Str.$type));
  this.m_index = this.m_index.toImmutable();

  this.m_vars = fan.sys.Map.make(fan.sys.Str.$type, fan.sys.Str.$type)
  this.m_vars.caseInsensitive$(true);
  this.m_vars = this.m_vars.toImmutable();

  // pod props map, keyed by pod.name
  this.m_props = fan.sys.Map.make(fan.sys.Str.$type, fan.sys.Map.$type);

  // env.out
  this.m_out = new fan.sys.SysOutStream(new fan.sys.ConsoleOutStream());
}

fan.std.Env.prototype.$setIndex = function(index)
{
  if (index.$typeof().toStr() != "[sys::Str:sys::Str[]]") throw fan.sys.ArgErr.make("Invalid type");
  this.m_index = index.toImmutable();
}

fan.std.Env.prototype.$setVars = function(vars)
{
  if (vars.$typeof().toStr() != "[sys::Str:sys::Str]") throw fan.sys.ArgErr.make("Invalid type");
  if (!vars.caseInsensitive()) throw fan.sys.ArgErr.make("Map must be caseInsensitive");
  this.m_vars = vars.toImmutable();
}

fan.std.Env.noDef = "_Env_nodef_";

// used to display locale keys
fan.std.Env.localeTestMode = false;

// check if running under NodeJS
fan.std.Env.$nodejs = this.window !== this;

//////////////////////////////////////////////////////////////////////////
// Obj
//////////////////////////////////////////////////////////////////////////

fan.std.Env.prototype.$typeof = function() { return fan.std.Env.$type; }

fan.std.Env.prototype.toStr = function() { return this.$typeof().toString(); }

//////////////////////////////////////////////////////////////////////////
// Non-Virtuals
//////////////////////////////////////////////////////////////////////////

fan.std.Env.prototype.runtime = function() { return "js"; }

// parent
// os
// arch
// platform
// idHash

//////////////////////////////////////////////////////////////////////////
// Virtuals
//////////////////////////////////////////////////////////////////////////

fan.std.Env.prototype.args = function() { return this.m_args; }

fan.std.Env.prototype.vars = function() { return this.m_vars; }

fan.std.Env.prototype.diagnostics = function()
{
  var map = fan.std.Map.make(fan.sys.Str.$type, fan.sys.Obj.$type);
  return map;
}

fan.std.Env.prototype.out = function() { return this.m_out; }

fan.std.Env.prototype.homeDir = function() { return this.m_homeDir; }

fan.std.Env.prototype.workDir = function() { return this.m_workDir; }

fan.std.Env.prototype.tempDir = function() { return this.m_tempDir; }

//////////////////////////////////////////////////////////////////////////
// State
//////////////////////////////////////////////////////////////////////////

fan.std.Env.prototype.index = function(key)
{
  return this.m_index.get(key, fan.sys.Str.$type.emptyList());
}

fan.std.Env.prototype.props = function(pod, uri, maxAge)
{
  var key = pod.$name() + ':' + uri.toStr();
  return this.$props(key);
}

fan.std.Env.prototype.config = function(pod, key, def)
{
  if (def === undefined) def = null;
  return this.props(pod, fan.std.Env.m_configProps, fan.std.Duration.m_oneMin).get(key, def);
}

fan.std.Env.prototype.locale = function(pod, key, def, locale)
{
  // if in test mode return pod::key
  if (fan.std.Env.localeTestMode &&
      key.indexOf(".browser") == -1 &&
      key.indexOf(".icon") == -1 &&
      key.indexOf(".accelerator") == -1 &&
      pod.$name() != "sys")
    return pod + "::" + key;

  if (def === undefined) def = fan.std.Env.noDef;
  if (locale === undefined) locale = fan.std.Locale.cur();

  var val;
  var maxAge = fan.std.Duration.m_maxVal;

  // 1. 'props(pod, `locale/{locale}.props`)'
  val = this.props(pod, locale.m_strProps, maxAge).get(key, null);
  if (val != null) return val;

  // 2. 'props(pod, `locale/{lang}.props`)'
  val = this.props(pod, locale.m_langProps, maxAge).get(key, null);
  if (val != null) return val;

  // 3. 'props(pod, `locale/en.props`)'
  val = this.props(pod, fan.std.Env.m_localeEnProps, maxAge).get(key, null);
  if (val != null) return val;

  // 4. Fallback to 'pod::key' unless 'def' specified
  if (def === fan.std.Env.noDef) return pod + "::" + key;
  return def;
}

fan.std.Env.prototype.$props = function(key)
{
  var map = this.m_props.get(key);
  if (map == null)
  {
    map = fan.sys.Map.make(fan.sys.Str.$type, fan.sys.Str.$type)
    this.m_props.add(key, map);
  }
  return map;
}
