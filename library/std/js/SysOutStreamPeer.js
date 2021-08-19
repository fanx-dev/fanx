fan.std.SysOutStreamPeer = function(){}


fan.std.SysOutStreamPeer.make = function(self) {
	return new fan.std.SysOutStreamPeer();
}
fan.std.SysOutStream.prototype.write = function(self, b) {
}
fan.std.SysOutStream.prototype.writeBytes = function(self, buf, off, len) {
}
fan.std.SysOutStream.prototype.sync = function(self) {
}
fan.std.SysOutStream.prototype.flush = function(self) {
}
fan.std.SysOutStream.prototype.close = function(self) {
}




/*************************************************************************
 * ConsoleOutStream
 ************************************************************************/

fan.std.ConsoleOutStream = fan.sys.Obj.$extend(fan.std.OutStream);
fan.std.ConsoleOutStream.prototype.$ctor = function()
{
  fan.std.OutStream.prototype.$ctor.call(this);
  this.m_buf = "";
  fan.std.Charset.static$init();
  fan.std.Endian.static$init();
  this.m_charset = fan.std.Charset.m_utf8;
  this.m_endian = fan.std.Endian.m_big;
}
fan.std.ConsoleOutStream.prototype.$typeof = function() { return fan.std.OutStream.$type; }


fan.std.ConsoleOutStream.prototype.endian = function() {
  return this.m_endian;
}
fan.std.ConsoleOutStream.prototype.endian$ = function(v) {
  this.m_endian = v;
}
fan.std.ConsoleOutStream.prototype.charset = function() {
  return this.m_charset;
}
fan.std.ConsoleOutStream.prototype.charset$ = function(v) {
  this.m_charset = v;
}

fan.std.ConsoleOutStream.prototype.write = function(v)
{
  if (v == 10) this.flush();
  else this.m_buf += String.fromCharCode(v)
}
fan.std.ConsoleOutStream.prototype.flush = function()
{
  if (this.m_buf.length > 0 && console) console.log(this.m_buf);
  this.m_buf = "";
}