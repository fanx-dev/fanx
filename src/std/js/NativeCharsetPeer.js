
fan.std.NativeCharsetPeer = function(){}


fan.std.NativeCharsetPeer.make = function(self) {
	return new fan.std.NativeCharsetPeer();
}

fan.std.NativeCharsetPeer.fromStr = function(name) {
	// check normalized name for predefined charsets
	var csName = name.upper();
	if (csName.equals("UTF-8"))
		return Charset.utf8;
	if (csName.equals("UTF-16BE"))
		return Charset.utf16BE;
	if (csName.equals("UTF-16LE"))
		return Charset.utf16LE;

	throw new fan.sys.UnsuppertedErr("encoder");
}

fan.std.NativeCharsetPeer.prototype.encode = function(self, ch, out) {
	throw new fan.sys.UnsuppertedErr("encoder");
}


fan.std.NativeCharsetPeer.prototype.encodeArray = function(self, ch, out, offset) {
	throw new fan.sys.UnsuppertedErr("encoder");
}

fan.std.NativeCharsetPeer.prototype.decode = function(self, input) {
	throw new fan.sys.UnsuppertedErr("encoder");
}

