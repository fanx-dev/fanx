
fan.std.SysInStreamPeer.make = function(self) {
  return new fan.std.SysInStreamPeer();
}

fan.std.SysInStreamPeer.prototype.avail = function(self) {
}
fan.std.SysInStreamPeer.prototype.read = function(self) {
}
fan.std.SysInStreamPeer.prototype.skip = function(self, n) {
}
fan.std.SysInStreamPeer.prototype.readBytes = function(self, ba, off, len) {
}
fan.std.SysInStreamPeer.prototype.unread = function(self, n) {
}
fan.std.SysInStreamPeer.prototype.close = function(self) {
}

fan.std.SysInStreamPeer.toSigned = function(val, num) {
  var c = val;
  switch (num) {
  case 1:
    return c <= 0x7F ? c : (0xFFFFFF00 | c);
  case 2:
    return c <= 0x7FFF ? c : (0xFFFF0000 | c);
  case 4:
    return (c & 0x7FFFFFFF) + Math.pow(2, 31);
  }
  return val;
}
