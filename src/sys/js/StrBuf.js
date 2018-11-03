//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   29 Dec 08  Andy Frank  Creation
//   20 May 09  Andy Frank  Refactor to new OO model
//

/**
 * StrBuf
 */
fan.sys.StrBuf = fan.sys.Obj.$extend(fan.sys.Obj);

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

fan.sys.StrBuf.prototype.$ctor = function()
{
  this.m_str = "";
}

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

fan.sys.StrBuf.prototype.$typeof = function()
{
  return fan.sys.StrBuf.$type;
}

fan.sys.StrBuf.prototype.add = function(obj)
{
  this.m_str += obj==null ? "null" : fan.sys.ObjUtil.toStr(obj);
  return this;
}

fan.sys.StrBuf.prototype.addChar = function(ch)
{
  this.m_str += String.fromCharCode(ch);
  return this;
}

fan.sys.StrBuf.prototype.capacity = function()
{
  if (this.m_capacity == null) return this.m_str.length;
  return this.m_capacity;
}
fan.sys.StrBuf.prototype.capacity$ = function(c) { this.m_capacity = c; }
fan.sys.StrBuf.prototype.m_capacity = null;

fan.sys.StrBuf.prototype.clear = function()
{
  this.m_str = "";
  return this;
}

fan.sys.StrBuf.prototype.get = function(i)
{
  if (i < 0) i = this.m_str.length+i;
  if (i < 0 || i >= this.m_str.length) throw fan.sys.IndexErr.make(i);
  return this.m_str.charCodeAt(i);
}

fan.sys.StrBuf.prototype.getRange = function(range)
{
  var size = this.m_str.length;
  var s = range.$start(size);
  var e = range.$end(size);
  if (e+1 < s) throw fan.sys.IndexErr.make(range);
  return this.m_str.substr(s, (e-s)+1);
}

fan.sys.StrBuf.prototype.set = function(i, ch)
{
  if (i < 0) i = this.m_str.length+i;
  if (i < 0 || i >= this.m_str.length) throw fan.sys.IndexErr.make(i);
  this.m_str = this.m_str.substr(0,i) + String.fromCharCode(ch) + this.m_str.substr(i+1);
  return this;
}

fan.sys.StrBuf.prototype.join = function(x, sep)
{
  if (sep === undefined) sep = " ";
  var s = (x == null) ? "null" : fan.sys.ObjUtil.toStr(x);
  if (this.m_str.length > 0) this.m_str += sep;
  this.m_str += s;
  return this;
}

fan.sys.StrBuf.prototype.insert = function(i, x)
{
  var s = (x == null) ? "null" : fan.sys.ObjUtil.toStr(x);
  if (i < 0) i = this.m_str.length+i;
  if (i < 0 || i > this.m_str.length) throw fan.sys.IndexErr.make(i);
  this.m_str = this.m_str.substr(0,i) + s + this.m_str.substr(i);
  return this;
}

fan.sys.StrBuf.prototype.remove = function(i)
{
  if (i < 0) i = this.m_str.length+i;
  if (i< 0 || i >= this.m_str.length) throw fan.sys.IndexErr.make(i);
  this.m_str = this.m_str.substr(0,i) + this.m_str.substr(i+1);
  return this;
}

fan.sys.StrBuf.prototype.removeRange = function(r)
{
  var s = r.$start(this.m_str.length);
  var e = r.$end(this.m_str.length);
  var n = e - s + 1;
  if (s < 0 || n < 0) throw fan.sys.IndexErr.make(r);
  this.m_str = this.m_str.substr(0,s) + this.m_str.substr(e+1);
  return this;
}

fan.sys.StrBuf.prototype.replaceRange = function(r, str)
{
  var s = r.$start(this.m_str.length);
  var e = r.$end(this.m_str.length);
  var n = e - s + 1;
  if (s < 0 || n < 0) throw fan.sys.IndexErr.make(r);
  this.m_str = this.m_str.substr(0,s) + str + this.m_str.substr(e+1);
  return this;
}

fan.sys.StrBuf.prototype.isEmpty = function()
{
  return this.m_str.length == 0;
}

fan.sys.StrBuf.prototype.size = function()
{
  return this.m_str.length;
}

fan.sys.StrBuf.prototype.toStr = function()
{
  return this.m_str;
}

fan.sys.StrBuf.prototype.out = function()
{
  return new fan.sys.StrBufOutStream(this);
}

//////////////////////////////////////////////////////////////////////////
// Static Methods
//////////////////////////////////////////////////////////////////////////

fan.sys.StrBuf.make = function() { return new fan.sys.StrBuf(); }