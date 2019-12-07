//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   24 Mar 09  Andy Frank  Creation
//   20 May 09  Andy Frank  Refactor to new OO model
//

/**
 * Slot.
 */
fan.std.Slot = fan.sys.Obj.$extend(fan.sys.Obj);

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

fan.std.Slot.prototype.$ctor = function()
{
  this.m_parent = null;
  this.m_qname  = null;
  this.m_name   = null;
  this.m_flags  = null;
  this.m_facets = null;
}

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

fan.std.Slot.prototype.$typeof = function() { return fan.std.Slot.$type; }
fan.std.Slot.prototype.toStr = function() { return this.m_qname; }
fan.std.Slot.prototype.$literalEncode = function(out)
{
  this.m_parent.$literalEncode(out);
  out.w(this.m_name);
}

//////////////////////////////////////////////////////////////////////////
// Management
//////////////////////////////////////////////////////////////////////////

fan.std.Slot.findMethod = function(qname, checked)
{
  if (checked === undefined) checked = true;
  var slot = fan.std.Slot.find(qname, checked);
  if (slot instanceof fan.std.Method || checked)
    return fan.sys.ObjUtil.coerce(slot, fan.std.Method.$type);
  return null;
}

fan.std.Slot.findField = function(qname, checked)
{
  if (checked === undefined) checked = true;
  var slot = fan.std.Slot.find(qname, checked);
  if (slot instanceof fan.std.Field || checked)
    return fan.sys.ObjUtil.coerce(slot, fan.std.Field.$type);
  return null;
}

fan.std.Slot.find = function(qname, checked)
{
  if (checked === undefined) checked = true;
  var typeName, slotName;
  try
  {
    var dot = qname.indexOf('.');
    typeName = qname.substring(0, dot);
    slotName = qname.substring(dot+1);
  }
  catch (e)
  {
    throw fan.sys.Err.make("Invalid slot qname \"" + qname + "\", use <pod>::<type>.<slot>");
  }
  var type = fan.std.Type.find(typeName, checked);
  if (type == null) return null;
  return type.slot(slotName, checked);
}

fan.std.Slot.findFunc = function(qname, checked)
{
  if (checked === undefined) checked = true;

  var m = fan.std.Slot.find(qname, checked);
  if (m == null) return null;
  return m.m_func;
}

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

fan.std.Slot.prototype.parent = function() { return this.m_parent; }
fan.std.Slot.prototype.qname = function() { return this.m_qname; }
fan.std.Slot.prototype.$name = function() { return this.m_name; }
fan.std.Slot.prototype.isField = function() { return this instanceof fan.std.Field; }
fan.std.Slot.prototype.isMethod = function() { return this instanceof fan.std.Method; }

//////////////////////////////////////////////////////////////////////////
// Flags
//////////////////////////////////////////////////////////////////////////

fan.std.Slot.prototype.isAbstract = function()  { return (this.m_flags & fan.sys.FConst.Abstract)  != 0; }
fan.std.Slot.prototype.isConst = function()     { return (this.m_flags & fan.sys.FConst.Const)     != 0; }
fan.std.Slot.prototype.isCtor = function()      { return (this.m_flags & fan.sys.FConst.Ctor)      != 0; }
fan.std.Slot.prototype.isInternal = function()  { return (this.m_flags & fan.sys.FConst.Internal)  != 0; }
fan.std.Slot.prototype.isNative = function()    { return (this.m_flags & fan.sys.FConst.Native)    != 0; }
fan.std.Slot.prototype.isOverride = function()  { return (this.m_flags & fan.sys.FConst.Override)  != 0; }
fan.std.Slot.prototype.isPrivate = function()   { return (this.m_flags & fan.sys.FConst.Private)   != 0; }
fan.std.Slot.prototype.isProtected = function() { return (this.m_flags & fan.sys.FConst.Protected) != 0; }
fan.std.Slot.prototype.isPublic = function()    { return (this.m_flags & fan.sys.FConst.Public)    != 0; }
fan.std.Slot.prototype.isStatic = function()    { return (this.m_flags & fan.sys.FConst.Static)    != 0; }
fan.std.Slot.prototype.isSynthetic = function() { return (this.m_flags & fan.sys.FConst.Synthetic) != 0; }
fan.std.Slot.prototype.isVirtual = function()   { return (this.m_flags & fan.sys.FConst.Virtual)   != 0; }

//////////////////////////////////////////////////////////////////////////
// Facets
//////////////////////////////////////////////////////////////////////////

fan.std.Slot.prototype.facets = function() { return this.m_facets.list(); }
fan.std.Slot.prototype.hasFacet = function(type) { return this.facet(type, false) != null; }
fan.std.Slot.prototype.facet = function(type, checked)
{
  if (checked === undefined) checked = true;
  return this.m_facets.get(type, checked);
}

//////////////////////////////////////////////////////////////////////////
// Util
//////////////////////////////////////////////////////////////////////////

fan.std.Slot.prototype.$$name = function(n)
{
  // must keep in sync with compilerJs::JsNode
  switch (n)
  {
    case "char":   return "$char";
    case "delete": return "$delete";
    case "enum":   return "$enum";
    case "export": return "$export";
    case "fan":    return "$fan";
    case "float":  return "$float";
    case "import": return "$import";
    case "in":     return "$in";
    case "int":    return "$int";
    case "name":   return "$name";
    case "typeof": return "$typeof";
    case "var":    return "$var";
    case "with":   return "$with";
  }
  return n;
}

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
fan.std.Facets = fan.sys.Obj.$extend(fan.sys.Obj);
fan.std.Facets.prototype.$ctor = function(map)
{
  this.m_map = map;
  this.m_list = null;
}

fan.std.Facets.empty = function()
{
  var x = fan.std.Facets.m_emptyVal;
  if (x == null) x = fan.std.Facets.m_emptyVal = new fan.std.Facets({});
  return x;
}

fan.std.Facets.makeTransient = function()
{
  var x = fan.std.Facets.m_transientVal;
  if (x == null)
  {
    var m = {};
    m[fan.sys.Transient.$type.qname()] = "";
    x = fan.std.Facets.m_transientVal = new fan.std.Facets(m);
  }
  return x;
}

fan.std.Facets.prototype.list = function()
{
  if (this.m_list == null)
  {
    this.m_list = fan.sys.List.make(8, fan.sys.Facet.$type);
    for (var key in this.m_map)
    {
      var type = fan.std.Type.find(key);
      this.m_list.add(this.get(type, true));
    }
    this.m_list = this.m_list.toImmutable();
  }
  return this.m_list;
}

fan.std.Facets.prototype.get = function(type, checked)
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

fan.std.Facets.prototype.decode = function(type, s)
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

fan.std.Facets.prototype.dup = function()
{
  var dup = {};
  for (key in this.m_map) dup[key] = this.m_map[key];
  return new fan.std.Facets(dup);
}

fan.std.Facets.prototype.inherit = function(facets)
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
    var type = fan.std.Type.find(key);
    var meta = type.facet(fan.sys.FacetMeta.$type, false);
    if (meta == null || !meta.m_inherited) continue;

    // inherit
    this.m_map[key] = facets.m_map[key];
  }
}

fan.std.Facets.m_emptyVal = null;
fan.std.Facets.m_transientVal = null;
