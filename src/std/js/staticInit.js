

fan.std.Map.fromLiteral = function(keys, vals)
{
  var map = fan.std.Map.make(keys.length);
  for (var i=0; i<keys.length; i++)
    map.set(keys[i], vals[i]);
  return map;
}
