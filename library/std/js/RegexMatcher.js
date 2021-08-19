//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Mar 10  Andy Frank  Creation
//

/**
 * RegexMatcher.
 */
fan.std.RegexMatcher = fan.sys.Obj.$extend(fan.sys.Obj);

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

fan.std.RegexMatcher.prototype.$ctor = function(regexp, source, str)
{
  this.m_regexp = regexp;
  this.m_source = source;
  this.m_str = str + "";
  this.m_match = null;
}

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

fan.std.RegexMatcher.prototype.equals = function(that) { return this === that; }

fan.std.RegexMatcher.prototype.toStr = function() { return this.m_source; }

fan.std.RegexMatcher.prototype.$typeof = function() { return fan.std.RegexMatcher.$type; }

//////////////////////////////////////////////////////////////////////////
// Matching
//////////////////////////////////////////////////////////////////////////

fan.std.RegexMatcher.prototype.matches = function()
{
  if (!this.m_regexpForMatching)
    this.m_regexpForMatching = fan.std.RegexMatcher.recompile(this.m_regexp, true);
  this.m_match = this.m_regexpForMatching.exec(this.m_str);
  this.m_wasMatch = this.m_match != null && this.m_match[0].length === this.m_str.length;
  return this.m_wasMatch;
}

fan.std.RegexMatcher.prototype.find = function()
{
  if (!this.m_regexpForMatching)
    this.m_regexpForMatching = fan.std.RegexMatcher.recompile(this.m_regexp, true);
  this.m_match = this.m_regexpForMatching.exec(this.m_str);
  this.m_wasMatch = this.m_match != null;
  return this.m_wasMatch;
}

//////////////////////////////////////////////////////////////////////////
// Replace
//////////////////////////////////////////////////////////////////////////

fan.std.RegexMatcher.prototype.replaceFirst = function(replacement)
{
  return this.m_str.replace(fan.std.RegexMatcher.recompile(this.m_regexp, false), replacement);
}

fan.std.RegexMatcher.prototype.replaceAll = function(replacement)
{
  return this.m_str.replace(fan.std.RegexMatcher.recompile(this.m_regexp, true), replacement);
}

//////////////////////////////////////////////////////////////////////////
// Group
//////////////////////////////////////////////////////////////////////////

fan.std.RegexMatcher.prototype.groupCount = function()
{
  if (!this.m_wasMatch)
    return 0;
  return this.m_match.length - 1;
}

fan.std.RegexMatcher.prototype.group = function(group)
{
  if (group === undefined) group = 0;
  if (!this.m_wasMatch)
    throw fan.sys.Err.make("No match found");
  if (group < 0 || group > this.groupCount())
    throw fan.sys.IndexErr.make(group);
  return this.m_match[group];
}

fan.std.RegexMatcher.prototype.start = function(group)
{
  if (!this.m_wasMatch)
    throw fan.sys.Err.make("No match found");
  if (group === undefined) group = 0;
  if (group < 0 || group > this.groupCount())
    throw fan.sys.IndexErr.make(group);
  if (group === 0)
    return this.m_match.index;
  throw fan.sys.UnsupportedErr.make("Not implemented in javascript");
}

fan.std.RegexMatcher.prototype.end = function(group)
{
  if (!this.m_wasMatch)
    throw fan.sys.Err.make("No match found");
  if (group === undefined) group = 0;
  if (group < 0 || group > this.groupCount())
    throw fan.sys.IndexErr.make(group);
  if (group === 0)
    return this.m_match.index + this.m_match[group].length;
  throw fan.sys.UnsupportedErr.make("Not implemented in javascript");
}

//////////////////////////////////////////////////////////////////////////
// Private
//////////////////////////////////////////////////////////////////////////

fan.std.RegexMatcher.recompile = function(regexp, global)
{
  var flags = global ? "g" : "";
  if (regexp.ignoreCase) flags += "i";
  if (regexp.multiline)  flags += "m";
  if (regexp.unicode)    flags += "u";
  return new RegExp(regexp.source, flags);
}