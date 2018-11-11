//
// Copyright (c) 2011, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   31 May 2011  Andy Frank  Creation
//

/**
 * Facets manages facet meta-data as a Str:Obj map.
 */
fan.sys.Facets = fan.sys.Obj.$extend(fan.sys.Obj);
fan.sys.Facets.prototype.$ctor = function(map)
{
  this.m_map = map;
  this.m_list = null;
}

fan.sys.Facets.empty = function()
{
  var x = fan.sys.Facets.m_emptyVal;
  if (x == null) x = fan.sys.Facets.m_emptyVal = new fan.sys.Facets({});
  return x;
}

fan.sys.Facets.makeTransient = function()
{
  var x = fan.sys.Facets.m_transientVal;
  if (x == null)
  {
    var m = {};
    m[fan.sys.Transient.$type.qname()] = "";
    x = fan.sys.Facets.m_transientVal = new fan.sys.Facets(m);
  }
  return x;
}

fan.sys.Facets.prototype.list = function()
{
  if (this.m_list == null)
  {
    this.m_list = fan.sys.List.make(8, fan.sys.Facet.$type);
    for (var key in this.m_map)
    {
      var type = fan.sys.Type.find(key);
      this.m_list.add(this.get(type, true));
    }
    this.m_list = this.m_list.toImmutable();
  }
  return this.m_list;
}

fan.sys.Facets.prototype.get = function(type, checked)
{
  var val = this.m_map[type.qname()];
  if (typeof val == "string")
  {
    var f = this.decode(type, val);
    this.m_map[type.qname()] = f;
    return f;
  }
  //if (val instanceof fan.sys.Facet)
  if (val != null) return val;
  if (checked) throw fan.sys.UnknownFacetErr.make(type.qname());
  return null;
}

fan.sys.Facets.prototype.decode = function(type, s)
{
  try
  {
    // if no string use make/defVal
    if (s.length == 0) return type.make();

    // decode using normal Fantom serialization
    return fan.std.ObjDecoder.decode(s);
  }
  catch (e)
  {
    var msg = "ERROR: Cannot decode facet " + type + ": " + s;
    fan.sys.ObjUtil.echo(msg);
    delete this.m_map[type.qname()];
    throw fan.sys.IOErr.make(msg);
  }
}

fan.sys.Facets.prototype.dup = function()
{
  var dup = {};
  for (key in this.m_map) dup[key] = this.m_map[key];
  return new fan.sys.Facets(dup);
}

fan.sys.Facets.prototype.inherit = function(facets)
{
  var keys = [];
  for (key in facets.m_map) keys.push(key);
  if (keys.length == 0) return;

  this.m_list = null;
  for (var i=0; i<keys.length; i++)
  {
    var key = keys[i];

    // if already mapped skipped
    if (this.m_map[key] != null) continue;

    // if not an inherited facet skip it
    var type = fan.sys.Type.find(key);
    var meta = type.facet(fan.sys.FacetMeta.$type, false);
    if (meta == null || !meta.m_inherited) continue;

    // inherit
    this.m_map[key] = facets.m_map[key];
  }
}

fan.sys.Facets.m_emptyVal = null;
fan.sys.Facets.m_transientVal = null;
