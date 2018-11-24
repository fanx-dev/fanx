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
}
fan.std.ConsoleOutStream.prototype.$typeof = function() { return fan.std.SysOutStream.$type; }
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