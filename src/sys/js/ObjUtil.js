//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   14 Nov 09  Andy Frank  Creation
//

fan.sys.ObjUtil = function() {};

//////////////////////////////////////////////////////////////////////////
// Compare
//////////////////////////////////////////////////////////////////////////

fan.sys.ObjUtil.hash = function(obj)
{
  if (obj instanceof fan.sys.Obj) return obj.hash();

  var t = typeof obj;
  if (t === "number") return fan.sys.Int.hash(obj);
  if (t === "string") return fan.sys.Str.hash(obj);

  // TODO FIXIT
  return 0;
}

fan.sys.ObjUtil.equals = function(a, b, op)
{
  if (a == null) return b == null;
  if (a instanceof fan.sys.Obj) return a.equals(b);

  var t = typeof a;
  if (t === "number") return fan.sys.Int.equals(a, b);
  if (t === "string") return a === b;

  var f = a.$fanType;
  if (f === fan.sys.Float.$type) return fan.sys.Float.equals(a, b);
  if (f === fan.std.Decimal.$type) return fan.std.Decimal.equals(a, b);

  return a === b;
}

fan.sys.ObjUtil.compare = function(a, b, op)
{
  if (a instanceof fan.sys.Obj)
  {
    if (b == null) return +1;
    return a.compare(b);
  }
  else if (a != null && a.$fanType != null)
  {
    if (op === true && (isNaN(a) || isNaN(b))) return Number.NaN;
    return fan.sys.Float.compare(a, b);
  }
  else
  {
    if (a == null)
    {
      if (b != null) return -1;
      return 0;
    }
    if (b == null) return 1;
    if (a < b) return -1;
    if (a > b) return 1;
    return 0;
  }
}

fan.sys.ObjUtil.compareNE = function(a,b) { return !fan.sys.ObjUtil.equals(a,b); }
fan.sys.ObjUtil.compareLT = function(a,b) { return fan.sys.ObjUtil.compare(a,b,true) <  0; }
fan.sys.ObjUtil.compareLE = function(a,b) { return fan.sys.ObjUtil.compare(a,b,true) <= 0; }
fan.sys.ObjUtil.compareGE = function(a,b) { return fan.sys.ObjUtil.compare(a,b,true) >= 0; }
fan.sys.ObjUtil.compareGT = function(a,b) { return fan.sys.ObjUtil.compare(a,b,true) >  0; }

//////////////////////////////////////////////////////////////////////////
// Type
//////////////////////////////////////////////////////////////////////////

fan.sys.ObjUtil.is = function(obj, type)
{
  if (obj == null) return false;
  return fan.sys.ObjUtil.$typeof(obj).is(type);
}

fan.sys.ObjUtil.as = function(obj, type)
{
  if (obj == null) return null;
  type = type.toNonNullable();
  var t = fan.sys.ObjUtil.$typeof(obj);
  //if (t.is(fan.sys.Func.$type)) return t.as(obj, type);
  //if (t.is(fan.sys.List.$type)) return t.as(obj, type);
  //if (t.is(fan.std.Map.$type))  return t.as(obj, type);
  if (t.is(type)) return obj;
  return null;
}

fan.sys.ObjUtil.coerce = function(obj, type)
{
  if (obj == null)
  {
    if (type.isNullable()) return obj;
    throw fan.sys.NullErr.make("Coerce to non-null");
  }

  var v = fan.sys.ObjUtil.as(obj, type);
  if (v == null)
  {
    var t = fan.sys.ObjUtil.$typeof(obj);
    throw fan.sys.CastErr.make(t + " cannot be cast to " + type);
  }

  return obj;
}

fan.sys.ObjUtil.$typeof = function(obj)
{
  if (obj instanceof fan.sys.Obj) return obj.$typeof();
  else return fan.std.Type.toFanType(obj);
}

fan.sys.ObjUtil.trap = function(obj, name, args)
{
  if (obj instanceof fan.sys.Obj) return obj.trap(name, args);
  else return fan.sys.ObjUtil.doTrap(obj, name, args, fan.std.Type.toFanType(obj));
}

fan.sys.ObjUtil.doTrap = function(obj, name, args, type)
{
  var slot = type.slot(name, false);

  if (slot == null) {
    if (obj != null && name.equals("typeof")) {
      return fan.std.Type.$typeof(obj);
    }
    throw fan.sys.UnknownSlotErr.make(type.qname()+"."+name);
  }

  if (slot instanceof fan.std.Method)
  {
    return slot.invoke(obj, args);
  }
  else
  {
    var argSize = (args == null) ? 0 : args.size();
    if (argSize == 0) return slot.get(obj);
    if (argSize == 1) // one arg -> setter
    {
      var val = args.get(0);
      slot.set(obj, val);
      return val;
    }
    throw fan.sys.ArgErr.make("Invalid number of args to get or set field '" + name + "'");
  }
}

//////////////////////////////////////////////////////////////////////////
// Const
//////////////////////////////////////////////////////////////////////////

fan.sys.ObjUtil.isImmutable = function(obj)
{
  if (obj instanceof fan.sys.Obj) return obj.isImmutable();
  else if (obj == null) return true;
  else
  {
    if ((typeof obj) == "boolean" || obj instanceof Boolean) return true;
    if ((typeof obj) == "number"  || obj instanceof Number) return true;
    if ((typeof obj) == "string"  || obj instanceof String) return true;
    if (obj.$fanType != null) return true;
  }
  throw fan.sys.UnknownTypeErr.make("Not a Fantom type: " + obj);
}

fan.sys.ObjUtil.toImmutable = function(obj)
{
  if (obj instanceof fan.sys.Obj) return obj.toImmutable();
  else if (obj == null) return null;
  else
  {
    if ((typeof obj) == "boolean" || obj instanceof Boolean) return obj;
    if ((typeof obj) == "number"  || obj instanceof Number) return obj;
    if ((typeof obj) == "string"  || obj instanceof String) return obj;
    if (obj.$fanType != null) return obj;
  }
  throw fan.sys.UnknownTypeErr.make("Not a Fantom type: " + obj);
}

//////////////////////////////////////////////////////////////////////////
// with
//////////////////////////////////////////////////////////////////////////

fan.sys.ObjUtil.$with = function(self, f)
{
  if (self instanceof fan.sys.Obj)
  {
    return self.$with(f);
  }
  else
  {
    f.call(self);
    return self;
  }
}

//////////////////////////////////////////////////////////////////////////
// toStr
//////////////////////////////////////////////////////////////////////////

fan.sys.ObjUtil.toStr = function(obj)
{
  if (obj == null) return "null";
  if (typeof obj == "string") return obj;
//  if (obj.constructor == Array) return fan.sys.List.toStr(obj);

  // TODO - can't for the life of me figure how the
  // heck Error.toString would ever try to call Obj.toStr
  // so trap it for now
//  if (obj instanceof Error) return Error.prototype.toString.call(obj);

// TEMP
if (obj.$fanType === fan.sys.Float.$type) return fan.sys.Float.toStr(obj);

  return obj.toString();
}

fan.sys.ObjUtil.echo = function(obj)
{
  if (obj === undefined) obj = "";
  var s = fan.sys.ObjUtil.toStr(obj);
  try { console.log(s); }
  catch (e1)
  {
    try { print(s + "\n"); }
    catch (e2) {} //alert(s); }
  }
}

