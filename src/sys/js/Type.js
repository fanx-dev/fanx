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
    var acc = fan.sys.List.make(fan.sys.Type.$type, []);
    for (var i=0; i<mixins.length; i++)
      acc.add(fan.sys.Type.find(mixins[i]));
    this.m_mixins = acc.ro();
  }

  var s = qname.split("::");
  this.m_qname    = qname;
  this.m_pod      = fan.sys.Pod.find(s[0]);
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
fan.sys.Type.prototype.log = function()       { return fan.sys.Log.get(this.m_pod.m_name); }
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

fan.sys.Type.prototype.isGenericType = function()
{
  return this == fan.sys.List.$type ||
         this == fan.sys.Map.$type ||
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
    fan.sys.Type.$noParams = fan.sys.Map.make(fan.sys.Str.$type, fan.sys.Type.$type).ro();
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

fan.sys.Type.prototype.toListOf = function()
{
  if (this.m_listOf == null) this.m_listOf = new fan.sys.ListType(this);
  return this.m_listOf;
}

fan.sys.Type.prototype.emptyList = function()
{
  if (this.$emptyList == null)
    this.$emptyList = fan.sys.List.make(this).toImmutable();
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
    if (defVal instanceof fan.sys.Field) return defVal.get(null);
    if (defVal instanceof fan.sys.Method) return defVal.invoke(null, null);
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
  var r = fanx_TypeParser.load(returns);
  var m = new fan.sys.Method(this, name, flags, r, params, facets);
  this.m_slotsInfo.push(m);
  return this;
}

// addField
fan.sys.Type.prototype.$af = function(name, flags, of, facets)
{
  var t = fanx_TypeParser.load(of);
  var f = new fan.sys.Field(this, name, flags, t, facets);
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
  var acc = fan.sys.List.make(fan.sys.Type.$type);

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
// Facets
//////////////////////////////////////////////////////////////////////////

fan.sys.Type.prototype.hasFacet = function(type)
{
  return this.facet(type, false) != null;
}

fan.sys.Type.prototype.facets = function()
{
  if (this.m_inheritedFacets == null) this.loadFacets();
  return this.m_inheritedFacets.list();
}

fan.sys.Type.prototype.facet = function(type, checked)
{
  if (checked === undefined) checked = true;
  if (this.m_inheritedFacets == null) this.loadFacets();
  return this.m_inheritedFacets.get(type, checked);
}

fan.sys.Type.prototype.loadFacets = function()
{
  var f = this.m_myFacets.dup();
  var inheritance = this.inheritance();
  for (var i=0; i<inheritance.size(); ++i)
  {
    var x = inheritance.get(i);
    if (x.m_myFacets) f.inherit(x.m_myFacets);
  }
  this.m_inheritedFacets = f;
}

//////////////////////////////////////////////////////////////////////////
// Util
//////////////////////////////////////////////////////////////////////////

fan.sys.Type.prototype.reflect = function()
{
  if (this.m_slotsByName != null) return this;
  this.doReflect();
  return this;
}

fan.sys.Type.prototype.doReflect = function()
{
  // these are working accumulators used to build the
  // data structures of my defined and inherited slots
  var slots = [];
  var nameToSlot  = {};   // String -> Slot
  var nameToIndex = {};   // String -> Int

  // merge in base class and mixin classes
  for (var i=0; i<this.m_mixins.size(); i++) this.$mergeType(this.m_mixins.get(i), slots, nameToSlot, nameToIndex);
  this.$mergeType(this.m_base, slots, nameToSlot, nameToIndex);

  // merge in all my slots
  for (var i=0; i<this.m_slotsInfo.length; i++)
  {
    var slot = this.m_slotsInfo[i]
    this.$mergeSlot(slot, slots, nameToSlot, nameToIndex);
  }

  // break out into fields and methods
  var fields  = [];
  var methods = [];
  for (var i=0; i<slots.length; i++)
  {
    var slot = slots[i];
    if (slot instanceof fan.sys.Field) fields.push(slot);
    else methods.push(slot);
  }

  // set lists
  this.m_slotList    = fan.sys.List.make(fan.sys.Slot.$type, slots);
  this.m_fieldList   = fan.sys.List.make(fan.sys.Field.$type, fields);
  this.m_methodList  = fan.sys.List.make(fan.sys.Method.$type, methods);
  this.m_slotsByName = nameToSlot;
}

/**
 * Merge the inherit's slots into my slot maps.
 *  slots:       Slot[] by order
 *  nameToSlot:  String name -> Slot
 *  nameToIndex: String name -> Long index of slots
 */
fan.sys.Type.prototype.$mergeType = function(inheritedType, slots, nameToSlot, nameToIndex)
{
  if (inheritedType == null) return;
  var inheritedSlots = inheritedType.reflect().slots();
  for (var i=0; i<inheritedSlots.size(); i++)
    this.$mergeSlot(inheritedSlots.get(i), slots, nameToSlot, nameToIndex);
}

/**
 * Merge the inherited slot into my slot maps.  Assume this slot
 * trumps any previous definition (because we process inheritance
 * and my slots in the right order)
 *  slots:       Slot[] by order
 *  nameToSlot:  String name -> Slot
 *  nameToIndex: String name -> Long index of slots
 */
fan.sys.Type.prototype.$mergeSlot = function(slot, slots, nameToSlot, nameToIndex)
{
  // skip constructors which aren't mine
  if (slot.isCtor() && slot.m_parent != this) return;

  var name = slot.m_name;
  var dup  = nameToIndex[name];
  if (dup != null)
  {
    // if the slot is inherited from Obj, then we can
    // safely ignore it as an override - the dup is most
    // likely already the same Object method inherited from
    // a mixin; but the dup might actually be a more specific
    // override in which case we definitely don't want to
    // override with the sys::Object version
    if (slot.parent() == fan.sys.Obj.$type)
      return;

    // if given the choice between two *inherited* slots where
    // one is concrete and abstract, then choose the concrete one
    var dupSlot = slots[dup];
    if (slot.parent() != this && slot.isAbstract() && !dupSlot.isAbstract())
      return;

// TODO FIXIT: this is not triggering -- possibly due to how we generate
// the type info via compilerJs?
    // check if this is a Getter or Setter, in which case the Field
    // trumps and we need to cache the method on the Field
    // Note: this works because we assume the compiler always generates
    // the field before the getter and setter in fcode
    if ((slot.m_flags & (fan.sys.FConst.Getter | fan.sys.FConst.Setter)) != 0)
    {
      var field = slots[dup];
      if ((slot.m_flags & fan.sys.FConst.Getter) != 0)
        field.m_getter = slot;
      else
        field.m_setter = slot;
      return;
    }

    nameToSlot[name] = slot;
    slots[dup] = slot;
  }
  else
  {
    nameToSlot[name] = slot;
    slots.push(slot);
    nameToIndex[name] = slots.length-1;
  }
}

//////////////////////////////////////////////////////////////////////////
// Static Methods
//////////////////////////////////////////////////////////////////////////

/**
 * Find the Fantom type for this qname.
 */
fan.sys.Type.find = function(sig, checked)
{
  return fanx_TypeParser.load(sig, checked);
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

/*************************************************************************
 * GenericType
 ************************************************************************/

fan.sys.GenericType = fan.sys.Obj.$extend(fan.sys.Type)
fan.sys.GenericType.prototype.$ctor = function(v) {}

fan.sys.GenericType.prototype.params = function()
{
  if (this.m_params == null) this.m_params = this.makeParams();
  return this.m_params;
}

fan.sys.GenericType.prototype.doReflect = function()
{
   // ensure master type is reflected
   var master = this.base();
   master.doReflect();
   var masterSlots = master.slots();

  // allocate slot data structures
  var slots = [];
  var fields = [];
  var methods = [];
  var slotsByName = {};

  // parameterize master's slots
  for (var i=0; i<masterSlots.size(); i++)
  {
    var slot = masterSlots.get(i);
    if (slot instanceof fan.sys.Method)
    {
      slot = this.parameterizeMethod(slot);
      methods.push(slot);
    }
    else
    {
      slot = this.parameterizeField(slot);
      fields.push(slot);
    }
    slots.push(slot);
    slotsByName[slot.m_name] = slot;
  }

  this.m_slotList = fan.sys.List.make(fan.sys.Slot.$type, slots);
  this.m_fieldList = fan.sys.List.make(fan.sys.Field.$type, fields);
  this.m_methodList = fan.sys.List.make(fan.sys.Method.$type, methods);
  this.m_slotsByName = slotsByName;
}

fan.sys.GenericType.prototype.parameterizeField = function(f)
{
  // if not generic, short circuit and reuse original
  var t = f.type();
  if (!t.isGenericParameter()) return f;

  // create new parameterized version
  t = this.parameterizeType(t);
  //var pf = new Field(this, f.name, f.flags, f.facets, f.lineNum, t);
  var pf = new fan.sys.Field(this, f.m_name, f.m_flags, t, f.m_facets);
  //pf.reflect = f.reflect;
  return pf;
}

fan.sys.GenericType.prototype.parameterizeMethod = function(m)
{
  // if not generic, short circuit and reuse original
  if (!m.isGenericMethod()) return m;

  // new signature
  var func = m.m_func;
  var ret;
  var params = fan.sys.List.make(fan.sys.Param.$type);

  // parameterize return type
  if (func.returns().isGenericParameter())
    ret = this.parameterizeType(func.returns());
  else
    ret = func.returns();

  // narrow params (or just reuse if not parameterized)
  var arity = m.params().size();
  for (var i=0; i<arity; ++i)
  {
    var p = m.params().get(i);
    if (p.m_type.isGenericParameter())
    {
      //params.add(new fan.sys.Param(p.name, parameterize(p.type), p.mask));
      params.add(new fan.sys.Param(p.m_name, this.parameterizeType(p.m_type), p.m_hasDefault));
    }
    else
    {
      params.add(p);
    }
  }

  //var pm = new Method(this, m.name, m.flags, m.facets, m.lineNum, ret, m.inheritedReturns, params, m);
  var pm = new fan.sys.Method(this, m.m_name, m.m_flags, ret, params, m.m_facets, m)
  //pm.reflect = m.reflect;
  return pm;
}

fan.sys.GenericType.prototype.parameterizeType = function(t)
{
  var nullable = t.isNullable();
  var nn = t.toNonNullable();
  if (nn instanceof fan.sys.ListType)
    t = this.parameterizeListType(nn);
  else if (nn instanceof fan.sys.FuncType)
    t = this.parameterizeFuncType(nn);
  else
    t = this.doParameterize(nn);
  return nullable ? t.toNullable() : t;
}

fan.sys.GenericType.prototype.parameterizeListType = function(t)
{
  return this.doParameterize(t.v).toListOf();
}

fan.sys.GenericType.prototype.parameterizeFuncType = function(t)
{
  var params = [];
  for (var i=0; i<t.pars.length; i++)
  {
    var param = t.pars[i];
    if (param.isGenericParameter()) param = this.doParameterize(param);
    params[i] = param;
  }

  var ret = t.ret;
  if (ret.isGenericParameter()) ret = this.doParameterize(ret);

  return new fan.sys.FuncType(params, ret);
}

fan.sys.GenericType.prototype.doParameterize = function(t) {}

/*************************************************************************
 * ListType
 ************************************************************************/

fan.sys.ListType = fan.sys.Obj.$extend(fan.sys.GenericType)
fan.sys.ListType.prototype.$ctor = function(v)
{
  this.v = v;
  this.m_qname  = "sys::List";
  this.m_pod    = fan.sys.Pod.find("sys");
  this.m_name   = "List";
  this.m_base   = fan.sys.List.$type;
  this.m_mixins = fan.sys.Type.$type.emptyList();
  this.m_slots  = {};
}

fan.sys.ListType.prototype.signature = function()
{
  return this.v.signature() + '[]';
}

fan.sys.ListType.prototype.equals = function(that)
{
  if (that instanceof fan.sys.ListType)
    return this.v.equals(that.v);
  else
    return false;
}

fan.sys.ListType.prototype.is = function(that)
{
  if (that instanceof fan.sys.ListType)
  {
    if (that.v.qname() == "sys::Obj") return true;
    return this.v.is(that.v);
  }
  if (that instanceof fan.sys.Type)
  {
    if (that.qname() == "sys::List") return true;
    if (that.qname() == "sys::Obj")  return true;
  }
  return false;
}

fan.sys.ListType.prototype.as = function(obj, that)
{
  var objType = fan.sys.ObjUtil.$typeof(obj);

  if (objType instanceof fan.sys.ListType &&
      objType.v.qname() == "sys::Obj" &&
      that instanceof fan.sys.ListType)
    return obj;

  if (that instanceof fan.sys.NullableType &&
      that.m_root instanceof fan.sys.ListType)
    that = that.m_root;

  return objType.is(that) ? obj : null;
}

fan.sys.ListType.prototype.toNullable = function()
{
  if (this.m_nullable == null) this.m_nullable = new fan.sys.NullableType(this);
  return this.m_nullable;
}

fan.sys.ListType.prototype.facets = function() { return fan.sys.List.$type.facets(); }
fan.sys.ListType.prototype.facet = function(type, checked) { return fan.sys.List.$type.facet(type, checked); }

fan.sys.ListType.prototype.makeParams = function()
{
  return fan.sys.Map.make(fan.sys.Str.$type, fan.sys.Type.$type)
    .set("V", this.v)
    .set("L", this).ro();
}

fan.sys.ListType.prototype.isGenericParameter = function()
{
  return this.v.isGenericParameter();
}

fan.sys.ListType.prototype.doParameterize = function(t)
{
  if (t == fan.sys.Sys.VType) return this.v;
  if (t == fan.sys.Sys.LType) return this;
  throw new Error(t.toString());
}

/*************************************************************************
 * MapType
 ************************************************************************/

fan.sys.MapType = fan.sys.Obj.$extend(fan.sys.GenericType);
fan.sys.MapType.prototype.$ctor = function(k, v)
{
  this.k = k;
  this.v = v;
  this.m_qname  = "sys::Map";
  this.m_pod    = fan.sys.Pod.find("sys");
  this.m_name   = "Map";
  this.m_base   = fan.sys.Map.$type;
  this.m_mixins = fan.sys.Type.$type.emptyList();
  this.m_slots  = {};
}

fan.sys.MapType.prototype.signature = function()
{
  return "[" + this.k.signature() + ':' + this.v.signature() + ']';
}

fan.sys.MapType.prototype.equals = function(that)
{
  if (that instanceof fan.sys.MapType)
    return this.k.equals(that.k) && this.v.equals(that.v);
  else
    return false;
}

fan.sys.MapType.prototype.is = function(that)
{
  if (that.isNullable()) that = that.m_root;

  if (that instanceof fan.sys.MapType)
  {
    return this.k.is(that.k) && this.v.is(that.v);
  }
  if (that instanceof fan.sys.Type)
  {
    if (that.qname() == "sys::Map") return true;
    if (that.qname() == "sys::Obj")  return true;
  }
  return false;
}

fan.sys.MapType.prototype.as = function(obj, that)
{
  var objType = fan.sys.ObjUtil.$typeof(obj);
  if (objType instanceof fan.sys.MapType && that instanceof fan.sys.MapType)
    return obj;
  return objType.is(that) ? obj : null;
}

fan.sys.MapType.prototype.toNullable = function()
{
  if (this.m_nullable == null) this.m_nullable = new fan.sys.NullableType(this);
  return this.m_nullable;
}

fan.sys.MapType.prototype.facets = function() { return fan.sys.Map.$type.facets(); }
fan.sys.MapType.prototype.facet = function(type, checked) { return fan.sys.Map.$type.facet(type, checked); }

fan.sys.MapType.prototype.makeParams = function()
{
  return fan.sys.Map.make(fan.sys.Str.$type, fan.sys.Type.$type)
    .set("K", this.k)
    .set("V", this.v)
    .set("M", this).ro();
}

fan.sys.MapType.prototype.isGenericParameter = function()
{
  return this.v.isGenericParameter() && this.k.isGenericParameter();
}

fan.sys.MapType.prototype.doParameterize = function(t)
{
  if (t == fan.sys.Sys.KType) return this.k;
  if (t == fan.sys.Sys.VType) return this.v;
  if (t == fan.sys.Sys.MType) return this;
  throw new Error(t.toString());
}

/*************************************************************************
 * FuncType
 ************************************************************************/

fan.sys.FuncType = fan.sys.Obj.$extend(fan.sys.GenericType);
fan.sys.FuncType.prototype.$ctor = function(params, ret)
{
  this.m_pod    = fan.sys.Pod.find("sys");
  this.m_name   = "Func";
  this.m_qname  = "sys::Func";
  this.m_base   = fan.sys.Obj.$type;
  this.pars     = params;
  this.ret      = ret;
  this.m_mixins = fan.sys.Type.$type.emptyList();

  // I am a generic parameter type if any my args or
  // return type are generic parameter types.
  this.genericParameterType |= ret.isGenericParameter();
  for (var i=0; i<params.length; ++i)
    this.genericParameterType |= params[i].isGenericParameter();
}

fan.sys.FuncType.prototype.signature = function()
{
  var s = '|'
  for (var i=0; i<this.pars.length; i++)
  {
    if (i > 0) s += ',';
    s += this.pars[i].signature();
  }
  s += '->';
  s += this.ret.signature();
  s += '|';
  return s;
}

fan.sys.FuncType.prototype.equals = function(that)
{
  if (that instanceof fan.sys.FuncType)
  {
    if (this.pars.length != that.pars.length) return false;
    for (var i=0; i<this.pars.length; i++)
      if (!this.pars[i].equals(that.pars[i])) return false;
    return this.ret.equals(that.ret);
  }
  return false;
}

fan.sys.FuncType.prototype.is = function(that)
{
  if (this == that) return true;
  if (that instanceof fan.sys.FuncType)
  {
    // match return type (if void is needed, anything matches)
    if (that.ret.m_qname != "sys::Void" && !this.ret.is(that.ret)) return false;

    // match params - it is ok for me to have less than
    // the type params (if I want to ignore them), but I
    // must have no more
    if (this.pars.length > that.pars.length) return false;
    for (var i=0; i<this.pars.length; ++i)
      if (!that.pars[i].is(this.pars[i])) return false;

    // this method works for the specified method type
    return true;
  }
  // TODO FIXIT - need to add as FuncType in Type.$af
  if (that.toString() == "sys::Func") return true;
  if (that.toString() == "sys::Func?") return true;
  return this.base().is(that);
}

fan.sys.FuncType.prototype.as = function(that)
{
  // TODO FIXIT
  return that;
}

fan.sys.FuncType.prototype.toNullable = function()
{
  if (this.m_nullable == null) this.m_nullable = new fan.sys.NullableType(this);
  return this.m_nullable;
}

fan.sys.FuncType.prototype.facets = function() { return fan.sys.Func.$type.facets(); }
fan.sys.FuncType.prototype.facet = function(type, checked) { return fan.sys.Func.$type.facet(type, checked); }

fan.sys.FuncType.prototype.makeParams = function()
{
  var map = fan.sys.Map.make(fan.sys.Str.$type, fan.sys.Type.$type);
  for (var i=0; i<this.pars.length; ++i)
    map.set(String.fromCharCode(i+65), this.pars[i]);
  return map.set("R", this.ret).ro();
}

fan.sys.FuncType.prototype.isGenericParameter = function() { return this.genericParameterType; }
fan.sys.FuncType.prototype.doParameterize = function(t)
{
  // return
  if (t == fan.sys.Sys.RType) return ret;

  // if A-H maps to avail params
  var name = t.$name().charCodeAt(0) - 65;
  if (name < this.pars.length) return this.pars[name];

  // otherwise let anything be used
  return fan.sys.Obj.$type;
}