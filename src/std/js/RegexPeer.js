fan.std.RegexPeer = function(){}


fan.std.RegexPeer.matches = function(self, s)
{
  return this.matcher(s).matches();
}

fan.std.RegexPeer.matcher = function(self, s)
{
  if (self.m_regexp === undefined) self.m_regexp = new RegExp(self.m_source);
  return new fan.std.RegexMatcher(self.m_regexp, self.m_source, s);
}

fan.std.RegexPeer.split = function(self, s, limit)
{
  if (limit === undefined) limit = 0;

  if (limit === 1)
    return fan.sys.List.make(fan.sys.Str.$type, [s]);

  var array = [];
  if (self.m_regexp === undefined) self.m_regexp = new RegExp(self.m_source);
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
  return fan.sys.List.make(fan.sys.Str.$type, array);
}

