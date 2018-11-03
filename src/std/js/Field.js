//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   24 Mar 09  Andy Frank  Creation
//   20 May 09  Andy Frank  Refactor to new OO model
//

/**
 * Field.
 */
fan.std.Field = fan.sys.Obj.$extend(fan.sys.Slot);

//////////////////////////////////////////////////////////////////////////
// Factories
//////////////////////////////////////////////////////////////////////////

fan.std.Field.makeSetFunc = function(map)
{
  return fan.sys.Func.make(
    fan.sys.List.make(fan.sys.Param.$type),
    fan.sys.Void.$type,
    function(obj)
    {
      var keys = map.keys();
      for (var i=0; i<keys.size(); i++)
      {
        var field = keys.get(i);
        var val = map.get(field);
        field.set(obj, val, false); //, obj != inCtor);
      }
    });
}

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

fan.std.Field.prototype.$ctor = function(parent, name, flags, type, facets)
{
  this.m_parent = parent;
  this.m_name   = name;
  this.m_qname  = parent.qname() + "." + name;
  this.m_flags  = flags;
  this.m_type   = type;
  this.m_$name  = this.$$name(name);
  this.m_$qname = this.m_parent.m_$qname + '.m_' + this.m_$name;
  this.m_getter = null;
  this.m_setter = null;
  this.m_facets = new fan.sys.Facets(facets);
}

//////////////////////////////////////////////////////////////////////////
// Obj
//////////////////////////////////////////////////////////////////////////

fan.std.Field.prototype.trap = function(name, args)
{
  // private undocumented access
  if (name == "getter") return this.m_getter;
  if (name == "setter") return this.m_setter;
  return fan.sys.Obj.prototype.trap.call(this, name, args);
}

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

fan.std.Field.prototype.type = function() { return this.m_type; }

fan.std.Field.prototype.get = function(instance)
{
  if (this.isStatic())
  {
    return eval(this.m_$qname);
  }
  else
  {
    var target = instance;
    if ((this.m_flags & fan.sys.FConst.Native) != 0)
      target = instance.peer;
    var getter = target[this.m_$name];
    if (getter != null)
      return getter.call(target);
    else
      return target["m_"+this.m_$name]
  }
}

fan.std.Field.prototype.set = function(instance, value, checkConst)
{
  if (checkConst === undefined) checkConst = true;

  // check const
  if ((this.m_flags & fan.sys.FConst.Const) != 0)
  {
    if (checkConst)
      throw fan.sys.ReadonlyErr.make("Cannot set const field " + this.m_qname);
    else if (value != null && !fan.sys.ObjUtil.isImmutable(value))
      throw fan.sys.ReadonlyErr.make("Cannot set const field " + this.m_qname + " with mutable value");
  }

  // check static
  if ((this.m_flags & fan.sys.FConst.Static) != 0) // && !parent.isJava())
    throw fan.sys.ReadonlyErr.make("Cannot set static field " + this.m_qname);

  // check type
  if (value != null && !fan.sys.ObjUtil.$typeof(value).is(this.m_type.toNonNullable()))
    throw fan.sys.ArgErr.make("Wrong type for field " + this.m_qname + ": " + this.m_type + " != " + fan.sys.ObjUtil.$typeof(value));

  // TODO
  //if (setter != null)
  //{
  //  setter.invoke(instance, new Object[] { value });
  //  return;
  //}

  if ((this.m_flags & fan.sys.FConst.Native) != 0)
  {
    var peer = instance.peer;
    var setter = peer[this.m_$name + "$"];
    setter.call(peer, instance, value);
  }
  else
  {
    var setter = instance[this.m_$name + "$"];
    if (setter != null)
      setter.call(instance, value);
    else
      instance["m_"+this.m_$name] = value;
  }
}

fan.std.Field.prototype.$typeof = function() { return fan.std.Field.$type; }

