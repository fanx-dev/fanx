//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   11 Dec 08  Andy Frank  Creation
//   20 May 09  Andy Frank  Refactor to new OO model
//

/**
 * Type models sys::Type.  Implementation classes are:
 *   - ClassType
 *   - GenericType (ListType, MapType, FuncType)
 *   - NullableType
 */
fan.sys.Type = fan.sys.Obj.$extend(fan.sys.Obj);

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

fan.sys.Type.prototype.$ctor = function(qname, base, mixins, facets, flags)
{
  // workaround for inhertiance
  if (qname === undefined) return;

  // mixins
  if (fan.sys.Type.$type != null)
  {
    var acc = fan.sys.List.makeFromJs(fan.sys.Type.$type, []);
    for (var i=0; i<mixins.length; i++)
      acc.add(fan.sys.Type.find(mixins[i]));
    acc.m_readOnly = true;
    this.m_mixins = acc;
  }

  var s = qname.split("::");
  this.m_qname    = qname;
  this.m_pod      = fan.std.Pod.find(s[0]);
  this.m_name     = s[1];
  this.m_base     = base == null ? null : fan.sys.Type.find(base);
  this.m_myFacets = new fan.sys.Facets(facets);
  this.m_flags    = flags;
  this.m_$qname   = 'fan.' + this.m_pod + '.' + this.m_name;
  this.m_isMixin  = false;
  this.m_nullable = new fan.sys.NullableType(this);
  this.m_slotsInfo   = [];   // $af/$am
  this.m_slotsByName = null; // doReflect Str:Slot
}

//////////////////////////////////////////////////////////////////////////
// Naming
//////////////////////////////////////////////////////////////////////////

fan.sys.Type.prototype.pod = function() { return this.m_pod; }
fan.sys.Type.prototype.$name = function() { return this.m_name; }
fan.sys.Type.prototype.qname = function() { return this.m_qname; }
fan.sys.Type.prototype.signature = function() { return this.m_qname; }

//////////////////////////////////////////////////////////////////////////
// Flags
//////////////////////////////////////////////////////////////////////////

fan.sys.Type.prototype.isAbstract  = function() { return (this.flags() & fan.sys.FConst.Abstract) != 0; }
fan.sys.Type.prototype.isClass     = function() { return (this.flags() & (fan.sys.FConst.Enum|fan.sys.FConst.Mixin)) == 0; }
fan.sys.Type.prototype.isConst     = function() { return (this.flags() & fan.sys.FConst.Const) != 0; }
fan.sys.Type.prototype.isEnum      = function() { return (this.flags() & fan.sys.FConst.Enum) != 0; }
fan.sys.Type.prototype.isFacet     = function() { return (this.flags() & fan.sys.FConst.Facet) != 0; }
fan.sys.Type.prototype.isFinal     = function() { return (this.flags() & fan.sys.FConst.Final) != 0; }
fan.sys.Type.prototype.isInternal  = function() { return (this.flags() & fan.sys.FConst.Internal) != 0; }
fan.sys.Type.prototype.isMixin     = function() { return (this.flags() & fan.sys.FConst.Mixin) != 0; }
fan.sys.Type.prototype.isPublic    = function() { return (this.flags() & fan.sys.FConst.Public) != 0; }
fan.sys.Type.prototype.isSynthetic = function() { return (this.flags() & fan.sys.FConst.Synthetic) != 0; }
fan.sys.Type.prototype.flags = function() { return this.m_flags; };

fan.sys.Type.prototype.trap = function(name, args)
{
  // private undocumented access
  if (name == "flags") return this.flags();
  return fan.sys.Obj.prototype.trap.call(this, name, args);
}

fan.sys.Type.prototype.equals = function(that)
{
  if (that instanceof fan.sys.Type)
    return this.signature() === that.signature();
  else
    return false;
}

//////////////////////////////////////////////////////////////////////////
// Value Types
//////////////////////////////////////////////////////////////////////////

fan.sys.Type.prototype.isVal = function()
{
  return this === fan.sys.Bool.$type ||
         this === fan.sys.Int.$type ||
         this === fan.sys.Float.$type;
}

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

fan.sys.Type.prototype.isClass = function()   { return !this.m_isMixin && this.m_base.m_qname != "sys::Enum"; }
fan.sys.Type.prototype.isEnum = function()    { return this.m_base != null && this.m_base.m_qname == "sys::Enum"; }
fan.sys.Type.prototype.isMixin = function()   { return this.m_isMixin; }
fan.sys.Type.prototype.log = function()       { return fan.std.Log.get(this.m_pod.m_name); }
fan.sys.Type.prototype.toStr = function()     { return this.signature(); }
fan.sys.Type.prototype.toLocale = function()  { return this.signature(); }
fan.sys.Type.prototype.$typeof = function()   { return fan.sys.Type.$type; }
fan.sys.Type.prototype.$literalEncode = function(out)  { out.w(this.signature()).w("#"); }

//////////////////////////////////////////////////////////////////////////
// Nullable
//////////////////////////////////////////////////////////////////////////

fan.sys.Type.prototype.isNullable = function() { return false; }
fan.sys.Type.prototype.toNonNullable = function() { return this; }

fan.sys.Type.prototype.toNullable = function() { return this.m_nullable; }
fan.sys.Type.prototype.toNonNullable = function() { return this; }

//////////////////////////////////////////////////////////////////////////
// Generics
//////////////////////////////////////////////////////////////////////////
/*
fan.sys.Type.prototype.isGenericType = function()
{
  return this == fan.sys.List.$type ||
         this == fan.std.Map.$type ||
         this == fan.sys.Func.$type;
}

fan.sys.Type.prototype.isGenericInstance = function() { false }

fan.sys.Type.prototype.isGenericParameter = function()
{
  return this.m_pod.m_name === "sys" && this.m_name.length === 1;
}

// fan.sys.Type.prototype.getRawType = function()
// {
//   if (!isGenericParameter()) return this;
//   if (this == Sys.LType) return Sys.ListType;
//   if (this == Sys.MType) return Sys.MapType;
//   if (this instanceof ListType) return Sys.ListType;
//   if (this instanceof MapType)  return Sys.MapType;
//   if (this instanceof FuncType) return Sys.FuncType;
//   return Sys.ObjType;
// }

fan.sys.Type.prototype.isGeneric = function() { return this.isGenericType(); }

fan.sys.Type.prototype.params = function()
{
  if (fan.sys.Type.$noParams == null)
    fan.sys.Type.$noParams = fan.std.Map.make(fan.sys.Str.$type, fan.sys.Type.$type).ro();
  return fan.sys.Type.$noParams;
}

fan.sys.Type.prototype.parameterize = function(params)
{
  if (this === fan.sys.List.$type)
  {
    var v = params.get("V");
    if (v == null) throw fan.sys.ArgErr.make("List.parameterize - V undefined");
    return v.toListOf();
  }

  if (this === fan.sys.Map.$type)
  {
    var v = params.get("V");
    var k = params.get("K");
    if (v == null) throw fan.sys.ArgErr.make("Map.parameterize - V undefined");
    if (k == null) throw fan.sys.ArgErr.make("Map.parameterize - K undefined");
    return new fan.sys.MapType(k, v);
  }

  if (this === fan.sys.Func.$type)
  {
    var r = params.get("R");
    if (r == null) throw fan.sys.ArgErr.make("Func.parameterize - R undefined");
    var p = [];
    for (var i=65; i<=72; ++i)
    {
      var x = params.get(String.fromCharCode(i));
      if (x == null) break;
      p.push(x);
    }
    return new fan.sys.FuncType(p, r);
  }

  throw fan.sys.UnsupportedErr.make("not generic: " + this);
}
*/

fan.sys.Type.prototype.toListOf = function()
{
  if (this.m_listOf == null) this.m_listOf = new fan.sys.ListType(this);
  return this.m_listOf;
}

fan.sys.Type.prototype.emptyList = function()
{
  if (this.$emptyList == null) {
    this.$emptyList = fan.sys.List.make(0, this);
    //.toImmutable();
    this.$emptyList.m_readOnly = true;
    this.$emptyList.m_immutable = true;
  }
  return this.$emptyList;
}

//////////////////////////////////////////////////////////////////////////
// Make
//////////////////////////////////////////////////////////////////////////

fan.sys.Type.prototype.make = function(args)
{
  if (args === undefined) args = null;

  var make = this.method("make", false);
  if (make != null && make.isPublic())
  {
    if (this.isAbstract() && !make.isStatic())
      throw fan.sys.Err.make("Cannot instantiate abstract class: " + this.m_qname);

    var numArgs = args == null ? 0 : args.size();
    var params = make.params();
    if ((numArgs == params.size()) ||
        (numArgs < params.size() && params.get(numArgs).hasDefault()))
      return make.invoke(null, args);
  }

  var defVal = this.slot("defVal", false);
  if (defVal != null && defVal.isPublic())
  {
    if (defVal instanceof fan.std.Field) return defVal.get(null);
    if (defVal instanceof fan.std.Method) return defVal.invoke(null, null);
  }

  throw fan.sys.Err.make("Type missing 'make' or 'defVal' slots: " + this);
}

//////////////////////////////////////////////////////////////////////////
// Slots
//////////////////////////////////////////////////////////////////////////

fan.sys.Type.prototype.slots   = function() { return this.reflect().m_slotList.ro(); }
fan.sys.Type.prototype.methods = function() { return this.reflect().m_methodList.ro(); }
fan.sys.Type.prototype.fields  = function() { return this.reflect().m_fieldList.ro(); }

fan.sys.Type.prototype.slot = function(name, checked)
{
  if (checked === undefined) checked = true;
  var slot = this.reflect().m_slotsByName[name];
  if (slot != null) return slot;
  if (checked) throw fan.sys.UnknownSlotErr.make(this.m_qname + "." + name);
  return null;
}

fan.sys.Type.prototype.method = function(name, checked)
{
  var slot = this.slot(name, checked);
  if (slot == null) return null;
  return fan.sys.ObjUtil.coerce(slot, fan.sys.Method.$type);
}

fan.sys.Type.prototype.field = function(name, checked)
{
  var slot = this.slot(name, checked);
  if (slot == null) return null;
  return fan.sys.ObjUtil.coerce(slot, fan.sys.Field.$type);
}

// addMethod
fan.sys.Type.prototype.$am = function(name, flags, returns, params, facets)
{
  var r = fan.sys.Type.find(returns);
  var m = new fan.std.Method(this, name, flags, r, params, facets);
  this.m_slotsInfo.push(m);
  return this;
}

// addField
fan.sys.Type.prototype.$af = function(name, flags, of, facets)
{
  var t = fan.sys.Type.find(of);
  var f = new fan.std.Field(this, name, flags, t, facets);
  this.m_slotsInfo.push(f);
  return this;
}

//////////////////////////////////////////////////////////////////////////
// Inheritance
//////////////////////////////////////////////////////////////////////////

fan.sys.Type.prototype.base = function()
{
  return this.m_base;
}

fan.sys.Type.prototype.mixins = function()
{
  // lazy-build mxins list for Obj and Type
  if (this.m_mixins == null)
    this.m_mixins = fan.sys.Type.$type.emptyList();
  return this.m_mixins;
}

fan.sys.Type.prototype.inheritance = function()
{
  if (this.m_inheritance == null) this.m_inheritance = fan.sys.Type.$inheritance(this);
  return this.m_inheritance;
}

fan.sys.Type.$inheritance = function(self)
{
  var map = {};
  var acc = fan.sys.List.make(8, fan.sys.Type.$type);

  // handle Void as a special case
  if (self == fan.sys.Void.$type)
  {
    acc.add(self);
    return acc.trim().ro();
  }

  // add myself
  map[self.qname()] = self;
  acc.add(self);

  // add my direct inheritance inheritance
  fan.sys.Type.addInheritance(self.base(), acc, map);
  var mixins = self.mixins();
  for (var i=0; i<mixins.size(); ++i)
    fan.sys.Type.addInheritance(mixins.get(i), acc, map);

  return acc.trim().ro();
}

fan.sys.Type.addInheritance = function(t, acc, map)
{
  if (t == null) return;
  var ti = t.inheritance();
  for (var i=0; i<ti.size(); ++i)
  {
    var x = ti.get(i);
    if (map[x.qname()] == null)
    {
      map[x.qname()] = x;
      acc.add(x);
    }
  }
}

fan.sys.Type.prototype.fits = function(that) { return this.toNonNullable().is(that.toNonNullable()); }
fan.sys.Type.prototype.is = function(that)
{
  // we don't take nullable into account for fits
  if (that instanceof fan.sys.NullableType)
    that = that.m_root;

  if (this.equals(that)) return true;

  // check for void
  if (this === fan.sys.Void.$type) return false;

  // check base class
  var base = this.m_base;
  while (base != null)
  {
    if (base.equals(that)) return true;
    base = base.m_base;
  }

  // check mixins
  var t = this;
  while (t != null)
  {
    var m = t.mixins();
    for (var i=0; i<m.size(); i++)
      if (fan.sys.Type.checkMixin(m.get(i), that)) return true;
    t = t.m_base;
  }

  return false;
}

fan.sys.Type.checkMixin = function(mixin, that)
{
  if (mixin.equals(that)) return true;
  var m = mixin.mixins();
  for (var i=0; i<m.size(); i++)
    if (fan.sys.Type.checkMixin(m.get(i), that))
      return true;
  return false;
}

//////////////////////////////////////////////////////////////////////////
// Static Methods
//////////////////////////////////////////////////////////////////////////

/**
 * Find the Fantom type for this qname.
 */
fan.sys.Type.find = function(sig, checked)
{
  return fan.sys.Sys.findType(sig, checked);
}

/**
 * Get the Fantom type
 */
fan.sys.Type.of = function(obj)
{
  if (obj instanceof fan.sys.Obj)
    return obj.$typeof();
  else
    return fan.sys.Type.toFanType(obj);
}

/**
 * Get the Fantom type
 */
fan.sys.Type.toFanType = function(obj)
{
  if (obj == null) throw fan.sys.Err.make("sys::Type.toFanType: obj is null");
  if (obj.$fanType != undefined) return obj.$fanType;
  if ((typeof obj) == "boolean" || obj instanceof Boolean) return fan.sys.Bool.$type;
  if ((typeof obj) == "number"  || obj instanceof Number)  return fan.sys.Int.$type;
  if ((typeof obj) == "string"  || obj instanceof String)  return fan.sys.Str.$type;
  throw fan.sys.Err.make("sys::Type.toFanType: Not a Fantom type: " + obj);
}

fan.sys.Type.common = function(objs)
{
  if (objs.length == 0) return fan.sys.Obj.$type.toNullable();
  var nullable = false;
  var best = null;
  for (var i=0; i<objs.length; i++)
  {
    var obj = objs[i];
    if (obj == null) { nullable = true; continue; }
    var t = fan.sys.ObjUtil.$typeof(obj);
    if (best == null) { best = t; continue; }
    while (!t.is(best))
    {
      best = best.base();
      if (best == null) return nullable ? fan.sys.Obj.$type.toNullable() : fan.sys.Obj.$type;
    }
  }
  if (best == null) best = fan.sys.Obj.$type;
  return nullable ? best.toNullable() : best;
}

/*************************************************************************
 * NullableType
 ************************************************************************/

fan.sys.NullableType = fan.sys.Obj.$extend(fan.sys.Type)
fan.sys.NullableType.prototype.$ctor = function(root)
{
  this.m_root = root;
  this.m_signature = root.signature() + "?";
}

fan.sys.NullableType.prototype.podName = function() { return this.m_root.podName(); }
fan.sys.NullableType.prototype.pod = function() { return this.m_root.pod(); }
fan.sys.NullableType.prototype.name = function() { return this.m_root.name(); }
fan.sys.NullableType.prototype.qname = function() { return this.m_root.qname(); }
fan.sys.NullableType.prototype.signature = function() { return this.m_signature; }
fan.sys.NullableType.prototype.flags = function() { return this.m_root.flags(); }

fan.sys.NullableType.prototype.base = function() { return this.m_root.base(); }
fan.sys.NullableType.prototype.mixins = function() { return this.m_root.mixins(); }
fan.sys.NullableType.prototype.inheritance = function() { return this.m_root.inheritance(); }
fan.sys.NullableType.prototype.is = function(type) { return this.m_root.is(type); }

fan.sys.NullableType.prototype.isVal = function() { return this.m_root.isVal(); }

fan.sys.NullableType.prototype.isNullable = function() { return true; }
fan.sys.NullableType.prototype.toNullable = function() { return this; }
fan.sys.NullableType.prototype.toNonNullable = function() { return this.m_root; }

fan.sys.NullableType.prototype.isGenericType = function() { return this.m_root.isGenericType(); }
fan.sys.NullableType.prototype.isGenericInstance = function() { return this.m_root.isGenericInstance(); }
fan.sys.NullableType.prototype.isGenericParameter = function() { return this.m_root.isGenericParameter(); }
fan.sys.NullableType.prototype.getRawType = function() { return this.m_root.getRawType(); }
fan.sys.NullableType.prototype.params = function() { return this.m_root.params(); }
fan.sys.NullableType.prototype.parameterize = function(params) { return this.m_root.parameterize(params).toNullable(); }

fan.sys.NullableType.prototype.fields = function() { return this.m_root.fields(); }
fan.sys.NullableType.prototype.methods = function() { return this.m_root.methods(); }
fan.sys.NullableType.prototype.slots = function() { return this.m_root.slots(); }
fan.sys.NullableType.prototype.slot = function(name, checked) { return this.m_root.slot(name, checked); }

fan.sys.NullableType.prototype.facets = function() { return this.m_root.facets(); }
fan.sys.NullableType.prototype.facet = function(type, checked) { return this.m_root.facet(type, checked); }

fan.sys.NullableType.prototype.doc = function() { return this.m_root.doc(); }
