
fan.std.TypeExt = fan.sys.Obj.$extend(fan.sys.Obj);
fan.std.TypeExt.prototype.$ctor = function() {}
fan.std.TypeExt.prototype.$typeof = function() { return fan.std.TypeExt.$type; }


//////////////////////////////////////////////////////////////////////////
// Slots
//////////////////////////////////////////////////////////////////////////

fan.std.TypeExt.slots   = function() { return this.reflect().m_slotList.ro(); }
fan.std.TypeExt.methods = function() { return this.reflect().m_methodList.ro(); }
fan.std.TypeExt.fields  = function() { return this.reflect().m_fieldList.ro(); }

fan.std.TypeExt.slot = function(name, checked)
{
  if (checked === undefined) checked = true;
  var slot = this.reflect().m_slotsByName[name];
  if (slot != null) return slot;
  if (checked) throw fan.sys.UnknownSlotErr.make(this.m_qname + "." + name);
  return null;
}

fan.std.TypeExt.method = function(name, checked)
{
  var slot = this.slot(name, checked);
  if (slot == null) return null;
  return fan.sys.ObjUtil.coerce(slot, fan.sys.Method.$type);
}

fan.std.TypeExt.field = function(name, checked)
{
  var slot = this.slot(name, checked);
  if (slot == null) return null;
  return fan.sys.ObjUtil.coerce(slot, fan.sys.Field.$type);
}

// addMethod
fan.std.TypeExt.$am = function(name, flags, returns, params, facets)
{
  var r = fanx_TypeParser.load(returns);
  var m = new fan.sys.Method(this, name, flags, r, params, facets);
  this.m_slotsInfo.push(m);
  return this;
}

// addField
fan.std.TypeExt.$af = function(name, flags, of, facets)
{
  var t = fanx_TypeParser.load(of);
  var f = new fan.sys.Field(this, name, flags, t, facets);
  this.m_slotsInfo.push(f);
  return this;
}

//////////////////////////////////////////////////////////////////////////
// Facets
//////////////////////////////////////////////////////////////////////////

fan.std.TypeExt.hasFacet = function(type)
{
  return this.facet(type, false) != null;
}

fan.std.TypeExt.facets = function()
{
  if (this.m_inheritedFacets == null) this.loadFacets();
  return this.m_inheritedFacets.list();
}

fan.std.TypeExt.facet = function(type, checked)
{
  if (checked === undefined) checked = true;
  if (this.m_inheritedFacets == null) this.loadFacets();
  return this.m_inheritedFacets.get(type, checked);
}

fan.std.TypeExt.loadFacets = function()
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

fan.std.TypeExt.reflect = function()
{
  if (this.m_slotsByName != null) return this;
  this.doReflect();
  return this;
}

fan.std.TypeExt.doReflect = function()
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
  this.m_slotList    = fan.sys.List.makeFromJs(fan.sys.Slot.$type, slots);
  this.m_fieldList   = fan.sys.List.makeFromJs(fan.sys.Field.$type, fields);
  this.m_methodList  = fan.sys.List.makeFromJs(fan.sys.Method.$type, methods);
  this.m_slotsByName = nameToSlot;
}

/**
 * Merge the inherit's slots into my slot maps.
 *  slots:       Slot[] by order
 *  nameToSlot:  String name -> Slot
 *  nameToIndex: String name -> Long index of slots
 */
fan.std.TypeExt.$mergeType = function(inheritedType, slots, nameToSlot, nameToIndex)
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
fan.std.TypeExt.$mergeSlot = function(slot, slots, nameToSlot, nameToIndex)
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
