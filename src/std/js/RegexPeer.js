fan.std.RegexPeer = function(){}

fan.std.RegexPeer.make = function(self) {
  return new fan.std.RegexPeer();
}

fan.std.RegexPeer.prototype.init = function(self) {
    self.m_regexp = new RegExp(self.m_source);
}

fan.std.RegexPeer.prototype.matches = function(self, s)
{
  return this.matcher(s).matches();
}

fan.std.RegexPeer.prototype.matcher = function(self, s)
{
  return new fan.std.RegexMatcher(self.m_regexp, self.m_source, s);
}

fan.std.RegexPeer.prototype.split = function(self, s, limit)
{
  if (limit === undefined) limit = 0;

  if (limit === 1)
    return fan.sys.List.makeFromJs(fan.sys.Str.$type, [s]);

  var array = [];
  var re = self.m_regexp;
  while (true)
  {
    var m = s.match(re);
    if (m == null || (limit != 0 && array.length == limit -1))
    {
      array.push(s);
      break;
    }
    array.push(s.substring(0, m.index));
    s = s.substring(m.index + m[0].length);
  }
  // remove trailing empty strings
  if (limit == 0)
  {
    while (array[array.length-1] == "") { array.pop(); }
  }
  return fan.sys.List.makeFromJs(fan.sys.Str.$type, array);
}

