//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 Dec 08  Andy Frank  Creation
//   20 May 09  Andy Frank  Refactor to new OO model
//

/**
 * Err
 */
fan.sys.Err = fan.sys.Obj.$extend(fan.sys.Obj);

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

fan.sys.Err.prototype.$ctor = function(msg, cause)
{
  this.$err    = new Error();
  this.m_msg   = msg;
  this.m_cause = cause;
}

fan.sys.Err.make$ = function(self, msg, cause)
{
  this.$err    = new Error();
  self.m_msg   = msg;
  self.m_cause = cause;
}

// TODO: hack to workaround how we get root errors
// mapped into the Err wrapper instance; really need
// to probably rework alot of this class to work better
fan.sys.Err.prototype.$assign = function(jsErr)
{
  this.$err = jsErr;
  return this;
}

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

fan.sys.Err.prototype.cause = function()
{
  return this.m_cause;
}

fan.sys.Err.prototype.$typeof = function()
{
  return fan.sys.Err.$type;
}

fan.sys.Err.prototype.toStr = function()
{
  return this.$typeof() + ": " + this.m_msg;
}

fan.sys.Err.prototype.msg = function()
{
  return this.m_msg;
}

fan.sys.Err.prototype.trace = function()
{
  fan.sys.ObjUtil.echo(this.traceToStr());
}

fan.sys.Err.prototype.traceToStr = function()
{
  var s = this.$typeof() + ": " + this.m_msg;
  if (this.$err.stack) s += "\n" + fan.sys.Err.cleanTrace(this.$err.stack);
  if (this.m_cause)    s += "\n  Caused by: " + this.m_cause.traceToStr();
  return s;
}

fan.sys.Err.cleanTrace = function(orig)
{
  var stack = [];
  var lines = orig.split('\n');
  for (var i=0; i<lines.length; i++)
  {
    var line = lines[i];
    if (line.indexOf("@") != -1)
    {
      // firefox
      var about = line.lastIndexOf("@");
      var slash = line.lastIndexOf("/");
      if (slash != -1)
      {
        // TODO FIXIT
        var func = "Unknown"; // line.substring(0, about)
        var sub = "  at " + func + " (" + line.substr(slash+1) + ")";
        stack.push(sub);
      }
    }
    else if (line.charAt(line.length-1) == ')')
    {
      // chrome
      var paren = line.lastIndexOf("(");
      var slash = line.lastIndexOf("/");
      var sub   = line.substring(0, paren+1) + line.substr(slash+1);
      stack.push(sub);
    }
    else
    {
      // add orig
      stack.push(line)
    }
  }
  return stack.join("\n") + "\n";
}

//////////////////////////////////////////////////////////////////////////
// Static
//////////////////////////////////////////////////////////////////////////

fan.sys.Err.make = function(err, cause)
{
  if (err instanceof fan.sys.Err) return err;
  if (err instanceof Error)
  {
    var m = err.message;
    if (m.indexOf(" from null") != -1) return fan.sys.NullErr.make(m, cause).$assign(err);
    if (m.indexOf(" of null")   != -1) return fan.sys.NullErr.make(m, cause).$assign(err);

    // TODO
    //  EvalError
    //  RangeError
    //  ReferenceError
    //  SyntaxError
    //  TypeError
    //  URIError

    // TODO: do we need to wrap `cause` too?

    return new fan.sys.Err(err.message, cause).$assign(err);
  }
  return new fan.sys.Err("" + err, cause);
}

